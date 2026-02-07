// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import { Ownable2Step } from "@openzeppelin/contracts/access/Ownable2Step.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
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

    /// @notice Metric payload pair used for ABI-encoded metrics submissions.
    struct MetricPair {
        string name;
        uint256 value;
    }

    /// @notice Custom metric definition
    struct MetricDefinition {
        string name;
        uint256 minValue;
        uint256 maxValue;
        bool required;
    }

    /// @notice Heartbeat configuration per service
    struct HeartbeatConfig {
        uint64 interval;
        uint8 maxMissed;
        bool customMetrics;
    }

    /// @notice Operator status tracking
    struct OperatorState {
        uint256 lastHeartbeat;
        uint64 consecutiveBeats;
        uint8 missedBeats;
        StatusCode status;
        bytes32 lastMetricsHash;
    }

    /// @notice Submit a heartbeat to prove operator is online
    function submitHeartbeat(
        uint64 serviceId,
        uint64 blueprintId,
        uint8 statusCode,
        bytes calldata metrics,
        bytes calldata signature
    ) external;

    /// @notice Submit heartbeat without signature (for trusted contexts)
    function submitHeartbeatDirect(
        uint64 serviceId,
        uint64 blueprintId,
        uint8 statusCode,
        bytes calldata metrics
    ) external;

    /// @notice Check if an operator is online for a service
    function isOnline(uint64 serviceId, address operator) external view returns (bool);

    /// @notice Get operator status for a service
    function getOperatorStatus(uint64 serviceId, address operator) external view returns (StatusCode);

    /// @notice Get last heartbeat timestamp for an operator
    function getLastHeartbeat(uint64 serviceId, address operator) external view returns (uint256);

    /// @notice Get full operator state
    function getOperatorState(uint64 serviceId, address operator) external view returns (OperatorState memory);

    /// @notice Get all online operators for a service
    function getOnlineOperators(uint64 serviceId) external view returns (address[] memory);

    /// @notice Get heartbeat config for a service
    function getHeartbeatConfig(uint64 serviceId) external view returns (HeartbeatConfig memory);

    /// @notice Check if operator has submitted heartbeat recently
    function isHeartbeatCurrent(uint64 serviceId, address operator) external view returns (bool);

    /// @notice Get a metric value for an operator
    function getMetricValue(uint64 serviceId, address operator, string calldata metricName) external view returns (uint256);

    /// @notice Get metric definitions for a service
    function getMetricDefinitions(uint64 serviceId) external view returns (MetricDefinition[] memory);

    /// @notice Register service owner (called by Tangle core)
    function registerServiceOwner(uint64 serviceId, address owner) external;

    /// @notice Configure heartbeat settings for a service
    function configureHeartbeat(uint64 serviceId, uint64 interval, uint8 maxMissed) external;

    /// @notice Enable custom metrics for a service
    function enableCustomMetrics(uint64 serviceId, bool enabled) external;

    /// @notice Batch set metric definitions for a service (replaces existing)
    function setMetricDefinitions(uint64 serviceId, MetricDefinition[] calldata definitions) external;

    /// @notice Add a custom metric definition
    function addMetricDefinition(uint64 serviceId, string calldata name, uint256 minValue, uint256 maxValue, bool required) external;

    /// @notice Report an operator for slashing
    function reportForSlashing(uint64 serviceId, address operator, string calldata reason) external;

    /// @notice Get offline operators that should be slashed
    function getSlashableOperators(uint64 serviceId) external view returns (address[] memory);

    /// @notice Operator voluntarily goes offline
    function goOffline(uint64 serviceId) external;

    /// @notice Operator comes back online
    function goOnline(uint64 serviceId) external;
}

/// @title OperatorStatusRegistry
/// @notice Tracks operator online/offline status via heartbeats
/// @dev Integrates with Blueprint SDK QoS metrics system
contract OperatorStatusRegistry is IOperatorStatusRegistry, Ownable2Step {
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
    bytes32 public constant HEARTBEAT_TYPEHASH = keccak256(
        "HeartbeatStatus(uint64 blockNumber,uint64 timestamp,uint64 serviceId,uint64 blueprintId,uint32 statusCode,string statusMessage)"
    );

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

    event MetricViolation(
        uint64 indexed serviceId,
        address indexed operator,
        string metricName,
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

    /// @notice All operators that have ever submitted a heartbeat: serviceId => operators
    mapping(uint64 => EnumerableSet.AddressSet) internal _allOperators;

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

    constructor(address _tangleCore, address initialOwner) Ownable(initialOwner) {
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
    ) external override {
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

        // Track operator in the all-operators set
        _allOperators[serviceId].add(operator);

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
        if (metrics.length == 0) return;

        MetricPair[] memory pairs;

        // Decode as MetricPair[]; a single metric should be encoded as a 1-element array.
        try this.decodeMetricPairs(metrics) returns (MetricPair[] memory decoded) {
            pairs = decoded;
        } catch {
            return;
        }

        for (uint256 i = 0; i < pairs.length; i++) {
            metricValues[serviceId][operator][pairs[i].name] = pairs[i].value;
            emit MetricReported(serviceId, operator, pairs[i].name, pairs[i].value);
        }

        // Validate metrics against definitions
        MetricDefinition[] storage definitions = serviceMetrics[serviceId];
        for (uint256 d = 0; d < definitions.length; d++) {
            MetricDefinition storage def = definitions[d];
            bool found = false;
            uint256 reportedValue;

            for (uint256 p = 0; p < pairs.length; p++) {
                if (keccak256(bytes(pairs[p].name)) == keccak256(bytes(def.name))) {
                    found = true;
                    reportedValue = pairs[p].value;
                    break;
                }
            }

            if (!found && def.required) {
                emit MetricViolation(serviceId, operator, def.name, "Required metric missing");
                continue;
            }

            if (found) {
                if (reportedValue < def.minValue || reportedValue > def.maxValue) {
                    emit MetricViolation(serviceId, operator, def.name, "Value out of bounds");
                }
            }
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
    function goOffline(uint64 serviceId) external override {
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
    function goOnline(uint64 serviceId) external override {
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
    function enableCustomMetrics(uint64 serviceId, bool enabled) external override {
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
    ) external override {
        require(msg.sender == serviceOwners[serviceId], "Not service owner");

        serviceMetrics[serviceId].push(MetricDefinition({
            name: name,
            minValue: minValue,
            maxValue: maxValue,
            required: required
        }));
    }

    /// @notice Batch set metric definitions for a service (replaces existing)
    function setMetricDefinitions(uint64 serviceId, MetricDefinition[] calldata definitions) external override {
        require(msg.sender == serviceOwners[serviceId], "Not service owner");
        delete serviceMetrics[serviceId];
        for (uint256 i = 0; i < definitions.length; i++) {
            require(definitions[i].maxValue >= definitions[i].minValue, "Invalid bounds");
            serviceMetrics[serviceId].push(definitions[i]);
        }
    }

    /// @notice Set slashing oracle address
    function setSlashingOracle(address oracle) external onlyOwner {
        // Governance-controlled (e.g., a timelock) should manage this address.
        slashingOracle = oracle;
    }

    /// @notice Set metrics recorder address for reward tracking
    function setMetricsRecorder(address recorder) external onlyOwner {
        // Governance-controlled (e.g., a timelock) should manage this address.
        metricsRecorder = recorder;
    }

    /// @notice Decode metric pairs from ABI-encoded payload.
    /// @dev External + try/catch wrapper target so malformed payloads don't brick heartbeats.
    function decodeMetricPairs(bytes calldata payload) external pure returns (MetricPair[] memory pairs) {
        return abi.decode(payload, (MetricPair[]));
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
    function getOperatorState(uint64 serviceId, address operator) external view override returns (OperatorState memory) {
        return operatorStates[serviceId][operator];
    }

    /// @notice Get all online operators for a service
    function getOnlineOperators(uint64 serviceId) external view override returns (address[] memory) {
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
    function getHeartbeatConfig(uint64 serviceId) external view override returns (HeartbeatConfig memory) {
        return _getConfig(serviceId);
    }

    /// @notice Get a metric value for an operator
    function getMetricValue(
        uint64 serviceId,
        address operator,
        string calldata metricName
    ) external view override returns (uint256) {
        return metricValues[serviceId][operator][metricName];
    }

    /// @notice Get metric definitions for a service
    function getMetricDefinitions(uint64 serviceId) external view override returns (MetricDefinition[] memory) {
        return serviceMetrics[serviceId];
    }

    /// @notice Check if operator has submitted heartbeat recently
    function isHeartbeatCurrent(uint64 serviceId, address operator) external view override returns (bool) {
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
    function getSlashableOperators(uint64 serviceId) external view override returns (address[] memory operators) {
        HeartbeatConfig memory config = _getConfig(serviceId);
        uint256 totalCount = _allOperators[serviceId].length();

        if (config.maxMissed == 0 || totalCount == 0) {
            return new address[](0);
        }

        uint256 threshold = uint256(config.interval) * uint256(config.maxMissed);

        // First pass: count slashable operators
        uint256 slashableCount = 0;
        for (uint256 i = 0; i < totalCount; i++) {
            address op = _allOperators[serviceId].at(i);
            OperatorState memory state = operatorStates[serviceId][op];
            // Skip operators that have never heartbeated, are already slashed, or voluntarily exiting
            if (state.lastHeartbeat == 0 || state.status == StatusCode.Slashed || state.status == StatusCode.Exiting) {
                continue;
            }
            if (block.timestamp - state.lastHeartbeat >= threshold) {
                slashableCount++;
            }
        }

        // Second pass: collect slashable operators
        operators = new address[](slashableCount);
        uint256 idx = 0;
        for (uint256 i = 0; i < totalCount; i++) {
            address op = _allOperators[serviceId].at(i);
            OperatorState memory state = operatorStates[serviceId][op];
            if (state.lastHeartbeat == 0 || state.status == StatusCode.Slashed || state.status == StatusCode.Exiting) {
                continue;
            }
            if (block.timestamp - state.lastHeartbeat >= threshold) {
                operators[idx] = op;
                idx++;
            }
        }
    }

    /// @notice Report an operator for slashing (called by slashing oracle)
    function reportForSlashing(
        uint64 serviceId,
        address operator,
        string calldata reason
    ) external override {
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
