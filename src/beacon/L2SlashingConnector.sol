// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { ValidatorPodManager } from "./ValidatorPodManager.sol";
import { ICrossChainMessenger } from "./interfaces/ICrossChainMessenger.sol";

interface IBeaconSlashPod {
    function beaconChainSlashingFactor() external view returns (uint64);
    /// @notice Parked execution-layer ETH (in gwei) the pod has accounted via checkpoints.
    /// @dev Tips, partial withdrawals and exited principal already in pod custody. This ETH
    ///      cannot be slashed on the beacon chain, so it must be excluded from the slash base.
    function withdrawableRestakedExecutionLayerGwei() external view returns (uint64);
}

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
/// - OP-Stack (Base/Optimism): native canonical CrossDomainMessenger
/// - Arbitrum: Retryable tickets
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
    /// @dev `registerPodOperator` / `batchRegisterPodOperators` reject an operator the
    ///      PodManager does not recognise, closing the BCN-004 vector where the owner could
    ///      map an arbitrary pod to an arbitrary address and ship slashing against it.
    error NotOperator(address operator);
    error SlashingFactorMismatch(address pod, uint64 expected, uint64 provided);
    /// @dev The factor delta resolves to a zero-bps L2 slash (operator has no L2 stake,
    ///      or the loss is sub-bps and truncates to 0). The L2 receiver hard-reverts on a
    ///      zero-bps message, so shipping one would advance this connector's baseline while
    ///      the L2 slash is permanently rejected — losing the delta and corrupting the
    ///      baseline. We fail-closed BEFORE mutating state so the same delta stays
    ///      re-propagable once the operator regains slashable L2 stake.
    error NothingToSlash(address pod, uint256 destinationChainId);
    /// @dev Caller is not the contract owner (replaces the old "Only owner" string revert).
    error NotOwner();
    /// @dev Paired input arrays have differing lengths (batch propagate / batch register).
    error LengthMismatch();
    /// @dev Native-asset refund/sweep call to the caller failed.
    error RefundFailed();
    /// @dev A self-call-only entrypoint was invoked by an external caller.
    error InternalOnly();

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

    /// @notice Last processed slashing factor per (pod, destination chain id).
    /// @dev Keying by destination is required so the same beacon-chain slash event
    ///      can be relayed to multiple chains; a single global value would freeze
    ///      every other destination after the first relay succeeded.
    mapping(address => mapping(uint256 => uint64)) public lastProcessedSlashingFactorByChain;

    /// @notice Cumulative L2 slash amount per (pod, destination chain id)
    mapping(address => mapping(uint256 => uint256)) public cumulativeSlashAmountByChain;

    /// @notice Per-destination nonce for message deduplication. Scoping by destination
    ///         chain id prevents nonce collisions when multiple connectors or redeploys
    ///         relay slashes to different chains in interleaved order.
    mapping(uint256 => uint256) public nonceByChain;

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
        if (msg.sender != owner) revert NotOwner();
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
    /// @dev Each self-call is funded with the full call-attributable balance so the bridge
    ///      fee is actually paid. Previously the self-calls forwarded `{value: 0}`, so with a
    ///      non-zero relay fee (the production case for OP-Stack/Arbitrum L1→L2 bridges) every
    ///      `_propagateBeaconSlashing` reverted `InsufficientFee`, the `try/catch` swallowed
    ///      it, and the batch silently advanced ZERO slashing factors. `_propagateBeaconSlashing`
    ///      refunds its own excess to `msg.sender` — which for these self-calls is this contract
    ///      — so unspent value returns here and is forwarded to the next pod; any final
    ///      remainder is swept back to the caller. Pre-existing contract funds (`baseline`) are
    ///      never touched.
    function batchPropagateBeaconSlashing(
        address[] calldata pods,
        uint64[] calldata newSlashingFactors
    )
        external
        payable
        onlySlashingOracle
    {
        if (pods.length != newSlashingFactors.length) revert LengthMismatch();

        uint256 baseline = address(this).balance - msg.value;

        for (uint256 i = 0; i < pods.length; i++) {
            // Forward the whole call-attributable balance; the self-call refunds its unused
            // portion back here (refund target is this contract), so the next iteration can
            // reuse it. A caught revert rolls back its value transfer, leaving the balance intact.
            uint256 forwardValue = address(this).balance - baseline;
            try this.propagateBeaconSlashingInternal{ value: forwardValue }(
                pods[i], newSlashingFactors[i], defaultDestinationChainId
            ) { }
                catch { }
        }

        // Sweep any unspent fee budget back to the caller, leaving pre-existing funds in place.
        uint256 leftover = address(this).balance - baseline;
        if (leftover > 0) {
            (bool success,) = msg.sender.call{ value: leftover }("");
            if (!success) revert RefundFailed();
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
        if (msg.sender != address(this)) revert InternalOnly();
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

        uint64 lastFactor = lastProcessedSlashingFactorByChain[pod][destinationChainId];

        // Initialize if first time on this chain
        if (lastFactor == 0) {
            lastFactor = 1e18; // 100%
        }

        // Slashing factor should only decrease
        if (newSlashingFactor >= lastFactor) {
            revert InvalidSlashingFactor();
        }

        // `slashPercentage` is the fraction of THIS pod's beacon balance lost
        // (1e18 == 100%), derived from the pod's own factor delta.
        // (cast to uint256 to avoid overflow)
        uint256 slashPercentage = (uint256(lastFactor - newSlashingFactor) * 1e18) / lastFactor;

        // Get the operator for this pod
        address operator = _getOperatorForPod(pod);
        if (operator == address(0)) {
            return; // Pod not registered, skip
        }

        uint64 actualFactor = IBeaconSlashPod(pod).beaconChainSlashingFactor();
        if (newSlashingFactor != actualFactor) {
            revert SlashingFactorMismatch(pod, actualFactor, newSlashingFactor);
        }

        // INVARIANT: a single pod's beacon slash can never remove more L2 stake than
        // that pod's own contribution to the operator's stake. `slashPercentage` is a
        // fraction of THIS pod's beacon balance, so the absolute loss attributable to
        // the pod is `podPrincipal * slashPercentage`. The shipped `slashBps` is that
        // absolute loss re-expressed against the operator's TOTAL L2 stake, which is the
        // base L2 (`MultiAssetDelegation._slash` / `ValidatorPodManager._slash`) applies
        // it to. This bounds the on-L2 slash to the pod's contribution, eliminating the
        // base mismatch (whole-stake over-slash) and the multi-pod amplification where
        // each pod independently slashed a share of the shared total stake.
        uint256 podPrincipal = _podBeaconPrincipal(pod);
        uint256 podSlashAmount = (podPrincipal * slashPercentage) / 1e18;

        // Operator's TOTAL L2 stake (self + delegated) — the exact base that L2's
        // `_slash` multiplies `slashBps` against. Using delegated-only here would
        // under- or over-state the realised L2 slash relative to the intended amount.
        uint256 operatorStake = podManager.getOperatorStake(operator);

        uint16 slashBps;
        uint256 l2SlashAmount;
        if (operatorStake == 0) {
            slashBps = 0;
            l2SlashAmount = 0;
        } else {
            uint256 bps = (podSlashAmount * 10_000) / operatorStake;
            if (bps > 10_000) bps = 10_000;
            slashBps = uint16(bps);
            // Realised L2 slash amount under the same integer math L2 will apply.
            l2SlashAmount = (operatorStake * slashBps) / 10_000;
        }

        // FAIL-CLOSED before any state mutation: a zero-bps message is hard-rejected by the
        // L2 receiver (`_handleSlashMessage` reverts on `slashBps == 0`). If we advanced the
        // baseline (`lastProcessedSlashingFactorByChain`) and shipped it anyway, the receiver
        // would permanently reject the slash while this connector treats the delta as consumed
        // — losing the slash and corrupting the baseline. Reverting here leaves the same factor
        // delta re-propagable once the operator regains slashable L2 stake (operatorStake > 0),
        // or once the loss is large enough to round to >= 1 bps.
        if (slashBps == 0) {
            revert NothingToSlash(pod, destinationChainId);
        }

        // Update state per destination
        lastProcessedSlashingFactorByChain[pod][destinationChainId] = newSlashingFactor;
        cumulativeSlashAmountByChain[pod][destinationChainId] += l2SlashAmount;

        // Encode the slash message with a destination-scoped nonce.
        uint256 messageNonce = nonceByChain[destinationChainId]++;
        bytes memory payload =
            abi.encodePacked(SLASH_MESSAGE_TYPE, abi.encode(operator, slashBps, newSlashingFactor, messageNonce, pod));

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
            if (!success) revert RefundFailed();
        }

        emit BeaconSlashingPropagated(pod, lastFactor, newSlashingFactor, l2SlashAmount, messageId);
        emit OperatorSlashedFromBeacon(operator, pod, l2SlashAmount, destinationChainId);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // VIEW FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Get the pending slash amount for a pod against a specific destination
    function getPendingSlashAmount(
        address pod,
        uint64 currentSlashingFactor,
        uint256 destinationChainId
    )
        external
        view
        returns (uint256)
    {
        uint64 lastFactor = lastProcessedSlashingFactorByChain[pod][destinationChainId];
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

        // Mirror propagation: scale the slash to the pod's own contribution, then
        // re-express against the operator's total L2 stake (see `_propagateBeaconSlashing`).
        uint256 podPrincipal = _podBeaconPrincipal(pod);
        uint256 podSlashAmount = (podPrincipal * slashPercentage) / 1e18;
        uint256 operatorStake = podManager.getOperatorStake(operator);
        if (operatorStake == 0) return 0;
        uint256 bps = (podSlashAmount * 10_000) / operatorStake;
        if (bps > 10_000) bps = 10_000;
        return (operatorStake * bps) / 10_000;
    }

    /// @notice Check if a pod has pending slashing to propagate to a specific destination
    function hasPendingSlashing(
        address pod,
        uint64 currentSlashingFactor,
        uint256 destinationChainId
    )
        external
        view
        returns (bool)
    {
        uint64 lastFactor = lastProcessedSlashingFactorByChain[pod][destinationChainId];
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
        uint64 lastFactor = lastProcessedSlashingFactorByChain[pod][destinationChainId];
        if (lastFactor == 0) lastFactor = 1e18;

        // Mirror propagation: pod-scaled slash re-expressed against operator total stake.
        // (slashBps is a fixed-width uint16, so its magnitude does not change payload
        //  size; this keeps the estimate consistent with the value actually shipped.)
        uint256 slashPercentage = (uint256(lastFactor - newSlashingFactor) * 1e18) / lastFactor;
        uint256 podPrincipal = _podBeaconPrincipal(pod);
        uint256 podSlashAmount = (podPrincipal * slashPercentage) / 1e18;
        uint256 operatorStake = operator == address(0) ? 0 : podManager.getOperatorStake(operator);
        uint16 slashBps = 0;
        if (operatorStake != 0) {
            uint256 bps = (podSlashAmount * 10_000) / operatorStake;
            if (bps > 10_000) bps = 10_000;
            slashBps = uint16(bps);
        }

        // Use the next-nonce-to-be-issued for accurate fee estimation; do not increment.
        uint256 estimatedNonce = nonceByChain[destinationChainId];
        bytes memory payload = abi.encodePacked(
            SLASH_MESSAGE_TYPE, abi.encode(operator, slashBps, newSlashingFactor, estimatedNonce, pod)
        );

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
    /// @dev BCN-004: validate both legs against the PodManager so the owner cannot map an
    ///      unknown/arbitrary pod to an arbitrary address and then ship a slash against it.
    function registerPodOperator(address pod, address operator) external onlyOwner {
        _validatePodOperator(pod, operator);
        podOperator[pod] = operator;
    }

    /// @notice Batch register pod to operator mappings
    function batchRegisterPodOperators(address[] calldata pods, address[] calldata operators) external onlyOwner {
        if (pods.length != operators.length) revert LengthMismatch();
        for (uint256 i = 0; i < pods.length; i++) {
            _validatePodOperator(pods[i], operators[i]);
            podOperator[pods[i]] = operators[i];
        }
    }

    /// @notice Reject registrations the PodManager does not back: a real pod (non-zero
    ///         owner) mapped to a registered operator. Closes the BCN-004 amplification
    ///         where the owner could fabricate pod→operator pairs to target victims.
    function _validatePodOperator(address pod, address operator) internal view {
        if (pod == address(0) || operator == address(0)) revert ZeroAddress();
        if (podManager.podToOwner(pod) == address(0)) revert UnknownPod(pod);
        if (!podManager.isOperator(operator)) revert NotOperator(operator);
    }

    /// @notice Update the slashing oracle address
    /// @dev BCN-002: reject the zero address so the oracle role cannot be silently bricked
    ///      (mirrors the `transferOwnership` guard below).
    function setSlashingOracle(address newOracle) external onlyOwner {
        if (newOracle == address(0)) revert ZeroAddress();
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

    /// @notice Beacon principal (in wei) still exposed to beacon-chain slashing for `pod`.
    /// @dev BCN-001: `totalAssetsOf` aggregates beacon principal PLUS parked execution-layer
    ///      ETH (tips, partial withdrawals and exited principal already in pod custody,
    ///      credited via `recordBeaconChainRebase`). That parked ETH can never be slashed on
    ///      the beacon chain, so including it in the slash base over-states the loss and lets
    ///      a modest beacon slash saturate `slashBps` at 100% of the operator's L2 stake.
    ///      Slash only against on-beacon principal: `totalAssets` minus the parked tally the
    ///      pod tracks (`withdrawableRestakedExecutionLayerGwei`).
    function _podBeaconPrincipal(address pod) internal view returns (uint256) {
        uint256 totalAssets = podManager.totalAssetsOf(podManager.podToOwner(pod));
        uint256 parkedWei = uint256(IBeaconSlashPod(pod).withdrawableRestakedExecutionLayerGwei()) * 1 gwei;
        return totalAssets > parkedWei ? totalAssets - parkedWei : 0;
    }

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
