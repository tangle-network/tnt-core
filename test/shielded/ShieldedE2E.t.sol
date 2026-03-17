// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BaseTest } from "../BaseTest.sol";
import { MockERC20 } from "../MockERC20.sol";
import { MockVAnchor } from "./MockVAnchor.sol";
import { ShieldedGateway } from "../../src/shielded/ShieldedGateway.sol";
import { ShieldedCredits } from "../../src/shielded/ShieldedCredits.sol";
import { IShieldedGateway } from "../../src/shielded/IShieldedGateway.sol";
import { IShieldedCredits } from "../../src/shielded/IShieldedCredits.sol";
import { Types } from "../../src/libraries/Types.sol";
import { CommonExtData, PublicInputs, Encryptions } from "protocol-solidity/structs/PublicInputs.sol";
import { MessageHashUtils } from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

/// @title ShieldedE2ETest
/// @notice End-to-end tests for the complete anonymous inference payment flow:
///         Deposit → Fund Credits → Request Service → Submit Jobs → Operator Claims
///
///         Uses MockVAnchor (skips ZK proofs) to test the full integration between:
///         VAnchor → ShieldedGateway → ShieldedCredits → tnt-core
contract ShieldedE2ETest is BaseTest {
    ShieldedGateway public gateway;
    ShieldedCredits public credits;
    MockVAnchor public mockPool;
    MockERC20 public wrappedToken;

    address public gatewayOwner = makeAddr("gatewayOwner");

    // Ephemeral spending key for credits
    uint256 internal spendingPrivKey = 0xbeef;
    address internal spendingPubKey;
    bytes32 internal salt = keccak256("e2e-salt");
    bytes32 internal commitment;

    uint256 public constant POOL_LIQUIDITY = 1000 ether;
    uint256 public constant CREDIT_DEPOSIT = 50 ether;
    uint256 public constant JOB_PRICE = 1 ether;

    function setUp() public override {
        super.setUp();

        wrappedToken = new MockERC20();
        mockPool = new MockVAnchor(address(wrappedToken));
        wrappedToken.mint(address(mockPool), POOL_LIQUIDITY);

        credits = new ShieldedCredits();
        gateway = new ShieldedGateway(address(tangle), address(credits), gatewayOwner);

        vm.prank(gatewayOwner);
        gateway.registerPool(address(wrappedToken), address(mockPool));

        _registerOperator(operator1);

        spendingPubKey = vm.addr(spendingPrivKey);
        commitment = keccak256(abi.encodePacked(spendingPubKey, salt));
    }

    /// @notice Full anonymous inference flow:
    ///   1. Anonymous deposit → fund credits via shielded gateway
    ///   2. Create a service with ephemeral key as permitted caller
    ///   3. Submit multiple jobs using credit spend authorizations
    ///   4. Operator claims payment for each completed job
    ///   5. User withdraws remaining credits
    function test_fullAnonymousInferenceFlow() public {
        // ─── Step 1: Fund credits anonymously
        // ──────────────────────────────
        // In production: user generates ZK proof for VAnchor withdrawal
        // In test: MockVAnchor skips proof verification

        gateway.shieldedFundCredits(_anchorProof(address(wrappedToken), CREDIT_DEPOSIT, 1), commitment, spendingPubKey);

        IShieldedCredits.CreditAccountView memory acct = credits.getAccount(commitment);
        assertEq(acct.balance, CREDIT_DEPOSIT, "Credits should be funded");
        assertEq(acct.spendingKey, spendingPubKey, "Spending key should be set");

        // Gateway should hold nothing
        assertEq(wrappedToken.balanceOf(address(gateway)), 0, "Gateway should be empty");

        // ─── Step 2: Create service with ephemeral key
        // ─────────────────────
        // The gateway creates the service (it becomes the owner)
        // The spending key address is added as permitted caller
        uint64 blueprintId = _createBlueprint(developer);
        _registerForBlueprint(operator1, blueprintId);

        address[] memory ops = new address[](1);
        ops[0] = operator1;
        address[] memory callers = new address[](1);
        callers[0] = spendingPubKey; // Ephemeral key can submit jobs

        IShieldedGateway.ServiceRequestParams memory params = IShieldedGateway.ServiceRequestParams({
            blueprintId: blueprintId,
            operators: ops,
            config: "",
            permittedCallers: callers,
            ttl: 0,
            confidentiality: Types.ConfidentialityPolicy.Any
        });

        // Fund the service request with a small amount (PayOnce)
        uint64 requestId = gateway.shieldedRequestService(_anchorProof(address(wrappedToken), 1 ether, 2), params);

        // Operator approves → service activates
        vm.prank(operator1);
        tangle.approveService(requestId, 0);
        uint64 serviceId = tangle.serviceCount() - 1;

        // ─── Step 3: Submit jobs using credit spend authorizations ─────────
        // The ephemeral key submits jobs directly to tnt-core
        // Payment comes from ShieldedCredits, not from the service escrow
        bytes32[] memory authHashes = new bytes32[](5);

        for (uint256 i = 0; i < 5; i++) {
            // Sign spend authorization off-chain (cheap!)
            IShieldedCredits.SpendAuth memory auth = _signSpend(serviceId, 0, operator1, JOB_PRICE, i);
            authHashes[i] = credits.authorizeSpend(auth);

            // Submit job using ephemeral key
            vm.prank(spendingPubKey);
            tangle.submitJob(serviceId, 0, abi.encode("inference request", i));
        }

        // Credits deducted for all 5 jobs
        assertEq(
            credits.getAccount(commitment).balance,
            CREDIT_DEPOSIT - (JOB_PRICE * 5),
            "Credits should reflect 5 job payments"
        );

        // ─── Step 4: Operator claims payment
        // ───────────────────────────────
        uint256 opBalBefore = wrappedToken.balanceOf(operator1);
        for (uint256 i = 0; i < 5; i++) {
            vm.prank(operator1);
            credits.claimPayment(authHashes[i], operator1);
        }
        uint256 opBalAfter = wrappedToken.balanceOf(operator1);
        assertEq(opBalAfter - opBalBefore, JOB_PRICE * 5, "Operator should receive all job payments");

        // ─── Step 5: User withdraws remaining credits
        // ──────────────────────
        uint256 remaining = credits.getAccount(commitment).balance;
        address exitAddr = makeAddr("exit");
        bytes memory withdrawSig = _signWithdraw(commitment, exitAddr, remaining, 5);
        credits.withdrawCredits(commitment, exitAddr, remaining, 5, withdrawSig);

        assertEq(wrappedToken.balanceOf(exitAddr), remaining, "User should get remaining credits");
        assertEq(credits.getAccount(commitment).balance, 0, "Credit balance should be zero");
    }

    /// @notice Test that a different operator cannot front-run claims
    function test_operatorCannotFrontRunClaim() public {
        gateway.shieldedFundCredits(_anchorProof(address(wrappedToken), CREDIT_DEPOSIT, 10), commitment, spendingPubKey);

        IShieldedCredits.SpendAuth memory auth = _signSpend(0, 0, operator1, JOB_PRICE, 0);
        bytes32 authHash = credits.authorizeSpend(auth);

        // Another address tries to claim
        address attacker = makeAddr("attacker");
        vm.prank(attacker);
        vm.expectRevert(abi.encodeWithSelector(IShieldedCredits.NotDesignatedOperator.selector, operator1, attacker));
        credits.claimPayment(authHash, attacker);

        // Designated operator can claim
        vm.prank(operator1);
        credits.claimPayment(authHash, operator1);
    }

    /// @notice Test that credits and service escrow are independent
    function test_creditsAndEscrowIndependent() public {
        // Fund credits
        gateway.shieldedFundCredits(_anchorProof(address(wrappedToken), CREDIT_DEPOSIT, 20), commitment, spendingPubKey);

        // Also fund a subscription service directly
        Types.BlueprintConfig memory config;
        config.pricing = Types.PricingModel.Subscription;
        config.subscriptionRate = 2 ether;
        config.subscriptionInterval = 30 days;
        uint64 blueprintId = _createBlueprintWithConfig(developer, address(0), config);
        _registerForBlueprint(operator1, blueprintId);

        address[] memory ops = new address[](1);
        ops[0] = operator1;

        // Fund service escrow via shielded gateway (separate from credits)
        wrappedToken.mint(user1, 20 ether);
        vm.startPrank(user1);
        wrappedToken.approve(address(tangle), 20 ether);
        uint64 requestId = tangle.requestService(
            blueprintId, ops, "", new address[](0), 0, address(wrappedToken), 20 ether, Types.ConfidentialityPolicy.Any
        );
        vm.stopPrank();

        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        // Credits balance unaffected by service funding
        assertEq(credits.getAccount(commitment).balance, CREDIT_DEPOSIT, "Credits should be independent");
    }

    // ═══════════════════════════════════════════════════════════════════════
    // HELPERS
    // ═══════════════════════════════════════════════════════════════════════

    function _anchorProof(
        address token,
        uint256 amount,
        uint256 nullifierSeed
    )
        internal
        view
        returns (IShieldedGateway.VAnchorProof memory)
    {
        CommonExtData memory extData = CommonExtData({
            recipient: address(gateway),
            extAmount: -int256(amount),
            relayer: address(0),
            fee: 0,
            refund: 0,
            token: token
        });

        uint256[] memory nullifiers = new uint256[](2);
        nullifiers[0] = uint256(keccak256(abi.encodePacked("e2e-null0", nullifierSeed)));
        nullifiers[1] = uint256(keccak256(abi.encodePacked("e2e-null1", nullifierSeed)));

        PublicInputs memory pubInputs = PublicInputs({
            roots: new bytes(64),
            extensionRoots: new bytes(0),
            inputNullifiers: nullifiers,
            outputCommitments: [uint256(0), uint256(0)],
            publicAmount: 0,
            extDataHash: 0
        });

        return IShieldedGateway.VAnchorProof({
            proof: new bytes(256),
            auxPublicInputs: new bytes(0),
            externalData: abi.encode(extData),
            publicInputs: abi.encode(pubInputs),
            encryptions: abi.encode(Encryptions({ encryptedOutput1: new bytes(0), encryptedOutput2: new bytes(0) }))
        });
    }

    function _signSpend(
        uint64 serviceId,
        uint8 jobIndex,
        address operator,
        uint256 amount,
        uint256 nonce
    )
        internal
        view
        returns (IShieldedCredits.SpendAuth memory)
    {
        uint64 expiry = uint64(block.timestamp) + 3600;
        bytes32 structHash = keccak256(
            abi.encode(credits.SPEND_TYPEHASH(), commitment, serviceId, jobIndex, amount, operator, nonce, expiry)
        );
        bytes32 digest = MessageHashUtils.toTypedDataHash(credits.DOMAIN_SEPARATOR(), structHash);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(spendingPrivKey, digest);

        return IShieldedCredits.SpendAuth({
            commitment: commitment,
            serviceId: serviceId,
            jobIndex: jobIndex,
            amount: amount,
            operator: operator,
            nonce: nonce,
            expiry: expiry,
            signature: abi.encodePacked(r, s, v)
        });
    }

    function _signWithdraw(
        bytes32 _commitment,
        address recipient,
        uint256 amount,
        uint256 nonce
    )
        internal
        view
        returns (bytes memory)
    {
        bytes32 structHash = keccak256(abi.encode(credits.WITHDRAW_TYPEHASH(), _commitment, recipient, amount, nonce));
        bytes32 digest = MessageHashUtils.toTypedDataHash(credits.DOMAIN_SEPARATOR(), structHash);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(spendingPrivKey, digest);
        return abi.encodePacked(r, s, v);
    }
}
