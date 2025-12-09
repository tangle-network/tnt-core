// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import { Types } from "./libraries/Types.sol";
import { PaymentLib } from "./libraries/PaymentLib.sol";
import { SlashingLib } from "./libraries/SlashingLib.sol";
import { IRestaking } from "./interfaces/IRestaking.sol";

/// @title TangleStorage
/// @notice Storage layout for Tangle Protocol v2
/// @dev Inherit this contract to maintain storage compatibility across upgrades
/// @dev Storage slots are explicitly managed to prevent collisions
abstract contract TangleStorage {
    using EnumerableSet for EnumerableSet.AddressSet;

    // ═══════════════════════════════════════════════════════════════════════════
    // CONSTANTS
    // ═══════════════════════════════════════════════════════════════════════════

    uint16 internal constant BPS_DENOMINATOR = 10_000;

    // Default payment split (can be changed by admin)
    uint16 internal constant DEFAULT_DEVELOPER_BPS = 5000;  // 50%
    uint16 internal constant DEFAULT_PROTOCOL_BPS = 1000;   // 10%
    uint16 internal constant DEFAULT_OPERATOR_BPS = 2000;   // 20%
    uint16 internal constant DEFAULT_RESTAKER_BPS = 2000;   // 20%

    // Default exit queue configuration
    uint64 internal constant DEFAULT_MIN_COMMITMENT_DURATION = 1 days;   // Minimum time before exit allowed
    uint64 internal constant DEFAULT_EXIT_QUEUE_DURATION = 7 days;       // Time between schedule and execute

    // ═══════════════════════════════════════════════════════════════════════════
    // PROTOCOL CONFIGURATION (Slot 0-10)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Restaking module for stake management
    IRestaking internal _restaking;

    /// @notice Protocol treasury address
    address payable internal _treasury;

    /// @notice Payment split configuration
    Types.PaymentSplit internal _paymentSplit;

    /// @notice EIP-712 domain separator (cached)
    bytes32 internal _domainSeparator;

    // ═══════════════════════════════════════════════════════════════════════════
    // COUNTERS (Slot 11-15)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Total blueprints created
    uint64 internal _blueprintCount;

    /// @notice Total service requests created
    uint64 internal _serviceRequestCount;

    /// @notice Total services activated
    uint64 internal _serviceCount;

    // ═══════════════════════════════════════════════════════════════════════════
    // BLUEPRINT STORAGE (Slot 16-25)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Blueprint ID => Blueprint data
    mapping(uint64 => Types.Blueprint) internal _blueprints;

    /// @notice Blueprint ID => Configuration
    mapping(uint64 => Types.BlueprintConfig) internal _blueprintConfigs;

    /// @notice Blueprint ID => Operator => Registration data
    mapping(uint64 => mapping(address => Types.OperatorRegistration)) internal _operatorRegistrations;

    /// @notice Blueprint ID => Operator => Preferences (includes ECDSA public key for gossip)
    mapping(uint64 => mapping(address => Types.OperatorPreferences)) internal _operatorPreferences;

    /// @notice Blueprint ID => Set of registered operators
    mapping(uint64 => EnumerableSet.AddressSet) internal _blueprintOperators;

    /// @notice Blueprint ID => Registration schema (encoded TLV bytes)
    mapping(uint64 => bytes) internal _registrationSchemas;

    /// @notice Blueprint ID => Service request schema
    mapping(uint64 => bytes) internal _requestSchemas;

    /// @notice Blueprint ID => Job schemas (params/result per job index)
    mapping(uint64 => Types.StoredJobSchema[]) internal _blueprintJobSchemas;

    // ═══════════════════════════════════════════════════════════════════════════
    // SERVICE REQUEST STORAGE (Slot 26-35)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Request ID => Service request data
    mapping(uint64 => Types.ServiceRequest) internal _serviceRequests;

    /// @notice Request ID => Operator address list
    mapping(uint64 => address[]) internal _requestOperators;

    /// @notice Request ID => Operator => Initial exposure (before approval)
    mapping(uint64 => mapping(address => uint16)) internal _requestExposures;

    /// @notice Request ID => Operator => Approved flag
    mapping(uint64 => mapping(address => bool)) internal _requestApprovals;

    /// @notice Request ID => Permitted callers list
    mapping(uint64 => address[]) internal _requestCallers;

    /// @notice Request ID => Security requirements
    mapping(uint64 => Types.AssetSecurityRequirement[]) internal _requestSecurityRequirements;

    /// @notice Request ID => Operator => Security commitments
    mapping(uint64 => mapping(address => Types.AssetSecurityCommitment[])) internal _requestSecurityCommitments;

    // ═══════════════════════════════════════════════════════════════════════════
    // SERVICE STORAGE (Slot 36-50)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Service ID => Service data
    mapping(uint64 => Types.Service) internal _services;

    /// @notice Service ID => Operator => ServiceOperator data
    mapping(uint64 => mapping(address => Types.ServiceOperator)) internal _serviceOperators;

    /// @notice Service ID => Set of active operators
    mapping(uint64 => EnumerableSet.AddressSet) internal _serviceOperatorSet;

    /// @notice Service ID => Set of permitted callers
    mapping(uint64 => EnumerableSet.AddressSet) internal _permittedCallers;

    /// @notice Service ID => Escrow account (for subscriptions)
    mapping(uint64 => PaymentLib.ServiceEscrow) internal _serviceEscrows;

    // ═══════════════════════════════════════════════════════════════════════════
    // JOB STORAGE (Slot 51-60)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Service ID => Next call ID
    mapping(uint64 => uint64) internal _serviceCallCount;

    /// @notice Service ID => Call ID => Job call data
    mapping(uint64 => mapping(uint64 => Types.JobCall)) internal _jobCalls;

    /// @notice Service ID => Call ID => Operator => Result submitted flag
    mapping(uint64 => mapping(uint64 => mapping(address => bool))) internal _jobResultSubmitted;

    /// @notice Service ID => Call ID => Job inputs (for passing to onJobResult hook)
    mapping(uint64 => mapping(uint64 => bytes)) internal _jobInputs;

    // ═══════════════════════════════════════════════════════════════════════════
    // REWARDS STORAGE (Slot 61-70)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Account => Token => Pending rewards (multi-token support)
    mapping(address => mapping(address => uint256)) internal _pendingRewards;

    /// @notice For backward compatibility: Account => Pending native rewards
    /// @dev Deprecated: use _pendingRewards[account][address(0)] instead
    mapping(address => uint256) internal _pendingNativeRewards;

    // ═══════════════════════════════════════════════════════════════════════════
    // SLASHING STORAGE (Slot 71-80)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Slashing state (config + counters)
    SlashingLib.SlashState internal _slashState;

    /// @notice Slash ID => Slash proposal
    mapping(uint64 => SlashingLib.SlashProposal) internal _slashProposals;

    // ═══════════════════════════════════════════════════════════════════════════
    // RFQ (QUOTE) STORAGE (Slot 81-90)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Quote hash => Used flag (for replay protection)
    mapping(bytes32 => bool) internal _usedQuotes;

    /// @notice Temporary bitmap for deduplicating operators within a quote batch
    mapping(address => bool) internal _quoteOperatorSeen;

    // ═══════════════════════════════════════════════════════════════════════════
    // METRICS STORAGE (Slot 91-95)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Optional metrics recorder for reward tracking
    /// @dev If set, protocol events are recorded for incentive distribution
    address internal _metricsRecorder;

    // ═══════════════════════════════════════════════════════════════════════════
    // OPERATOR STATUS STORAGE (Slot 96-100)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Operator status registry for heartbeat tracking
    /// @dev If set, heartbeat settings are configured from BSM hooks
    address internal _operatorStatusRegistry;

    // ═══════════════════════════════════════════════════════════════════════════
    // EXIT QUEUE STORAGE (Slot 101-110)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Service ID => Operator => Exit request
    mapping(uint64 => mapping(address => Types.ExitRequest)) internal _exitRequests;

    /// @notice Blueprint ID => Custom exit config (if set)
    mapping(uint64 => Types.ExitConfig) internal _blueprintExitConfigs;

    /// @notice Blueprint ID => Has custom exit config flag
    mapping(uint64 => bool) internal _hasCustomExitConfig;

    // ═══════════════════════════════════════════════════════════════════════════
    // RESERVED STORAGE GAP
    // ═══════════════════════════════════════════════════════════════════════════

    /// @dev Reserved storage slots for future upgrades
    /// @dev When adding new storage, decrease this gap accordingly
    uint256[45] private _gap;
}
