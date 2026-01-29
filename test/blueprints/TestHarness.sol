// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test } from "forge-std/Test.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import { Tangle } from "../../src/Tangle.sol";
import { ITangleFull } from "../../src/interfaces/ITangle.sol";
import { IMultiAssetDelegation } from "../../src/interfaces/IMultiAssetDelegation.sol";
import { MultiAssetDelegation } from "../../src/staking/MultiAssetDelegation.sol";
import { Types } from "../../src/libraries/Types.sol";
import { MasterBlueprintServiceManager } from "../../src/MasterBlueprintServiceManager.sol";
import { MBSMRegistry } from "../../src/MBSMRegistry.sol";
import { BlueprintDefinitionHelper } from "../support/BlueprintDefinitionHelper.sol";
import { TangleBlueprintsFacet } from "../../src/facets/tangle/TangleBlueprintsFacet.sol";
import { TangleBlueprintsManagementFacet } from "../../src/facets/tangle/TangleBlueprintsManagementFacet.sol";
import { TangleOperatorsFacet } from "../../src/facets/tangle/TangleOperatorsFacet.sol";
import { TangleServicesRequestsFacet } from "../../src/facets/tangle/TangleServicesRequestsFacet.sol";
import { TangleServicesFacet } from "../../src/facets/tangle/TangleServicesFacet.sol";
import { TangleServicesLifecycleFacet } from "../../src/facets/tangle/TangleServicesLifecycleFacet.sol";
import { TangleJobsFacet } from "../../src/facets/tangle/TangleJobsFacet.sol";
import { TangleJobsAggregationFacet } from "../../src/facets/tangle/TangleJobsAggregationFacet.sol";
import { TangleQuotesFacet } from "../../src/facets/tangle/TangleQuotesFacet.sol";
import { TangleQuotesExtensionFacet } from "../../src/facets/tangle/TangleQuotesExtensionFacet.sol";
import { TanglePaymentsFacet } from "../../src/facets/tangle/TanglePaymentsFacet.sol";
import { TangleSlashingFacet } from "../../src/facets/tangle/TangleSlashingFacet.sol";
import { StakingOperatorsFacet } from "../../src/facets/staking/StakingOperatorsFacet.sol";
import { StakingDepositsFacet } from "../../src/facets/staking/StakingDepositsFacet.sol";
import { StakingDelegationsFacet } from "../../src/facets/staking/StakingDelegationsFacet.sol";
import { StakingSlashingFacet } from "../../src/facets/staking/StakingSlashingFacet.sol";
import { StakingAssetsFacet } from "../../src/facets/staking/StakingAssetsFacet.sol";
import { StakingViewsFacet } from "../../src/facets/staking/StakingViewsFacet.sol";
import { StakingAdminFacet } from "../../src/facets/staking/StakingAdminFacet.sol";

import { MockServiceFeeDistributor } from "../mocks/MockServiceFeeDistributor.sol";

/// @title BlueprintTestHarness
/// @notice Comprehensive test harness for BSM testing with reusable primitives
/// @dev Provides easy blueprint deployment, operator setup, and hook verification
abstract contract BlueprintTestHarness is Test, BlueprintDefinitionHelper {
    // ═══════════════════════════════════════════════════════════════════════════
    // CORE CONTRACTS
    // ═══════════════════════════════════════════════════════════════════════════

    ITangleFull public tangle;
    IMultiAssetDelegation public staking;
    ERC1967Proxy public tangleProxy;
    ERC1967Proxy public restakingProxy;
    MasterBlueprintServiceManager public masterManager;
    MBSMRegistry public mbsmRegistry;

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

        // Deploy staking proxy
        restakingProxy = new ERC1967Proxy(
            address(restakingImpl),
            abi.encodeCall(
                MultiAssetDelegation.initialize,
                (admin, 1 ether, 0.1 ether, 1000)
            )
        );
        staking = IMultiAssetDelegation(payable(address(restakingProxy)));

        // Deploy tangle proxy
        tangleProxy = new ERC1967Proxy(
            address(tangleImpl),
            abi.encodeCall(
                Tangle.initialize,
                (admin, address(staking), payable(treasury))
            )
        );
        tangle = ITangleFull(payable(address(tangleProxy)));

        vm.startPrank(admin);
        _registerStakingFacets();
        _registerTangleFacets();
        vm.stopPrank();

        // Grant slasher role for slashing operations
        vm.prank(admin);
        staking.addSlasher(address(tangleProxy));

        // Grant tangle role for blueprint management operations
        vm.prank(admin);
        staking.setTangle(address(tangleProxy));

        masterManager = new MasterBlueprintServiceManager(admin, address(tangle));
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

        // Default payment split includes a restaker share; configure a distributor in the harness
        // so service creation/tests don't depend on treasury fallback behavior.
        MockServiceFeeDistributor distributor = new MockServiceFeeDistributor();
        vm.startPrank(admin);
        tangle.setServiceFeeDistributor(address(distributor));
        staking.setServiceFeeDistributor(address(distributor));
        vm.stopPrank();
    }

    function _registerTangleFacets() internal {
        Tangle router = Tangle(payable(address(tangleProxy)));
        router.registerFacet(address(new TangleBlueprintsFacet()));
        router.registerFacet(address(new TangleBlueprintsManagementFacet()));
        router.registerFacet(address(new TangleOperatorsFacet()));
        router.registerFacet(address(new TangleServicesRequestsFacet()));
        router.registerFacet(address(new TangleServicesFacet()));
        router.registerFacet(address(new TangleServicesLifecycleFacet()));
        router.registerFacet(address(new TangleJobsFacet()));
        router.registerFacet(address(new TangleJobsAggregationFacet()));
        router.registerFacet(address(new TangleQuotesFacet()));
        router.registerFacet(address(new TangleQuotesExtensionFacet()));
        router.registerFacet(address(new TanglePaymentsFacet()));
        router.registerFacet(address(new TangleSlashingFacet()));
    }

    function _registerStakingFacets() internal {
        MultiAssetDelegation router = MultiAssetDelegation(payable(address(restakingProxy)));
        router.registerFacet(address(new StakingOperatorsFacet()));
        router.registerFacet(address(new StakingDepositsFacet()));
        router.registerFacet(address(new StakingDelegationsFacet()));
        router.registerFacet(address(new StakingSlashingFacet()));
        router.registerFacet(address(new StakingAssetsFacet()));
        router.registerFacet(address(new StakingViewsFacet()));
        router.registerFacet(address(new StakingAdminFacet()));
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
        staking.registerOperator{ value: 10 ether }();
        vm.prank(operator2);
        staking.registerOperator{ value: 10 ether }();
        vm.prank(operator3);
        staking.registerOperator{ value: 10 ether }();
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
        blueprintId =
            tangle.createBlueprint(_blueprintDefinition(string(abi.encodePacked("ipfs://blueprint-v", _toString(version))), manager));

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
        blueprintId = tangle.createBlueprint(
            _blueprintDefinitionWithConfig(
                string(abi.encodePacked("ipfs://blueprint-v", _toString(version))),
                manager,
                config
            )
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
        tangle.registerOperator(blueprintId, _operatorGossipKey(operator, 0), "");
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
        uint256 stake = staking.getOperatorStake(operator);
        uint16 slashBps = stake == 0 ? 0 : uint16((amount * 10_000) / stake);
        if (slashBps > 10_000) slashBps = 10_000;
        vm.prank(serviceOwner);
        return tangle.proposeSlash(serviceId, operator, slashBps, keccak256("test-evidence"));
    }

    /// @notice Execute a slash (after dispute window)
    function executeSlash(uint64 slashId) public {
        // Fast forward past dispute window (+ TIMESTAMP_BUFFER for M-6 fix)
        vm.warp(block.timestamp + 7 days + 16);
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
            // forge-lint: disable-next-line(unsafe-typecast)
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function _operatorGossipKey(address operator, uint8 salt) internal pure returns (bytes memory key) {
        key = new bytes(65);
        key[0] = 0x04;
        bytes32 payload = keccak256(abi.encodePacked(operator, salt));
        for (uint256 i = 0; i < 32; ++i) {
            key[i + 1] = payload[i];
        }
    }
}
