// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Script, console2 } from "forge-std/Script.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import { Tangle } from "../../src/v2/Tangle.sol";
import { MultiAssetDelegation } from "../../src/v2/restaking/MultiAssetDelegation.sol";
import { OperatorStatusRegistry } from "../../src/v2/restaking/OperatorStatusRegistry.sol";
import { Types } from "../../src/v2/libraries/Types.sol";

/// @title LocalTestnetSetup
/// @notice Deploy and setup a complete local testnet environment for integration testing
/// @dev Run with: forge script script/v2/LocalTestnet.s.sol:LocalTestnetSetup --rpc-url http://localhost:8545 --broadcast
contract LocalTestnetSetup is Script {

    // Anvil default accounts
    uint256 constant DEPLOYER_KEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
    uint256 constant OPERATOR1_KEY = 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d;
    uint256 constant OPERATOR2_KEY = 0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a;
    uint256 constant DELEGATOR_KEY = 0x7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6;

    address deployer;
    address operator1;
    address operator2;
    address delegator;

    // Deployed contracts
    address public tangleProxy;
    address public restakingProxy;
    address public statusRegistry;

    // Test blueprint/service
    uint64 public blueprintId;
    uint64 public requestId;
    uint64 public serviceId;

    function run() external {
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

        // Step 1: Deploy all contracts
        _deployContracts();

        // Step 2: Register operators in restaking
        _registerOperatorsRestaking();

        // Step 3: Create a test blueprint
        _createBlueprint();

        // Step 4: Operators register for blueprint
        _operatorsRegisterForBlueprint();

        // Step 5: Delegator stakes to operators
        _delegatorStake();

        // Step 6: Request and approve a service
        _createAndApproveService();

        // Summary
        console2.log("\n=== Local Testnet Ready ===");
        console2.log("Tangle:", tangleProxy);
        console2.log("MultiAssetDelegation:", restakingProxy);
        console2.log("OperatorStatusRegistry:", statusRegistry);
        console2.log("Blueprint ID:", blueprintId);
        console2.log("Service ID:", serviceId);
        console2.log("\nOperators registered and staked");
        console2.log("Delegator has delegated to both operators");
        console2.log("Service is active and ready for jobs");
    }

    function _deployContracts() internal {
        console2.log("\n=== Deploying Contracts ===");
        vm.startBroadcast(DEPLOYER_KEY);

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

        // Configure cross-references
        MultiAssetDelegation(payable(restakingProxy)).addSlasher(tangleProxy);
        Tangle(payable(tangleProxy)).setOperatorStatusRegistry(statusRegistry);

        vm.stopBroadcast();
    }

    function _registerOperatorsRestaking() internal {
        console2.log("\n=== Registering Operators in Restaking ===");
        MultiAssetDelegation restaking = MultiAssetDelegation(payable(restakingProxy));

        // Operator 1 registers with 10 ETH stake
        vm.startBroadcast(OPERATOR1_KEY);
        restaking.registerOperator{ value: 10 ether }();
        console2.log("Operator1 registered with 10 ETH stake");
        vm.stopBroadcast();

        // Operator 2 registers with 10 ETH stake
        vm.startBroadcast(OPERATOR2_KEY);
        restaking.registerOperator{ value: 10 ether }();
        console2.log("Operator2 registered with 10 ETH stake");
        vm.stopBroadcast();
    }

    function _createBlueprint() internal {
        console2.log("\n=== Creating Blueprint ===");
        vm.startBroadcast(DEPLOYER_KEY);

        Tangle tangle = Tangle(payable(tangleProxy));

        // Create a simple blueprint (no manager)
        blueprintId = tangle.createBlueprint(
            "ipfs://QmTestBlueprint",
            address(0) // No manager for simplicity
        );
        console2.log("Blueprint created:", blueprintId);

        vm.stopBroadcast();
    }

    function _operatorsRegisterForBlueprint() internal {
        console2.log("\n=== Operators Registering for Blueprint ===");
        Tangle tangle = Tangle(payable(tangleProxy));

        // Operator 1 registers for blueprint
        vm.startBroadcast(OPERATOR1_KEY);
        tangle.registerOperator(blueprintId, "", ""); // Empty preferences
        console2.log("Operator1 registered for blueprint");
        vm.stopBroadcast();

        // Operator 2 registers for blueprint
        vm.startBroadcast(OPERATOR2_KEY);
        tangle.registerOperator(blueprintId, "", ""); // Empty preferences
        console2.log("Operator2 registered for blueprint");
        vm.stopBroadcast();
    }

    function _delegatorStake() internal {
        console2.log("\n=== Delegator Staking ===");
        MultiAssetDelegation restaking = MultiAssetDelegation(payable(restakingProxy));

        vm.startBroadcast(DELEGATOR_KEY);

        // Deposit and delegate 5 ETH to operator1
        restaking.depositAndDelegate{ value: 5 ether }(operator1);
        console2.log("Delegated 5 ETH to Operator1");

        // Deposit and delegate 5 ETH to operator2
        restaking.depositAndDelegate{ value: 5 ether }(operator2);
        console2.log("Delegated 5 ETH to Operator2");

        vm.stopBroadcast();
    }

    function _createAndApproveService() internal {
        console2.log("\n=== Creating and Approving Service ===");

        Tangle tangle = Tangle(payable(tangleProxy));

        // Create service request
        address[] memory operators = new address[](2);
        operators[0] = operator1;
        operators[1] = operator2;

        address[] memory permittedCallers = new address[](0);

        vm.startBroadcast(DEPLOYER_KEY);
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
        vm.stopBroadcast();

        // Operators approve the service
        vm.startBroadcast(OPERATOR1_KEY);
        tangle.approveService(requestId, 50); // 50% restaking exposure
        console2.log("Operator1 approved service");
        vm.stopBroadcast();

        vm.startBroadcast(OPERATOR2_KEY);
        tangle.approveService(requestId, 50); // 50% restaking exposure
        console2.log("Operator2 approved service");
        vm.stopBroadcast();

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
