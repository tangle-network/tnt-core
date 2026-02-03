# Security Audit: Slashing Flow Analysis

## Executive Summary

**Claim Under Analysis:** "If an operator has 0 stake in a committed asset, slashing returns 0"

**Verdict: PARTIALLY TRUE - with critical nuances**

The claim is technically accurate for the **operator's self-stake portion**, but **MISLEADING** regarding overall slashing behavior. Delegator assets ARE still slashed even when the operator has 0 self-stake.

---

## 1. Slashing Entry Points

Three main entry points exist in `StakingSlashingFacet.sol`:

```solidity
function slashForBlueprint(operator, blueprintId, serviceId, slashBps, evidence)
function slashForService(operator, blueprintId, serviceId, commitments, slashBps, evidence)
function slash(operator, serviceId, slashBps, evidence)  // consensus/native only
```

All require `SLASHER_ROLE` (held by Tangle core contract).

---

## 2. Full Slashing Flow Trace

### 2.1 From `executeSlash()` in Slashing.sol (lines 85-107)

```solidity
function executeSlash(uint64 slashId) external nonReentrant returns (uint256 actualSlashed) {
    // ...validation...
    
    // Calls staking contract's slashForBlueprint
    actualSlashed = _staking.slashForBlueprint(
        proposal.operator,
        svc.blueprintId,
        proposal.serviceId,
        proposal.effectiveSlashBps,
        proposal.evidence
    );
    // ...
}
```

### 2.2 `_slashForBlueprint()` in SlashingManager.sol (lines 165-221)

This iterates through all enabled assets (native + ERC20s) and calls `_slashBlueprintPoolsForAsset()` for each.

### 2.3 **CRITICAL FUNCTION:** `_slashBlueprintPoolsForAsset()` (lines 380-455)

```solidity
function _slashBlueprintPoolsForAsset(
    address operator,
    uint64 blueprintId,
    uint64 serviceId,
    Types.Asset memory asset,
    bytes32 assetHash,
    bytes32 bondHash,
    uint16 slashBps,
    bytes32 evidence,
    Types.OperatorMetadata storage meta
) internal returns (uint256 assetSlashed) {
    Types.OperatorRewardPool storage allPool = _rewardPools[operator][assetHash];
    Types.OperatorRewardPool storage bpPool = _blueprintPools[operator][blueprintId][assetHash];
    
    // ⚠️ KEY LOGIC: Determine operator stake for THIS asset
    uint256 operatorStake = assetHash == bondHash ? meta.stake : 0;
    
    // ⚠️ EARLY RETURN CONDITION
    if (operatorStake == 0 && allPool.totalAssets == 0 && bpPool.totalAssets == 0) {
        return 0;  // Returns 0 ONLY if ALL three are zero
    }
    
    // Calculate slash amounts
    uint256 operatorSlashAmount = (operatorStake * slashBps) / BPS_DENOMINATOR;
    uint256 allModeSlashAmount = (allPool.totalAssets * slashBps) / BPS_DENOMINATOR;
    uint256 fixedModeSlashAmount = (bpPool.totalAssets * slashBps) / BPS_DENOMINATOR;
    
    // Execute slashes
    uint256 actualOperatorSlash = operatorSlashAmount > 0 ? _slashOperatorStake(operator, operatorSlashAmount) : 0;
    uint256 actualAllModeSlash = _slashAllModePool(operator, assetHash, allModeSlashAmount);
    uint256 actualFixedModeSlash = _slashBlueprintPool(operator, blueprintId, assetHash, fixedModeSlashAmount);
    
    assetSlashed = actualOperatorSlash + actualAllModeSlash + actualFixedModeSlash;
    // ...
}
```

---

## 3. What Happens When Operator Has 0 Stake

### Scenario A: Operator has 0 stake, NO delegators
- `operatorStake = 0`
- `allPool.totalAssets = 0`
- `bpPool.totalAssets = 0`
- **Result:** Early return with `0` ✅

### Scenario B: Operator has 0 stake, BUT has delegators
- `operatorStake = 0`
- `allPool.totalAssets = 100 ETH` (from delegators)
- `bpPool.totalAssets = 50 ETH` (from fixed-mode delegators)
- **Result:** 
  - `actualOperatorSlash = 0` (no self-stake to slash)
  - `actualAllModeSlash = 100 ETH * slashBps / 10000` ⚠️ **DELEGATORS SLASHED**
  - `actualFixedModeSlash = 50 ETH * slashBps / 10000` ⚠️ **DELEGATORS SLASHED**

---

## 4. Security Commitment Validation Gap

### The Problem

In `ServicesApprovals.sol`, `_validateSecurityCommitments()` only validates:
1. No duplicate asset commitments
2. Each required asset has a commitment
3. Commitment `exposureBps` is within min/max bounds

```solidity
function _validateSecurityCommitments(
    Types.AssetSecurityRequirement[] storage requirements,
    Types.AssetSecurityCommitment[] calldata commitments
) internal view {
    // Validates format and bounds
    // ⚠️ DOES NOT validate operator actually holds these assets!
}
```

### Attack Vector

An operator can:
1. Commit to assets they don't hold (e.g., commit 100% exposure to TokenX)
2. Join services requiring TokenX security
3. Collect rewards/fees
4. If slashed, their TokenX slash = 0 (they have none)
5. **Delegators who delegated TokenX to this operator get slashed instead**

---

## 5. Delegator Slashing Deep Dive

### `_slashAllModePool()` (lines 328-345)

```solidity
function _slashAllModePool(
    address operator,
    bytes32 assetHash,
    uint256 amount
) internal returns (uint256 slashed) {
    Types.OperatorRewardPool storage pool = _rewardPools[operator][assetHash];
    
    if (pool.totalAssets == 0 || amount == 0) {
        return 0;
    }
    
    // Reduces totalAssets - delegator shares remain constant
    // Exchange rate drops: each share worth less
    if (pool.totalAssets >= amount) {
        pool.totalAssets -= amount;
        slashed = amount;
    } else {
        slashed = pool.totalAssets;
        pool.totalAssets = 0;
    }
}
```

This is ERC4626-style O(1) slashing. **Delegators are slashed regardless of operator's self-stake.**

---

## 6. Mitigating Factors

### 6.1 Minimum Operator Stake Requirement
```solidity
// In DelegationStorage.sol
struct AssetConfig {
    uint256 minOperatorStake;  // Configurable per asset
    // ...
}
```
Operators must meet minimum stake to be `Active`. However:
- This is per-asset configurable
- Could be set to 0
- Operator could reduce stake after joining services

### 6.2 Operator Status Check
After slashing, if operator's bond asset stake falls below minimum:
```solidity
uint256 minStake = _assetConfigs[bondHash].minOperatorStake;
if (meta.stake < minStake) {
    meta.status = Types.OperatorStatus.Inactive;
}
```
This prevents future service joins but doesn't protect existing delegators.

### 6.3 Delegation Mode Restrictions
Operators can restrict who delegates to them:
```solidity
enum DelegationMode {
    Disabled,   // Only operator can self-stake
    Whitelist,  // Only approved addresses
    Open        // Anyone can delegate
}
```

---

## 7. Security Implications

### HIGH Severity
1. **Delegator Exploitation:** Operators can commit to assets they don't hold, exposing delegators to 100% of the slashing risk while bearing 0% themselves.

2. **Asymmetric Risk:** Delegators may not realize their funds secure services for assets the operator hasn't staked.

### MEDIUM Severity
3. **Commitment Gaming:** Operators could strategically commit to high-exposure percentages for assets they don't hold, then reduce actual stake.

### LOW Severity
4. **Information Asymmetry:** No on-chain verification that commitments match actual holdings at slash time.

---

## 8. Recommendations

### Immediate
1. **Add stake verification at slash time:**
```solidity
// In _slashBlueprintPoolsForAsset
function _slashBlueprintPoolsForAsset(...) {
    // Calculate what operator SHOULD have based on commitments
    uint256 requiredStake = _calculateRequiredStake(operator, serviceId, assetHash);
    
    // If operator doesn't have enough, slash proportionally less from delegators
    // OR: revert if commitment was fraudulent
}
```

2. **Commitment validation at join time:**
```solidity
// In ServicesApprovals._validateSecurityCommitments
function _validateSecurityCommitments(...) {
    for (uint256 i = 0; i < commitments.length; i++) {
        uint256 operatorHolding = _staking.getOperatorStakeForAsset(msg.sender, commitments[i].asset);
        if (operatorHolding == 0 && commitments[i].exposureBps > 0) {
            revert Errors.CannotCommitToAssetNotHeld();
        }
    }
}
```

### Long-term
3. **Proportional slashing based on actual stake ratios**
4. **Delegator visibility into operator asset composition**
5. **Commitment snapshot at service join time**

---

## 9. Code References

| Location | Function | Relevance |
|----------|----------|-----------|
| `SlashingManager.sol:380-455` | `_slashBlueprintPoolsForAsset` | Main slash logic |
| `SlashingManager.sol:328-345` | `_slashAllModePool` | Delegator pool slash |
| `SlashingManager.sol:356-375` | `_slashBlueprintPool` | Fixed-mode pool slash |
| `ServicesApprovals.sol:228-280` | `_validateSecurityCommitments` | Commitment validation |
| `Slashing.sol:85-107` | `executeSlash` | External entry point |

---

## 10. Conclusion

The claim "If an operator has 0 stake in a committed asset, slashing returns 0" is:

- ✅ **TRUE** for operator self-stake portion
- ❌ **FALSE** for delegator funds (they WILL be slashed)
- ⚠️ **MISLEADING** because it implies zero economic impact

**The real risk:** Operators can commit to securing services with assets they don't hold, creating a situation where **delegators bear 100% of slashing risk** while operators bear **0%** for that specific asset.

This is a significant protocol design consideration that should be addressed to prevent delegator exploitation.

---

*Audit completed: 2026-02-03*
*Auditor: Claude (via OpenClaw)*
