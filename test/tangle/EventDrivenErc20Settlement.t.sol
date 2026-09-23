// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BaseTest } from "../BaseTest.sol";
import { Tangle } from "../../src/Tangle.sol";
import { Types } from "../../src/libraries/Types.sol";
import { Errors } from "../../src/libraries/Errors.sol";
import { BlueprintServiceManagerBase } from "../../src/BlueprintServiceManagerBase.sol";
import { MockERC20 } from "../mocks/MockERC20.sol";
import { MockToken } from "../mocks/MockToken.sol";
import { TangleJobsRFQFacet } from "../../src/facets/tangle/TangleJobsRFQFacet.sol";

/// @notice Blueprint manager that allow-lists a single settlement asset for both request-time
///         and job-time payment-asset checks (context id is ignored, so the same answer holds
///         for `requestContextId` and `serviceId`).
contract AllowAssetManager is BlueprintServiceManagerBase {
    mapping(address => bool) internal _allowed;

    function setAllowed(address asset, bool allowed) external {
        _allowed[asset] = allowed;
    }

    function queryIsPaymentAssetAllowed(uint64, address asset) external view override returns (bool) {
        return _allowed[asset];
    }
}

/// @title EventDrivenErc20SettlementTest
/// @notice Covers the generalized EventDriven per-job settlement asset: an EventDriven service
///         may settle per-job billing in native OR a manager-allowed ERC20 (e.g. Tempo PathUSD).
///         AUDITED FINANCIAL code — every path (happy, back-compat, fail-closed) is exercised.
contract EventDrivenErc20SettlementTest is BaseTest {
    uint256 internal constant OPERATOR1_PK = 0x1A;
    uint256 internal constant OPERATOR2_PK = 0x2B;

    MockERC20 internal settleToken; // 18-decimal allow-listed settlement token
    // One BlueprintServiceManagerBase instance backs exactly ONE blueprint (its
    // `onBlueprintCreated` is single-init), so each blueprint gets its own manager.
    AllowAssetManager internal manager; // backs erc20Blueprint; de-list tests mutate this one
    AllowAssetManager internal nativeManager; // backs nativeBlueprint

    uint64 internal erc20Blueprint; // EventDriven, settles in `settleToken`
    uint64 internal nativeBlueprint; // EventDriven, settles in native (address(0))
    uint64 internal erc20Service;
    uint64 internal nativeService;

    uint256 internal constant RATE = 10 ether; // per-job rate (18-dec token units)

    function setUp() public override {
        super.setUp();

        operator1 = vm.addr(OPERATOR1_PK);
        operator2 = vm.addr(OPERATOR2_PK);
        vm.deal(operator1, 100 ether);
        vm.deal(operator2, 100 ether);

        // Register the RFQ facet so submitJobFromQuote is routable. Deploy the facet FIRST so
        // the `new` does not consume the admin prank; then register under the prank.
        TangleJobsRFQFacet rfqFacet = new TangleJobsRFQFacet();
        vm.prank(admin);
        Tangle(payable(address(tangleProxy))).registerFacet(address(rfqFacet));

        settleToken = new MockERC20();
        settleToken.mint(user1, 1_000_000 ether);

        manager = new AllowAssetManager();
        manager.setAllowed(address(settleToken), true);
        manager.setAllowed(address(0), true);

        nativeManager = new AllowAssetManager();
        nativeManager.setAllowed(address(0), true);

        Types.BlueprintConfig memory cfg = Types.BlueprintConfig({
            membership: Types.MembershipModel.Fixed,
            pricing: Types.PricingModel.EventDriven,
            minOperators: 1,
            maxOperators: 10,
            subscriptionRate: 0,
            subscriptionInterval: 0,
            eventRate: RATE
        });

        vm.startPrank(developer);
        erc20Blueprint =
            tangle.createBlueprint(_blueprintDefinitionWithConfig("ipfs://ed-erc20", address(manager), cfg));
        nativeBlueprint =
            tangle.createBlueprint(_blueprintDefinitionWithConfig("ipfs://ed-native", address(nativeManager), cfg));
        vm.stopPrank();

        _registerOperator(operator1, 5 ether);
        _registerOperator(operator2, 5 ether);
        _registerForBlueprint(operator1, erc20Blueprint);
        _registerForBlueprint(operator2, erc20Blueprint);
        _registerForBlueprint(operator1, nativeBlueprint);
        _registerForBlueprint(operator2, nativeBlueprint);

        erc20Service = _activateEventDrivenService(erc20Blueprint, address(settleToken));
        nativeService = _activateEventDrivenService(nativeBlueprint, address(0));
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // getServicePaymentAsset VIEW
    // ═══════════════════════════════════════════════════════════════════════════

    function test_GetServicePaymentAsset_Erc20() public view {
        assertEq(tangle.getServicePaymentAsset(erc20Service), address(settleToken));
    }

    function test_GetServicePaymentAsset_NativeReturnsZero() public view {
        assertEq(tangle.getServicePaymentAsset(nativeService), address(0));
    }

    function test_GetServicePaymentAsset_UnknownServiceReturnsZero() public view {
        // Non-EventDriven / unknown ids default to the native sentinel.
        assertEq(tangle.getServicePaymentAsset(9999), address(0));
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // ERC20 HAPPY PATH
    // ═══════════════════════════════════════════════════════════════════════════

    function test_Erc20_SubmitJob_TransfersViaTransferFrom_AndDistributes() public {
        uint256 userBefore = settleToken.balanceOf(user1);
        uint256 devBefore = settleToken.balanceOf(developer);
        uint256 treasuryBefore = settleToken.balanceOf(treasury);
        uint256 tangleBefore = settleToken.balanceOf(address(tangle));

        // Job submitter must approve the Tangle and send NO native value.
        vm.startPrank(user1);
        settleToken.approve(address(tangle), RATE);
        uint64 callId = tangle.submitJob(erc20Service, 0, "");
        vm.stopPrank();

        // Payment recorded in the ERC20, pulled via transferFrom (user spent exactly RATE).
        Types.JobCall memory job = tangle.getJobCall(erc20Service, callId);
        assertEq(job.payment, RATE, "job payment must equal rate");
        assertEq(userBefore - settleToken.balanceOf(user1), RATE, "user must spend exactly RATE in the ERC20");

        // Complete the job -> distribution fires in the ERC20.
        vm.prank(operator1);
        tangle.submitResult(erc20Service, callId, "");

        assertTrue(tangle.getJobCall(erc20Service, callId).completed, "job must be completed");

        // Split defaults: 20% dev (push), 20% treasury (push), 40% operator + 20% staker.
        // No security commitments -> staker folds into operator pool = 60% accrued as pending,
        // split across the TWO service operators by weight (equal exposure -> even halves).
        uint256 devShare = (RATE * 2000) / 10_000;
        uint256 protoShare = (RATE * 2000) / 10_000;
        uint256 opPool = RATE - devShare - protoShare; // remaining 60%, shared by both operators

        assertEq(settleToken.balanceOf(developer) - devBefore, devShare, "developer ERC20 share");
        assertEq(settleToken.balanceOf(treasury) - treasuryBefore, protoShare, "treasury ERC20 share");

        uint256 op1Pending = tangle.pendingRewards(operator1, address(settleToken));
        uint256 op2Pending = tangle.pendingRewards(operator2, address(settleToken));
        assertEq(op1Pending + op2Pending, opPool, "operator pool split across both operators");
        assertEq(op1Pending, opPool / 2, "operator1 gets its weighted half");

        // Conservation: only the (undistributed-to-claim) operator pool remains in the Tangle.
        assertEq(settleToken.balanceOf(address(tangle)) - tangleBefore, opPool, "residual held == operator pool");

        // Operator can claim the ERC20 reward.
        uint256 opTokenBefore = settleToken.balanceOf(operator1);
        vm.prank(operator1);
        tangle.claimRewards(address(settleToken));
        assertEq(settleToken.balanceOf(operator1) - opTokenBefore, op1Pending, "operator claimed ERC20 reward");
        assertEq(tangle.pendingRewards(operator1, address(settleToken)), 0, "pending cleared after claim");
    }

    function test_Erc20_SubmitJob_UsesPerJobRateOverride() public {
        uint256 override_ = 25 ether;
        uint8[] memory idx = new uint8[](1);
        idx[0] = 0;
        uint256[] memory rates = new uint256[](1);
        rates[0] = override_;
        vm.prank(developer);
        tangle.setJobEventRates(erc20Blueprint, idx, rates);

        vm.startPrank(user1);
        settleToken.approve(address(tangle), override_);
        uint64 callId = tangle.submitJob(erc20Service, 0, "");
        vm.stopPrank();

        assertEq(tangle.getJobCall(erc20Service, callId).payment, override_);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // NATIVE BACK-COMPAT
    // ═══════════════════════════════════════════════════════════════════════════

    function test_Native_SubmitJob_UnchangedBehavior() public {
        uint256 devBefore = developer.balance;
        uint256 treasuryBefore = treasury.balance;

        // Native EventDriven: value == payment, exactly as before this change.
        vm.prank(user1);
        uint64 callId = tangle.submitJob{ value: RATE }(nativeService, 0, "");

        assertEq(tangle.getJobCall(nativeService, callId).payment, RATE);

        vm.prank(operator1);
        tangle.submitResult(nativeService, callId, "");

        uint256 devShare = (RATE * 2000) / 10_000;
        uint256 protoShare = (RATE * 2000) / 10_000;
        uint256 opPool = RATE - devShare - protoShare; // 60%, split across both operators

        assertEq(developer.balance - devBefore, devShare, "developer native share");
        assertEq(treasury.balance - treasuryBefore, protoShare, "treasury native share");
        assertEq(
            tangle.pendingRewards(operator1) + tangle.pendingRewards(operator2),
            opPool,
            "operator pool split across both operators"
        );
        assertEq(tangle.pendingRewards(operator1), opPool / 2, "operator1 gets its weighted half");
    }

    function test_Native_RequestService_NoManagerGateForNative() public {
        // A native EventDriven REQUEST must not require the manager to allow `address(0)` at
        // request time: build a blueprint whose manager allow-lists NOTHING and confirm the
        // native request still activates. (This is the request-time behavior my change
        // preserves — the job-time native gate is a separate, pre-existing check.)
        AllowAssetManager strictManager = new AllowAssetManager();
        // Deliberately allow nothing at request time.

        Types.BlueprintConfig memory cfg = Types.BlueprintConfig({
            membership: Types.MembershipModel.Fixed,
            pricing: Types.PricingModel.EventDriven,
            minOperators: 1,
            maxOperators: 10,
            subscriptionRate: 0,
            subscriptionInterval: 0,
            eventRate: RATE
        });
        vm.prank(developer);
        uint64 bp = tangle.createBlueprint(
            _blueprintDefinitionWithConfig("ipfs://ed-native-strict", address(strictManager), cfg)
        );
        _registerForBlueprint(operator1, bp);
        _registerForBlueprint(operator2, bp);

        // The request activates without the manager allow-listing native — no request-time
        // TokenNotAllowed revert — and the service's settlement asset is native.
        uint64 svc = _activateEventDrivenService(bp, address(0));
        assertEq(tangle.getServicePaymentAsset(svc), address(0));

        // Now allow native so the (pre-existing) job-time gate passes, and confirm a native
        // job settles exactly as before.
        strictManager.setAllowed(address(0), true);
        vm.prank(user1);
        uint64 callId = tangle.submitJob{ value: RATE }(svc, 0, "");
        assertEq(tangle.getJobCall(svc, callId).payment, RATE);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // FAIL-CLOSED
    // ═══════════════════════════════════════════════════════════════════════════

    function test_FailClosed_RequestDisallowedErc20Reverts() public {
        // A second, un-allowlisted token.
        MockERC20 badToken = new MockERC20();
        badToken.mint(user1, 1000 ether);

        address[] memory ops = new address[](1);
        ops[0] = operator1;
        address[] memory callers = new address[](0);

        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(Errors.TokenNotAllowed.selector, address(badToken)));
        tangle.requestService(
            erc20Blueprint, ops, "", callers, 0, address(badToken), 0, Types.ConfidentialityPolicy.Any
        );
    }

    function test_FailClosed_NativeValueOnErc20ServiceReverts() public {
        // ERC20-settlement service: sending native value must revert in collectPayment
        // (ERC20 path requires msgValue == 0).
        vm.startPrank(user1);
        settleToken.approve(address(tangle), RATE);
        vm.expectRevert(abi.encodeWithSelector(Errors.InvalidMsgValue.selector, 0, RATE));
        tangle.submitJob{ value: RATE }(erc20Service, 0, "");
        vm.stopPrank();
    }

    function test_FailClosed_MissingApprovalOnErc20ServiceReverts() public {
        // No approval -> transferFrom reverts inside collectPayment.
        vm.prank(user1);
        vm.expectRevert();
        tangle.submitJob(erc20Service, 0, "");
    }

    function test_FailClosed_ZeroValueOnNativeServiceReverts() public {
        // Native service with payment > 0: submitting with value 0 must revert
        // (native path requires msgValue == payment).
        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(Errors.InvalidMsgValue.selector, RATE, 0));
        tangle.submitJob(nativeService, 0, "");
    }

    function test_FailClosed_ManagerDelistsErc20AfterActivation() public {
        // Manager de-lists the settlement token AFTER activation: per-job collection must
        // fail closed at submit time even though the token was allowed at request time.
        manager.setAllowed(address(settleToken), false);

        vm.startPrank(user1);
        settleToken.approve(address(tangle), RATE);
        vm.expectRevert(abi.encodeWithSelector(Errors.TokenNotAllowed.selector, address(settleToken)));
        tangle.submitJob(erc20Service, 0, "");
        vm.stopPrank();
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // RFQ IN ERC20
    // ═══════════════════════════════════════════════════════════════════════════

    function test_Erc20_SubmitJobFromQuote_SettlesInErc20() public {
        uint256 price = 30 ether;
        Types.SignedJobQuote[] memory quotes = new Types.SignedJobQuote[](1);
        quotes[0] = _createJobQuote(operator1, OPERATOR1_PK, erc20Service, 0, price);

        uint256 userBefore = settleToken.balanceOf(user1);

        vm.startPrank(user1);
        settleToken.approve(address(tangle), price);
        uint64 callId = tangle.submitJobFromQuote(erc20Service, 0, "", quotes);
        vm.stopPrank();

        assertEq(tangle.getJobCall(erc20Service, callId).payment, price);
        assertTrue(tangle.getJobCall(erc20Service, callId).isRFQ);
        assertEq(userBefore - settleToken.balanceOf(user1), price, "RFQ pulled ERC20 via transferFrom");

        // Complete -> the single quoted operator is paid its full quote in the ERC20.
        vm.prank(operator1);
        tangle.submitResult(erc20Service, callId, "");
        assertTrue(tangle.getJobCall(erc20Service, callId).completed);

        uint256 devShare = (price * 2000) / 10_000;
        uint256 protoShare = (price * 2000) / 10_000;
        uint256 opShare = price - devShare - protoShare;
        assertEq(tangle.pendingRewards(operator1, address(settleToken)), opShare, "RFQ operator ERC20 share");
    }

    function test_Erc20_SubmitJobFromQuote_NativeValueReverts() public {
        uint256 price = 30 ether;
        Types.SignedJobQuote[] memory quotes = new Types.SignedJobQuote[](1);
        quotes[0] = _createJobQuote(operator1, OPERATOR1_PK, erc20Service, 0, price);

        vm.startPrank(user1);
        settleToken.approve(address(tangle), price);
        vm.expectRevert(abi.encodeWithSelector(Errors.InvalidMsgValue.selector, 0, price));
        tangle.submitJobFromQuote{ value: price }(erc20Service, 0, "", quotes);
        vm.stopPrank();
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // DECIMALS NOTE: 6-decimal settlement token (e.g. Tempo PathUSD)
    // ═══════════════════════════════════════════════════════════════════════════

    function test_SixDecimalToken_RateIsInTokenSmallestUnit() public {
        MockToken usd = new MockToken("PathUSD", "pUSD", 6);
        usd.mint(user1, 1_000_000e6);

        AllowAssetManager usdManager = new AllowAssetManager();
        usdManager.setAllowed(address(usd), true);

        // Rate is 5.00 pUSD expressed in the token's 6-decimal smallest unit.
        uint256 usdRate = 5e6;
        Types.BlueprintConfig memory cfg = Types.BlueprintConfig({
            membership: Types.MembershipModel.Fixed,
            pricing: Types.PricingModel.EventDriven,
            minOperators: 1,
            maxOperators: 10,
            subscriptionRate: 0,
            subscriptionInterval: 0,
            eventRate: usdRate
        });
        vm.prank(developer);
        uint64 bp = tangle.createBlueprint(_blueprintDefinitionWithConfig("ipfs://ed-usd", address(usdManager), cfg));
        _registerForBlueprint(operator1, bp);
        _registerForBlueprint(operator2, bp);

        uint64 svc = _activateEventDrivenService(bp, address(usd));
        assertEq(tangle.getServicePaymentAsset(svc), address(usd));

        uint256 userBefore = usd.balanceOf(user1);
        vm.startPrank(user1);
        usd.approve(address(tangle), usdRate);
        uint64 callId = tangle.submitJob(svc, 0, "");
        vm.stopPrank();

        // Exactly 5.00 pUSD (5e6 units) collected — the rate is denominated in the settlement
        // asset's smallest unit, not a fixed 18-decimal scale.
        assertEq(tangle.getJobCall(svc, callId).payment, usdRate);
        assertEq(userBefore - usd.balanceOf(user1), usdRate);

        vm.prank(operator1);
        tangle.submitResult(svc, callId, "");

        uint256 devShare = (usdRate * 2000) / 10_000;
        uint256 protoShare = (usdRate * 2000) / 10_000;
        uint256 opPool = usdRate - devShare - protoShare; // split across both operators
        assertEq(usd.balanceOf(developer), devShare, "developer pUSD share");
        assertEq(usd.balanceOf(treasury), protoShare, "treasury pUSD share");
        assertEq(
            tangle.pendingRewards(operator1, address(usd)) + tangle.pendingRewards(operator2, address(usd)),
            opPool,
            "operator pUSD pool split across both operators"
        );
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // FUZZ
    // ═══════════════════════════════════════════════════════════════════════════

    function testFuzz_Erc20_SubmitJob_VariableRate(uint128 rawRate) public {
        uint256 rate = uint256(rawRate);
        vm.assume(rate >= 100); // PaymentLib.MINIMUM_PAYMENT_AMOUNT
        vm.assume(rate <= 100_000 ether);

        settleToken.mint(user1, rate);

        uint8[] memory idx = new uint8[](1);
        idx[0] = 0;
        uint256[] memory rates = new uint256[](1);
        rates[0] = rate;
        vm.prank(developer);
        tangle.setJobEventRates(erc20Blueprint, idx, rates);

        uint256 userBefore = settleToken.balanceOf(user1);
        vm.startPrank(user1);
        settleToken.approve(address(tangle), rate);
        uint64 callId = tangle.submitJob(erc20Service, 0, "");
        vm.stopPrank();

        assertEq(tangle.getJobCall(erc20Service, callId).payment, rate);
        assertEq(userBefore - settleToken.balanceOf(user1), rate);

        vm.prank(operator1);
        tangle.submitResult(erc20Service, callId, "");
        assertTrue(tangle.getJobCall(erc20Service, callId).completed);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // HELPERS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Request + fully approve a 2-operator EventDriven service settling in `asset`.
    function _activateEventDrivenService(uint64 blueprintId, address asset) internal returns (uint64 serviceId) {
        address[] memory ops = new address[](2);
        ops[0] = operator1;
        ops[1] = operator2;
        address[] memory callers = new address[](0);

        vm.prank(user1);
        uint64 requestId =
            tangle.requestService(blueprintId, ops, "", callers, 0, asset, 0, Types.ConfidentialityPolicy.Any);

        vm.prank(operator1);
        tangle.approveService(_approve(requestId));
        vm.prank(operator2);
        tangle.approveService(_approve(requestId));

        serviceId = tangle.serviceCount() - 1;
    }

    function _createJobQuote(
        address operator,
        uint256 privateKey,
        uint64 serviceId,
        uint8 jobIndex,
        uint256 price
    )
        internal
        view
        returns (Types.SignedJobQuote memory)
    {
        Types.JobQuoteDetails memory details = Types.JobQuoteDetails({
            requester: user1,
            serviceId: serviceId,
            jobIndex: jobIndex,
            price: price,
            timestamp: uint64(block.timestamp),
            expiry: uint64(block.timestamp) + 1 hours,
            confidentiality: 0,
            inputsHash: keccak256("")
        });

        bytes32 typeHash = keccak256(
            "JobQuoteDetails(address requester,uint64 serviceId,uint8 jobIndex,uint256 price,uint64 timestamp,uint64 expiry,uint8 confidentiality,bytes32 inputsHash)"
        );
        bytes32 domainSeparator = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256("TangleQuote"),
                keccak256("1"),
                block.chainid,
                address(tangle)
            )
        );
        bytes32 structHash = keccak256(
            abi.encode(
                typeHash,
                details.requester,
                details.serviceId,
                details.jobIndex,
                details.price,
                details.timestamp,
                details.expiry,
                details.confidentiality,
                details.inputsHash
            )
        );
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, digest);
        return Types.SignedJobQuote({ details: details, signature: abi.encodePacked(r, s, v), operator: operator });
    }
}
