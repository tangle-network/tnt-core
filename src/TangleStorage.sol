// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import { Types } from "./libraries/Types.sol";
import { PaymentLib } from "./libraries/PaymentLib.sol";
import { SlashingLib } from "./libraries/SlashingLib.sol";
import { IStaking } from "./interfaces/IStaking.sol";
import { IMBSMRegistry } from "./interfaces/IMBSMRegistry.sol";
import { ProtocolConfig } from "./config/ProtocolConfig.sol";

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

    /// @notice Conversion factor from basis points to percent (100 bps = 1%)
    uint16 internal constant BPS_TO_PERCENT = 100;

    /// @notice Maximum percent value (100%)
    uint8 internal constant MAX_PERCENT = 100;

    /// @notice Default BLS aggregation threshold (67%)
    uint16 internal constant DEFAULT_AGGREGATION_THRESHOLD_BPS = 6700;

    /// @notice Default TNT minimum exposure (10%)
    uint16 internal constant DEFAULT_TNT_MIN_EXPOSURE_BPS = 1000;

    // Default payment split (can be changed by admin)
    // Default split: 20% developer / 20% protocol / 40% operator pool / 20% staker pool.
    // Keeper rebate defaults to zero — admins can carve up to a few hundred bps for the
    // permissionless bill caller via `setPaymentSplit` to incentivise keeper bots.
    uint16 internal constant DEFAULT_DEVELOPER_BPS = 2000;
    uint16 internal constant DEFAULT_PROTOCOL_BPS = 2000;
    uint16 internal constant DEFAULT_OPERATOR_BPS = 4000;
    uint16 internal constant DEFAULT_STAKER_BPS = 2000;
    uint16 internal constant DEFAULT_KEEPER_BPS = 0;

    // Default exit queue configuration
    uint64 internal constant DEFAULT_MIN_COMMITMENT_DURATION = ProtocolConfig.MIN_COMMITMENT_DURATION;
    uint64 internal constant DEFAULT_EXIT_QUEUE_DURATION = ProtocolConfig.EXIT_QUEUE_DURATION;

    // ═══════════════════════════════════════════════════════════════════════════
    // PROTOCOL CONFIGURATION (Slot 0-10)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Staking module for stake management
    IStaking internal _staking;

    /// @notice Protocol treasury address
    address payable internal _treasury;

    /// @notice Configurable maximum number of blueprints per operator
    uint32 internal _maxBlueprintsPerOperator;

    /// @notice Payment split configuration
    Types.PaymentSplit internal _paymentSplit;

    /// @notice EIP-712 domain separator (cached)
    bytes32 internal _domainSeparator;

    /// @notice Registry that resolves master blueprint service managers
    IMBSMRegistry internal _mbsmRegistry;

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

    /// @notice Blueprint ID => Metadata URI
    mapping(uint64 => string) internal _blueprintMetadataUri;

    /// @notice Blueprint ID => Pinned metadata digest
    mapping(uint64 => bytes32) internal _blueprintMetadataHash;

    /// @notice Blueprint ID => Rich metadata
    mapping(uint64 => Types.BlueprintMetadata) internal _blueprintMetadata;

    /// @notice Blueprint ID => Implementation sources
    mapping(uint64 => Types.BlueprintSource[]) internal _blueprintSources;

    /// @notice Blueprint ID => Supported membership models
    mapping(uint64 => Types.MembershipModel[]) internal _blueprintSupportedMemberships;

    /// @notice Blueprint ID => Resolved master blueprint service manager revision
    mapping(uint64 => uint32) internal _blueprintMasterRevisions;

    /// @notice Blueprint ID => encoded blueprint definition blob
    mapping(uint64 => bytes) internal _blueprintDefinitionBlobs;

    /// @notice Operator => Count of registered blueprints (enforces limits)
    mapping(address => uint32) internal _operatorBlueprintCounts;

    /// @notice Blueprint ID => Operator => Registration data
    mapping(uint64 => mapping(address => Types.OperatorRegistration)) internal _operatorRegistrations;

    /// @notice Blueprint ID => Operator => Preferences (includes ECDSA public key for gossip)
    mapping(uint64 => mapping(address => Types.OperatorPreferences)) internal _operatorPreferences;

    /// @notice Blueprint ID => Key hash => Operator (prevents duplicate gossip keys)
    mapping(uint64 => mapping(bytes32 => address)) internal _blueprintOperatorKeys;

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

    /// @notice Request ID => Operator => BLS public key (stored during approval, transferred to service on activation)
    mapping(uint64 => mapping(address => Types.BLSPubkey)) internal _requestOperatorBlsPubkeys;

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

    /// @notice Service ID => Security requirements (persisted on activation)
    mapping(uint64 => Types.AssetSecurityRequirement[]) internal _serviceSecurityRequirements;

    /// @notice Service ID => Operator => Security commitments (persisted on activation)
    mapping(uint64 => mapping(address => Types.AssetSecurityCommitment[])) internal _serviceSecurityCommitments;

    /// @notice Service ID => Operator => Asset hash => Commitment exposure bps (persisted on activation)
    /// @dev Asset hash = keccak256(abi.encode(asset.kind, asset.token))
    mapping(uint64 => mapping(address => mapping(bytes32 => uint16))) internal _serviceSecurityCommitmentBps;

    /// @notice Service ID => Operator => BLS public key for aggregated signature verification
    /// @dev Stored when operator approves service with BLS key, used to verify aggregated signatures
    mapping(uint64 => mapping(address => Types.BLSPubkey)) internal _serviceOperatorBlsPubkeys;

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

    /// @notice Live count of pending (unresolved) slash proposals per operator. Used to
    ///         enforce `SlashConfig.maxPendingSlashesPerOperator` so a malicious proposer
    ///         can't grief an operator by spamming pending slashes that all bump the
    ///         staking-side `_operatorPendingSlashCount`.
    mapping(address => uint64) internal _operatorActiveSlashProposals;

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
    // INCENTIVES STORAGE (Slot 111-120)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice TNT token used for default security requirements + TNT staker incentives
    address internal _tntToken;

    /// @notice Reward vaults contract that tracks TNT delegations and distributes TNT rewards
    address internal _rewardVaults;

    /// @notice Default minimum TNT exposure for all service requests (bps)
    uint16 internal _defaultTntMinExposureBps;

    /// @notice Deprecated (reserved storage): was "TNT staker fee bps"
    uint16 internal _deprecatedTntStakerFeeBps;

    /// @notice Discount applied to service payments made in TNT (bps of the payment amount; capped to protocol share)
    uint16 internal _tntPaymentDiscountBps;

    /// @notice Distributor for service-fee payouts to stakers (multi-asset, per-asset commitments)
    address internal _serviceFeeDistributor;

    /// @notice Price oracle for USD-normalized scoring (optional, but required for USD-weighted splits)
    address internal _priceOracle;

    /// @notice Governance-tunable ceiling on `maxOperators` per service.
    /// @dev Read at request validation and at join time; blueprint configs with
    ///      `maxOperators == 0` ("unlimited") clamp to this value. Seeded from
    ///      `ProtocolConfig.DEFAULT_MAX_OPERATORS_PER_SERVICE` at init; admin may
    ///      raise or lower it via `setMaxOperatorsPerService` (zero rejected).
    uint32 internal _maxOperatorsPerService;

    // ═══════════════════════════════════════════════════════════════════════════
    // ROUTER SELECTOR REGISTRY
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Function selector => facet address
    mapping(bytes4 => address) internal _facetForSelector;

    // ═══════════════════════════════════════════════════════════════════════════
    // RESERVED (USED) STORAGE
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Account => Set of reward tokens with pending operator rewards
    /// @dev Uses a reserved storage slot to support token discovery for `pendingRewards`.
    mapping(address => EnumerableSet.AddressSet) internal _pendingRewardTokens;

    // ═══════════════════════════════════════════════════════════════════════════
    // OPERATOR SERVICE TRACKING (Slot 121-125)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Blueprint ID => Operator => Count of active services
    /// @dev Used to prevent operators from unregistering while having active services
    mapping(uint64 => mapping(address => uint32)) internal _operatorActiveServiceCount;

    // ═══════════════════════════════════════════════════════════════════════════
    // SERVICE REQUEST TTL CONFIGURATION (Slot 126-130)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Minimum TTL for service requests (0 = use protocol default)
    uint64 internal _minServiceTtl;

    /// @notice Maximum TTL for service requests (0 = use protocol default)
    uint64 internal _maxServiceTtl;

    /// @notice Grace period for request expiry (0 = use protocol default)
    /// @dev Operators have this additional time to approve after request expiry
    uint64 internal _requestExpiryGracePeriod;

    /// @notice Maximum age for quote timestamps (0 = use protocol default)
    /// @dev Quotes with timestamps older than this are rejected
    uint64 internal _maxQuoteAge;

    // ═══════════════════════════════════════════════════════════════════════════
    // BLUEPRINT METADATA LOCK (Slot 131-135)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Blueprint ID => Whether metadata is locked (cannot be updated)
    /// @dev Set to true when first operator registers for the blueprint
    mapping(uint64 => bool) internal _blueprintMetadataLocked;

    // ═══════════════════════════════════════════════════════════════════════════
    // PRICING STORAGE (Slot 136-140)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Blueprint ID => Job Index => Per-job event rate override
    /// @dev If non-zero, overrides BlueprintConfig.eventRate for that jobIndex
    mapping(uint64 => mapping(uint8 => uint256)) internal _jobEventRates;

    /// @notice Service ID => Call ID => Set of quoted operators (for RFQ jobs)
    mapping(uint64 => mapping(uint64 => EnumerableSet.AddressSet)) internal _jobQuotedOperators;

    /// @notice Service ID => Call ID => Operator => Quoted price (for RFQ jobs)
    mapping(uint64 => mapping(uint64 => mapping(address => uint256))) internal _jobQuotedPrices;

    /// @notice Service ID => Operator => Resource commitment hash (for QoS disputes)
    /// @dev keccak256 of EIP-712-hashed ResourceCommitment[] from the operator's quote
    mapping(uint64 => mapping(address => bytes32)) internal _serviceResourceCommitmentHash;

    /// @notice Blueprint ID => Default resource requirements
    mapping(uint64 => Types.ResourceCommitment[]) internal _blueprintResourceRequirements;

    /// @notice Request ID => Resource requirements for this service request
    mapping(uint64 => Types.ResourceCommitment[]) internal _requestResourceRequirements;

    // ═══════════════════════════════════════════════════════════════════════════
    // TEE ATTESTATION COMMITMENTS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Request ID => Operator => keccak256 root over the operator's
    ///         TeeAttestationCommitment[] supplied at approval. Cleared after
    ///         activation copies the value forward.
    /// @dev Full array is emitted in `TeeCommitmentsRecorded` so any indexer or
    ///      slashing witness can reconstruct it. Storing the root keeps activation
    ///      gas O(operators) instead of O(operators × commitments × slots).
    mapping(uint64 => mapping(address => bytes32)) internal _requestTeeCommitmentRoot;

    /// @notice Service ID => Operator => keccak256 root over the operator's
    ///         TeeAttestationCommitment[]. Read by slashing / blueprint provisioning
    ///         hooks; the original array is supplied as a witness and verified
    ///         against this root.
    mapping(uint64 => mapping(address => bytes32)) internal _serviceTeeCommitmentRoot;

    // ═══════════════════════════════════════════════════════════════════════════
    // DISPUTE BOND ESCROW (pull-pattern)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Disputer => pending bond refund (wei). Credited on `cancelSlash`,
    ///         drained by the disputer's own `claimDisputeBond()` call. The pull
    ///         pattern closes the re-entry window where a disputer-contract's
    ///         fallback could re-enter the staking module (whose pending-slash
    ///         counter is already decremented at this point) and exit at the
    ///         pre-slash exchange rate (pre-slash exchange rate snapshot).
    mapping(address => uint256) internal _pendingDisputeBondRefunds;

    // ═══════════════════════════════════════════════════════════════════════════
    // TWAP SUBSCRIPTION BILLING — PER-(SERVICE, OPERATOR, ASSET) CURSORS
    // ═══════════════════════════════════════════════════════════════════════════
    // The bill weight is the integral of `stake × commitmentBps` over the period,
    // per (operator, asset) the service requires. Cursors track the cumulative
    // stake-seconds last attributed for each (service, op, asset) so cumDelta is
    // correct under joins, leaves, rejoins, and per-asset commitment changes.

    /// @notice Service ID => Operator => keccak256(asset.kind, asset.token) =>
    ///         cum stake-seconds at the most recent attribution event (activation
    ///         seed, join hook, prior bill). Zero sentinel = "never attributed."
    mapping(uint64 => mapping(address => mapping(bytes32 => uint256))) internal _twapCursorByOpAsset;

    /// @notice Service ID => Operator => keccak256(asset.kind, asset.token) =>
    ///         activation-time USD-per-1e18-token conversion snapshot. Captured
    ///         once when the (op, asset) cursor is first seeded — either at
    ///         service activation (`_initSubscriptionBaseline`) or when an
    ///         operator joins post-activation (`_finalizeJoin`) — and reused on
    ///         every subsequent bill. Pins the per-(op, asset) leg of the bill
    ///         weight to the activation price so post-activation oracle drift
    ///         cannot inflate one operator's share of the (capped-at-nominal)
    ///         bill at the expense of honest co-operators.
    ///
    ///         The value stored is `oracle.toUSD(token, 1e18)` — i.e. how many
    ///         18-decimal-USD units one 1e18-unit of `token` was worth at
    ///         activation. Token decimals are absorbed by the oracle adapter
    ///         (see `IPriceOracle`), so the conversion at bill time is
    ///         `usd = (contribution * snapshot) / 1e18`. Zero sentinel = no
    ///         snapshot (oracle disabled at activation, or fallback fired).
    mapping(uint64 => mapping(address => mapping(bytes32 => uint256))) internal _baselinePriceByOpAsset;

    // ═══════════════════════════════════════════════════════════════════════════
    // BLUEPRINT BINARY VERSIONS
    // ═══════════════════════════════════════════════════════════════════════════
    // Append-only per-blueprint binary registry plus per-service upgrade policy
    // and operator acknowledgement tracking. Resolution of the effective version
    // for a service is handled by `BlueprintsBinaryVersions.effectiveBinaryVersion`.

    /// @notice Blueprint ID => append-only list of binary versions. `versionId` is
    ///         the array index; entries are never removed so indices stay stable.
    mapping(uint64 => Types.BinaryVersion[]) internal _blueprintBinaryVersions;

    /// @notice Blueprint ID => currently active version ID for `AUTO` services.
    /// @dev Sentinel `0` is also the genesis version's index, so any blueprint with
    ///      at least one published version has a well-defined active index. Reads
    ///      against a blueprint with zero versions revert `VersionNotFound`.
    mapping(uint64 => uint64) internal _blueprintActiveVersionId;

    /// @notice Service ID => upgrade policy controlling how the effective version
    ///         is resolved. Default value `0` corresponds to `UpgradePolicy.APPROVE`.
    mapping(uint64 => Types.UpgradePolicy) internal _serviceUpgradePolicy;

    /// @notice Service ID => last version ID an operator of the service acknowledged.
    /// @dev Read only under `UpgradePolicy.APPROVE`. Sentinel `0` collapses with the
    ///      genesis version's index; the resolution path explicitly handles both
    ///      "no ack" and "ack == 0" by returning the genesis row.
    mapping(uint64 => uint64) internal _serviceAckedVersionId;

    // ═══════════════════════════════════════════════════════════════════════════
    // BLUEPRINT BINARY ATTESTATIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Blueprint ID => version ID => append-only attestation list. Rows
    ///         are never deleted; revocation flips the `revoked` flag so historical
    ///         indexers can reconstruct the full provenance trail.
    mapping(uint64 => mapping(uint64 => Types.Attestation[])) internal _blueprintVersionAttestations;

    // ═══════════════════════════════════════════════════════════════════════════
    // RESERVED STORAGE GAP
    // ═══════════════════════════════════════════════════════════════════════════

    /// @dev Reserved storage slots for future upgrades. Standard gap size is 50.
    ///      Slots already consumed: 10 (initial) + 5 (binary versions block above:
    ///      4 mappings for versions/policy/ack + 1 mapping for attestations).
    uint256[34] private __gap;
}
