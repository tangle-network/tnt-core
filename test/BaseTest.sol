// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test } from "forge-std/Test.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { Tangle } from "../src/Tangle.sol";
import { ITangleFull } from "../src/interfaces/ITangle.sol";
import { IMultiAssetDelegation } from "../src/interfaces/IMultiAssetDelegation.sol";
import { MultiAssetDelegation } from "../src/staking/MultiAssetDelegation.sol";
import { Types } from "../src/libraries/Types.sol";
import { BlueprintDefinitionHelper } from "./support/BlueprintDefinitionHelper.sol";
import { MasterBlueprintServiceManager } from "../src/MasterBlueprintServiceManager.sol";
import { MBSMRegistry } from "../src/MBSMRegistry.sol";
import { TangleBlueprintsFacet } from "../src/facets/tangle/TangleBlueprintsFacet.sol";
import { TangleBlueprintsManagementFacet } from "../src/facets/tangle/TangleBlueprintsManagementFacet.sol";
import { TangleOperatorsFacet } from "../src/facets/tangle/TangleOperatorsFacet.sol";
import { TangleServicesRequestsFacet } from "../src/facets/tangle/TangleServicesRequestsFacet.sol";
import { TangleServicesFacet } from "../src/facets/tangle/TangleServicesFacet.sol";
import { TangleServicesLifecycleFacet } from "../src/facets/tangle/TangleServicesLifecycleFacet.sol";
import { TangleJobsFacet } from "../src/facets/tangle/TangleJobsFacet.sol";
import { TangleJobsAggregationFacet } from "../src/facets/tangle/TangleJobsAggregationFacet.sol";
import { TangleQuotesFacet } from "../src/facets/tangle/TangleQuotesFacet.sol";
import { TangleQuotesExtensionFacet } from "../src/facets/tangle/TangleQuotesExtensionFacet.sol";
import { TanglePaymentsFacet } from "../src/facets/tangle/TanglePaymentsFacet.sol";
import { TangleSlashingFacet } from "../src/facets/tangle/TangleSlashingFacet.sol";
import { StakingOperatorsFacet } from "../src/facets/staking/StakingOperatorsFacet.sol";
import { StakingDepositsFacet } from "../src/facets/staking/StakingDepositsFacet.sol";
import { StakingDelegationsFacet } from "../src/facets/staking/StakingDelegationsFacet.sol";
import { StakingSlashingFacet } from "../src/facets/staking/StakingSlashingFacet.sol";
import { StakingAssetsFacet } from "../src/facets/staking/StakingAssetsFacet.sol";
import { StakingViewsFacet } from "../src/facets/staking/StakingViewsFacet.sol";
import { StakingAdminFacet } from "../src/facets/staking/StakingAdminFacet.sol";

import { MockServiceFeeDistributor } from "./mocks/MockServiceFeeDistributor.sol";

/// @title BaseTest
/// @notice Base test contract with common setup for v2 tests
abstract contract BaseTest is Test, BlueprintDefinitionHelper {
    // Contracts
    ITangleFull public tangle;
    IMultiAssetDelegation public staking;
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

        // Deploy staking proxy
        restakingProxy = new ERC1967Proxy(
            address(restakingImpl),
            abi.encodeCall(
                MultiAssetDelegation.initialize, (admin, MIN_OPERATOR_STAKE, MIN_DELEGATION, OPERATOR_COMMISSION_BPS)
            )
        );
        staking = IMultiAssetDelegation(payable(address(restakingProxy)));

        // Deploy tangle proxy
        tangleProxy = new ERC1967Proxy(
            address(tangleImpl), abi.encodeCall(Tangle.initialize, (admin, address(staking), payable(treasury)))
        );
        tangle = ITangleFull(payable(address(tangleProxy)));

        vm.startPrank(admin);
        _registerStakingFacets();
        _registerTangleFacets();
        vm.stopPrank();

        // Setup: grant slasher role to tangle for slashing operations
        vm.prank(admin);
        staking.addSlasher(address(tangleProxy));

        // Setup: grant tangle role for blueprint management operations
        vm.prank(admin);
        staking.setTangle(address(tangleProxy));

        // Deploy master blueprint service manager and registry
        masterManager = new MasterBlueprintServiceManager(admin, address(tangle));
        MBSMRegistry registryImpl = new MBSMRegistry();
        ERC1967Proxy registryProxy =
            new ERC1967Proxy(address(registryImpl), abi.encodeCall(MBSMRegistry.initialize, (admin)));
        mbsmRegistry = MBSMRegistry(address(registryProxy));

        vm.startPrank(admin);
        mbsmRegistry.grantRole(mbsmRegistry.MANAGER_ROLE(), address(tangleProxy));
        mbsmRegistry.addVersion(address(masterManager));
        Tangle(payable(address(tangleProxy))).setMBSMRegistry(address(mbsmRegistry));
        vm.stopPrank();

        // Configure a default service-fee distributor so the default payment split
        // (which includes a restaker share) behaves like production deployments.
        MockServiceFeeDistributor distributor = new MockServiceFeeDistributor();
        vm.startPrank(admin);
        tangle.setServiceFeeDistributor(address(distributor));
        staking.setServiceFeeDistributor(address(distributor));
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

    /// @notice Register an operator with minimum stake and enable delegation
    function _registerOperator(address operator) internal {
        vm.prank(operator);
        staking.registerOperator{ value: MIN_OPERATOR_STAKE }();
        // Enable delegation by default for tests
        vm.prank(operator);
        staking.setDelegationMode(Types.DelegationMode.Open);
    }

    /// @notice Register an operator with custom stake and enable delegation
    function _registerOperator(address operator, uint256 stake) internal {
        vm.prank(operator);
        staking.registerOperator{ value: stake }();
        // Enable delegation by default for tests
        vm.prank(operator);
        staking.setDelegationMode(Types.DelegationMode.Open);
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

    function _createBlueprint(address owner, string memory metadataUri, address manager) internal returns (uint64) {
        vm.prank(owner);
        return tangle.createBlueprint(_blueprintDefinition(metadataUri, manager));
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

    /// @notice Create a blueprint with explicit configuration
    function _createBlueprintWithConfig(
        address owner,
        address manager,
        Types.BlueprintConfig memory config
    )
        internal
        returns (uint64)
    {
        vm.prank(owner);
        return tangle.createBlueprint(_blueprintDefinitionWithConfig("ipfs://metadata", manager, config));
    }

    function _createBlueprintWithConfig(
        address owner,
        string memory metadataUri,
        address manager,
        Types.BlueprintConfig memory config
    )
        internal
        returns (uint64)
    {
        vm.prank(owner);
        return tangle.createBlueprint(_blueprintDefinitionWithConfig(metadataUri, manager, config));
    }

    /// @notice Create a blueprint using the current msg.sender (expects caller to prank)
    function _createBlueprintAsSender(string memory metadataUri, address manager) internal returns (uint64) {
        return tangle.createBlueprint(_blueprintDefinition(metadataUri, manager));
    }

    /// @notice Create a blueprint with config using the current msg.sender
    function _createBlueprintWithConfigAsSender(
        string memory metadataUri,
        address manager,
        Types.BlueprintConfig memory config
    )
        internal
        returns (uint64)
    {
        return tangle.createBlueprint(_blueprintDefinitionWithConfig(metadataUri, manager, config));
    }

    /// @notice Create a blueprint with a specific number of job definitions using current msg.sender
    function _createBlueprintAsSenderWithJobs(
        string memory metadataUri,
        address manager,
        uint256 jobCount
    )
        internal
        returns (uint64)
    {
        return tangle.createBlueprint(_blueprintDefinitionWithJobCount(metadataUri, manager, jobCount));
    }

    /// @notice Create a fixed service with custom job schemas and optional manager
    function _createServiceWithSchemas(
        bytes memory paramsSchema,
        bytes memory resultSchema,
        address manager
    )
        internal
        returns (uint64 blueprintId, uint64 serviceId)
    {
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
        tangle.registerOperator(
            blueprintId, _operatorGossipKey(operator, 0), "http://localhost:8545", registrationInputs
        );
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
    )
        internal
    {
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
    function _requestService(address requester, uint64 blueprintId, address operator) internal returns (uint64) {
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
    )
        internal
        returns (uint64)
    {
        address[] memory operators = new address[](1);
        operators[0] = operator;
        address[] memory callers = new address[](0);

        vm.prank(requester);
        return tangle.requestService{ value: payment }(blueprintId, operators, "", callers, 0, address(0), payment);
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
    )
        internal
        returns (uint64 blueprintId, uint64 serviceId)
    {
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
        uint64 requestId = tangle.requestServiceWithExposure(blueprintId, ops, exposures, "", callers, 0, address(0), 0);

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
    )
        internal
        returns (uint64 requestId)
    {
        address[] memory operators = new address[](1);
        operators[0] = operator;
        address[] memory callers = new address[](0);

        vm.startPrank(requester);
        IERC20(token).approve(address(tangle), payment);
        requestId = tangle.requestService(blueprintId, operators, "", callers, 0, token, payment);
        vm.stopPrank();
    }
}
