# Security Audit: Issue #75 - Operators Can Commit Without Stake

**Auditor**: Ferdinand (OpenClaw)  
**Date**: 2026-02-03  
**Severity Assessment**: CRITICAL (Confirmed)

## Executive Summary

**The issue is VALID.** After tracing the complete flow from service request → approval → activation → payment → slashing, I confirm that:

1. ✅ **Operators can approve services claiming security for assets they don't hold**
2. ✅ **They receive full payment based on claimed exposure, not actual stake**
3. ✅ **Slashing produces zero penalty for zero-stake operators**
4. ✅ **The validation code EXISTS but is NEVER CALLED**

This is not intentional design. The `ExposureManager.validateCommitments()` function was written specifically to prevent this attack but was never integrated into the approval flow.

---

## Detailed Analysis

### 1. Approval Flow Missing Stake Validation

**File**: `src/core/ServicesApprovals.sol`

The `_validateSecurityCommitments()` function (line 226) validates:
- ✅ No duplicate commitments
- ✅ Exposure % within min/max bounds
- ❌ **DOES NOT CHECK**: Operator has actual stake in the asset

```solidity
// What IS validated (lines 226-260):
function _validateSecurityCommitments(...) internal view {
    // 1. Check for duplicates
    for (uint256 i = 0; i < commitments.length; i++) {
        for (uint256 j = i + 1; j < commitments.length; j++) {
            if (commitments[i].asset.token == commitments[j].asset.token ...) {
                revert Errors.DuplicateAssetCommitment(...);
            }
        }
    }
    
    // 2. Check each requirement has valid commitment
    for (uint256 i = 0; i < requirements.length; i++) {
        // Only validates exposureBps is within [min, max] bounds
        if (commitments[j].exposureBps < req.minExposureBps) { revert; }
        if (commitments[j].exposureBps > req.maxExposureBps) { revert; }
    }
    
    // MISSING: No call to staking.getOperatorStakeForAsset()
}
```

### 2. ExposureManager Has Correct Validation (But Unused)

**File**: `src/exposure/ExposureManager.sol`

The `validateCommitments()` function at line 129 DOES check stake:

```solidity
function _validateSingleCommitment(...) internal view returns (...) {
    // ... bounds validation ...
    
    // THIS IS THE CORRECT CHECK (lines 243-252):
    uint256 delegation = _getOperatorDelegationForAsset(operator, requirement.asset);
    if (delegation == 0) {
        return (false, ExposureTypes.CommitmentValidationResult({
            valid: false,
            reason: "No delegation for asset",  // ← This should reject!
            asset: requirement.asset,
            requiredStake: 1,
            actualStake: 0
        }));
    }
}
```

**Evidence this is intentional design (from ExposureManager.sol header comments):**
```
/// Architecture:
/// 3. When operators approve, their commitments are validated against:
///    - Their own exposure limits
///    - Min/max from service requirements  
///    - Their actual delegation for each asset  ← INTENDED BUT NOT WIRED
```

**Grep for usage:**
```bash
$ grep -rn "validateCommitments" --include="*.sol" src/
# Only found in: ExposureManager.sol itself + test files
# NEVER called from ServicesApprovals or TangleServicesFacet
```

### 3. Payment Distribution Ignores Actual Stake

**File**: `src/core/Payments.sol` + `src/libraries/PaymentLib.sol`

Payment is distributed based on `exposureBps` (the claimed commitment), NOT actual stake:

```solidity
// Payments.sol lines 146-153 - exposure comes from stored commitment
for (uint256 i = 0; i < operatorsLength;) {
    exposures[i] = _serviceOperators[serviceId][operators[i]].exposureBps;  // ← From commitment
    totalExposure += exposures[i];
}

// PaymentLib.sol line 160 - no stake in formula
uint256 opShare = (totalOperatorAmount * exposure) / totalExposure;
```

**Impact Example:**
| Operator | Actual Stake | Claimed Exposure | Payment |
|----------|-------------|------------------|---------|
| Alice    | 1000 ETH    | 50%              | 200 USDC |
| Bob      | 0 ETH       | 50%              | 200 USDC |

Bob gets paid equally despite providing zero security.

### 4. Slashing Returns Zero for Zero Stake

**File**: `src/staking/SlashingManager.sol`

Lines 519-522 show the early return for zero stake:

```solidity
uint256 operatorStake = assetHash == bondHash ? meta.stake : 0;
if (operatorStake == 0 && allPool.totalAssets == 0 && bpPool.totalAssets == 0) {
    return 0;  // ← Zero-stake operator loses nothing
}
```

And slashing calculation (lines 524-527):
```solidity
uint256 operatorSlashAmount = (operatorStake * slashBps) / BPS_DENOMINATOR;
// If operatorStake = 0, operatorSlashAmount = 0
```

### 5. Request Validation Also Missing Stake Check

**File**: `src/core/ServicesRequests.sol`

The `_validateRequestOperators()` function (line 189) only checks:
- ✅ Operator is registered for blueprint
- ✅ Operator is active in staking
- ❌ **DOES NOT CHECK**: Operator has stake for requested assets

---

## Attack Scenario (Confirmed Viable)

1. Deployer creates service requiring 1000 ETH security
2. Selects Operator Bob (who has 0 ETH staked, but is a registered operator)
3. Request passes `_validateRequestOperators` (only checks isOperatorActive)
4. Bob calls `approveServiceWithCommitments([{asset: ETH, exposureBps: 5000}])`
5. `_validateSecurityCommitments` passes (only checks bounds, not stake)
6. Service activates, Bob's exposure stored as 50%
7. Billing occurs: Bob receives 50% of operator share
8. Slashing occurs: `operatorStake = 0`, slash amount = 0
9. **Result**: Bob collected fees for security he never provided

---

## Recommended Fixes

### Option A: Wire Up ExposureManager (Recommended)

Add to `ServicesApprovals._approveServiceWithCommitmentsInternal()`:

```solidity
// After existing validation
if (requirements.length > 0) {
    _validateSecurityCommitments(requirements, commitments);
    
    // NEW: Validate operator has actual stake
    (bool valid, ExposureTypes.CommitmentValidationResult memory result) = 
        _exposureManager.validateCommitments(msg.sender, requirements, commitments);
    if (!valid) {
        revert Errors.InvalidCommitment(result.reason);
    }
}
```

### Option B: Inline Stake Check

Add to `_validateSecurityCommitments()`:

```solidity
for (uint256 i = 0; i < requirements.length; i++) {
    // ... existing bounds validation ...
    
    // NEW: Verify operator has actual stake
    uint256 operatorStake = _staking.getOperatorStakeForAsset(msg.sender, req.asset);
    if (operatorStake == 0) {
        revert Errors.NoStakeForAsset(req.asset.token);
    }
}
```

### Additional: Validate at Request Time

Add to `_validateRequestOperators()`:

```solidity
// NEW: Check operator has stake for at least one security requirement
if (_requestSecurityRequirements[requestId].length > 0) {
    bool hasAnyStake = false;
    for (uint256 j = 0; j < requirements.length; j++) {
        if (_staking.getOperatorStakeForAsset(operators[i], requirements[j].asset) > 0) {
            hasAnyStake = true;
            break;
        }
    }
    if (!hasAnyStake) {
        revert Errors.OperatorHasNoStakeForRequirements(operators[i]);
    }
}
```

---

## Files Requiring Changes

| File | Function | Change |
|------|----------|--------|
| `src/core/ServicesApprovals.sol` | `_validateSecurityCommitments` | Add stake validation |
| `src/core/ServicesApprovals.sol` | `_approveServiceWithCommitmentsInternal` | Wire ExposureManager |
| `src/core/ServicesRequests.sol` | `_validateRequestOperators` | Add stake pre-check |
| `src/core/Base.sol` | State | Add `_exposureManager` reference |

---

## Severity: CRITICAL

- **Likelihood**: High - Any registered operator can exploit this
- **Impact**: High - Complete bypass of economic security model
- **Exploitability**: Easy - No special tools or timing required
- **Detection**: Low - No on-chain indication of zero-stake operators

This fundamentally undermines the protocol's security guarantees. Service requesters pay for security they don't receive.
