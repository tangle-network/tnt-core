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
import { IMBSMRegistry } from "../interfaces/IMBSMRegistry.sol";
import { IOperatorStatusRegistry } from "../restaking/OperatorStatusRegistry.sol";
import { ProtocolConfig } from "../config/ProtocolConfig.sol";

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

    /// @notice Emitted when a service is activated from a pending request
    /// @param serviceId The newly created service ID
    /// @param requestId The request ID that was activated
    /// @param blueprintId The blueprint this service is based on
    event ServiceActivated(uint64 indexed serviceId, uint64 indexed requestId, uint64 indexed blueprintId);

    /// @notice Emitted when the MBSM registry is updated
    /// @param registry The new registry address
    event MBSMRegistryUpdated(address indexed registry);

    /// @notice Emitted when the metrics recorder is updated
    /// @param recorder The new recorder address (or zero to disable)
    event MetricsRecorderUpdated(address indexed recorder);

    /// @notice Emitted when the operator status registry is updated
    /// @param registry The new registry address (or zero to disable)
    event OperatorStatusRegistryUpdated(address indexed registry);

    /// @notice Emitted when the service fee distributor is updated
    /// @param distributor The new distributor address (or zero to disable)
    event ServiceFeeDistributorUpdated(address indexed distributor);

    /// @notice Emitted when the price oracle is updated
    /// @param oracle The new oracle address (or zero to disable)
    event PriceOracleUpdated(address indexed oracle);

    /// @notice Emitted when max blueprints per operator limit is changed
    /// @param oldMax Previous maximum value
    /// @param newMax New maximum value (0 means unlimited)
    event MaxBlueprintsPerOperatorUpdated(uint32 oldMax, uint32 newMax);

    /// @notice Emitted when the TNT token address is updated
    /// @param token The new TNT token address (or zero to disable)
    event TntTokenUpdated(address indexed token);

    /// @notice Emitted when the reward vaults address is updated
    /// @param vaults The new reward vaults address (or zero to disable)
    event RewardVaultsUpdated(address indexed vaults);

    /// @notice Emitted when default TNT minimum exposure is changed
    /// @param oldBps Previous exposure in basis points
    /// @param newBps New exposure in basis points
    event DefaultTntMinExposureBpsUpdated(uint16 oldBps, uint16 newBps);

    /// @notice Emitted when TNT payment discount is changed
    /// @param oldBps Previous discount in basis points
    /// @param newBps New discount in basis points
    event TntPaymentDiscountBpsUpdated(uint16 oldBps, uint16 newBps);

    /// @notice Emitted when the payment split configuration is updated
    /// @param developerBps Developer share in basis points
    /// @param protocolBps Protocol share in basis points
    /// @param operatorBps Operator share in basis points
    /// @param restakerBps Restaker share in basis points
    event PaymentSplitUpdated(uint16 developerBps, uint16 protocolBps, uint16 operatorBps, uint16 restakerBps);

    /// @notice Emitted when the protocol treasury address is updated
    /// @param treasury The new treasury address
    event TreasuryUpdated(address indexed treasury);

    /// @notice Emitted when minimum service TTL is updated
    /// @param oldTtl Previous minimum TTL
    /// @param newTtl New minimum TTL (0 means use protocol default)
    event MinServiceTtlUpdated(uint64 oldTtl, uint64 newTtl);

    /// @notice Emitted when maximum service TTL is updated
    /// @param oldTtl Previous maximum TTL
    /// @param newTtl New maximum TTL (0 means use protocol default)
    event MaxServiceTtlUpdated(uint64 oldTtl, uint64 newTtl);

    /// @notice Emitted when request expiry grace period is updated
    /// @param oldPeriod Previous grace period
    /// @param newPeriod New grace period (0 means use protocol default)
    event RequestExpiryGracePeriodUpdated(uint64 oldPeriod, uint64 newPeriod);

    /// @notice Emitted when maximum quote age is updated
    /// @param oldAge Previous maximum age
    /// @param newAge New maximum age (0 means use protocol default)
    event MaxQuoteAgeUpdated(uint64 oldAge, uint64 newAge);

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

        _maxBlueprintsPerOperator = ProtocolConfig.MAX_BLUEPRINTS_PER_OPERATOR;
        _defaultTntMinExposureBps = DEFAULT_TNT_MIN_EXPOSURE_BPS;
        _tntPaymentDiscountBps = 0;

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

    /// @notice Pause the contract, preventing most state-changing operations
    /// @dev Only callable by accounts with PAUSER_ROLE
    function pause() external onlyRole(PAUSER_ROLE) {
        _pause();
    }

    /// @notice Unpause the contract, allowing state-changing operations to resume
    /// @dev Only callable by accounts with PAUSER_ROLE
    function unpause() external onlyRole(PAUSER_ROLE) {
        _unpause();
    }

    /// @notice Authorize an upgrade to a new implementation
    /// @dev Required for UUPS pattern, only callable by UPGRADER_ROLE
    /// @param newImplementation Address of the new implementation (unused, just for interface)
    function _authorizeUpgrade(address newImplementation) internal override onlyRole(UPGRADER_ROLE) {}

    /// @notice Set the metrics recorder for incentive tracking
    /// @param recorder The metrics recorder address (set to address(0) to disable)
    function setMetricsRecorder(address recorder) external onlyRole(ADMIN_ROLE) {
        _metricsRecorder = recorder;
        emit MetricsRecorderUpdated(recorder);
    }

    /// @notice Get the metrics recorder address
    /// @return The configured metrics recorder address (or zero if disabled)
    function metricsRecorder() external view returns (address) {
        return _metricsRecorder;
    }

    /// @notice Set the operator status registry for heartbeat tracking
    /// @param registry The operator status registry address (set to address(0) to disable)
    function setOperatorStatusRegistry(address registry) external onlyRole(ADMIN_ROLE) {
        _operatorStatusRegistry = registry;
        emit OperatorStatusRegistryUpdated(registry);
    }

    /// @notice Get the operator status registry address
    /// @return The configured operator status registry address (or zero if disabled)
    function operatorStatusRegistry() external view returns (address) {
        return _operatorStatusRegistry;
    }

    /// @notice Configure the service-fee distributor for restaker payouts
    /// @dev This contract is expected to be called by `Payments` during fee distribution.
    /// @param distributor The service fee distributor address (set to address(0) to disable)
    function setServiceFeeDistributor(address distributor) external onlyRole(ADMIN_ROLE) {
        _serviceFeeDistributor = distributor;
        emit ServiceFeeDistributorUpdated(distributor);
    }

    /// @notice Get configured service-fee distributor
    /// @return The configured service fee distributor address (or zero if disabled)
    function serviceFeeDistributor() external view returns (address) {
        return _serviceFeeDistributor;
    }

    /// @notice Configure the price oracle used for USD-normalized scoring (optional)
    /// @param oracle The price oracle address (set to address(0) to disable)
    function setPriceOracle(address oracle) external onlyRole(ADMIN_ROLE) {
        _priceOracle = oracle;
        emit PriceOracleUpdated(oracle);
    }

    /// @notice Get configured price oracle
    /// @return The configured price oracle address (or zero if disabled)
    function priceOracle() external view returns (address) {
        return _priceOracle;
    }

    /// @notice Configure the Master Blueprint Service Manager registry
    /// @param registry The MBSM registry address (cannot be zero)
    function setMBSMRegistry(address registry) external onlyRole(ADMIN_ROLE) {
        if (registry == address(0)) revert Errors.ZeroAddress();
        _mbsmRegistry = IMBSMRegistry(registry);
        emit MBSMRegistryUpdated(registry);
    }

    /// @notice Get the configured Master Blueprint Service Manager registry
    /// @return The configured MBSM registry address
    function mbsmRegistry() external view returns (address) {
        return address(_mbsmRegistry);
    }

    /// @notice Get maximum registered blueprints allowed per operator
    /// @return The maximum number of blueprints per operator (0 means unlimited)
    function maxBlueprintsPerOperator() external view returns (uint32) {
        return _maxBlueprintsPerOperator;
    }

    /// @notice Update maximum blueprints per operator (0 disables the limit)
    /// @param newMax The new maximum number of blueprints per operator
    function setMaxBlueprintsPerOperator(uint32 newMax) external onlyRole(ADMIN_ROLE) {
        uint32 oldMax = _maxBlueprintsPerOperator;
        _maxBlueprintsPerOperator = newMax;
        emit MaxBlueprintsPerOperatorUpdated(oldMax, newMax);
    }

    /// @notice TNT token used for default security requirements + TNT restaker incentives
    /// @return The configured TNT token address (or zero if disabled)
    function tntToken() external view returns (address) {
        return _tntToken;
    }

    /// @notice Configure TNT token address (set to address(0) to disable TNT defaults)
    /// @param token The TNT token address
    function setTntToken(address token) external onlyRole(ADMIN_ROLE) {
        _tntToken = token;
        emit TntTokenUpdated(token);
    }

    /// @notice RewardVaults contract used to distribute TNT restaker rewards
    /// @return The configured reward vaults address (or zero if disabled)
    function rewardVaults() external view returns (address) {
        return _rewardVaults;
    }

    /// @notice Configure RewardVaults address (set to address(0) to disable TNT restaker payouts)
    /// @param vaults The reward vaults address
    function setRewardVaults(address vaults) external onlyRole(ADMIN_ROLE) {
        _rewardVaults = vaults;
        emit RewardVaultsUpdated(vaults);
    }

    /// @notice Default minimum TNT exposure (bps) required for all service requests
    /// @return The default minimum TNT exposure in basis points
    function defaultTntMinExposureBps() external view returns (uint16) {
        return _defaultTntMinExposureBps;
    }

    /// @notice Configure default minimum TNT exposure (bps) required for all service requests
    /// @param minExposureBps The minimum TNT exposure in basis points
    function setDefaultTntMinExposureBps(uint16 minExposureBps) external onlyRole(ADMIN_ROLE) {
        if (minExposureBps == 0 || minExposureBps > BPS_DENOMINATOR) revert Errors.InvalidSecurityRequirement();
        uint16 oldBps = _defaultTntMinExposureBps;
        _defaultTntMinExposureBps = minExposureBps;
        emit DefaultTntMinExposureBpsUpdated(oldBps, minExposureBps);
    }

    /// @notice Discount applied to service payments made in TNT (bps of the payment amount; capped to protocol share)
    /// @return The discount in basis points applied to TNT payments
    function tntPaymentDiscountBps() external view returns (uint16) {
        return _tntPaymentDiscountBps;
    }

    /// @notice Configure discount applied to service payments made in TNT (bps of the payment amount; capped to protocol share)
    /// @param discountBps The discount in basis points
    function setTntPaymentDiscountBps(uint16 discountBps) external onlyRole(ADMIN_ROLE) {
        if (discountBps > BPS_DENOMINATOR) revert Errors.InvalidState();
        uint16 oldBps = _tntPaymentDiscountBps;
        _tntPaymentDiscountBps = discountBps;
        emit TntPaymentDiscountBpsUpdated(oldBps, discountBps);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SERVICE REQUEST TTL CONFIGURATION (M-1 fix)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Configure minimum TTL for service requests (0 = use protocol default)
    /// @param minTtl The new minimum TTL value
    function setMinServiceTtl(uint64 minTtl) external onlyRole(ADMIN_ROLE) {
        uint64 oldTtl = _minServiceTtl;
        _minServiceTtl = minTtl;
        emit MinServiceTtlUpdated(oldTtl, minTtl);
    }

    /// @notice Configure maximum TTL for service requests (0 = use protocol default)
    /// @param maxTtl The new maximum TTL value
    function setMaxServiceTtl(uint64 maxTtl) external onlyRole(ADMIN_ROLE) {
        uint64 oldTtl = _maxServiceTtl;
        _maxServiceTtl = maxTtl;
        emit MaxServiceTtlUpdated(oldTtl, maxTtl);
    }

    /// @notice Configure request expiry grace period (0 = use protocol default)
    /// @param gracePeriod The new grace period value
    function setRequestExpiryGracePeriod(uint64 gracePeriod) external onlyRole(ADMIN_ROLE) {
        uint64 oldPeriod = _requestExpiryGracePeriod;
        _requestExpiryGracePeriod = gracePeriod;
        emit RequestExpiryGracePeriodUpdated(oldPeriod, gracePeriod);
    }

    /// @notice Get request expiry grace period
    /// @return The grace period in seconds (uses protocol default if not configured)
    function requestExpiryGracePeriod() external view returns (uint64) {
        return _requestExpiryGracePeriod > 0 ? _requestExpiryGracePeriod : ProtocolConfig.REQUEST_EXPIRY_GRACE_PERIOD;
    }

    /// @notice Configure maximum quote age (0 = use protocol default)
    /// @param maxAge The new maximum quote age value
    function setMaxQuoteAge(uint64 maxAge) external onlyRole(ADMIN_ROLE) {
        uint64 oldAge = _maxQuoteAge;
        _maxQuoteAge = maxAge;
        emit MaxQuoteAgeUpdated(oldAge, maxAge);
    }

    /// @notice Get maximum quote age
    /// @return The maximum quote age in seconds (uses protocol default if not configured)
    function maxQuoteAge() external view returns (uint64) {
        return _maxQuoteAge > 0 ? _maxQuoteAge : ProtocolConfig.MAX_QUOTE_AGE;
    }

    /// @notice Get stored security requirements for a service request
    /// @param requestId The request ID to query
    /// @return requirements The array of security requirements for the request
    function getServiceRequestSecurityRequirements(uint64 requestId)
        external
        view
        returns (Types.AssetSecurityRequirement[] memory requirements)
    {
        Types.AssetSecurityRequirement[] storage stored = _requestSecurityRequirements[requestId];
        requirements = new Types.AssetSecurityRequirement[](stored.length);
        for (uint256 i = 0; i < stored.length; i++) {
            requirements[i] = stored[i];
        }
    }

    /// @notice Get stored security commitments for a service request by operator
    /// @param requestId The request ID to query
    /// @param operator The operator address to query
    /// @return commitments The array of security commitments for the operator
    function getServiceRequestSecurityCommitments(uint64 requestId, address operator)
        external
        view
        returns (Types.AssetSecurityCommitment[] memory commitments)
    {
        Types.AssetSecurityCommitment[] storage stored = _requestSecurityCommitments[requestId][operator];
        commitments = new Types.AssetSecurityCommitment[](stored.length);
        for (uint256 i = 0; i < stored.length; i++) {
            commitments[i] = stored[i];
        }
    }

    /// @notice Get stored security requirements for an active service
    /// @param serviceId The service ID to query
    /// @return requirements The array of security requirements for the service
    function getServiceSecurityRequirements(uint64 serviceId)
        external
        view
        returns (Types.AssetSecurityRequirement[] memory requirements)
    {
        Types.AssetSecurityRequirement[] storage stored = _serviceSecurityRequirements[serviceId];
        requirements = new Types.AssetSecurityRequirement[](stored.length);
        for (uint256 i = 0; i < stored.length; i++) {
            requirements[i] = stored[i];
        }
    }

    /// @notice Get stored security commitments for an active service by operator
    /// @param serviceId The service ID to query
    /// @param operator The operator address to query
    /// @return commitments The array of security commitments for the operator
    function getServiceSecurityCommitments(uint64 serviceId, address operator)
        external
        view
        returns (Types.AssetSecurityCommitment[] memory commitments)
    {
        Types.AssetSecurityCommitment[] storage stored = _serviceSecurityCommitments[serviceId][operator];
        commitments = new Types.AssetSecurityCommitment[](stored.length);
        for (uint256 i = 0; i < stored.length; i++) {
            commitments[i] = stored[i];
        }
    }

    /// @notice Get committed exposure bps for an operator's asset on a service (0 if unset)
    function getServiceSecurityCommitmentBps(
        uint64 serviceId,
        address operator,
        Types.AssetKind kind,
        address token
    ) external view returns (uint16) {
        // forge-lint: disable-next-line(asm-keccak256)
        bytes32 assetHash = keccak256(abi.encode(kind, token));
        return _serviceSecurityCommitmentBps[serviceId][operator][assetHash];
    }

    /// @notice Get number of blueprints registered by an operator
    /// @param operator The operator address to query
    /// @return The number of blueprints the operator is registered for
    function operatorBlueprintCount(address operator) external view returns (uint32) {
        return _operatorBlueprintCounts[operator];
    }

    /// @notice Get stored blueprint metadata
    /// @param blueprintId The blueprint ID to query
    /// @return metadata The blueprint's rich metadata
    /// @return metadataUri The blueprint's metadata URI
    function blueprintMetadata(uint64 blueprintId)
        external
        view
        returns (Types.BlueprintMetadata memory metadata, string memory metadataUri)
    {
        metadata = _blueprintMetadata[blueprintId];
        metadataUri = _blueprintMetadataUri[blueprintId];
    }

    /// @notice Get stored blueprint sources
    /// @param blueprintId The blueprint ID to query
    /// @return sources The array of implementation sources for the blueprint
    function blueprintSources(uint64 blueprintId) external view returns (Types.BlueprintSource[] memory sources) {
        Types.BlueprintSource[] storage stored = _blueprintSources[blueprintId];
        sources = new Types.BlueprintSource[](stored.length);
        for (uint256 i = 0; i < stored.length; ++i) {
            sources[i] = stored[i];
        }
    }

    /// @notice Get supported membership models for a blueprint
    /// @param blueprintId The blueprint ID to query
    /// @return memberships The array of supported membership models
    function blueprintSupportedMemberships(uint64 blueprintId)
        external
        view
        returns (Types.MembershipModel[] memory memberships)
    {
        Types.MembershipModel[] storage stored = _blueprintSupportedMemberships[blueprintId];
        memberships = new Types.MembershipModel[](stored.length);
        for (uint256 i = 0; i < stored.length; ++i) {
            memberships[i] = stored[i];
        }
    }

    /// @notice Get the pinned master blueprint service manager revision for a blueprint
    /// @param blueprintId The blueprint ID to query
    /// @return The MBSM revision pinned for this blueprint
    function blueprintMasterRevision(uint64 blueprintId) external view returns (uint32) {
        return _blueprintMasterRevisions[blueprintId];
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

    /// @notice Get total number of blueprints created
    /// @return The total blueprint count (also used as next blueprint ID)
    function blueprintCount() external view returns (uint64) { return _blueprintCount; }

    /// @notice Get total number of services created
    /// @return The total service count (also used as next service ID)
    function serviceCount() external view returns (uint64) { return _serviceCount; }

    /// @notice Get total number of service requests created
    /// @return The total service request count (also used as next request ID)
    function serviceRequestCount() external view returns (uint64) { return _serviceRequestCount; }

    /// @notice Get blueprint details by ID
    /// @param id The blueprint ID to query
    /// @return The blueprint's core details
    function getBlueprint(uint64 id) external view returns (Types.Blueprint memory) {
        return _blueprints[id];
    }

    /// @notice Get blueprint configuration by ID
    /// @param id The blueprint ID to query
    /// @return The blueprint's operational configuration
    function getBlueprintConfig(uint64 id) external view returns (Types.BlueprintConfig memory) {
        return _blueprintConfigs[id];
    }

    /// @notice Get service request details by ID
    /// @param id The service request ID to query
    /// @return The service request details
    function getServiceRequest(uint64 id) external view returns (Types.ServiceRequest memory) {
        return _serviceRequests[id];
    }

    /// @notice Get service details by ID
    /// @param id The service ID to query
    /// @return The service details
    function getService(uint64 id) external view returns (Types.Service memory) {
        return _services[id];
    }

    /// @notice Get operator's data for a specific service
    /// @param serviceId The service ID to query
    /// @param op The operator address
    /// @return The operator's service-specific data
    function getServiceOperator(uint64 serviceId, address op) external view returns (Types.ServiceOperator memory) {
        return _serviceOperators[serviceId][op];
    }

    /// @notice Get all operator addresses for a service
    /// @param serviceId The service ID to query
    /// @return The array of operator addresses assigned to the service
    function getServiceOperators(uint64 serviceId) external view returns (address[] memory) {
        return _serviceOperatorSet[serviceId].values();
    }

    /// @notice Get job call details
    /// @param serviceId The service ID
    /// @param callId The job call ID within the service
    /// @return The job call details
    function getJobCall(uint64 serviceId, uint64 callId) external view returns (Types.JobCall memory) {
        return _jobCalls[serviceId][callId];
    }

    /// @notice Get operator's registration data for a blueprint
    /// @param blueprintId The blueprint ID
    /// @param op The operator address
    /// @return The operator's registration data
    function getOperatorRegistration(uint64 blueprintId, address op) external view returns (Types.OperatorRegistration memory) {
        return _operatorRegistrations[blueprintId][op];
    }

    /// @notice Check if operator is registered for a blueprint
    /// @param blueprintId The blueprint ID
    /// @param op The operator address
    /// @return True if the operator is registered, false otherwise
    function isOperatorRegistered(uint64 blueprintId, address op) external view returns (bool) {
        return _operatorRegistrations[blueprintId][op].registeredAt != 0;
    }

    /// @notice Get operator preferences for a blueprint (includes ECDSA public key)
    /// @param blueprintId The blueprint ID
    /// @param op The operator address
    /// @return The operator's preferences including BLS and ECDSA keys
    function getOperatorPreferences(uint64 blueprintId, address op) external view returns (Types.OperatorPreferences memory) {
        return _operatorPreferences[blueprintId][op];
    }

    /// @notice Get operator's ECDSA public key for gossip network identity
    /// @dev Returns the key used for signing/verifying gossip messages
    /// @param blueprintId The blueprint ID
    /// @param op The operator address
    /// @return The operator's ECDSA public key bytes
    function getOperatorPublicKey(uint64 blueprintId, address op) external view returns (bytes memory) {
        return _operatorPreferences[blueprintId][op].ecdsaPublicKey;
    }

    /// @notice Check if a service is currently active
    /// @param serviceId The service ID to check
    /// @return True if the service is active, false otherwise
    function isServiceActive(uint64 serviceId) external view returns (bool) {
        return _services[serviceId].status == Types.ServiceStatus.Active;
    }

    /// @notice Check if an operator is active in a service
    /// @param serviceId The service ID
    /// @param op The operator address
    /// @return True if the operator is active in the service, false otherwise
    function isServiceOperator(uint64 serviceId, address op) external view returns (bool) {
        return _serviceOperators[serviceId][op].active;
    }

    /// @notice Check if an address is a permitted caller for a service
    /// @param serviceId The service ID
    /// @param caller The address to check
    /// @return True if the address can submit jobs, false otherwise
    function isPermittedCaller(uint64 serviceId, address caller) external view returns (bool) {
        return _permittedCallers[serviceId].contains(caller);
    }

    /// @notice Get the number of operators registered for a blueprint
    /// @param blueprintId The blueprint ID
    /// @return The count of registered operators
    function blueprintOperatorCount(uint64 blueprintId) external view returns (uint256) {
        return _blueprintOperators[blueprintId].length();
    }

    /// @notice Accept native token
    receive() external payable {}
}
