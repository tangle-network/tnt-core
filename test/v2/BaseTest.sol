// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test } from "forge-std/Test.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { Tangle } from "../../src/v2/Tangle.sol";
import { MultiAssetDelegation } from "../../src/v2/restaking/MultiAssetDelegation.sol";
import { Types } from "../../src/v2/libraries/Types.sol";
import { BlueprintDefinitionHelper } from "../support/BlueprintDefinitionHelper.sol";
import { MasterBlueprintServiceManager } from "../../src/v2/MasterBlueprintServiceManager.sol";
import { MBSMRegistry } from "../../src/v2/MBSMRegistry.sol";

/// @title BaseTest
/// @notice Base test contract with common setup for v2 tests
abstract contract BaseTest is Test, BlueprintDefinitionHelper {
    // Contracts
    Tangle public tangle;
    MultiAssetDelegation public restaking;
    MasterBlueprintServiceManager public masterManager;
    MBSMRegistry public mbsmRegistry;

    // Proxies
    ERC1967Proxy public tangleProxy;
    ERC1967Proxy public restakingProxy;

    // Actors
    address public admin = makeAddr("admin");
    address public treasury = makeAddr("treasury");
    address public developer = makeAddr("developer");
    address public operator1 = makeAddr("operator1");
    address public operator2 = makeAddr("operator2");
    address public operator3 = makeAddr("operator3");
    address public delegator1 = makeAddr("delegator1");
    address public delegator2 = makeAddr("delegator2");
    address public user1 = makeAddr("user1");
    address public user2 = makeAddr("user2");

    // Constants
    uint256 public constant MIN_OPERATOR_STAKE = 1 ether;
    uint256 public constant MIN_DELEGATION = 0.1 ether;
    uint16 public constant OPERATOR_COMMISSION_BPS = 1000; // 10%

    function setUp() public virtual {
        // Deploy implementations
        Tangle tangleImpl = new Tangle();
        MultiAssetDelegation restakingImpl = new MultiAssetDelegation();

        // Deploy restaking proxy
        restakingProxy = new ERC1967Proxy(
            address(restakingImpl),
            abi.encodeCall(
                MultiAssetDelegation.initialize,
                (admin, MIN_OPERATOR_STAKE, MIN_DELEGATION, OPERATOR_COMMISSION_BPS)
            )
        );
        restaking = MultiAssetDelegation(payable(address(restakingProxy)));

        // Deploy tangle proxy
        tangleProxy = new ERC1967Proxy(
            address(tangleImpl),
            abi.encodeCall(
                Tangle.initialize,
                (admin, address(restaking), payable(treasury))
            )
        );
        tangle = Tangle(payable(address(tangleProxy)));

        // Setup: grant slasher role to tangle
        vm.prank(admin);
        restaking.addSlasher(address(tangle));

        // Deploy master blueprint service manager and registry
        masterManager = new MasterBlueprintServiceManager(admin, address(tangle));
        MBSMRegistry registryImpl = new MBSMRegistry();
        ERC1967Proxy registryProxy = new ERC1967Proxy(
            address(registryImpl),
            abi.encodeCall(MBSMRegistry.initialize, (admin))
        );
        mbsmRegistry = MBSMRegistry(address(registryProxy));

        vm.startPrank(admin);
        mbsmRegistry.grantRole(mbsmRegistry.MANAGER_ROLE(), address(tangle));
        mbsmRegistry.addVersion(address(masterManager));
        tangle.setMBSMRegistry(address(mbsmRegistry));
        vm.stopPrank();

        // Fund actors
        vm.deal(operator1, 100 ether);
        vm.deal(operator2, 100 ether);
        vm.deal(operator3, 100 ether);
        vm.deal(delegator1, 100 ether);
        vm.deal(delegator2, 100 ether);
        vm.deal(user1, 100 ether);
        vm.deal(user2, 100 ether);
        vm.deal(developer, 100 ether);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // HELPERS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Register an operator with minimum stake
    function _registerOperator(address operator) internal {
        vm.prank(operator);
        restaking.registerOperator{ value: MIN_OPERATOR_STAKE }();
    }

    /// @notice Register an operator with custom stake
    function _registerOperator(address operator, uint256 stake) internal {
        vm.prank(operator);
        restaking.registerOperator{ value: stake }();
    }

    /// @notice Create a blueprint and return its ID
    function _createBlueprint(address owner) internal returns (uint64) {
        vm.prank(owner);
        return tangle.createBlueprint(_blueprintDefinition("ipfs://metadata", address(0)));
    }

    function _createBlueprint(address owner, string memory metadataUri) internal returns (uint64) {
        vm.prank(owner);
        return tangle.createBlueprint(_blueprintDefinition(metadataUri, address(0)));
    }

    /// @notice Create a blueprint with service manager
    function _createBlueprint(address owner, address manager) internal returns (uint64) {
        vm.prank(owner);
        return tangle.createBlueprint(_blueprintDefinition("ipfs://metadata", manager));
    }

    function _createBlueprint(
        address owner,
        string memory metadataUri,
        address manager
    ) internal returns (uint64) {
        vm.prank(owner);
        return tangle.createBlueprint(_blueprintDefinition(metadataUri, manager));
    }

    /// @notice Create a blueprint with explicit configuration
    function _createBlueprintWithConfig(
        address owner,
        address manager,
        Types.BlueprintConfig memory config
    ) internal returns (uint64) {
        vm.prank(owner);
        return tangle.createBlueprint(_blueprintDefinitionWithConfig("ipfs://metadata", manager, config));
    }

    function _createBlueprintWithConfig(
        address owner,
        string memory metadataUri,
        address manager,
        Types.BlueprintConfig memory config
    ) internal returns (uint64) {
        vm.prank(owner);
        return tangle.createBlueprint(_blueprintDefinitionWithConfig(metadataUri, manager, config));
    }

    /// @notice Create a blueprint using the current msg.sender (expects caller to prank)
    function _createBlueprintAsSender(
        string memory metadataUri,
        address manager
    ) internal returns (uint64) {
        return tangle.createBlueprint(_blueprintDefinition(metadataUri, manager));
    }

    /// @notice Create a blueprint with config using the current msg.sender
    function _createBlueprintWithConfigAsSender(
        string memory metadataUri,
        address manager,
        Types.BlueprintConfig memory config
    ) internal returns (uint64) {
        return tangle.createBlueprint(_blueprintDefinitionWithConfig(metadataUri, manager, config));
    }

    /// @notice Create a blueprint with a specific number of job definitions using current msg.sender
    function _createBlueprintAsSenderWithJobs(
        string memory metadataUri,
        address manager,
        uint256 jobCount
    ) internal returns (uint64) {
        return tangle.createBlueprint(_blueprintDefinitionWithJobCount(metadataUri, manager, jobCount));
    }

    /// @notice Create a fixed service with custom job schemas and optional manager
    function _createServiceWithSchemas(
        bytes memory paramsSchema,
        bytes memory resultSchema,
        address manager
    ) internal returns (uint64 blueprintId, uint64 serviceId) {
        Types.BlueprintDefinition memory def = _blueprintDefinition("ipfs://schema-service", manager);
        def.jobs[0].paramsSchema = paramsSchema;
        def.jobs[0].resultSchema = resultSchema;

        vm.prank(developer);
        blueprintId = tangle.createBlueprint(def);

        _registerForBlueprint(operator1, blueprintId);

        address[] memory ops = new address[](1);
        ops[0] = operator1;
        address[] memory callers = new address[](0);

        vm.prank(user1);
        uint64 requestId = tangle.requestService(blueprintId, ops, "", callers, 0, address(0), 0);

        vm.prank(operator1);
        tangle.approveService(requestId, 0);

        serviceId = tangle.serviceCount() - 1;
    }

    /// @notice Register operator for a blueprint
    function _registerForBlueprint(address operator, uint64 blueprintId) internal {
        vm.prank(operator);
        tangle.registerOperator(blueprintId, _operatorGossipKey(operator, 0), "http://localhost:8545", "");
    }

    function _registerForBlueprint(address operator, uint64 blueprintId, bytes memory registrationInputs) internal {
        vm.prank(operator);
        tangle.registerOperator(blueprintId, _operatorGossipKey(operator, 0), "http://localhost:8545", registrationInputs);
    }

    function _directRegisterOperator(address operator, uint64 blueprintId, string memory rpc) internal {
        vm.prank(operator);
        tangle.registerOperator(blueprintId, _operatorGossipKey(operator, 0), rpc);
    }

    function _directRegisterOperator(
        address operator,
        uint64 blueprintId,
        string memory rpc,
        bytes memory registrationInputs
    ) internal {
        vm.prank(operator);
        tangle.registerOperator(blueprintId, _operatorGossipKey(operator, 0), rpc, registrationInputs);
    }

    /// @notice Deterministically derives a unique 65-byte uncompressed key per operator/salt
    function _operatorGossipKey(address operator, uint8 salt) internal pure returns (bytes memory key) {
        key = new bytes(65);
        key[0] = 0x04;
        bytes32 payload = keccak256(abi.encodePacked(operator, salt));
        for (uint256 i = 0; i < 32; ++i) {
            key[i + 1] = payload[i];
        }
    }

    /// @notice Request a service with single operator
    function _requestService(
        address requester,
        uint64 blueprintId,
        address operator
    ) internal returns (uint64) {
        address[] memory operators = new address[](1);
        operators[0] = operator;
        address[] memory callers = new address[](0);

        vm.prank(requester);
        return tangle.requestService(blueprintId, operators, "", callers, 0, address(0), 0);
    }

    /// @notice Request a service with payment
    function _requestServiceWithPayment(
        address requester,
        uint64 blueprintId,
        address operator,
        uint256 payment
    ) internal returns (uint64) {
        address[] memory operators = new address[](1);
        operators[0] = operator;
        address[] memory callers = new address[](0);

        vm.prank(requester);
        return tangle.requestService{ value: payment }(
            blueprintId, operators, "", callers, 0, address(0), payment
        );
    }

    /// @notice Approve a service request
    function _approveService(address operator, uint64 requestId) internal {
        vm.prank(operator);
        tangle.approveService(requestId, 0);
    }

    /// @notice Create a service with custom exposures and optional manager
    function _createServiceWithExposure(
        address manager,
        address[] memory ops,
        uint16[] memory exposures
    ) internal returns (uint64 blueprintId, uint64 serviceId) {
        Types.BlueprintDefinition memory def = _blueprintDefinition("ipfs://job-manager", manager);
        def.jobs[0].paramsSchema = _boolSchema();
        def.jobs[0].resultSchema = _boolSchema();

        vm.prank(developer);
        blueprintId = tangle.createBlueprint(def);

        for (uint256 i = 0; i < ops.length; i++) {
            _registerForBlueprint(ops[i], blueprintId);
        }

        address[] memory callers = new address[](0);
        vm.prank(user1);
        uint64 requestId = tangle.requestServiceWithExposure(
            blueprintId,
            ops,
            exposures,
            "",
            callers,
            0,
            address(0),
            0
        );

        for (uint256 i = 0; i < ops.length; i++) {
            vm.prank(ops[i]);
            tangle.approveService(requestId, 0);
        }

        serviceId = tangle.serviceCount() - 1;
    }

    /// @notice Request a service paying with ERC20 tokens
    function _requestServiceWithErc20(
        address requester,
        uint64 blueprintId,
        address operator,
        address token,
        uint256 payment
    ) internal returns (uint64 requestId) {
        address[] memory operators = new address[](1);
        operators[0] = operator;
        address[] memory callers = new address[](0);

        vm.startPrank(requester);
        IERC20(token).approve(address(tangle), payment);
        requestId = tangle.requestService(
            blueprintId,
            operators,
            "",
            callers,
            0,
            token,
            payment
        );
        vm.stopPrank();
    }
}
