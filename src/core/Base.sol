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
import { IStaking } from "../interfaces/IStaking.sol";
import { IBlueprintServiceManager } from "../interfaces/IBlueprintServiceManager.sol";
import { IMetricsRecorder } from "../interfaces/IMetricsRecorder.sol";
import { IOperatorStatusRegistry } from "../staking/OperatorStatusRegistry.sol";
import { IPriceOracle } from "../oracles/interfaces/IPriceOracle.sol";
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
    /// @param confidentiality The effective execution confidentiality for the service
    event ServiceActivated(
        uint64 indexed serviceId,
        uint64 indexed requestId,
        uint64 indexed blueprintId,
        Types.ConfidentialityPolicy confidentiality
    );

    /// @notice Emitted when the MBSM registry is updated
    /// @param registry The new registry address
    event MBSMRegistryUpdated(address indexed registry);

    /// @notice Emitted when an operator commits per-asset resources to a service (request, quote,
    ///         or extension). Declared once here and shared by the services/quotes mixins.
    event ResourcesCommitted(
        uint64 indexed serviceId, address indexed operator, Types.ResourceCommitment[] commitments
    );

    /// @notice Emitted when a best-effort blueprint-manager hook reverted or ran out of
    ///         the capped gas stipend. Observable so off-chain monitors can detect a
    ///         misbehaving BSM without halting the protocol path.
    event ManagerHookFailed(address indexed manager, bytes4 indexed selector, bytes returnData);

    /// @notice Emitted when a price-oracle query reverted on the billing hot path and
    ///         the protocol fell back to raw token-second weighting. The bill still
    ///         completes; off-chain monitors should investigate the oracle health.
    event PriceOracleFallback(address indexed oracle, address indexed token, bytes returnData);

    /// @notice Emitted when the metrics recorder is updated
    /// @param recorder The new recorder address (or zero to disable)
    event MetricsRecorderUpdated(address indexed recorder);

    /// @notice Emitted when the per-deployment manager-hook gas budget is changed.
    event ManagerHookGasLimitUpdated(uint256 limit);

    /// @notice Emitted when the operator status registry is updated
    /// @param registry The new registry address (or zero to disable)
    event OperatorStatusRegistryUpdated(address indexed registry);

    /// @notice Emitted when the service fee distributor is updated
    /// @param distributor The new distributor address (or zero to disable)
    event ServiceFeeDistributorUpdated(address indexed distributor);

    /// @notice Emitted when the price oracle is updated
    /// @param oracle The new oracle address (or zero to disable)
    event PriceOracleUpdated(address indexed oracle);

    /// @notice Emitted when the per-service operator ceiling is changed by governance.
    event MaxOperatorsPerServiceUpdated(uint32 newCap);

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
    /// @param stakerBps Staker share in basis points
    event PaymentSplitUpdated(
        uint16 developerBps, uint16 protocolBps, uint16 operatorBps, uint16 stakerBps, uint16 keeperBps
    );

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
    /// @param staking_ Staking module address
    /// @param treasury_ Protocol treasury address
    /// @dev H-5 SECURITY: After deployment, DEFAULT_ADMIN_ROLE should be transferred to a
    ///      TangleTimelock contract to enforce governance delays on critical admin operations.
    ///      Failure to do so leaves the protocol vulnerable to instant malicious admin actions.
    // forge-lint: disable-next-line(mixed-case-function)
    function __Base_init(address admin, address staking_, address payable treasury_) internal onlyInitializing {
        if (admin == address(0) || staking_ == address(0) || treasury_ == address(0)) {
            revert Errors.ZeroAddress();
        }

        __UUPSUpgradeable_init();
        __Pausable_init();
        __ReentrancyGuard_init();
        __AccessControl_init();

        // H-5 WARNING: Transfer DEFAULT_ADMIN_ROLE to TangleTimelock post-deployment
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ADMIN_ROLE, admin);
        _grantRole(PAUSER_ROLE, admin);
        _grantRole(UPGRADER_ROLE, admin);
        _grantRole(SLASH_ADMIN_ROLE, admin);

        _staking = IStaking(staking_);
        _treasury = treasury_;

        _maxBlueprintsPerOperator = ProtocolConfig.MAX_BLUEPRINTS_PER_OPERATOR;
        _maxOperatorsPerService = ProtocolConfig.DEFAULT_MAX_OPERATORS_PER_SERVICE;
        _defaultTntMinExposureBps = DEFAULT_TNT_MIN_EXPOSURE_BPS;
        _tntPaymentDiscountBps = 0;

        // Initialize payment split
        _paymentSplit = Types.PaymentSplit({
            developerBps: DEFAULT_DEVELOPER_BPS,
            protocolBps: DEFAULT_PROTOCOL_BPS,
            operatorBps: DEFAULT_OPERATOR_BPS,
            stakerBps: DEFAULT_STAKER_BPS,
            keeperBps: DEFAULT_KEEPER_BPS
        });

        // Domain separator is computed on-the-fly from `block.chainid` (see
        // `_domainSeparatorView`) so a post-fork chainid mismatch invalidates quotes
        // signed under the old chain id automatically. We keep the storage slot
        // populated as a snapshot for off-chain indexers but never read it on-chain.
        _domainSeparator = SignatureLib.computeDomainSeparator("TangleQuote", "1", address(this));

        // Initialize slashing config
        SlashingLib.initializeConfig(_slashState);
    }

    /// @notice Compute the EIP-712 domain separator at the *current* chainid. Used by all
    ///         on-chain quote / signature verification so a chain fork or upgrade does not
    ///         allow replays signed under a different chainid.
    function _domainSeparatorView() internal view returns (bytes32) {
        return SignatureLib.computeDomainSeparator("TangleQuote", "1", address(this));
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // ADMIN
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Authorize an upgrade to a new implementation
    /// @dev Required for UUPS pattern, only callable by UPGRADER_ROLE
    /// @param newImplementation Address of the new implementation (unused, just for interface)
    function _authorizeUpgrade(address newImplementation) internal override onlyRole(UPGRADER_ROLE) { }

    /// @notice Resolve the asset used for TWAP-fair subscription billing.
    /// @dev Bond asset (TNT) when configured, otherwise native. Matches the asset
    ///      `IStaking.getOperatorStake` aggregates over. Defined here so both the
    ///      service-lifecycle join hook and `Payments._computeTwapBillAmount`
    ///      converge on the exact same asset.
    function _bondAssetForBilling() internal view returns (Types.Asset memory asset) {
        address bond = _tntToken;
        if (bond == address(0)) {
            return Types.Asset({ kind: Types.AssetKind.Native, token: address(0) });
        }
        return Types.Asset({ kind: Types.AssetKind.ERC20, token: bond });
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // METRICS HOOKS (lightweight, fail-safe)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Record a service creation event
    function _recordServiceCreated(
        uint64 serviceId,
        uint64 blueprintId,
        address owner,
        uint256 operatorCount
    )
        internal
    {
        if (_metricsRecorder != address(0)) {
            try IMetricsRecorder(_metricsRecorder)
                .recordServiceCreated(serviceId, blueprintId, owner, operatorCount) { }
                catch { }
        }
    }

    /// @notice Record a job call event
    function _recordJobCall(uint64 serviceId, address caller, uint64 jobCallId) internal {
        if (_metricsRecorder != address(0)) {
            try IMetricsRecorder(_metricsRecorder).recordJobCall(serviceId, caller, jobCallId) { } catch { }
        }
    }

    /// @notice Record a job completion event
    function _recordJobCompletion(address operator, uint64 serviceId, uint64 jobCallId, bool success) internal {
        if (_metricsRecorder != address(0)) {
            try IMetricsRecorder(_metricsRecorder).recordJobCompletion(operator, serviceId, jobCallId, success) { }
                catch { }
        }
    }

    /// @notice Record a payment event
    function _recordPayment(address payer, uint64 serviceId, address token, uint256 amount) internal {
        if (_metricsRecorder != address(0)) {
            try IMetricsRecorder(_metricsRecorder).recordPayment(payer, serviceId, token, amount) { } catch { }
        }
    }

    /// @notice Record a blueprint creation event
    function _recordBlueprintCreated(uint64 blueprintId, address developer) internal {
        if (_metricsRecorder != address(0)) {
            try IMetricsRecorder(_metricsRecorder).recordBlueprintCreated(blueprintId, developer) { } catch { }
        }
    }

    /// @notice Record a blueprint registration event
    function _recordBlueprintRegistration(uint64 blueprintId, address operator) internal {
        if (_metricsRecorder != address(0)) {
            try IMetricsRecorder(_metricsRecorder).recordBlueprintRegistration(blueprintId, operator) { } catch { }
        }
    }

    /// @notice Record a slash event
    function _recordSlash(address operator, uint64 serviceId, uint256 amount) internal {
        if (_metricsRecorder != address(0)) {
            try IMetricsRecorder(_metricsRecorder).recordSlash(operator, serviceId, amount) { } catch { }
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // HEARTBEAT HOOKS (lightweight, fail-safe)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Configure heartbeat settings and register operators for a service
    /// @dev Called during service activation to set up liveness tracking.
    ///      Registers the service owner, selected operators, and heartbeat config.
    /// @param serviceId The service ID
    /// @param manager The blueprint's service manager address
    /// @param owner The service owner address
    /// @param operators The operators selected for this service instance
    function _configureHeartbeat(
        uint64 serviceId,
        address manager,
        address owner,
        address[] memory operators
    )
        internal
    {
        if (_operatorStatusRegistry == address(0)) return;

        // Get heartbeat interval from BSM (use default if not implemented or returns useDefault=true)
        uint64 interval = 0; // 0 means use registry default
        uint8 maxMissed = 0; // 0 means use registry default

        if (manager != address(0)) {
            (bool okInt, bytes memory retInt) = _tryStaticcallManager(
                manager, abi.encodeWithSelector(IBlueprintServiceManager.getHeartbeatInterval.selector, serviceId), 64
            );
            if (okInt) {
                (bool useDefault, uint64 customInterval) = abi.decode(retInt, (bool, uint64));
                if (!useDefault && customInterval > 0) interval = customInterval;
            }

            (bool okThr, bytes memory retThr) = _tryStaticcallManager(
                manager, abi.encodeWithSelector(IBlueprintServiceManager.getHeartbeatThreshold.selector, serviceId), 64
            );
            if (okThr) {
                (bool useDefault, uint8 threshold) = abi.decode(retThr, (bool, uint8));
                if (!useDefault && threshold > 0) {
                    // threshold is a percentage; mapped to max-missed beats inversely
                    // (90% ≈ 1 missed, 50% ≈ 3 missed).
                    maxMissed = threshold > 80 ? 1 : (threshold > 50 ? 2 : 3);
                }
            }
        }

        // Register service owner and configure heartbeat
        try IOperatorStatusRegistry(_operatorStatusRegistry).registerServiceOwner(serviceId, owner) { } catch { }

        // Register each selected operator for this service instance
        for (uint256 i = 0; i < operators.length; i++) {
            try IOperatorStatusRegistry(_operatorStatusRegistry).registerOperator(serviceId, operators[i]) { } catch { }
        }

        // Configure heartbeat if custom values provided
        if (interval > 0 || maxMissed > 0) {
            // Use defaults for unspecified values
            if (interval == 0) interval = 300; // 5 minutes default
            if (maxMissed == 0) maxMissed = 3;

            try IOperatorStatusRegistry(_operatorStatusRegistry).configureHeartbeat(serviceId, interval, maxMissed) { }
                catch { }
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // INTERNAL GETTERS
    // ═══════════════════════════════════════════════════════════════════════════

    function _getBlueprint(uint64 id) internal view returns (Types.Blueprint storage) {
        if (id >= _blueprintCount) revert Errors.BlueprintNotFound(id);
        return _blueprints[id];
    }

    /// @dev Validate a blueprint's binary sources: at least one source, each with
    ///      at least one binary, every binary carrying a non-zero sha256. Shared by
    ///      createBlueprint and setBlueprintSources so both enforce the same shape.
    function _validateBlueprintSources(Types.BlueprintSource[] calldata sources) internal pure {
        if (sources.length == 0) revert Errors.BlueprintSourcesRequired();
        for (uint256 i = 0; i < sources.length; ++i) {
            Types.BlueprintSource calldata source = sources[i];
            if (source.binaries.length == 0) revert Errors.BlueprintBinaryRequired();
            for (uint256 j = 0; j < source.binaries.length; ++j) {
                if (source.binaries[j].sha256 == bytes32(0)) {
                    revert Errors.BlueprintBinaryHashRequired();
                }
            }
        }
    }

    /// @notice Emitted on blueprint creation and every source repoint, carrying the FULL source set.
    /// @dev Sources are NOT stored on-chain (only `_blueprintSourcesHash` anchors them); the cold-start
    ///      manager reconstructs them from this event via the indexer. A repoint re-fires the whole
    ///      array (not a delta) so event-sourced copies always converge on the latest set.
    event BlueprintSourcesRecorded(
        uint64 indexed blueprintId, bytes32 indexed sourcesHash, Types.BlueprintSource[] sources
    );

    /// @dev Anchor a blueprint's sources by hash and emit the full payload. No on-chain array is kept:
    ///      the cold-start manager resolves operator binaries from the BlueprintSourcesRecorded event
    ///      (via the indexer), and `_blueprintSourcesHash` remains the on-chain anchor that operators
    ///      ack against (a repoint changes the hash, invalidating stale acks). calldata-encoded so the
    ///      digest is deterministic and cheap to recompute off-chain. Shared by createBlueprint (genesis)
    ///      and setBlueprintSources (owner repoint). Callers must validate via {_validateBlueprintSources}.
    function _writeBlueprintSources(uint64 blueprintId, Types.BlueprintSource[] calldata sources) internal {
        bytes32 sourcesHash = keccak256(abi.encode(sources));
        _blueprintSourcesHash[blueprintId] = sourcesHash;
        emit BlueprintSourcesRecorded(blueprintId, sourcesHash, sources);
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
    // WARNING: Blueprint managers are trusted contracts. A malicious manager
    // can manipulate state during callbacks. Only register audited managers.
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Query whether a manager allows a payment asset in a specific context.
    /// @dev Strict behavior (fail-closed):
    ///      - `contextId` is authoritative when implemented by the manager.
    ///      - No legacy `0` override when a nonzero context is denied.
    ///      - Missing/reverting hooks deny by default.
    function _isPaymentAssetAllowedByManager(
        address manager,
        uint64 contextId,
        address asset
    )
        internal
        view
        returns (bool)
    {
        if (manager == address(0)) return true;

        (bool hasContextResult, bool contextAllowed) = _tryQueryPaymentAssetAllowed(manager, contextId, asset);
        if (hasContextResult) return contextAllowed;
        return false;
    }

    function _tryQueryPaymentAssetAllowed(
        address manager,
        uint64 contextId,
        address asset
    )
        private
        view
        returns (bool hasResult, bool allowed)
    {
        (bool ok, bytes memory ret) = _tryStaticcallManager(
            manager,
            abi.encodeWithSelector(IBlueprintServiceManager.queryIsPaymentAssetAllowed.selector, contextId, asset),
            32
        );
        if (!ok) return (false, false);
        return (true, abi.decode(ret, (bool)));
    }

    /// @notice Maximum gas forwarded to a blueprint manager hook.
    /// @dev Capped so a malicious or buggy BSM cannot burn the entire transaction
    ///      gas, and so that downstream protocol logic always has enough gas left to
    ///      finalize state changes (CEI). Hooks should be lightweight; bookkeeping work
    ///      belongs off-chain. The cap must still clear a real hook body (a few SSTOREs)
    ///      on chains that meter storage far above mainnet — e.g. Tempo prices SSTORE
    ///      ~11x higher, turning a ~45k mainnet hook into ~500k there. 2M keeps the
    ///      reentrancy/DoS bound tight while clearing that headroom.
    /// @notice Default gas budget for a blueprint-manager hook when no per-deployment
    ///         override is set. 500k is the tight all-chain DoS bound; a buggy/malicious BSM
    ///         can burn at most this per hook, and downstream CEI finalization always has gas.
    uint256 internal constant MANAGER_HOOK_GAS_LIMIT_DEFAULT = 500_000;

    /// @dev Effective per-hook gas budget: the per-deployment override if set, else the default.
    ///      Lets high-SSTORE-metering chains (e.g. Tempo) raise the budget so a real setup hook
    ///      clears, without loosening the DoS bound on cheap chains.
    function _hookGasLimit() internal view returns (uint256) {
        uint256 configured = _managerHookGasLimit;
        return configured == 0 ? MANAGER_HOOK_GAS_LIMIT_DEFAULT : configured;
    }

    /// @notice Call manager with revert on failure (capped gas).
    function _callManager(address manager, bytes memory data) internal {
        (bool success, bytes memory returnData) = manager.call{ gas: _hookGasLimit() }(data);
        if (!success) {
            if (returnData.length > 0) {
                revert Errors.ManagerReverted(manager, returnData);
            }
            revert Errors.ManagerRejected(manager);
        }
    }

    /// @notice Try to call manager, ignore failures (capped gas).
    /// @dev Failure is observable via the `ManagerHookFailed` event so off-chain monitors
    ///      can detect a misbehaving BSM without halting the protocol path.
    function _tryCallManager(address manager, bytes memory data) internal {
        (bool success, bytes memory returnData) = manager.call{ gas: _hookGasLimit() }(data);
        if (!success) {
            emit ManagerHookFailed(manager, bytes4(data), returnData);
        }
    }

    /// @notice Best-effort gas-capped staticcall to a manager view hook.
    /// @dev Returns `(false, "")` on revert, on a manager set to `address(0)`, on calls
    ///      that consumed more than the hook gas budget, or on returndata
    ///      shorter than `minReturnLen`. Callers MUST treat the failure case as
    ///      "no answer" and fall back to a safe default; never trust an `ok=false`
    ///      branch to surface a structured error.
    function _tryStaticcallManager(
        address manager,
        bytes memory data,
        uint256 minReturnLen
    )
        internal
        view
        returns (bool ok, bytes memory ret)
    {
        if (manager == address(0)) return (false, "");
        (ok, ret) = manager.staticcall{ gas: _hookGasLimit() }(data);
        if (!ok || ret.length < minReturnLen) return (false, "");
    }

    /// @notice Maximum gas forwarded to the price-oracle adapter per query.
    /// @dev Same cap pattern as the manager hook budget: bounds the cost of a buggy
    ///      or adversarial oracle adapter on the billing hot path so the keeper's
    ///      gas budget cannot be drained.
    uint256 internal constant ORACLE_QUERY_GAS_LIMIT = 250_000;

    /// @notice Best-effort `toUSD` query with a gas cap and revert isolation.
    /// @dev Returns the raw `amount` on revert / oracle disabled / wrong return shape,
    ///      and surfaces failure via `PriceOracleFallback`. This is the shared
    ///      degraded-fairness path used by `PaymentsBilling._accrueOperatorWeights`
    ///      and `PaymentsDistribution._initSubscriptionBaseline`: an oracle outage
    ///      degrades to raw token-second weighting rather than freezing the bill.
    function _safeToUSD(address oracleAddr, address token, uint256 amount) internal returns (uint256) {
        if (oracleAddr == address(0) || amount == 0) return amount;
        (bool ok, bytes memory ret) = oracleAddr.staticcall{ gas: ORACLE_QUERY_GAS_LIMIT }(
            abi.encodeWithSelector(IPriceOracle.toUSD.selector, token, amount)
        );
        if (!ok || ret.length < 32) {
            emit PriceOracleFallback(oracleAddr, token, ret);
            return amount;
        }
        return abi.decode(ret, (uint256));
    }

    /// @notice View variant of `_safeToUSD` for the activation-time baseline path.
    /// @dev Does not emit (events would change the function's view-ness) — callers on
    ///      activation paths should monitor `PriceOracleFallback` from the bill path
    ///      for ongoing oracle health.
    function _safeToUSDView(address oracleAddr, address token, uint256 amount) internal view returns (uint256) {
        if (oracleAddr == address(0) || amount == 0) return amount;
        (bool ok, bytes memory ret) = oracleAddr.staticcall{ gas: ORACLE_QUERY_GAS_LIMIT }(
            abi.encodeWithSelector(IPriceOracle.toUSD.selector, token, amount)
        );
        if (!ok || ret.length < 32) return amount;
        return abi.decode(ret, (uint256));
    }
}
