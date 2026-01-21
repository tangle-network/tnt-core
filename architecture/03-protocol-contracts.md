# Protocol Contracts

Core Solidity contracts for Tangle v2.

## Contract Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              TangleCore.sol                                  │
│                         (Entry Point / Facade)                              │
└───────────┬─────────────────┬─────────────────┬─────────────────┬───────────┘
            │                 │                 │                 │
    ┌───────▼───────┐ ┌───────▼───────┐ ┌───────▼───────┐ ┌───────▼───────┐
    │  Blueprint    │ │   Service     │ │     Job       │ │    Rewards    │
    │   Registry    │ │   Manager     │ │   Manager     │ │  Distributor  │
    └───────────────┘ └───────────────┘ └───────────────┘ └───────────────┘
            │                 │                 │                 │
            └─────────────────┴─────────────────┴─────────────────┘
                                      │
                              ┌───────▼───────┐
                              │   Security    │
                              │   Manager     │
                              │  (Abstract)   │
                              └───────────────┘
```

## TangleCore.sol

Main entry point and coordinator.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import {ReentrancyGuardUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import {SafeERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {IBlueprintRegistry} from "./interfaces/IBlueprintRegistry.sol";
import {IServiceManager} from "./interfaces/IServiceManager.sol";
import {IJobManager} from "./interfaces/IJobManager.sol";
import {ISecurityManager} from "./security/ISecurityManager.sol";
import {IRewardsDistributor} from "./interfaces/IRewardsDistributor.sol";
import {IBlueprintServiceManager} from "./hooks/IBlueprintServiceManager.sol";

/// @title TangleCore
/// @notice Main entry point for Tangle Protocol
/// @dev Coordinates between modules and enforces access control
contract TangleCore is
    UUPSUpgradeable,
    AccessControlUpgradeable,
    PausableUpgradeable,
    ReentrancyGuardUpgradeable
{
    using SafeERC20 for IERC20;

    // ═══════════════════════════════════════════════════════════════════════
    // ROLES
    // ═══════════════════════════════════════════════════════════════════════

    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

    // ═══════════════════════════════════════════════════════════════════════
    // STATE
    // ═══════════════════════════════════════════════════════════════════════

    IBlueprintRegistry public blueprintRegistry;
    IServiceManager public serviceManager;
    IJobManager public jobManager;
    ISecurityManager public securityManager;
    IRewardsDistributor public rewardsDistributor;

    // Payment configuration
    PaymentConfig public paymentConfig;

    struct PaymentConfig {
        uint16 developerBps;      // Basis points to developer (e.g., 5000 = 50%)
        uint16 protocolBps;       // Basis points to protocol
        uint16 operatorBps;       // Basis points to operators
        uint16 stakerBps;         // Basis points to stakers
        address payable protocolTreasury;
    }

    // ═══════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════

    event ModuleUpdated(string indexed moduleName, address oldAddress, address newAddress);
    event PaymentConfigUpdated(PaymentConfig config);

    // ═══════════════════════════════════════════════════════════════════════
    // INITIALIZER
    // ═══════════════════════════════════════════════════════════════════════

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(
        address admin,
        address _blueprintRegistry,
        address _serviceManager,
        address _jobManager,
        address _securityManager,
        address _rewardsDistributor
    ) external initializer {
        __UUPSUpgradeable_init();
        __AccessControl_init();
        __Pausable_init();
        __ReentrancyGuard_init();

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(UPGRADER_ROLE, admin);
        _grantRole(PAUSER_ROLE, admin);

        blueprintRegistry = IBlueprintRegistry(_blueprintRegistry);
        serviceManager = IServiceManager(_serviceManager);
        jobManager = IJobManager(_jobManager);
        securityManager = ISecurityManager(_securityManager);
        rewardsDistributor = IRewardsDistributor(_rewardsDistributor);

        // Default payment split
        paymentConfig = PaymentConfig({
            developerBps: 5000,   // 50%
            protocolBps: 1000,    // 10%
            operatorBps: 2000,    // 20%
            stakerBps: 2000,      // 20%
            protocolTreasury: payable(admin)
        });
    }

    // ═══════════════════════════════════════════════════════════════════════
    // BLUEPRINT OPERATIONS
    // ═══════════════════════════════════════════════════════════════════════

    /// @notice Create a new blueprint from a full definition
    /// @param definition Fully specified Types.BlueprintDefinition payload
    function createBlueprint(Types.BlueprintDefinition calldata definition) external whenNotPaused returns (uint64 blueprintId) {
        Types.BlueprintDefinition memory def = definition;
        // ... validate + store metadata, schemas, sources, memberships
        blueprintId = _nextBlueprintId++;
        blueprints[blueprintId] = Blueprint({
            owner: msg.sender,
            manager: def.manager,
            createdAt: block.timestamp,
            active: true,
            membership: def.config.membership,
            pricing: def.config.pricing
        });

        // Notify service-specific manager
        if (def.manager != address(0)) {
            IBlueprintServiceManager(def.manager).onBlueprintCreated(blueprintId, msg.sender, address(this));
        }

        // Record the definition with the Master Blueprint Service Manager
        IMasterBlueprintServiceManager(masterManager).onBlueprintCreated(
            blueprintId,
            msg.sender,
            abi.encode(def)
        );
        _mbsmRegistry.pinBlueprint(blueprintId, resolvedRevision);
    }

    // ═══════════════════════════════════════════════════════════════════════
    // OPERATOR OPERATIONS
    // ═══════════════════════════════════════════════════════════════════════

    // Operator registration
    // ---------------------
    // - Operators must meet the staking self-stake minimum before registering.

    /// @notice Register operator to a blueprint
    /// @param blueprintId The blueprint to register for
    /// @param preferences Encoded operator preferences (RPC address, pricing, etc.)
    /// @param registrationInputs Additional registration data for the hook
    function registerOperator(
        uint64 blueprintId,
        bytes calldata preferences,
        bytes calldata registrationInputs
    ) external payable whenNotPaused {
        require(securityManager.isOperatorActive(msg.sender), "Not active operator");

        blueprintRegistry.registerOperator(blueprintId, msg.sender, preferences);

        // Call hook
        address manager = blueprintRegistry.getManager(blueprintId);
        if (manager != address(0)) {
            IBlueprintServiceManager(manager).onRegister{value: msg.value}(
                _toOperatorPreferences(msg.sender, preferences),
                registrationInputs
            );
        }
    }

    /// @notice Unregister operator from a blueprint
    function unregisterOperator(uint64 blueprintId) external whenNotPaused {
        blueprintRegistry.unregisterOperator(blueprintId, msg.sender);

        address manager = blueprintRegistry.getManager(blueprintId);
        if (manager != address(0)) {
            IBlueprintServiceManager(manager).onUnregister(
                _toOperatorPreferences(msg.sender, "")
            );
        }
    }

    // ═══════════════════════════════════════════════════════════════════════
    // SERVICE OPERATIONS
    // ═══════════════════════════════════════════════════════════════════════

    /// @notice Request a new service instance
    /// @param blueprintId The blueprint to instantiate
    /// @param operators Operators to provide the service
    /// @param config Encoded service configuration
    /// @param permittedCallers Addresses allowed to call jobs on this service
    /// @param ttl Time-to-live in seconds (0 for unlimited)
    /// @param paymentAsset Payment token (address(0) for native)
    /// @param paymentAmount Payment amount
    function requestService(
        uint64 blueprintId,
        address[] calldata operators,
        bytes calldata config,
        address[] calldata permittedCallers,
        uint64 ttl,
        address paymentAsset,
        uint256 paymentAmount
    ) external payable whenNotPaused nonReentrant returns (uint64 requestId) {
        // Validate operators
        for (uint256 i = 0; i < operators.length; i++) {
            require(
                blueprintRegistry.isOperatorRegistered(blueprintId, operators[i]),
                "Operator not registered"
            );
            require(
                securityManager.isOperatorActive(operators[i]),
                "Operator not active"
            );
        }

        // Collect payment
        _collectPayment(paymentAsset, paymentAmount);

        // Create request
        requestId = serviceManager.createRequest(
            blueprintId,
            msg.sender,
            operators,
            config,
            permittedCallers,
            ttl,
            paymentAsset,
            paymentAmount
        );

        // Call hook
        address manager = blueprintRegistry.getManager(blueprintId);
        if (manager != address(0)) {
            IBlueprintServiceManager(manager).onRequest{value: paymentAsset == address(0) ? paymentAmount : 0}(
                _toRequestParams(requestId, blueprintId, operators, config, permittedCallers, ttl, paymentAsset, paymentAmount)
            );
        }
    }

    /// @notice Approve a service request (operator)
    function approveService(uint64 requestId, uint8 stakingPercent) external whenNotPaused {
        (uint64 blueprintId, bool allApproved) = serviceManager.approve(requestId, msg.sender, stakingPercent);

        address manager = blueprintRegistry.getManager(blueprintId);
        if (manager != address(0)) {
            IBlueprintServiceManager(manager).onApprove(
                _toOperatorPreferences(msg.sender, ""),
                requestId,
                stakingPercent
            );
        }

        if (allApproved) {
            _activateService(requestId, blueprintId, manager);
        }
    }

    /// @notice Reject a service request (operator)
    function rejectService(uint64 requestId) external whenNotPaused {
        (uint64 blueprintId, address requester, address paymentAsset, uint256 paymentAmount) =
            serviceManager.reject(requestId, msg.sender);

        // Refund payment
        _refundPayment(requester, paymentAsset, paymentAmount);

        address manager = blueprintRegistry.getManager(blueprintId);
        if (manager != address(0)) {
            IBlueprintServiceManager(manager).onReject(
                _toOperatorPreferences(msg.sender, ""),
                requestId
            );
        }
    }

    function _activateService(uint64 requestId, uint64 blueprintId, address manager) internal {
        (uint64 serviceId, address owner, address[] memory operators, address[] memory permittedCallers, uint64 ttl) =
            serviceManager.activate(requestId);

        // Distribute payment
        _distributePayment(requestId, serviceId, blueprintId, manager);

        // Call hook
        if (manager != address(0)) {
            IBlueprintServiceManager(manager).onServiceInitialized(
                requestId,
                serviceId,
                owner,
                permittedCallers,
                ttl
            );
        }
    }

    /// @notice Terminate a service
    function terminateService(uint64 serviceId) external whenNotPaused {
        (uint64 blueprintId, address owner) = serviceManager.terminate(serviceId, msg.sender);

        address manager = blueprintRegistry.getManager(blueprintId);
        if (manager != address(0)) {
            IBlueprintServiceManager(manager).onServiceTermination(serviceId, owner);
        }
    }

    // ═══════════════════════════════════════════════════════════════════════
    // JOB OPERATIONS
    // ═══════════════════════════════════════════════════════════════════════

    /// @notice Submit a job call to a service
    /// @param serviceId The service to call
    /// @param jobId The job identifier within the blueprint
    /// @param inputs Encoded job inputs
    function callJob(
        uint64 serviceId,
        uint8 jobId,
        bytes calldata inputs
    ) external payable whenNotPaused returns (uint64 callId) {
        (uint64 blueprintId,) = serviceManager.getService(serviceId);
        require(serviceManager.isPermittedCaller(serviceId, msg.sender), "Not permitted");

        callId = jobManager.createCall(serviceId, jobId, msg.sender, inputs);

        address manager = blueprintRegistry.getManager(blueprintId);
        if (manager != address(0)) {
            IBlueprintServiceManager(manager).onJobCall{value: msg.value}(
                serviceId,
                jobId,
                callId,
                inputs
            );
        }
    }

    /// @notice Submit a batch of job calls
    function callJobBatch(
        uint64 serviceId,
        uint8[] calldata jobIds,
        bytes[] calldata inputs
    ) external payable whenNotPaused returns (uint64[] memory callIds) {
        require(jobIds.length == inputs.length, "Length mismatch");

        callIds = new uint64[](jobIds.length);
        for (uint256 i = 0; i < jobIds.length; i++) {
            callIds[i] = this.callJob(serviceId, jobIds[i], inputs[i]);
        }
    }

    /// @notice Submit a job result (operator)
    /// @param serviceId The service
    /// @param callId The job call being responded to
    /// @param outputs Encoded job outputs
    function submitResult(
        uint64 serviceId,
        uint64 callId,
        bytes calldata outputs
    ) external whenNotPaused {
        require(serviceManager.isServiceOperator(serviceId, msg.sender), "Not operator");

        (uint64 blueprintId,) = serviceManager.getService(serviceId);
        (uint8 jobId, bytes memory inputs) = jobManager.getCall(serviceId, callId);

        jobManager.submitResult(serviceId, callId, msg.sender, outputs);

        // Record reward
        uint256 reward = _calculateReward(serviceId, callId);
        if (reward > 0) {
            rewardsDistributor.recordReward(msg.sender, serviceId, reward);
            securityManager.notifyReward(msg.sender, serviceId, reward, address(0));
        }

        address manager = blueprintRegistry.getManager(blueprintId);
        if (manager != address(0)) {
            IBlueprintServiceManager(manager).onJobResult(
                serviceId,
                jobId,
                callId,
                _toOperatorPreferences(msg.sender, ""),
                inputs,
                outputs
            );
        }
    }

    /// @notice Submit multiple results in one transaction
    function submitResultBatch(
        uint64 serviceId,
        uint64[] calldata callIds,
        bytes[] calldata outputs
    ) external whenNotPaused {
        require(callIds.length == outputs.length, "Length mismatch");

        for (uint256 i = 0; i < callIds.length; i++) {
            this.submitResult(serviceId, callIds[i], outputs[i]);
        }
    }

    // ═══════════════════════════════════════════════════════════════════════
    // SLASHING
    // ═══════════════════════════════════════════════════════════════════════

    /// @notice Initiate a slash against an operator
    function slash(
        uint64 serviceId,
        address operator,
        uint256 amount,
        bytes32 evidence
    ) external whenNotPaused {
        (uint64 blueprintId,) = serviceManager.getService(serviceId);
        address manager = blueprintRegistry.getManager(blueprintId);

        // Verify caller is authorized slasher
        require(
            msg.sender == manager ||
            msg.sender == IBlueprintServiceManager(manager).querySlashingOrigin(serviceId),
            "Not authorized"
        );

        // Call unapplied slash hook first (dispute window)
        if (manager != address(0)) {
            IBlueprintServiceManager(manager).onUnappliedSlash(
                serviceId,
                abi.encodePacked(operator),
                uint8((amount * 100) / securityManager.getOperatorTotalStake(operator))
            );
        }

        // Execute slash through security manager
        uint256 slashed = securityManager.slash(ISecurityManager.SlashParams({
            operator: operator,
            serviceId: serviceId,
            amount: amount,
            asset: address(0),
            evidence: evidence
        }));

        if (manager != address(0)) {
            IBlueprintServiceManager(manager).onSlash(
                serviceId,
                abi.encodePacked(operator),
                uint8((slashed * 100) / amount)
            );
        }
    }

    // ═══════════════════════════════════════════════════════════════════════
    // PAYMENT HANDLING
    // ═══════════════════════════════════════════════════════════════════════

    function _collectPayment(address asset, uint256 amount) internal {
        if (asset == address(0)) {
            require(msg.value >= amount, "Insufficient native payment");
        } else {
            IERC20(asset).safeTransferFrom(msg.sender, address(this), amount);
        }
    }

    function _refundPayment(address to, address asset, uint256 amount) internal {
        if (asset == address(0)) {
            payable(to).transfer(amount);
        } else {
            IERC20(asset).safeTransfer(to, amount);
        }
    }

    function _distributePayment(
        uint64 requestId,
        uint64 serviceId,
        uint64 blueprintId,
        address manager
    ) internal {
        (address paymentAsset, uint256 amount) = serviceManager.getRequestPayment(requestId);
        if (amount == 0) return;

        PaymentConfig memory config = paymentConfig;

        // Calculate splits
        uint256 developerAmount = (amount * config.developerBps) / 10000;
        uint256 protocolAmount = (amount * config.protocolBps) / 10000;
        uint256 operatorAmount = (amount * config.operatorBps) / 10000;
        uint256 stakerAmount = amount - developerAmount - protocolAmount - operatorAmount;

        // Get developer address from hook
        address payable developerAddress = manager != address(0)
            ? IBlueprintServiceManager(manager).queryDeveloperPaymentAddress(serviceId)
            : payable(blueprintRegistry.getOwner(blueprintId));

        // Distribute
        _transferPayment(developerAddress, paymentAsset, developerAmount);
        _transferPayment(config.protocolTreasury, paymentAsset, protocolAmount);

        // Operator + Staker amounts go to rewards distributor
        _transferPayment(payable(address(rewardsDistributor)), paymentAsset, operatorAmount + stakerAmount);
        rewardsDistributor.notifyServicePayment(serviceId, operatorAmount, stakerAmount, paymentAsset);
    }

    function _transferPayment(address payable to, address asset, uint256 amount) internal {
        if (amount == 0) return;
        if (asset == address(0)) {
            to.transfer(amount);
        } else {
            IERC20(asset).safeTransfer(to, amount);
        }
    }

    function _calculateReward(uint64 serviceId, uint64 callId) internal view returns (uint256) {
        // Simplified: equal share per result
        // Real implementation would factor in job complexity, operator stake, etc.
        return 0; // Rewards come from service payment distribution
    }

    // ═══════════════════════════════════════════════════════════════════════
    // HELPERS
    // ═══════════════════════════════════════════════════════════════════════

    function _toOperatorPreferences(address operator, bytes memory prefs)
        internal
        pure
        returns (ServiceOperators.OperatorPreferences memory)
    {
        return ServiceOperators.OperatorPreferences({
            ecdsaPublicKey: abi.encodePacked(operator),
            rpcAddress: prefs.length > 0 ? string(prefs) : ""
        });
    }

    function _toRequestParams(
        uint64 requestId,
        uint64 /* blueprintId */,
        address[] calldata operators,
        bytes calldata config,
        address[] calldata permittedCallers,
        uint64 ttl,
        address paymentAsset,
        uint256 paymentAmount
    ) internal view returns (ServiceOperators.RequestParams memory) {
        ServiceOperators.OperatorPreferences[] memory opPrefs =
            new ServiceOperators.OperatorPreferences[](operators.length);

        for (uint256 i = 0; i < operators.length; i++) {
            opPrefs[i] = _toOperatorPreferences(operators[i], "");
        }

        return ServiceOperators.RequestParams({
            requestId: requestId,
            requester: msg.sender,
            operators: opPrefs,
            requestInputs: config,
            permittedCallers: permittedCallers,
            ttl: ttl,
            paymentAsset: Assets.Asset({
                kind: paymentAsset == address(0) ? Assets.Kind.Custom : Assets.Kind.Erc20,
                data: bytes32(uint256(uint160(paymentAsset)))
            }),
            amount: paymentAmount
        });
    }

    // ═══════════════════════════════════════════════════════════════════════
    // ADMIN
    // ═══════════════════════════════════════════════════════════════════════

    function setPaymentConfig(PaymentConfig calldata config) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(
            config.developerBps + config.protocolBps + config.operatorBps + config.stakerBps == 10000,
            "Must sum to 100%"
        );
        paymentConfig = config;
        emit PaymentConfigUpdated(config);
    }

    function setModule(string calldata name, address module) external onlyRole(DEFAULT_ADMIN_ROLE) {
        bytes32 nameHash = keccak256(bytes(name));

        if (nameHash == keccak256("blueprintRegistry")) {
            emit ModuleUpdated(name, address(blueprintRegistry), module);
            blueprintRegistry = IBlueprintRegistry(module);
        } else if (nameHash == keccak256("serviceManager")) {
            emit ModuleUpdated(name, address(serviceManager), module);
            serviceManager = IServiceManager(module);
        } else if (nameHash == keccak256("jobManager")) {
            emit ModuleUpdated(name, address(jobManager), module);
            jobManager = IJobManager(module);
        } else if (nameHash == keccak256("securityManager")) {
            emit ModuleUpdated(name, address(securityManager), module);
            securityManager = ISecurityManager(module);
        } else if (nameHash == keccak256("rewardsDistributor")) {
            emit ModuleUpdated(name, address(rewardsDistributor), module);
            rewardsDistributor = IRewardsDistributor(module);
        } else {
            revert("Unknown module");
        }
    }

    function pause() external onlyRole(PAUSER_ROLE) {
        _pause();
    }

    function unpause() external onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    function _authorizeUpgrade(address) internal override onlyRole(UPGRADER_ROLE) {}

    // Allow receiving native tokens
    receive() external payable {}
}
```

## BlueprintRegistry.sol

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

contract BlueprintRegistry is AccessControlUpgradeable {
    using EnumerableSet for EnumerableSet.AddressSet;

    struct Blueprint {
        address owner;
        address manager;
        string metadataURI;
        bytes32 codeHash;
        bool active;
        uint64 createdAt;
    }

    mapping(uint64 => Blueprint) public blueprints;
    mapping(uint64 => EnumerableSet.AddressSet) internal _operators;
    mapping(uint64 => mapping(address => bytes)) public operatorPreferences;

    uint64 public nextBlueprintId;

    bytes32 public constant CORE_ROLE = keccak256("CORE_ROLE");

    event BlueprintCreated(uint64 indexed blueprintId, address indexed owner, address manager, bytes32 codeHash);
    event BlueprintUpdated(uint64 indexed blueprintId, string metadataURI);
    event OperatorRegistered(uint64 indexed blueprintId, address indexed operator);
    event OperatorUnregistered(uint64 indexed blueprintId, address indexed operator);

    function initialize(address core) external initializer {
        __AccessControl_init();
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(CORE_ROLE, core);
    }

    function create(
        address owner,
        string calldata metadataURI,
        address manager,
        bytes32 codeHash
    ) external onlyRole(CORE_ROLE) returns (uint64 blueprintId) {
        blueprintId = nextBlueprintId++;

        blueprints[blueprintId] = Blueprint({
            owner: owner,
            manager: manager,
            metadataURI: metadataURI,
            codeHash: codeHash,
            active: true,
            createdAt: uint64(block.timestamp)
        });

        emit BlueprintCreated(blueprintId, owner, manager, codeHash);
    }

    function registerOperator(
        uint64 blueprintId,
        address operator,
        bytes calldata preferences
    ) external onlyRole(CORE_ROLE) {
        require(blueprints[blueprintId].active, "Blueprint not active");

        _operators[blueprintId].add(operator);
        operatorPreferences[blueprintId][operator] = preferences;

        emit OperatorRegistered(blueprintId, operator);
    }

    function unregisterOperator(uint64 blueprintId, address operator) external onlyRole(CORE_ROLE) {
        _operators[blueprintId].remove(operator);
        delete operatorPreferences[blueprintId][operator];

        emit OperatorUnregistered(blueprintId, operator);
    }

    // Queries
    function getManager(uint64 blueprintId) external view returns (address) {
        return blueprints[blueprintId].manager;
    }

    function getOwner(uint64 blueprintId) external view returns (address) {
        return blueprints[blueprintId].owner;
    }

    function isOperatorRegistered(uint64 blueprintId, address operator) external view returns (bool) {
        return _operators[blueprintId].contains(operator);
    }

    function getOperators(uint64 blueprintId) external view returns (address[] memory) {
        return _operators[blueprintId].values();
    }

    function getOperatorCount(uint64 blueprintId) external view returns (uint256) {
        return _operators[blueprintId].length();
    }
}
```

## ServiceManager.sol

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract ServiceManager {
    using EnumerableSet for EnumerableSet.AddressSet;

    enum RequestStatus { Pending, Approved, Rejected, Activated }
    enum ServiceStatus { Active, Terminated }

    struct ServiceRequest {
        uint64 blueprintId;
        address requester;
        address[] operators;
        bytes config;
        address[] permittedCallers;
        uint64 ttl;
        address paymentAsset;
        uint256 paymentAmount;
        RequestStatus status;
        uint256 approvalCount;
        uint64 createdAt;
    }

    struct Service {
        uint64 blueprintId;
        uint64 requestId;
        address owner;
        uint64 createdAt;
        uint64 ttl;
        ServiceStatus status;
    }

    mapping(uint64 => ServiceRequest) public requests;
    mapping(uint64 => mapping(address => bool)) public approvals;
    mapping(uint64 => Service) public services;
    mapping(uint64 => EnumerableSet.AddressSet) internal _serviceOperators;
    mapping(uint64 => EnumerableSet.AddressSet) internal _serviceCallers;

    uint64 public nextRequestId;
    uint64 public nextServiceId;

    bytes32 public constant CORE_ROLE = keccak256("CORE_ROLE");

    event ServiceRequested(uint64 indexed requestId, uint64 indexed blueprintId, address requester);
    event ServiceApproved(uint64 indexed requestId, address indexed operator);
    event ServiceRejected(uint64 indexed requestId, address indexed operator);
    event ServiceActivated(uint64 indexed serviceId, uint64 indexed requestId);
    event ServiceTerminated(uint64 indexed serviceId);

    function createRequest(
        uint64 blueprintId,
        address requester,
        address[] calldata operators,
        bytes calldata config,
        address[] calldata permittedCallers,
        uint64 ttl,
        address paymentAsset,
        uint256 paymentAmount
    ) external returns (uint64 requestId) {
        requestId = nextRequestId++;

        requests[requestId] = ServiceRequest({
            blueprintId: blueprintId,
            requester: requester,
            operators: operators,
            config: config,
            permittedCallers: permittedCallers,
            ttl: ttl,
            paymentAsset: paymentAsset,
            paymentAmount: paymentAmount,
            status: RequestStatus.Pending,
            approvalCount: 0,
            createdAt: uint64(block.timestamp)
        });

        emit ServiceRequested(requestId, blueprintId, requester);
    }

    function approve(uint64 requestId, address operator, uint8 /* stakingPercent */)
        external
        returns (uint64 blueprintId, bool allApproved)
    {
        ServiceRequest storage req = requests[requestId];
        require(req.status == RequestStatus.Pending, "Not pending");
        require(_isRequestOperator(requestId, operator), "Not operator");
        require(!approvals[requestId][operator], "Already approved");

        approvals[requestId][operator] = true;
        req.approvalCount++;

        allApproved = req.approvalCount == req.operators.length;
        if (allApproved) {
            req.status = RequestStatus.Approved;
        }

        emit ServiceApproved(requestId, operator);
        return (req.blueprintId, allApproved);
    }

    function reject(uint64 requestId, address operator)
        external
        returns (uint64 blueprintId, address requester, address paymentAsset, uint256 paymentAmount)
    {
        ServiceRequest storage req = requests[requestId];
        require(req.status == RequestStatus.Pending, "Not pending");
        require(_isRequestOperator(requestId, operator), "Not operator");

        req.status = RequestStatus.Rejected;

        emit ServiceRejected(requestId, operator);
        return (req.blueprintId, req.requester, req.paymentAsset, req.paymentAmount);
    }

    function activate(uint64 requestId)
        external
        returns (uint64 serviceId, address owner, address[] memory operators, address[] memory permittedCallers, uint64 ttl)
    {
        ServiceRequest storage req = requests[requestId];
        require(req.status == RequestStatus.Approved, "Not approved");

        req.status = RequestStatus.Activated;
        serviceId = nextServiceId++;

        services[serviceId] = Service({
            blueprintId: req.blueprintId,
            requestId: requestId,
            owner: req.requester,
            createdAt: uint64(block.timestamp),
            ttl: req.ttl,
            status: ServiceStatus.Active
        });

        // Add operators
        for (uint256 i = 0; i < req.operators.length; i++) {
            _serviceOperators[serviceId].add(req.operators[i]);
        }

        // Add permitted callers
        for (uint256 i = 0; i < req.permittedCallers.length; i++) {
            _serviceCallers[serviceId].add(req.permittedCallers[i]);
        }

        emit ServiceActivated(serviceId, requestId);
        return (serviceId, req.requester, req.operators, req.permittedCallers, req.ttl);
    }

    function terminate(uint64 serviceId, address caller)
        external
        returns (uint64 blueprintId, address owner)
    {
        Service storage svc = services[serviceId];
        require(svc.status == ServiceStatus.Active, "Not active");
        require(caller == svc.owner, "Not owner");

        svc.status = ServiceStatus.Terminated;

        emit ServiceTerminated(serviceId);
        return (svc.blueprintId, svc.owner);
    }

    // Queries
    function getService(uint64 serviceId) external view returns (uint64 blueprintId, address owner) {
        Service storage svc = services[serviceId];
        return (svc.blueprintId, svc.owner);
    }

    function getRequestPayment(uint64 requestId) external view returns (address asset, uint256 amount) {
        ServiceRequest storage req = requests[requestId];
        return (req.paymentAsset, req.paymentAmount);
    }

    function isServiceOperator(uint64 serviceId, address operator) external view returns (bool) {
        return _serviceOperators[serviceId].contains(operator);
    }

    function isPermittedCaller(uint64 serviceId, address caller) external view returns (bool) {
        return _serviceCallers[serviceId].contains(caller) || caller == services[serviceId].owner;
    }

    function _isRequestOperator(uint64 requestId, address operator) internal view returns (bool) {
        address[] storage ops = requests[requestId].operators;
        for (uint256 i = 0; i < ops.length; i++) {
            if (ops[i] == operator) return true;
        }
        return false;
    }
}
```

## JobManager.sol

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract JobManager {
    struct JobCall {
        uint8 jobId;
        address caller;
        bytes inputs;
        uint64 timestamp;
        bool hasResult;
        address resultSubmitter;
        bytes result;
    }

    mapping(uint64 => mapping(uint64 => JobCall)) public jobCalls;
    mapping(uint64 => uint64) public serviceCallCount;

    event JobCalled(uint64 indexed serviceId, uint8 indexed jobId, uint64 callId, address caller, bytes32 inputsHash);
    event ResultSubmitted(uint64 indexed serviceId, uint64 indexed callId, address operator, bytes32 outputsHash);

    function createCall(
        uint64 serviceId,
        uint8 jobId,
        address caller,
        bytes calldata inputs
    ) external returns (uint64 callId) {
        callId = serviceCallCount[serviceId]++;

        jobCalls[serviceId][callId] = JobCall({
            jobId: jobId,
            caller: caller,
            inputs: inputs,
            timestamp: uint64(block.timestamp),
            hasResult: false,
            resultSubmitter: address(0),
            result: ""
        });

        emit JobCalled(serviceId, jobId, callId, caller, keccak256(inputs));
    }

    function submitResult(
        uint64 serviceId,
        uint64 callId,
        address operator,
        bytes calldata outputs
    ) external {
        JobCall storage call = jobCalls[serviceId][callId];
        require(!call.hasResult, "Result already submitted");

        call.hasResult = true;
        call.resultSubmitter = operator;
        call.result = outputs;

        emit ResultSubmitted(serviceId, callId, operator, keccak256(outputs));
    }

    function getCall(uint64 serviceId, uint64 callId)
        external
        view
        returns (uint8 jobId, bytes memory inputs)
    {
        JobCall storage call = jobCalls[serviceId][callId];
        return (call.jobId, call.inputs);
    }

    function hasResult(uint64 serviceId, uint64 callId) external view returns (bool) {
        return jobCalls[serviceId][callId].hasResult;
    }
}
```

## RewardsDistributor.sol

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {SafeERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/// @title RewardsDistributor
/// @notice Masterchef-style rewards distribution for operators and delegators
contract RewardsDistributor {
    using SafeERC20 for IERC20;

    struct OperatorPool {
        uint256 accumulatedPerShare;  // Scaled by 1e18
        uint256 totalDelegated;
        uint64 lastUpdateBlock;
    }

    struct DelegatorDebt {
        uint256 lastAccumulatedPerShare;
        uint256 delegatedAmount;
    }

    // Operator commission rewards (direct claim)
    mapping(address => mapping(address => uint256)) public pendingOperatorRewards; // operator => asset => amount

    // Delegator pool rewards
    mapping(address => OperatorPool) public operatorPools;
    mapping(address => mapping(address => DelegatorDebt)) public delegatorDebts; // delegator => operator => debt

    // Configuration
    uint256 public operatorCommissionBps = 1000; // 10%
    uint256 public constant PRECISION = 1e18;

    address public core;
    address public securityManager;

    event RewardRecorded(address indexed operator, uint64 indexed serviceId, uint256 operatorShare, uint256 delegatorShare);
    event OperatorRewardsClaimed(address indexed operator, address asset, uint256 amount);
    event DelegatorRewardsClaimed(address indexed delegator, address indexed operator, uint256 amount);
    event ServicePaymentReceived(uint64 indexed serviceId, uint256 operatorAmount, uint256 stakerAmount);

    modifier onlyCore() {
        require(msg.sender == core, "Only core");
        _;
    }

    function initialize(address _core, address _securityManager) external {
        require(core == address(0), "Already initialized");
        core = _core;
        securityManager = _securityManager;
    }

    /// @notice Record a reward for an operator (called after job result)
    function recordReward(address operator, uint64 serviceId, uint256 amount) external onlyCore {
        if (amount == 0) return;

        // Split between operator commission and delegator pool
        uint256 operatorShare = (amount * operatorCommissionBps) / 10000;
        uint256 delegatorShare = amount - operatorShare;

        // Operator commission - direct claim
        pendingOperatorRewards[operator][address(0)] += operatorShare;

        // Delegator pool - accumulate per share
        OperatorPool storage pool = operatorPools[operator];
        if (pool.totalDelegated > 0) {
            pool.accumulatedPerShare += (delegatorShare * PRECISION) / pool.totalDelegated;
        }
        pool.lastUpdateBlock = uint64(block.number);

        emit RewardRecorded(operator, serviceId, operatorShare, delegatorShare);
    }

    /// @notice Called when service payment is distributed
    function notifyServicePayment(
        uint64 serviceId,
        uint256 operatorAmount,
        uint256 stakerAmount,
        address asset
    ) external onlyCore {
        // This amount is for distribution to all service operators and their delegators
        // Implementation would distribute based on service operator set
        emit ServicePaymentReceived(serviceId, operatorAmount, stakerAmount);
    }

    /// @notice Operator claims their commission rewards
    function claimOperatorRewards(address asset) external {
        uint256 pending = pendingOperatorRewards[msg.sender][asset];
        require(pending > 0, "No rewards");

        pendingOperatorRewards[msg.sender][asset] = 0;

        if (asset == address(0)) {
            payable(msg.sender).transfer(pending);
        } else {
            IERC20(asset).safeTransfer(msg.sender, pending);
        }

        emit OperatorRewardsClaimed(msg.sender, asset, pending);
    }

    /// @notice Delegator claims their pool rewards from an operator
    function claimDelegatorRewards(address operator) external {
        OperatorPool storage pool = operatorPools[operator];
        DelegatorDebt storage debt = delegatorDebts[msg.sender][operator];

        uint256 pending = (debt.delegatedAmount * (pool.accumulatedPerShare - debt.lastAccumulatedPerShare)) / PRECISION;
        require(pending > 0, "No rewards");

        debt.lastAccumulatedPerShare = pool.accumulatedPerShare;

        payable(msg.sender).transfer(pending);

        emit DelegatorRewardsClaimed(msg.sender, operator, pending);
    }

    /// @notice Update delegator debt when delegation changes (called by security manager)
    function updateDelegation(address delegator, address operator, uint256 newAmount) external {
        require(msg.sender == securityManager, "Only security manager");

        OperatorPool storage pool = operatorPools[operator];
        DelegatorDebt storage debt = delegatorDebts[delegator][operator];

        // Harvest pending rewards first
        if (debt.delegatedAmount > 0 && pool.accumulatedPerShare > debt.lastAccumulatedPerShare) {
            uint256 pending = (debt.delegatedAmount * (pool.accumulatedPerShare - debt.lastAccumulatedPerShare)) / PRECISION;
            if (pending > 0) {
                payable(delegator).transfer(pending);
                emit DelegatorRewardsClaimed(delegator, operator, pending);
            }
        }

        // Update pool totals
        pool.totalDelegated = pool.totalDelegated - debt.delegatedAmount + newAmount;

        // Update debt
        debt.delegatedAmount = newAmount;
        debt.lastAccumulatedPerShare = pool.accumulatedPerShare;
    }

    /// @notice View pending rewards for operator
    function pendingOperatorReward(address operator, address asset) external view returns (uint256) {
        return pendingOperatorRewards[operator][asset];
    }

    /// @notice View pending rewards for delegator
    function pendingDelegatorReward(address delegator, address operator) external view returns (uint256) {
        OperatorPool storage pool = operatorPools[operator];
        DelegatorDebt storage debt = delegatorDebts[delegator][operator];

        return (debt.delegatedAmount * (pool.accumulatedPerShare - debt.lastAccumulatedPerShare)) / PRECISION;
    }

    receive() external payable {}
}
```

## Foundry Configuration

```toml
# foundry.toml
[profile.default]
src = "src"
out = "out"
libs = ["lib"]
solc = "0.8.24"
optimizer = true
optimizer_runs = 200
via_ir = true
evm_version = "cancun"

# Testing
fuzz = { runs = 1000 }
invariant = { runs = 256, depth = 128 }

# Gas reporting
gas_reports = ["*"]

[profile.default.fmt]
line_length = 120
tab_width = 4
bracket_spacing = false
int_types = "long"
multiline_func_header = "all"
quote_style = "double"
number_underscore = "thousands"

[rpc_endpoints]
arbitrum = "${ARBITRUM_RPC_URL}"
base = "${BASE_RPC_URL}"

[etherscan]
arbitrum = { key = "${ARBISCAN_API_KEY}" }
base = { key = "${BASESCAN_API_KEY}" }
```
