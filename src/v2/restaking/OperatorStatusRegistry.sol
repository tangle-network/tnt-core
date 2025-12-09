// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import { IMetricsRecorder } from "../interfaces/IMetricsRecorder.sol";

/// @title IOperatorStatusRegistry
/// @notice Interface for operator status registry
/// @dev Matches blueprint-sdk QoS heartbeat patterns
interface IOperatorStatusRegistry {
    /// @notice Operator status codes (matches blueprint-sdk status_code conventions)
    /// @dev 0 = Healthy, 1-99 = Degraded, 100+ = Critical, 200+ = Slashable
    enum StatusCode {
        Healthy,        // 0: Operator is healthy and responding
        Degraded,       // 1: Operator is responding but with issues
        Offline,        // 2: Operator missed heartbeat threshold
        Slashed,        // 3: Operator was slashed for misbehavior
        Exiting         // 4: Operator is voluntarily exiting
    }

    /// @notice Submit a heartbeat to prove operator is online
    /// @dev Signature format matches blueprint-sdk: keccak256(service_id || blueprint_id || metrics)
    /// @param serviceId The service ID
    /// @param blueprintId The blueprint ID
    /// @param statusCode Operator-reported status code (0 = healthy)
    /// @param metrics Encoded metrics data (can be empty)
    /// @param signature ECDSA signature of the heartbeat message
    function submitHeartbeat(
        uint64 serviceId,
        uint64 blueprintId,
        uint8 statusCode,
        bytes calldata metrics,
        bytes calldata signature
    ) external;

    /// @notice Check if an operator is online for a service
    function isOnline(uint64 serviceId, address operator) external view returns (bool);

    /// @notice Get operator status for a service
    function getOperatorStatus(uint64 serviceId, address operator) external view returns (StatusCode);

    /// @notice Get last heartbeat timestamp for an operator
    function getLastHeartbeat(uint64 serviceId, address operator) external view returns (uint256);

    /// @notice Register service owner (called by Tangle core)
    function registerServiceOwner(uint64 serviceId, address owner) external;

    /// @notice Configure heartbeat settings for a service
    function configureHeartbeat(uint64 serviceId, uint64 interval, uint8 maxMissed) external;
}

/// @title OperatorStatusRegistry
/// @notice Tracks operator online/offline status via heartbeats
/// @dev Integrates with Blueprint SDK QoS metrics system
contract OperatorStatusRegistry is IOperatorStatusRegistry {
    using ECDSA for bytes32;
    using EnumerableSet for EnumerableSet.AddressSet;

    // ═══════════════════════════════════════════════════════════════════════════
    // CONSTANTS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Default heartbeat interval (5 minutes)
    uint64 public constant DEFAULT_HEARTBEAT_INTERVAL = 5 minutes;

    /// @notice Default max missed heartbeats before offline
    uint8 public constant DEFAULT_MAX_MISSED_HEARTBEATS = 3;

    /// @notice Domain separator for EIP-712 signatures (kept for backwards compatibility)
    bytes32 public immutable DOMAIN_SEPARATOR;

    /// @notice Heartbeat message typehash (for reference - actual signing uses raw keccak256)
    /// @dev Signature: keccak256(abi.encodePacked(serviceId, blueprintId, abiEncodedStatus)) with Ethereum prefix
    ///      HeartbeatStatus = (uint64 blockNumber, uint64 timestamp, uint64 serviceId, uint64 blueprintId, uint32 statusCode, string statusMessage)
    ///      TODO(blueprint-sdk): Update to use ABI encoding instead of SCALE, and big-endian for serviceId/blueprintId
    bytes32 public constant HEARTBEAT_TYPEHASH = keccak256(
        "HeartbeatStatus(uint64 blockNumber,uint64 timestamp,uint64 serviceId,uint64 blueprintId,uint32 statusCode,string statusMessage)"
    );

    // ═══════════════════════════════════════════════════════════════════════════
    // STRUCTS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Heartbeat configuration per service
    struct HeartbeatConfig {
        uint64 interval;          // Heartbeat interval in seconds
        uint8 maxMissed;          // Max missed heartbeats before offline
        bool customMetrics;       // Whether service uses custom metrics
    }

    /// @notice Operator status tracking
    struct OperatorState {
        uint256 lastHeartbeat;    // Timestamp of last heartbeat
        uint64 consecutiveBeats;  // Number of consecutive successful heartbeats
        uint8 missedBeats;        // Number of consecutive missed heartbeats
        StatusCode status;        // Current status
        bytes32 lastMetricsHash;  // Hash of last reported metrics
    }

    /// @notice Custom metric definition
    struct MetricDefinition {
        string name;              // Metric name (e.g., "cpu_usage")
        uint256 minValue;         // Minimum acceptable value
        uint256 maxValue;         // Maximum acceptable value
        bool required;            // Whether metric is required
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    event HeartbeatReceived(
        uint64 indexed serviceId,
        uint64 indexed blueprintId,
        address indexed operator,
        uint8 statusCode,
        uint256 timestamp
    );

    event OperatorWentOffline(
        uint64 indexed serviceId,
        address indexed operator,
        uint8 missedBeats
    );

    event OperatorCameOnline(
        uint64 indexed serviceId,
        address indexed operator
    );

    event StatusChanged(
        uint64 indexed serviceId,
        address indexed operator,
        StatusCode oldStatus,
        StatusCode newStatus
    );

    event HeartbeatConfigUpdated(
        uint64 indexed serviceId,
        uint64 interval,
        uint8 maxMissed
    );

    event MetricReported(
        uint64 indexed serviceId,
        address indexed operator,
        string metricName,
        uint256 value
    );

    event SlashingTriggered(
        uint64 indexed serviceId,
        address indexed operator,
        string reason
    );

    // ═══════════════════════════════════════════════════════════════════════════
    // STATE
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Heartbeat config per service: serviceId => config
    mapping(uint64 => HeartbeatConfig) public heartbeatConfigs;

    /// @notice Operator state per service: serviceId => operator => state
    mapping(uint64 => mapping(address => OperatorState)) public operatorStates;

    /// @notice Online operators per service: serviceId => operators
    mapping(uint64 => EnumerableSet.AddressSet) internal _onlineOperators;

    /// @notice Service owners who can configure heartbeat settings
    mapping(uint64 => address) public serviceOwners;

    /// @notice Custom metrics per service: serviceId => metric definitions
    mapping(uint64 => MetricDefinition[]) public serviceMetrics;

    /// @notice Last reported metric values: serviceId => operator => metricName => value
    mapping(uint64 => mapping(address => mapping(string => uint256))) public metricValues;

    /// @notice Tangle core contract address for service validation
    // forge-lint: disable-next-line(screaming-snake-case-immutable)
    address public immutable tangleCore;

    /// @notice Slashing callback interface
    address public slashingOracle;

    /// @notice Metrics recorder for reward distribution
    address public metricsRecorder;

    /// @notice Cooldown between successive critical heartbeat alerts per service/operator
    uint64 public constant SLASH_ALERT_COOLDOWN = 1 hours;

    /// @notice Last critical alert timestamp (serviceId => operator => timestamp)
    mapping(uint64 => mapping(address => uint64)) private _lastCriticalAlert;

    // ═══════════════════════════════════════════════════════════════════════════
    // CONSTRUCTOR
    // ═══════════════════════════════════════════════════════════════════════════

    constructor(address _tangleCore) {
        tangleCore = _tangleCore;

        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256("OperatorStatusRegistry"),
                keccak256("1"),
                block.chainid,
                address(this)
            )
        );
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // HEARTBEAT SUBMISSION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Submit a heartbeat to prove operator is online
    /// @dev Signature: ECDSA over keccak256(abi.encodePacked(serviceId, blueprintId, metrics))
    ///      NOTE: Uses native EVM big-endian encoding. Blueprint-SDK must use to_be_bytes() not to_le_bytes()
    /// @param serviceId The service ID
    /// @param blueprintId The blueprint ID
    /// @param statusCode Operator-reported status code (0 = healthy)
    /// @param metrics Encoded metrics data (can be empty)
    /// @param signature ECDSA signature of the heartbeat message
    function submitHeartbeat(
        uint64 serviceId,
        uint64 blueprintId,
        uint8 statusCode,
        bytes calldata metrics,
        bytes calldata signature
    ) external override {
        // Verify signature using native EVM encoding (big-endian):
        // message = abi.encodePacked(serviceId, blueprintId, metrics)
        // hash = keccak256(message)
        // signature = ECDSA.sign(ethSignedMessageHash(hash))
        // forge-lint: disable-next-line(asm-keccak256)
        bytes32 messageHash = keccak256(abi.encodePacked(serviceId, blueprintId, metrics));

        // Recover signer using Ethereum signed message format
        // forge-lint: disable-next-line(asm-keccak256)
        bytes32 ethSignedHash = keccak256(
            abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash)
        );

        address signer = ethSignedHash.recover(signature);
        require(signer == msg.sender, "Invalid signature");

        _processHeartbeat(serviceId, blueprintId, msg.sender, statusCode, metrics);
    }

    /// @notice Submit heartbeat without signature (for trusted contexts)
    /// @dev Can be called directly by operators in trusted environments
    function submitHeartbeatDirect(
        uint64 serviceId,
        uint64 blueprintId,
        uint8 statusCode,
        bytes calldata metrics
    ) external {
        _processHeartbeat(serviceId, blueprintId, msg.sender, statusCode, metrics);
    }

    /// @notice Process a heartbeat submission
    function _processHeartbeat(
        uint64 serviceId,
        uint64 blueprintId,
        address operator,
        uint8 statusCode,
        bytes calldata metrics
    ) internal {
        OperatorState storage state = operatorStates[serviceId][operator];
        HeartbeatConfig memory config = _getConfig(serviceId);

        // Update state
        StatusCode oldStatus = state.status;
        state.lastHeartbeat = block.timestamp;
        state.lastMetricsHash = keccak256(metrics);
        state.missedBeats = 0;
        state.consecutiveBeats++;

        // Determine new status based on reported code
        StatusCode newStatus;
        if (statusCode == 0) {
            newStatus = StatusCode.Healthy;
        } else if (statusCode < 100) {
            newStatus = StatusCode.Degraded;
        } else {
            // Status codes >= 100 indicate problems that may trigger slashing
            newStatus = StatusCode.Degraded;
            _checkSlashingCondition(serviceId, blueprintId, operator, statusCode, metrics);
        }

        state.status = newStatus;

        // Update online set
        if (oldStatus == StatusCode.Offline && newStatus != StatusCode.Offline) {
            _onlineOperators[serviceId].add(operator);
            emit OperatorCameOnline(serviceId, operator);
        }

        // Process custom metrics if enabled
        if (config.customMetrics && metrics.length > 0) {
            _processMetrics(serviceId, operator, metrics);
        }

        emit HeartbeatReceived(serviceId, blueprintId, operator, statusCode, block.timestamp);

        if (oldStatus != newStatus) {
            emit StatusChanged(serviceId, operator, oldStatus, newStatus);
        }

        // Record heartbeat to metrics for reward distribution
        if (metricsRecorder != address(0)) {
            try IMetricsRecorder(metricsRecorder).recordHeartbeat(
                operator,
                serviceId,
                uint64(block.timestamp)
            ) {} catch {}
        }
    }

    /// @notice Process custom metrics from heartbeat
    function _processMetrics(
        uint64 serviceId,
        address operator,
        bytes calldata metrics
    ) internal {
        // Decode metrics as (string name, uint256 value) pairs
        // Format: abi.encode([(name, value), ...])
        if (metrics.length < 64) return; // Minimum size for one metric

        uint256 offset = 0;
        while (offset + 64 <= metrics.length) {
            // Simplified parsing - in production, use proper ABI decoding
            string memory name;
            uint256 value;

            // Try to decode a metric pair
            (name, value) = abi.decode(metrics[offset:], (string, uint256));

            metricValues[serviceId][operator][name] = value;
            emit MetricReported(serviceId, operator, name, value);

            // Move to next pair (simplified - actual size depends on string length)
            offset += 64 + bytes(name).length;
            if (offset > metrics.length) break;
        }
    }

    /// @notice Check if status code indicates a slashing condition
    function _checkSlashingCondition(
        uint64 serviceId,
        uint64 blueprintId,
        address operator,
        uint8 statusCode,
        bytes calldata /* metrics */
    ) internal {
        // Status codes indicating slashable offenses:
        // 100+ : Self-reported critical error
        // 200+ : Protocol violation detected
        // 255  : Operator requesting exit due to inability to serve

        if (statusCode >= 200) {
            uint64 currentTime = uint64(block.timestamp);
            uint64 lastAlert = _lastCriticalAlert[serviceId][operator];
            if (lastAlert == 0 || currentTime - lastAlert >= SLASH_ALERT_COOLDOWN) {
                _lastCriticalAlert[serviceId][operator] = currentTime;
                emit SlashingTriggered(serviceId, operator, "Protocol violation reported");
                // Could call slashing oracle here - blueprintId available for context
            }
        }

        // Silence unused variable warning
        blueprintId;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // OFFLINE DETECTION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Check and update operator status based on heartbeat timing
    /// @dev Should be called periodically (e.g., by keepers or during other operations)
    function checkOperatorStatus(uint64 serviceId, address operator) external {
        OperatorState storage state = operatorStates[serviceId][operator];
        HeartbeatConfig memory config = _getConfig(serviceId);

        if (state.lastHeartbeat == 0) {
            return; // Never submitted a heartbeat
        }

        uint256 elapsed = block.timestamp - state.lastHeartbeat;
        // forge-lint: disable-next-line(unsafe-typecast)
        uint8 missedBeats = uint8(elapsed / config.interval);

        if (missedBeats > state.missedBeats) {
            state.missedBeats = missedBeats;
            state.consecutiveBeats = 0;

            if (missedBeats >= config.maxMissed && state.status != StatusCode.Offline) {
                StatusCode oldStatus = state.status;
                state.status = StatusCode.Offline;
                _onlineOperators[serviceId].remove(operator);

                emit OperatorWentOffline(serviceId, operator, missedBeats);
                emit StatusChanged(serviceId, operator, oldStatus, StatusCode.Offline);
            }
        }
    }

    /// @notice Batch check multiple operators
    function checkOperatorsStatus(uint64 serviceId, address[] calldata operators) external {
        for (uint256 i = 0; i < operators.length; i++) {
            this.checkOperatorStatus(serviceId, operators[i]);
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // OPERATOR AVAILABILITY TOGGLE (matches Substrate go_online/go_offline)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Operator voluntarily goes offline
    /// @dev Prevents slashing for missed heartbeats while operator is intentionally offline
    /// @param serviceId The service ID
    function goOffline(uint64 serviceId) external {
        OperatorState storage state = operatorStates[serviceId][msg.sender];

        StatusCode oldStatus = state.status;
        if (oldStatus == StatusCode.Slashed) {
            revert("Cannot go offline while slashed");
        }

        state.status = StatusCode.Exiting;
        _onlineOperators[serviceId].remove(msg.sender);

        emit StatusChanged(serviceId, msg.sender, oldStatus, StatusCode.Exiting);
    }

    /// @notice Operator comes back online after voluntary offline period
    /// @dev Must submit a heartbeat after coming online to be marked Healthy
    /// @param serviceId The service ID
    function goOnline(uint64 serviceId) external {
        OperatorState storage state = operatorStates[serviceId][msg.sender];

        StatusCode oldStatus = state.status;
        if (oldStatus == StatusCode.Slashed) {
            revert("Cannot go online while slashed");
        }

        // Transition from Exiting/Offline to Degraded (must heartbeat to become Healthy)
        state.status = StatusCode.Degraded;
        state.missedBeats = 0;
        _onlineOperators[serviceId].add(msg.sender);

        emit OperatorCameOnline(serviceId, msg.sender);
        emit StatusChanged(serviceId, msg.sender, oldStatus, StatusCode.Degraded);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // CONFIGURATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Configure heartbeat settings for a service
    /// @param serviceId The service ID
    /// @param interval Heartbeat interval in seconds
    /// @param maxMissed Max missed heartbeats before offline
    function configureHeartbeat(
        uint64 serviceId,
        uint64 interval,
        uint8 maxMissed
    ) external {
        require(
            msg.sender == tangleCore ||
            msg.sender == serviceOwners[serviceId] ||
            serviceOwners[serviceId] == address(0),
            "Not authorized"
        );

        require(interval >= 60, "Interval too short"); // Minimum 1 minute
        require(maxMissed >= 1, "Max missed must be >= 1");

        heartbeatConfigs[serviceId] = HeartbeatConfig({
            interval: interval,
            maxMissed: maxMissed,
            customMetrics: heartbeatConfigs[serviceId].customMetrics
        });

        emit HeartbeatConfigUpdated(serviceId, interval, maxMissed);
    }

    /// @notice Register service owner
    /// @dev Only callable by the Tangle core contract
    function registerServiceOwner(uint64 serviceId, address owner) external {
        require(msg.sender == tangleCore, "Only Tangle core");
        require(serviceOwners[serviceId] == address(0), "Already registered");
        serviceOwners[serviceId] = owner;
    }

    /// @notice Enable custom metrics for a service
    function enableCustomMetrics(uint64 serviceId, bool enabled) external {
        require(msg.sender == serviceOwners[serviceId], "Not service owner");
        heartbeatConfigs[serviceId].customMetrics = enabled;
    }

    /// @notice Add a custom metric definition
    function addMetricDefinition(
        uint64 serviceId,
        string calldata name,
        uint256 minValue,
        uint256 maxValue,
        bool required
    ) external {
        require(msg.sender == serviceOwners[serviceId], "Not service owner");

        serviceMetrics[serviceId].push(MetricDefinition({
            name: name,
            minValue: minValue,
            maxValue: maxValue,
            required: required
        }));
    }

    /// @notice Set slashing oracle address
    function setSlashingOracle(address oracle) external {
        // In production, should be access controlled
        slashingOracle = oracle;
    }

    /// @notice Set metrics recorder address for reward tracking
    function setMetricsRecorder(address recorder) external {
        // In production, should be access controlled
        metricsRecorder = recorder;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // VIEW FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Check if an operator is online for a service
    function isOnline(uint64 serviceId, address operator) external view override returns (bool) {
        return operatorStates[serviceId][operator].status == StatusCode.Healthy ||
               operatorStates[serviceId][operator].status == StatusCode.Degraded;
    }

    /// @notice Get operator status for a service
    function getOperatorStatus(uint64 serviceId, address operator) external view override returns (StatusCode) {
        return operatorStates[serviceId][operator].status;
    }

    /// @notice Get last heartbeat timestamp for an operator
    function getLastHeartbeat(uint64 serviceId, address operator) external view override returns (uint256) {
        return operatorStates[serviceId][operator].lastHeartbeat;
    }

    /// @notice Get full operator state
    function getOperatorState(uint64 serviceId, address operator) external view returns (OperatorState memory) {
        return operatorStates[serviceId][operator];
    }

    /// @notice Get all online operators for a service
    function getOnlineOperators(uint64 serviceId) external view returns (address[] memory) {
        uint256 count = _onlineOperators[serviceId].length();
        address[] memory result = new address[](count);
        for (uint256 i = 0; i < count; i++) {
            result[i] = _onlineOperators[serviceId].at(i);
        }
        return result;
    }

    /// @notice Get online operator count
    function getOnlineOperatorCount(uint64 serviceId) external view returns (uint256) {
        return _onlineOperators[serviceId].length();
    }

    /// @notice Get heartbeat config for a service
    function getHeartbeatConfig(uint64 serviceId) external view returns (HeartbeatConfig memory) {
        return _getConfig(serviceId);
    }

    /// @notice Get a metric value for an operator
    function getMetricValue(
        uint64 serviceId,
        address operator,
        string calldata metricName
    ) external view returns (uint256) {
        return metricValues[serviceId][operator][metricName];
    }

    /// @notice Get metric definitions for a service
    function getMetricDefinitions(uint64 serviceId) external view returns (MetricDefinition[] memory) {
        return serviceMetrics[serviceId];
    }

    /// @notice Check if operator has submitted heartbeat recently
    function isHeartbeatCurrent(uint64 serviceId, address operator) external view returns (bool) {
        HeartbeatConfig memory config = _getConfig(serviceId);
        OperatorState memory state = operatorStates[serviceId][operator];

        if (state.lastHeartbeat == 0) return false;

        return (block.timestamp - state.lastHeartbeat) < config.interval;
    }

    /// @notice Get config with defaults
    function _getConfig(uint64 serviceId) internal view returns (HeartbeatConfig memory) {
        HeartbeatConfig memory config = heartbeatConfigs[serviceId];

        // Apply defaults if not configured
        if (config.interval == 0) {
            config.interval = DEFAULT_HEARTBEAT_INTERVAL;
        }
        if (config.maxMissed == 0) {
            config.maxMissed = DEFAULT_MAX_MISSED_HEARTBEATS;
        }

        return config;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SLASHING INTEGRATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Get offline operators that should be slashed
    /// @param serviceId The service ID
    /// @return operators Array of operators that are offline beyond threshold
    function getSlashableOperators(uint64 serviceId) external view returns (address[] memory operators) {
        // Placeholder implementation until keeper integration enumerates offline operators.
        // Touch config and online set to ensure state reads so function stays view-only.
        HeartbeatConfig memory config = _getConfig(serviceId);
        uint256 onlineCount = _onlineOperators[serviceId].length();

        if (config.maxMissed == 0 || onlineCount == 0) {
            // Config maxMissed == 0 means service has no heartbeat enforcement; nothing to slash.
            return new address[](0);
        }

        // Real implementation will iterate over operators and compare last heartbeat vs interval.
        return new address[](0);
    }

    /// @notice Report an operator for slashing (called by slashing oracle)
    function reportForSlashing(
        uint64 serviceId,
        address operator,
        string calldata reason
    ) external {
        require(msg.sender == slashingOracle, "Not slashing oracle");

        OperatorState storage state = operatorStates[serviceId][operator];
        state.status = StatusCode.Slashed;
        _onlineOperators[serviceId].remove(operator);
        _lastCriticalAlert[serviceId][operator] = uint64(block.timestamp);

        emit SlashingTriggered(serviceId, operator, reason);
    }

    /// @notice Get the last critical heartbeat timestamp for an operator
    function getLastCriticalHeartbeat(uint64 serviceId, address operator) external view returns (uint64) {
        return _lastCriticalAlert[serviceId][operator];
    }
}
