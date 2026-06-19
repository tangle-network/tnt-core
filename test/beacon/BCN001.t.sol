// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test, console2 } from "forge-std/Test.sol";
import { ValidatorPodManager } from "src/beacon/ValidatorPodManager.sol";
import { L2SlashingConnector } from "src/beacon/L2SlashingConnector.sol";
import { MockBeaconOracle } from "src/beacon/BeaconRootReceiver.sol";
import { ICrossChainMessenger } from "src/beacon/interfaces/ICrossChainMessenger.sol";

/// @notice BCN-001 regression: `L2SlashingConnector` must slash only against on-beacon
///         principal, excluding parked execution-layer ETH (tips / partial withdrawals /
///         exited principal already in pod custody). Before the fix it derived the slash
///         base from `podManager.totalAssetsOf()`, which includes that parked ETH, so a
///         50% beacon slash on a 32-ETH validator with 968 ETH parked saturated `slashBps`
///         at the 10000 cap (100% of L2 stake) instead of the ~16-ETH real loss.
contract BCN001OverSlashPoC is Test {
    MockBeaconOracle oracle;
    ValidatorPodManager vpm;
    L2SlashingConnector connector;
    address constant POD = address(0xA1);
    address constant POD_OWNER = address(0xB1);
    address constant OPERATOR = address(0xC1);
    address constant SLASHING_ORACLE = address(0xD1);
    uint256 constant TANGLE_CHAIN = 5000;
    MockMessenger messenger;

    function setUp() public {
        oracle = new MockBeaconOracle();
        vpm = new ValidatorPodManager(address(oracle), 1 ether);
        messenger = new MockMessenger();

        // Make the connector's PodManager validity checks (BCN-004) pass for the mocked pod.
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

    function test_parkedEthExcludedFromSlashBase() public {
        // 32 ETH on-beacon principal + 968 ETH parked execution-layer ETH = 1000 ETH total.
        uint256 onBeaconPrincipal = 32 ether;
        uint256 parkedEth = 968 ether;
        uint256 totalAssets = onBeaconPrincipal + parkedEth;
        vm.mockCall(
            address(vpm), abi.encodeWithSelector(vpm.totalAssetsOf.selector, POD_OWNER), abi.encode(totalAssets)
        );
        vm.mockCall(
            address(vpm), abi.encodeWithSelector(vpm.getOperatorStake.selector, OPERATOR), abi.encode(100 ether)
        );

        // The pod reports its parked tally (in gwei); the connector subtracts it from the base.
        uint64 newFactor = 0.5e18; // 50% beacon slash
        MockPod mockPod = new MockPod(newFactor);
        vm.etch(POD, address(mockPod).code);
        MockPod(address(POD)).setValue(newFactor);
        MockPod(address(POD)).setParked(uint64(parkedEth / 1 gwei));

        vm.deal(SLASHING_ORACLE, 1 ether);
        vm.prank(SLASHING_ORACLE);
        connector.propagateBeaconSlashing{ value: 0.01 ether }(POD, newFactor);

        bytes memory payload = messenger.lastPayload();
        bytes memory body = new bytes(payload.length - 4);
        for (uint256 i = 0; i < body.length; i++) {
            body[i] = payload[i + 4];
        }
        (, uint16 slashBps,,,) = abi.decode(body, (address, uint16, uint64, uint256, address));

        // 50% of 32 ETH = 16 ETH lost; against a 100 ETH operator stake that is 1600 bps.
        // It must NOT saturate at 10000 (which would burn the entire L2 stake).
        assertEq(slashBps, 1600, "BCN-001: slash reflects only on-beacon principal, parked ETH excluded");
        assertLt(slashBps, 10_000, "BCN-001: no 100% saturation from parked ETH");
    }
}

contract MockMessenger is ICrossChainMessenger {
    bytes private _lastPayload;
    uint256 public fee = 0.001 ether;

    function sendMessage(uint256, address, bytes calldata payload, uint256) external payable returns (bytes32) {
        require(msg.value >= fee, "fee");
        _lastPayload = payload;
        return keccak256(payload);
    }

    function lastPayload() external view returns (bytes memory) {
        return _lastPayload;
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
