// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { OwnableUpgradeable } from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import { ICrossChainReceiver } from "./interfaces/ICrossChainMessenger.sol";

/// @title IOpStackCrossDomainMessenger
/// @notice Minimal interface for the OP-stack `L2CrossDomainMessenger` singleton.
/// @dev On OP-stack chains (Optimism, Base, and other Bedrock forks) the
///      `L2CrossDomainMessenger` is a shared predeploy. It exposes the
///      authenticated L1 sender of the message currently being relayed via
///      `xDomainMessageSender()`. Any L2 contract that trusts a message coming
///      from the singleton MUST read this value to authenticate the L1 origin —
///      `msg.sender` alone only proves "the singleton relayed *some* message",
///      not *who* on L1 sent it.
interface IOpStackCrossDomainMessenger {
    function xDomainMessageSender() external view returns (address);
}

/// @title IL2Slasher
/// @notice Interface for the L2 slashing mechanism
/// @dev Implement this on Tangle L2 to execute slashing
interface IL2Slasher {
    /// @notice Slash an operator's stake
    /// @param operator The operator to slash
    /// @param slashBps Slash percentage in basis points
    /// @param reason Encoded reason/proof for the slash
    function slashOperator(address operator, uint16 slashBps, bytes calldata reason) external;

    /// @notice Check if an operator can be slashed
    /// @param operator The operator address
    /// @return canSlash True if the operator has stake that can be slashed
    function canSlash(address operator) external view returns (bool canSlash);

    /// @notice Get operator's slashable stake
    /// @param operator The operator address
    /// @return stake The amount of stake that can be slashed
    function getSlashableStake(address operator) external view returns (uint256 stake);
}

/// @title L2SlashingReceiver
/// @notice Receives cross-chain slashing messages and executes them on L2
/// @dev Deploy this on Tangle L2 (or any destination chain) behind an ERC1967 proxy.
///      C-3 : converted to UUPS upgradeable so post-mainnet bug remediation
///      does not require re-deploying every bridge endpoint and re-authorising senders.
///      Storage is namespaced under the ERC-7201 slot
///      `tangle.beacon.L2SlashingReceiver` to keep upgrade-safe layout invariants.
contract L2SlashingReceiver is Initializable, UUPSUpgradeable, OwnableUpgradeable, ICrossChainReceiver {
    // ═══════════════════════════════════════════════════════════════════════════
    // ERRORS
    // ═══════════════════════════════════════════════════════════════════════════

    error UnauthorizedMessenger();
    error UnauthorizedSourceChain();
    error UnauthorizedSender();
    error InvalidPayload();
    error SlashingFailed();
    error SenderNotPending();
    error SenderActivationTooEarly(uint256 activationTime);
    error NonceAlreadyProcessed(uint256 sourceChainId, address sender, uint256 nonce);
    error SlashingNotPossible(address operator);
    error ZeroAddress();
    /// @dev Raised when the messenger is configured as the OP-stack singleton but the
    ///      authenticated L1 sender (`xDomainMessageSender()`) does not match the
    ///      trusted counterpart registered for the source chain.
    error UnauthorizedOpStackSender(uint256 sourceChainId, address xDomainSender);
    /// @dev Raised when an OP-stack-mode delivery arrives for a source chain that has
    ///      no trusted L1 counterpart configured, so no message can be authenticated.
    error OpStackSenderNotConfigured(uint256 sourceChainId);
    /// @dev Raised by `flushDeferredSlash` when the operator has no banked deferred debt.
    error NoDeferredSlash(address operator);

    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    event SlashingReceived(uint256 indexed sourceChainId, address indexed operator, uint16 slashBps, bytes32 messageId);

    event SlashingExecuted(address indexed operator, uint16 slashBps, uint64 slashingFactor);

    /// @notice Emitted when a slash cannot be applied immediately (no slashable stake) and the
    ///         owed bps are banked for later collection via `flushDeferredSlash`.
    event SlashingDeferred(address indexed operator, uint16 slashBps, uint256 totalDeferredBps);

    /// @notice Emitted when previously-banked deferred slash debt is realised against an operator.
    event DeferredSlashFlushed(address indexed operator, uint16 slashBps, uint256 remainingDeferredBps);

    event AuthorizedSenderUpdated(uint256 indexed chainId, address indexed sender, bool authorized);
    event AuthorizedSenderScheduled(uint256 indexed chainId, address indexed sender, uint256 activationTime);
    event MessengerScheduled(address indexed newMessenger, uint256 activationTime);
    event MessengerUpdated(address indexed oldMessenger, address indexed newMessenger);
    event SlasherScheduled(address indexed newSlasher, uint256 activationTime);
    event SlasherUpdated(address indexed newSlasher);

    /// @notice Emitted when OP-stack delivery mode is toggled for the configured messenger.
    event OpStackMessengerModeUpdated(bool enabled);
    /// @notice Emitted when the trusted L1 counterpart for an OP-stack source chain is set.
    event OpStackL1SenderUpdated(uint256 indexed sourceChainId, address indexed l1Sender);

    // ═══════════════════════════════════════════════════════════════════════════
    // CONSTANTS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Message type for beacon chain slashing
    bytes4 public constant SLASH_MESSAGE_TYPE = bytes4(keccak256("BEACON_SLASH"));

    /// @notice Delay before new authorized senders become active
    uint256 public constant SENDER_ACTIVATION_DELAY = 2 days;

    /// @notice Basis-point denominator (100% == 10_000 bps). A single slash can never exceed this.
    uint16 public constant BPS_DENOMINATOR = 10_000;

    // ═══════════════════════════════════════════════════════════════════════════
    // ERC-7201 NAMESPACED STORAGE
    // ═══════════════════════════════════════════════════════════════════════════

    /// @custom:storage-location erc7201:tangle.beacon.L2SlashingReceiver
    /// @dev All mutable state lives in this struct so the implementation contract
    ///      has zero state at fixed slots, and an upgrade simply re-points the
    ///      proxy at a new logic contract that reads from the same namespaced slot.
    struct ReceiverStorage {
        // Core wired contracts
        IL2Slasher slasher;
        address messenger;
        // Authorized senders per source chain
        mapping(uint256 => mapping(address => bool)) authorizedSenders;
        // pending authorizations (chainId => sender => activation timestamp)
        mapping(uint256 => mapping(address => uint256)) pendingAuthorizedSenders;
        // timelocked admin swaps for messenger / slasher
        address pendingMessenger;
        uint256 pendingMessengerAt;
        address pendingSlasher;
        uint256 pendingSlasherAt;
        // Replay protection (sourceChain => sender => nonce => processed)
        mapping(uint256 => mapping(address => mapping(uint256 => bool))) processedNonces;
        // Cumulative slash bps per operator from beacon chain
        mapping(address => uint256) beaconSlashTotal;
        // ── OP-stack direct-delivery authentication (cross-chain MEDIUM, forgeable-slash) ──
        // When the configured `messenger` is the OP-stack `L2CrossDomainMessenger`
        // singleton (rather than a dedicated per-bridge adapter that pre-authenticates
        // the L1 origin), the calldata `sender` passed to `receiveMessage` is
        // ATTACKER-CONTROLLED and must NOT be trusted for authorization. With this flag
        // set, the authenticated L1 sender is derived from
        // `IOpStackCrossDomainMessenger(messenger).xDomainMessageSender()` and matched
        // against `opStackL1Sender[sourceChainId]`.
        bool opStackMessengerMode;
        // sourceChainId => trusted L1 counterpart (the L2SlashingConnector on that chain)
        mapping(uint256 => address) opStackL1Sender;
        // Dedicated staging for OP-stack sender scheduling, disjoint from
        // `pendingAuthorizedSenders` so an OP-stack schedule cannot be activated into the
        // adapter-path `authorizedSenders` (or vice-versa) by calling the wrong activator.
        // (chainId => pending sender) and (chainId => activation timestamp).
        mapping(uint256 => address) pendingOpStackL1Sender;
        mapping(uint256 => uint256) pendingOpStackL1SenderAt;
        // Timelock for DISABLING OP-stack mode (the dangerous downgrade back to calldata-sender
        // trust). Enabling is immediate (tightening); disabling is delayed so a mode flip cannot
        // silently re-open the forgeable path without the same 2-day window every other anchor has.
        uint256 opStackModeDisableAt;
        // ── Deferred-slash debt (beacon-slash-evasion MEDIUM) ──
        // When a slash message arrives but the operator currently has no slashable L2 stake
        // (`canSlash == false`, e.g. they withdrew all L2 stake to dodge a pending beacon
        // slash), reverting forever would let them escape permanently — the bridge nonce is
        // single-shot and cannot be redelivered after the message is consumed elsewhere, and an
        // always-reverting message blocks no future stake from being slashed. Instead we BANK
        // the owed bps here, mark the nonce processed, and let anyone realise it via
        // `flushDeferredSlash` the moment the operator re-acquires slashable stake. Accumulated
        // bps are capped to BPS_DENOMINATOR on flush so a re-staked operator can never be
        // slashed for more than 100% of their stake.
        mapping(address => uint256) deferredSlashBps;
        // Reserved storage for future upgrades. Keep this LAST.
        // Gap reduced 50 → 48 (opStackMessengerMode + opStackL1Sender), then 48 → 45
        // (pendingOpStackL1Sender + pendingOpStackL1SenderAt + opStackModeDisableAt), then
        // 45 → 44 (deferredSlashBps). Append-only; slots preserved.
        uint256[44] __gap;
    }

    /// @notice ERC-7201 slot:
    ///         keccak256(abi.encode(uint256(keccak256("tangle.beacon.L2SlashingReceiver")) - 1))
    ///         & ~bytes32(uint256(0xff))
    bytes32 private constant RECEIVER_STORAGE_SLOT = 0x82055dbb59125fee25966888e9f62ec781a4d1c7ca467f7e3e2e55d698dfc400;

    function _getStorage() private pure returns (ReceiverStorage storage $) {
        bytes32 slot = RECEIVER_STORAGE_SLOT;
        assembly {
            $.slot := slot
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // CONSTRUCTOR / INITIALIZER
    // ═══════════════════════════════════════════════════════════════════════════

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /// @notice Initialize the receiver behind a proxy.
    /// @param _slasher    The L2 slasher contract that applies stake reductions.
    /// @param _messenger  Trusted bridge adapter that may invoke `receiveMessage`.
    ///                    Pass `address(0)` so the deploy script can wire the
    ///                    bridge adapter via `setMessenger` (bootstrap path).
    /// @param _owner      Initial admin/owner. Should be a multisig or timelock.
    /// @dev Init order matters: ownership must be granted before any sender is
    ///      authorised, since `setAuthorizedSender` is `onlyOwner`.
    function initialize(address _slasher, address _messenger, address _owner) external initializer {
        if (_owner == address(0)) revert ZeroAddress();

        __UUPSUpgradeable_init();
        __Ownable_init(_owner);

        ReceiverStorage storage $ = _getStorage();
        $.slasher = IL2Slasher(_slasher);
        $.messenger = _messenger;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // VIEW HELPERS (preserve original public-state surface for off-chain readers)
    // ═══════════════════════════════════════════════════════════════════════════

    function slasher() external view returns (IL2Slasher) {
        return _getStorage().slasher;
    }

    function messenger() external view returns (address) {
        return _getStorage().messenger;
    }

    function authorizedSenders(uint256 chainId, address sender) external view returns (bool) {
        return _getStorage().authorizedSenders[chainId][sender];
    }

    function pendingAuthorizedSenders(uint256 chainId, address sender) external view returns (uint256) {
        return _getStorage().pendingAuthorizedSenders[chainId][sender];
    }

    function pendingMessenger() external view returns (address) {
        return _getStorage().pendingMessenger;
    }

    function pendingMessengerAt() external view returns (uint256) {
        return _getStorage().pendingMessengerAt;
    }

    function pendingSlasher() external view returns (address) {
        return _getStorage().pendingSlasher;
    }

    function pendingSlasherAt() external view returns (uint256) {
        return _getStorage().pendingSlasherAt;
    }

    function processedNonces(uint256 sourceChainId, address sender, uint256 nonce) external view returns (bool) {
        return _getStorage().processedNonces[sourceChainId][sender][nonce];
    }

    function beaconSlashTotal(address operator) external view returns (uint256) {
        return _getStorage().beaconSlashTotal[operator];
    }

    /// @notice Banked slash debt (in bps) owed by an operator that had no slashable L2 stake
    ///         when the slash arrived. Realisable via `flushDeferredSlash` once stake returns.
    function deferredSlashBps(address operator) external view returns (uint256) {
        return _getStorage().deferredSlashBps[operator];
    }

    function opStackMessengerMode() external view returns (bool) {
        return _getStorage().opStackMessengerMode;
    }

    function opStackL1Sender(uint256 sourceChainId) external view returns (address) {
        return _getStorage().opStackL1Sender[sourceChainId];
    }

    /// @notice Pending (scheduled) OP-stack L1 sender + its activation time for a source chain.
    function pendingOpStackL1Sender(uint256 sourceChainId)
        external
        view
        returns (address sender, uint256 activationAt)
    {
        ReceiverStorage storage $ = _getStorage();
        return ($.pendingOpStackL1Sender[sourceChainId], $.pendingOpStackL1SenderAt[sourceChainId]);
    }

    /// @notice Scheduled activation time for a pending OP-stack mode disable (0 if none).
    function opStackModeDisableAt() external view returns (uint256) {
        return _getStorage().opStackModeDisableAt;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // MODIFIERS
    // ═══════════════════════════════════════════════════════════════════════════

    modifier onlyMessenger() {
        _onlyMessenger();
        _;
    }

    function _onlyMessenger() internal view {
        if (msg.sender != _getStorage().messenger) revert UnauthorizedMessenger();
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // CROSS-CHAIN RECEIVE
    // ═══════════════════════════════════════════════════════════════════════════

    /// @inheritdoc ICrossChainReceiver
    /// @dev Cross-chain MEDIUM (forgeable-slash): the calldata `sender` is only
    ///      trustworthy when the configured `messenger` is a dedicated per-bridge
    ///      adapter that has ALREADY authenticated the L1 origin before forwarding:
    ///        - `ArbitrumL2Receiver` — checks `msg.sender == applyL1ToL2Alias(l1Sender)`
    ///        - `BaseL2Receiver`     — checks `l2Messenger.xDomainMessageSender() == l1Sender`
    ///      In all of those paths the adapter passes its own pre-authenticated
    ///      `l1Sender` through as `sender`, so trusting it here is sound.
    ///
    ///      The DANGEROUS path is wiring the OP-stack `L2CrossDomainMessenger`
    ///      SINGLETON directly as `messenger`. That singleton relays messages for
    ///      every L1 actor, so `onlyMessenger` proves nothing about the L1 origin and
    ///      the calldata `sender` is fully attacker-chosen — an attacker simply sets
    ///      it to the real connector address. When `opStackMessengerMode` is enabled
    ///      we therefore DISCARD the calldata `sender` for authorization and derive the
    ///      authenticated L1 sender from `xDomainMessageSender()`, matching it against
    ///      the trusted counterpart registered per source chain.
    function receiveMessage(uint256 sourceChainId, address sender, bytes calldata payload) external onlyMessenger {
        ReceiverStorage storage $ = _getStorage();

        // Authenticate the L1 origin. `authenticatedSender` is the address used for
        // BOTH authorization and downstream nonce namespacing.
        address authenticatedSender;
        if ($.opStackMessengerMode) {
            // The messenger is the OP-stack singleton: the calldata `sender` is
            // attacker-controlled and is ignored. Derive the real L1 sender from the
            // messenger and require it equals the trusted counterpart for this chain.
            address trusted = $.opStackL1Sender[sourceChainId];
            if (trusted == address(0)) revert OpStackSenderNotConfigured(sourceChainId);

            address xDomainSender = IOpStackCrossDomainMessenger($.messenger).xDomainMessageSender();
            if (xDomainSender != trusted) revert UnauthorizedOpStackSender(sourceChainId, xDomainSender);

            authenticatedSender = xDomainSender;
        } else {
            // Dedicated adapter path: the adapter already authenticated the L1 origin
            // and forwarded its own pre-authenticated `l1Sender` as `sender`.
            if (!$.authorizedSenders[sourceChainId][sender]) {
                revert UnauthorizedSender();
            }
            authenticatedSender = sender;
        }

        // Decode and validate payload
        if (payload.length < 4) revert InvalidPayload();

        bytes4 messageType = bytes4(payload[:4]);

        if (messageType == SLASH_MESSAGE_TYPE) {
            _handleSlashMessage($, sourceChainId, authenticatedSender, payload[4:]);
        } else {
            revert InvalidPayload();
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // INTERNAL
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Handle a slash message from L1
    /// @dev Nonce/CEI ordering: a delivered slash ALWAYS consumes its bridge nonce exactly once.
    ///      Two terminal outcomes both consume the nonce:
    ///        1. `canSlash == true`  → the slash is applied immediately.
    ///        2. `canSlash == false` → the operator currently has no slashable L2 stake (e.g.
    ///           they withdrew everything to dodge a pending beacon slash). We BANK the owed bps
    ///           as deferred debt and let `flushDeferredSlash` realise it the moment stake
    ///           returns. Consuming the nonce here is safe because the debt now lives in this
    ///           contract's storage, not in the (single-shot, non-redeliverable) bridge message.
    ///      The earlier design reverted on `canSlash == false`, which let an operator escape the
    ///      slash permanently by zeroing their L2 stake — every redelivery reverted forever.
    ///      The legitimate "zero bps" case (`slashBps == 0`) is still a hard revert: the L1
    ///      connector now fails-closed before shipping a zero-bps message, so receiving one is an
    ///      invalid payload, not a no-op to bank.
    function _handleSlashMessage(
        ReceiverStorage storage $,
        uint256 sourceChainId,
        address sender,
        bytes calldata data
    )
        internal
    {
        // Decode: operator, slashBps, slashingFactor, nonce, podAddress
        (address operator, uint16 slashBps, uint64 slashingFactor, uint256 nonce, address pod) =
            abi.decode(data, (address, uint16, uint64, uint256, address));

        // Revert (not silent return) so the relayer can distinguish "already processed"
        // from "still pending" during retry / partition recovery.
        if ($.processedNonces[sourceChainId][sender][nonce]) {
            revert NonceAlreadyProcessed(sourceChainId, sender, nonce);
        }

        // A zero-bps message is always invalid: the L1 connector fails-closed before shipping one.
        if (slashBps == 0) {
            revert InvalidPayload();
        }

        // F10: bound the incoming bps at receipt (defense-in-depth). The L1 connector already
        // clamps to BPS_DENOMINATOR, but the receiver must not trust an unbounded cross-chain
        // value: a >100% message would inflate the deferred accumulator beyond what any single
        // flush can ever realise, overstating booked debt. A single slash can never exceed 100%.
        if (slashBps > BPS_DENOMINATOR) {
            revert InvalidPayload();
        }

        // The nonce is consumed exactly once regardless of which branch we take below; the slash
        // can no longer be replayed once banked or applied.
        $.processedNonces[sourceChainId][sender][nonce] = true;

        if ($.slasher.canSlash(operator)) {
            // Apply immediately.
            _applySlash($, sourceChainId, operator, slashBps, slashingFactor, pod);
        } else {
            // No slashable stake right now: bank the debt so the operator cannot evade the slash
            // by withdrawing their L2 stake. Realised later via `flushDeferredSlash`.
            uint256 newTotal = $.deferredSlashBps[operator] + slashBps;
            $.deferredSlashBps[operator] = newTotal;
            emit SlashingDeferred(operator, slashBps, newTotal);
        }

        emit SlashingReceived(sourceChainId, operator, slashBps, keccak256(abi.encode(sourceChainId, sender, nonce)));
    }

    /// @notice Apply a slash and book-keep the cumulative beacon slash total.
    /// @dev `slashOperator` reverting here reverts the whole tx (and, for the immediate path,
    ///      un-consumes the nonce), so a slasher that is paused/unavailable never silently drops
    ///      the slash.
    function _applySlash(
        ReceiverStorage storage $,
        uint256 sourceChainId,
        address operator,
        uint16 slashBps,
        uint64 slashingFactor,
        address pod
    )
        internal
    {
        bytes memory reason = abi.encode("BEACON_CHAIN_SLASH", sourceChainId, pod, slashingFactor, block.timestamp);
        $.slasher.slashOperator(operator, slashBps, reason);
        $.beaconSlashTotal[operator] += slashBps;
        emit SlashingExecuted(operator, slashBps, slashingFactor);
    }

    /// @notice Realise an operator's banked deferred slash debt once they regain slashable stake.
    /// @dev Permissionless: the debt is fixed and adversarially favourable to the protocol, so
    ///      anyone may trigger collection (a watcher/keeper, the slasher, or the protocol itself).
    ///      The banked bps are capped to `BPS_DENOMINATOR` so a re-staked operator can never be
    ///      slashed for more than 100% of their stake in a single flush; any excess remains booked
    ///      and is collectable on the next flush after they re-stake again.
    /// @param operator The operator whose deferred slash debt to realise.
    function flushDeferredSlash(address operator) external {
        ReceiverStorage storage $ = _getStorage();
        uint256 owed = $.deferredSlashBps[operator];
        if (owed == 0) revert NoDeferredSlash(operator);
        if (!$.slasher.canSlash(operator)) revert SlashingNotPossible(operator);

        uint16 applyBps = owed > BPS_DENOMINATOR ? BPS_DENOMINATOR : uint16(owed);
        uint256 remaining = owed - applyBps;
        $.deferredSlashBps[operator] = remaining;

        bytes memory reason = abi.encode("BEACON_CHAIN_SLASH_DEFERRED", operator, applyBps, block.timestamp);
        $.slasher.slashOperator(operator, applyBps, reason);
        $.beaconSlashTotal[operator] += applyBps;

        emit SlashingExecuted(operator, applyBps, 0);
        emit DeferredSlashFlushed(operator, applyBps, remaining);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // ADMIN
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Schedule authorization of a sender (subject to timelock)
    /// @dev For revoking authorization, takes effect immediately
    function setAuthorizedSender(uint256 chainId, address sender, bool authorized) external onlyOwner {
        ReceiverStorage storage $ = _getStorage();
        if (!authorized) {
            // Revocation is immediate
            $.authorizedSenders[chainId][sender] = false;
            $.pendingAuthorizedSenders[chainId][sender] = 0;
            emit AuthorizedSenderUpdated(chainId, sender, false);
        } else {
            // Authorization is timelocked
            uint256 activationTime = block.timestamp + SENDER_ACTIVATION_DELAY;
            $.pendingAuthorizedSenders[chainId][sender] = activationTime;
            emit AuthorizedSenderScheduled(chainId, sender, activationTime);
        }
    }

    /// @notice Enable / disable OP-stack direct-delivery mode for the configured messenger.
    /// @dev Set to `true` ONLY when `messenger` is the OP-stack `L2CrossDomainMessenger`
    ///      singleton. In that mode the calldata `sender` is ignored and the L1 origin is
    ///      authenticated via `xDomainMessageSender()` against `opStackL1Sender`. Toggling
    ///      the mode does not by itself authorize any sender — the trusted L1 counterpart
    ///      must be activated through the timelocked `setOpStackL1Sender` /
    ///      `activateOpStackL1Sender` flow below.
    function setOpStackMessengerMode(bool enabled) external onlyOwner {
        ReceiverStorage storage $ = _getStorage();
        if (enabled) {
            // Enabling tightens auth (calldata sender ignored → xDomainMessageSender required),
            // so it is immediate; this also cancels any pending disable.
            $.opStackMessengerMode = true;
            $.opStackModeDisableAt = 0;
            emit OpStackMessengerModeUpdated(true);
        } else {
            // Disabling is the dangerous downgrade (re-trusts the calldata sender). Timelock it
            // so a mode flip cannot silently re-open the forgeable path inside the window every
            // other trust anchor here is protected by. Apply via `activateOpStackMessengerModeDisable`.
            $.opStackModeDisableAt = block.timestamp + SENDER_ACTIVATION_DELAY;
            emit OpStackMessengerModeUpdated(false);
        }
    }

    /// @notice Apply a previously-scheduled OP-stack mode disable after the activation delay.
    function activateOpStackMessengerModeDisable() external onlyOwner {
        ReceiverStorage storage $ = _getStorage();
        uint256 at = $.opStackModeDisableAt;
        if (at == 0) revert SenderNotPending();
        if (block.timestamp < at) revert SenderActivationTooEarly(at);
        $.opStackMessengerMode = false;
        $.opStackModeDisableAt = 0;
        emit OpStackMessengerModeUpdated(false);
    }

    /// @notice Schedule (or immediately revoke) the trusted L1 counterpart for an
    ///         OP-stack source chain. Mirrors `setAuthorizedSender`: authorization is
    ///         timelocked behind `SENDER_ACTIVATION_DELAY`, revocation is immediate.
    /// @dev The trusted counterpart is the `L2SlashingConnector` on the source chain.
    ///      Because OP-stack mode derives the L1 sender from `xDomainMessageSender()`,
    ///      this value is the sole trust anchor for the OP path and so carries the same
    ///      activation delay as `authorizedSenders` — a compromised owner cannot instantly
    ///      repoint it to an attacker-controlled L1 contract.
    function setOpStackL1Sender(uint256 sourceChainId, address l1Sender, bool authorized) external onlyOwner {
        ReceiverStorage storage $ = _getStorage();
        if (!authorized) {
            // Revocation is immediate, and only clears the slot if it currently points
            // at `l1Sender` (so a stale revoke cannot wipe a freshly-rotated anchor).
            if ($.opStackL1Sender[sourceChainId] == l1Sender) {
                $.opStackL1Sender[sourceChainId] = address(0);
                emit OpStackL1SenderUpdated(sourceChainId, address(0));
            }
            $.pendingOpStackL1SenderAt[sourceChainId] = 0;
            return;
        }
        if (l1Sender == address(0)) revert ZeroAddress();
        uint256 activationTime = block.timestamp + SENDER_ACTIVATION_DELAY;
        // Staged in the OP-stack-only mapping. We key only by chainId (one trusted L1
        // counterpart per source chain) and store the pending sender + its activation time.
        $.pendingOpStackL1Sender[sourceChainId] = l1Sender;
        $.pendingOpStackL1SenderAt[sourceChainId] = activationTime;
        emit AuthorizedSenderScheduled(sourceChainId, l1Sender, activationTime);
    }

    /// @notice Activate a pending OP-stack trusted L1 counterpart after the delay elapses.
    function activateOpStackL1Sender(uint256 sourceChainId, address l1Sender) external onlyOwner {
        ReceiverStorage storage $ = _getStorage();
        uint256 activationTime = $.pendingOpStackL1SenderAt[sourceChainId];
        if (activationTime == 0 || $.pendingOpStackL1Sender[sourceChainId] != l1Sender) revert SenderNotPending();
        if (block.timestamp < activationTime) revert SenderActivationTooEarly(activationTime);

        $.opStackL1Sender[sourceChainId] = l1Sender;
        $.pendingOpStackL1SenderAt[sourceChainId] = 0;
        emit OpStackL1SenderUpdated(sourceChainId, l1Sender);
    }

    /// @notice Activate a pending authorized sender after delay
    function activateAuthorizedSender(uint256 chainId, address sender) external onlyOwner {
        ReceiverStorage storage $ = _getStorage();
        uint256 activationTime = $.pendingAuthorizedSenders[chainId][sender];
        if (activationTime == 0) revert SenderNotPending();
        if (block.timestamp < activationTime) revert SenderActivationTooEarly(activationTime);

        $.authorizedSenders[chainId][sender] = true;
        $.pendingAuthorizedSenders[chainId][sender] = 0;
        emit AuthorizedSenderUpdated(chainId, sender, true);
    }

    /// @notice Schedule a messenger swap; takes effect after `SENDER_ACTIVATION_DELAY`.
    /// @dev Without the timelock, a compromised owner can hot-swap the messenger to
    ///      a contract they control and immediately impersonate any previously-
    ///      authorised sender, undercutting the H-4 timelock entirely. The first
    ///      messenger set (when `messenger == address(0)`) is allowed without
    ///      delay so deploy scripts can wire the bridge before any message has
    ///      been processed; subsequent swaps go through the timelock.
    function setMessenger(address _messenger) external onlyOwner {
        if (_messenger == address(0)) revert UnauthorizedMessenger();
        ReceiverStorage storage $ = _getStorage();
        if ($.messenger == address(0)) {
            $.messenger = _messenger;
            emit MessengerUpdated(address(0), _messenger);
            return;
        }
        $.pendingMessenger = _messenger;
        $.pendingMessengerAt = block.timestamp + SENDER_ACTIVATION_DELAY;
        emit MessengerScheduled(_messenger, $.pendingMessengerAt);
    }

    /// @notice Activate a previously-scheduled messenger swap.
    function activateMessenger() external onlyOwner {
        ReceiverStorage storage $ = _getStorage();
        address next = $.pendingMessenger;
        if (next == address(0)) revert SenderNotPending();
        if (block.timestamp < $.pendingMessengerAt) revert SenderActivationTooEarly($.pendingMessengerAt);
        address old = $.messenger;
        $.messenger = next;
        $.pendingMessenger = address(0);
        $.pendingMessengerAt = 0;
        emit MessengerUpdated(old, next);
    }

    /// @notice Schedule a slasher swap; takes effect after `SENDER_ACTIVATION_DELAY`.
    /// @dev First-bootstrap exception mirrors `setMessenger`: when the current
    ///      slasher is unset, allow immediate write so deploy scripts work.
    function setSlasher(address _slasher) external onlyOwner {
        if (_slasher == address(0)) revert UnauthorizedSender();
        ReceiverStorage storage $ = _getStorage();
        if (address($.slasher) == address(0)) {
            $.slasher = IL2Slasher(_slasher);
            emit SlasherUpdated(_slasher);
            return;
        }
        $.pendingSlasher = _slasher;
        $.pendingSlasherAt = block.timestamp + SENDER_ACTIVATION_DELAY;
        emit SlasherScheduled(_slasher, $.pendingSlasherAt);
    }

    /// @notice Activate a previously-scheduled slasher swap.
    function activateSlasher() external onlyOwner {
        ReceiverStorage storage $ = _getStorage();
        address next = $.pendingSlasher;
        if (next == address(0)) revert SenderNotPending();
        if (block.timestamp < $.pendingSlasherAt) revert SenderActivationTooEarly($.pendingSlasherAt);
        $.slasher = IL2Slasher(next);
        $.pendingSlasher = address(0);
        $.pendingSlasherAt = 0;
        emit SlasherUpdated(next);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // VIEW
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Check if a nonce has been processed
    function isNonceProcessed(uint256 sourceChainId, address sender, uint256 nonce) external view returns (bool) {
        return _getStorage().processedNonces[sourceChainId][sender][nonce];
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // UPGRADE AUTHORIZATION (UUPS / C-3)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @inheritdoc UUPSUpgradeable
    /// @dev Only the owner (a multisig or timelock in production) may upgrade the
    ///      implementation. The owner is the same role gating sender / messenger /
    ///      slasher mutations, so upgrade authority is no broader than existing
    ///      admin authority — but concentrated logic still warrants a timelock owner.
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner { }
}
