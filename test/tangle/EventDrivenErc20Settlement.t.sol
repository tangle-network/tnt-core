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

/// @notice Blueprint manager that allow-lists a single settlement asset for both the
///         blueprint-time (`setBlueprintSettlementAsset`) and job-time payment-asset checks
///         (context id is ignored, so the same answer holds for `blueprintId` and `serviceId`).
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
///         may settle per-job billing in native OR a manager-allowed ERC20 (e.g. Tempo PathUSD),
///         with the settlement asset chosen by the blueprint DEVELOPER at the blueprint level
///         (same party that sets the per-job rate), NOT by the customer at request time.
///         AUDITED FINANCIAL code — every path (happy, back-compat, fail-closed, exploit) is
///         exercised.
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

    bytes32 private constant QUOTE_TYPEHASH = keccak256(
        "QuoteDetails(address requester,uint64 blueprintId,uint64 ttlBlocks,uint256 totalCost,uint64 timestamp,uint64 expiry,uint8 confidentiality,uint8 operation,uint64 serviceId,AssetSecurityCommitment[] securityCommitments,ResourceCommitment[] resourceCommitments)Asset(uint8 kind,address token)AssetSecurityCommitment(Asset asset,uint16 exposureBps)ResourceCommitment(uint8 kind,uint64 count)"
    );

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
        // Developer declares the settlement asset ON THE BLUEPRINT. The native blueprint is
        // left at the address(0) default (no setter call) to prove native back-compat.
        tangle.setBlueprintSettlementAsset(erc20Blueprint, address(settleToken));
        vm.stopPrank();

        _registerOperator(operator1, 5 ether);
        _registerOperator(operator2, 5 ether);
        _registerForBlueprint(operator1, erc20Blueprint);
        _registerForBlueprint(operator2, erc20Blueprint);
        _registerForBlueprint(operator1, nativeBlueprint);
        _registerForBlueprint(operator2, nativeBlueprint);

        erc20Service = _activateEventDrivenService(erc20Blueprint);
        nativeService = _activateEventDrivenService(nativeBlueprint);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // BLUEPRINT SETTLEMENT ASSET (setter auth + validation + view)
    // ═══════════════════════════════════════════════════════════════════════════

    function test_GetBlueprintSettlementAsset_Erc20() public view {
        assertEq(tangle.getBlueprintSettlementAsset(erc20Blueprint), address(settleToken));
    }

    function test_GetBlueprintSettlementAsset_NativeDefaultIsZero() public view {
        // Never set on the native blueprint -> defaults to the native sentinel.
        assertEq(tangle.getBlueprintSettlementAsset(nativeBlueprint), address(0));
    }

    function test_SetBlueprintSettlementAsset_OnlyOwner() public {
        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(Errors.NotBlueprintOwner.selector, erc20Blueprint, user1));
        tangle.setBlueprintSettlementAsset(erc20Blueprint, address(settleToken));
    }

    function test_SetBlueprintSettlementAsset_RejectsManagerDisallowedToken() public {
        MockERC20 badToken = new MockERC20();
        vm.prank(developer);
        vm.expectRevert(abi.encodeWithSelector(Errors.TokenNotAllowed.selector, address(badToken)));
        tangle.setBlueprintSettlementAsset(erc20Blueprint, address(badToken));
    }

    function test_SetBlueprintSettlementAsset_NativeAlwaysAllowed() public {
        // Even a manager that allow-lists nothing must accept native (address(0)).
        AllowAssetManager strict = new AllowAssetManager();
        Types.BlueprintConfig memory cfg = _edConfig(RATE);
        vm.startPrank(developer);
        uint64 bp = tangle.createBlueprint(_blueprintDefinitionWithConfig("ipfs://ed-strict", address(strict), cfg));
        tangle.setBlueprintSettlementAsset(bp, address(0)); // must not revert
        vm.stopPrank();
        assertEq(tangle.getBlueprintSettlementAsset(bp), address(0));
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // getServicePaymentAsset VIEW (pinned from the BLUEPRINT, not the request)
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
    // CUSTOMER CANNOT CHOOSE THE ASSET (root-cause guard)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice (a) An EventDriven request with a non-zero paymentToken reverts — the customer
    ///         cannot pick the settlement asset. The asset comes wholly from the blueprint.
    function test_Request_CustomerCannotChooseErc20Asset() public {
        address[] memory ops = new address[](1);
        ops[0] = operator1;
        address[] memory callers = new address[](0);

        // Even the blueprint's OWN allow-listed settlement token is rejected as a request-time
        // paymentToken: EventDriven requests must be native. The asset is not the customer's.
        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(Errors.TokenNotAllowed.selector, address(settleToken)));
        tangle.requestService(
            erc20Blueprint, ops, "", callers, 0, address(settleToken), 0, Types.ConfidentialityPolicy.Any
        );
    }

    /// @notice (a) A non-native paymentToken NOT on the blueprint's asset is likewise rejected —
    ///         same revert, because the check is "EventDriven request must be native", not a
    ///         per-token allow-list.
    function test_Request_CustomerCannotChooseArbitraryAsset() public {
        MockERC20 badToken = new MockERC20();
        address[] memory ops = new address[](1);
        ops[0] = operator1;
        address[] memory callers = new address[](0);

        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(Errors.TokenNotAllowed.selector, address(badToken)));
        tangle.requestService(
            erc20Blueprint, ops, "", callers, 0, address(badToken), 0, Types.ConfidentialityPolicy.Any
        );
    }

    /// @notice (b) With the blueprint's asset = ERC20, jobs settle in that token via transferFrom
    ///         and the customer CANNOT force native — supplying native value reverts.
    function test_Erc20_Blueprint_SettlesInErc20_CustomerCannotForceNative() public {
        // The service pinned the blueprint's ERC20 asset (proven by the view).
        assertEq(tangle.getServicePaymentAsset(erc20Service), address(settleToken));

        // Native value on the ERC20 service reverts (collectPayment requires msgValue == 0).
        vm.startPrank(user1);
        settleToken.approve(address(tangle), RATE);
        vm.expectRevert(abi.encodeWithSelector(Errors.InvalidMsgValue.selector, 0, RATE));
        tangle.submitJob{ value: RATE }(erc20Service, 0, "");
        vm.stopPrank();

        // The correct path settles in the ERC20.
        vm.startPrank(user1);
        settleToken.approve(address(tangle), RATE);
        uint64 callId = tangle.submitJob(erc20Service, 0, "");
        vm.stopPrank();
        assertEq(tangle.getJobCall(erc20Service, callId).payment, RATE);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // EXPLOIT (c): a 6-dec-scale rate CANNOT be driven to settle in native
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice (c) The original 10^12x under-payment exploit, proven dead. A blueprint authors a
    ///         6-decimal PathUSD rate (5e6 = 5.00 pUSD). PRE-FIX, the customer chose the
    ///         settlement asset at request time: passing native `address(0)` pinned a
    ///         NATIVE-settling service, so every job settled at 5e6 wei = 5e-12 TNT (~$0) while
    ///         consuming real compute priced at $5.00. POST-FIX, the settlement asset is sourced
    ///         wholly from the blueprint (the developer's pUSD), independent of what the customer
    ///         passes. The customer's request MUST be native `address(0)` (it is not a choice —
    ///         a non-native request reverts), and the resulting service still settles in pUSD.
    ///         So:
    ///           1. the customer cannot request a NON-native asset (reverts, tested elsewhere);
    ///           2. requesting native `address(0)` — the pre-fix exploit trigger — no longer
    ///              yields a native-settling service: it settles in the blueprint's pUSD; and
    ///           3. every job collects 5e6 pUSD UNITS (5.00 pUSD), never 5e6 wei of native, and
    ///              native value is rejected outright.
    ///         There is NO code path to a service whose settlement asset differs from its
    ///         blueprint's declared asset.
    function test_Exploit_SixDecimalRateCannotSettleInNative() public {
        MockToken usd = new MockToken("PathUSD", "pUSD", 6);
        usd.mint(user1, 1_000_000e6);

        AllowAssetManager usdManager = new AllowAssetManager();
        usdManager.setAllowed(address(usd), true);

        uint256 usdRate = 5e6; // 5.00 pUSD in 6-dec smallest units — the exploit's rate.
        Types.BlueprintConfig memory cfg = _edConfig(usdRate);

        vm.startPrank(developer);
        uint64 bp =
            tangle.createBlueprint(_blueprintDefinitionWithConfig("ipfs://ed-exploit", address(usdManager), cfg));
        tangle.setBlueprintSettlementAsset(bp, address(usd));
        vm.stopPrank();
        _registerForBlueprint(operator1, bp);
        _registerForBlueprint(operator2, bp);

        address[] memory ops = new address[](2);
        ops[0] = operator1;
        ops[1] = operator2;
        address[] memory callers = new address[](0);

        // ATTACK: request the service passing native `address(0)` — the exact input that PRE-FIX
        // pinned a native-settling service and enabled the 10^12x under-payment. The request
        // succeeds (native is the mandatory request asset), but crucially the service pins the
        // BLUEPRINT's pUSD asset, NOT native. The customer's native input does NOT choose the
        // settlement asset.
        vm.prank(user1);
        uint64 requestId =
            tangle.requestService(bp, ops, "", callers, 0, address(0), 0, Types.ConfidentialityPolicy.Any);
        vm.prank(operator1);
        tangle.approveService(_approve(requestId));
        vm.prank(operator2);
        tangle.approveService(_approve(requestId));
        uint64 svc = tangle.serviceCount() - 1;

        assertEq(
            tangle.getServicePaymentAsset(svc),
            address(usd),
            "native request STILL settles in the blueprint's pUSD - the exploit's native pin is gone"
        );

        // The customer cannot pay the pUSD-priced job with native value: the ERC20 path requires
        // msgValue == 0. Native cannot be substituted to under-pay.
        vm.startPrank(user1);
        usd.approve(address(tangle), usdRate);
        vm.expectRevert(abi.encodeWithSelector(Errors.InvalidMsgValue.selector, 0, usdRate));
        tangle.submitJob{ value: usdRate }(svc, 0, "");
        vm.stopPrank();

        // The only reachable path collects exactly 5e6 pUSD UNITS (5.00 pUSD), never 5e6 wei of
        // native. If the exploit were live, `payment` would be 5e6 wei of a NATIVE-settling
        // service (5e-12 TNT); here it is 5.00 pUSD and no native is accepted.
        uint256 nativeBalBefore = address(tangle).balance;
        uint256 usdBefore = usd.balanceOf(user1);
        vm.startPrank(user1);
        usd.approve(address(tangle), usdRate);
        uint64 callId = tangle.submitJob(svc, 0, "");
        vm.stopPrank();

        assertEq(tangle.getJobCall(svc, callId).payment, usdRate, "payment is 5e6 pUSD units (5.00 pUSD)");
        assertEq(usdBefore - usd.balanceOf(user1), usdRate, "exactly 5.00 pUSD pulled from customer");
        assertEq(address(tangle).balance, nativeBalBefore, "no native was accepted for this job");
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
    // NATIVE BACK-COMPAT (d): blueprint asset unset == pre-change behavior
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
        // request time: build a blueprint whose manager allow-lists NOTHING (and whose
        // settlement asset is left at the native default) and confirm the native request still
        // activates. The job-time native gate is a separate, pre-existing check.
        AllowAssetManager strictManager = new AllowAssetManager();
        // Deliberately allow nothing at request time; leave blueprint asset unset (native).

        Types.BlueprintConfig memory cfg = _edConfig(RATE);
        vm.prank(developer);
        uint64 bp = tangle.createBlueprint(
            _blueprintDefinitionWithConfig("ipfs://ed-native-strict", address(strictManager), cfg)
        );
        _registerForBlueprint(operator1, bp);
        _registerForBlueprint(operator2, bp);

        // The request activates without the manager allow-listing native — no request-time
        // TokenNotAllowed revert — and the service's settlement asset is native.
        uint64 svc = _activateEventDrivenService(bp);
        assertEq(tangle.getServicePaymentAsset(svc), address(0));

        // Now allow native so the (pre-existing) job-time gate passes, and confirm a native
        // job settles exactly as before.
        strictManager.setAllowed(address(0), true);
        vm.prank(user1);
        uint64 callId = tangle.submitJob{ value: RATE }(svc, 0, "");
        assertEq(tangle.getJobCall(svc, callId).payment, RATE);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // PIN-AT-ACTIVATION (e): changing the blueprint asset does not re-price live services
    // ═══════════════════════════════════════════════════════════════════════════

    function test_PinAtActivation_BlueprintAssetChangeDoesNotRepriceLiveService() public {
        // erc20Service pinned settleToken at activation.
        assertEq(tangle.getServicePaymentAsset(erc20Service), address(settleToken));

        // Developer switches the blueprint to a DIFFERENT (also-allowed) token AFTER the
        // service went live.
        MockERC20 newToken = new MockERC20();
        manager.setAllowed(address(newToken), true);
        vm.prank(developer);
        tangle.setBlueprintSettlementAsset(erc20Blueprint, address(newToken));
        assertEq(tangle.getBlueprintSettlementAsset(erc20Blueprint), address(newToken), "blueprint asset updated");

        // The LIVE service keeps its originally pinned asset — it is NOT re-priced.
        assertEq(
            tangle.getServicePaymentAsset(erc20Service),
            address(settleToken),
            "live service keeps its activation-pinned asset"
        );

        // A newly activated service picks up the NEW blueprint asset.
        newToken.mint(user1, 1_000_000 ether);
        uint64 svc2 = _activateEventDrivenService(erc20Blueprint);
        assertEq(tangle.getServicePaymentAsset(svc2), address(newToken), "new service pins the new asset");

        // And the old service still bills in its old token.
        vm.startPrank(user1);
        settleToken.approve(address(tangle), RATE);
        uint64 callId = tangle.submitJob(erc20Service, 0, "");
        vm.stopPrank();
        assertEq(tangle.getJobCall(erc20Service, callId).payment, RATE);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // QUOTE-PATH ACTIVATION also pins the BLUEPRINT asset (second activation path)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice The RFQ `createServiceFromQuotes` path is a SECOND way to stand up an EventDriven
    ///         service. It must pin the same blueprint-declared settlement asset as the
    ///         request/approve path — otherwise a quote-created service of an ERC20 blueprint
    ///         would be left at the native `address(0)` default and re-open the exact 10^12x
    ///         under-payment (a 6-dec rate settling in native) through a different entry point.
    function test_QuotePath_EventDrivenService_PinsBlueprintErc20Asset() public {
        Types.SignedQuote[] memory quotes = _createZeroCostQuote(erc20Blueprint, 120);

        vm.prank(user1);
        uint64 svc = tangle.createServiceFromQuotes(erc20Blueprint, quotes, "", new address[](0), 120);

        // The quote-created service settles in the blueprint's ERC20, not native.
        assertEq(
            tangle.getServicePaymentAsset(svc),
            address(settleToken),
            "quote-created EventDriven service must pin the blueprint's ERC20 asset"
        );

        // And a job on it settles in the ERC20 (native value rejected).
        vm.startPrank(user1);
        settleToken.approve(address(tangle), RATE);
        vm.expectRevert(abi.encodeWithSelector(Errors.InvalidMsgValue.selector, 0, RATE));
        tangle.submitJob{ value: RATE }(svc, 0, "");
        vm.stopPrank();

        vm.startPrank(user1);
        settleToken.approve(address(tangle), RATE);
        uint64 callId = tangle.submitJob(svc, 0, "");
        vm.stopPrank();
        assertEq(tangle.getJobCall(svc, callId).payment, RATE, "quote-path job settles in the ERC20 at RATE");
    }

    /// @notice Native quote-created service leaves the asset at the native default (back-compat).
    function test_QuotePath_NativeBlueprint_LeavesNativeDefault() public {
        Types.SignedQuote[] memory quotes = _createZeroCostQuote(nativeBlueprint, 120);

        vm.prank(user1);
        uint64 svc = tangle.createServiceFromQuotes(nativeBlueprint, quotes, "", new address[](0), 120);

        assertEq(tangle.getServicePaymentAsset(svc), address(0), "native quote service stays native");

        vm.prank(user1);
        uint64 callId = tangle.submitJob{ value: RATE }(svc, 0, "");
        assertEq(tangle.getJobCall(svc, callId).payment, RATE);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // FAIL-CLOSED
    // ═══════════════════════════════════════════════════════════════════════════

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
        // fail closed at submit time even though the token was allowed at blueprint-set time.
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
        Types.BlueprintConfig memory cfg = _edConfig(usdRate);
        vm.startPrank(developer);
        uint64 bp = tangle.createBlueprint(_blueprintDefinitionWithConfig("ipfs://ed-usd", address(usdManager), cfg));
        tangle.setBlueprintSettlementAsset(bp, address(usd));
        vm.stopPrank();
        _registerForBlueprint(operator1, bp);
        _registerForBlueprint(operator2, bp);

        uint64 svc = _activateEventDrivenService(bp);
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

    function _edConfig(uint256 eventRate) internal pure returns (Types.BlueprintConfig memory) {
        return Types.BlueprintConfig({
            membership: Types.MembershipModel.Fixed,
            pricing: Types.PricingModel.EventDriven,
            minOperators: 1,
            maxOperators: 10,
            subscriptionRate: 0,
            subscriptionInterval: 0,
            eventRate: eventRate
        });
    }

    /// @notice Request + fully approve a 2-operator EventDriven service. The settlement asset is
    ///         sourced from the BLUEPRINT (set by the developer), so the customer's request is
    ///         always native `address(0)` — the customer never chooses the asset.
    function _activateEventDrivenService(uint64 blueprintId) internal returns (uint64 serviceId) {
        address[] memory ops = new address[](2);
        ops[0] = operator1;
        ops[1] = operator2;
        address[] memory callers = new address[](0);

        vm.prank(user1);
        uint64 requestId =
            tangle.requestService(blueprintId, ops, "", callers, 0, address(0), 0, Types.ConfidentialityPolicy.Any);

        vm.prank(operator1);
        tangle.approveService(_approve(requestId));
        vm.prank(operator2);
        tangle.approveService(_approve(requestId));

        serviceId = tangle.serviceCount() - 1;
    }

    /// @notice A single zero-cost operator quote signed by operator1 for the given blueprint,
    ///         suitable for `createServiceFromQuotes` on an EventDriven blueprint (which requires
    ///         `totalCost == 0`). Empty security/resource commitment arrays.
    function _createZeroCostQuote(uint64 blueprintId, uint64 ttl) internal view returns (Types.SignedQuote[] memory) {
        Types.QuoteDetails memory details = Types.QuoteDetails({
            requester: user1,
            blueprintId: blueprintId,
            ttlBlocks: ttl,
            totalCost: 0,
            timestamp: uint64(block.timestamp),
            expiry: uint64(block.timestamp + 1 hours),
            confidentiality: Types.ConfidentialityPolicy.Any,
            operation: Types.QuoteOperation.Create,
            serviceId: 0,
            securityCommitments: new Types.AssetSecurityCommitment[](0),
            resourceCommitments: new Types.ResourceCommitment[](0)
        });

        bytes32 emptyArrayHash = keccak256("");
        bytes32 domainSeparator = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes("TangleQuote")),
                keccak256(bytes("1")),
                block.chainid,
                address(tangle)
            )
        );
        bytes32 structHash = keccak256(
            abi.encode(
                QUOTE_TYPEHASH,
                details.requester,
                details.blueprintId,
                details.ttlBlocks,
                details.totalCost,
                details.timestamp,
                details.expiry,
                details.confidentiality,
                details.operation,
                details.serviceId,
                emptyArrayHash, // hash of the empty securityCommitments array
                emptyArrayHash // hash of the empty resourceCommitments array
            )
        );
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(OPERATOR1_PK, digest);

        Types.SignedQuote[] memory quotes = new Types.SignedQuote[](1);
        quotes[0] = Types.SignedQuote({ details: details, signature: abi.encodePacked(r, s, v), operator: operator1 });
        return quotes;
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
