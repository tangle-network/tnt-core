// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { PausableUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import { ReentrancyGuardUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import { AccessControlUpgradeable } from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import { TangleStorage } from "../TangleStorage.sol";
import { Types } from "../libraries/Types.sol";
import { Errors } from "../libraries/Errors.sol";
import { SignatureLib } from "../libraries/SignatureLib.sol";
import { SlashingLib } from "../libraries/SlashingLib.sol";
import { IRestaking } from "../interfaces/IRestaking.sol";
import { IBlueprintServiceManager } from "../interfaces/IBlueprintServiceManager.sol";
import { IMetricsRecorder } from "../interfaces/IMetricsRecorder.sol";
import { IOperatorStatusRegistry } from "../restaking/OperatorStatusRegistry.sol";

/// @title Base
/// @notice Base contract for Tangle Protocol with initialization, access control, and helpers
/// @dev All mixin contracts inherit from this
abstract contract Base is
    Initializable,
    UUPSUpgradeable,
    PausableUpgradeable,
    ReentrancyGuardUpgradeable,
    AccessControlUpgradeable,
    TangleStorage
{
    using EnumerableSet for EnumerableSet.AddressSet;

    // ═══════════════════════════════════════════════════════════════════════════
    // ROLES
    // ═══════════════════════════════════════════════════════════════════════════

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    bytes32 public constant SLASH_ADMIN_ROLE = keccak256("SLASH_ADMIN_ROLE");

    // ═══════════════════════════════════════════════════════════════════════════
    // SHARED EVENTS (defined once, used across mixins)
    // ═══════════════════════════════════════════════════════════════════════════

    event ServiceActivated(uint64 indexed serviceId, uint64 indexed requestId, uint64 indexed blueprintId);

    // ═══════════════════════════════════════════════════════════════════════════
    // INITIALIZATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /// @notice Initialize the contract
    /// @param admin Admin address
    /// @param restaking_ Restaking module address
    /// @param treasury_ Protocol treasury address
    // forge-lint: disable-next-line(mixed-case-function)
    function __Base_init(
        address admin,
        address restaking_,
        address payable treasury_
    ) internal onlyInitializing {
        if (admin == address(0) || restaking_ == address(0) || treasury_ == address(0)) {
            revert Errors.ZeroAddress();
        }

        __UUPSUpgradeable_init();
        __Pausable_init();
        __ReentrancyGuard_init();
        __AccessControl_init();

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ADMIN_ROLE, admin);
        _grantRole(PAUSER_ROLE, admin);
        _grantRole(UPGRADER_ROLE, admin);
        _grantRole(SLASH_ADMIN_ROLE, admin);

        _restaking = IRestaking(restaking_);
        _treasury = treasury_;

        // Initialize payment split
        _paymentSplit = Types.PaymentSplit({
            developerBps: DEFAULT_DEVELOPER_BPS,
            protocolBps: DEFAULT_PROTOCOL_BPS,
            operatorBps: DEFAULT_OPERATOR_BPS,
            restakerBps: DEFAULT_RESTAKER_BPS
        });

        // Initialize EIP-712 domain separator
        _domainSeparator = SignatureLib.computeDomainSeparator(
            "TangleQuote",
            "1",
            address(this)
        );

        // Initialize slashing config
        SlashingLib.initializeConfig(_slashState);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // ADMIN
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Pause the contract
    function pause() external onlyRole(PAUSER_ROLE) {
        _pause();
    }

    /// @notice Unpause the contract
    function unpause() external onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    /// @notice Required for UUPS upgrades
    function _authorizeUpgrade(address) internal override onlyRole(UPGRADER_ROLE) {}

    /// @notice Set the metrics recorder for incentive tracking
    /// @param recorder The metrics recorder address (set to address(0) to disable)
    function setMetricsRecorder(address recorder) external onlyRole(ADMIN_ROLE) {
        _metricsRecorder = recorder;
    }

    /// @notice Get the metrics recorder address
    function metricsRecorder() external view returns (address) {
        return _metricsRecorder;
    }

    /// @notice Set the operator status registry for heartbeat tracking
    /// @param registry The operator status registry address (set to address(0) to disable)
    function setOperatorStatusRegistry(address registry) external onlyRole(ADMIN_ROLE) {
        _operatorStatusRegistry = registry;
    }

    /// @notice Get the operator status registry address
    function operatorStatusRegistry() external view returns (address) {
        return _operatorStatusRegistry;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // METRICS HOOKS (lightweight, fail-safe)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Record a service creation event
    function _recordServiceCreated(uint64 serviceId, uint64 blueprintId, address owner, uint256 operatorCount) internal {
        if (_metricsRecorder != address(0)) {
            try IMetricsRecorder(_metricsRecorder).recordServiceCreated(serviceId, blueprintId, owner, operatorCount) {} catch {}
        }
    }

    /// @notice Record a job call event
    function _recordJobCall(uint64 serviceId, address caller, uint64 jobCallId) internal {
        if (_metricsRecorder != address(0)) {
            try IMetricsRecorder(_metricsRecorder).recordJobCall(serviceId, caller, jobCallId) {} catch {}
        }
    }

    /// @notice Record a job completion event
    function _recordJobCompletion(address operator, uint64 serviceId, uint64 jobCallId, bool success) internal {
        if (_metricsRecorder != address(0)) {
            try IMetricsRecorder(_metricsRecorder).recordJobCompletion(operator, serviceId, jobCallId, success) {} catch {}
        }
    }

    /// @notice Record a payment event
    function _recordPayment(address payer, uint64 serviceId, address token, uint256 amount) internal {
        if (_metricsRecorder != address(0)) {
            try IMetricsRecorder(_metricsRecorder).recordPayment(payer, serviceId, token, amount) {} catch {}
        }
    }

    /// @notice Record a blueprint creation event
    function _recordBlueprintCreated(uint64 blueprintId, address developer) internal {
        if (_metricsRecorder != address(0)) {
            try IMetricsRecorder(_metricsRecorder).recordBlueprintCreated(blueprintId, developer) {} catch {}
        }
    }

    /// @notice Record a blueprint registration event
    function _recordBlueprintRegistration(uint64 blueprintId, address operator) internal {
        if (_metricsRecorder != address(0)) {
            try IMetricsRecorder(_metricsRecorder).recordBlueprintRegistration(blueprintId, operator) {} catch {}
        }
    }

    /// @notice Record a slash event
    function _recordSlash(address operator, uint64 serviceId, uint256 amount) internal {
        if (_metricsRecorder != address(0)) {
            try IMetricsRecorder(_metricsRecorder).recordSlash(operator, serviceId, amount) {} catch {}
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // HEARTBEAT HOOKS (lightweight, fail-safe)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Configure heartbeat settings for a service from BSM hooks
    /// @dev Called during service activation to set up liveness tracking
    /// @param serviceId The service ID
    /// @param manager The blueprint's service manager address
    /// @param owner The service owner address
    function _configureHeartbeat(uint64 serviceId, address manager, address owner) internal {
        if (_operatorStatusRegistry == address(0)) return;

        // Get heartbeat interval from BSM (use default if not implemented or returns useDefault=true)
        uint64 interval = 0; // 0 means use registry default
        uint8 maxMissed = 0; // 0 means use registry default

        if (manager != address(0)) {
            // Try to get custom heartbeat interval
            try IBlueprintServiceManager(manager).getHeartbeatInterval(serviceId) returns (bool useDefault, uint64 customInterval) {
                if (!useDefault && customInterval > 0) {
                    interval = customInterval;
                }
            } catch {}

            // Try to get custom heartbeat threshold (max missed before offline)
            try IBlueprintServiceManager(manager).getHeartbeatThreshold(serviceId) returns (bool useDefault, uint8 threshold) {
                if (!useDefault && threshold > 0) {
                    // threshold is percentage, we interpret high values as max missed beats
                    // Lower threshold = stricter = fewer missed allowed
                    // e.g., 90% threshold ≈ allow 1 missed, 50% ≈ allow 3 missed
                    maxMissed = threshold > 80 ? 1 : (threshold > 50 ? 2 : 3);
                }
            } catch {}
        }

        // Register service owner and configure heartbeat
        try IOperatorStatusRegistry(_operatorStatusRegistry).registerServiceOwner(serviceId, owner) {} catch {}

        // Configure heartbeat if custom values provided
        if (interval > 0 || maxMissed > 0) {
            // Use defaults for unspecified values
            if (interval == 0) interval = 300; // 5 minutes default
            if (maxMissed == 0) maxMissed = 3;

            try IOperatorStatusRegistry(_operatorStatusRegistry).configureHeartbeat(
                serviceId,
                interval,
                maxMissed
            ) {} catch {}
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // INTERNAL GETTERS
    // ═══════════════════════════════════════════════════════════════════════════

    function _getBlueprint(uint64 id) internal view returns (Types.Blueprint storage) {
        if (id >= _blueprintCount) revert Errors.BlueprintNotFound(id);
        return _blueprints[id];
    }

    function _getServiceRequest(uint64 id) internal view returns (Types.ServiceRequest storage) {
        if (id >= _serviceRequestCount) revert Errors.ServiceRequestNotFound(id);
        return _serviceRequests[id];
    }

    function _getService(uint64 id) internal view returns (Types.Service storage) {
        if (id >= _serviceCount) revert Errors.ServiceNotFound(id);
        return _services[id];
    }

    function _getJobCall(uint64 serviceId, uint64 callId) internal view returns (Types.JobCall storage) {
        if (callId >= _serviceCallCount[serviceId]) revert Errors.JobCallNotFound(serviceId, callId);
        return _jobCalls[serviceId][callId];
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // MANAGER HOOKS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Call manager with revert on failure
    function _callManager(address manager, bytes memory data) internal {
        (bool success, bytes memory returnData) = manager.call(data);
        if (!success) {
            if (returnData.length > 0) {
                revert Errors.ManagerReverted(manager, returnData);
            }
            revert Errors.ManagerRejected(manager);
        }
    }

    /// @notice Try to call manager, ignore failures
    function _tryCallManager(address manager, bytes memory data) internal {
        (bool success,) = manager.call(data);
        success; // Silence unused variable warning
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // VIEW FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    function blueprintCount() external view returns (uint64) { return _blueprintCount; }
    function serviceCount() external view returns (uint64) { return _serviceCount; }
    function serviceRequestCount() external view returns (uint64) { return _serviceRequestCount; }

    function getBlueprint(uint64 id) external view returns (Types.Blueprint memory) {
        return _blueprints[id];
    }

    function getBlueprintConfig(uint64 id) external view returns (Types.BlueprintConfig memory) {
        return _blueprintConfigs[id];
    }

    function getServiceRequest(uint64 id) external view returns (Types.ServiceRequest memory) {
        return _serviceRequests[id];
    }

    function getService(uint64 id) external view returns (Types.Service memory) {
        return _services[id];
    }

    function getServiceOperator(uint64 serviceId, address op) external view returns (Types.ServiceOperator memory) {
        return _serviceOperators[serviceId][op];
    }

    function getServiceOperators(uint64 serviceId) external view returns (address[] memory) {
        return _serviceOperatorSet[serviceId].values();
    }

    function getJobCall(uint64 serviceId, uint64 callId) external view returns (Types.JobCall memory) {
        return _jobCalls[serviceId][callId];
    }

    function getOperatorRegistration(uint64 blueprintId, address op) external view returns (Types.OperatorRegistration memory) {
        return _operatorRegistrations[blueprintId][op];
    }

    function isOperatorRegistered(uint64 blueprintId, address op) external view returns (bool) {
        return _operatorRegistrations[blueprintId][op].registeredAt != 0;
    }

    /// @notice Get operator preferences for a blueprint (includes ECDSA public key)
    function getOperatorPreferences(uint64 blueprintId, address op) external view returns (Types.OperatorPreferences memory) {
        return _operatorPreferences[blueprintId][op];
    }

    /// @notice Get operator's ECDSA public key for gossip network identity
    /// @dev Returns the key used for signing/verifying gossip messages
    function getOperatorPublicKey(uint64 blueprintId, address op) external view returns (bytes memory) {
        return _operatorPreferences[blueprintId][op].ecdsaPublicKey;
    }

    function isServiceActive(uint64 serviceId) external view returns (bool) {
        return _services[serviceId].status == Types.ServiceStatus.Active;
    }

    function isServiceOperator(uint64 serviceId, address op) external view returns (bool) {
        return _serviceOperators[serviceId][op].active;
    }

    function isPermittedCaller(uint64 serviceId, address caller) external view returns (bool) {
        return _permittedCallers[serviceId].contains(caller);
    }

    function blueprintOperatorCount(uint64 blueprintId) external view returns (uint256) {
        return _blueprintOperators[blueprintId].length();
    }

    /// @notice Accept native token
    receive() external payable {}
}
