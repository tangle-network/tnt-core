// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test } from "forge-std/Test.sol";

import { DeployV2 } from "../../script/Deploy.s.sol";
import { DeployBeaconSlashingL1 } from "../../script/DeployBeaconSlashing.s.sol";
import { DeployL2Slashing } from "../../script/DeployL2Slashing.s.sol";
import { LocalTestnetSetup } from "../../script/LocalTestnet.s.sol";
import { TangleL2Slasher } from "../../src/beacon/TangleL2Slasher.sol";
import { IStaking } from "../../src/interfaces/IStaking.sol";
import { Types } from "../../src/libraries/Types.sol";
import { MultiAssetDelegation } from "../../src/staking/MultiAssetDelegation.sol";
import { OperatorStatusRegistry } from "../../src/staking/OperatorStatusRegistry.sol";
import { Tangle } from "../../src/Tangle.sol";
import { TangleToken } from "../../src/governance/TangleToken.sol";
import { FullDeploy } from "../../script/FullDeploy.s.sol";
import { ITangleFull } from "../../src/interfaces/ITangle.sol";
import { SlashingLib } from "../../src/libraries/SlashingLib.sol";
import { DeployGovernance } from "../../script/DeployGovernance.s.sol";
import { GovernanceDeployer } from "../../src/governance/GovernanceDeployer.sol";
import { TangleTimelock } from "../../src/governance/TangleTimelock.sol";
import { TangleGovernor } from "../../src/governance/TangleGovernor.sol";

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
    )
        external
        override
        returns (uint256)
    {
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
    )
        external
        override
        returns (uint256)
    {
        emit OperatorSlashed(operator, 0, slashBps, evidence);
        return slashBps;
    }

    function slash(address operator, uint64, uint16 slashBps, bytes32 evidence) external override returns (uint256) {
        emit OperatorSlashed(operator, 0, slashBps, evidence);
        return slashBps;
    }

    function isSlasher(address) external pure override returns (bool) {
        return true;
    }

    function addBlueprintForOperator(address, uint64) external override { }
    function removeBlueprintForOperator(address, uint64) external override { }

    // Pending slash tracking (no-op for mock)
    function incrementPendingSlash(address) external override { }
    function decrementPendingSlash(address) external override { }

    function getPendingSlashCount(address) external pure override returns (uint64) {
        return 0;
    }

    // F5: TWAP stake-seconds (deployment-script mock — zeros suffice)
    function getCumStakeSeconds(
        address,
        Types.Asset calldata
    )
        external
        pure
        override
        returns (uint256, uint64, uint256)
    {
        return (0, 0, 0);
    }
}

contract DeployV2Harness is DeployV2 {
    function deployCoreNoPrank(
        address admin,
        address treasury
    )
        external
        returns (address stakingProxy, address tangleProxy, address statusRegistry)
    {
        (stakingProxy,, tangleProxy,, statusRegistry) = _deployCore(0, admin, admin, treasury, false);
    }

    function deployCoreWithStatusRegistryOwnerNoPrank(
        address admin,
        address treasury,
        address statusRegistryOwner
    )
        external
        returns (address stakingProxy, address tangleProxy, address statusRegistry)
    {
        (stakingProxy,, tangleProxy,, statusRegistry) =
            _deployCore(0, admin, admin, treasury, statusRegistryOwner, false);
    }
}

contract FullDeployHarness is FullDeploy {
    function assertGovernanceConfigurationNoPrank(
        address bootstrapAdmin,
        address timelock,
        address multisig,
        address tangleAddr,
        address stakingAddr,
        address tntToken,
        address statusRegistryAddr
    )
        external
        view
    {
        RolesConfig memory roles = RolesConfig({
            admin: bootstrapAdmin,
            treasury: bootstrapAdmin,
            timelock: timelock,
            multisig: multisig,
            revokeBootstrap: true
        });

        _assertGovernanceConfiguration(
            roles,
            bootstrapAdmin,
            timelock,
            multisig,
            tangleAddr,
            stakingAddr,
            statusRegistryAddr,
            tntToken,
            address(0),
            address(0),
            address(0),
            address(0),
            address(0)
        );
    }

    function applyProtocolParamsNoPrank(
        address tangleAddr,
        SlashingParamsConfig memory slashing,
        PaymentsConfig memory payments
    )
        external
    {
        _applyProtocolParams(tangleAddr, slashing, payments);
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
        (, podManager, connector, messenger) =
            _deploy(bridge, 0, admin, admin, oracle, tangleChainId, l2Receiver, beaconOracle, true, false);
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

contract DeployGovernanceHarness is DeployGovernance {
    function deployAndRenounceNoBroadcast(GovernanceDeployer.DeployParams memory params)
        external
        returns (address token, address timelock, address governor)
    {
        return _deployAndRenounce(params);
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
        vm.deal(deployer, 1000 ether);
        DeployV2Harness script = new DeployV2Harness();
        address admin = deployer;
        address treasury = deployer;

        (address stakingProxy, address tangleProxy, address statusRegistry) = script.deployCoreNoPrank(admin, treasury);

        assertTrue(stakingProxy != address(0), "staking proxy");
        assertTrue(tangleProxy != address(0), "tangle proxy");
        assertTrue(statusRegistry != address(0), "status registry");

        MultiAssetDelegation staking = MultiAssetDelegation(payable(stakingProxy));
        bytes32 slasherRole = staking.SLASHER_ROLE();
        assertTrue(staking.hasRole(slasherRole, tangleProxy), "tangle should be slasher");
        assertEq(Tangle(payable(tangleProxy)).operatorStatusRegistry(), statusRegistry, "registry wired");
        assertTrue(Tangle(payable(tangleProxy)).tntToken() != address(0), "tnt token configured");
    }

    function testDeployCoreCanSetStatusRegistryOwnerToTimelock() public {
        address admin = makeAddr("admin");
        address treasury = makeAddr("treasury");
        address timelock = makeAddr("timelock");

        DeployV2Harness script = new DeployV2Harness();
        (, address tangleProxy, address statusRegistry) =
            script.deployCoreWithStatusRegistryOwnerNoPrank(admin, treasury, timelock);

        assertEq(OperatorStatusRegistry(statusRegistry).owner(), timelock, "status registry should start on timelock");
        assertEq(Tangle(payable(tangleProxy)).operatorStatusRegistry(), statusRegistry, "registry wired");
    }

    function testFullDeployRoleHandoffRevokesBootstrapAndPinsGovernance() public {
        address admin = makeAddr("admin");
        address treasury = makeAddr("treasury");
        address timelock = makeAddr("timelock");
        address multisig = makeAddr("multisig");

        DeployV2Harness deployHarness = new DeployV2Harness();
        (address stakingProxy, address tangleProxy, address statusRegistry) =
            deployHarness.deployCoreWithStatusRegistryOwnerNoPrank(admin, treasury, timelock);

        FullDeployHarness fullDeploy = new FullDeployHarness();
        Tangle tangle = Tangle(payable(tangleProxy));
        MultiAssetDelegation staking = MultiAssetDelegation(payable(stakingProxy));
        TangleToken token = TangleToken(tangle.tntToken());

        vm.startPrank(admin);
        tangle.grantRole(tangle.DEFAULT_ADMIN_ROLE(), timelock);
        tangle.grantRole(tangle.ADMIN_ROLE(), timelock);
        tangle.grantRole(tangle.UPGRADER_ROLE(), timelock);
        tangle.grantRole(tangle.PAUSER_ROLE(), multisig);
        tangle.grantRole(tangle.SLASH_ADMIN_ROLE(), multisig);
        tangle.revokeRole(tangle.PAUSER_ROLE(), admin);
        tangle.revokeRole(tangle.SLASH_ADMIN_ROLE(), admin);
        tangle.revokeRole(tangle.ADMIN_ROLE(), admin);
        tangle.revokeRole(tangle.UPGRADER_ROLE(), admin);
        tangle.revokeRole(tangle.DEFAULT_ADMIN_ROLE(), admin);

        staking.grantRole(staking.DEFAULT_ADMIN_ROLE(), timelock);
        staking.grantRole(staking.ADMIN_ROLE(), timelock);
        staking.grantRole(staking.ASSET_MANAGER_ROLE(), multisig);
        staking.revokeRole(staking.ASSET_MANAGER_ROLE(), admin);
        staking.revokeRole(staking.ADMIN_ROLE(), admin);
        staking.revokeRole(staking.DEFAULT_ADMIN_ROLE(), admin);

        token.grantRole(token.DEFAULT_ADMIN_ROLE(), timelock);
        token.grantRole(token.MINTER_ROLE(), timelock);
        token.grantRole(token.UPGRADER_ROLE(), timelock);
        token.revokeRole(token.MINTER_ROLE(), admin);
        token.revokeRole(token.UPGRADER_ROLE(), admin);
        token.revokeRole(token.DEFAULT_ADMIN_ROLE(), admin);
        vm.stopPrank();

        fullDeploy.assertGovernanceConfigurationNoPrank(
            admin, timelock, multisig, tangleProxy, stakingProxy, address(token), statusRegistry
        );

        assertTrue(tangle.hasRole(tangle.DEFAULT_ADMIN_ROLE(), timelock), "timelock should own tangle admin");
        assertTrue(tangle.hasRole(tangle.PAUSER_ROLE(), multisig), "multisig should own pauser");
        assertFalse(tangle.hasRole(tangle.DEFAULT_ADMIN_ROLE(), admin), "bootstrap tangle admin should be revoked");
        assertFalse(tangle.hasRole(tangle.PAUSER_ROLE(), admin), "bootstrap pauser should be revoked");

        assertTrue(staking.hasRole(staking.DEFAULT_ADMIN_ROLE(), timelock), "timelock should own staking admin");
        assertTrue(staking.hasRole(staking.ASSET_MANAGER_ROLE(), multisig), "multisig should own staking asset manager");
        assertFalse(staking.hasRole(staking.DEFAULT_ADMIN_ROLE(), admin), "bootstrap staking admin should be revoked");

        assertEq(OperatorStatusRegistry(statusRegistry).owner(), timelock, "status registry owner should stay timelock");
    }

    function testFullDeployAppliesSlashAndPaymentParams() public {
        address admin = makeAddr("admin");
        address treasury = makeAddr("treasury");
        address timelock = makeAddr("timelock");

        DeployV2Harness deployHarness = new DeployV2Harness();
        (, address tangleProxy,) = deployHarness.deployCoreWithStatusRegistryOwnerNoPrank(admin, treasury, timelock);

        FullDeployHarness fullDeploy = new FullDeployHarness();
        Tangle tangle = Tangle(payable(tangleProxy));

        // Grant the harness ADMIN_ROLE so its internal setter calls succeed — this
        // mirrors the deployer holding bootstrap admin during the real broadcast.
        // Cache the role before the prank: the inner view call would otherwise consume it.
        bytes32 adminRole = tangle.ADMIN_ROLE();
        vm.prank(admin);
        tangle.grantRole(adminRole, address(fullDeploy));

        FullDeploy.SlashingParamsConfig memory slashing = FullDeploy.SlashingParamsConfig({
            set: true,
            disputeWindow: 604_800,
            instantSlashEnabled: false,
            maxSlashBps: 5000,
            disputeResolutionDeadline: 1_814_400,
            disputeBond: 0.02 ether,
            maxPendingSlashesPerOperator: 8
        });
        FullDeploy.PaymentsConfig memory payments = FullDeploy.PaymentsConfig({
            set: true,
            developerBps: 2000,
            protocolBps: 1950,
            operatorBps: 4000,
            stakerBps: 2000,
            keeperBps: 50
        });

        fullDeploy.applyProtocolParamsNoPrank(tangleProxy, slashing, payments);

        SlashingLib.SlashConfig memory sc = ITangleFull(tangleProxy).getSlashConfig();
        assertEq(sc.maxSlashBps, 5000, "maxSlashBps should be the secure 50%, not the 100% default");
        assertEq(sc.disputeWindow, 604_800, "disputeWindow");
        assertEq(sc.disputeBond, 0.02 ether, "disputeBond should be priced, not free");
        assertEq(sc.disputeResolutionDeadline, 1_814_400, "disputeResolutionDeadline");
        assertEq(sc.maxPendingSlashesPerOperator, 8, "maxPendingSlashesPerOperator");
        assertFalse(sc.instantSlashEnabled, "instantSlash must be off");

        (uint16 dev, uint16 protocol, uint16 op, uint16 staker, uint16 keeper) =
            ITangleFull(tangleProxy).paymentSplit();
        assertEq(dev, 2000, "developerBps");
        assertEq(protocol, 1950, "protocolBps");
        assertEq(op, 4000, "operatorBps");
        assertEq(staker, 2000, "stakerBps");
        assertEq(keeper, 50, "keeperBps should fund the keeper market");
    }

    function testFullDeployPaymentSplitMustSumToTenThousand() public {
        address admin = makeAddr("admin");
        address treasury = makeAddr("treasury");

        DeployV2Harness deployHarness = new DeployV2Harness();
        (, address tangleProxy,) = deployHarness.deployCoreNoPrank(admin, treasury);

        FullDeployHarness fullDeploy = new FullDeployHarness();
        bytes32 adminRole = Tangle(payable(tangleProxy)).ADMIN_ROLE();
        vm.prank(admin);
        Tangle(payable(tangleProxy)).grantRole(adminRole, address(fullDeploy));

        FullDeploy.SlashingParamsConfig memory slashing; // set=false, skipped
        FullDeploy.PaymentsConfig memory payments = FullDeploy.PaymentsConfig({
            set: true,
            developerBps: 2000,
            protocolBps: 2000,
            operatorBps: 4000,
            stakerBps: 2000,
            keeperBps: 50 // sum = 10050, must revert
        });

        vm.expectRevert(bytes("FullDeploy: payment split must sum to 10000"));
        fullDeploy.applyProtocolParamsNoPrank(tangleProxy, slashing, payments);
    }

    function testDeployGovernanceWiresRolesAndRenouncesAdmin() public {
        DeployGovernanceHarness harness = new DeployGovernanceHarness();

        // Mainnet-shaped params with a fresh token (admin = harness for the local test).
        GovernanceDeployer.DeployParams memory params = GovernanceDeployer.DeployParams({
            tokenAdmin: address(harness),
            initialTokenSupply: 50_000_000 ether,
            existingToken: address(0),
            timelockDelay: 4 days,
            votingDelay: uint48(1 days),
            votingPeriod: uint32(7 days),
            proposalThreshold: 200_000 ether,
            quorumPercent: 6
        });

        (address token, address timelockAddr, address governorAddr) = harness.deployAndRenounceNoBroadcast(params);

        TangleTimelock timelock = TangleTimelock(payable(timelockAddr));
        TangleGovernor governor = TangleGovernor(payable(governorAddr));

        // Governor owns proposal/cancel; deployer admin is gone; params took.
        assertTrue(timelock.hasRole(timelock.PROPOSER_ROLE(), governorAddr), "governor should propose");
        assertTrue(timelock.hasRole(timelock.CANCELLER_ROLE(), governorAddr), "governor should cancel");
        assertFalse(
            timelock.hasRole(timelock.DEFAULT_ADMIN_ROLE(), address(harness)), "bootstrap admin must be renounced"
        );
        assertEq(timelock.getMinDelay(), 4 days, "timelock delay");
        assertEq(governor.votingPeriod(), 7 days, "voting period");
        assertEq(governor.proposalThreshold(), 200_000 ether, "proposal threshold");
        assertEq(governor.timelock(), timelockAddr, "governor bound to timelock");
        assertTrue(token != address(0), "token deployed");
    }

    function testDeployBeaconSlashingScriptRunsOpStack() public {
        uint256 originalChainId = block.chainid;
        vm.chainId(1); // ensure OP-Stack default L1 messenger resolves (Base on mainnet)

        // Etch dummy code at Base's L1CrossDomainMessenger so _verifyBridgeContract passes
        address l1CrossDomainMessenger = 0x866E82a600A1414e583f7F13623F1aC5d58b0Afa;
        vm.etch(l1CrossDomainMessenger, hex"00");

        uint256 privateKey = 0xB0B;
        address deployer = vm.addr(privateKey);
        vm.deal(deployer, 1000 ether);

        address admin = deployer;
        address oracle = makeAddr("oracle");
        address receiver = makeAddr("receiver");

        DeployBeaconSlashingHarness script = new DeployBeaconSlashingHarness();
        (address podManager, address connector, address messenger) = script.deployNoPrank(
            DeployBeaconSlashingL1.BridgeProtocol.OpStack, admin, oracle, 3799, receiver, address(0)
        );

        assertTrue(podManager != address(0), "pod manager deployed");
        assertTrue(connector != address(0), "connector deployed");
        assertTrue(messenger != address(0), "messenger deployed");

        vm.chainId(originalChainId);
    }

    function testDeployL2SlashingScriptRunsDirectMessenger() public {
        uint256 privateKey = 0xC0FFEE;
        address deployer = vm.addr(privateKey);
        vm.deal(deployer, 1000 ether);

        MockStaking staking = new MockStaking();
        staking.setStake(makeAddr("operator"), 32 ether);

        DeployL2SlashingHarness script = new DeployL2SlashingHarness();
        address admin = deployer;
        address messenger = makeAddr("messenger");

        (address slasher, address receiver) = script.deployNoPrank(
            DeployL2Slashing.BridgeProtocol.DirectMessenger, admin, address(staking), 11_155_111, address(0), messenger
        );

        assertTrue(slasher != address(0), "slasher deployed");
        assertTrue(receiver != address(0), "receiver deployed");

        TangleL2Slasher slasherContract = TangleL2Slasher(slasher);
        assertTrue(slasherContract.authorizedCallers(receiver), "receiver should be authorized caller");
    }

    function testLocalTestnetSetupRuns() public {
        LocalTestnetSetup script = new LocalTestnetSetup();

        address deployer = vm.addr(LOCAL_DEPLOYER_KEY);
        address operator1 = vm.addr(LOCAL_OPERATOR1_KEY);
        address operator2 = vm.addr(LOCAL_OPERATOR2_KEY);
        address delegator = vm.addr(LOCAL_DELEGATOR_KEY);

        vm.deal(deployer, 1000 ether);
        vm.deal(operator1, 1000 ether);
        vm.deal(operator2, 1000 ether);
        vm.deal(delegator, 1000 ether);

        uint64 serviceId = script.dryRun();
        assertEq(serviceId, script.requestId(), "service/request");
        assertTrue(script.tangleProxy() != address(0), "tangle deployed");
    }
}
