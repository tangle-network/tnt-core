# Pricing & Payment Integration Guide

How blueprint developers, operators, and dapp integrators configure pricing for services and jobs on Tangle.

This guide reflects the protocol's behavior as implemented in `src/core/Payments.sol`,
`src/libraries/PaymentLib.sol`, and `src/interfaces/IBlueprintServiceManager.sol`. Code
snippets are runnable against the current ABI; the v5-tuple `paymentSplit()` view and the
`computeBillAdjustmentBps` manager hook are required reading.

---

## Pricing Models

Every blueprint declares a `PricingModel` at registration via `BlueprintConfig`. The
choice is permanent — services spawned from the blueprint inherit it.

```solidity
enum PricingModel {
    PayOnce,       // 0 — Single upfront payment at service creation
    Subscription,  // 1 — Recurring, TWAP-fair, permissionlessly-billed escrow
    EventDriven    // 2 — Pay-per-job submission; no upfront permitted
}
```

### Which model to use

| Model | Use case | Payer | Settlement |
|-------|----------|-------|------------|
| `PayOnce` | Fixed-duration deliverables with predictable cost (deploy a validator for 30 days, run a one-off compute job) | Service requester | Lump sum distributed at activation |
| `Subscription` | Long-running services billed periodically (managed infra, hosted nodes, RPC) | Service owner funds escrow; anyone triggers bills | Per-interval draws against escrow |
| `EventDriven` | Usage-priced services where cost varies per call (AI inference, sandboxed compute) | Job submitter | Per-job `msg.value` at submission |

---

## PayOnce

### Blueprint config

```solidity
BlueprintConfig({
    pricing: PricingModel.PayOnce,
    subscriptionRate: 0,
    subscriptionInterval: 0,
    eventRate: 0
    // ...
})
```

### Flow

1. Operators publish off-chain `SignedQuote`s (EIP-712) with `totalCost` for the requested TTL.
2. User calls `createServiceFromQuotes(blueprintId, quotes, config, permittedCallers, ttl)` with `msg.value == Σ quotes[i].details.totalCost`.
3. Payment is distributed immediately via the shared `PaymentSplit` pipeline. No keeper rebate is paid (this isn't a permissionless bill).

The blueprint developer controls nothing about price — operators set their own via signed
quotes. The protocol enforces sum-equals-msg.value, signature validity, expiry, and
single-use replay protection.

---

## Subscription

Subscription pricing is the model that demands the most operational thought. It must:

- bill a customer fairly for the security they actually got each period;
- keep operators incentivized to do work, including the work of triggering bills;
- never let a stake-ramping operator overcharge; and
- not livelock when the operator set is temporarily empty.

The implementation does all four.

### Blueprint config

```solidity
BlueprintConfig({
    pricing: PricingModel.Subscription,
    subscriptionRate: 1 ether,         // Maximum nominal draw per interval (wei)
    subscriptionInterval: 30 days,     // Billing interval (seconds)
    eventRate: 0
    // ...
})
```

### Lifecycle

1. Service activates (request flow or `createServiceFromQuotes`). The protocol seeds
   per-operator TWAP cursors and **pins the baseline stake** in `ServiceEscrow.subscriptionBaselineStake`. Emits `SubscriptionBaselineInitialized(serviceId, baselineStake, operatorCount)`.
2. Service owner calls `fundService(serviceId, amount)` to top up escrow. Re-validated against the manager's `queryIsPaymentAssetAllowed` (a manager that revokes a token after activation blocks further top-ups in that token).
3. Anyone calls `billSubscription(serviceId)` once `block.timestamp >= lastPaymentAt + interval`. Each call processes **exactly one period** of length `interval`; missed periods catch up over repeated calls.
4. If escrow runs short for the grace window, anyone calls `terminateServiceForNonPayment(serviceId)`. After termination, the owner reclaims remaining escrow with `withdrawRemainingEscrow(serviceId)`.

### The bill formula (TWAP-fair, capped)

The protocol computes the bill from per-operator cum-stake-second deltas accrued over
the period, denominated by the activation baseline:

```
billRaw  = nominalRate * cumDeltaPeriod / (baselineStake * interval)
billCap  = min(billRaw, nominalRate)                          // never exceed nominal
billFinal = billCap * computeBillAdjustmentBps(...) / 10_000  // manager QoS discount
```

Implementation: `PaymentLib.twapBillAmount` (`src/libraries/PaymentLib.sol`).

Two structural properties make this safe for both sides of the market:

- **Customer-fair, upper bound.** `billCap` ensures an operator ramping stake mid-period CANNOT inflate the customer's bill above the nominal rate. The customer signed up for `subscriptionRate`; that's the worst case.
- **Customer-fair, lower bound.** If operators ramp stake DOWN during the period, `cumDeltaPeriod` falls and the bill falls with it. Reduced security earns the customer a proportional refund without any owner action.
- **Operator-fair payout.** Per-operator weights for the operator-pool split are `cumDelta_op × exposureBps_op` — the same TWAP cursors that drive `cumDeltaPeriod`. An operator who actually held more stake-time during the period earns a larger slice of the (capped) pool. Customer-fairness and operator-fairness are linked: an operator who ramped stake just before the bill raises both the bill input AND their share of it — neither side is gameable in isolation.

Arithmetic overflow on `nominalRate * cumDeltaPeriod` reverts with
`BillingArithmeticOverflow` rather than silently distributing nonsense — a misconfigured
upstream state must be fixed at its source.

### Empty operator set: no livelock

If the active-operator set is empty at bill time:

- `lastPaymentAt` advances by `interval` (cursor stays on rails).
- Escrow is **not** touched.
- `SubscriptionBillSkippedNoOperators(serviceId, period)` is emitted.
- The next call (if operators have rejoined) bills the standard rate against the fresh period.

This is a defense against operator-set churn causing repeated cursor-stalls.

### Baseline must be initialized

If a service somehow reaches its first bill without `subscriptionBaselineStake` set, the
bill reverts with `SubscriptionBaselineNotInitialized(serviceId)`. The canonical
activation paths (`_handleInitialPayments` in the request flow,
`createServiceFromQuotes` in the quote flow) both seed the baseline; this error fires
only if a non-canonical path is added in the future and forgets the seed.

### Dust bills don't brick services

If the bill (after TWAP scaling AND the manager QoS adjustment) is smaller than the
minimum amount that can be cleanly split N ways under the configured `PaymentSplit`, the
bill is treated as processed-at-zero-cost: the cursor advances, `SubscriptionBilled` is
emitted with `amount == 0`, and no escrow draw occurs. This stops a manager hook that
returns a small-but-nonzero `qosBps` from reverting deep in `_distributeBill` and
permanently stalling the service. The dust threshold is computed in
`PaymentLib.minBillAmount(split, operatorCount)`.

### Escrow accounting

`getServiceEscrow(serviceId)` returns:

```solidity
struct ServiceEscrow {
    address token;                       // Native (address(0)) or ERC-20
    uint256 balance;                     // Available to draw
    uint256 totalDeposited;              // Lifetime
    uint256 totalReleased;               // Lifetime
    uint256 __reserved0;                 // Always zero; reserved
    uint256 subscriptionBaselineStake;   // Pinned at activation; denominator in twapBillAmount
}
```

The invariant `totalDeposited >= totalReleased + balance` holds in all paths. The
staker-share refund path explicitly counter-releases (decrements `totalReleased`) when a
share lands back in escrow.

### Non-payment termination

Failing one bill does not terminate. Termination becomes permissionless after a
configurable grace window:

```
eligible_at = lastPaymentAt + interval + (interval * graceIntervals)
```

`graceIntervals` defaults to `0` if the blueprint manager returns `(true, _)` from
`getNonPaymentTerminationPolicy`. Managers can opt into longer grace by returning
`(false, N)`. Protocol caps the custom value for safety.

```solidity
contract MySubscriptionPolicy is BlueprintServiceManagerBase {
    /// @dev Three extra intervals of slack before anyone can terminate.
    function getNonPaymentTerminationPolicy(uint64)
        external pure override
        returns (bool useDefault, uint64 graceIntervals)
    {
        return (false, 3);
    }
}
```

Return `(true, 0)` for protocol default. Return `(false, 0)` to make termination
eligible immediately at the first underfunded due time.

### Public surface

```solidity
function fundService(uint64 serviceId, uint256 amount) external payable;
function billSubscription(uint64 serviceId) external;
function billSubscriptionBatch(uint64[] calldata serviceIds)
    external returns (uint256 totalBilled, uint256 billedCount);
function getBillableServices(uint64[] calldata serviceIds)
    external view returns (uint64[] memory billable);
function terminateServiceForNonPayment(uint64 serviceId) external;
function withdrawRemainingEscrow(uint64 serviceId) external;
```

`getBillableServices` mirrors `_isBillable` exactly: a service is reported as billable
only if it's active, subscription-priced, baseline-seeded, past its TTL guard, past its
interval, AND its escrow can cover at least `subscriptionRate` (because the cap-at-nominal
guarantee means a successful bill never exceeds `subscriptionRate`).

### Subscription bill flow

```
billSubscription(serviceId)  [caller = keeper]
    │
    ├─ eligibility checks (active, subscription, not TTL-expired, period due)
    │
    ├─ active operators?
    │     no  → emit SubscriptionBillSkippedNoOperators
    │            advance cursor, return
    │
    ├─ accrue per-op cumDelta × exposureBps weights
    │
    ├─ require subscriptionBaselineStake != 0
    │     no  → revert SubscriptionBaselineNotInitialized
    │
    ├─ amount = twapBillAmount(nominalRate, cumDelta, baseline, interval)
    │     amount = min(amount, nominalRate)            // never inflate
    │
    ├─ qosBps = computeBillAdjustmentBps(...) (gas-capped staticcall)
    │     amount *= qosBps / 10_000                    // discount only
    │     emit SubscriptionBillAdjustedByManager(...)
    │
    ├─ dust check: amount < minBillAmount(split, N)?
    │     yes → emit SubscriptionBilled(amount=0), advance cursor, return
    │
    ├─ balance < amount?
    │     yes → revert / return false (cursor unchanged)
    │            (non-payment termination is the recovery path)
    │
    ├─ release amount from escrow
    │
    └─ _distributeBill:
          ├─ developer  → developerBps   (manager hook overrides recipient)
          ├─ protocol   → protocolBps    (TNT discount may carve into this)
          ├─ keeper     → keeperBps      (pending-rewards accrual)
          ├─ operators  → operatorBps    (split by weights)
          └─ stakers    → stakerBps      (per-op via ServiceFeeDistributor,
                                           refund-to-escrow on failure)
```

---

## EventDriven

The most flexible model. Each job submission pays on the spot.

### Blueprint config

```solidity
BlueprintConfig({
    pricing: PricingModel.EventDriven,
    eventRate: 0.001 ether,    // Fallback per-job rate
    subscriptionRate: 0,
    subscriptionInterval: 0
    // ...
})
```

### No upfront payment at request

EventDriven services are funded **only** by per-job `msg.value`. The request flow
rejects any non-zero `paymentAmount`:

```solidity
if (pricing == Types.PricingModel.EventDriven) {
    if (paymentAmount != 0) revert Errors.UpfrontPaymentNotAllowedForEventDriven();
    if (paymentToken != address(0)) revert Errors.InvalidPaymentToken();
}
```

Source: `src/core/ServicesRequests.sol` — `_validatePricingPaymentConsistency`. The
goal is to fail loudly at request time rather than collect funds that later have
nowhere to go.

### Settlement asset

EventDriven payments are **native-token only** today. Request-time `paymentToken` must
be `address(0)`; `submitJob` / `submitJobFromQuote` collect via `msg.value`.

### Rate resolution

When a job is submitted, the protocol resolves the price as:

```
per-job override (_jobEventRates[blueprintId][jobIndex])
    └─ if 0 → fallback to BlueprintConfig.eventRate
```

```solidity
function _collectJobPaymentIfNeeded(...) private returns (uint256 payment) {
    if (svc.pricing == Types.PricingModel.EventDriven) {
        uint256 perJob = _jobEventRates[svc.blueprintId][jobIndex];
        payment = perJob > 0 ? perJob : _blueprintConfigs[svc.blueprintId].eventRate;
        PaymentLib.collectPayment(address(0), payment, msgValue);
        _recordPayment(payer, serviceId, address(0), payment);
    }
}
```

### Per-job overrides

```solidity
function setJobEventRates(
    uint64 blueprintId,
    uint8[] calldata jobIndexes,   // < job schema count
    uint256[] calldata rates       // Set to 0 to clear an override
) external;

function getJobEventRate(uint64 blueprintId, uint8 jobIndex)
    external view returns (uint256);
```

Each override emits `JobEventRateSet(blueprintId, jobIndex, rate)`.

### Example: tiered AI sandbox

```solidity
function getDefaultJobRates(uint256 baseRate)
    external pure returns (uint8[] memory, uint256[] memory)
{
    uint8[] memory jobs   = new uint8[](3);
    uint256[] memory rates = new uint256[](3);

    jobs[0] = 5;  rates[0] = baseRate;        // 1x — EXEC
    jobs[1] = 6;  rates[1] = 20 * baseRate;   // 20x — single LLM call
    jobs[2] = 7;  rates[2] = 250 * baseRate;  // 250x — multi-turn agent

    return (jobs, rates);
}
```

Blueprint owners apply the overrides post-deployment with
`tangle.setJobEventRates(blueprintId, jobIndexes, rates)`.

### EventDriven flow

```
submitJob(serviceId, jobIndex, inputs)  [msg.value == effective rate]
    │
    ├─ resolve rate: per-job override → BlueprintConfig.eventRate
    ├─ collect payment (native; reject mismatched msg.value)
    └─ record payment

submitResult / submitAggregatedResult
    │
    └─ on completion → _distributePaymentWithEffectiveExposure
          (no keeper rebate; weights = effective exposure)
```

---

## Job RFQ

For jobs whose price is negotiated per request. The buyer requests a quote from
specific operators, who sign EIP-712, and the buyer submits the job with the signed
quote(s).

### When to use RFQ vs fixed rates

| Mode | Mechanism |
|------|-----------|
| Standardized ops with predictable cost | Fixed per-job rates (`setJobEventRates`) |
| Variable cost (model choice, resource sizing, volume discounts) | Job RFQ (`submitJobFromQuote`) |

### EIP-712 types

```solidity
struct JobQuoteDetails {
    address requester;       // Caller authorized to redeem (defeats front-running)
    uint64 serviceId;
    uint8 jobIndex;
    uint256 price;
    uint64 timestamp;
    uint64 expiry;
    uint8 confidentiality;   // 0=Any, 1=Required, 2=Preferred
}

struct SignedJobQuote {
    JobQuoteDetails details;
    bytes signature;
    address operator;
}
```

Domain: `EIP712Domain(string name, string version, uint256 chainId, address verifyingContract)` with `name="TangleQuote"`, `version="1"`.

### Submission

```solidity
function submitJobFromQuote(
    uint64 serviceId,
    uint8 jobIndex,
    bytes calldata inputs,
    SignedJobQuote[] calldata quotes
) external payable returns (uint64 callId);
```

- `msg.value == Σ quotes[i].details.price`.
- Each quote's `(serviceId, jobIndex, requester)` must match the call.
- Each operator must be active in the service.
- Quotes expire on `expiry` and against `maxQuoteAge` (default 1 hour).
- Each quote digest is single-use (`_usedQuotes[digest]`).

### Result enforcement

Only operators quoted on the call may submit results:

```solidity
if (job.isRFQ && !_jobQuotedOperators[serviceId][callId].contains(msg.sender)) {
    revert Errors.NotQuotedOperator(serviceId, callId);
}
```

### Payment distribution for RFQ jobs

Each quoted operator's gross share is their **individually quoted price** (not a pro-rata
split of the total). The standard `PaymentSplit` (developer / protocol / operator pool /
staker pool) still applies to each operator's slice; weights inside the operator pool
are exposure-based.

### View functions

```solidity
function getJobQuotedOperators(uint64 serviceId, uint64 callId)
    external view returns (address[] memory);

function getJobQuotedPrice(uint64 serviceId, uint64 callId, address operator)
    external view returns (uint256);
```

### Operator-side implementation

The on-chain contract verifies quotes; operators need off-chain software to generate and
sign them. The Tangle blueprint SDK provides this.

**Signer — `blueprint-tangle-extra`:**

```rust
use blueprint_tangle_extra::job_quote::{JobQuoteSigner, JobQuoteDetails, QuoteSigningDomain};

let domain = QuoteSigningDomain {
    chain_id: 1,
    verifying_contract: tangle_proxy_address,
};
let signer = JobQuoteSigner::new(operator_keypair, domain);

let details = JobQuoteDetails {
    requester: buyer_address,
    service_id: 42,
    job_index: 7,
    price: U256::from(250_000_000_000_000u64), // 0.00025 ETH
    timestamp: now,
    expiry: now + 3600,
    confidentiality: 0,
};

let signed = signer.sign(&details);   // ready to submit on-chain
```

**Quote-serving — `blueprint-pricing-engine`:**

```proto
service PricingEngine {
  rpc GetPrice    (GetPriceRequest)    returns (GetPriceResponse);
  rpc GetJobPrice (GetJobPriceRequest) returns (GetJobPriceResponse);
}
```

Operators configure per-job prices in a `(service_id, job_index) → price` map. Buyers
hit the gRPC endpoint, receive a signed quote, and submit it on-chain.

See [`tangle-network/blueprint` `crates/pricing-engine`](https://github.com/tangle-network/blueprint/tree/main/crates/pricing-engine)
for benchmarking, caching, and transport.

---

## Service-Level RFQ (createServiceFromQuotes)

Distinct from Job RFQ. This creates an entire `PayOnce` service from operator quotes:

```solidity
function createServiceFromQuotes(
    uint64 blueprintId,
    SignedQuote[] calldata quotes,
    bytes calldata config,
    address[] calldata permittedCallers,
    uint64 ttl
) external payable returns (uint64 serviceId);
```

Each operator signs `QuoteDetails` containing `totalCost`, `requester`, `blueprintId`,
`ttlBlocks`, `securityCommitments`, and `resourceCommitments`. The buyer pays
`Σ quote.totalCost`. Payment is distributed at activation through the standard
`PaymentSplit`.

When a quote-flow service is `Subscription`-priced, the protocol also seeds the
TWAP baseline immediately after activation.

---

## Payment Distribution

All payment paths (PayOnce, Subscription, EventDriven) converge on the same
`_distributeBill` core in `src/core/Payments.sol`. The differences live in **weights**
and **whether a keeper is paid**.

### PaymentSplit (5-tuple)

Admin-configurable, must sum to exactly 10_000.

```solidity
struct PaymentSplit {
    uint16 developerBps;   // Blueprint owner (or manager-overridden recipient)
    uint16 protocolBps;    // Treasury
    uint16 operatorBps;    // Operator pool (weighted by stake-time × exposure)
    uint16 stakerBps;      // Staker pool (routed through ServiceFeeDistributor)
    uint16 keeperBps;      // Permissionless-bill caller; zero on non-keeper paths
}
```

Defaults (`src/TangleStorage.sol`):

| Share | Default | Constant |
|-------|---------|----------|
| developer | 20% | `DEFAULT_DEVELOPER_BPS = 2000` |
| protocol | 20% | `DEFAULT_PROTOCOL_BPS = 2000` |
| operator | 40% | `DEFAULT_OPERATOR_BPS = 4000` |
| staker | 20% | `DEFAULT_STAKER_BPS = 2000` |
| keeper | 0% | `DEFAULT_KEEPER_BPS = 0` |

Admins set the live split via:

```solidity
function setPaymentSplit(Types.PaymentSplit calldata split) external; // ADMIN_ROLE
```

`PaymentLib.validateSplit` enforces the 10_000 sum across all five fields.

Read the live split with the 5-tuple view:

```solidity
function paymentSplit() external view returns (
    uint16 developerBps,
    uint16 protocolBps,
    uint16 operatorBps,
    uint16 stakerBps,
    uint16 keeperBps
);
```

### Distribution flow

```
gross amount (post-TWAP, post-QoS for subscription bills)
├── developerBps  → developer recipient (manager hook, gas-capped)
├── protocolBps   → treasury  (TNT discount may carve into this share)
├── operatorBps   → operator pool  (split by per-op weights)
├── stakerBps     → staker pool   (per-op forwarding to ServiceFeeDistributor;
│                                  refund to escrow on failure)
└── keeperBps     → bill caller   (only when includeKeeper == true; otherwise
                                   folded into operator pool)
```

`PaymentLib.calculateSplit` floor-divides the developer/protocol/operator/keeper
amounts; any rounding dust accumulates on the staker share so `Σ shares == amount`
exactly.

### Operator weighting

Per-operator weights differ by path:

| Path | Weight per operator |
|------|--------------------|
| Subscription bill | `cumDelta_op × exposureBps_op` (TWAP — same cursors that drive bill amount) |
| PayOnce / EventDriven / Job RFQ | `effectiveExposure_op` (delegation × `exposureBps`); fallback to flat `1` when no stake exists |

In both paths, rounding dust accumulates on the LAST operator's share to keep
`Σ operator_shares == operator_pool` exactly.

When `hasSecurityCommitments == false` (no real delegated stake backs operators), the
staker share is folded into the operator pool. Compute providers always get paid.

### Developer payment address

`queryDeveloperPaymentAddress(serviceId)` is called via a gas-capped staticcall
(`MANAGER_HOOK_GAS_LIMIT = 500_000`). A revert, an empty return, or `address(0)` falls
back to the blueprint owner. This bound exists for the same reason the QoS hook is
bounded: a malicious manager must not be able to brick payment by grinding gas.

### Staker share routing

The per-operator staker slice is forwarded to the configured `ServiceFeeDistributor`.
If no distributor is set, or the distributor reverts on a native-token transfer, the
slice is **refunded to the service escrow** (with a counter-release of `totalReleased`),
and `StakerShareRefundedToEscrow(serviceId, operator, token, amount, reason)` is
emitted. Customers recover funds for unrouted operator shares; a misbehaving
distributor cannot brick all subscription bills.

For ERC-20s, tokens are sent to the distributor first; if the post-transfer call
reverts, the tokens are already out of the contract — the event still fires so the
protocol can recover off-chain.

### TNT payment discount

If the settlement token is TNT and `_tntPaymentDiscountBps > 0`, the protocol carves a
discount out of the protocol share and forwards it to the service owner. Discount is
clamped to the available protocol amount; never overdraws. Event:
`TntPaymentDiscountApplied(serviceId, recipient, token, amount)`.

### Pull-pattern rewards

Operator, keeper, and (failed-distributor) shares are accrued to a per-account /
per-token mapping. Recipients claim with:

```solidity
function claimRewards() external;                          // Native
function claimRewards(address token) external;             // Specific token
function claimRewardsBatch(address[] calldata tokens) external;
function claimRewardsAll() external;                       // All tracked tokens

function pendingRewards(address account) external view returns (uint256);   // Native
function pendingRewards(address account, address token) external view returns (uint256);
function rewardTokens(address account) external view returns (address[] memory);
```

Pull-pattern is mandatory: a contract recipient that reverts on `receive()` must not be
able to brick the distribution path. The reward is parked; the recipient claims when
they're ready.

---

## Manager QoS Hook (computeBillAdjustmentBps)

This is the single most powerful customization for subscription blueprints. Implement
it to scale the per-period bill by quality-of-service evidence: uptime, missed
heartbeats, missed results, SLA percentile, anything the manager observes.

### Interface

```solidity
function computeBillAdjustmentBps(
    uint64 serviceId,
    uint64 periodStart,   // Inclusive (== prior lastPaymentAt)
    uint64 periodEnd      // Exclusive (== lastPaymentAt + interval)
) external view returns (uint16 adjustmentBps);
```

### Semantics

- Returns basis points: `10_000` = full bill, `0` = bill waived. Values above `10_000`
  are clamped — **a manager cannot inflate the customer's bill**.
- Called via gas-capped staticcall (`MANAGER_HOOK_GAS_LIMIT = 500_000`). Reverts,
  out-of-gas, or malformed returns yield a full bill (`10_000` bps) and the bill
  proceeds — no permissionless caller can be griefed.
- Called BEFORE escrow draw, so a discount actually reduces what's deducted.
- When `adjustmentBps < 10_000`, the protocol emits
  `SubscriptionBillAdjustedByManager(serviceId, preAdjustmentAmount, adjustedAmount, adjustmentBps)`
  where `preAdjustmentAmount` is the TWAP-and-cap-resolved amount (not the nominal
  rate).

`BlueprintServiceManagerBase` ships a default that returns `10_000` (no discount). You
only override when you actually want SLA-coupled pricing.

### Worked example: uptime-based discount

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BlueprintServiceManagerBase } from "tnt-core/src/BlueprintServiceManagerBase.sol";

/// @notice Bill adjustment driven by per-period uptime sampling.
/// @dev Off-chain heartbeats are recorded into `uptimeBpsByPeriod` by an oracle
///      role (omitted from this snippet for brevity). The bill is then a linear
///      function of uptime, with a floor so a brief outage doesn't zero the bill.
contract UptimeBilledBlueprint is BlueprintServiceManagerBase {
    /// serviceId => periodStart => uptime in bps over [periodStart, periodStart + interval)
    mapping(uint64 => mapping(uint64 => uint16)) public uptimeBpsByPeriod;
    /// Customer never pays less than this fraction of the bill, even on extended outage.
    uint16 public constant FLOOR_BPS = 2_500; // 25%

    function recordPeriodUptime(uint64 serviceId, uint64 periodStart, uint16 uptimeBps)
        external onlyTrustedOracle
    {
        require(uptimeBps <= 10_000, "uptime out of range");
        uptimeBpsByPeriod[serviceId][periodStart] = uptimeBps;
    }

    function computeBillAdjustmentBps(
        uint64 serviceId,
        uint64 periodStart,
        uint64 /*periodEnd*/
    ) external view override returns (uint16) {
        uint16 uptime = uptimeBpsByPeriod[serviceId][periodStart];
        if (uptime == 0) return 10_000; // No sample → full bill (fail-safe for customer)
        if (uptime < FLOOR_BPS) return FLOOR_BPS;
        return uptime;
    }

    // onlyTrustedOracle modifier intentionally elided.
}
```

The protocol guarantees:

- The customer cannot be over-billed by a buggy oracle (return > 10_000 is clamped).
- A reverting `recordPeriodUptime` can still leave the lookup returning zero — the
  override above intentionally treats zero as "no sample, charge full" so the customer
  isn't accidentally given a 100% discount.
- A reverting `computeBillAdjustmentBps` call (gas, OOG, malformed return) is treated
  as full bill, so the bill still proceeds.

Tradeoffs the blueprint author chooses:

- **Whether zero means full-bill or full-discount** (the example chooses full-bill;
  inverting is a one-line change and a very different incentive).
- **Whether to compute uptime on-chain or pull it from an oracle** (the example pulls).
- **Whether to apply a floor** (the example does, to protect operators from a single
  bad day).

---

## Keeper Rebate

Subscription bills are permissionless. Anyone can call `billSubscription` or
`billSubscriptionBatch`. To make that incentive-compatible — so bots actually trigger
bills on time instead of waiting for someone else to pay gas — the protocol pays the
caller a share of every bill they successfully drive.

### How it accrues

When `keeperBps > 0` AND the bill is non-zero AND the bill clears the dust threshold,
`_distributeBill` allocates `keeperBps / 10_000` of the gross bill to the caller via
the same pending-rewards mapping used for operators:

```
addPendingReward(_pendingRewards, keeper, token, keeperAmount);
emit KeeperRebateAccrued(serviceId, keeper, token, amount);
```

The caller is `msg.sender` of the public bill entry point. For
`billSubscriptionBatch`, the same caller earns the rebate on every successful service
in the batch (so a single bot sweeping the schedule earns one transaction's worth of
gas and N services' worth of rebate).

### How to claim

```solidity
tangle.claimRewards();                     // Native rebates
tangle.claimRewards(usdcAddress);          // ERC-20 rebates for a specific token
tangle.claimRewardsBatch([weth, usdc]);    // Multiple tokens at once
tangle.claimRewardsAll();                  // All tracked tokens
```

Pull pattern: a bot's gas-budget for the bill call is bounded, and a contract-keeper
can't be force-fed ETH that would revert its `receive`.

### When admins should enable it

Default is `DEFAULT_KEEPER_BPS = 0`. Admins should enable it when:

- **Subscription services live for long periods.** The cost of one missed bill is the
  cost of running the operator without revenue for a full interval.
- **The protocol can't rely on operators triggering their own bills.** Operators
  earn the operator share regardless of who calls `billSubscription` — a keeper rebate
  is what pays a *non-operator* to keep the schedule moving.
- **The bill is large enough that a small % is meaningful gas-reimbursement.** A
  50-100 bps slice typically pays for the call gas on rollups and leaves margin for
  the keeper bot.

### Carving keeper bps from other buckets

The 10_000 sum constraint means `setPaymentSplit` reallocates rather than mints. A
50 bps keeper share has to come from somewhere — typically a 50 bps cut to the
protocol or developer share, depending on which party is funding the keeper subsidy.

```solidity
// Example: 50 bps to keeper, carved from protocol share.
tangle.setPaymentSplit(Types.PaymentSplit({
    developerBps: 2000,
    protocolBps:  1950,   // was 2000
    operatorBps:  4000,
    stakerBps:    2000,
    keeperBps:      50    // was 0
}));
```

`PaymentLib.validateSplit` reverts with `InvalidPaymentSplit` if the five fields don't
sum to exactly 10_000.

### Non-keeper paths

PayOnce, EventDriven per-job, RFQ — none of these are permissionless bills. They run
through `_distributePaymentWithEffectiveExposure` with `keeper = address(0)`, which
folds the `keeperBps` allocation into the operator pool. So the configured
`keeperBps` only diverts revenue from the operator pool on the permissionless-bill
path; on non-keeper paths, the operator pool effectively receives `operatorBps +
keeperBps`.

---

## Events Reference

Emitted from `src/core/Payments.sol`:

| Event | When |
|-------|------|
| `EscrowFunded(serviceId, token, amount)` | `fundService` deposit |
| `EscrowRefunded(serviceId, owner, token, amount)` | `withdrawRemainingEscrow` after termination |
| `SubscriptionBilled(serviceId, amount, period)` | Any subscription bill processed (`amount == 0` for zero-rate / dust-skip / no-operator periods) |
| `SubscriptionBillSkippedNoOperators(serviceId, period)` | Zero active operators at bill time; cursor advanced, escrow untouched |
| `SubscriptionBillAdjustedByManager(serviceId, preAdjustmentAmount, adjustedAmount, adjustmentBps)` | Manager QoS hook reduced the bill |
| `SubscriptionBaselineInitialized(serviceId, baselineStake, operatorCount)` | TWAP cursors + baseline pinned at activation |
| `KeeperRebateAccrued(serviceId, keeper, token, amount)` | Bill caller's rebate added to pending rewards |
| `StakerShareRefundedToEscrow(serviceId, operator, token, amount, reason)` | Staker forwarding failed; share returned to escrow (or surfaced for already-transferred ERC20) |
| `PaymentDistributed(serviceId, blueprintId, token, grossAmount, developerRecipient, developerAmount, protocolAmount, operatorPoolAmount, stakerPoolAmount)` | Every distribution (subscription, PayOnce, RFQ, per-job) |
| `OperatorRewardAccrued(serviceId, operator, token, blueprintId, amount)` | Operator's slice of the operator pool added to pending rewards |
| `RewardsClaimed(account, token, amount)` | Any `claimRewards*` path that pays out non-zero |
| `TntPaymentDiscountApplied(serviceId, recipient, token, amount)` | TNT payment-discount carved from protocol share to service owner |
| `PaymentSplitUpdated(developerBps, protocolBps, operatorBps, stakerBps, keeperBps)` | Admin updates the live split |

---

## Errors Reference

Errors in `src/libraries/Errors.sol` that are pricing-specific or commonly hit:

| Error | Cause |
|-------|-------|
| `BillingArithmeticOverflow()` | `nominalRate * cumDeltaPeriod` overflowed — fix upstream state (stake / rate sanity) |
| `SubscriptionBaselineNotInitialized(uint64 serviceId)` | First bill against a service activated via a non-canonical path that skipped baseline seeding |
| `UpfrontPaymentNotAllowedForEventDriven()` | Request flow attempted to send non-zero `paymentAmount` for an EventDriven blueprint |
| `InvalidPaymentToken()` | Mixed-token escrow (deposit token differs from prior deposit) or EventDriven with non-native `paymentToken` |
| `TokenNotAllowed(address token)` | Manager's `queryIsPaymentAssetAllowed` rejected the chosen settlement token |
| `InsufficientEscrowBalance(uint256 required, uint256 available)` | Subscription bill demanded more than escrow held |
| `InvalidPaymentSplit()` | `setPaymentSplit` arguments don't sum to exactly 10_000 |
| `InvalidMsgValue(uint256 expected, uint256 sent)` | Native payment with mismatched `msg.value`, or ERC-20 payment with non-zero `msg.value` |
| `FeeOnTransferTokenRejected(address token)` | ERC-20 ingress credited less than transferred (fee-on-transfer / rebasing — refused at the door) |
| `PaymentTooSmall(uint256 amount, uint256 minimum)` | Dust payment below `PaymentLib.MINIMUM_PAYMENT_AMOUNT` rejected |
| `PaymentFailed()` | Native-token call to recipient returned `false` |
| `NotQuotedOperator(uint64 serviceId, uint64 callId)` | Result submission for an RFQ job from an operator not in the quote set |

---

## Storage Layout (Pricing-Related)

From `src/TangleStorage.sol`:

| Slot / mapping | Purpose |
|----------------|---------|
| `_blueprintConfigs[blueprintId]` | `BlueprintConfig` (`eventRate`, `subscriptionRate`, `subscriptionInterval`) |
| `_jobEventRates[blueprintId][jobIndex]` | Per-job rate overrides (0 → fall back to `eventRate`) |
| `_serviceEscrows[serviceId]` | `ServiceEscrow` (`token`, `balance`, `totalDeposited`, `totalReleased`, `subscriptionBaselineStake`) |
| `_twapCursorByOp[serviceId][operator]` | Per-operator TWAP cursor (cum stake-seconds at last bill / activation) |
| `_paymentSplit` | Global five-field `PaymentSplit` |
| `_pendingRewards[account][token]` | Pull-pattern accrual mapping for operators, keepers, claimers |
| `_pendingRewardTokens[account]` | Enumerable set of tokens with non-zero pending rewards |
| `_serviceFeeDistributor` | Address forwarded the staker pool's per-operator shares |
| `_tntPaymentDiscountBps` | TNT-settled discount, funded from protocol share |
| `_jobQuotedOperators[serviceId][callId]` | RFQ operators authorized to submit results |
| `_jobQuotedPrices[serviceId][callId][operator]` | Operator's quoted price for an RFQ call |
| `_usedQuotes[digest]` | Quote replay protection |

---

## What's Protocol vs Custom

| Capability | Protocol-native | Requires custom manager |
|------------|----------------|-------------------------|
| Three pricing models | Yes | No |
| Per-job event rate overrides | Yes (`setJobEventRates`) | No |
| Rate fallback to `BlueprintConfig.eventRate` | Yes | No |
| Job RFQ with EIP-712 signed quotes | Yes (`submitJobFromQuote`) | No |
| Service-level RFQ | Yes (`createServiceFromQuotes`) | No |
| TWAP-fair subscription billing with cap-at-nominal | Yes | No |
| Empty-operator-set livelock prevention | Yes | No |
| Five-bucket payment split (dev / protocol / operator / staker / keeper) | Yes | No |
| Permissionless bill triggers + keeper rebates | Yes (admin enables via `keeperBps`) | No |
| Subscription escrow with per-service tokens | Yes | No |
| Quote replay protection | Yes | No |
| QoS-coupled subscription discounts | Hook only | `computeBillAdjustmentBps` |
| Custom developer payment address per service | Hook only | `queryDeveloperPaymentAddress` |
| Restricting payment assets | Hook only | `queryIsPaymentAssetAllowed` |
| Required result count for jobs | Hook only | `getRequiredResultCount` |
| Non-payment termination grace | Hook only | `getNonPaymentTerminationPolicy` |
| Multiplier-based job rate tables | No | Define in manager + apply via `setJobEventRates` |
| Dynamic per-call pricing | No | Job RFQ |
| Metered / per-second billing | No | Off-chain settlement or manager hook coupled to QoS bps |
| ERC-20 settlement for EventDriven jobs | Not yet | PayOnce / Subscription support ERC-20; EventDriven is native-only today |

---

## Integration Checklist

### Blueprint developer (on-chain)

1. Choose `PricingModel` at registration. It cannot be changed.
2. Set `subscriptionRate` and `subscriptionInterval` for `Subscription`; set `eventRate` for `EventDriven`.
3. After registration, call `setJobEventRates` to override rates for specific jobs.
4. Optionally implement `queryDeveloperPaymentAddress` to route the developer share.
5. Optionally implement `queryIsPaymentAssetAllowed` to gate settlement tokens.
6. Optionally implement `computeBillAdjustmentBps` for SLA-coupled subscription pricing.
7. Optionally implement `getNonPaymentTerminationPolicy` for custom subscription grace.
8. Optionally implement `getRequiredResultCount` for multi-operator consensus thresholds.

### Blueprint developer (off-chain)

9. For RFQ blueprints: integrate `JobQuoteSigner` from `blueprint-tangle-extra` for EIP-712 signing.
10. For RFQ blueprints: embed `blueprint-pricing-engine` or implement an equivalent gRPC endpoint.
11. Define operator-configurable pricing parameters (resource rates, model costs, margins).
12. For `Subscription`: run `SubscriptionBillingKeeper` from `blueprint-tangle-extra` to auto-trigger bills (claims keeper rebates if `keeperBps > 0`).

### Operator

1. Fixed-rate blueprints need no per-operator pricing config — rates are set by the blueprint owner.
2. RFQ blueprints: configure per-job prices in operator config (e.g., `operator.toml`); the blueprint binary signs and serves quotes automatically.
3. For `Subscription` services: billing happens automatically if the blueprint runs `SubscriptionBillingKeeper`, or call `billSubscription`/`billSubscriptionBatch` manually.
4. Call `claimRewards` / `claimRewardsAll` to withdraw accrued earnings.

### Service consumer

1. `EventDriven` (fixed): `submitJob` with `msg.value == getJobEventRate(blueprintId, jobIndex)`.
2. `EventDriven` (RFQ): obtain signed `JobQuoteDetails` (with `requester == self`) from each operator, then `submitJobFromQuote` with `msg.value == Σ price`.
3. `Subscription`: call `fundService` to keep escrow funded; monitor `SubscriptionBillAdjustedByManager` and `EscrowFunded` for off-chain accounting; call `withdrawRemainingEscrow` after termination.
4. `PayOnce`: pay at service creation via `createServiceFromQuotes` with `msg.value == Σ quote.totalCost`.

### Admin

1. Default split is `2000 / 2000 / 4000 / 2000 / 0`. To enable permissionless bills with rebates, carve `keeperBps` from another bucket via `setPaymentSplit`.
2. Configure `_serviceFeeDistributor` before the staker share matters; unconfigured means staker shares refund into the service escrow.
3. Configure `_treasury` early — it receives the protocol share.
4. `_tntPaymentDiscountBps` is opt-in; zero by default.
