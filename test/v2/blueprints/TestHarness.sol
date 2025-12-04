// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test, console2 } from "forge-std/Test.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import { Tangle } from "../../../src/v2/Tangle.sol";
import { MultiAssetDelegation } from "../../../src/v2/restaking/MultiAssetDelegation.sol";
import { BlueprintServiceManagerBase } from "../../../src/v2/BlueprintServiceManagerBase.sol";
import { IBlueprintServiceManager } from "../../../src/v2/interfaces/IBlueprintServiceManager.sol";
import { Types } from "../../../src/v2/libraries/Types.sol";
import { Errors } from "../../../src/v2/libraries/Errors.sol";

/// @title BlueprintTestHarness
/// @notice Comprehensive test harness for BSM testing with reusable primitives
/// @dev Provides easy blueprint deployment, operator setup, and hook verification
abstract contract BlueprintTestHarness is Test {
    // ═══════════════════════════════════════════════════════════════════════════
    // CORE CONTRACTS
    // ═══════════════════════════════════════════════════════════════════════════

    Tangle public tangle;
    MultiAssetDelegation public restaking;
    ERC1967Proxy public tangleProxy;
    ERC1967Proxy public restakingProxy;

    // ═══════════════════════════════════════════════════════════════════════════
    // ACTORS
    // ═══════════════════════════════════════════════════════════════════════════

    address public admin = makeAddr("admin");
    address public treasury = makeAddr("treasury");
    address public blueprintOwner = makeAddr("blueprintOwner");
    address public serviceOwner = makeAddr("serviceOwner");

    address public operator1 = makeAddr("operator1");
    address public operator2 = makeAddr("operator2");
    address public operator3 = makeAddr("operator3");

    // ═══════════════════════════════════════════════════════════════════════════
    // TRACKING
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Deployed blueprint managers by version
    mapping(uint256 => address[]) public managersByVersion;

    /// @notice Blueprint ID to manager address
    mapping(uint64 => address) public blueprintManagers;

    /// @notice Blueprint ID to version
    mapping(uint64 => uint256) public blueprintVersions;

    /// @notice All deployed blueprint IDs
    uint64[] public deployedBlueprints;

    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS FOR VERIFICATION
    // ═══════════════════════════════════════════════════════════════════════════

    event BlueprintDeployed(uint64 indexed blueprintId, address manager, uint256 version);
    event OperatorRegisteredForBlueprint(uint64 indexed blueprintId, address operator);
    event ServiceCreated(uint64 indexed blueprintId, uint64 serviceId, address owner);

    // ═══════════════════════════════════════════════════════════════════════════
    // SETUP
    // ═══════════════════════════════════════════════════════════════════════════

    function setUp() public virtual {
        _deployProtocol();
        _fundActors();
        _registerOperatorsWithRestaking();
    }

    function _deployProtocol() internal {
        // Deploy implementations
        Tangle tangleImpl = new Tangle();
        MultiAssetDelegation restakingImpl = new MultiAssetDelegation();

        // Deploy restaking proxy
        restakingProxy = new ERC1967Proxy(
            address(restakingImpl),
            abi.encodeCall(
                MultiAssetDelegation.initialize,
                (admin, 1 ether, 0.1 ether, 1000)
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

        // Grant slasher role
        vm.prank(admin);
        restaking.addSlasher(address(tangle));
    }

    function _fundActors() internal {
        vm.deal(admin, 100 ether);
        vm.deal(blueprintOwner, 100 ether);
        vm.deal(serviceOwner, 100 ether);
        vm.deal(operator1, 100 ether);
        vm.deal(operator2, 100 ether);
        vm.deal(operator3, 100 ether);
    }

    function _registerOperatorsWithRestaking() internal {
        vm.prank(operator1);
        restaking.registerOperator{ value: 10 ether }();
        vm.prank(operator2);
        restaking.registerOperator{ value: 10 ether }();
        vm.prank(operator3);
        restaking.registerOperator{ value: 10 ether }();
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // BLUEPRINT DEPLOYMENT PRIMITIVES
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Deploy a blueprint with a specific manager version
    /// @param version The BSM version to deploy (1, 2, 3, etc.)
    /// @return blueprintId The created blueprint ID
    /// @return manager The deployed manager address
    function deployBlueprint(uint256 version) public returns (uint64 blueprintId, address manager) {
        return deployBlueprintWithOwner(version, blueprintOwner);
    }

    /// @notice Deploy a blueprint with custom owner
    function deployBlueprintWithOwner(uint256 version, address owner) public returns (uint64 blueprintId, address manager) {
        // Deploy manager based on version
        manager = _deployManager(version);

        // Create blueprint
        vm.prank(owner);
        blueprintId = tangle.createBlueprint(
            string(abi.encodePacked("ipfs://blueprint-v", _toString(version))),
            manager
        );

        // Track
        blueprintManagers[blueprintId] = manager;
        blueprintVersions[blueprintId] = version;
        managersByVersion[version].push(manager);
        deployedBlueprints.push(blueprintId);

        emit BlueprintDeployed(blueprintId, manager, version);
    }

    /// @notice Deploy a blueprint with full config
    function deployBlueprintWithConfig(
        uint256 version,
        address owner,
        Types.BlueprintConfig memory config
    ) public returns (uint64 blueprintId, address manager) {
        manager = _deployManager(version);

        vm.prank(owner);
        blueprintId = tangle.createBlueprintWithConfig(
            string(abi.encodePacked("ipfs://blueprint-v", _toString(version))),
            manager,
            config
        );

        blueprintManagers[blueprintId] = manager;
        blueprintVersions[blueprintId] = version;
        managersByVersion[version].push(manager);
        deployedBlueprints.push(blueprintId);

        emit BlueprintDeployed(blueprintId, manager, version);
    }

    /// @notice Internal: Deploy a manager for a specific version
    function _deployManager(uint256 version) internal virtual returns (address);

    // ═══════════════════════════════════════════════════════════════════════════
    // OPERATOR REGISTRATION PRIMITIVES
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Register operator for a blueprint
    function registerOperatorForBlueprint(address operator, uint64 blueprintId) public {
        vm.prank(operator);
        tangle.registerOperator(blueprintId, "", "");
        emit OperatorRegisteredForBlueprint(blueprintId, operator);
    }

    /// @notice Register all operators for a blueprint
    function registerAllOperatorsForBlueprint(uint64 blueprintId) public {
        registerOperatorForBlueprint(operator1, blueprintId);
        registerOperatorForBlueprint(operator2, blueprintId);
        registerOperatorForBlueprint(operator3, blueprintId);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SERVICE CREATION PRIMITIVES
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Create a service with single operator
    function createService(
        uint64 blueprintId,
        address operator,
        uint256 payment
    ) public returns (uint64 serviceId) {
        address[] memory operators = new address[](1);
        operators[0] = operator;
        return createServiceWithOperators(blueprintId, operators, payment);
    }

    /// @notice Create a service with multiple operators
    function createServiceWithOperators(
        uint64 blueprintId,
        address[] memory operators,
        uint256 payment
    ) public returns (uint64 serviceId) {
        address[] memory callers = new address[](0);

        vm.prank(serviceOwner);
        uint64 requestId = tangle.requestService{ value: payment }(
            blueprintId,
            operators,
            "",
            callers,
            0,
            address(0),
            payment
        );

        // Approve with all operators
        for (uint256 i = 0; i < operators.length; i++) {
            vm.prank(operators[i]);
            tangle.approveService(requestId, 0);
        }

        serviceId = tangle.serviceCount() - 1;
        emit ServiceCreated(blueprintId, serviceId, serviceOwner);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // JOB PRIMITIVES
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Submit a job for a service
    function submitJob(
        uint64 serviceId,
        uint8 jobIndex,
        bytes memory inputs
    ) public returns (uint64 callId) {
        vm.prank(serviceOwner);
        return tangle.submitJob(serviceId, jobIndex, inputs);
    }

    /// @notice Submit a job result
    function submitJobResult(
        uint64 serviceId,
        uint64 callId,
        address operator,
        bytes memory outputs
    ) public {
        vm.prank(operator);
        tangle.submitResult(serviceId, callId, outputs);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SLASHING PRIMITIVES
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Propose a slash
    function proposeSlash(
        uint64 serviceId,
        address operator,
        uint256 amount
    ) public returns (uint64 slashId) {
        vm.prank(serviceOwner);
        return tangle.proposeSlash(serviceId, operator, amount, keccak256("test-evidence"));
    }

    /// @notice Execute a slash (after dispute window)
    function executeSlash(uint64 slashId) public {
        // Fast forward past dispute window
        vm.warp(block.timestamp + 7 days + 1);
        tangle.executeSlash(slashId);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // VERIFICATION HELPERS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Get manager for blueprint
    function getManager(uint64 blueprintId) public view returns (address) {
        return blueprintManagers[blueprintId];
    }

    /// @notice Get all blueprints of a version
    function getBlueprintsOfVersion(uint256 version) public view returns (uint64[] memory) {
        uint64[] memory result = new uint64[](deployedBlueprints.length);
        uint256 count = 0;

        for (uint256 i = 0; i < deployedBlueprints.length; i++) {
            if (blueprintVersions[deployedBlueprints[i]] == version) {
                result[count++] = deployedBlueprints[i];
            }
        }

        // Resize array
        assembly {
            mstore(result, count)
        }
        return result;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // INTERNAL HELPERS
    // ═══════════════════════════════════════════════════════════════════════════

    function _toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) return "0";
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}
