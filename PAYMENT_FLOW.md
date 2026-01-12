# Service Payment Flow (v2)

This document describes how a service payment moves through the protocol and which contracts hold/track “rewards” for later claiming.

## Mental Model (ELI5)

When a customer pays for a service, the protocol splits the payment into four piles:

1. **Developer pile** → sent immediately to the blueprint owner (or a custom developer address via the blueprint’s manager).
2. **Treasury pile** → sent immediately to the protocol treasury.
3. **Operator pile** → tracked as “pending rewards” inside Tangle; operators claim it later.
4. **Restaker pile** → forwarded into `ServiceFeeDistributor`; restakers claim it later (in the same payment token).

Key idea: **operator earnings and restaker earnings use different accounting systems**.

## High-Level Architecture

```
Customer pays (ETH/ERC20)
        │
        ▼
Tangle (Payments)
  - developer share → immediate transfer
  - protocol share  → immediate transfer (treasury)
  - operator share  → accrues in Tangle pendingRewards
  - restaker share  → forwarded to ServiceFeeDistributor
        │
        ▼
ServiceFeeDistributor
  - attributes rewards to delegators based on delegation “score”
  - (optional) streams restaker-share over TTL via StreamingPaymentManager
  - restakers claim per-token via claimAll(token)
```

## Where “Rewards” Live

### Operator Earnings (Service Payments)

- **Where tracked:** `Tangle` (see `src/v2/core/Payments.sol`)
- **Paid in:** same token used to pay for the service (ETH or ERC20)
- **View:**
  - `tangle.pendingRewards(operator)` (native)
  - `tangle.pendingRewards(operator, token)` (ERC20)
- **Claim:**
  - `tangle.claimRewards()` (native)
  - `tangle.claimRewards(token)` (ERC20)

### Restaker Earnings (Service-Fee Restaker Share)

- **Where tracked:** `ServiceFeeDistributor` (see `src/v2/rewards/ServiceFeeDistributor.sol`)
- **Paid in:** the service’s payment token (multi-token)
- **How it allocates:** accumulated-per-score accounting (O(1) updates), using delegation score (principal × lockMultiplier), optionally USD-weighted via oracle.
- **View (per token):** `ServiceFeeDistributor.pendingRewards(delegator, token)`
- **Claim (per token):** `ServiceFeeDistributor.claimAll(token)`

Notes:
- If the service has a TTL and a `StreamingPaymentManager` is configured, the restaker-share can be streamed; `claimAll(token)` automatically “drips” streams before harvesting.
- If `serviceFeeDistributor` is unset, the restaker share is routed to treasury (payments still succeed).

## PayOnce vs Subscription

The split logic is the same; only the trigger differs:

- **PayOnce:** payment is provided at `requestService(...)` and distributed when the service becomes active (on final approval).
- **Subscription:** customer funds escrow via `fundService(...)`, then anyone can trigger `billSubscription(...)` to distribute the next interval’s amount.

## TNT Discount (Not a Reward Source)

If a service is paid in TNT and `tntPaymentDiscountBps` is set, the protocol can rebate part of the payment to the service owner, capped to the protocol share. This is a pricing incentive (discount), not a separate reward stream.
