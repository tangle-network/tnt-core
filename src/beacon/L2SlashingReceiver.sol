// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { OwnableUpgradeable } from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import { ICrossChainReceiver } from "./interfaces/ICrossChainMessenger.sol";

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

    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    event SlashingReceived(uint256 indexed sourceChainId, address indexed operator, uint16 slashBps, bytes32 messageId);

    event SlashingExecuted(address indexed operator, uint16 slashBps, uint64 slashingFactor);

    event AuthorizedSenderUpdated(uint256 indexed chainId, address indexed sender, bool authorized);
    event AuthorizedSenderScheduled(uint256 indexed chainId, address indexed sender, uint256 activationTime);
    event MessengerScheduled(address indexed newMessenger, uint256 activationTime);
    event MessengerUpdated(address indexed oldMessenger, address indexed newMessenger);
    event SlasherScheduled(address indexed newSlasher, uint256 activationTime);
    event SlasherUpdated(address indexed newSlasher);

    // ═══════════════════════════════════════════════════════════════════════════
    // CONSTANTS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Message type for beacon chain slashing
    bytes4 public constant SLASH_MESSAGE_TYPE = bytes4(keccak256("BEACON_SLASH"));

    /// @notice Delay before new authorized senders become active
    uint256 public constant SENDER_ACTIVATION_DELAY = 2 days;

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
        // Reserved storage for future upgrades. Keep this LAST.
        uint256[50] __gap;
    }

    /// @notice ERC-7201 slot:
    ///         keccak256(abi.encode(uint256(keccak256("tangle.beacon.L2SlashingReceiver")) - 1))
    ///         & ~bytes32(uint256(0xff))
    bytes32 private constant RECEIVER_STORAGE_SLOT =
        0x82055dbb59125fee25966888e9f62ec781a4d1c7ca467f7e3e2e55d698dfc400;

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
    function receiveMessage(uint256 sourceChainId, address sender, bytes calldata payload) external onlyMessenger {
        ReceiverStorage storage $ = _getStorage();

        // Verify sender is authorized for this source chain
        if (!$.authorizedSenders[sourceChainId][sender]) {
            revert UnauthorizedSender();
        }

        // Decode and validate payload
        if (payload.length < 4) revert InvalidPayload();

        bytes4 messageType = bytes4(payload[:4]);

        if (messageType == SLASH_MESSAGE_TYPE) {
            _handleSlashMessage($, sourceChainId, sender, payload[4:]);
        } else {
            revert InvalidPayload();
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // INTERNAL
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Handle a slash message from L1
    /// @dev Critical CEI ordering: the slash must apply BEFORE the nonce is consumed.
    ///      A previous version flipped the nonce to "processed" first, which meant
    ///      transient failures (`canSlash == false` because the operator just
    ///      unregistered, slashing paused, etc.) silently dropped the slash with no
    ///      retry path — the bridge cannot redeliver an already-consumed nonce. The
    ///      legitimate "applied with zero bps" case (`slashBps == 0`) is also a hard
    ///      revert here so the L1 connector never wastes a bridge fee on a no-op.
    function _handleSlashMessage(
        ReceiverStorage storage $,
        uint256 sourceChainId,
        address sender,
        bytes calldata data
    ) internal {
        // Decode: operator, slashBps, slashingFactor, nonce, podAddress
        (address operator, uint16 slashBps, uint64 slashingFactor, uint256 nonce, address pod) =
            abi.decode(data, (address, uint16, uint64, uint256, address));

        // Revert (not silent return) so the relayer can distinguish "already processed"
        // from "still pending" during retry / partition recovery.
        if ($.processedNonces[sourceChainId][sender][nonce]) {
            revert NonceAlreadyProcessed(sourceChainId, sender, nonce);
        }

        // Refuse to mark the nonce processed unless the slash is going to apply. If the
        // slasher cannot apply the slash right now (paused, unknown operator, etc.) we
        // revert so the bridge layer keeps the message available for retry.
        if (slashBps == 0) {
            revert InvalidPayload();
        }
        if (!$.slasher.canSlash(operator)) {
            revert SlashingNotPossible(operator);
        }

        // Apply the slash FIRST (state-changing), then mark the nonce processed.
        // If `slashOperator` reverts, the whole tx reverts and the nonce stays open.
        bytes memory reason = abi.encode("BEACON_CHAIN_SLASH", sourceChainId, pod, slashingFactor, block.timestamp);
        $.slasher.slashOperator(operator, slashBps, reason);
        $.beaconSlashTotal[operator] += slashBps;

        $.processedNonces[sourceChainId][sender][nonce] = true;

        emit SlashingExecuted(operator, slashBps, slashingFactor);
        emit SlashingReceived(sourceChainId, operator, slashBps, keccak256(abi.encode(sourceChainId, sender, nonce)));
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
