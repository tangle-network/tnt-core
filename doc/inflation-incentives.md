# TNT Inflation Incentive System

## Overview

Pre-funded reward pool that distributes TNT to ecosystem participants based on activity metrics. No minting - only distributes what's funded.

## Distribution Weights

| Category | Weight | Rationale |
|----------|--------|-----------|
| Staking | 10% | Passive capital provision - lowest value |
| Operators | 25% | Active work running services |
| Customers | 10% | Fee rebates for service usage |
| Developers | 25% | Blueprint creation and ecosystem growth |
| Restakers | 30% | Real slashing risk from service exposure |

**Verify:** `InflationPool.getWeights()` returns `(1000, 2500, 1000, 2500, 3000)`

### Design Rationale

- **Staking (10%)**: Passive deposits that aren't delegated to services provide minimal security value
- **Restakers (30%)**: Delegators whose stake secures active services take real slashing risk and deserve the largest share
- **Operators/Developers (25% each)**: Active participants who build and run the ecosystem
- **Customers (10%)**: Rebate for service usage to encourage adoption

## Epoch Configuration

| Parameter | Value | Contract Field |
|-----------|-------|----------------|
| Seconds per year | 365 days | `SECONDS_PER_YEAR` |
| Default epoch | 7 days | `epochLength` (configurable) |

**Verify:** `InflationPool.epochLength()`

## Operator Score Formula

```
score = jobScore + heartbeatBonus

jobScore = (jobsCompleted × successRate × stakeWeight) / 10000
heartbeatBonus = (heartbeats × stakeWeight) / 100
stakeWeight = operatorTotalStake / 1e9
successRate = (successfulJobs × 10000) / jobsCompleted
```

**Note:** Uses LINEAR stake weight (not sqrt) to prevent Sybil advantage from stake splitting.
With sqrt, splitting 100 stake into 2×50 gives +41% more score. Linear is Sybil-neutral.

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

## Restaker Score Formula

```
score = exposureScore
exposureScore = USD_exposure × duration_seconds
```

Rewards delegators proportionally to their risk exposure - higher USD value staked for longer durations = higher score.

**Verify via TangleMetrics:**
- `delegatorExposureScore(delegator)`
- `totalExposureScore()`
- `getRestakerStats(delegator)` returns `(exposureScore, shareOfTotal)`

## Customer Score Formula

```
score = totalFeesPaid
```

Simple proportional rebate based on fees paid.

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
- **Only stakers**: 100% to staking
- **Stakers + restakers**: 50% each
- **All active**: Uses configured weights (10/25/10/25/30)

## Admin Configuration

### Changing Weights

```solidity
// Requires ADMIN_ROLE
// All five must sum to 10000 (100%)
InflationPool.setDistributionWeights(
    1000,  // stakingBps (10%)
    2500,  // operatorsBps (25%)
    1000,  // customersBps (10%)
    2500,  // developersBps (25%)
    3000   // restakersBps (30%)
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

## Key Contracts

| Contract | Purpose |
|----------|---------|
| `InflationPool` | Epoch distribution, claiming, weight configuration |
| `TangleMetrics` | Activity recording (jobs, heartbeats, exposure, fees) |
| `RewardVaults` | Staking reward distribution to delegators |
| `ServiceFeeDistributor` | Service fee distribution and exposure tracking |

## Governance

The InflationPool is modular and upgradeable:

1. **Upgrade existing**: Governance can upgrade via `UPGRADER_ROLE`
2. **Deploy new**: Deploy a new incentive contract pointing to same TangleMetrics
3. **Change weights**: Call `setDistributionWeights()` via governance

New incentive contracts can read from TangleMetrics (public view functions) and apply completely different formulas without touching core protocol.

## Verification Commands

```solidity
// Check current weights
InflationPool.getWeights() // (staking, operators, customers, developers, restakers)

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
TangleMetrics.getRestakerStats(delegator)
```

## Vault UI + Claiming Helpers

| Function | Purpose |
|----------|---------|
| `getVaultSummary(asset)` | Config+state+utilization for vault tables |
| `getAllVaultSummaries()` | Fetch every vault snapshot in one call |
| `getDelegatorPositions(asset, delegator)` | Operator positions with scores and pending TNT |
| `pendingDelegatorRewardsAll(asset, delegator)` | Batch view for "Claim All" buttons |
| `claimDelegatorRewardsBatch(asset, operators[])` | Single tx to claim multiple pools |
| `claimDelegatorRewardsFor(asset, operator, delegator)` | Third-party claim trigger |
