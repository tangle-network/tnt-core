// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

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
/// @dev Deploy this on Tangle L2 (or any destination chain)
contract L2SlashingReceiver is ICrossChainReceiver {
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

    /// @notice H-4 FIX: Delay before new authorized senders become active
    uint256 public constant SENDER_ACTIVATION_DELAY = 2 days;

    // ═══════════════════════════════════════════════════════════════════════════
    // STATE
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice The L2 slasher contract
    IL2Slasher public slasher;

    /// @notice The cross-chain messenger that can call receiveMessage
    address public messenger;

    /// @notice Owner address
    address public owner;

    /// @notice Authorized senders per source chain (chainId => sender => authorized)
    mapping(uint256 => mapping(address => bool)) public authorizedSenders;

    /// @notice H-4 FIX: Pending authorized senders with activation timestamp
    /// @dev chainId => sender => activation timestamp (0 means not pending)
    mapping(uint256 => mapping(address => uint256)) public pendingAuthorizedSenders;

    /// @notice Cross-chain auditor C-2: a compromised owner could otherwise hot-swap
    ///         the messenger / slasher and impersonate any authorised sender,
    ///         undercutting the H-4 timelock entirely. Both swaps now require the
    ///         same SENDER_ACTIVATION_DELAY queue.
    address public pendingMessenger;
    uint256 public pendingMessengerAt;
    address public pendingSlasher;
    uint256 public pendingSlasherAt;

    /// @notice Nonce for deduplication (sourceChain => sender => nonce => processed)
    mapping(uint256 => mapping(address => mapping(uint256 => bool))) public processedNonces;

    /// @notice Cumulative slash bps per operator from beacon chain
    mapping(address => uint256) public beaconSlashTotal;

    // ═══════════════════════════════════════════════════════════════════════════
    // CONSTRUCTOR
    // ═══════════════════════════════════════════════════════════════════════════

    constructor(address _slasher, address _messenger) {
        slasher = IL2Slasher(_slasher);
        messenger = _messenger;
        owner = msg.sender;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // MODIFIERS
    // ═══════════════════════════════════════════════════════════════════════════

    modifier onlyMessenger() {
        _onlyMessenger();
        _;
    }

    function _onlyMessenger() internal view {
        if (msg.sender != messenger) revert UnauthorizedMessenger();
    }

    modifier onlyOwner() {
        _onlyOwner();
        _;
    }

    function _onlyOwner() internal view {
        require(msg.sender == owner, "Only owner");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // CROSS-CHAIN RECEIVE
    // ═══════════════════════════════════════════════════════════════════════════

    /// @inheritdoc ICrossChainReceiver
    function receiveMessage(uint256 sourceChainId, address sender, bytes calldata payload) external onlyMessenger {
        // Verify sender is authorized for this source chain
        if (!authorizedSenders[sourceChainId][sender]) {
            revert UnauthorizedSender();
        }

        // Decode and validate payload
        if (payload.length < 4) revert InvalidPayload();

        bytes4 messageType = bytes4(payload[:4]);

        if (messageType == SLASH_MESSAGE_TYPE) {
            _handleSlashMessage(sourceChainId, sender, payload[4:]);
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
    function _handleSlashMessage(uint256 sourceChainId, address sender, bytes calldata data) internal {
        // Decode: operator, slashBps, slashingFactor, nonce, podAddress
        (address operator, uint16 slashBps, uint64 slashingFactor, uint256 nonce, address pod) =
            abi.decode(data, (address, uint16, uint64, uint256, address));

        // Revert (not silent return) so the relayer can distinguish "already processed"
        // from "still pending" during retry / partition recovery.
        if (processedNonces[sourceChainId][sender][nonce]) {
            revert NonceAlreadyProcessed(sourceChainId, sender, nonce);
        }

        // Refuse to mark the nonce processed unless the slash is going to apply. If the
        // slasher cannot apply the slash right now (paused, unknown operator, etc.) we
        // revert so the bridge layer keeps the message available for retry.
        if (slashBps == 0) {
            revert InvalidPayload();
        }
        if (!slasher.canSlash(operator)) {
            revert SlashingNotPossible(operator);
        }

        // Apply the slash FIRST (state-changing), then mark the nonce processed.
        // If `slashOperator` reverts, the whole tx reverts and the nonce stays open.
        bytes memory reason = abi.encode("BEACON_CHAIN_SLASH", sourceChainId, pod, slashingFactor, block.timestamp);
        slasher.slashOperator(operator, slashBps, reason);
        beaconSlashTotal[operator] += slashBps;

        processedNonces[sourceChainId][sender][nonce] = true;

        emit SlashingExecuted(operator, slashBps, slashingFactor);
        emit SlashingReceived(sourceChainId, operator, slashBps, keccak256(abi.encode(sourceChainId, sender, nonce)));
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // ADMIN
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice H-4 FIX: Schedule authorization of a sender (subject to timelock)
    /// @dev For revoking authorization, takes effect immediately
    function setAuthorizedSender(uint256 chainId, address sender, bool authorized) external onlyOwner {
        if (!authorized) {
            // Revocation is immediate
            authorizedSenders[chainId][sender] = false;
            pendingAuthorizedSenders[chainId][sender] = 0;
            emit AuthorizedSenderUpdated(chainId, sender, false);
        } else {
            // Authorization is timelocked
            uint256 activationTime = block.timestamp + SENDER_ACTIVATION_DELAY;
            pendingAuthorizedSenders[chainId][sender] = activationTime;
            emit AuthorizedSenderScheduled(chainId, sender, activationTime);
        }
    }

    /// @notice H-4 FIX: Activate a pending authorized sender after delay
    function activateAuthorizedSender(uint256 chainId, address sender) external onlyOwner {
        uint256 activationTime = pendingAuthorizedSenders[chainId][sender];
        if (activationTime == 0) revert SenderNotPending();
        if (block.timestamp < activationTime) revert SenderActivationTooEarly(activationTime);

        authorizedSenders[chainId][sender] = true;
        pendingAuthorizedSenders[chainId][sender] = 0;
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
        if (messenger == address(0)) {
            messenger = _messenger;
            emit MessengerUpdated(address(0), _messenger);
            return;
        }
        pendingMessenger = _messenger;
        pendingMessengerAt = block.timestamp + SENDER_ACTIVATION_DELAY;
        emit MessengerScheduled(_messenger, pendingMessengerAt);
    }

    /// @notice Activate a previously-scheduled messenger swap.
    function activateMessenger() external onlyOwner {
        address next = pendingMessenger;
        if (next == address(0)) revert SenderNotPending();
        if (block.timestamp < pendingMessengerAt) revert SenderActivationTooEarly(pendingMessengerAt);
        address old = messenger;
        messenger = next;
        pendingMessenger = address(0);
        pendingMessengerAt = 0;
        emit MessengerUpdated(old, next);
    }

    /// @notice Schedule a slasher swap; takes effect after `SENDER_ACTIVATION_DELAY`.
    /// @dev First-bootstrap exception mirrors `setMessenger`: when the current
    ///      slasher is unset, allow immediate write so deploy scripts work.
    function setSlasher(address _slasher) external onlyOwner {
        if (_slasher == address(0)) revert UnauthorizedSender();
        if (address(slasher) == address(0)) {
            slasher = IL2Slasher(_slasher);
            emit SlasherUpdated(_slasher);
            return;
        }
        pendingSlasher = _slasher;
        pendingSlasherAt = block.timestamp + SENDER_ACTIVATION_DELAY;
        emit SlasherScheduled(_slasher, pendingSlasherAt);
    }

    /// @notice Activate a previously-scheduled slasher swap.
    function activateSlasher() external onlyOwner {
        address next = pendingSlasher;
        if (next == address(0)) revert SenderNotPending();
        if (block.timestamp < pendingSlasherAt) revert SenderActivationTooEarly(pendingSlasherAt);
        slasher = IL2Slasher(next);
        pendingSlasher = address(0);
        pendingSlasherAt = 0;
        emit SlasherUpdated(next);
    }

    /// @notice Transfer ownership
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Zero address");
        owner = newOwner;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // VIEW
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Check if a nonce has been processed
    function isNonceProcessed(uint256 sourceChainId, address sender, uint256 nonce) external view returns (bool) {
        return processedNonces[sourceChainId][sender][nonce];
    }
}
