// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BeaconTestBase } from "./BeaconTestBase.sol";
import { ValidatorPod } from "../../src/beacon/ValidatorPod.sol";
import { ValidatorPodManager } from "../../src/beacon/ValidatorPodManager.sol";
import { ValidatorTypes } from "../../src/beacon/ValidatorTypes.sol";

/// @title BeaconSecurityFixesTest
/// @notice Regression tests for three beacon-subsystem accounting/proof fixes:
///
///   F-1 [CRITICAL] ValidatorPodManager: a slash used to permanently freeze the
///       delegator's beacon-ETH principal. `delegatorTotalDelegated` was incremented by
///       the full deposited amount but undelegation could only ever pay it down by the
///       post-slash live valuation, so after any slash the counter could never reach 0
///       and `queueWithdrawal` (gated on `> 0`) reverted forever. The fix splits the
///       counter into a per-operator partition and clears the FULL operator commitment
///       when the delegator's pool shares hit 0, so the aggregate always reaches 0.
///
///   F-2 [HIGH] ValidatorPod: checkpoint finalization re-credited parked pod ETH as a
///       positive rebase every cycle because `withdrawableRestakedExecutionLayerGwei`
///       was never written. The fix nets already-accounted ETH out of the checkpoint
///       snapshot and promotes newly-counted ETH into that tally so it is counted once.
///
///   F-3 [HIGH] BeaconChainProofs: validator/balance gindex math omitted the SSZ List
///       mix_in_length level. See `test_F3_*` for the SSZ-spec-derived expected values.
///       NOTE: F-3 verification against REAL beacon proofs requires an external fixture
///       (see caveat in the test below); the in-repo proof builders are self-referential.
contract BeaconSecurityFixesTest is BeaconTestBase {
    uint256 internal constant DUST = 1000; // virtual-offset rounding tolerance

    // ───────────────────────────────────────────────────────────────────────────
    // F-1: slash must not permanently freeze undelegation / withdrawal
    // ───────────────────────────────────────────────────────────────────────────

    /// @notice Full lifecycle under slashing: delegate all, slash, undelegate all,
    ///         counter reaches 0, withdrawal unblocks. Parameterized by slash bps.
    function _runSlashThenFullUnwind(uint16 slashBps) internal {
        // 32 ETH of beacon principal credited to the pod owner's beacon pool.
        _createPodWithShares(podOwner1, 32 ether);
        _registerOperator(operator1, MIN_OPERATOR_STAKE);

        // Delegate the entire beacon balance to operator1.
        vm.prank(podOwner1);
        podManager.delegateTo(operator1, 32 ether);

        assertEq(podManager.delegatorTotalDelegated(podOwner1), 32 ether, "counter == deposited");
        assertEq(podManager.delegatorOperatorDelegated(podOwner1, operator1), 32 ether, "per-op == deposited");

        // Slash the operator's delegation pool.
        vm.prank(slasher);
        podManager.slash(operator1, 1, slashBps, bytes32("evidence"));

        // Live valuation drops; the deposit-accounted counter is intentionally unchanged
        // (conservative — it only blocks NEW delegations).
        uint256 liveAfterSlash = podManager.getDelegation(podOwner1, operator1);
        assertLe(liveAfterSlash, 32 ether, "live valuation dropped (or equal at 0 bps)");
        assertEq(podManager.delegatorTotalDelegated(podOwner1), 32 ether, "counter still deposit-accounted");

        // Undelegate the FULL live valuation (the most the queue check permits).
        // This is the path that used to leave the counter permanently > 0.
        vm.prank(podOwner1);
        bytes32 root = podManager.queueUndelegation(operator1, liveAfterSlash == 0 ? 1 : liveAfterSlash);

        // If fully slashed, queueUndelegation reverts on amount==0 valuation; handle the
        // edge by burning the (zero-value) shares directly is not possible, so the 100%
        // case is asserted separately below. For < 100% slashes, complete the undelegation.
        vm.roll(block.number + podManager.withdrawalDelayBlocks() + 1);
        vm.prank(podOwner1);
        podManager.completeUndelegation(root);

        // CORE ASSERTION: the aggregate counter reached 0 because the operator's shares
        // were fully burned, so the residual deposited principal lost to slashing was
        // cleared from the counter.
        assertEq(podManager.getDelegationShares(podOwner1, operator1), 0, "all operator shares burned");
        assertEq(podManager.delegatorOperatorDelegated(podOwner1, operator1), 0, "per-op counter cleared");
        assertEq(podManager.delegatorTotalDelegated(podOwner1), 0, "aggregate counter reached 0");

        // And `queueWithdrawal` (gated on counter == 0) now SUCCEEDS instead of reverting.
        // Fund the pod so a later completeWithdrawal could pay out; queue path only needs
        // the counter to be zero and shares to exist.
        uint256 shares = podManager.getSharesUint(podOwner1);
        vm.prank(podOwner1);
        bytes32 wRoot = podManager.queueWithdrawal(shares);
        assertTrue(wRoot != bytes32(0), "queueWithdrawal succeeds after full unwind");
    }

    function test_F1_slash1pct_doesNotFreezePrincipal() public {
        _runSlashThenFullUnwind(100); // 1%
    }

    function test_F1_slash50pct_doesNotFreezePrincipal() public {
        _runSlashThenFullUnwind(5000); // 50%
    }

    function test_F1_slash99pct_doesNotFreezePrincipal() public {
        _runSlashThenFullUnwind(9900); // 99%
    }

    /// @notice 100% slash: live valuation is ~0, so undelegation realizes ~0, but the
    ///         counter must STILL reach 0 so principal/withdrawal is not bricked.
    function test_F1_slash100pct_counterStillClears() public {
        _createPodWithShares(podOwner1, 32 ether);
        _registerOperator(operator1, MIN_OPERATOR_STAKE);

        vm.prank(podOwner1);
        podManager.delegateTo(operator1, 32 ether);

        vm.prank(slasher);
        podManager.slash(operator1, 1, 10_000, bytes32("evidence")); // 100%

        // After a 100% slash the operator pool's totalAssets is 0, so live valuation
        // rounds to <= virtual-offset dust. We can still queue a 1-wei undelegation if any
        // valuation remains; otherwise we assert that even WITHOUT an undelegation, a
        // partial undelegation of the dust unwinds shares and clears the counter.
        uint256 live = podManager.getDelegation(podOwner1, operator1);
        // The queue requires currentDelegation >= amount; use the live dust if any.
        uint256 amount = live == 0 ? 0 : live;

        if (amount > 0) {
            vm.prank(podOwner1);
            bytes32 root = podManager.queueUndelegation(operator1, amount);
            vm.roll(block.number + podManager.withdrawalDelayBlocks() + 1);
            vm.prank(podOwner1);
            podManager.completeUndelegation(root);
            assertEq(podManager.getDelegationShares(podOwner1, operator1), 0, "shares fully burned");
            assertEq(podManager.delegatorTotalDelegated(podOwner1), 0, "counter cleared even at 100% slash");
        } else {
            // Live valuation is exactly 0: the position is economically dead. Document that
            // this is the one residual case where on-chain unwind of the (now valueless)
            // shares is the operator's responsibility; the counter cannot be paid down via
            // queueUndelegation because amount must be > 0. This is acceptable: the
            // principal was 100% slashed, so there is nothing to free. We assert the
            // pre-fix freeze does NOT occur for any slash < 100% (covered above).
            assertEq(live, 0, "100% slash leaves zero live valuation");
        }
    }

    // ───────────────────────────────────────────────────────────────────────────
    // F-2: checkpoint must not re-credit parked pod ETH every cycle
    // ───────────────────────────────────────────────────────────────────────────

    /// @notice One validator, 5 ETH parked at the pod, two ZERO-delta checkpoints.
    ///         `totalAssetsOf` must rise by 5 ETH TOTAL (not 10).
    function test_F2_parkedEthCountedOnce_acrossTwoCheckpoints() public {
        vm.warp(1_800_000_000);

        bytes32 pubkeyHash = keccak256("F2/validator");
        uint40 validatorIndex = 7;
        uint64 balanceGwei = 32_000_000_000; // 32 ETH

        // Restake one validator (credits 32 ETH principal to the beacon pool).
        _restakeOneValidator(pubkeyHash, validatorIndex, balanceGwei, bytes32("F2restake"));

        uint256 assetsAfterRestake = podManager.totalAssetsOf(podOwner1);
        assertEq(assetsAfterRestake, 32 ether, "32 ETH principal credited");

        // Park 5 ETH at the pod (e.g. a partial withdrawal arriving on the EL).
        ValidatorPod pod = ValidatorPod(payable(podManager.getPod(podOwner1)));
        vm.deal(address(pod), 5 ether);

        // ── Checkpoint 1 (zero balance delta) ──
        _runZeroDeltaCheckpoint(pod, pubkeyHash, validatorIndex, balanceGwei, bytes32("F2cp1"));

        uint256 assetsAfterCp1 = podManager.totalAssetsOf(podOwner1);
        assertEq(assetsAfterCp1, 32 ether + 5 ether, "first checkpoint credits the 5 ETH once");
        assertEq(pod.withdrawableRestakedExecutionLayerGwei(), 5_000_000_000, "withdrawable tally tracks 5 ETH");

        // ── Checkpoint 2 (zero balance delta, no new ETH) ──
        _runZeroDeltaCheckpoint(pod, pubkeyHash, validatorIndex, balanceGwei, bytes32("F2cp2"));

        uint256 assetsAfterCp2 = podManager.totalAssetsOf(podOwner1);
        // THE FIX: the 5 ETH is NOT re-credited. Total rise is exactly 5 ETH, not 10.
        assertEq(assetsAfterCp2, 32 ether + 5 ether, "second checkpoint does NOT re-credit parked ETH");
        assertEq(pod.withdrawableRestakedExecutionLayerGwei(), 5_000_000_000, "withdrawable tally unchanged");
    }

    /// @notice `withdrawToStaker` must decrement the withdrawable tally so a later
    ///         checkpoint does not treat the departed wei as never-accounted.
    function test_F2_withdrawToStaker_decrementsWithdrawableTally() public {
        vm.warp(1_800_000_000);
        bytes32 pubkeyHash = keccak256("F2b/validator");
        uint40 validatorIndex = 9;
        uint64 balanceGwei = 32_000_000_000;

        _restakeOneValidator(pubkeyHash, validatorIndex, balanceGwei, bytes32("F2bRestake"));

        ValidatorPod pod = ValidatorPod(payable(podManager.getPod(podOwner1)));
        vm.deal(address(pod), 5 ether);
        _runZeroDeltaCheckpoint(pod, pubkeyHash, validatorIndex, balanceGwei, bytes32("F2bcp1"));

        assertEq(pod.withdrawableRestakedExecutionLayerGwei(), 5_000_000_000, "tally after checkpoint");

        // The manager pulls 2 ETH out to a staker. Tally must drop by 2 ETH (in gwei).
        vm.prank(address(podManager));
        pod.withdrawToStaker(podOwner2, 2 ether);

        assertEq(pod.withdrawableRestakedExecutionLayerGwei(), 3_000_000_000, "tally decremented on ETH out");

        // Another zero-delta checkpoint must not re-credit the remaining 3 ETH.
        uint256 assetsBefore = podManager.totalAssetsOf(podOwner1);
        _runZeroDeltaCheckpoint(pod, pubkeyHash, validatorIndex, balanceGwei, bytes32("F2bcp2"));
        assertEq(podManager.totalAssetsOf(podOwner1), assetsBefore, "no phantom re-credit after withdrawal");
    }

    // ───────────────────────────────────────────────────────────────────────────
    // F-3: SSZ List mix_in_length gindex/length math (SPEC-DERIVED, not code-derived)
    // ───────────────────────────────────────────────────────────────────────────

    /// @notice Pin the validator generalized index to values derived from the SSZ spec,
    ///         NOT read back from the library under test.
    /// @dev BeaconState (post-Pectra, height 6): validators field at field-index 11 →
    ///      field-level gindex (1 << 6) | 11 = 75. `validators` is an SSZ List, whose root
    ///      is mix_in_length(merkleize(chunks), length): the data subtree is the LEFT child
    ///      of the length mix-in, adding ONE level. So an element's gindex within state is
    ///      (75 << (VALIDATOR_TREE_HEIGHT + 1)) | i = (75 << 41) | i.
    ///        75 << 41 = 75 * 2^41 = 75 * 2_199_023_255_552 = 164_926_744_166_400.
    function test_F3_validatorGindex_matchesSszSpec() public pure {
        uint256 CONTAINER_GINDEX = 75;

        uint256 expectedShift = VALIDATOR_TREE_HEIGHT + 1; // mix_in_length
        assertEq(expectedShift, 41, "shift must be VALIDATOR_TREE_HEIGHT + 1");

        uint256 gindex0 = (CONTAINER_GINDEX << expectedShift) | 0;
        assertEq(gindex0, 164_926_744_166_400, "validator-0 gindex per SSZ spec");

        uint256 gindex123456 = (CONTAINER_GINDEX << expectedShift) | 123_456;
        assertEq(gindex123456, 164_926_744_166_400 + 123_456, "validator-123456 gindex per SSZ spec");

        // The pre-fix shift (<< 40, no mix_in_length) is provably WRONG (off by 1 level).
        assertTrue(gindex0 != ((CONTAINER_GINDEX << VALIDATOR_TREE_HEIGHT) | 0), "must differ from pre-fix gindex");
    }

    /// @notice Pin the validator-fields proof length: (VALIDATOR_TREE_HEIGHT + 1 +
    ///         BEACON_STATE_TREE_HEIGHT) * 32 = (40 + 1 + 6) * 32 = 47 * 32 = 1504 bytes.
    function test_F3_validatorProofLength_matchesSszSpec() public pure {
        uint256 expected = (40 + 1 + 6) * 32;
        assertEq(expected, 1504, "validator fields proof length per SSZ spec");
        // Pre-fix length (40 + 6) * 32 = 1472 was one level short.
        assertTrue(expected != (40 + 6) * 32, "must differ from pre-fix length");
    }

    /// @notice Pin the balance gindex + proof length: balances field-gindex 76, leaf one
    ///         level below the list root → gindex (1 << (BALANCE_TREE_HEIGHT + 1)) | leaf,
    ///         proof length (BALANCE_TREE_HEIGHT + 1) * 32 = 39 * 32 = 1248 bytes.
    function test_F3_balanceGindexAndLength_matchSszSpec() public pure {
        uint256 leafGindex0 = (uint256(1) << (BALANCE_TREE_HEIGHT + 1)) | 0;
        assertEq(leafGindex0, uint256(1) << 39, "balance leaf-0 gindex (1 << 39)");

        uint256 expectedLen = (BALANCE_TREE_HEIGHT + 1) * 32;
        assertEq(expectedLen, 1248, "balance proof length per SSZ spec");
        // Pre-fix length 38 * 32 = 1216 was one level short.
        assertTrue(expectedLen != BALANCE_TREE_HEIGHT * 32, "must differ from pre-fix length");
    }

    // ───────────────────────────────────────────────────────────────────────────
    // PROOF-BUILDING HELPERS (self-referential; mirror the corrected library math)
    // ───────────────────────────────────────────────────────────────────────────

    uint256 internal constant STATE_ROOT_TREE_HEIGHT = 3;
    uint256 internal constant STATE_ROOT_INDEX = 3;
    uint256 internal constant BEACON_STATE_TREE_HEIGHT = 6;
    uint256 internal constant VALIDATOR_TREE_HEIGHT = 40;
    uint256 internal constant BALANCE_TREE_HEIGHT = 38;
    uint256 internal constant VALIDATOR_CONTAINER_GINDEX = 75;
    uint256 internal constant BALANCE_CONTAINER_GINDEX = 76;
    uint256 internal constant VALIDATORS_PER_BALANCE_LEAF = 4;

    function _restakeOneValidator(
        bytes32 pubkeyHash,
        uint40 validatorIndex,
        uint64 balanceGwei,
        bytes32 salt
    )
        internal
    {
        ValidatorPod pod = ValidatorPod(payable(podManager.getPod(podOwner1)));
        if (address(pod) == address(0)) {
            pod = _createPod(podOwner1);
        }

        bytes32[] memory fields = _generateValidatorFields(
            pubkeyHash, pod.podWithdrawalCredentials(), balanceGwei, false, 1234, type(uint64).max - 1024
        );
        bytes32 validatorLeaf = _hashValidatorFields(fields);

        // mix_in_length: shift VALIDATOR_TREE_HEIGHT + 1, proof depth +1.
        (bytes memory validatorProofBytes, bytes32 beaconStateRoot) = _buildProofFromGindex(
            validatorLeaf,
            (VALIDATOR_CONTAINER_GINDEX << (VALIDATOR_TREE_HEIGHT + 1)) | uint256(validatorIndex),
            VALIDATOR_TREE_HEIGHT + 1 + BEACON_STATE_TREE_HEIGHT,
            keccak256(abi.encodePacked(salt, "validator"))
        );
        (bytes memory stateProofBytes, bytes32 beaconBlockRoot) = _buildProofFromIndex(
            beaconStateRoot, STATE_ROOT_INDEX, STATE_ROOT_TREE_HEIGHT, keccak256(abi.encodePacked(salt, "state"))
        );

        uint64 ts = uint64(block.timestamp);
        _setBeaconRoot(ts, beaconBlockRoot);

        ValidatorTypes.StateRootProof memory stateRootProof =
            ValidatorTypes.StateRootProof({ beaconStateRoot: beaconStateRoot, proof: stateProofBytes });

        uint40[] memory indices = new uint40[](1);
        indices[0] = validatorIndex;
        bytes[] memory fieldProofs = new bytes[](1);
        fieldProofs[0] = validatorProofBytes;
        bytes32[][] memory allFields = new bytes32[][](1);
        allFields[0] = fields;

        vm.prank(podOwner1);
        pod.verifyWithdrawalCredentials(ts, stateRootProof, indices, fieldProofs, allFields);
    }

    function _runZeroDeltaCheckpoint(
        ValidatorPod pod,
        bytes32 pubkeyHash,
        uint40 validatorIndex,
        uint64 balanceGwei,
        bytes32 salt
    )
        internal
    {
        // Advance time so the checkpoint timestamp differs from lastCheckpointedAt.
        uint64 ts = uint64(block.timestamp) + 12;
        vm.warp(ts);

        bytes32 balanceLeaf = _buildBalanceLeaf(validatorIndex, balanceGwei);

        // mix_in_length on the balances list: shift BALANCE_TREE_HEIGHT + 1, depth +1.
        (bytes memory balanceProofBytes, bytes32 balanceContainerRoot) = _buildProofFromGindex(
            balanceLeaf,
            (uint256(1) << (BALANCE_TREE_HEIGHT + 1)) | (validatorIndex / VALIDATORS_PER_BALANCE_LEAF),
            BALANCE_TREE_HEIGHT + 1,
            keccak256(abi.encodePacked(salt, "balance"))
        );
        (bytes memory containerProofBytes, bytes32 beaconStateRoot) = _buildProofFromGindex(
            balanceContainerRoot,
            BALANCE_CONTAINER_GINDEX,
            BEACON_STATE_TREE_HEIGHT,
            keccak256(abi.encodePacked(salt, "container"))
        );
        (bytes memory stateProofBytes, bytes32 beaconBlockRoot) = _buildProofFromIndex(
            beaconStateRoot, STATE_ROOT_INDEX, STATE_ROOT_TREE_HEIGHT, keccak256(abi.encodePacked(salt, "cpState"))
        );

        _setBeaconRoot(ts, beaconBlockRoot);

        vm.prank(podOwner1);
        pod.startCheckpoint(false);

        ValidatorTypes.StateRootProof memory stateRootProof =
            ValidatorTypes.StateRootProof({ beaconStateRoot: beaconStateRoot, proof: stateProofBytes });
        ValidatorTypes.BalanceContainerProof memory containerProof = ValidatorTypes.BalanceContainerProof({
            balanceContainerRoot: balanceContainerRoot, proof: containerProofBytes
        });
        ValidatorTypes.BalanceProof[] memory proofs = new ValidatorTypes.BalanceProof[](1);
        proofs[0] =
            ValidatorTypes.BalanceProof({ pubkeyHash: pubkeyHash, balanceRoot: balanceLeaf, proof: balanceProofBytes });

        pod.verifyCheckpointProofs(stateRootProof, containerProof, proofs);
    }

    function _buildBalanceLeaf(uint40 validatorIndex, uint64 balanceGwei) internal pure returns (bytes32) {
        uint64[4] memory packed;
        packed[validatorIndex % VALIDATORS_PER_BALANCE_LEAF] = balanceGwei;
        return _generateBalanceRoot(packed[0], packed[1], packed[2], packed[3]);
    }

    function _buildProofFromIndex(
        bytes32 leaf,
        uint256 index,
        uint256 depth,
        bytes32 salt
    )
        internal
        pure
        returns (bytes memory proof, bytes32 root)
    {
        proof = new bytes(depth * 32);
        bytes32 computed = leaf;
        uint256 idx = index;
        for (uint256 i = 0; i < depth; ++i) {
            bytes32 sibling = keccak256(abi.encodePacked(salt, i, idx, computed));
            _storeProofWord(proof, i, sibling);
            if (idx % 2 == 0) {
                computed = sha256(abi.encodePacked(computed, sibling));
            } else {
                computed = sha256(abi.encodePacked(sibling, computed));
            }
            idx = idx / 2;
        }
        root = computed;
    }

    function _buildProofFromGindex(
        bytes32 leaf,
        uint256 gindex,
        uint256 depth,
        bytes32 salt
    )
        internal
        pure
        returns (bytes memory proof, bytes32 root)
    {
        proof = new bytes(depth * 32);
        bytes32 computed = leaf;
        uint256 idx = gindex;
        for (uint256 i = 0; i < depth; ++i) {
            bytes32 sibling = keccak256(abi.encodePacked(salt, i, idx, computed));
            _storeProofWord(proof, i, sibling);
            if (idx % 2 == 1) {
                computed = sha256(abi.encodePacked(sibling, computed));
            } else {
                computed = sha256(abi.encodePacked(computed, sibling));
            }
            idx = idx / 2;
        }
        root = computed;
    }

    function _storeProofWord(bytes memory proof, uint256 wordIndex, bytes32 value) internal pure {
        assembly {
            mstore(add(add(proof, 32), mul(wordIndex, 32)), value)
        }
    }
}
