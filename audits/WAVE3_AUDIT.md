# Wave 3 Security Audit - Deep Analysis

**Date**: 2026-01-17
**Auditors**: Claude Code AI Fleet (6 specialized agents + Slither)
**Scope**: tnt-core v2 contracts

## Executive Summary

Deep security audit using static analysis (Slither) and 6 specialized agents covering invariants, MEV, upgrades, reentrancy, access control, and arithmetic. Found 70+ issues beyond the 47 already fixed.

## Severity Summary

| Severity | Count |
|----------|-------|
| HIGH | 7 |
| MEDIUM | 19 |
| LOW/INFO | 44+ |

---

## HIGH Severity (7)

### H-1: Pending Slash Count Mismatch Risk (INV-8)
**Location**: `Slashing.sol`, `SlashingManager.sol`
**Issue**: If `incrementPendingSlash`/`decrementPendingSlash` calls fail silently, count drifts permanently, blocking all delegator withdrawals forever.
**Fix**: Add admin recovery function to reset count; consider making operations atomic.

### H-2: TWAP Oracle Manipulation (MEV-6)
**Location**: `UniswapV3Oracle.sol`
**Issue**: 30-minute TWAP can be manipulated for low-liquidity pools, affecting slashing calculations.
**Fix**: Use ChainlinkOracle for high-stakes operations; add circuit breakers for price deviations.

### H-3: Beacon Chain Proof Arbitrage (MEV-10)
**Location**: `L2SlashingReceiver.sol`, bridge contracts
**Issue**: Cross-chain delay allows front-running L2 slashing by monitoring L1 events.
**Fix**: Implement retroactive slashing with lookback windows.

### H-4: L2SlashingReceiver Authorization (AC-4)
**Location**: `L2SlashingReceiver.sol:127-147`
**Issue**: Single owner can add malicious authorized senders to fabricate slash messages.
**Fix**: Add timelock for adding authorized senders.

### H-5: DEFAULT_ADMIN_ROLE Full Power (AC-5)
**Location**: `Base.__Base_init()`
**Issue**: Initial admin has complete protocol control; compromise = total takeover.
**Fix**: Transfer DEFAULT_ADMIN_ROLE to timelock immediately after deployment.

### H-6: Reentrancy in SlashingManager._slash (Slither)
**Location**: `SlashingManager.sol:348-349`
**Issue**: External call to `IServiceFeeDistributor.onFixedModeSlashed()` inside loop before state finalization.
**Fix**: Move external calls after all state updates or add reentrancy guard.

### H-7: ETH to Arbitrary User (Slither)
**Location**: `DepositManager.sol:324`
**Issue**: `_transferAsset` sends ETH to arbitrary address via low-level call.
**Fix**: Already uses CEI pattern; document trust assumptions.

---

## MEDIUM Severity (19)

### Invariant Issues
- **M-1 (INV-1)**: Share-to-asset conversion precision loss causes accounting drift
- **M-2 (INV-2)**: Blueprint pool and delegation record share mismatch
- **M-3 (INV-6)**: `delegatedAmount` not reduced after slashing
- **M-4 (INV-9)**: LiquidDelegationVault `totalAssets()` includes pending unstakes

### MEV Issues
- **M-5 (MEV-1)**: Pending slash check missing at `_executeDelegatorUnstake`
- **M-6 (MEV-2)**: `minStakeEpochs` can be set to 0, allowing flash stake
- **M-7 (MEV-8)**: Slash execution ordering can be gamed
- **M-8 (MEV-9)**: Blueprint selection mode can be changed to avoid slashes

### Upgrade Issues
- **M-9 (UPG-1)**: SlashingManager storage variables lack gap protection
- **M-10 (UPG-11)**: Enum reordering corrupts storage

### Reentrancy Issues
- **M-11 (REENT-4)**: Blueprint manager callback can manipulate state
- **M-12 (REENT-7)**: Cross-contract reentrancy via ServiceFeeDistributor

### Access Control Issues
- **M-13 (AC-1)**: Blueprint manager can force remove operators without limits
- **M-14 (AC-2)**: Service owner can propose slashes (conflict of interest)
- **M-15 (AC-3)**: Cross-chain messenger single owner control
- **M-16 (AC-6)**: TANGLE_ROLE has broad write access without timelock
- **M-17 (AC-8)**: `querySlashingOrigin` return value not validated

### Arithmetic Issues
- **M-18 (ARITH-3)**: Division before multiplication in score delta loses precision
- **M-19 (ARITH-11)**: Exposure BPS truncation allows escaping micro-slashes
- **M-20 (ARITH-12)**: LiquidDelegationVault lacks first-depositor protection

---

## LOW Severity (Selected)

- INV-3: Slashing below virtual assets offset
- INV-4: No path to resolve disputed slashes
- INV-5: Service operator state inconsistent after termination
- INV-7: Pending unstake shares not adjusted after slash
- INV-10: Force remove below minimum operators
- INV-11: Commission change first-set bypass
- INV-12: Effective slash BPS can be zero
- MEV-3: Subscription billing back-running
- MEV-5: Service approval racing
- MEV-7: Round advancement timing
- UPG-2 to UPG-7: Various upgrade safety improvements
- REENT-1,2,3,5,6,8: Minor reentrancy concerns
- AC-7,9,10,11,12: Access control improvements
- ARITH-1,2,4,10,15: Minor arithmetic issues

---

## Architectural Observations

1. **Trust Model Complexity**: Blueprint managers have significant power over operators. Document trust assumptions clearly.

2. **Cross-Contract State**: Tangle and Restaking share state but have separate reentrancy guards. Consider unified lock.

3. **Oracle Dependency**: Price oracle used in slashing creates manipulation surface. Consider fallback mechanisms.

4. **Pending Slash Tracking**: Counter-based approach is gas-efficient but fragile if operations fail.

---

## Recommendations Priority

1. Add pending slash recovery mechanism (H-1)
2. Timelock for L2SlashingReceiver authorized senders (H-4)
3. Transfer admin to timelock post-deployment (H-5)
4. Add pending slash check at unstake execution (M-5)
5. Enforce `minStakeEpochs >= 1` (M-6)
6. Apply virtual shares to LiquidDelegationVault (M-20)
7. Move SlashingManager storage to DelegationStorage (M-9)
8. Add minimum effective slash BPS (M-19)
