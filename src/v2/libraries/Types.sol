// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title Types
/// @notice Shared types for Tangle Protocol v2
library Types {
    // ═══════════════════════════════════════════════════════════════════════════
    // BLUEPRINT
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Membership model for a service
    /// @dev IMPORTANT: Enum values must only be APPENDED, never reordered or inserted.
    /// Changing order will corrupt existing storage. Fixed=0, Dynamic=1.
    enum MembershipModel {
        Fixed,      // Operators are fixed at service creation
        Dynamic     // Operators can join/leave after service activation
    }

    /// @notice Pricing model for service payments
    /// @dev IMPORTANT: Enum values must only be APPENDED, never reordered or inserted.
    /// Changing order will corrupt existing storage. PayOnce=0, Subscription=1, EventDriven=2.
    enum PricingModel {
        PayOnce,        // Single payment at service request
        Subscription,   // Recurring payments per interval
        EventDriven     // Payment per job/event
    }

    /// @notice Blueprint - a template for services
    /// @dev Struct is packed for optimal storage:
    ///      Slot 0: owner (20 bytes)
    ///      Slot 1: manager (20 bytes)
    ///      Slot 2: createdAt (8) + operatorCount (4) + membership (1) + pricing (1) + active (1) = 15 bytes
    struct Blueprint {
        address owner;              // Can transfer ownership, update metadata
        address manager;            // IBlueprintServiceManager implementation (0 = none)
        uint64 createdAt;           // Creation timestamp
        uint32 operatorCount;       // Number of registered operators
        MembershipModel membership; // Fixed or Dynamic
        PricingModel pricing;       // How payments work
        bool active;                // Can be deactivated by owner
    }

    /// @notice Blueprint configuration set at creation
    struct BlueprintConfig {
        MembershipModel membership;
        PricingModel pricing;
        uint32 minOperators;        // Minimum operators for service
        uint32 maxOperators;        // Maximum operators (0 = unlimited)
        uint256 subscriptionRate;   // Rate per interval (for Subscription model)
        uint64 subscriptionInterval; // Interval in seconds
        uint256 eventRate;          // Rate per event (for EventDriven model)
    }

    /// @notice Metadata describing a blueprint for explorers and off-chain tooling
    struct BlueprintMetadata {
        string name;
        string description;
        string author;
        string category;
        string codeRepository;
        string logo;
        string website;
        string license;
        string profilingData;
    }

    /// @notice Definition of a single job entry in a blueprint
    struct JobDefinition {
        string name;
        string description;
        string metadataUri;
        bytes paramsSchema;
        bytes resultSchema;
    }

    /// @notice Serialized schema bytes for job params/result pairs
    struct StoredJobSchema {
        bytes params;
        bytes result;
    }

    /// @notice Blueprint definition emitted by off-chain tooling and persisted on-chain
    struct BlueprintDefinition {
        string metadataUri;                 // IPFS/HTTPS pointer to raw blueprint JSON
        address manager;                    // Service manager contract for hooks
        uint32 masterManagerRevision;       // Revision of the master manager contract
        bool hasConfig;                     // True when config should be applied
        BlueprintConfig config;             // Optional blueprint-specific config
        BlueprintMetadata metadata;         // Human friendly metadata
        JobDefinition[] jobs;               // Job descriptors
        bytes registrationSchema;           // Operator registration schema
        bytes requestSchema;                // Service request schema
        BlueprintSource[] sources;          // Implementation sources
        MembershipModel[] supportedMemberships; // Allowed membership models
    }

    /// @notice Schema validation target used for contextual error reporting
    enum SchemaTarget {
        Registration,
        Request,
        JobParams,
        JobResult
    }

    /// @notice Supported blueprint source kinds
    enum BlueprintSourceKind {
        Container,
        Wasm,
        Native
    }

    /// @notice Fetcher types for blueprint artifacts
    enum BlueprintFetcherKind {
        None,
        Ipfs,
        Http,
        Github
    }

    /// @notice Supported WASM runtimes
    enum WasmRuntime {
        Unknown,
        Wasmtime,
        Wasmer
    }

    /// @notice Container image reference
    struct ImageRegistrySource {
        string registry;
        string image;
        string tag;
    }

    /// @notice WASM runtime configuration
    struct WasmSource {
        WasmRuntime runtime;
        BlueprintFetcherKind fetcher;
        string artifactUri; // e.g. CID or URL
        string entrypoint;  // Function entrypoint
    }

    /// @notice Native binary configuration
    struct NativeSource {
        BlueprintFetcherKind fetcher;
        string artifactUri;
        string entrypoint;
    }

    /// @notice Testing harness metadata for blueprints
    struct TestingSource {
        string cargoPackage;
        string cargoBin;
        string basePath;
    }

    /// @notice Supported CPU/architecture targets for blueprint binaries
    enum BlueprintArchitecture {
        Wasm32,
        Wasm64,
        Wasi32,
        Wasi64,
        Amd32,
        Amd64,
        Arm32,
        Arm64,
        RiscV32,
        RiscV64
    }

    /// @notice Supported operating systems for blueprint binaries
    enum BlueprintOperatingSystem {
        Unknown,
        Linux,
        Windows,
        MacOS,
        BSD
    }

    /// @notice Binary descriptor including sha256 hash used for integrity checks
    struct BlueprintBinary {
        BlueprintArchitecture arch;
        BlueprintOperatingSystem os;
        string name;
        bytes32 sha256;
    }

    /// @notice Blueprint binary source reference
    struct BlueprintSource {
        BlueprintSourceKind kind;
        ImageRegistrySource container;
        WasmSource wasm;
        NativeSource native;
        TestingSource testing;
        BlueprintBinary[] binaries;
    }

    /// @notice Blueprint schema node definition used by SchemaLib
    struct BlueprintFieldType {
        BlueprintFieldKind kind;
        uint16 arrayLength;
        BlueprintFieldType[] children;
        string name;
    }

    /// @notice Primitive kinds supported within blueprint schemas
    enum BlueprintFieldKind {
        Void,
        Bool,
        Uint8,
        Int8,
        Uint16,
        Int16,
        Uint32,
        Int32,
        Uint64,
        Int64,
        Uint128,
        Int128,
        Uint256,
        Int256,
        Address,
        Bytes32,
        FixedBytes,
        String,
        Bytes,
        Optional,
        Array,
        List,
        Struct
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // OPERATOR
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Operator registration status for a specific blueprint
    struct OperatorRegistration {
        uint64 registeredAt;  // 0 if not registered
        uint64 updatedAt;     // Last preference update
        bool active;          // Can be deactivated
        bool online;          // Available for new services
    }

    /// @notice Operator preferences including gossip network identity
    /// @dev The ecdsaPublicKey is used for gossip network message signing/verification
    ///      and may differ from the operator's wallet key (msg.sender)
    struct OperatorPreferences {
        bytes ecdsaPublicKey;   // ECDSA public key for gossip network identity
        string rpcAddress;      // RPC endpoint URL
    }

    /// @notice BLS public key for aggregated signature verification
    /// @dev Stored as raw uint256[4] for efficient storage and comparison
    struct BLSPubkey {
        uint256[4] key;         // G2 point: [x0, x1, y0, y1]
    }

    /// @notice Asset security requirement for a service request
    /// @dev Exposure percentages in basis points (10000 = 100%)
    struct AssetSecurityRequirement {
        Asset asset;              // Which asset
        uint16 minExposureBps;    // Minimum exposure required
        uint16 maxExposureBps;    // Maximum exposure allowed
    }

    /// @notice Asset security commitment from an operator
    /// @dev Operator commits a specific exposure percentage for each required asset
    struct AssetSecurityCommitment {
        Asset asset;              // Which asset
        uint16 exposureBps;       // Committed exposure percentage
    }

    /// @notice Operator's full security commitment for a service
    struct OperatorSecurityCommitment {
        address operator;
        AssetSecurityCommitment[] commitments;  // Per-asset commitments
        uint64 committedAt;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SERVICE
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Service status
    /// @dev IMPORTANT: Enum values must only be APPENDED, never reordered or inserted.
    /// Changing order will corrupt existing storage. Pending=0, Active=1, Terminated=2.
    enum ServiceStatus {
        Pending,     // Waiting for operator approvals
        Active,      // Running
        Terminated   // Ended (by owner or expiry)
    }

    /// @notice Service request - pending service awaiting approval
    /// @dev Struct layout for storage optimization:
    ///      Slot 0: blueprintId (8) + requester (20) = 28 bytes (could be tighter but crossing slot)
    ///      Slot 1: createdAt (8) + ttl (8) + operatorCount (4) + approvalCount (4) = 24 bytes
    ///      Slot 2: paymentToken (20) + membership (1) + minOperators (4) = 25 bytes
    ///      Slot 3: paymentAmount (32)
    ///      Slot 4: maxOperators (4) + rejected (1) = 5 bytes
    struct ServiceRequest {
        uint64 blueprintId;
        address requester;
        uint64 createdAt;
        uint64 ttl;                 // 0 = no expiry
        uint32 operatorCount;       // Expected operators
        uint32 approvalCount;       // Current approvals
        address paymentToken;       // ERC20 or address(0) for native
        uint256 paymentAmount;      // Initial payment
        MembershipModel membership; // Fixed or Dynamic
        uint32 minOperators;        // For dynamic: minimum required
        uint32 maxOperators;        // For dynamic: maximum allowed (0 = unlimited)
        bool rejected;
    }

    /// @notice Service - an active instance of a blueprint
    /// @dev Struct layout for storage optimization:
    ///      Slot 0: blueprintId (8) + owner (20) = 28 bytes
    ///      Slot 1: createdAt (8) + ttl (8) + terminatedAt (8) = 24 bytes
    ///      Slot 2: lastPaymentAt (8) + operatorCount (4) + minOperators (4) + maxOperators (4) = 20 bytes
    ///      Slot 3: membership (1) + pricing (1) + status (1) = 3 bytes
    struct Service {
        uint64 blueprintId;
        address owner;
        uint64 createdAt;
        uint64 ttl;                 // 0 = no expiry
        uint64 terminatedAt;        // 0 if active
        uint64 lastPaymentAt;       // For subscription tracking
        uint32 operatorCount;       // Current operator count
        uint32 minOperators;        // Minimum required (for dynamic)
        uint32 maxOperators;        // Maximum allowed (0 = unlimited)
        MembershipModel membership;
        PricingModel pricing;
        ServiceStatus status;
    }

    /// @notice Operator's participation in a service
    /// @dev Packed into single storage slot: exposureBps (2) + joinedAt (8) + leftAt (8) + active (1) = 19 bytes
    struct ServiceOperator {
        uint16 exposureBps;   // Stake exposure in basis points
        uint64 joinedAt;      // When operator joined
        uint64 leftAt;        // When operator left (0 if active)
        bool active;          // Currently participating
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // JOB
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Job call - a unit of work submitted to a service
    /// @dev Struct layout:
    ///      Slot 0: jobIndex (1) + caller (20) + createdAt (8) + resultCount (4) = 33 bytes (crosses slot)
    ///      Slot 1: payment (32)
    ///      Slot 2: completed (1)
    struct JobCall {
        uint8 jobIndex;        // Which job in the blueprint
        address caller;
        uint64 createdAt;
        uint32 resultCount;    // Number of results submitted
        uint256 payment;       // Payment for this job (EventDriven model)
        bool completed;        // Marked complete by hook or threshold
    }

    /// @notice Job result from an operator
    struct JobResult {
        address operator;
        uint64 submittedAt;
        bytes32 outputHash;    // Hash of actual output (full data in event)
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // REWARDS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Payment split configuration
    /// @dev Percentages in basis points (10000 = 100%)
    struct PaymentSplit {
        uint16 developerBps;   // To blueprint owner
        uint16 protocolBps;    // To protocol treasury
        uint16 operatorBps;    // To service operators (weighted by exposure)
        uint16 stakerBps;      // To delegators/stakers
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // MULTI-ASSET DELEGATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Asset type for multi-asset support
    /// @dev IMPORTANT: Enum values must only be APPENDED, never reordered or inserted.
    /// Changing order will corrupt existing storage. Native=0, ERC20=1.
    enum AssetKind {
        Native,     // Native token (ETH)
        ERC20       // ERC20 token
    }

    /// @notice Asset identifier
    struct Asset {
        AssetKind kind;
        address token;  // address(0) for Native
    }

    /// @notice Lock multiplier tiers for deposits
    /// @dev Multipliers: None=1.0x, 1mo=1.1x, 2mo=1.2x, 3mo=1.3x, 6mo=1.6x
    enum LockMultiplier {
        None,           // No lock, 1.0x multiplier
        OneMonth,       // ~30 days lock, 1.1x multiplier
        TwoMonths,      // ~60 days lock, 1.2x multiplier
        ThreeMonths,    // ~90 days lock, 1.3x multiplier
        SixMonths       // ~180 days lock, 1.6x multiplier
    }

    /// @notice Lock info for a deposit
    struct LockInfo {
        uint256 amount;
        LockMultiplier multiplier;
        uint64 expiryBlock;
    }

    /// @notice Deposit for a single asset
    struct Deposit {
        uint256 amount;             // Total deposited
        uint256 delegatedAmount;    // Currently delegated (cannot exceed amount)
        // Note: locks stored separately for gas efficiency
    }

    /// @notice Blueprint selection for a delegation
    enum BlueprintSelectionMode {
        All,    // Participate in all blueprints the operator supports
        Fixed   // Participate only in selected blueprints
    }

    /// @notice Delegation record from delegator to operator
    /// @dev Stores shares, not raw amounts. Use exchange rate to compute actual value.
    struct BondInfoDelegator {
        address operator;
        uint256 shares;         // Number of shares in operator's pool (NOT raw amount!)
        Asset asset;
        BlueprintSelectionMode selectionMode;
        // Fixed blueprint IDs stored separately if selectionMode == Fixed
    }

    /// @notice Withdraw request (pending)
    struct WithdrawRequest {
        Asset asset;
        uint256 amount;
        uint64 requestedRound;
    }

    /// @notice Unstake request (pending delegation removal)
    /// @dev Stores shares to unstake, converted from amount at request time
    struct BondLessRequest {
        address operator;
        Asset asset;
        uint256 shares;              // Shares to unstake (NOT raw amount!)
        uint64 requestedRound;
        BlueprintSelectionMode selectionMode;
        uint256 slashFactorSnapshot; // Reserved (kept for storage compatibility)
        // Blueprint IDs stored separately if Fixed
    }

    /// @notice Operator status
    /// @dev IMPORTANT: Enum values must only be APPENDED, never reordered or inserted.
    /// Changing order will corrupt existing storage. Active=0, Inactive=1, Leaving=2.
    enum OperatorStatus {
        Active,
        Inactive,
        Leaving     // Exit scheduled, waiting for delay
    }

    /// @notice Operator metadata
    struct OperatorMetadata {
        uint256 stake;              // Self-stake amount
        uint32 delegationCount;     // Total delegations received
        OperatorStatus status;
        uint64 leavingRound;        // Round when leaving was scheduled (if Leaving)
        // delegations and blueprint_ids stored separately
    }

    /// @notice Operator bond reduction request
    struct OperatorBondLessRequest {
        uint256 amount;
        uint64 requestedRound;
    }

    /// @notice Snapshot of operator state at round start (for stable reward calculation)
    struct OperatorSnapshot {
        uint256 stake;
        uint256 totalDelegated;
        // Individual delegations stored separately
    }

    /// @notice Delegator status
    enum DelegatorStatus {
        Active,
        LeavingScheduled
    }

    /// @notice Per-operator reward pool (share-based accounting for O(1) slashing)
    /// @dev Uses ERC4626-style share accounting for O(1) slashing
    struct OperatorRewardPool {
        uint256 totalShares;        // Total shares outstanding (not amounts!)
        uint256 totalAssets;        // Total underlying value (decreases on slash)
        // Exchange rate = totalAssets / totalShares
        // After slash: totalAssets decreases, shares stay same → each share worth less
    }

    /// @notice Asset configuration
    struct AssetConfig {
        bool enabled;
        uint256 minOperatorStake;
        uint256 minDelegation;
        uint256 depositCap;         // 0 = unlimited
        uint256 currentDeposits;    // Track total deposits
        uint16 rewardMultiplierBps; // 10000 = 1x, for asset-specific boosts
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SLASHING
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Slash parameters
    struct SlashParams {
        address operator;
        uint64 serviceId;
        uint256 amount;
        bytes32 evidence;      // IPFS hash or other reference
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // RFQ (Request For Quote) - SIGNED PRICE QUOTES
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Resource pricing for a quote
    struct ResourcePricing {
        string kind;              // Resource type (CPU, MemoryMB, StorageMB, GPU, etc.)
        uint64 count;             // Quantity
        uint256 pricePerUnit;     // Price per unit in payment token
    }

    /// @notice Quote details from an operator
    struct QuoteDetails {
        uint64 blueprintId;       // Which blueprint
        uint64 ttlBlocks;         // Service duration in blocks
        uint256 totalCost;        // Total cost in payment token (wei)
        uint64 timestamp;         // When quote was generated
        uint64 expiry;            // Quote expiry timestamp
        AssetSecurityCommitment[] securityCommitments;  // Operator's security commitments
    }

    /// @notice Signed quote from an operator
    struct SignedQuote {
        QuoteDetails details;     // Quote details
        bytes signature;          // EIP-712 signature over quote details hash
        address operator;         // Operator address (recovered from signature)
    }

    /// @notice EIP-712 domain for quote signatures
    /// @dev Used for structured data signing
    struct QuoteDomain {
        string name;              // "TangleQuote"
        string version;           // "1"
        uint256 chainId;
        address verifyingContract;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // BLS AGGREGATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Threshold type for BLS aggregation
    enum ThresholdType {
        CountBased,     // Percentage of operator count
        StakeWeighted   // Percentage of total stake
    }

    /// @notice BLS aggregation configuration for a job
    struct AggregationConfig {
        bool required;              // Whether aggregation is required
        uint16 thresholdBps;        // Threshold in basis points (6700 = 67%)
        ThresholdType thresholdType; // Count-based or stake-weighted
    }

    /// @notice BN254 G1 point for BLS signatures
    // forge-lint: disable-next-line(pascal-case-struct)
    struct BN254G1Point {
        uint256 x;
        uint256 y;
    }

    /// @notice BN254 G2 point for BLS public keys
    // forge-lint: disable-next-line(pascal-case-struct)
    struct BN254G2Point {
        uint256[2] x;  // x = x0 * i + x1
        uint256[2] y;  // y = y0 * i + y1
    }

    /// @notice Aggregated job result with BLS signature
    struct AggregatedJobResult {
        uint64 serviceId;
        uint64 callId;
        bytes output;
        BN254G1Point signature;         // Aggregated BLS signature
        uint256 signerBitmap;           // Bitmap of which operators signed
        BN254G2Point aggregatedPubkey;  // Aggregated public key of signers
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // OPERATOR EXIT QUEUE
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Exit configuration for operator service departures
    /// @dev Can be set per-blueprint, with protocol defaults as fallback
    struct ExitConfig {
        uint64 minCommitmentDuration;   // Minimum time operator must stay after joining (seconds)
        uint64 exitQueueDuration;       // Time between scheduling exit and completing it (seconds)
        bool forceExitAllowed;          // Allow service owner to force-exit operators (emergency)
    }

    /// @notice Operator exit request (pending departure)
    struct ExitRequest {
        uint64 serviceId;
        uint64 scheduledAt;             // When exit was scheduled
        uint64 executeAfter;            // Earliest time exit can be executed
        bool pending;                   // True if exit is pending
    }

    /// @notice Exit status for an operator-service pair
    enum ExitStatus {
        None,           // Not in exit queue
        Scheduled,      // Exit scheduled, waiting for queue duration
        Executable,     // Queue duration passed, can execute
        Completed       // Exit completed (operator left)
    }
}
