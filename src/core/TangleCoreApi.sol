// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Base } from "./Base.sol";
import { Types } from "../libraries/Types.sol";
import { Errors } from "../libraries/Errors.sol";
import { IMBSMRegistry } from "../interfaces/IMBSMRegistry.sol";
import { ProtocolConfig } from "../config/ProtocolConfig.sol";
import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

/// @title TangleCoreApi
/// @notice External admin + view API served directly by the Tangle router.
/// @dev Split out of Base so protocol facets — which need only Base's storage layout,
///      modifiers, shared events and internal helpers — do not compile these
///      router-only functions into their runtime bytecode. The router inherits this
///      mixin, so its callable surface is unchanged; facets inherit Base directly.
abstract contract TangleCoreApi is Base {
    using EnumerableSet for EnumerableSet.AddressSet;

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

    /// @notice Set the metrics recorder for incentive tracking
    /// @param recorder The metrics recorder address (set to address(0) to disable)
    function setMetricsRecorder(address recorder) external onlyRole(ADMIN_ROLE) whenNotPaused {
        _metricsRecorder = recorder;
        emit MetricsRecorderUpdated(recorder);
    }

    /// @notice Get the metrics recorder address
    /// @return The configured metrics recorder address (or zero if disabled)
    function metricsRecorder() external view returns (address) {
        return _metricsRecorder;
    }

    /// @notice Set the per-deployment blueprint-manager hook gas budget.
    /// @dev Zero resets to the 500k default. Raise only on chains that meter SSTORE far
    ///      above mainnet (e.g. Tempo) so a real BSM setup hook clears; still a hard per-hook
    ///      DoS bound. Ceiling caps how loose it can be set.
    /// @param limit New per-hook gas budget (0 = default 500k)
    function setManagerHookGasLimit(uint256 limit) external onlyRole(ADMIN_ROLE) whenNotPaused {
        if (limit > 8_000_000) revert Errors.InvalidState();
        _managerHookGasLimit = limit;
        emit ManagerHookGasLimitUpdated(limit);
    }

    /// @notice The effective blueprint-manager hook gas budget (override, or 500k default).
    function managerHookGasLimit() external view returns (uint256) {
        return _hookGasLimit();
    }

    /// @notice Set the operator status registry for heartbeat tracking
    /// @param registry The operator status registry address (set to address(0) to disable)
    function setOperatorStatusRegistry(address registry) external onlyRole(ADMIN_ROLE) whenNotPaused {
        _operatorStatusRegistry = registry;
        emit OperatorStatusRegistryUpdated(registry);
    }

    /// @notice Get the operator status registry address
    /// @return The configured operator status registry address (or zero if disabled)
    function operatorStatusRegistry() external view returns (address) {
        return _operatorStatusRegistry;
    }

    /// @notice Configure the service-fee distributor for staker payouts
    /// @dev This contract is expected to be called by `Payments` during fee distribution.
    /// @param distributor The service fee distributor address (set to address(0) to disable)
    function setServiceFeeDistributor(address distributor) external onlyRole(ADMIN_ROLE) whenNotPaused {
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
    function setPriceOracle(address oracle) external onlyRole(ADMIN_ROLE) whenNotPaused {
        _priceOracle = oracle;
        emit PriceOracleUpdated(oracle);
    }

    /// @notice Raise or lower the per-service operator ceiling.
    /// @dev Bounds every per-operator loop in the billing / distribute / terminate
    ///      paths. Zero is rejected; very large values let admins tune the upper
    ///      bound for high-fanout services but increase worst-case bill gas.
    function setMaxOperatorsPerService(uint32 cap) external onlyRole(ADMIN_ROLE) whenNotPaused {
        if (cap == 0) revert Errors.InvalidState();
        _maxOperatorsPerService = cap;
        emit MaxOperatorsPerServiceUpdated(cap);
    }

    /// @notice Get the current per-service operator ceiling.
    function maxOperatorsPerService() external view returns (uint32) {
        return _maxOperatorsPerService;
    }

    /// @notice Get configured price oracle
    /// @return The configured price oracle address (or zero if disabled)
    function priceOracle() external view returns (address) {
        return _priceOracle;
    }

    /// @notice Configure the Master Blueprint Service Manager registry
    /// @param registry The MBSM registry address (cannot be zero)
    function setMBSMRegistry(address registry) external onlyRole(ADMIN_ROLE) whenNotPaused {
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
    function setMaxBlueprintsPerOperator(uint32 newMax) external onlyRole(ADMIN_ROLE) whenNotPaused {
        uint32 oldMax = _maxBlueprintsPerOperator;
        _maxBlueprintsPerOperator = newMax;
        emit MaxBlueprintsPerOperatorUpdated(oldMax, newMax);
    }

    /// @notice TNT token used for default security requirements + TNT staker incentives
    /// @return The configured TNT token address (or zero if disabled)
    function tntToken() external view returns (address) {
        return _tntToken;
    }

    /// @notice Configure TNT token address (set to address(0) to disable TNT defaults)
    /// @param token The TNT token address
    function setTntToken(address token) external onlyRole(ADMIN_ROLE) whenNotPaused {
        _tntToken = token;
        emit TntTokenUpdated(token);
    }

    /// @notice RewardVaults contract used to distribute TNT staker rewards
    /// @return The configured reward vaults address (or zero if disabled)
    function rewardVaults() external view returns (address) {
        return _rewardVaults;
    }

    /// @notice Configure RewardVaults address (set to address(0) to disable TNT staker payouts)
    /// @param vaults The reward vaults address
    function setRewardVaults(address vaults) external onlyRole(ADMIN_ROLE) whenNotPaused {
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
    function setDefaultTntMinExposureBps(uint16 minExposureBps) external onlyRole(ADMIN_ROLE) whenNotPaused {
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

    /// @notice Configure discount applied to service payments made in TNT (bps of the payment amount; capped to
    /// protocol share) @param discountBps The discount in basis points
    function setTntPaymentDiscountBps(uint16 discountBps) external onlyRole(ADMIN_ROLE) whenNotPaused {
        if (discountBps > BPS_DENOMINATOR) revert Errors.InvalidState();
        uint16 oldBps = _tntPaymentDiscountBps;
        _tntPaymentDiscountBps = discountBps;
        emit TntPaymentDiscountBpsUpdated(oldBps, discountBps);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SERVICE REQUEST TTL CONFIGURATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Configure minimum TTL for service requests (0 = use protocol default)
    /// @param minTtl The new minimum TTL value
    function setMinServiceTtl(uint64 minTtl) external onlyRole(ADMIN_ROLE) whenNotPaused {
        uint64 oldTtl = _minServiceTtl;
        _minServiceTtl = minTtl;
        emit MinServiceTtlUpdated(oldTtl, minTtl);
    }

    /// @notice Configure maximum TTL for service requests (0 = use protocol default)
    /// @param maxTtl The new maximum TTL value
    function setMaxServiceTtl(uint64 maxTtl) external onlyRole(ADMIN_ROLE) whenNotPaused {
        uint64 oldTtl = _maxServiceTtl;
        _maxServiceTtl = maxTtl;
        emit MaxServiceTtlUpdated(oldTtl, maxTtl);
    }

    /// @notice Configure request expiry grace period (0 = use protocol default)
    /// @param gracePeriod The new grace period value
    function setRequestExpiryGracePeriod(uint64 gracePeriod) external onlyRole(ADMIN_ROLE) whenNotPaused {
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
    function setMaxQuoteAge(uint64 maxAge) external onlyRole(ADMIN_ROLE) whenNotPaused {
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
    function getServiceRequestSecurityCommitments(
        uint64 requestId,
        address operator
    )
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
    function getServiceSecurityCommitments(
        uint64 serviceId,
        address operator
    )
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
    )
        external
        view
        returns (uint16)
    {
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

    // ═══════════════════════════════════════════════════════════════════════════
    // VIEW FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Get total number of services created
    /// @return The total service count (also used as next service ID)
    function serviceCount() external view returns (uint64) {
        return _serviceCount;
    }

    /// @notice Get total number of service requests created
    /// @return The total service request count (also used as next request ID)
    function serviceRequestCount() external view returns (uint64) {
        return _serviceRequestCount;
    }

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

    /// @notice Get a service's per-job settlement asset (EventDriven pricing).
    /// @dev Returns the token every per-job bill for this service is collected and
    ///      distributed in: `address(0)` for native, or the ERC20 the blueprint DEVELOPER
    ///      declared (`setBlueprintSettlementAsset`) and the service pinned at activation.
    ///      The customer does NOT choose this asset. Drivers read this to decide whether
    ///      to send native `msg.value` or to `approve` the Tangle and submit with value 0.
    ///      For non-EventDriven services (or an unknown id) this returns `address(0)`,
    ///      which is the native sentinel and does not imply the service settles per-job.
    ///      NOTE: the per-job rate (`getJobEventRate`) is denominated in THIS asset's
    ///      smallest unit — a service settling in a 6-decimal token (e.g. Tempo PathUSD)
    ///      must have its rate set in 6-dec units, not 18.
    /// @param serviceId The service ID to query
    /// @return The settlement asset address (`address(0)` = native)
    function getServicePaymentAsset(uint64 serviceId) external view returns (address) {
        return _serviceEventDrivenAsset[serviceId];
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
    function getOperatorRegistration(
        uint64 blueprintId,
        address op
    )
        external
        view
        returns (Types.OperatorRegistration memory)
    {
        return _operatorRegistrations[blueprintId][op];
    }

    /// @notice Check if operator is registered for a blueprint
    /// @param blueprintId The blueprint ID
    /// @param op The operator address
    /// @return True if the operator is registered, false otherwise
    function isOperatorRegistered(uint64 blueprintId, address op) external view returns (bool) {
        return _operatorRegistrations[blueprintId][op].registeredAt != 0;
    }

    /// @notice Get operator preferences for a blueprint (ECDSA public key)
    /// @dev The returned rpcAddress is always empty: it is not persisted on-chain. Read the
    ///      operator's RPC endpoint from OperatorRegistered / OperatorPreferencesUpdated events.
    /// @param blueprintId The blueprint ID
    /// @param op The operator address
    /// @return The operator's preferences (ecdsaPublicKey populated; rpcAddress empty)
    function getOperatorPreferences(
        uint64 blueprintId,
        address op
    )
        external
        view
        returns (Types.OperatorPreferences memory)
    {
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
    receive() external payable { }
}
