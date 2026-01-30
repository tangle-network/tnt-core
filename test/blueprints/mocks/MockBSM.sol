// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BlueprintServiceManagerBase } from "../../../src/BlueprintServiceManagerBase.sol";

/// @title MockBSM_V1
/// @notice Version 1 - Basic BSM with hook tracking for testing
/// @dev Tracks all hook calls for verification
contract MockBSM_V1 is BlueprintServiceManagerBase {
    // ═══════════════════════════════════════════════════════════════════════════
    // HOOK TRACKING
    // ═══════════════════════════════════════════════════════════════════════════

    struct HookCalls {
        uint256 onBlueprintCreated;
        uint256 onRegister;
        uint256 onUnregister;
        uint256 onUpdatePreferences;
        uint256 onRequest;
        uint256 onApprove;
        uint256 onReject;
        uint256 onServiceInitialized;
        uint256 onServiceTermination;
        uint256 onJobCall;
        uint256 onJobResult;
        uint256 onUnappliedSlash;
        uint256 onSlash;
        uint256 onOperatorJoined;
        uint256 onOperatorLeft;
    }

    HookCalls public hookCalls;

    // Detailed tracking
    address[] public registeredOperators;
    uint64[] public initializedServices;
    mapping(address => bytes) public operatorRegistrationInputs;
    mapping(uint64 => bytes) public serviceRequestInputs;
    mapping(uint64 => uint256) public jobCallCounts;
    mapping(uint64 => mapping(uint64 => bytes)) public jobInputs;
    mapping(uint64 => mapping(uint64 => bytes)) public jobOutputs;

    // ═══════════════════════════════════════════════════════════════════════════
    // VERSION INFO
    // ═══════════════════════════════════════════════════════════════════════════

    function version() external pure virtual returns (uint256) {
        return 1;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // BLUEPRINT LIFECYCLE
    // ═══════════════════════════════════════════════════════════════════════════

    function onBlueprintCreated(uint64 _blueprintId, address owner, address _tangleCore) external virtual override {
        blueprintId = _blueprintId;
        blueprintOwner = owner;
        tangleCore = _tangleCore;
        hookCalls.onBlueprintCreated++;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // OPERATOR LIFECYCLE
    // ═══════════════════════════════════════════════════════════════════════════

    function onRegister(address operator, bytes calldata inputs) external payable virtual override onlyFromTangle {
        hookCalls.onRegister++;
        registeredOperators.push(operator);
        operatorRegistrationInputs[operator] = inputs;
    }

    function onUnregister(address) external virtual override onlyFromTangle {
        hookCalls.onUnregister++;
    }

    function onUpdatePreferences(address, bytes calldata) external payable virtual override onlyFromTangle {
        hookCalls.onUpdatePreferences++;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SERVICE LIFECYCLE
    // ═══════════════════════════════════════════════════════════════════════════

    function onRequest(
        uint64 requestId,
        address,
        address[] calldata,
        bytes calldata requestInputs,
        uint64,
        address,
        uint256
    ) external payable virtual override onlyFromTangle {
        hookCalls.onRequest++;
        serviceRequestInputs[requestId] = requestInputs;
    }

    function onApprove(address, uint64, uint8) external payable virtual override onlyFromTangle {
        hookCalls.onApprove++;
    }

    function onReject(address, uint64) external virtual override onlyFromTangle {
        hookCalls.onReject++;
    }

    function onServiceInitialized(
        uint64,
        uint64,
        uint64 serviceId,
        address,
        address[] calldata,
        uint64
    ) external virtual override onlyFromTangle {
        hookCalls.onServiceInitialized++;
        initializedServices.push(serviceId);
    }

    function onServiceTermination(uint64, address) external virtual override onlyFromTangle {
        hookCalls.onServiceTermination++;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // DYNAMIC MEMBERSHIP
    // ═══════════════════════════════════════════════════════════════════════════

    function onOperatorJoined(uint64, address, uint16) external virtual override onlyFromTangle {
        hookCalls.onOperatorJoined++;
    }

    function onOperatorLeft(uint64, address) external virtual override onlyFromTangle {
        hookCalls.onOperatorLeft++;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // JOB LIFECYCLE
    // ═══════════════════════════════════════════════════════════════════════════

    function onJobCall(uint64 serviceId, uint8, uint64 jobCallId, bytes calldata inputs)
        external
        payable
        virtual
        override
        onlyFromTangle
    {
        hookCalls.onJobCall++;
        jobCallCounts[serviceId]++;
        jobInputs[serviceId][jobCallId] = inputs;
    }

    function onJobResult(
        uint64 serviceId,
        uint8,
        uint64 jobCallId,
        address,
        bytes calldata,
        bytes calldata outputs
    ) external payable virtual override onlyFromTangle {
        hookCalls.onJobResult++;
        jobOutputs[serviceId][jobCallId] = outputs;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SLASHING
    // ═══════════════════════════════════════════════════════════════════════════

    function onUnappliedSlash(uint64, bytes calldata, uint8) external virtual override onlyFromTangle {
        hookCalls.onUnappliedSlash++;
    }

    function onSlash(uint64, bytes calldata, uint8) external virtual override onlyFromTangle {
        hookCalls.onSlash++;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // VIEW HELPERS
    // ═══════════════════════════════════════════════════════════════════════════

    function getRegisteredOperatorCount() external view returns (uint256) {
        return registeredOperators.length;
    }

    function getInitializedServiceCount() external view returns (uint256) {
        return initializedServices.length;
    }

    function getHookCalls() external view returns (HookCalls memory) {
        return hookCalls;
    }

    /// @notice Allow immediate exits for testing (no commitment/queue durations)
    function getExitConfig(uint64) external pure virtual override returns (
        bool useDefault,
        uint64 minCommitmentDuration,
        uint64 exitQueueDuration,
        bool forceExitAllowed
    ) {
        return (false, 0, 0, false);
    }
}

/// @title MockBSM_V2
/// @notice Version 2 - BSM with validation and custom configs
/// @dev Adds operator allowlist and custom service config
contract MockBSM_V2 is MockBSM_V1 {
    // ═══════════════════════════════════════════════════════════════════════════
    // V2 SPECIFIC STATE
    // ═══════════════════════════════════════════════════════════════════════════

    error OperatorNotAllowed(address operator);
    error InsufficientPayment(uint256 required, uint256 provided);
    error InvalidJobIndex(uint8 job);

    mapping(address => bool) public allowedOperators;
    bool public operatorAllowlistEnabled;
    uint256 public minimumPayment;
    uint8 public maxJobIndex;

    // Custom service configs
    mapping(uint64 => uint64) public customHeartbeatIntervals;
    mapping(uint64 => uint64) public customSlashingWindows;

    function version() external pure virtual override returns (uint256) {
        return 2;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // V2 CONFIGURATION
    // ═══════════════════════════════════════════════════════════════════════════

    function setOperatorAllowlistEnabled(bool enabled) external {
        operatorAllowlistEnabled = enabled;
    }

    function setAllowedOperator(address operator, bool allowed) external {
        allowedOperators[operator] = allowed;
    }

    function setMinimumPayment(uint256 amount) external {
        minimumPayment = amount;
    }

    function setMaxJobIndex(uint8 maxIndex) external {
        maxJobIndex = maxIndex;
    }

    function setCustomHeartbeatInterval(uint64 serviceId, uint64 interval) external {
        customHeartbeatIntervals[serviceId] = interval;
    }

    function setCustomSlashingWindow(uint64 serviceId, uint64 window) external {
        customSlashingWindows[serviceId] = window;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // V2 OVERRIDES WITH VALIDATION
    // ═══════════════════════════════════════════════════════════════════════════

    function onRegister(address operator, bytes calldata inputs) external payable override onlyFromTangle {
        if (operatorAllowlistEnabled && !allowedOperators[operator]) {
            revert OperatorNotAllowed(operator);
        }
        hookCalls.onRegister++;
        registeredOperators.push(operator);
        operatorRegistrationInputs[operator] = inputs;
    }

    function onRequest(
        uint64 requestId,
        address,
        address[] calldata,
        bytes calldata requestInputs,
        uint64,
        address,
        uint256 paymentAmount
    ) external payable override onlyFromTangle {
        if (minimumPayment > 0 && paymentAmount < minimumPayment) {
            revert InsufficientPayment(minimumPayment, paymentAmount);
        }
        hookCalls.onRequest++;
        serviceRequestInputs[requestId] = requestInputs;
    }

    function onJobCall(uint64 serviceId, uint8 job, uint64 jobCallId, bytes calldata inputs)
        external
        payable
        virtual
        override
        onlyFromTangle
    {
        if (maxJobIndex > 0 && job > maxJobIndex) {
            revert InvalidJobIndex(job);
        }
        hookCalls.onJobCall++;
        jobCallCounts[serviceId]++;
        jobInputs[serviceId][jobCallId] = inputs;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // V2 CUSTOM CONFIGS
    // ═══════════════════════════════════════════════════════════════════════════

    function getHeartbeatInterval(uint64 serviceId)
        external
        view
        override
        returns (bool useDefault, uint64 interval)
    {
        if (customHeartbeatIntervals[serviceId] > 0) {
            return (false, customHeartbeatIntervals[serviceId]);
        }
        return (true, 0);
    }

    function getSlashingWindow(uint64 serviceId) external view override returns (bool useDefault, uint64 window) {
        if (customSlashingWindows[serviceId] > 0) {
            return (false, customSlashingWindows[serviceId]);
        }
        return (true, 0);
    }
}

/// @title MockBSM_V3
/// @notice Version 3 - Most advanced BSM with strict requirements
/// @dev Adds quorum requirements, custom slashing origin, payment routing
contract MockBSM_V3 is MockBSM_V2 {
    // ═══════════════════════════════════════════════════════════════════════════
    // V3 SPECIFIC STATE
    // ═══════════════════════════════════════════════════════════════════════════

    error ServiceNotActive(uint64 serviceId);
    error OperatorCannotLeave(address operator);

    // Custom authorities
    mapping(uint64 => address) public customSlashingOrigins;
    mapping(uint64 => address) public customDisputeOrigins;
    mapping(uint64 => address payable) public customDeveloperAddresses;

    // Membership controls
    mapping(uint64 => mapping(address => bool)) public blockedFromJoining;
    mapping(uint64 => mapping(address => bool)) public blockedFromLeaving;

    // Job result requirements
    mapping(uint64 => mapping(uint8 => uint32)) public customResultCounts;

    // Service state tracking
    mapping(uint64 => bool) public serviceActive;

    function version() external pure override returns (uint256) {
        return 3;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // V3 CONFIGURATION
    // ═══════════════════════════════════════════════════════════════════════════

    function setCustomSlashingOrigin(uint64 serviceId, address origin) external {
        customSlashingOrigins[serviceId] = origin;
    }

    function setCustomDisputeOrigin(uint64 serviceId, address origin) external {
        customDisputeOrigins[serviceId] = origin;
    }

    function setCustomDeveloperAddress(uint64 serviceId, address payable addr) external {
        customDeveloperAddresses[serviceId] = addr;
    }

    function setBlockedFromJoining(uint64 serviceId, address operator, bool blocked) external {
        blockedFromJoining[serviceId][operator] = blocked;
    }

    function setBlockedFromLeaving(uint64 serviceId, address operator, bool blocked) external {
        blockedFromLeaving[serviceId][operator] = blocked;
    }

    function setCustomResultCount(uint64 serviceId, uint8 jobIndex, uint32 count) external {
        customResultCounts[serviceId][jobIndex] = count;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // V3 OVERRIDES
    // ═══════════════════════════════════════════════════════════════════════════

    function onServiceInitialized(
        uint64,
        uint64,
        uint64 serviceId,
        address,
        address[] calldata,
        uint64
    ) external override onlyFromTangle {
        hookCalls.onServiceInitialized++;
        initializedServices.push(serviceId);
        serviceActive[serviceId] = true;
    }

    function onServiceTermination(uint64 serviceId, address) external override onlyFromTangle {
        hookCalls.onServiceTermination++;
        serviceActive[serviceId] = false;
    }

    function onJobCall(uint64 serviceId, uint8 job, uint64 jobCallId, bytes calldata inputs)
        external
        payable
        override
        onlyFromTangle
    {
        if (!serviceActive[serviceId]) {
            revert ServiceNotActive(serviceId);
        }
        if (maxJobIndex > 0 && job > maxJobIndex) {
            revert InvalidJobIndex(job);
        }
        hookCalls.onJobCall++;
        jobCallCounts[serviceId]++;
        jobInputs[serviceId][jobCallId] = inputs;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // V3 MEMBERSHIP CONTROLS
    // ═══════════════════════════════════════════════════════════════════════════

    function canJoin(uint64 serviceId, address operator) external view override returns (bool) {
        return !blockedFromJoining[serviceId][operator];
    }

    function canLeave(uint64 serviceId, address operator) external view override returns (bool) {
        return !blockedFromLeaving[serviceId][operator];
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // V3 AUTHORIZATION QUERIES
    // ═══════════════════════════════════════════════════════════════════════════

    function querySlashingOrigin(uint64 serviceId) external view override returns (address) {
        if (customSlashingOrigins[serviceId] != address(0)) {
            return customSlashingOrigins[serviceId];
        }
        return address(this);
    }

    function queryDisputeOrigin(uint64 serviceId) external view override returns (address) {
        if (customDisputeOrigins[serviceId] != address(0)) {
            return customDisputeOrigins[serviceId];
        }
        return address(this);
    }

    function queryDeveloperPaymentAddress(uint64 serviceId) external view override returns (address payable) {
        if (customDeveloperAddresses[serviceId] != address(0)) {
            return customDeveloperAddresses[serviceId];
        }
        return payable(blueprintOwner);
    }

    function getRequiredResultCount(uint64 serviceId, uint8 jobIndex) external view override returns (uint32) {
        if (customResultCounts[serviceId][jobIndex] > 0) {
            return customResultCounts[serviceId][jobIndex];
        }
        return 1;
    }
}
