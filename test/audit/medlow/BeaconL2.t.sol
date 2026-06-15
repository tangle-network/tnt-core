// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test } from "forge-std/Test.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import { L2SlashingConnector } from "../../../src/beacon/L2SlashingConnector.sol";
import { L2SlashingReceiver, IL2Slasher } from "../../../src/beacon/L2SlashingReceiver.sol";

/// @title Beacon → L2 slashing audit regression tests (MED/LOW unit: beacon-l2)
/// @notice Each test asserts a SECURE invariant introduced by the remediation in
///         L2SlashingConnector.sol / L2SlashingReceiver.sol. Reverting either fix makes the
///         matching test fail:
///
///   MEDIUM (connector zero-bps baseline corruption):
///     A factor decrease that resolves to a 0-bps L2 slash (operator has no L2 stake, or the
///     loss truncates sub-bps) used to advance the connector's per-destination baseline AND
///     ship the message. The receiver hard-reverts on a 0-bps message, so the slash was lost
///     and the baseline corrupted (the same delta could never be re-propagated). The fix
///     reverts `NothingToSlash` BEFORE mutating state, leaving the delta re-propagable.
///
///   MEDIUM (operator evades beacon slash by zeroing L2 stake):
///     The receiver used to revert the whole tx forever on `!canSlash(operator)`. An operator
///     who withdrew all L2 stake escaped the slash permanently (the bridge nonce is single-shot
///     and cannot be redelivered). The fix banks the owed bps as deferred debt, consumes the
///     nonce, and lets anyone realise the debt via `flushDeferredSlash` once stake returns.

// ──────────────────────────────────────────────────────────────────────────────
// Mocks
// ──────────────────────────────────────────────────────────────────────────────

/// @notice Minimal stand-in for `ValidatorPodManager` exposing only the selectors the
///         connector reads: `podToOwner`, `totalAssetsOf`, `getOperatorStake`.
contract MockPodManager {
    mapping(address => address) public podToOwner;
    mapping(address => uint256) internal _totalAssetsOf;
    mapping(address => uint256) internal _operatorStake;

    function setPodOwner(address pod, address owner) external {
        podToOwner[pod] = owner;
    }

    function setTotalAssetsOf(address owner, uint256 amount) external {
        _totalAssetsOf[owner] = amount;
    }

    function setOperatorStake(address operator, uint256 amount) external {
        _operatorStake[operator] = amount;
    }

    function totalAssetsOf(address owner) external view returns (uint256) {
        return _totalAssetsOf[owner];
    }

    function getOperatorStake(address operator) external view returns (uint256) {
        return _operatorStake[operator];
    }
}

/// @notice Pod that reports a controllable `beaconChainSlashingFactor`.
contract MockSlashPod {
    uint64 public factor;

    function setFactor(uint64 f) external {
        factor = f;
    }

    function beaconChainSlashingFactor() external view returns (uint64) {
        return factor;
    }
}

/// @notice Cross-chain messenger that always quotes a zero fee and records the last payload.
contract MockMessenger {
    bytes public lastPayload;
    uint256 public sendCount;

    function estimateFee(uint256, bytes calldata, uint256) external pure returns (uint256) {
        return 0;
    }

    function sendMessage(
        uint256,
        address,
        bytes calldata payload,
        uint256
    )
        external
        payable
        returns (bytes32)
    {
        lastPayload = payload;
        sendCount += 1;
        return keccak256(payload);
    }

    function isChainSupported(uint256) external pure returns (bool) {
        return true;
    }
}

/// @notice Slasher whose `canSlash` and recorded slashes are fully controllable, so the test can
///         simulate an operator with zero slashable stake (evasion) and then re-staking.
contract MockSlasher is IL2Slasher {
    bool public slashable;
    uint256 public totalSlashedBps;
    uint16 public lastSlashBps;
    uint256 public slashCalls;

    function setSlashable(bool s) external {
        slashable = s;
    }

    function slashOperator(address, uint16 slashBps, bytes calldata) external override {
        lastSlashBps = slashBps;
        totalSlashedBps += slashBps;
        slashCalls += 1;
    }

    function canSlash(address) external view override returns (bool) {
        return slashable;
    }

    function getSlashableStake(address) external view override returns (uint256) {
        return slashable ? 1 ether : 0;
    }
}

// ──────────────────────────────────────────────────────────────────────────────
// Connector tests — MEDIUM: zero-bps fail-closed before state mutation
// ──────────────────────────────────────────────────────────────────────────────

contract BeaconL2ConnectorAuditTest is Test {
    MockPodManager internal podManager;
    MockMessenger internal messenger;
    MockSlashPod internal pod;
    L2SlashingConnector internal connector;

    address internal oracle = makeAddr("oracle");
    address internal operator = makeAddr("operator");
    address internal podOwner = makeAddr("podOwner");
    uint256 internal constant DEST_CHAIN = 8453;

    function setUp() public {
        podManager = new MockPodManager();
        messenger = new MockMessenger();
        pod = new MockSlashPod();

        connector = new L2SlashingConnector(address(podManager), oracle);
        connector.setMessenger(address(messenger));
        connector.setChainConfig(DEST_CHAIN, makeAddr("receiver"), 200_000, true);
        connector.setDefaultDestinationChain(DEST_CHAIN);
        connector.registerPodOperator(address(pod), operator);

        podManager.setPodOwner(address(pod), podOwner);
    }

    /// @notice A factor decrease that resolves to 0 bps (operator has zero L2 stake) MUST revert
    ///         `NothingToSlash` BEFORE the per-destination baseline is advanced, so the same delta
    ///         is still re-propagable once the operator regains slashable L2 stake.
    function test_connector_zeroStake_revertsAndPreservesBaseline() public {
        // Operator has withdrawn all L2 stake → slashBps would round to 0.
        podManager.setTotalAssetsOf(podOwner, 32 ether);
        podManager.setOperatorStake(operator, 0);

        uint64 newFactor = 0.5e18; // 50% beacon loss
        pod.setFactor(newFactor);

        // Baseline is uninitialised (== 0, treated as 1e18). It must NOT advance.
        assertEq(connector.lastProcessedSlashingFactorByChain(address(pod), DEST_CHAIN), 0, "baseline starts unset");

        vm.prank(oracle);
        vm.expectRevert(
            abi.encodeWithSelector(L2SlashingConnector.NothingToSlash.selector, address(pod), DEST_CHAIN)
        );
        connector.propagateBeaconSlashing(address(pod), newFactor);

        // SECURE INVARIANT 1: no message was shipped (no wasted bridge fee on a guaranteed-reject).
        assertEq(messenger.sendCount(), 0, "no zero-bps message shipped");
        // SECURE INVARIANT 2: baseline NOT corrupted → the delta remains re-propagable.
        assertEq(
            connector.lastProcessedSlashingFactorByChain(address(pod), DEST_CHAIN),
            0,
            "baseline must NOT advance on a zero-bps slash"
        );
        assertEq(
            connector.cumulativeSlashAmountByChain(address(pod), DEST_CHAIN),
            0,
            "cumulative slash must not be credited for a zero-bps slash"
        );
    }

    /// @notice Re-propagability: once the operator re-stakes on L2, the SAME factor delta that was
    ///         rejected above now ships successfully — proving the earlier revert left state clean.
    function test_connector_reStaking_makesSameDeltaPropagable() public {
        podManager.setTotalAssetsOf(podOwner, 32 ether);
        podManager.setOperatorStake(operator, 0);

        uint64 newFactor = 0.5e18;
        pod.setFactor(newFactor);

        vm.prank(oracle);
        vm.expectRevert(
            abi.encodeWithSelector(L2SlashingConnector.NothingToSlash.selector, address(pod), DEST_CHAIN)
        );
        connector.propagateBeaconSlashing(address(pod), newFactor);

        // Operator re-acquires L2 stake; the identical factor delta must now be propagable.
        podManager.setOperatorStake(operator, 32 ether);

        vm.prank(oracle);
        connector.propagateBeaconSlashing(address(pod), newFactor);

        assertEq(messenger.sendCount(), 1, "delta propagates after re-staking");
        assertEq(
            connector.lastProcessedSlashingFactorByChain(address(pod), DEST_CHAIN),
            newFactor,
            "baseline advances only on a real (non-zero) slash"
        );
        assertGt(
            connector.cumulativeSlashAmountByChain(address(pod), DEST_CHAIN),
            0,
            "cumulative slash credited on the real slash"
        );
    }

    /// @notice A genuine non-zero slash still propagates normally (no false-positive guard).
    function test_connector_nonZeroSlash_propagates() public {
        podManager.setTotalAssetsOf(podOwner, 32 ether);
        podManager.setOperatorStake(operator, 32 ether);

        uint64 newFactor = 0.5e18;
        pod.setFactor(newFactor);

        vm.prank(oracle);
        connector.propagateBeaconSlashing(address(pod), newFactor);

        assertEq(messenger.sendCount(), 1, "real slash ships exactly one message");
        assertEq(
            connector.lastProcessedSlashingFactorByChain(address(pod), DEST_CHAIN), newFactor, "baseline advanced"
        );
    }
}

// ──────────────────────────────────────────────────────────────────────────────
// Receiver tests — MEDIUM: deferred-debt queue defeats stake-zeroing evasion
// ──────────────────────────────────────────────────────────────────────────────

contract BeaconL2ReceiverAuditTest is Test {
    L2SlashingReceiver internal receiver;
    MockSlasher internal slasher;

    address internal owner = makeAddr("owner");
    address internal messenger = makeAddr("messenger");
    address internal connector = makeAddr("connector");
    address internal operator = makeAddr("operator");

    uint256 internal constant SRC_CHAIN = 11_155_111;
    bytes4 internal constant SLASH_TYPE = bytes4(keccak256("BEACON_SLASH"));

    function setUp() public {
        slasher = new MockSlasher();

        L2SlashingReceiver impl = new L2SlashingReceiver();
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(impl), abi.encodeCall(L2SlashingReceiver.initialize, (address(slasher), messenger, owner))
        );
        receiver = L2SlashingReceiver(address(proxy));

        // Authorise the connector as the L1 sender (adapter path).
        vm.startPrank(owner);
        receiver.setAuthorizedSender(SRC_CHAIN, connector, true);
        vm.warp(block.timestamp + receiver.SENDER_ACTIVATION_DELAY() + 1);
        receiver.activateAuthorizedSender(SRC_CHAIN, connector);
        vm.stopPrank();
    }

    function _slashPayload(
        address op,
        uint16 slashBps,
        uint64 factor,
        uint256 nonce,
        address pod
    )
        internal
        pure
        returns (bytes memory)
    {
        return abi.encodePacked(SLASH_TYPE, abi.encode(op, slashBps, factor, nonce, pod));
    }

    /// @notice An operator who has zeroed their L2 slashable stake (`canSlash == false`) does NOT
    ///         escape the slash: the owed bps are banked as deferred debt and the bridge nonce is
    ///         consumed (so no infinite-revert / redelivery is required).
    function test_receiver_zeroStake_banksDeferredDebtAndConsumesNonce() public {
        slasher.setSlashable(false); // operator withdrew all L2 stake to dodge the slash

        bytes memory payload = _slashPayload(operator, 500, 0.5e18, 1, makeAddr("pod"));

        vm.prank(messenger);
        receiver.receiveMessage(SRC_CHAIN, connector, payload);

        // SECURE INVARIANT 1: no immediate slash, but the debt is BANKED (not lost).
        assertEq(slasher.slashCalls(), 0, "nothing slashed while stake is zero");
        assertEq(receiver.deferredSlashBps(operator), 500, "owed bps banked as deferred debt");
        // SECURE INVARIANT 2: the nonce is consumed (the debt lives in storage now, not the bridge).
        assertTrue(receiver.isNonceProcessed(SRC_CHAIN, connector, 1), "nonce consumed once banked");
    }

    /// @notice Once the operator re-acquires slashable stake, ANYONE can realise the banked debt
    ///         via `flushDeferredSlash`. The slash that was evaded is finally applied.
    function test_receiver_flushAfterReStake_appliesDeferredSlash() public {
        slasher.setSlashable(false);
        vm.prank(messenger);
        receiver.receiveMessage(SRC_CHAIN, connector, _slashPayload(operator, 500, 0.5e18, 1, makeAddr("pod")));
        assertEq(receiver.deferredSlashBps(operator), 500, "debt banked");

        // Operator re-stakes; a random keeper (not owner/messenger) flushes the debt.
        slasher.setSlashable(true);
        address keeper = makeAddr("keeper");
        vm.prank(keeper);
        receiver.flushDeferredSlash(operator);

        // SECURE INVARIANT: the evaded slash is now realised, debt cleared.
        assertEq(slasher.slashCalls(), 1, "deferred slash applied on flush");
        assertEq(slasher.lastSlashBps(), 500, "exact banked bps applied");
        assertEq(receiver.deferredSlashBps(operator), 0, "debt cleared after flush");
        assertEq(receiver.beaconSlashTotal(operator), 500, "cumulative beacon slash credited");
    }

    /// @notice Multiple evaded slashes accumulate; a flush caps the realised slash at 10_000 bps
    ///         (100%) and keeps the overflow booked for a later flush.
    function test_receiver_multipleDeferred_capAtBpsDenominator() public {
        slasher.setSlashable(false);
        vm.startPrank(messenger);
        receiver.receiveMessage(SRC_CHAIN, connector, _slashPayload(operator, 7000, 0.3e18, 1, makeAddr("pod")));
        receiver.receiveMessage(SRC_CHAIN, connector, _slashPayload(operator, 6000, 0.1e18, 2, makeAddr("pod")));
        vm.stopPrank();
        assertEq(receiver.deferredSlashBps(operator), 13_000, "debt accumulates across messages");

        slasher.setSlashable(true);
        receiver.flushDeferredSlash(operator);

        // SECURE INVARIANT: a single flush never slashes more than 100%; overflow stays booked.
        assertEq(slasher.lastSlashBps(), receiver.BPS_DENOMINATOR(), "flush capped at 100%");
        assertEq(receiver.deferredSlashBps(operator), 3000, "overflow remains booked for next flush");
    }

    /// @notice The deferred path is keyed on `canSlash`: flushing while the operator still has no
    ///         slashable stake reverts (no phantom slash), but the debt is preserved.
    function test_receiver_flushWhileNotSlashable_revertsAndKeepsDebt() public {
        slasher.setSlashable(false);
        vm.prank(messenger);
        receiver.receiveMessage(SRC_CHAIN, connector, _slashPayload(operator, 500, 0.5e18, 1, makeAddr("pod")));

        vm.expectRevert(abi.encodeWithSelector(L2SlashingReceiver.SlashingNotPossible.selector, operator));
        receiver.flushDeferredSlash(operator);

        assertEq(receiver.deferredSlashBps(operator), 500, "debt preserved when flush cannot apply");
    }

    /// @notice Flushing with no banked debt reverts `NoDeferredSlash` (no silent no-op slash).
    function test_receiver_flushWithNoDebt_reverts() public {
        slasher.setSlashable(true);
        vm.expectRevert(abi.encodeWithSelector(L2SlashingReceiver.NoDeferredSlash.selector, operator));
        receiver.flushDeferredSlash(operator);
    }

    /// @notice When the operator DOES have slashable stake, the slash applies immediately and no
    ///         deferred debt is created (the fix does not change the happy path).
    function test_receiver_slashableOperator_appliesImmediately() public {
        slasher.setSlashable(true);
        vm.prank(messenger);
        receiver.receiveMessage(SRC_CHAIN, connector, _slashPayload(operator, 500, 0.5e18, 1, makeAddr("pod")));

        assertEq(slasher.slashCalls(), 1, "slash applied immediately when slashable");
        assertEq(receiver.deferredSlashBps(operator), 0, "no deferred debt on the happy path");
        assertEq(receiver.beaconSlashTotal(operator), 500, "cumulative slash credited");
        assertTrue(receiver.isNonceProcessed(SRC_CHAIN, connector, 1), "nonce consumed");
    }

    /// @notice A zero-bps message is still a hard revert (the L1 connector fails-closed before
    ///         shipping one, so receiving one is an invalid payload — never banked as debt).
    function test_receiver_zeroBps_revertsAsInvalidPayload() public {
        slasher.setSlashable(true);
        vm.prank(messenger);
        vm.expectRevert(L2SlashingReceiver.InvalidPayload.selector);
        receiver.receiveMessage(SRC_CHAIN, connector, _slashPayload(operator, 0, 0.5e18, 1, makeAddr("pod")));

        assertEq(receiver.deferredSlashBps(operator), 0, "zero-bps must not bank deferred debt");
        assertFalse(receiver.isNonceProcessed(SRC_CHAIN, connector, 1), "zero-bps must not consume the nonce");
    }

    /// @notice Replay protection survives the banking path: a consumed nonce cannot be re-delivered
    ///         to double-bank the same deferred debt.
    function test_receiver_deferredNonce_notReplayable() public {
        slasher.setSlashable(false);
        bytes memory payload = _slashPayload(operator, 500, 0.5e18, 1, makeAddr("pod"));

        vm.prank(messenger);
        receiver.receiveMessage(SRC_CHAIN, connector, payload);

        vm.prank(messenger);
        vm.expectRevert(
            abi.encodeWithSelector(L2SlashingReceiver.NonceAlreadyProcessed.selector, SRC_CHAIN, connector, 1)
        );
        receiver.receiveMessage(SRC_CHAIN, connector, payload);

        assertEq(receiver.deferredSlashBps(operator), 500, "debt not double-banked on replay");
    }
}
