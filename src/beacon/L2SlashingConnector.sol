// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { ValidatorPodManager } from "./ValidatorPodManager.sol";
import { ICrossChainMessenger } from "./interfaces/ICrossChainMessenger.sol";

/// @title L2SlashingConnector
/// @notice Connects beacon chain slashing events to Tangle L2 slashing mechanism
/// @dev This contract bridges between beacon chain native staking and Tangle's L2 slashing
///
/// Architecture:
/// 1. Beacon chain slashing is detected via ValidatorPod.verifyStaleBalance()
/// 2. This triggers beaconChainSlashingFactor reduction in ValidatorPod
/// 3. L2SlashingConnector observes these events and sends cross-chain message
/// 4. L2SlashingReceiver receives message and executes slashing on L2
///
/// Chain-agnostic: Works with any ICrossChainMessenger implementation:
/// - Base: Native L1→L2 messaging
/// - Arbitrum: Retryable tickets
/// - Tempo: Custom bridge
/// - LayerZero: OApp messaging
/// - Axelar: GMP
/// - Hyperlane: Mailbox
contract L2SlashingConnector {
    // ═══════════════════════════════════════════════════════════════════════════
    // ERRORS
    // ═══════════════════════════════════════════════════════════════════════════

    error OnlySlashingOracle();
    error InvalidSlashingFactor();
    error SlashingAlreadyProcessed();
    error ZeroAddress();
    error InsufficientFee();
    error UnsupportedDestinationChain();
    error MessengerNotConfigured();
    error UnknownPod(address pod);

    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Emitted when a beacon chain slashing is propagated to L2
    event BeaconSlashingPropagated(
        address indexed pod, uint64 oldFactor, uint64 newFactor, uint256 l2SlashAmount, bytes32 messageId
    );

    /// @notice Emitted when an operator is slashed on L2 due to beacon slashing
    event OperatorSlashedFromBeacon(
        address indexed operator, address indexed pod, uint256 amount, uint256 destinationChainId
    );

    /// @notice Emitted when the slashing oracle is updated
    event SlashingOracleUpdated(address indexed oldOracle, address indexed newOracle);

    /// @notice Emitted when cross-chain config is updated
    event CrossChainConfigUpdated(uint256 indexed chainId, address receiver, uint256 gasLimit);

    /// @notice Emitted when messenger is updated
    event MessengerUpdated(address indexed oldMessenger, address indexed newMessenger);

    // ═══════════════════════════════════════════════════════════════════════════
    // CONSTANTS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Message type identifier for slashing
    bytes4 public constant SLASH_MESSAGE_TYPE = bytes4(keccak256("BEACON_SLASH"));

    // ═══════════════════════════════════════════════════════════════════════════
    // STRUCTS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Configuration for a destination chain
    struct ChainConfig {
        address receiver; // L2SlashingReceiver address on destination
        uint256 gasLimit; // Gas limit for execution on destination
        bool enabled; // Whether this destination is enabled
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // STATE
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice The ValidatorPodManager contract
    // forge-lint: disable-next-line(screaming-snake-case-immutable)
    ValidatorPodManager public immutable podManager;

    /// @notice The cross-chain messenger (bridge-agnostic)
    ICrossChainMessenger public messenger;

    /// @notice Address authorized to trigger slashing propagation
    address public slashingOracle;

    /// @notice Owner address
    address public owner;

    /// @notice Default destination chain ID (e.g., Tangle L2)
    uint256 public defaultDestinationChainId;

    /// @notice Chain configurations (chainId => config)
    mapping(uint256 => ChainConfig) public chainConfigs;

    /// @notice Mapping of pod -> last processed slashing factor
    mapping(address => uint64) public lastProcessedSlashingFactor;

    /// @notice Mapping of pod -> cumulative L2 slash amount
    mapping(address => uint256) public cumulativeSlashAmount;

    /// @notice Nonce for message deduplication
    uint256 public nonce;

    /// @notice Pod to operator mapping
    mapping(address => address) public podOperator;

    // ═══════════════════════════════════════════════════════════════════════════
    // CONSTRUCTOR
    // ═══════════════════════════════════════════════════════════════════════════

    constructor(address _podManager, address _slashingOracle) {
        if (_podManager == address(0)) revert ZeroAddress();
        podManager = ValidatorPodManager(_podManager);
        slashingOracle = _slashingOracle;
        owner = msg.sender;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // MODIFIERS
    // ═══════════════════════════════════════════════════════════════════════════

    modifier onlySlashingOracle() {
        _onlySlashingOracle();
        _;
    }

    function _onlySlashingOracle() internal view {
        if (msg.sender != slashingOracle && msg.sender != owner) {
            revert OnlySlashingOracle();
        }
    }

    modifier onlyOwner() {
        _onlyOwner();
        _;
    }

    function _onlyOwner() internal view {
        require(msg.sender == owner, "Only owner");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SLASHING PROPAGATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Propagate beacon chain slashing to L2
    /// @param pod The ValidatorPod that was slashed on beacon chain
    /// @param newSlashingFactor The new beaconChainSlashingFactor from the pod
    /// @dev Called by the slashing oracle when it detects a slashing factor decrease
    function propagateBeaconSlashing(address pod, uint64 newSlashingFactor) external payable onlySlashingOracle {
        _propagateBeaconSlashing(pod, newSlashingFactor, defaultDestinationChainId);
    }

    /// @notice Propagate beacon chain slashing to a specific chain
    /// @param pod The ValidatorPod that was slashed
    /// @param newSlashingFactor The new slashing factor
    /// @param destinationChainId Target chain for slashing
    function propagateBeaconSlashingToChain(
        address pod,
        uint64 newSlashingFactor,
        uint256 destinationChainId
    )
        external
        payable
        onlySlashingOracle
    {
        _propagateBeaconSlashing(pod, newSlashingFactor, destinationChainId);
    }

    /// @notice Batch propagate multiple beacon slashings
    /// @param pods Array of pods to process
    /// @param newSlashingFactors Corresponding slashing factors
    function batchPropagateBeaconSlashing(
        address[] calldata pods,
        uint64[] calldata newSlashingFactors
    )
        external
        payable
        onlySlashingOracle
    {
        require(pods.length == newSlashingFactors.length, "Length mismatch");

        for (uint256 i = 0; i < pods.length; i++) {
            // Try to propagate, continue on failure
            try this.propagateBeaconSlashingInternal{ value: 0 }(
                pods[i], newSlashingFactors[i], defaultDestinationChainId
            ) { }
                catch { }
        }
    }

    /// @notice Internal propagation (for try/catch in batch)
    function propagateBeaconSlashingInternal(
        address pod,
        uint64 newSlashingFactor,
        uint256 destinationChainId
    )
        external
        payable
    {
        require(msg.sender == address(this), "Internal only");
        _propagateBeaconSlashing(pod, newSlashingFactor, destinationChainId);
    }

    function _propagateBeaconSlashing(address pod, uint64 newSlashingFactor, uint256 destinationChainId) internal {
        // Validate chain config
        ChainConfig memory config = chainConfigs[destinationChainId];
        if (!config.enabled || config.receiver == address(0)) {
            revert UnsupportedDestinationChain();
        }

        if (address(messenger) == address(0)) {
            revert MessengerNotConfigured();
        }

        uint64 lastFactor = lastProcessedSlashingFactor[pod];

        // Initialize if first time
        if (lastFactor == 0) {
            lastFactor = 1e18; // 100%
        }

        // Slashing factor should only decrease
        if (newSlashingFactor >= lastFactor) {
            revert InvalidSlashingFactor();
        }

        // Calculate the slash percentage (cast to uint256 to avoid overflow)
        uint256 slashPercentage = (uint256(lastFactor - newSlashingFactor) * 1e18) / lastFactor;
        uint16 slashBps = uint16((slashPercentage * 10_000) / 1e18);
        if (slashBps > 10_000) slashBps = 10_000;

        // Get the operator for this pod
        address operator = _getOperatorForPod(pod);
        if (operator == address(0)) {
            return; // Pod not registered, skip
        }

        // Calculate L2 slash amount based on operator's total delegated stake
        uint256 operatorStake = podManager.operatorDelegatedStake(operator);
        uint256 l2SlashAmount = (operatorStake * slashPercentage) / 1e18;

        // Update state
        lastProcessedSlashingFactor[pod] = newSlashingFactor;
        cumulativeSlashAmount[pod] += l2SlashAmount;

        // Encode the slash message
        bytes memory payload =
            abi.encodePacked(SLASH_MESSAGE_TYPE, abi.encode(operator, slashBps, newSlashingFactor, nonce++, pod));

        // Estimate fee and validate
        uint256 fee = messenger.estimateFee(destinationChainId, payload, config.gasLimit);
        if (msg.value < fee) {
            revert InsufficientFee();
        }

        // Send cross-chain message
        bytes32 messageId =
            messenger.sendMessage{ value: fee }(destinationChainId, config.receiver, payload, config.gasLimit);

        // Refund excess
        if (msg.value > fee) {
            (bool success,) = msg.sender.call{ value: msg.value - fee }("");
            require(success, "Refund failed");
        }

        emit BeaconSlashingPropagated(pod, lastFactor, newSlashingFactor, l2SlashAmount, messageId);
        emit OperatorSlashedFromBeacon(operator, pod, l2SlashAmount, destinationChainId);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // VIEW FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Get the pending slash amount for a pod
    function getPendingSlashAmount(address pod, uint64 currentSlashingFactor) external view returns (uint256) {
        uint64 lastFactor = lastProcessedSlashingFactor[pod];
        if (lastFactor == 0) {
            lastFactor = 1e18;
        }

        if (currentSlashingFactor >= lastFactor) {
            return 0;
        }

        uint256 slashPercentage = (uint256(lastFactor - currentSlashingFactor) * 1e18) / lastFactor;

        address operator = _getOperatorForPod(pod);
        if (operator == address(0)) {
            return 0;
        }

        uint256 operatorStake = podManager.operatorDelegatedStake(operator);
        return (operatorStake * slashPercentage) / 1e18;
    }

    /// @notice Check if a pod has pending slashing to propagate
    function hasPendingSlashing(address pod, uint64 currentSlashingFactor) external view returns (bool) {
        uint64 lastFactor = lastProcessedSlashingFactor[pod];
        if (lastFactor == 0) {
            lastFactor = 1e18;
        }
        return currentSlashingFactor < lastFactor;
    }

    /// @notice Estimate fee for propagating slashing
    function estimatePropagationFee(
        address pod,
        uint64 newSlashingFactor,
        uint256 destinationChainId
    )
        external
        view
        returns (uint256)
    {
        if (address(messenger) == address(0)) return 0;

        ChainConfig memory config = chainConfigs[destinationChainId];
        if (!config.enabled) return 0;

        address operator = _getOperatorForPod(pod);
        uint64 lastFactor = lastProcessedSlashingFactor[pod];
        if (lastFactor == 0) lastFactor = 1e18;

        uint256 slashPercentage = (uint256(lastFactor - newSlashingFactor) * 1e18) / lastFactor;
        uint16 slashBps = uint16((slashPercentage * 10_000) / 1e18);
        if (slashBps > 10_000) slashBps = 10_000;

        bytes memory payload =
            abi.encodePacked(SLASH_MESSAGE_TYPE, abi.encode(operator, slashBps, newSlashingFactor, nonce, pod));

        return messenger.estimateFee(destinationChainId, payload, config.gasLimit);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // ADMIN FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Set the cross-chain messenger
    function setMessenger(address _messenger) external onlyOwner {
        address old = address(messenger);
        messenger = ICrossChainMessenger(_messenger);
        emit MessengerUpdated(old, _messenger);
    }

    /// @notice Configure a destination chain
    function setChainConfig(uint256 chainId, address receiver, uint256 gasLimit, bool enabled) external onlyOwner {
        chainConfigs[chainId] = ChainConfig({ receiver: receiver, gasLimit: gasLimit, enabled: enabled });
        emit CrossChainConfigUpdated(chainId, receiver, gasLimit);
    }

    /// @notice Set the default destination chain
    function setDefaultDestinationChain(uint256 chainId) external onlyOwner {
        defaultDestinationChainId = chainId;
    }

    /// @notice Register pod to operator mapping
    function registerPodOperator(address pod, address operator) external onlyOwner {
        podOperator[pod] = operator;
    }

    /// @notice Batch register pod to operator mappings
    function batchRegisterPodOperators(address[] calldata pods, address[] calldata operators) external onlyOwner {
        require(pods.length == operators.length, "Length mismatch");
        for (uint256 i = 0; i < pods.length; i++) {
            podOperator[pods[i]] = operators[i];
        }
    }

    /// @notice Update the slashing oracle address
    function setSlashingOracle(address newOracle) external onlyOwner {
        address oldOracle = slashingOracle;
        slashingOracle = newOracle;
        emit SlashingOracleUpdated(oldOracle, newOracle);
    }

    /// @notice Transfer ownership
    function transferOwnership(address newOwner) external onlyOwner {
        if (newOwner == address(0)) revert ZeroAddress();
        owner = newOwner;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // INTERNAL FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Get the operator address for a pod
    function _getOperatorForPod(address pod) internal view returns (address) {
        address operator = podOperator[pod];
        if (operator != address(0)) {
            return operator;
        }
        revert UnknownPod(pod);
    }

    /// @notice Allow contract to receive ETH for fee payments
    receive() external payable { }
}
