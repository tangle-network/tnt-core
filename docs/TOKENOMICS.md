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

## Stablecoin agent payments

Two stablecoin paths exist. Only an on-chain job enters the split above. This section does not change settlement and does not add a rate. `setPaymentSplit` remains the only way the live tuple changes; read it with `paymentSplit()`.

### On-chain EventDriven already uses the split

EventDriven settlement is native-token only at request time. `ServicesRequests._validatePricingPaymentConsistency` requires `paymentToken == address(0)` and `paymentAmount == 0`. The customer does not choose the asset. The blueprint owner does, with `setBlueprintSettlementAsset`. `address(0)` is native and is the default. Any other asset must pass the manager allow-list.

`submitJob` / `submitJobFromQuote` collect that pinned asset (`JobsSubmission._collectJobPaymentIfNeeded`, `JobsRFQ`). When a result finalizes the job, `TangleJobsFacet._distributeJobPayment` calls `distributePayment` with the same asset. That is `_distributePaymentWithEffectiveExposure` with no keeper, which is `_distributeBill`. An on-chain stablecoin job is already inside `PaymentSplit`.

At the default split in the table above, that gross reaches:

| Recipient | Default already in this file | Delivery |
|-----------|------------------------------|----------|
| Operators | 40% (`DEFAULT_OPERATOR_BPS = 4000`). This path is not a permissionless bill, so a keeper share, if an admin has set one, folds into this pool. The default keeper share is 0%. | `pendingRewards` for the settlement asset, withdrawn with `claimRewards` |
| Blueprint developer | 20% (`DEFAULT_DEVELOPER_BPS = 2000`) | Pushed to `queryDeveloperPaymentAddress`, or the blueprint owner if that hook is empty |
| Protocol treasury (the TNT protocol's share) | 20% (`DEFAULT_PROTOCOL_BPS = 2000`) | Pushed to the treasury in the settlement asset |
| Stakers/delegators | 20% (`DEFAULT_STAKER_BPS = 2000`) | Forwarded per operator through `ServiceFeeDistributor` in the settlement asset. If no operator has effective exposure, this share folds into the operator pool. If the distributor is unset or the forward fails, `StakerShareRefundedToEscrow` fires. |
| Keeper | 0% (`DEFAULT_KEEPER_BPS = 0`) | Not paid. `keeper` is `address(0)` on this path. |

Rounding dust stays on the staker share (`PaymentLib.calculateSplit`). The treasury is paid in the stablecoin. The split does not mint TNT and does not swap the stablecoin for TNT. `_tntPaymentDiscountBps` moves value only when the bill token is TNT, and only out of the protocol share. `InflationPool` is not credited by the payment.

### x402 settles outside PaymentSplit

This repository has no x402 facilitator and no external-settlement function. An agent that pays a stablecoin over x402 pays the resource server's payee. That transfer never calls `distributePayment`.

| Party | x402 / off-protocol stablecoin today |
|-------|--------------------------------------|
| Operators | The payee receives the gross. There is no exposure-weighted pool. |
| Blueprint developer | Nothing. |
| Stakers/delegators | Nothing. |
| TNT protocol treasury | Nothing. The payment does not reach the treasury, does not buy TNT, and does not fund `InflationPool`. |

### Future PaymentSplit path — acceptance

Not implemented. Precondition: the mainnet deployment recorded in `deploy/MAINNET-PARAMETERS.md` is complete. This document does not deploy mainnet and does not change live settlement.

After that precondition, one entry may take an already-settled stablecoin amount and call the existing `distributePayment` path. It must not define a new split or a new price.

**Inputs**

- `serviceId` of an Active service.
- `token`: the ERC-20 the agent paid. It must be that service's pinned asset (`getServicePaymentAsset`).
- `amount`: the settled gross, in `token`'s smallest unit. The protocol does not reprice it. The existing dust floor in `PaymentLib.collectPayment` still applies.
- `operators`: the service operator set, or the single quoted operator on an RFQ job. The same set `_distributeJobPayment` already passes.
- The live `paymentSplit()`. The defaults quoted above are developer 2000, protocol 2000, operator 4000, staker 2000, keeper 0.

**Outputs**

On the path where the developer and the treasury accept `token`, a distributor is set, and operators have effective exposure:

- `PaymentDistributed` carries that `token` and gross. Developer, protocol, operator-pool, and staker-pool amounts equal `PaymentLib.calculateSplit(amount, paymentSplit(), false)`. `includeKeeper` is false, so any keeper bps fold into the operator pool and the keeper amount is 0.
- Operator shares sit in `pendingRewards` for `token` until `claimRewards(token)`.
- The developer share and the protocol share are pushed in `token`. A failed push follows the existing `PushTransferFailed` rule and folds that amount into the operator pool. It does not leave the gross unsplit with the payee.
- The staker share is forwarded in `token` to `ServiceFeeDistributor`, or folded or refunded under the rules already in this file.
- The treasury's balance of `token` increases by the protocol share. TNT supply does not change. `InflationPool` does not change. `_tntPaymentDiscountBps` does not move a stablecoin.

**Proof**

- A local Foundry test, not a mainnet transaction. Settle one mock ERC-20 gross through the entry and assert `PaymentDistributed` matches `calculateSplit` of the live default split, operator `pendingRewards` sum to the operator pool, the treasury's token balance increases by the protocol share, the developer recipient increases by the developer share, and a configured distributor records the staker share for that token.
- If the entry is absent or the call reverts, the operator's token balance does not increase by the gross.
- This documentation does not change storage. An implementation that appends a field shrinks `__gap` in the same change and passes the existing storage-layout snapshot test.

### Protocol task list

Checked against this revision. Open items are not started. Their precondition is the mainnet deploy above.

- [x] Request-time EventDriven `paymentToken` is native-only. The job asset is the blueprint's (`setBlueprintSettlementAsset`), not the customer's.
- [x] On-chain EventDriven collection and distribution already pass `_serviceEventDrivenAsset` into `distributePayment`. A stablecoin job submitted on-chain already reaches operators, the developer, stakers, and the protocol treasury under the split above.
- [x] No x402 or external-settlement function in this repository calls `distributePayment`. x402 settles outside `PaymentSplit` and reaches only the payee.
- [x] The split to reuse is the live `PaymentSplit` in this file. No new basis points.
- [ ] After the mainnet deploy: add one entry that takes a settled stablecoin gross and calls the existing `distributePayment` path. No new split, no new rate, no TNT conversion, and no mainnet broadcast to add the entry.
- [ ] After the mainnet deploy: land the Foundry proof under **Proof** before any caller is pointed at the entry.
- [ ] After the mainnet deploy and after that proof is green: an x402 payee may be set to the entry. Until then the payee stays outside this contract. A failed forward must not count as a full payment to the operator.

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
