# Payment Distribution Audit - tnt-core

**Date:** 2026-02-03  
**Auditor:** Subagent (payments-audit)  
**Scope:** Payment distribution flow, operator vs restaker compensation

---

## Executive Summary

The claims under investigation are **TECHNICALLY VALID** but the design appears **INTENTIONAL** for a restaking protocol where operator compensation is based on **risk commitment** (exposure) rather than **capital provided** (stake).

### Claims Investigated:
1. ✅ **CONFIRMED**: "Operator payment share is based on exposureBps (their claimed commitment), NOT actual stake"
2. ⚠️ **PARTIALLY CONFIRMED**: "An operator with 0 stake but 50% exposure gets paid the same as one with 1000 ETH staked at 50%"
   - Note: Operators need `minOperatorStake` (not 0), but an operator with 10 ETH at 50% exposure gets the same operator share as one with 1000 ETH at 50%

---

## 1. Payment Flow Analysis

### Entry Point: Subscription Billing
**File:** `src/core/Payments.sol` (lines 119-155)

```solidity
function _billSubscriptionInternal(uint64 serviceId) internal {
    // ... validation ...
    
    address[] memory operators = _serviceOperatorSet[serviceId].values();
    uint256 operatorsLength = operators.length;
    uint16[] memory exposures = new uint16[](operatorsLength);
    uint256 totalExposure = 0;

    for (uint256 i = 0; i < operatorsLength;) {
        // KEY: exposureBps is the operator's DECLARED commitment, NOT their actual stake
        exposures[i] = _serviceOperators[serviceId][operators[i]].exposureBps;
        totalExposure += exposures[i];
        unchecked { ++i; }
    }

    _distributePayment(serviceId, svc.blueprintId, token, rate, operators, exposures, totalExposure);
}
```

### How `exposureBps` is Set
**File:** `src/core/Services.sol` (lines 667-730)

```solidity
function joinService(uint64 serviceId, uint16 exposureBps) external whenNotPaused nonReentrant {
    // ... validation ...
    
    // Only check: operator meets MINIMUM stake requirement (NOT proportional to exposureBps)
    uint256 minStake = _staking.minOperatorStake();
    if (!_staking.meetsStakeRequirement(msg.sender, minStake)) {
        revert Errors.InsufficientStake(msg.sender, minStake, _staking.getOperatorStake(msg.sender));
    }
    
    // exposureBps is simply stored as declared - no validation against actual stake
    _serviceOperators[serviceId][msg.sender] = Types.ServiceOperator({
        exposureBps: exposureBps,  // <-- OPERATOR CHOOSES THIS VALUE
        joinedAt: uint64(block.timestamp),
        leftAt: 0,
        active: true
    });
}
```

---

## 2. Operator Payment Calculation

**File:** `src/libraries/PaymentLib.sol` (lines 88-128)

```solidity
function calculateOperatorPayments(
    uint256 totalOperatorAmount,
    uint256 totalRestakerAmount,
    address[] memory operators,
    uint16[] memory exposures,      // <-- This is exposureBps, NOT stake
    uint256 totalExposure
) internal pure returns (OperatorPayment[] memory payments) {
    if (totalExposure == 0) {
        return new OperatorPayment[](0);
    }

    payments = new OperatorPayment[](operators.length);

    for (uint256 i = 0; i < operators.length; i++) {
        uint256 exposure = exposures[i];

        if (i == operators.length - 1) {
            // Last operator gets remainder
            payments[i] = OperatorPayment({
                operator: operators[i],
                operatorShare: totalOperatorAmount - operatorDistributed,
                restakerShare: totalRestakerAmount - restakerDistributed
            });
        } else {
            // KEY CALCULATION: Payment based on exposure, NOT actual stake
            uint256 opShare = (totalOperatorAmount * exposure) / totalExposure;
            uint256 restakeShare = (totalRestakerAmount * exposure) / totalExposure;
            // ...
        }
    }
}
```

### Critical Observation
The `exposure` variable in the payment calculation is **directly** the `exposureBps` value that operators declare when joining. There is **NO** lookup of actual stake or delegation amounts.

---

## 3. Restaker Payment Path (Contrasting Behavior)

**File:** `src/rewards/ServiceFeeDistributor.sol`

The restaker share flows to `ServiceFeeDistributor.distributeServiceFee()` which **DOES** use actual stake:

```solidity
// Restaker distribution uses actual delegation scores
mapping(address => mapping(bytes32 => uint256)) public totalAllScore;
mapping(address => mapping(uint64 => mapping(bytes32 => uint256))) public totalFixedScore;
```

Scores are computed from actual delegated amounts:
```solidity
// In onDelegationChanged() - called when delegation changes
uint256 scoreDelta = (amount * lockMultiplierBps) / BPS_DENOMINATOR;
totalAllScore[operator][assetHash] += scoreDelta;
```

**Restaker payments ARE weighted by actual capital provided.**

---

## 4. Economic Relationship: Exposure vs Slashing

The design appears intentional because `exposureBps` affects slashing:

**File:** `src/core/Slashing.sol` (lines 59-62)

```solidity
uint16 effectiveExposureBps = opData.exposureBps;
// ... commitment calculation ...
uint16 cappedSlashBps = SlashingLib.capSlashBps(slashBps, _slashState.config.maxSlashBps);
```

**File:** `src/libraries/SlashingLib.sol` (lines 159-165)

```solidity
function calculateEffectiveSlashBps(
    uint16 slashBps,
    uint16 exposureBps
) internal pure returns (uint16) {
    return uint16((uint256(slashBps) * exposureBps) / BPS_DENOMINATOR);
}
```

Higher exposure = more slashable stake. So `exposureBps` represents **risk commitment**, not capital.

---

## 5. Verdict: Intentional Design vs Bug

### Evidence Supporting INTENTIONAL Design:
1. **Risk-based compensation**: Operators are paid for slashing risk taken (exposure), not capital provided
2. **Separation of concerns**: 
   - Operator share → compensation for service provision and risk commitment
   - Restaker share → return on capital (correctly uses actual stake)
3. **Slashing alignment**: `exposureBps` directly affects slashable amount, creating economic alignment

### Evidence Supporting POTENTIAL ISSUE:
1. **No maximum validation**: Operator can claim 100% exposure with minimum stake
2. **No proportionality check**: No validation that `exposureBps` is reasonable given actual stake
3. **Gaming potential**: If slashing is rare/never happens, operators can claim high exposure with minimal capital

---

## 6. Economic Implications

### Scenario Analysis

| Operator | Actual Stake | exposureBps | Operator Payment Share | Slashable Amount |
|----------|-------------|-------------|------------------------|------------------|
| Alice    | 1000 ETH    | 5000 (50%)  | 50%                    | 500 ETH          |
| Bob      | 10 ETH      | 5000 (50%)  | 50%                    | 5 ETH            |

**Result**: Bob receives the same operator payment as Alice despite having 1% of her capital at risk.

### Risk Analysis
- **If slashing is credible**: Bob's exposure is capped at 5 ETH (his actual stake), creating implicit protection
- **If slashing is rare/theoretical**: Bob extracts disproportionate value with minimal capital

---

## 7. Recommendations

### If This Is Intentional Design:
1. **Document explicitly** in NatSpec that operator payment is risk-based, not capital-based
2. **Consider adding** an optional proportionality check per blueprint
3. **Ensure** slashing is credible and automated to maintain economic alignment

### If This Is a Bug/Oversight:
1. **Add validation** in `joinService()`:
   ```solidity
   uint256 actualStake = _staking.getOperatorStake(msg.sender);
   uint256 maxExposure = (actualStake * BPS_DENOMINATOR) / totalServiceValue;
   require(exposureBps <= maxExposure, "Exposure exceeds stake");
   ```
2. **Weight operator payments** by `min(exposureBps, actualStakeProportionBps)`

---

## 8. Code Path Summary

```
Service Billing
    │
    ▼
Payments._billSubscriptionInternal()
    │
    ├── Collects exposureBps from _serviceOperators[].exposureBps
    │   (Operator-declared, NOT actual stake)
    │
    ▼
Payments._distributePayment()
    │
    ├── Calculates split via PaymentLib.calculateSplit()
    │   • developerAmount
    │   • protocolAmount  
    │   • operatorAmount  ──────────────────────┐
    │   • restakerAmount  ───────────────────┐  │
    │                                        │  │
    ▼                                        │  │
PaymentLib.calculateOperatorPayments()       │  │
    │                                        │  │
    │  opShare = operatorAmount * exposureBps / totalExposure
    │  (NO actual stake lookup!)             │  │
    │                                        │  │
    ├── operatorShare → _pendingRewards      │  │
    │                   (based on exposure)  │  │
    │                                        │  │
    └── restakerShare ───────────────────────┘  │
              │                                 │
              ▼                                 │
    ServiceFeeDistributor.distributeServiceFee()
              │
              │  Uses totalAllScore / totalFixedScore
              │  (Based on ACTUAL delegated amounts)
              │
              ▼
        Restaker rewards (stake-weighted)
```

---

## 9. Conclusion

The payment system has **two distinct compensation models**:

| Recipient | Compensation Basis | Variable Used | Correct? |
|-----------|-------------------|---------------|----------|
| Operators | Risk commitment (exposure) | `exposureBps` | By design |
| Restakers | Capital provided (stake) | `totalAllScore` | ✅ Yes |

The operator payment path using `exposureBps` instead of actual stake is **likely intentional** for a restaking protocol where operators are compensated for the slashing risk they accept, while restakers are compensated for capital provided.

**However**, without explicit documentation or proportionality guards, this creates potential for gaming if slashing is not credibly enforced.

---

*Generated by payments-audit subagent*
