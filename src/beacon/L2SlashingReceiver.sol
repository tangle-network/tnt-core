// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {ICrossChainReceiver} from "./interfaces/ICrossChainMessenger.sol";

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

    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    event SlashingReceived(
        uint256 indexed sourceChainId,
        address indexed operator,
        uint16 slashBps,
        bytes32 messageId
    );

    event SlashingExecuted(
        address indexed operator,
        uint16 slashBps,
        uint64 slashingFactor
    );

    event AuthorizedSenderUpdated(uint256 indexed chainId, address indexed sender, bool authorized);
    event AuthorizedSenderScheduled(uint256 indexed chainId, address indexed sender, uint256 activationTime);
    event MessengerUpdated(address indexed oldMessenger, address indexed newMessenger);

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
    function receiveMessage(
        uint256 sourceChainId,
        address sender,
        bytes calldata payload
    ) external onlyMessenger {
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
    function _handleSlashMessage(
        uint256 sourceChainId,
        address sender,
        bytes calldata data
    ) internal {
        // Decode: operator, slashBps, slashingFactor, nonce, podAddress
        (
            address operator,
            uint16 slashBps,
            uint64 slashingFactor,
            uint256 nonce,
            address pod
        ) = abi.decode(data, (address, uint16, uint64, uint256, address));

        // Check nonce hasn't been processed (replay protection)
        if (processedNonces[sourceChainId][sender][nonce]) {
            return; // Silently ignore duplicate
        }
        processedNonces[sourceChainId][sender][nonce] = true;

        // Create reason bytes for audit trail
        bytes memory reason = abi.encode(
            "BEACON_CHAIN_SLASH",
            sourceChainId,
            pod,
            slashingFactor,
            block.timestamp
        );

        // Execute slashing
        if (slasher.canSlash(operator) && slashBps > 0) {
            slasher.slashOperator(operator, slashBps, reason);
            beaconSlashTotal[operator] += slashBps;

            emit SlashingExecuted(operator, slashBps, slashingFactor);
        }

        emit SlashingReceived(
            sourceChainId,
            operator,
            slashBps,
            keccak256(abi.encode(sourceChainId, sender, nonce))
        );
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // ADMIN
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice H-4 FIX: Schedule authorization of a sender (subject to timelock)
    /// @dev For revoking authorization, takes effect immediately
    function setAuthorizedSender(
        uint256 chainId,
        address sender,
        bool authorized
    ) external onlyOwner {
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

    /// @notice Update the messenger address
    function setMessenger(address _messenger) external onlyOwner {
        address old = messenger;
        messenger = _messenger;
        emit MessengerUpdated(old, _messenger);
    }

    /// @notice Update the slasher contract
    function setSlasher(address _slasher) external onlyOwner {
        slasher = IL2Slasher(_slasher);
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
    function isNonceProcessed(
        uint256 sourceChainId,
        address sender,
        uint256 nonce
    ) external view returns (bool) {
        return processedNonces[sourceChainId][sender][nonce];
    }
}
