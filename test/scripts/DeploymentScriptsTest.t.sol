// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";

import {DeployV2} from "../../script/Deploy.s.sol";
import {DeployBeaconSlashingL1} from "../../script/DeployBeaconSlashing.s.sol";
import {DeployL2Slashing} from "../../script/DeployL2Slashing.s.sol";
import {LocalTestnetSetup} from "../../script/LocalTestnet.s.sol";
import {L2SlashingReceiver} from "../../src/beacon/L2SlashingReceiver.sol";
import {TangleL2Slasher} from "../../src/beacon/TangleL2Slasher.sol";
import {HyperlaneReceiver} from "../../src/beacon/bridges/HyperlaneCrossChainMessenger.sol";
import {LayerZeroReceiver} from "../../src/beacon/bridges/LayerZeroCrossChainMessenger.sol";
import { IStaking } from "../../src/interfaces/IStaking.sol";
import { Types } from "../../src/libraries/Types.sol";
import { MultiAssetDelegation } from "../../src/staking/MultiAssetDelegation.sol";
import { Tangle } from "../../src/Tangle.sol";

/// @notice Minimal staking stub so L2 slashing scripts can deploy their contracts
contract MockStaking is IStaking {
    mapping(address => uint256) public operatorStake;

    function setStake(address operator, uint256 amount) external {
        operatorStake[operator] = amount;
    }

    function isOperator(address) external pure override returns (bool) {
        return true;
    }

    function isOperatorActive(address) external pure override returns (bool) {
        return true;
    }

    function getOperatorStake(address operator) external view override returns (uint256) {
        return operatorStake[operator];
    }

    function getOperatorSelfStake(address operator) external view override returns (uint256) {
        return operatorStake[operator];
    }

    function getOperatorDelegatedStake(address) external pure override returns (uint256) {
        return 0;
    }

    function getOperatorDelegatedStakeForAsset(address, Types.Asset calldata) external pure override returns (uint256) {
        return 0;
    }

    function getOperatorStakeForAsset(address operator, Types.Asset calldata) external view override returns (uint256) {
        return operatorStake[operator];
    }

    function getDelegation(address, address) external pure override returns (uint256) {
        return 0;
    }

    function getTotalDelegation(address) external pure override returns (uint256) {
        return 0;
    }

    function minOperatorStake() external pure override returns (uint256) {
        return 1 ether;
    }

    function meetsStakeRequirement(address, uint256) external pure override returns (bool) {
        return true;
    }

    function slashForBlueprint(
        address operator,
        uint64,
        uint64,
        uint16 slashBps,
        bytes32 evidence
    ) external override returns (uint256) {
        emit OperatorSlashed(operator, 0, slashBps, evidence);
        return slashBps;
    }

    function slashForService(
        address operator,
        uint64,
        uint64,
        Types.AssetSecurityCommitment[] calldata,
        uint16 slashBps,
        bytes32 evidence
    ) external override returns (uint256) {
        emit OperatorSlashed(operator, 0, slashBps, evidence);
        return slashBps;
    }

    function slash(
        address operator,
        uint64,
        uint16 slashBps,
        bytes32 evidence
    ) external override returns (uint256) {
        emit OperatorSlashed(operator, 0, slashBps, evidence);
        return slashBps;
    }

    function isSlasher(address) external pure override returns (bool) {
        return true;
    }

    function addBlueprintForOperator(address, uint64) external override {}
    function removeBlueprintForOperator(address, uint64) external override {}

    // M-9 FIX: Pending slash tracking (no-op for mock)
    function incrementPendingSlash(address) external override {}
    function decrementPendingSlash(address) external override {}
    function getPendingSlashCount(address) external pure override returns (uint64) { return 0; }
}

contract DeployV2Harness is DeployV2 {
    function deployCoreNoPrank(address admin, address treasury)
        external
        returns (address stakingProxy, address tangleProxy, address statusRegistry)
    {
        (
            stakingProxy,
            ,
            tangleProxy,
            ,
            statusRegistry
        ) = _deployCore(0, admin, admin, treasury, false);
    }
}

contract DeployBeaconSlashingHarness is DeployBeaconSlashingL1 {
    function deployNoPrank(
        BridgeProtocol bridge,
        address admin,
        address oracle,
        uint256 tangleChainId,
        address l2Receiver,
        address beaconOracle
    )
        external
        returns (address podManager, address connector, address messenger)
    {
        (, podManager, connector, messenger) = _deploy(
            bridge,
            0,
            admin,
            admin,
            oracle,
            tangleChainId,
            l2Receiver,
            beaconOracle,
            true,
            false
        );
    }
}

contract DeployL2SlashingHarness is DeployL2Slashing {
    function deployNoPrank(
        BridgeProtocol bridge,
        address admin,
        address staking,
        uint256 sourceChainId,
        address l1Connector,
        address messengerOverride
    )
        external
        returns (address slasher, address receiver)
    {
        (slasher, receiver,) = _deploy(
            bridge,
            0,
            admin,
            admin,
            staking,
            sourceChainId,
            l1Connector,
            messengerOverride,
            vm.envOr("L1_MESSENGER", address(0)),
            false
        );
    }
}

contract DeploymentScriptsTest is Test {
    uint256 internal constant LOCAL_DEPLOYER_KEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
    uint256 internal constant LOCAL_OPERATOR1_KEY = 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d;
    uint256 internal constant LOCAL_OPERATOR2_KEY = 0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a;
    uint256 internal constant LOCAL_DELEGATOR_KEY = 0x7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6;

    function testDeployV2ScriptRuns() public {
        uint256 privateKey = 0xA11CE;
        address deployer = vm.addr(privateKey);
        vm.deal(deployer, 1_000 ether);
        DeployV2Harness script = new DeployV2Harness();
        address admin = deployer;
        address treasury = deployer;

        (address stakingProxy, address tangleProxy, address statusRegistry) =
            script.deployCoreNoPrank(admin, treasury);

        assertTrue(stakingProxy != address(0), "restaking proxy");
        assertTrue(tangleProxy != address(0), "tangle proxy");
        assertTrue(statusRegistry != address(0), "status registry");

        MultiAssetDelegation staking = MultiAssetDelegation(payable(stakingProxy));
        bytes32 slasherRole = staking.SLASHER_ROLE();
        assertTrue(staking.hasRole(slasherRole, tangleProxy), "tangle should be slasher");
        assertEq(Tangle(payable(tangleProxy)).operatorStatusRegistry(), statusRegistry, "registry wired");
        assertTrue(Tangle(payable(tangleProxy)).tntToken() != address(0), "tnt token configured");
    }

    function testDeployBeaconSlashingScriptRunsHyperlane() public {
        uint256 originalChainId = block.chainid;
        vm.chainId(1); // ensure Hyperlane addresses resolve

        // Etch dummy code at mainnet Hyperlane addresses so _verifyBridgeContract passes
        address hyperlaneMailbox = 0xc005dc82818d67AF737725bD4bf75435d065D239;
        address hyperlaneIgp = 0x6cA0B6D22da47f091B7613223cD4BB03a2d77918;
        vm.etch(hyperlaneMailbox, hex"00");
        vm.etch(hyperlaneIgp, hex"00");

        uint256 privateKey = 0xB0B;
        address deployer = vm.addr(privateKey);
        vm.deal(deployer, 1_000 ether);

        address admin = deployer;
        address oracle = makeAddr("oracle");
        address receiver = makeAddr("receiver");

        DeployBeaconSlashingHarness script = new DeployBeaconSlashingHarness();
        (address podManager, address connector, address messenger) = script.deployNoPrank(
            DeployBeaconSlashingL1.BridgeProtocol.Hyperlane,
            admin,
            oracle,
            3799,
            receiver,
            address(0)
        );

        assertTrue(podManager != address(0), "pod manager deployed");
        assertTrue(connector != address(0), "connector deployed");
        assertTrue(messenger != address(0), "messenger deployed");

        vm.chainId(originalChainId);
    }

    function testDeployBeaconSlashingScriptRunsLayerZero() public {
        uint256 originalChainId = block.chainid;
        vm.chainId(11155111); // Sepolia supported by both messengers

        // Etch dummy code at Sepolia LayerZero endpoint so _verifyBridgeContract passes
        address layerZeroEndpoint = 0x6EDCE65403992e310A62460808c4b910D972f10f;
        vm.etch(layerZeroEndpoint, hex"00");

        uint256 privateKey = 0xCAFE;
        address deployer = vm.addr(privateKey);
        vm.deal(deployer, 1_000 ether);

        address admin = deployer;
        address oracle = makeAddr("oracle2");
        address receiver = makeAddr("receiver2");

        DeployBeaconSlashingHarness script = new DeployBeaconSlashingHarness();
        (address podManager, address connector, address messenger) = script.deployNoPrank(
            DeployBeaconSlashingL1.BridgeProtocol.LayerZero,
            admin,
            oracle,
            3799,
            receiver,
            address(0)
        );

        assertTrue(podManager != address(0), "pod manager deployed");
        assertTrue(connector != address(0), "connector deployed");
        assertTrue(messenger != address(0), "layerzero messenger deployed");

        vm.chainId(originalChainId);
    }

    function testDeployL2SlashingScriptRunsDirectMessenger() public {
        uint256 privateKey = 0xC0FFEE;
        address deployer = vm.addr(privateKey);
        vm.deal(deployer, 1_000 ether);

        MockStaking staking = new MockStaking();
        staking.setStake(makeAddr("operator"), 32 ether);

        DeployL2SlashingHarness script = new DeployL2SlashingHarness();
        address admin = deployer;
        address messenger = makeAddr("messenger");

        (address slasher, address receiver) = script.deployNoPrank(
            DeployL2Slashing.BridgeProtocol.DirectMessenger,
            admin,
            address(staking),
            11155111,
            address(0),
            messenger
        );

        assertTrue(slasher != address(0), "slasher deployed");
        assertTrue(receiver != address(0), "receiver deployed");

        TangleL2Slasher slasherContract = TangleL2Slasher(slasher);
        assertTrue(slasherContract.authorizedCallers(receiver), "receiver should be authorized caller");
    }

    function testDeployL2SlashingScriptRunsHyperlane() public {
        uint256 privateKey = 0xDAD;
        address deployer = vm.addr(privateKey);
        vm.deal(deployer, 1_000 ether);

        MockStaking staking = new MockStaking();
        staking.setStake(makeAddr("operator"), 32 ether);

        // Provide Hyperlane mailbox via env and etch code at address
        address mailbox = makeAddr("hyperlaneMailbox");
        vm.etch(mailbox, hex"00"); // Etch dummy code so _verifyBridgeContract passes
        vm.setEnv("HYPERLANE_MAILBOX", vm.toString(mailbox));
        vm.setEnv("L1_MESSENGER", vm.toString(makeAddr("hyperlaneL1Messenger")));

        DeployL2SlashingHarness script = new DeployL2SlashingHarness();
        address admin = deployer;
        address l1Connector = makeAddr("l1Connector");

        (address slasher, address receiver) = script.deployNoPrank(
            DeployL2Slashing.BridgeProtocol.Hyperlane,
            admin,
            address(staking),
            1,
            l1Connector,
            address(0)
        );

        assertTrue(slasher != address(0), "slasher deployed");
        assertTrue(receiver != address(0), "receiver deployed");
        address adapter = L2SlashingReceiver(receiver).messenger();
        assertTrue(adapter != address(0) && adapter.code.length > 0, "hyperlane adapter deployed");
        assertEq(HyperlaneReceiver(adapter).mailbox(), mailbox, "hyperlane mailbox wired");
    }

    function testDeployL2SlashingScriptRunsLayerZero() public {
        uint256 privateKey = 0xDAD1;
        address deployer = vm.addr(privateKey);
        vm.deal(deployer, 1_000 ether);

        MockStaking staking = new MockStaking();
        staking.setStake(makeAddr("operator"), 32 ether);

        // Provide LayerZero endpoint via env and etch code at address
        address endpoint = makeAddr("layerzeroEndpoint");
        vm.etch(endpoint, hex"00"); // Etch dummy code so _verifyBridgeContract passes
        vm.setEnv("LAYERZERO_ENDPOINT", vm.toString(endpoint));
        vm.setEnv("L1_MESSENGER", vm.toString(makeAddr("layerzeroL1Messenger")));
        // Provide the source EID explicitly for the harness (chainId 1 => 30101).
        vm.setEnv("LAYERZERO_SOURCE_EID", vm.toString(uint256(30101)));

        DeployL2SlashingHarness script = new DeployL2SlashingHarness();
        address admin = deployer;
        address l1Connector = makeAddr("l1ConnectorLZ");

        (address slasher, address receiver) = script.deployNoPrank(
            DeployL2Slashing.BridgeProtocol.LayerZero,
            admin,
            address(staking),
            1,
            l1Connector,
            address(0)
        );

        assertTrue(slasher != address(0), "slasher deployed");
        assertTrue(receiver != address(0), "receiver deployed");
        address adapter = L2SlashingReceiver(receiver).messenger();
        assertTrue(adapter != address(0) && adapter.code.length > 0, "layerzero adapter deployed");
        assertEq(LayerZeroReceiver(adapter).endpoint(), endpoint, "layerzero endpoint wired");
    }

    function testLocalTestnetSetupRuns() public {
        LocalTestnetSetup script = new LocalTestnetSetup();

        address deployer = vm.addr(LOCAL_DEPLOYER_KEY);
        address operator1 = vm.addr(LOCAL_OPERATOR1_KEY);
        address operator2 = vm.addr(LOCAL_OPERATOR2_KEY);
        address delegator = vm.addr(LOCAL_DELEGATOR_KEY);

        vm.deal(deployer, 1_000 ether);
        vm.deal(operator1, 1_000 ether);
        vm.deal(operator2, 1_000 ether);
        vm.deal(delegator, 1_000 ether);

        uint64 serviceId = script.dryRun();
        assertEq(serviceId, script.requestId(), "service/request");
        assertTrue(script.tangleProxy() != address(0), "tangle deployed");
    }
}
