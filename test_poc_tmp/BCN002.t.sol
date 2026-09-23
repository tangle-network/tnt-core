// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test, console2 } from "forge-std/Test.sol";
import { ValidatorPodManager } from "src/beacon/ValidatorPodManager.sol";
import { L2SlashingConnector } from "src/beacon/L2SlashingConnector.sol";
import { MockBeaconOracle } from "src/beacon/BeaconRootReceiver.sol";
import { ICrossChainMessenger } from "src/beacon/interfaces/ICrossChainMessenger.sol";

/// @notice PoC for BCN-002: batchPropagateBeaconSlashing forwards {value: 0} to each
///         self-call, so when the messenger charges a non-zero fee (the production case
///         for Base/Arbitrum L1->L2 bridges) every pod's propagation reverts
///         InsufficientFee inside _propagateBeaconSlashing, the outer try/catch swallows
///         it, and the whole batch silently advances ZERO slashing factors. The existing
///         test_batchPropagateBeaconSlashing_MultiplePods only passes because it calls
///         messenger.setMockFee(0) first (CrossChainSlashingTest.t.sol:428), which hides
///         the bug. This PoC leaves the fee at its default non-zero value.
contract BCN002BatchDropsSlashesPoC is Test {
    MockBeaconOracle oracle;
    ValidatorPodManager vpm;
    L2SlashingConnector connector;
    MockMessenger messenger;
    address constant POD = address(0xA1);
    address constant POD_OWNER = address(0xB1);
    address constant OPERATOR = address(0xC1);
    address constant SLASHING_ORACLE = address(0xD1);
    uint256 constant TANGLE_CHAIN = 5000;

    function setUp() public {
        oracle = new MockBeaconOracle();
        vpm = new ValidatorPodManager(address(oracle), 1 ether);
        messenger = new MockMessenger(); // default fee = 0.001 ether (non-zero, like prod)

        vm.startPrank(SLASHING_ORACLE);
        connector = new L2SlashingConnector(address(vpm), SLASHING_ORACLE);
        connector.setMessenger(address(messenger));
        connector.setChainConfig(TANGLE_CHAIN, address(0xFE), 200_000, true);
        connector.setDefaultDestinationChain(TANGLE_CHAIN);
        connector.registerPodOperator(POD, OPERATOR);
        vm.stopPrank();
    }

    function test_batchSilentlyDropsAllSlashesWhenFeeNonZero() public {
        // Mock VPM views: pod principal 40 ETH, operator stake 40 ETH -> nonzero slashBps.
        vm.mockCall(address(vpm), abi.encodeWithSelector(vpm.podToOwner.selector, POD), abi.encode(POD_OWNER));
        vm.mockCall(address(vpm), abi.encodeWithSelector(vpm.totalAssetsOf.selector, POD_OWNER), abi.encode(40 ether));
        vm.mockCall(address(vpm), abi.encodeWithSelector(vpm.getOperatorStake.selector, OPERATOR), abi.encode(40 ether));

        // Pod factor 1.0 -> 0.5 (50% real slash).
        uint64 newFactor = 0.5e18;
        MockPod mockPod = new MockPod(newFactor);
        vm.etch(POD, address(mockPod).code);
        MockPod(address(POD)).setValue(newFactor);

        address[] memory pods = new address[](1);
        pods[0] = POD;
        uint64[] memory newFactors = new uint64[](1);
        newFactors[0] = newFactor;

        // Fund the oracle generously so a SINGLE-pod propagate would succeed.
        vm.deal(SLASHING_ORACLE, 1 ether);

        // ----- Single-pod path succeeds (baseline confirmation the setup is valid).
        vm.prank(SLASHING_ORACLE);
        connector.propagateBeaconSlashing{ value: 0.01 ether }(POD, newFactor);
        assertEq(
            connector.lastProcessedSlashingFactorByChain(POD, TANGLE_CHAIN),
            newFactor,
            "single-path should propagate"
        );

        // ----- Batch path on a fresh pod with the SAME non-zero fee silently drops.
        // Deploy a second connector (fresh state) so the baseline is unset.
        vm.startPrank(SLASHING_ORACLE);
        L2SlashingConnector connector2 = new L2SlashingConnector(address(vpm), SLASHING_ORACLE);
        connector2.setMessenger(address(messenger));
        connector2.setChainConfig(TANGLE_CHAIN, address(0xFE), 200_000, true);
        connector2.setDefaultDestinationChain(TANGLE_CHAIN);
        connector2.registerPodOperator(POD, OPERATOR);
        vm.stopPrank();

        vm.prank(SLASHING_ORACLE);
        connector2.batchPropagateBeaconSlashing{ value: 1 ether }(pods, newFactors); // does not revert

        // The baseline must have advanced for the slash to be considered propagated.
        // With {value:0} forwarding, _propagateBeaconSlashing reverts InsufficientFee
        // before reaching the state mutation at L306, so this stays 0 (initialised).
        assertEq(
            connector2.lastProcessedSlashingFactorByChain(POD, TANGLE_CHAIN),
            0,
            "BCN-002: batch silently dropped the slash (baseline unchanged)"
        );
        assertEq(
            messenger.lastPayload().length,
            0,
            "BCN-002: batch sent no cross-chain message"
        );

        console2.log("BCN-002 PoC: batch silently dropped slash; messenger payload empty");
    }
}

contract MockMessenger is ICrossChainMessenger {
    bytes public lastPayload;
    uint256 public fee = 0.001 ether; // NON-ZERO, mirrors production L1->L2 relay fee

    function sendMessage(uint256, address, bytes calldata payload, uint256) external payable returns (bytes32) {
        require(msg.value >= fee, "fee");
        lastPayload = payload;
        return keccak256(payload);
    }

    function estimateFee(uint256, bytes calldata, uint256) external view returns (uint256) {
        return fee;
    }

    function isChainSupported(uint256) external pure returns (bool) {
        return true;
    }
}

contract MockPod {
    uint64 public beaconChainSlashingFactor;

    constructor(uint64 v) {
        beaconChainSlashingFactor = v;
    }

    function setValue(uint64 v) external {
        beaconChainSlashingFactor = v;
    }
}
