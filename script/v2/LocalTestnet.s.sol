// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Script, console2 } from "forge-std/Script.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import { Tangle } from "../../src/v2/Tangle.sol";
import { MultiAssetDelegation } from "../../src/v2/restaking/MultiAssetDelegation.sol";
import { OperatorStatusRegistry } from "../../src/v2/restaking/OperatorStatusRegistry.sol";
import { TangleToken } from "../../src/v2/governance/TangleToken.sol";
import { MasterBlueprintServiceManager } from "../../src/v2/MasterBlueprintServiceManager.sol";
import { MBSMRegistry } from "../../src/v2/MBSMRegistry.sol";
import { Types } from "../../src/v2/libraries/Types.sol";
import { BlueprintDefinitionHelper } from "../../test/support/BlueprintDefinitionHelper.sol";

/// @title LocalTestnetSetup
/// @notice Deploy and setup a complete local testnet environment for integration testing
/// @dev Run with: forge script script/v2/LocalTestnet.s.sol:LocalTestnetSetup --rpc-url http://localhost:8545 --broadcast
contract LocalTestnetSetup is Script, BlueprintDefinitionHelper {

    // Anvil default accounts
    uint256 constant DEPLOYER_KEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
    uint256 constant OPERATOR1_KEY = 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d;
    uint256 constant OPERATOR2_KEY = 0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a;
    uint256 constant DELEGATOR_KEY = 0x7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6;

    address deployer;
    address operator1;
    address operator2;
    address delegator;

    bool internal useBroadcastKeys;

    // Deployed contracts
    address public tangleProxy;
    address public restakingProxy;
    address public statusRegistry;
    TangleToken public bondToken;

    // Test blueprint/service
    uint64 public blueprintId;
    uint64 public requestId;
    uint64 public serviceId;

    function run() external {
        _executeSetup(true);
    }

    /// @notice Dry run setup for CI/tests (no broadcast cheatcodes)
    function dryRun() external returns (uint64) {
        return _executeSetup(false);
    }

    function _executeSetup(bool broadcast) internal returns (uint64) {
        useBroadcastKeys = broadcast;

        // Derive addresses
        deployer = vm.addr(DEPLOYER_KEY);
        operator1 = vm.addr(OPERATOR1_KEY);
        operator2 = vm.addr(OPERATOR2_KEY);
        delegator = vm.addr(DELEGATOR_KEY);

        console2.log("=== Accounts ===");
        console2.log("Deployer:", deployer);
        console2.log("Operator1:", operator1);
        console2.log("Operator2:", operator2);
        console2.log("Delegator:", delegator);

        _deployContracts();
        _registerOperatorsRestaking();
        _createBlueprint();
        _operatorsRegisterForBlueprint();
        _delegatorStake();
        _createAndApproveService();

        console2.log("\n=== Local Testnet Ready ===");
        console2.log("Tangle:", tangleProxy);
        console2.log("MultiAssetDelegation:", restakingProxy);
        console2.log("OperatorStatusRegistry:", statusRegistry);
        console2.log("Blueprint ID:", blueprintId);
        console2.log("Service ID:", serviceId);
        console2.log("\nOperators registered and staked");
        console2.log("Delegator has delegated to both operators");
        console2.log("Service is active and ready for jobs");

        return serviceId;
    }

    function _deployContracts() internal {
        console2.log("\n=== Deploying Contracts ===");
        if (useBroadcastKeys) {
            vm.startBroadcast(DEPLOYER_KEY);
        } else {
            vm.startPrank(deployer);
        }

        // Deploy MultiAssetDelegation
        MultiAssetDelegation restakingImpl = new MultiAssetDelegation();
        bytes memory restakingInit = abi.encodeCall(
            MultiAssetDelegation.initialize,
            (deployer, 1 ether, 0.1 ether, 1000) // minOpStake, minDelegation, commissionBps
        );
        restakingProxy = address(new ERC1967Proxy(address(restakingImpl), restakingInit));
        console2.log("MultiAssetDelegation:", restakingProxy);

        // Deploy Tangle
        Tangle tangleImpl = new Tangle();
        bytes memory tangleInit = abi.encodeCall(
            Tangle.initialize,
            (deployer, restakingProxy, payable(deployer))
        );
        tangleProxy = address(new ERC1967Proxy(address(tangleImpl), tangleInit));
        console2.log("Tangle:", tangleProxy);

        // Deploy OperatorStatusRegistry
        statusRegistry = address(new OperatorStatusRegistry(tangleProxy));
        console2.log("OperatorStatusRegistry:", statusRegistry);

        // Deploy TNT bond token via proxy and mint to deployer
        TangleToken tokenImpl = new TangleToken();
        ERC1967Proxy tokenProxy = new ERC1967Proxy(
            address(tokenImpl),
            abi.encodeCall(TangleToken.initialize, (deployer, 1_000_000 ether))
        );
        bondToken = TangleToken(address(tokenProxy));
        console2.log("TangleToken (bond asset):", address(bondToken));

        // Distribute TNT to operators so they can bond
        bondToken.transfer(operator1, 1_000 ether);
        bondToken.transfer(operator2, 1_000 ether);

        // Configure cross-references
        MultiAssetDelegation(payable(restakingProxy)).addSlasher(tangleProxy);

        Tangle tangle = Tangle(payable(tangleProxy));
        tangle.setOperatorStatusRegistry(statusRegistry);
        tangle.setOperatorBondAsset(address(bondToken));

        // Deploy master blueprint service manager + registry
        MasterBlueprintServiceManager masterManager = new MasterBlueprintServiceManager(deployer, tangleProxy);
        MBSMRegistry registryImpl = new MBSMRegistry();
        ERC1967Proxy registryProxy = new ERC1967Proxy(
            address(registryImpl),
            abi.encodeCall(MBSMRegistry.initialize, (deployer))
        );
        MBSMRegistry registry = MBSMRegistry(address(registryProxy));
        registry.grantRole(registry.MANAGER_ROLE(), tangleProxy);
        registry.addVersion(address(masterManager));
        tangle.setMBSMRegistry(address(registry));

        if (useBroadcastKeys) {
            vm.stopBroadcast();
        } else {
            vm.stopPrank();
        }
    }

    function _registerOperatorsRestaking() internal {
        console2.log("\n=== Registering Operators in Restaking ===");
        MultiAssetDelegation restaking = MultiAssetDelegation(payable(restakingProxy));

        // Operator 1 registers with 10 ETH stake
        if (useBroadcastKeys) {
            vm.startBroadcast(OPERATOR1_KEY);
        } else {
            vm.startPrank(operator1);
        }
        restaking.registerOperator{ value: 10 ether }();
        console2.log("Operator1 registered with 10 ETH stake");
        if (useBroadcastKeys) {
            vm.stopBroadcast();
        } else {
            vm.stopPrank();
        }

        // Operator 2 registers with 10 ETH stake
        if (useBroadcastKeys) {
            vm.startBroadcast(OPERATOR2_KEY);
        } else {
            vm.startPrank(operator2);
        }
        restaking.registerOperator{ value: 10 ether }();
        console2.log("Operator2 registered with 10 ETH stake");
        if (useBroadcastKeys) {
            vm.stopBroadcast();
        } else {
            vm.stopPrank();
        }
    }

    function _createBlueprint() internal {
        console2.log("\n=== Creating Blueprint ===");
        if (useBroadcastKeys) {
            vm.startBroadcast(DEPLOYER_KEY);
        } else {
            vm.startPrank(deployer);
        }

        Tangle tangle = Tangle(payable(tangleProxy));

        Types.BlueprintDefinition memory def = _blueprintDefinition("ipfs://QmTestBlueprint", address(0));
        blueprintId = tangle.createBlueprint(def);
        console2.log("Blueprint created:", blueprintId);

        // Require a 100 TNT bond per operator registration
        tangle.setOperatorBlueprintBond(100 ether);
        console2.log("Operator bond set to 100 TNT");

        if (useBroadcastKeys) {
            vm.stopBroadcast();
        } else {
            vm.stopPrank();
        }
    }

    function _operatorsRegisterForBlueprint() internal {
        console2.log("\n=== Operators Registering for Blueprint ===");
        Tangle tangle = Tangle(payable(tangleProxy));
        uint256 bond = tangle.operatorBlueprintBond();
        address bondAsset = tangle.operatorBondToken();

        bytes memory operator1Key = hex"040102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f40";
        bytes memory operator2Key = hex"044142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f606162636465666768696a6b6c6d6e6f707172737475767778797a7b7c7d7e7f80";

        // Operator 1 registers for blueprint
        if (useBroadcastKeys) {
            vm.startBroadcast(OPERATOR1_KEY);
        } else {
            vm.startPrank(operator1);
        }
        if (bondAsset != address(0)) {
            bondToken.approve(tangleProxy, bond);
            tangle.registerOperator(blueprintId, operator1Key, "http://operator1.local:8545");
        } else {
            tangle.registerOperator{ value: bond }(blueprintId, operator1Key, "http://operator1.local:8545");
        }
        console2.log("Operator1 registered for blueprint");
        if (useBroadcastKeys) {
            vm.stopBroadcast();
        } else {
            vm.stopPrank();
        }

        // Operator 2 registers for blueprint
        if (useBroadcastKeys) {
            vm.startBroadcast(OPERATOR2_KEY);
        } else {
            vm.startPrank(operator2);
        }
        if (bondAsset != address(0)) {
            bondToken.approve(tangleProxy, bond);
            tangle.registerOperator(blueprintId, operator2Key, "http://operator2.local:8545");
        } else {
            tangle.registerOperator{ value: bond }(blueprintId, operator2Key, "http://operator2.local:8545");
        }
        console2.log("Operator2 registered for blueprint");
        if (useBroadcastKeys) {
            vm.stopBroadcast();
        } else {
            vm.stopPrank();
        }
    }

    function _delegatorStake() internal {
        console2.log("\n=== Delegator Staking ===");
        MultiAssetDelegation restaking = MultiAssetDelegation(payable(restakingProxy));

        if (useBroadcastKeys) {
            vm.startBroadcast(DELEGATOR_KEY);
        } else {
            vm.startPrank(delegator);
        }

        // Deposit and delegate 5 ETH to operator1
        restaking.depositAndDelegate{ value: 5 ether }(operator1);
        console2.log("Delegated 5 ETH to Operator1");

        // Deposit and delegate 5 ETH to operator2
        restaking.depositAndDelegate{ value: 5 ether }(operator2);
        console2.log("Delegated 5 ETH to Operator2");

        if (useBroadcastKeys) {
            vm.stopBroadcast();
        } else {
            vm.stopPrank();
        }
    }

    function _createAndApproveService() internal {
        console2.log("\n=== Creating and Approving Service ===");

        Tangle tangle = Tangle(payable(tangleProxy));

        // Create service request
        address[] memory operators = new address[](2);
        operators[0] = operator1;
        operators[1] = operator2;

        address[] memory permittedCallers = new address[](0);

        if (useBroadcastKeys) {
            vm.startBroadcast(DEPLOYER_KEY);
        } else {
            vm.startPrank(deployer);
        }
        requestId = tangle.requestService(
            blueprintId,
            operators,
            "", // Empty config
            permittedCallers,
            0, // No TTL
            address(0), // Native ETH payment
            0 // No payment for one-time
        );
        console2.log("Service requested, ID:", requestId);
        if (useBroadcastKeys) {
            vm.stopBroadcast();
        } else {
            vm.stopPrank();
        }

        // Operators approve the service
        if (useBroadcastKeys) {
            vm.startBroadcast(OPERATOR1_KEY);
        } else {
            vm.startPrank(operator1);
        }
        tangle.approveService(requestId, 50); // 50% restaking exposure
        console2.log("Operator1 approved service");
        if (useBroadcastKeys) {
            vm.stopBroadcast();
        } else {
            vm.stopPrank();
        }

        if (useBroadcastKeys) {
            vm.startBroadcast(OPERATOR2_KEY);
        } else {
            vm.startPrank(operator2);
        }
        tangle.approveService(requestId, 50); // 50% restaking exposure
        console2.log("Operator2 approved service");
        if (useBroadcastKeys) {
            vm.stopBroadcast();
        } else {
            vm.stopPrank();
        }

        // After all approvals, service should be active with same ID as request
        serviceId = requestId;
        console2.log("Service activated:", serviceId);
    }
}

/// @title TestServiceFlow
/// @notice Test the complete service flow after deployment
/// @dev Run after LocalTestnetSetup
contract TestServiceFlow is Script {
    uint256 constant DEPLOYER_KEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
    uint256 constant OPERATOR1_KEY = 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d;

    function run() external {
        address tangleProxy = vm.envAddress("TANGLE_PROXY");
        uint64 serviceId = uint64(vm.envUint("SERVICE_ID"));

        Tangle tangle = Tangle(payable(tangleProxy));

        console2.log("Testing service flow for service:", serviceId);

        // Submit a job (as service owner or permitted caller)
        vm.startBroadcast(DEPLOYER_KEY);
        uint64 callId = tangle.submitJob(
            serviceId,
            0, // job index
            abi.encode("test input")
        );
        console2.log("Job submitted, callId:", callId);
        vm.stopBroadcast();

        // Submit result (as operator)
        vm.startBroadcast(OPERATOR1_KEY);
        tangle.submitResult(
            serviceId,
            callId,
            abi.encode("test result")
        );
        console2.log("Job result submitted");
        vm.stopBroadcast();

        console2.log("Service flow test complete!");
    }
}

/// @title TestHeartbeat
/// @notice Test operator heartbeat submission
contract TestHeartbeat is Script {
    uint256 constant OPERATOR1_KEY = 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d;

    function run() external {
        address statusRegistry = vm.envAddress("STATUS_REGISTRY");
        uint64 serviceId = uint64(vm.envUint("SERVICE_ID"));
        uint64 blueprintId = uint64(vm.envUint("BLUEPRINT_ID"));

        OperatorStatusRegistry registry = OperatorStatusRegistry(statusRegistry);

        console2.log("Submitting heartbeat for service:", serviceId);

        vm.startBroadcast(OPERATOR1_KEY);

        // Create heartbeat signature using Foundry's vm.sign
        bytes memory metrics = "";
        bytes32 messageHash = keccak256(abi.encodePacked(serviceId, blueprintId, metrics));
        // Add Ethereum signed message prefix
        bytes32 ethSignedHash = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash)
        );
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(OPERATOR1_KEY, ethSignedHash);
        bytes memory signature = abi.encodePacked(r, s, v);

        registry.submitHeartbeat(
            serviceId,
            blueprintId,
            0, // Healthy
            metrics,
            signature
        );
        console2.log("Heartbeat submitted");

        vm.stopBroadcast();
    }
}
