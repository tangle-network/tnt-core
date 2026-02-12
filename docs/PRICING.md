# Pricing & Payment Integration Guide

How blueprint developers and operators configure pricing for services and jobs on Tangle.

---

## Pricing Models

Every blueprint declares a `PricingModel` at registration time via `BlueprintConfig`. This cannot be changed after registration.

```solidity
enum PricingModel {
    PayOnce,       // 0 — Single upfront payment at service creation
    Subscription,  // 1 — Recurring interval-based billing from escrow
    EventDriven    // 2 — Pay-per-job submission
}
```

### Which model to use

| Model | When to use | Who pays | When they pay |
|-------|-------------|----------|---------------|
| `PayOnce` | Fixed-duration services with predictable cost (e.g., deploy a validator for 30 days) | Service requester | At `createServiceFromQuotes()` |
| `Subscription` | Long-running services billed periodically (e.g., monthly infra hosting) | Service owner (funds escrow) | Each interval via `billSubscription()` |
| `EventDriven` | Usage-based services where cost varies by job type (e.g., AI sandbox, compute marketplace) | Job submitter | At each `submitJob()` or `submitJobFromQuote()` |

---

## PayOnce

### Blueprint config

```solidity
BlueprintConfig({
    pricing: PricingModel.PayOnce,
    // These fields are unused for PayOnce but must be set:
    subscriptionRate: 0,
    subscriptionInterval: 0,
    eventRate: 0,
    // ...
})
```

### Flow

1. Operators publish off-chain `SignedQuote`s (EIP-712) with their `totalCost` for the requested TTL
2. User calls `createServiceFromQuotes(blueprintId, quotes, config, permittedCallers, ttl)` with `msg.value >= sum(quote.totalCost)`
3. Payment is distributed immediately via `PaymentSplit`

### What the developer controls

Nothing beyond the pricing model. Operators set their own prices via quotes.

---

## Subscription

### Blueprint config

```solidity
BlueprintConfig({
    pricing: PricingModel.Subscription,
    subscriptionRate: 1 ether,         // Amount billed per interval
    subscriptionInterval: 30 days,     // Billing interval in seconds
    eventRate: 0,                      // Unused
    // ...
})
```

### Flow

1. Service is created (via request/approve or quotes)
2. Service owner calls `fundService(serviceId, amount)` to deposit into escrow
3. Anyone calls `billSubscription(serviceId)` after each interval elapses
4. Protocol deducts `subscriptionRate` from escrow and distributes via `PaymentSplit`
5. If escrow is insufficient, billing reverts — service stays active but unpaid

### Key functions

```solidity
// Fund the escrow (service owner)
function fundService(uint64 serviceId, uint256 amount) external payable;

// Trigger billing (anyone — operators are naturally incentivized)
function billSubscription(uint64 serviceId) external;

// Batch billing
function billSubscriptionBatch(uint64[] calldata serviceIds) external returns (uint256 totalBilled, uint256 billedCount);

// Check what's billable (view)
function getBillableServices(uint64[] calldata serviceIds) external view returns (uint64[] memory billable);
```

### Escrow details

- Token is set at service creation (native or ERC-20)
- `getServiceEscrow(serviceId)` returns `{ token, balance, totalDeposited, totalReleased }`
- No auto-termination on empty escrow — billing simply fails until refunded

---

## EventDriven

The most flexible model. Each job submission pays on the spot.

### Blueprint config

```solidity
BlueprintConfig({
    pricing: PricingModel.EventDriven,
    eventRate: 0.001 ether,  // Default rate for all jobs (fallback)
    subscriptionRate: 0,     // Unused
    subscriptionInterval: 0, // Unused
    // ...
})
```

### Rate resolution

When a job is submitted, the protocol resolves the price in this order:

```
per-job override (_jobEventRates[blueprintId][jobIndex])
    └─ if 0 → fallback to BlueprintConfig.eventRate
```

Source: `JobsSubmission.sol:146-162`

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

### Per-job rate overrides

Blueprint owners set per-job rates after registration:

```solidity
// Set rates for specific job indexes (blueprint owner only)
function setJobEventRates(
    uint64 blueprintId,
    uint8[] calldata jobIndexes,  // Must be valid job indexes (< job schema count)
    uint256[] calldata rates       // Rate in wei. Set to 0 to clear override (revert to eventRate)
) external;

// Read the effective rate (returns override or fallback)
function getJobEventRate(uint64 blueprintId, uint8 jobIndex) external view returns (uint256 rate);
```

Events emitted: `JobEventRateSet(blueprintId, jobIndex, rate)` for each override.

### Example: AI sandbox with 17 job types

```solidity
// In your BSM contract, define multipliers
function getDefaultJobRates(uint256 baseRate) external pure returns (uint8[] memory, uint256[] memory) {
    uint8[] memory jobs = new uint8[](17);
    uint256[] memory rates = new uint256[](17);

    // Tier 1 (1x) — trivial ops
    jobs[0] = 5;  rates[0] = baseRate;       // EXEC
    jobs[1] = 1;  rates[1] = baseRate;       // STOP
    jobs[2] = 2;  rates[2] = baseRate;       // RESUME
    // ...
    // Tier 4 (20x) — single LLM call
    jobs[6] = 6;  rates[6] = 20 * baseRate;  // PROMPT
    // Tier 7 (250x) — multi-turn agent
    jobs[7] = 7;  rates[7] = 250 * baseRate; // TASK

    return (jobs, rates);
}
```

Then post-deployment:

```bash
# Set all rates in one transaction
forge script ConfigureJobRates.s.sol:ConfigureJobRates \
  --rpc-url $RPC_URL --broadcast
```

The script calls `tangle.setJobEventRates(blueprintId, jobIndexes, rates)`.

---

## Job RFQ (Request For Quote)

For jobs where the price should be negotiated per-request rather than fixed by the blueprint. The user requests a quote from specific operators, who sign an EIP-712 price, and the user submits the job with the signed quote(s).

### When to use RFQ vs fixed rates

| Use case | Mechanism |
|----------|-----------|
| Standardized ops with predictable cost | Fixed per-job rates (`setJobEventRates`) |
| Variable cost (different LLM models, custom container specs, volume discounts) | Job RFQ (`submitJobFromQuote`) |

### EIP-712 types

```solidity
struct JobQuoteDetails {
    uint64 serviceId;   // Which service instance
    uint8 jobIndex;     // Which job type
    uint256 price;      // Operator's price in native token (wei)
    uint64 timestamp;   // When quote generated
    uint64 expiry;      // Quote expiry timestamp
}

struct SignedJobQuote {
    JobQuoteDetails details;
    bytes signature;    // EIP-712 signature
    address operator;   // Quoted operator address
}
```

TypeHash:

```
JobQuoteDetails(uint64 serviceId,uint8 jobIndex,uint256 price,uint64 timestamp,uint64 expiry)
```

Domain: `EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)` with `name="TangleQuote"`, `version="1"`, `verifyingContract=<tangle proxy>`.

### Submission

```solidity
function submitJobFromQuote(
    uint64 serviceId,
    uint8 jobIndex,
    bytes calldata inputs,
    SignedJobQuote[] calldata quotes  // 1 or more operator quotes
) external payable returns (uint64 callId);
```

- `msg.value` must equal `sum(quotes[i].details.price)`
- Each quote's `serviceId` and `jobIndex` must match the call params
- Each operator must be active in the service
- Quotes expire based on `expiry` field and `maxQuoteAge` (default: 1 hour)
- Replay-protected: each quote digest can only be used once

### Result enforcement

Only quoted operators can submit results for RFQ jobs:

```solidity
// In _validateResultSubmissionState:
if (job.isRFQ && !_jobQuotedOperators[serviceId][callId].contains(msg.sender)) {
    revert Errors.NotQuotedOperator(serviceId, callId);
}
```

### Payment distribution for RFQ jobs

On job completion, each quoted operator receives their individual quoted price (not a proportional split). The payment is distributed through the standard `PaymentSplit` but weighted by each operator's quoted price rather than effective exposure.

### View functions

```solidity
function getJobQuotedOperators(uint64 serviceId, uint64 callId) external view returns (address[] memory);
function getJobQuotedPrice(uint64 serviceId, uint64 callId, address operator) external view returns (uint256);
```

### Operator-side implementation (blueprint-sdk)

The on-chain contract verifies quotes — but operators need off-chain software to **generate and sign** them. The `blueprint-sdk` provides this infrastructure.

**EIP-712 signing utility** — `blueprint-tangle-extra` crate:

```rust
use blueprint_tangle_extra::job_quote::{JobQuoteSigner, JobQuoteDetails, QuoteSigningDomain};

let domain = QuoteSigningDomain {
    chain_id: 1,
    verifying_contract: tangle_proxy_address,
};
let signer = JobQuoteSigner::new(operator_keypair, domain);

let details = JobQuoteDetails {
    service_id: 42,
    job_index: 7,
    price: U256::from(250_000_000_000_000u64), // 0.00025 ETH
    timestamp: now,
    expiry: now + 3600,
};

let signed_quote = signer.sign(&details); // Returns SignedJobQuote ready for on-chain
```

**gRPC quote-serving server** — `blueprint-pricing-engine` crate:

The pricing-engine is a standalone daemon that operators run alongside their blueprint. It exposes two gRPC endpoints:

```proto
service PricingEngine {
  rpc GetPrice (GetPriceRequest) returns (GetPriceResponse);      // Service-level quotes
  rpc GetJobPrice (GetJobPriceRequest) returns (GetJobPriceResponse); // Per-job quotes
}
```

The operator configures per-job prices in a config map `(service_id, job_index) → price`. When a user requests a quote, the engine looks up the price, signs it with EIP-712, and returns the signed quote. The user then submits it on-chain via `submitJobFromQuote()`.

**What blueprint developers need to do for RFQ support:**

1. Use `JobQuoteSigner` from `blueprint-tangle-extra` for EIP-712 signing
2. Either use the `pricing-engine` daemon directly, or build custom quote-serving logic into your operator binary
3. Define your pricing dimensions (per-model, per-resource, flat rate) and expose operator-configurable cost parameters
4. The operator runs your software and configures their prices — the protocol handles the rest

See `blueprint-sdk/crates/pricing-engine/` for the complete reference implementation including benchmarking, caching, and gRPC transport.

---

## Service-Level RFQ (createServiceFromQuotes)

Separate from Job RFQ. This creates an entire service from operator quotes, used for `PayOnce` services.

```solidity
function createServiceFromQuotes(
    uint64 blueprintId,
    SignedQuote[] calldata quotes,    // One per operator
    bytes calldata config,
    address[] calldata permittedCallers,
    uint64 ttl
) external payable returns (uint64 serviceId);
```

Each operator signs a `QuoteDetails` struct containing `totalCost`, `blueprintId`, `ttlBlocks`, and optional `securityCommitments`.

The user pays `sum(quote.totalCost)`. Payment is distributed immediately.

---

## Payment Distribution

All payment (PayOnce, Subscription, EventDriven) flows through the same distribution logic.

### PaymentSplit

Global protocol configuration (admin-only):

```solidity
struct PaymentSplit {
    uint16 developerBps;   // To blueprint owner (default: 2000 = 20%)
    uint16 protocolBps;    // To protocol treasury (default: 2000 = 20%)
    uint16 operatorBps;    // To service operators (default: 4000 = 40%)
    uint16 stakerBps;      // To delegators/restakers (default: 2000 = 20%)
}
// Must sum to 10000 (100%)
```

### Distribution flow

```
Total payment
├── developerBps% → blueprint owner (or BSM's queryDeveloperPaymentAddress)
├── protocolBps%  → protocol treasury
├── operatorBps%  → operator pool (split by effective exposure)
└── stakerBps%    → restaker pool (forwarded to ServiceFeeDistributor)
```

### Operator weighting

Operators are paid proportionally to their **effective exposure**:

```
effective_exposure = delegation_amount × exposureBps
```

If no restakers exist (`totalEffectiveExposure == 0`), the restaker share merges into the operator pool and operators split equally based on their stored `exposureBps`.

### Developer payment address

By default, the blueprint `owner` receives the developer share. BSMs can override this:

```solidity
// In your BSM:
function queryDeveloperPaymentAddress(uint64 serviceId) external view returns (address payable) {
    return payable(customDevAddress);
}
```

### TNT payment discount

If the payment token is TNT, the protocol can apply a discount (`_tntPaymentDiscountBps`) funded from the protocol share and sent to the service owner.

### Claiming rewards

Operator and restaker shares are accrued as pending rewards, not transferred immediately:

```solidity
function claimRewards() external;                          // Native token
function claimRewards(address token) external;             // Specific token
function claimRewardsBatch(address[] calldata tokens) external;  // Multiple tokens
function claimRewardsAll() external;                       // All tokens

function pendingRewards(address account) external view returns (uint256);
function pendingRewards(address account, address token) external view returns (uint256);
```

---

## Storage Layout

Pricing-related storage in `TangleStorage.sol`:

| Mapping | Purpose |
|---------|---------|
| `_blueprintConfigs[blueprintId]` | `BlueprintConfig` with `eventRate`, `subscriptionRate`, `subscriptionInterval` |
| `_jobEventRates[blueprintId][jobIndex]` | Per-job rate overrides (0 = use `eventRate` fallback) |
| `_serviceEscrows[serviceId]` | Subscription escrow (`token`, `balance`, `totalDeposited`, `totalReleased`) |
| `_jobQuotedOperators[serviceId][callId]` | `EnumerableSet` of operators quoted for an RFQ job |
| `_jobQuotedPrices[serviceId][callId][operator]` | Individual quoted price per operator per RFQ job |
| `_usedQuotes[digest]` | Replay protection — `true` if quote digest has been consumed |
| `_paymentSplit` | Global `PaymentSplit` config |
| `_pendingRewards[account][token]` | Accrued, unclaimed rewards |

---

## What's Protocol-Level vs Custom

| Capability | Built into protocol | Requires custom BSM logic |
|------------|--------------------|----|
| Three pricing models (PayOnce/Subscription/EventDriven) | Yes | No |
| Per-job event rate overrides | Yes (`setJobEventRates`) | No |
| Rate fallback to `BlueprintConfig.eventRate` | Yes | No |
| Job RFQ with EIP-712 signed quotes | Yes (`submitJobFromQuote`) | No |
| Service-level RFQ (`createServiceFromQuotes`) | Yes | No |
| Payment split (dev/protocol/operator/staker) | Yes | No |
| Subscription escrow + billing | Yes | No |
| Replay protection on quotes | Yes | No |
| Custom developer payment address | Yes (BSM hook) | `queryDeveloperPaymentAddress()` |
| Custom required result count | Yes (BSM hook) | `getRequiredResultCount()` |
| Multiplier-based rate tables | No | Define in BSM (see ai-agent-sandbox-blueprint) |
| Dynamic pricing based on model/resources | No | Use Job RFQ or custom BSM logic |
| Metered/per-second billing | No | Custom BSM or off-chain settlement |
| ERC-20 payment for EventDriven jobs | Not yet | PayOnce/Subscription support ERC-20; EventDriven is native-only currently |

---

## Integration Checklist

### Blueprint developer

**On-chain (Solidity):**

1. Choose `PricingModel` at blueprint registration
2. Set `BlueprintConfig.eventRate` as the default per-job rate (EventDriven)
3. Set `subscriptionRate` and `subscriptionInterval` (Subscription)
4. After registration, call `setJobEventRates()` to override rates for specific job types
5. Optionally implement `queryDeveloperPaymentAddress()` in your BSM
6. Optionally implement `getRequiredResultCount()` for multi-operator result thresholds

**Off-chain (Rust operator binary):**

7. If using RFQ: integrate `JobQuoteSigner` from `blueprint-tangle-extra` for EIP-712 quote signing
8. If using RFQ: either embed the `pricing-engine` gRPC server or implement your own quote-serving endpoint
9. Define operator-configurable pricing parameters (resource rates, model costs, margins)
10. For `Subscription`: run `SubscriptionBillingKeeper` from `blueprint-tangle-extra` to auto-bill

### Operator

1. For fixed-rate blueprints: no pricing config needed — rates are set by the blueprint owner
2. For RFQ blueprints: configure per-job prices in the blueprint's operator config (e.g., `operator.toml`)
3. The blueprint software handles quote signing and serving automatically via `JobQuoteSigner` + gRPC
4. For `Subscription` services: billing happens automatically if the blueprint runs `SubscriptionBillingKeeper`, or call `billSubscription()` manually
5. Call `claimRewards()` to withdraw accrued earnings

### Service consumer

1. For `EventDriven` (fixed rates): call `submitJob()` with `msg.value >= getJobEventRate(blueprintId, jobIndex)`
2. For `EventDriven` (RFQ): request quotes from operators via their gRPC endpoint, call `submitJobFromQuote()` with signed quotes
3. For `Subscription`: call `fundService()` to keep escrow funded
4. For `PayOnce`: pay at service creation via `createServiceFromQuotes()`
