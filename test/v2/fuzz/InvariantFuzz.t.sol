// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test, console2 } from "forge-std/Test.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import { Tangle } from "../../../src/v2/Tangle.sol";
import { ITangleFull } from "../../../src/v2/interfaces/ITangle.sol";
import { IMultiAssetDelegation } from "../../../src/v2/interfaces/IMultiAssetDelegation.sol";
import { MultiAssetDelegation } from "../../../src/v2/restaking/MultiAssetDelegation.sol";
import { Types } from "../../../src/v2/libraries/Types.sol";
import { Errors } from "../../../src/v2/libraries/Errors.sol";
import { SlashingLib } from "../../../src/v2/libraries/SlashingLib.sol";
import { PaymentLib } from "../../../src/v2/libraries/PaymentLib.sol";
import { MasterBlueprintServiceManager } from "../../../src/v2/MasterBlueprintServiceManager.sol";
import { MBSMRegistry } from "../../../src/v2/MBSMRegistry.sol";
import { BlueprintDefinitionHelper } from "../../support/BlueprintDefinitionHelper.sol";
import { TangleBlueprintsFacet } from "../../../src/v2/facets/tangle/TangleBlueprintsFacet.sol";
import { TangleOperatorsFacet } from "../../../src/v2/facets/tangle/TangleOperatorsFacet.sol";
import { TangleServicesFacet } from "../../../src/v2/facets/tangle/TangleServicesFacet.sol";
import { TangleJobsFacet } from "../../../src/v2/facets/tangle/TangleJobsFacet.sol";
import { TangleQuotesFacet } from "../../../src/v2/facets/tangle/TangleQuotesFacet.sol";
import { TanglePaymentsFacet } from "../../../src/v2/facets/tangle/TanglePaymentsFacet.sol";
import { TangleSlashingFacet } from "../../../src/v2/facets/tangle/TangleSlashingFacet.sol";
import { RestakingOperatorsFacet } from "../../../src/v2/facets/restaking/RestakingOperatorsFacet.sol";
import { RestakingDepositsFacet } from "../../../src/v2/facets/restaking/RestakingDepositsFacet.sol";
import { RestakingDelegationsFacet } from "../../../src/v2/facets/restaking/RestakingDelegationsFacet.sol";
import { RestakingRewardsFacet } from "../../../src/v2/facets/restaking/RestakingRewardsFacet.sol";
import { RestakingSlashingFacet } from "../../../src/v2/facets/restaking/RestakingSlashingFacet.sol";
import { RestakingAssetsFacet } from "../../../src/v2/facets/restaking/RestakingAssetsFacet.sol";
import { RestakingViewsFacet } from "../../../src/v2/facets/restaking/RestakingViewsFacet.sol";
import { RestakingAdminFacet } from "../../../src/v2/facets/restaking/RestakingAdminFacet.sol";

/// @title InvariantFuzzTest
/// @notice Critical invariant tests for the system
contract InvariantFuzzTest is Test, BlueprintDefinitionHelper {
    ITangleFull public tangle;
    IMultiAssetDelegation public restaking;
    MasterBlueprintServiceManager public masterManager;
    MBSMRegistry public mbsmRegistry;

    address public admin = makeAddr("admin");
    address public treasury = makeAddr("treasury");
    address public developer = makeAddr("developer");
    address public operator1 = makeAddr("operator1");
    address public operator2 = makeAddr("operator2");
    address public operator3 = makeAddr("operator3");
    address public user1 = makeAddr("user1");

    uint64 public blueprintId;
    uint64 public serviceId;

    // Tracking for invariant checks
    uint256 public totalPaymentsReceived;
    uint256 public totalPaymentsDistributed;
    uint256 public totalSlashed;

    function setUp() public {
        // Deploy implementations
        Tangle tangleImpl = new Tangle();
        MultiAssetDelegation restakingImpl = new MultiAssetDelegation();

        // Deploy restaking proxy
        ERC1967Proxy restakingProxy = new ERC1967Proxy(
            address(restakingImpl),
            abi.encodeCall(
                MultiAssetDelegation.initialize,
                (admin, 1 ether, 0.1 ether, 1000)
            )
        );
        restaking = IMultiAssetDelegation(payable(address(restakingProxy)));

        // Deploy tangle proxy
        ERC1967Proxy tangleProxy = new ERC1967Proxy(
            address(tangleImpl),
            abi.encodeCall(
                Tangle.initialize,
                (admin, address(restaking), payable(treasury))
            )
        );
        tangle = ITangleFull(payable(address(tangleProxy)));

        vm.startPrank(admin);
        _registerRestakingFacets(address(restakingProxy));
        _registerTangleFacets(address(tangleProxy));
        vm.stopPrank();

        // Grant slasher role
        vm.prank(admin);
        restaking.addSlasher(address(tangleProxy));

        masterManager = new MasterBlueprintServiceManager(admin, address(tangleProxy));
        MBSMRegistry registryImpl = new MBSMRegistry();
        ERC1967Proxy registryProxy = new ERC1967Proxy(
            address(registryImpl),
            abi.encodeCall(MBSMRegistry.initialize, (admin))
        );
        mbsmRegistry = MBSMRegistry(address(registryProxy));
        vm.startPrank(admin);
        mbsmRegistry.grantRole(mbsmRegistry.MANAGER_ROLE(), address(tangleProxy));
        mbsmRegistry.addVersion(address(masterManager));
        Tangle(payable(address(tangleProxy))).setMBSMRegistry(address(mbsmRegistry));
        vm.stopPrank();

        // Fund actors
        vm.deal(operator1, 1000 ether);
        vm.deal(operator2, 1000 ether);
        vm.deal(operator3, 1000 ether);
        vm.deal(developer, 100 ether);
        vm.deal(user1, 1000 ether);

        // Setup basic infrastructure
        vm.prank(operator1);
        restaking.registerOperator{ value: 100 ether }();
        vm.prank(operator2);
        restaking.registerOperator{ value: 100 ether }();
        vm.prank(operator3);
        restaking.registerOperator{ value: 100 ether }();

        vm.prank(developer);
        blueprintId = tangle.createBlueprint(_blueprintDefinition("ipfs://invariant", address(0)));

        vm.prank(operator1);
        tangle.registerOperator(blueprintId, _operatorGossipKey(operator1, 0), "");
        vm.prank(operator2);
        tangle.registerOperator(blueprintId, _operatorGossipKey(operator2, 0), "");
        vm.prank(operator3);
        tangle.registerOperator(blueprintId, _operatorGossipKey(operator3, 0), "");

        // Create initial service
        address[] memory ops = new address[](1);
        ops[0] = operator1;

        vm.prank(user1);
        uint64 requestId = tangle.requestService(blueprintId, ops, "", new address[](0), 0, address(0), 0);

        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        serviceId = 0;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // INVARIANT: Slash effective amount never exceeds proposed amount
    // ═══════════════════════════════════════════════════════════════════════════

    function testFuzz_Invariant_EffectiveSlashNeverExceedsProposed(
        uint256 amount,
        uint16 exposure
    ) public {
        amount = bound(amount, 0.01 ether, 100 ether);
        exposure = uint16(bound(uint256(exposure), 1, 10000));

        // Create service with custom exposure
        address[] memory ops = new address[](1);
        ops[0] = operator2;
        uint16[] memory exposures = new uint16[](1);
        exposures[0] = exposure;

        vm.prank(user1);
        uint64 requestId = tangle.requestServiceWithExposure(
            blueprintId, ops, exposures, "", new address[](0), 0, address(0), 0
        );

        vm.prank(operator2);
        tangle.approveService(requestId, 0);

        uint64 newServiceId = tangle.serviceCount() - 1;

        vm.prank(user1);
        uint64 slashId = tangle.proposeSlash(newServiceId, operator2, amount, keccak256("evidence"));

        SlashingLib.SlashProposal memory proposal = tangle.getSlashProposal(slashId);

        // INVARIANT: effectiveAmount <= amount
        assertLe(proposal.effectiveAmount, proposal.amount, "INVARIANT VIOLATED: effective > proposed");

        // More specifically: effectiveAmount = amount * exposure / 10000
        uint256 expected = (amount * exposure) / 10000;
        assertEq(proposal.effectiveAmount, expected, "Effective amount calculation wrong");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // INVARIANT: Operator stake can never go negative
    // ═══════════════════════════════════════════════════════════════════════════

    function testFuzz_Invariant_StakeNeverNegative(uint256 slashAmount) public {
        slashAmount = bound(slashAmount, 1 ether, 500 ether);

        uint256 stakeBefore = restaking.getOperatorSelfStake(operator1);

        vm.prank(user1);
        uint64 slashId = tangle.proposeSlash(serviceId, operator1, slashAmount, keccak256("evidence"));

        vm.warp(block.timestamp + 7 days + 1);
        tangle.executeSlash(slashId);

        uint256 stakeAfter = restaking.getOperatorSelfStake(operator1);

        // INVARIANT: stake >= 0 (always true for uint, but verify reasonable behavior)
        assertLe(stakeAfter, stakeBefore, "Stake increased after slash");

        if (slashAmount <= stakeBefore) {
            assertEq(stakeAfter, stakeBefore - slashAmount, "Incorrect stake reduction");
        } else {
            assertEq(stakeAfter, 0, "Stake should be 0 when slashing more than available");
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // INVARIANT: Service operator count always within bounds
    // ═══════════════════════════════════════════════════════════════════════════

    function testFuzz_Invariant_OperatorCountWithinBounds(
        uint8 minOps,
        uint8 maxOps,
        uint8 requestOps
    ) public {
        minOps = uint8(bound(uint256(minOps), 1, 3));
        maxOps = uint8(bound(uint256(maxOps), minOps, 5));
        requestOps = uint8(bound(uint256(requestOps), 1, 5));

        Types.BlueprintConfig memory config = Types.BlueprintConfig({
            membership: Types.MembershipModel.Fixed,
            pricing: Types.PricingModel.PayOnce,
            minOperators: minOps,
            maxOperators: maxOps,
            subscriptionRate: 0,
            subscriptionInterval: 0,
            eventRate: 0,
            operatorBond: 0
        });

        vm.prank(developer);
        uint64 newBpId =
            tangle.createBlueprint(_blueprintDefinitionWithConfig("ipfs://bounds", address(0), config));

        // Register enough operators
        address[] memory operators = new address[](requestOps);
        for (uint8 i = 0; i < requestOps; i++) {
            address op;
            if (i == 0) op = operator1;
            else if (i == 1) op = operator2;
            else if (i == 2) op = operator3;
            else {
                op = makeAddr(string(abi.encodePacked("op", uint256(i))));
                vm.deal(op, 10 ether);
                vm.prank(op);
                restaking.registerOperator{ value: 5 ether }();
            }

            if (i >= 3) {
                vm.prank(op);
                tangle.registerOperator(newBpId, _operatorGossipKey(op, i), "");
            } else {
                // Use existing registrations if possible, or register
                if (!tangle.isOperatorRegistered(newBpId, op)) {
                    vm.prank(op);
                    tangle.registerOperator(newBpId, _operatorGossipKey(op, i), "");
                }
            }
            operators[i] = op;
        }

        // Request service
        if (requestOps < minOps) {
            vm.prank(user1);
            vm.expectRevert(abi.encodeWithSelector(Errors.InsufficientOperators.selector, minOps, requestOps));
            tangle.requestService(newBpId, operators, "", new address[](0), 0, address(0), 0);
        } else if (requestOps > maxOps) {
            vm.prank(user1);
            vm.expectRevert(abi.encodeWithSelector(Errors.TooManyOperators.selector, maxOps, requestOps));
            tangle.requestService(newBpId, operators, "", new address[](0), 0, address(0), 0);
        } else {
            // Should succeed
            vm.prank(user1);
            tangle.requestService(newBpId, operators, "", new address[](0), 0, address(0), 0);
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // INVARIANT: Payment split always sums to 100%
    // ═══════════════════════════════════════════════════════════════════════════

    function testFuzz_Invariant_PaymentSplitSums100(
        uint16 devBps,
        uint16 protoBps,
        uint16 opBps
    ) public {
        // Bound individual values
        devBps = uint16(bound(uint256(devBps), 0, 10000));
        protoBps = uint16(bound(uint256(protoBps), 0, 10000 - devBps));
        opBps = uint16(bound(uint256(opBps), 0, 10000 - devBps - protoBps));
        uint16 restakerBps = 10000 - devBps - protoBps - opBps;

        Types.PaymentSplit memory split = Types.PaymentSplit({
            developerBps: devBps,
            protocolBps: protoBps,
            operatorBps: opBps,
            restakerBps: restakerBps
        });

        // Should always succeed if sum is exactly 10000
        vm.prank(admin);
        tangle.setPaymentSplit(split);

        (uint16 d, uint16 p, uint16 o, uint16 r) = tangle.paymentSplit();
        assertEq(d + p + o + r, 10000, "INVARIANT VIOLATED: split doesn't sum to 100%");
    }

    function testFuzz_Invariant_PaymentSplitRejectsInvalid(
        uint16 devBps,
        uint16 protoBps,
        uint16 opBps,
        uint16 restakerBps
    ) public {
        // Test that invalid splits are rejected
        uint256 total = uint256(devBps) + uint256(protoBps) + uint256(opBps) + uint256(restakerBps);

        Types.PaymentSplit memory split = Types.PaymentSplit({
            developerBps: devBps,
            protocolBps: protoBps,
            operatorBps: opBps,
            restakerBps: restakerBps
        });

        if (total != 10000) {
            vm.prank(admin);
            vm.expectRevert(Errors.InvalidPaymentSplit.selector);
            tangle.setPaymentSplit(split);
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // INVARIANT: Service count monotonically increases
    // ═══════════════════════════════════════════════════════════════════════════

    function testFuzz_Invariant_ServiceCountMonotonic(uint8 numServices) public {
        numServices = uint8(bound(uint256(numServices), 1, 20));

        uint64 previousCount = tangle.serviceCount();

        for (uint8 i = 0; i < numServices; i++) {
            address[] memory ops = new address[](1);
            ops[0] = operator1;

            vm.prank(user1);
            uint64 requestId = tangle.requestService(blueprintId, ops, "", new address[](0), 0, address(0), 0);

            vm.prank(operator1);
            tangle.approveService(requestId, 0);

            uint64 currentCount = tangle.serviceCount();
            assertGt(currentCount, previousCount, "INVARIANT VIOLATED: service count didn't increase");
            previousCount = currentCount;
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // INVARIANT: Slash proposal IDs are unique and sequential
    // ═══════════════════════════════════════════════════════════════════════════

    function testFuzz_Invariant_SlashIdsSequential(uint8 numSlashes) public {
        numSlashes = uint8(bound(uint256(numSlashes), 1, 30));

        uint64 previousId = type(uint64).max;

        for (uint8 i = 0; i < numSlashes; i++) {
            vm.prank(user1);
            uint64 slashId = tangle.proposeSlash(
                serviceId,
                operator1,
                0.01 ether,
                keccak256(abi.encodePacked("evidence", i))
            );

            if (previousId != type(uint64).max) {
                assertEq(slashId, previousId + 1, "INVARIANT VIOLATED: slash IDs not sequential");
            }
            previousId = slashId;
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // INVARIANT: Dispute window config is within valid range
    // ═══════════════════════════════════════════════════════════════════════════

    function testFuzz_Invariant_DisputeWindowValid(uint64 window) public {
        if (window < 1 hours || window > 30 days) {
            vm.prank(admin);
            vm.expectRevert(Errors.InvalidSlashConfig.selector);
            tangle.setSlashConfig(window, false, 10000);
        } else {
            vm.prank(admin);
            tangle.setSlashConfig(window, false, 10000);

            // Verify by creating slash
            vm.prank(user1);
            uint64 slashId = tangle.proposeSlash(serviceId, operator1, 0.01 ether, keccak256("test"));

            SlashingLib.SlashProposal memory proposal = tangle.getSlashProposal(slashId);
            assertEq(
                proposal.executeAfter,
                proposal.proposedAt + window,
                "Dispute window not applied correctly"
            );
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // INVARIANT: Escrow balance never exceeds total deposited
    // ═══════════════════════════════════════════════════════════════════════════

    function testFuzz_Invariant_EscrowBalanceValid(
        uint256 deposit,
        uint8 billCount
    ) public {
        deposit = bound(deposit, 1 ether, 100 ether);
        billCount = uint8(bound(uint256(billCount), 1, 20));

        Types.BlueprintConfig memory config = Types.BlueprintConfig({
            membership: Types.MembershipModel.Fixed,
            pricing: Types.PricingModel.Subscription,
            minOperators: 1,
            maxOperators: 10,
            subscriptionRate: 0.1 ether,
            subscriptionInterval: 1 days,
            eventRate: 0,
            operatorBond: 0
        });

        vm.prank(developer);
        uint64 subBp =
            tangle.createBlueprint(_blueprintDefinitionWithConfig("ipfs://escrow-inv", address(0), config));

        vm.prank(operator1);
        tangle.registerOperator(subBp, _operatorGossipKey(operator1, 0), "");

        address[] memory ops = new address[](1);
        ops[0] = operator1;

        vm.prank(user1);
        uint64 requestId = tangle.requestService{ value: deposit }(
            subBp, ops, "", new address[](0), 365 days, address(0), deposit
        );

        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        uint64 subServiceId = tangle.serviceCount() - 1;

        uint256 currentTime = block.timestamp;
        for (uint8 i = 0; i < billCount; i++) {
            PaymentLib.ServiceEscrow memory escrow = tangle.getServiceEscrow(subServiceId);

            // INVARIANT: balance <= totalDeposited
            assertLe(escrow.balance, escrow.totalDeposited, "INVARIANT VIOLATED: balance > deposited");

            // INVARIANT: balance + totalReleased = totalDeposited
            assertEq(
                escrow.balance + escrow.totalReleased,
                escrow.totalDeposited,
                "INVARIANT VIOLATED: accounting mismatch"
            );

            if (escrow.balance >= 0.1 ether) {
                currentTime += 1 days + 1;
                vm.warp(currentTime);
                tangle.billSubscription(subServiceId);
            }
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // INVARIANT: Active operator in service is always registered for blueprint
    // ═══════════════════════════════════════════════════════════════════════════

    function testFuzz_Invariant_ServiceOperatorRegistered() public view {
        address[] memory operators = tangle.getServiceOperators(serviceId);

        Types.Service memory svc = tangle.getService(serviceId);

        for (uint256 i = 0; i < operators.length; i++) {
            assertTrue(
                tangle.isOperatorRegistered(svc.blueprintId, operators[i]),
                "INVARIANT VIOLATED: service operator not registered"
            );
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // INVARIANT: Pending rewards are claimable
    // ═══════════════════════════════════════════════════════════════════════════

    function testFuzz_Invariant_PendingRewardsClaimable(uint256 payment) public {
        payment = bound(payment, 0.1 ether, 10 ether);

        address[] memory ops = new address[](1);
        ops[0] = operator1;

        vm.prank(user1);
        uint64 requestId = tangle.requestService{ value: payment }(
            blueprintId, ops, "", new address[](0), 0, address(0), payment
        );

        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        uint256 pending = tangle.pendingRewards(operator1);
        if (pending > 0) {
            uint256 balanceBefore = operator1.balance;

            vm.prank(operator1);
            tangle.claimRewards();

            // INVARIANT: claimed amount equals pending
            assertEq(operator1.balance - balanceBefore, pending, "INVARIANT VIOLATED: claimed != pending");
            assertEq(tangle.pendingRewards(operator1), 0, "INVARIANT VIOLATED: pending not cleared");
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // INVARIANT: Blueprint count monotonically increases
    // ═══════════════════════════════════════════════════════════════════════════

    function testFuzz_Invariant_BlueprintCountMonotonic(uint8 numBlueprints) public {
        numBlueprints = uint8(bound(uint256(numBlueprints), 1, 20));

        uint64 previousCount = tangle.blueprintCount();

        for (uint8 i = 0; i < numBlueprints; i++) {
            vm.prank(developer);
            tangle.createBlueprint(_blueprintDefinition(string(abi.encodePacked("ipfs://bp", uint256(i))), address(0)));

            uint64 currentCount = tangle.blueprintCount();
            assertGt(currentCount, previousCount, "INVARIANT VIOLATED: blueprint count didn't increase");
            previousCount = currentCount;
        }
    }

    function _operatorGossipKey(address operator, uint256 salt) internal pure returns (bytes memory key) {
        key = new bytes(65);
        key[0] = 0x04;
        bytes32 payload = keccak256(abi.encodePacked(operator, salt));
        for (uint256 i = 0; i < 32; ++i) {
            key[i + 1] = payload[i];
        }
    }

    function _registerTangleFacets(address tangleProxy) internal {
        Tangle router = Tangle(payable(tangleProxy));
        router.registerFacet(address(new TangleBlueprintsFacet()));
        router.registerFacet(address(new TangleOperatorsFacet()));
        router.registerFacet(address(new TangleServicesFacet()));
        router.registerFacet(address(new TangleJobsFacet()));
        router.registerFacet(address(new TangleQuotesFacet()));
        router.registerFacet(address(new TanglePaymentsFacet()));
        router.registerFacet(address(new TangleSlashingFacet()));
    }

    function _registerRestakingFacets(address restakingProxy) internal {
        MultiAssetDelegation router = MultiAssetDelegation(payable(restakingProxy));
        router.registerFacet(address(new RestakingOperatorsFacet()));
        router.registerFacet(address(new RestakingDepositsFacet()));
        router.registerFacet(address(new RestakingDelegationsFacet()));
        router.registerFacet(address(new RestakingRewardsFacet()));
        router.registerFacet(address(new RestakingSlashingFacet()));
        router.registerFacet(address(new RestakingAssetsFacet()));
        router.registerFacet(address(new RestakingViewsFacet()));
        router.registerFacet(address(new RestakingAdminFacet()));
    }
}
