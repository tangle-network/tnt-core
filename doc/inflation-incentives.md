# TNT Inflation Incentive System

## Overview

Pre-funded reward pool that distributes TNT to ecosystem participants based on activity metrics. No minting - only distributes what's funded.

Service-fee rewards for restakers are paid from service payments via `ServiceFeeDistributor`. Inflation can optionally
allocate a restaker share that is also distributed through `ServiceFeeDistributor` by exposure.

## Distribution Weights

| Category | Weight | Rationale |
|----------|--------|-----------|
| Staking | 40% | Explicit staking incentives (RewardVaults) |
| Operators | 25% | Active work running services |
| Customers | 10% | Fee rebates for service usage |
| Developers | 25% | Blueprint creation and ecosystem growth |
| Restakers | 0% (default) | Optional exposure-weighted restaker inflation |

**Verify:** `InflationPool.getWeights()` returns `(4000, 2500, 1000, 2500, 0)`

### Design Rationale

- **Staking (40%)**: Primary inflation sink to fund TNT staking incentives via `RewardVaults`
- **Operators/Developers (25% each)**: Active participants who build and run the ecosystem
- **Customers (10%)**: Rebate for service usage to encourage adoption
- **Restakers (0% default)**: Optional exposure-weighted inflation for delegators

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

## Restaker Inflation (Optional)

When `restakersBps > 0`, the pool distributes a restaker share by exposure using `ServiceFeeDistributor`.
An account with `DISTRIBUTOR_ROLE` calls `distributeEpochWithServices(serviceIds)` with the active services for that epoch.

Restaker inflation is allocated:
1. By service exposure (USD-weighted) across services in the list.
2. By operator exposure within each service.
3. By delegator score within each operator and asset (handled by `ServiceFeeDistributor`).

Configuration:
- `InflationPool.setRestakerInflationConfig(tangle, serviceFeeDistributor)`
- `ServiceFeeDistributor.setInflationPool(inflationPool)`

## Operator Commission

| Parameter | Value | Contract Field |
|-----------|-------|----------------|
| Commission | 15% | `RewardVaults.operatorCommissionBps = 1500` |

Operator receives commission, remainder goes to delegator pool.

**Verify:** `RewardVaults.operatorCommissionBps()`

## Redistribution

When a category has no eligible participants, its allocation redistributes to active categories **equally** (not by weight).
If restaker inflation is configured but no eligible services are provided, that share remains in the pool for a later epoch.

Example scenarios:
- **Only stakers**: 100% to staking
- **Stakers + operators**: 50% each
- **All active**: Uses configured weights (40/25/10/25)

## Admin Configuration

### Changing Weights

```solidity
// Requires ADMIN_ROLE
// All five must sum to 10000 (100%)
InflationPool.setWeights(
    4000,  // stakingBps (40%)
    2500,  // operatorsBps (25%)
    1000,  // customersBps (10%)
    2500,  // developersBps (25%)
    0      // restakersBps (0% default)
);
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
| `TangleMetrics` | Activity recording (jobs, heartbeats, fees) |
| `RewardVaults` | Staking reward distribution to delegators |
| `ServiceFeeDistributor` | Service-fee rewards to restakers (separate from inflation) |

## Governance

The InflationPool is modular and upgradeable:

1. **Upgrade existing**: Governance can upgrade via `UPGRADER_ROLE`
2. **Deploy new**: Deploy a new incentive contract pointing to same TangleMetrics
3. **Change weights**: Call `setWeights()` via governance

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
