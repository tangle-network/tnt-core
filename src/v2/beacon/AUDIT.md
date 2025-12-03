# Beacon Chain Validator Restaking - Security Audit

**Date**: December 2024
**Status**: PRE-PRODUCTION - Critical issues identified

---

## Executive Summary

This audit identifies **critical** security issues that must be fixed before production use.

| Severity | Count | Status |
|----------|-------|--------|
| CRITICAL | 3 | ❌ Open |
| HIGH | 5 | ❌ Open |
| MEDIUM | 3 | ❌ Open |
| LOW | 2 | ❌ Open |

---

## CRITICAL Issues

### C-1: Empty Proof Attack in Merkle Verification

**Location**: `BeaconChainProofs.sol:290-316, 318-370`

**Description**: The Merkle proof verification functions don't check for empty proofs. If `proof.length == 0` and `leaf == root`, verification incorrectly passes.

**Impact**: An attacker could bypass proof verification entirely.

**EigenLayer Reference**: This exact bug was found in EigenLayer's Code4rena audit.

**Fix**:
```solidity
function _verifyMerkleProof(...) internal pure returns (bool) {
    if (proof.length == 0) return false;  // ADD THIS
    // ... rest of function
}
```

---

### C-2: Incorrect Generalized Index Calculation

**Location**: `BeaconChainProofs.sol:124`

**Description**: The generalized index for validators is calculated as:
```solidity
(VALIDATORS_INDEX << VALIDATOR_TREE_HEIGHT) | uint256(validatorIndex)
```

This is incorrect. The proper SSZ generalized index calculation needs to account for the full path through the beacon state tree.

**Impact**: Proof verification will fail for legitimate proofs, or worse, accept invalid proofs.

**EigenLayer Reference**: EigenLayer uses `BeaconChainProofs.VALIDATOR_TREE_ROOT_INDEX` which is `((1 << VALIDATOR_LIST_INDEX) << VALIDATOR_TREE_HEIGHT)`.

**Fix**: Need to rewrite using proper SSZ tree indexing.

---

### C-3: Balance Container Verification Bypasses State Root

**Location**: `BeaconChainProofs.sol:148-168`

**Description**: `verifyBalanceContainer` attempts to verify the balance container directly against the beacon block root, but the balances are in the beacon STATE, not block header.

The proof path should be:
1. Block root → State root (3 levels)
2. State root → Balances root (5 levels for Deneb)

Currently it only does step 2 but against the wrong root.

**Impact**: Balance proofs will always fail or accept invalid proofs.

---

## HIGH Issues

### H-1: _getTotalRestakedGwei Returns 0

**Location**: `ValidatorPod.sol:399-403`

**Description**: This function is a placeholder that always returns 0, but it's used in checkpoint creation to set `priorBeaconBalanceGwei`.

```solidity
function _getTotalRestakedGwei() internal view returns (uint64 total) {
    return 0; // Placeholder - BROKEN
}
```

**Impact**: Checkpoint accounting will be completely wrong.

**Fix**: Track a running total of restaked gwei, or iterate validators.

---

### H-2: verifyCheckpointProofs Missing Access Control

**Location**: `ValidatorPod.sol:267-299`

**Description**: The function is missing `onlyPodOwner` modifier. Anyone can submit checkpoint proofs for any pod.

**Impact**: Griefing attack - malicious actor could submit incorrect proofs.

**Fix**: Add `onlyPodOwner` modifier.

---

### H-3: _getTotalDelegatedBy Returns 0

**Location**: `ValidatorPodManager.sol:233-237`

**Description**: Placeholder that always returns 0, causing delegation checks to always pass.

```solidity
function _getTotalDelegatedBy(address delegator) internal view returns (uint256 total) {
    return 0; // Always returns 0!
}
```

**Impact**: Users can over-delegate beyond their shares.

**Fix**: Track total delegations per delegator.

---

### H-4: Slashing Doesn't Reduce Delegator Shares

**Location**: `ValidatorPodManager.sol:326-345`

**Description**: When slashing from delegated stake, only `operatorDelegatedStake` is reduced. Individual delegators' `podOwnerShares` are never reduced.

**Impact**: Delegators don't lose shares when slashed, breaking the security model.

**Fix**: Implement proportional slashing similar to `MultiAssetDelegation`.

---

### H-5: No Beacon Root Staleness Check

**Location**: `ValidatorPod.sol:146-148`

**Description**: No check that the beacon timestamp is recent. Proofs against very old beacon states could be accepted.

**Impact**: Replay attacks using old beacon states.

**Fix**: Add maximum age check (e.g., 27 hours like EigenLayer).

---

## MEDIUM Issues

### M-1: No Withdrawal Mechanism

**Location**: `ValidatorPodManager.sol`

**Description**: There's no way to actually withdraw restaked ETH. Shares are tracked but can't be redeemed.

**Impact**: Funds permanently locked in the protocol.

**Fix**: Implement withdrawal queue similar to EigenLayer.

---

### M-2: Checkpoint Can Use Stale Beacon Root

**Location**: `ValidatorPod.sol:246-248`

**Description**: `startCheckpoint` uses `block.timestamp` to get beacon root, but doesn't verify the root is sufficiently recent.

**Impact**: Checkpoints could use outdated balance data.

---

### M-3: Pod Balance Double-Counting Risk

**Location**: `ValidatorPod.sol:342-346`

**Description**: In `_finalizeCheckpoint`, both `balanceDeltasGwei` AND `podBalanceGwei` are added to the total delta:

```solidity
int256 totalDeltaWei = int256(currentCheckpoint.balanceDeltasGwei) * 1 gwei;
totalDeltaWei += int256(uint256(currentCheckpoint.podBalanceGwei)) * 1 gwei;
```

If the pod balance came from validator withdrawals that are also reflected in balance deltas, this could double-count.

---

## LOW Issues

### L-1: No Event for Operator Deregistration

**Location**: `ValidatorPodManager.sol`

**Description**: `OperatorDeregistered` event is defined but never emitted (no deregistration function).

---

### L-2: ValidatorInfo Uses uint64 for validatorIndex But Casts From uint40

**Location**: `ValidatorPod.sol:212-217`

**Description**: Inconsistent types - `validatorIndex` parameter is `uint40` but stored as `uint64`.

---

## Recommendations

1. **Do NOT use in production** until critical issues are fixed
2. Port EigenLayer's `BeaconChainProofs.sol` directly (MIT licensed)
3. Add comprehensive fuzz testing for Merkle proofs
4. Get professional audit before mainnet deployment

---

## Test Coverage Requirements

Before production, need tests for:

- [ ] Empty proof rejection
- [ ] Invalid proof rejection
- [ ] Correct generalized index calculation
- [ ] State root → validator path verification
- [ ] Balance extraction (little-endian)
- [ ] Withdrawal credentials validation
- [ ] Checkpoint accounting
- [ ] Slashing proportionality
- [ ] Delegation limits
- [ ] Access control
