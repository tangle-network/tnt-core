# TNT Tokenomics — tnt-core (EVM contracts)

Technical reference. Every number here is sourced from the contract code in this repo. Where a value is governance-adjustable, the default at initialization is given.

## Reward systems

TNT rewards in tnt-core flow through two mechanisms:

1. **Service fees** — payment splits on every service bill (see below). Fees are paid by service consumers in whatever token the service accepts; the split routes shares to operators, the blueprint developer, the protocol treasury, and stakers.
2. **InflationPool** — an epoch-based distribution of a governance-funded TNT allocation across five categories. The pool **cannot mint**; it distributes only what the treasury funds it with. This is the protocol-emission side of the economy.

Both mechanisms are pure EVM — no Substrate pallets involved.

## Payment split (every service bill)

Defined in `Types.PaymentSplit`, initialized in `Base.sol`, applied by `PaymentsDistribution._distributeBill`.

| Recipient | Default | Where |
|-----------|---------|-------|
| Operators (weighted by effective exposure) | 40% | `DEFAULT_OPERATOR_BPS = 4000` |
| Blueprint developer | 20% | `DEFAULT_DEVELOPER_BPS = 2000` |
| Protocol treasury | 20% | `DEFAULT_PROTOCOL_BPS = 2000` |
| Stakers/delegators (via ServiceFeeDistributor) | 20% | `DEFAULT_STAKER_BPS = 2000` |
| Keeper (bill-trigger gas rebate) | 0% | `DEFAULT_KEEPER_BPS = 0` |

Adjustable via `setPaymentSplit` (admin role).

### Operator weighting

Operators receive their 40% share weighted by **effective exposure**: delegation × `exposureBps` (the security commitment each operator has assigned to the blueprint). If no operator has effective exposure, the pool is split equally.

### Staker distribution

The staker 20% flows through `ServiceFeeDistributor`, which tracks per-operator, per-asset, per-token accumulated scores. Score = deposit amount × lock multiplier (bps). TNT-denominated stakes receive a configurable score boost (`tntScoreRate`).

### TNT payment discount

`_tntPaymentDiscountBps` (default 0): when a bill is paid in TNT rather than another token, the service owner receives a discount funded from the protocol share. This creates a demand sink for TNT-denominated service payments.

## InflationPool (epoch distribution)

`InflationPool.sol`. Receives a yearly TNT allocation from governance/treasury and streams it across five categories per epoch:

| Category | Default weight | Basis |
|----------|---------------|-------|
| Staking/delegators (via RewardVaults) | 40% | `stakingBps = 4000` |
| Operators | 25% | `operatorsBps = 2500` |
| Blueprint developers | 25% | `developersBps = 2500` |
| Customers (service usage) | 10% | `customersBps = 1000` |
| Staker exposure rewards | 0% | `stakersBps = 0` (governance can enable) |

Weights must sum to 10000 bps (`setDistributionWeights`). The pool is pre-funded via `fund()` (FUNDER_ROLE) and distributes per epoch via `distributeEpoch()` or `distributeEpochWithServices()`.

### No minting

The pool holds `IERC20 tntToken` and can only transfer. A compromise of this contract exposes the pool balance, not the token supply. Governance can `emergencyWithdraw()` remaining funds to a replacement pool.

## TangleMetrics (merit weighting)

`TangleMetrics.sol` records the activity data that operator/customer/developer weights draw on. Callable only by addresses holding RECORDER_ROLE:

| Function | Signal |
|----------|--------|
| `recordStake` / `recordUnstake` | Delegation changes |
| `recordOperatorRegistered` | New operator |
| `recordHeartbeat` | Operator liveness per service |
| `recordJobCompletion` | Per-job delivery (operators, developers) |
| `recordServiceCreated` / `recordServiceTerminated` | Service lifecycle |
| `recordSlash` | Operator violation (negative signal) |
| `recordJobCall` | Service demand |

Blueprints that drive more job completions and heartbeats generate more merit-score for their operators in the InflationPool distribution.

## Slashing

`SlashingManager.sol` + `OperatorStatusRegistry.sol`. Operators who fail service commitments are slashed by governance (propose → dispute window → execute). The `L2SlashingConnector` extends this to L2. Blueprint service managers inherit slashing hooks (see `ComputeProviderSlashing` in tangle-slashing).

## Staking architecture

`staking/` provides:

- **DepositManager** — reserve assets before delegation
- **DelegationManagerLib** — operator/delegator accounting
- **MultiAssetDelegation** — multi-token delegation with lock multipliers
- **LiquidDelegationVault / LiquidDelegationFactory** — ERC-4626-style liquid delegation shares
- **OperatorManager / OperatorStatusRegistry** — operator lifecycle

## Historical note

The predecessor Tangle chain (Substrate runtime) is archived. All live protocol logic — staking, delegation, blueprints, services, payments, rewards, slashing — is in these EVM contracts. The InflationPool's pre-funded design exists precisely because these contracts cannot mint: the treasury funds each yearly allocation, and the pool streams it. Block-level validator emissions (if the chain uses a validator set) are outside this repo's scope.
