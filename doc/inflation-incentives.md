# TNT Inflation Incentive System

## Overview

Pre-funded reward pool that distributes TNT to ecosystem participants based on activity metrics. No minting - only distributes what's funded.

## Distribution Weights

| Category | Weight | Contract Field |
|----------|--------|----------------|
| Staking | 50% | `weights.stakingBps = 5000` |
| Operators | 25% | `weights.operatorsBps = 2500` |
| Customers | 10% | `weights.customersBps = 1000` |
| Developers | 15% | `weights.developersBps = 1500` |

**Verify:** `InflationPool.getWeights()` returns `(5000, 2500, 1000, 1500)`

## Epoch Configuration

| Parameter | Value | Contract Field |
|-----------|-------|----------------|
| Seconds per year | 365 days | `SECONDS_PER_YEAR` |
| Legacy blocks per year (unused) | 2,628,000 | `BLOCKS_PER_YEAR` |
| Default epoch | 7 days | `epochLength` (configurable, in seconds) |

**Verify:** `InflationPool.epochLength()`

## Operator Score Formula

```
score = jobScore + heartbeatBonus

jobScore = (jobsCompleted × successRate × stakeWeight) / 10000
heartbeatBonus = (heartbeats × stakeWeight) / 100
stakeWeight = sqrt(operatorTotalStake / 1e18) × 1e9
successRate = (successfulJobs × 10000) / jobsCompleted
```

**Verify via TangleMetrics:**
- `operatorJobsCompleted(operator)`
- `operatorJobsSuccessful(operator)`
- `operatorTotalStake(operator)`
- `operatorHeartbeats(operator)`

## Developer Score Formula

```
score = blueprintScore + serviceScore + jobScore + feeScore

blueprintScore = blueprintCount × 500
serviceScore = totalServices × 1000
jobScore = totalJobs × 100
feeScore = sqrt(totalFees / 1e18) × 1e9
```

**Verify via TangleMetrics:**
- `developerBlueprintCount(developer)`
- `developerTotalServices(developer)`
- `developerTotalJobs(developer)`
- `developerTotalFees(developer)`

## Customer Score Formula

```
score = totalFeesPaid
```

**Verify:** `TangleMetrics.totalFeesPaid(customer)`

## Staking Distribution

Distributed proportionally across vaults based on deposits:
```
vaultShare = (epochBudget × stakingWeight × vaultDeposits) / (10000 × totalDeposits)
```

**Verify:** `RewardVaults.vaultStates(asset)` returns `(totalDeposits, ...)`

## Operator Commission

| Parameter | Value | Contract Field |
|-----------|-------|----------------|
| Commission | 15% | `RewardVaults.operatorCommissionBps = 1500` |

Operator receives commission, remainder goes to delegator pool.

**Verify:** `RewardVaults.operatorCommissionBps()`

## Redistribution

When a category has no eligible participants, its allocation redistributes to active categories **equally** (not by weight).

Example scenarios:
- **Only stakers**: 100% to staking (ops/customers/devs portions redistribute)
- **Stakers + operators**: ~62.5% staking, ~37.5% operators
- **Stakers + operators + devs**: ~53.3% staking, ~28.3% operators, ~18.3% developers
- **All active**: Uses configured weights (50/25/10/15)

## Admin Configuration

### Changing Weights

```solidity
// Requires ADMIN_ROLE
// All four must sum to 10000 (100%)
InflationPool.setWeights(
    5000,  // stakingBps (50%)
    2500,  // operatorsBps (25%)
    1000,  // customersBps (10%)
    1500   // developersBps (15%)
)
```

### Changing Epoch Length

```solidity
// Requires ADMIN_ROLE
// Min: 60 seconds, Max: 365 days
InflationPool.setEpochLength(7 days);
```

### Funding the Pool

```solidity
// Requires FUNDER_ROLE
// First approve tokens, then call fund()
TNT.approve(inflationPool, amount)
InflationPool.fund(amount)
```

## Key Contract Addresses

| Contract | Purpose |
|----------|---------|
| `InflationPool` | Epoch distribution, claiming |
| `TangleMetrics` | Activity recording |
| `RewardVaults` | Staking reward distribution |

## Verification Commands

```solidity
// Check current weights
InflationPool.getWeights() // (staking, operators, customers, developers)

// Check epoch status
InflationPool.currentEpoch()
InflationPool.isEpochReady()
InflationPool.poolBalance()

// Check pending rewards
InflationPool.pendingOperatorRewards(operator)
InflationPool.pendingCustomerRewards(customer)
InflationPool.pendingDeveloperRewards(developer)

// Check metrics
TangleMetrics.getOperatorSuccessRate(operator) // basis points
TangleMetrics.getBlueprintStats(blueprintId)
TangleMetrics.getDeveloperStats(developer)
```

## Vault UI + Claiming Helpers

To make the on-chain experience parity with the Substrate pallet while preserving our pre-funded guarantees, `RewardVaults` now exposes the following helpers:

| Function | Purpose |
|----------|---------|
| `getVaultSummary(asset)` | Returns config+state+derived utilization so UIs can render vault tables without extra RPC calls |
| `getAllVaultSummaries()` | Convenience helper to fetch every vault snapshot in one call |
| `getDelegatorPositions(asset, delegator)` | Lists every operator the delegator is staked with, including boosted score, lock metadata, and pending TNT |
| `pendingDelegatorRewardsAll(asset, delegator)` | Batch view of claimable rewards + total, used to drive “Claim All” buttons |
| `claimDelegatorRewardsBatch(asset, operators[])` | Single transaction to claim multiple operator pools; reduces UX friction and gas |
| `claimDelegatorRewardsFor(asset, operator, delegator)` | Lets helper services trigger claims on behalf of a delegator (funds always sent to delegator) |

These helpers mirror the capabilities of the Substrate rewards pallet (vault metadata, other-account claims, pooled accounting) while keeping TNT distribution limited to whatever funds governance pre-loads into `RewardVaults`.
