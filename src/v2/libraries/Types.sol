// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title Types
/// @notice Shared types for Tangle Protocol v2
library Types {
    // ═══════════════════════════════════════════════════════════════════════════
    // BLUEPRINT
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Membership model for a service
    enum MembershipModel {
        Fixed,      // Operators are fixed at service creation
        Dynamic     // Operators can join/leave after service activation
    }

    /// @notice Pricing model for service payments
    enum PricingModel {
        PayOnce,        // Single payment at service request
        Subscription,   // Recurring payments per interval
        EventDriven     // Payment per job/event
    }

    /// @notice Blueprint - a template for services
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
    enum ServiceStatus {
        Pending,     // Waiting for operator approvals
        Active,      // Running
        Terminated   // Ended (by owner or expiry)
    }

    /// @notice Service request - pending service awaiting approval
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

    /// @notice Reward pool for delegator rewards (Masterchef-style)
    struct RewardPool {
        uint256 accRewardPerShare;  // Accumulated rewards per share, scaled by 1e18
        uint256 totalShares;        // Total delegated amount
        uint64 lastUpdateBlock;     // Last block rewards were updated
    }

    /// @notice Payment split configuration
    /// @dev Percentages in basis points (10000 = 100%)
    struct PaymentSplit {
        uint16 developerBps;   // To blueprint owner
        uint16 protocolBps;    // To protocol treasury
        uint16 operatorBps;    // To service operators (weighted by exposure)
        uint16 restakerBps;    // To delegators/restakers
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // MULTI-ASSET DELEGATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Asset type for multi-asset support
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
        uint256 shares;         // Shares to unstake (NOT raw amount!)
        uint64 requestedRound;
        BlueprintSelectionMode selectionMode;
        // Blueprint IDs stored separately if Fixed
    }

    /// @notice Operator status
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

    /// @notice Per-operator reward pool (Share-based with Masterchef rewards)
    /// @dev Uses ERC4626-style share accounting for O(1) slashing
    struct OperatorRewardPool {
        uint256 accRewardPerShare;  // Accumulated rewards per share, scaled by 1e18
        uint256 totalShares;        // Total shares outstanding (not amounts!)
        uint256 totalAssets;        // Total underlying value (decreases on slash)
        uint64 lastUpdateRound;     // Last round rewards were updated
        // Exchange rate = totalAssets / totalShares
        // After slash: totalAssets decreases, shares stay same → each share worth less
    }

    /// @notice Delegator's reward debt for an operator
    struct DelegatorRewardDebt {
        uint256 rewardDebt;         // Reward debt for Masterchef calculation
        uint256 pendingRewards;     // Accumulated unclaimed rewards
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
}
