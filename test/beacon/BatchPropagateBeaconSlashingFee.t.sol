// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test } from "forge-std/Test.sol";
import { ValidatorPodManager } from "src/beacon/ValidatorPodManager.sol";
import { L2SlashingConnector } from "src/beacon/L2SlashingConnector.sol";
import { MockBeaconOracle } from "../mocks/MockBeaconOracle.sol";
import { ICrossChainMessenger } from "src/beacon/interfaces/ICrossChainMessenger.sol";

/// @notice Regression for the batch fee-forwarding bug: `batchPropagateBeaconSlashing` used
///         to forward `{value: 0}` to each internal self-call, so when the messenger charges a
///         non-zero relay fee (the production case for OP-Stack/Arbitrum L1→L2 bridges) every
///         `_propagateBeaconSlashing` reverted `InsufficientFee`, the `try/catch` swallowed it,
///         and the batch silently advanced ZERO slashing factors. The fix funds each self-call
///         from the call-attributable balance and sweeps the remainder back to the caller.
contract BatchPropagateBeaconSlashingFeeTest is Test {
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

        // BCN-004 registration validation: pod must have a known owner and a registered operator.
        vm.mockCall(address(vpm), abi.encodeWithSelector(vpm.podToOwner.selector, POD), abi.encode(POD_OWNER));
        vm.mockCall(address(vpm), abi.encodeWithSelector(vpm.isOperator.selector, OPERATOR), abi.encode(true));

        vm.startPrank(SLASHING_ORACLE);
        connector = new L2SlashingConnector(address(vpm), SLASHING_ORACLE);
        connector.setMessenger(address(messenger));
        connector.setChainConfig(TANGLE_CHAIN, address(0xFE), 200_000, true);
        connector.setDefaultDestinationChain(TANGLE_CHAIN);
        connector.registerPodOperator(POD, OPERATOR);
        vm.stopPrank();
    }

    function test_batchPropagatesUnderNonZeroFee() public {
        vm.mockCall(address(vpm), abi.encodeWithSelector(vpm.totalAssetsOf.selector, POD_OWNER), abi.encode(40 ether));
        vm.mockCall(address(vpm), abi.encodeWithSelector(vpm.getOperatorStake.selector, OPERATOR), abi.encode(40 ether));

        uint64 newFactor = 0.5e18; // 50% real slash
        MockPod mockPod = new MockPod(newFactor);
        vm.etch(POD, address(mockPod).code);
        MockPod(address(POD)).setValue(newFactor);
        MockPod(address(POD)).setParked(0);

        address[] memory pods = new address[](1);
        pods[0] = POD;
        uint64[] memory newFactors = new uint64[](1);
        newFactors[0] = newFactor;

        vm.deal(SLASHING_ORACLE, 1 ether);
        uint256 oracleBefore = SLASHING_ORACLE.balance;

        vm.prank(SLASHING_ORACLE);
        connector.batchPropagateBeaconSlashing{ value: 1 ether }(pods, newFactors);

        // The batch must actually propagate: baseline advanced + a cross-chain message shipped.
        assertEq(
            connector.lastProcessedSlashingFactorByChain(POD, TANGLE_CHAIN),
            newFactor,
            "batch advanced the baseline (slash propagated)"
        );
        assertGt(messenger.lastPayload().length, 0, "batch shipped a cross-chain message");

        // Only the bridge fee was spent; the rest is swept back to the caller.
        assertEq(oracleBefore - SLASHING_ORACLE.balance, messenger.fee(), "only the fee was spent; remainder refunded");
        assertEq(address(connector).balance, 0, "no fee budget stranded in the connector");
    }
}

contract MockMessenger is ICrossChainMessenger {
    bytes public lastPayload;
    uint256 public fee = 0.001 ether; // NON-ZERO, mirrors production L1→L2 relay fee

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
    uint64 public withdrawableRestakedExecutionLayerGwei;

    constructor(uint64 v) {
        beaconChainSlashingFactor = v;
    }

    function setValue(uint64 v) external {
        beaconChainSlashingFactor = v;
    }

    function setParked(uint64 g) external {
        withdrawableRestakedExecutionLayerGwei = g;
    }
}
