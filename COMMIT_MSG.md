fix: payment distribution based on effective exposure (delegation × exposureBps)

## Problem

Operators were being paid based solely on their declared `exposureBps`
commitment, ignoring their actual delegated stake. This allowed operators
with zero delegation to receive equal payment to operators with substantial
security capital at risk.

Example of the bug:
- Operator A: 500 ETH delegated, 10% exposure → should get 71.4%
- Operator B: 0 ETH delegated, 10% exposure → was getting 50%!

## Solution

Payment distribution now uses **effective exposure** = delegation × exposureBps.

This ensures operators are paid proportionally to the actual security
capital they have at risk, not just their declared commitment percentage.

## Changes

### Core Changes

- `PaymentLib.calculateOperatorPayments`: Now accepts `uint256[]` effective
  exposures instead of `uint16[]` exposure bps. Added legacy wrapper for
  backward compatibility.

- `Payments.sol`: Added `_distributePaymentWithEffectiveExposure()` that
  computes effective exposures from operator delegations and security
  commitments. Subscription billing now uses this method.

- `PaymentsEffectiveExposure.sol`: New mixin providing effective exposure
  calculation logic with optional price oracle for USD normalization.

### Facet Changes

- `TanglePaymentsFacet`: Added `distributePaymentWithEffectiveExposure()`
  for internal cross-facet calls.

- `TangleServicesFacet`: PayOnce payments during service activation now
  compute and use effective exposures.

- `ITanglePaymentsInternal`: Added new interface function for effective
  exposure payment distribution.

### Tests

- `EffectiveExposurePayments.t.sol`: Unit tests for PaymentLib with
  effective exposures, including bug demonstration.

- `EffectiveExposureIntegration.t.sol`: Integration tests documenting
  expected behavior and edge cases.

## Behavior Change

| Operator | Delegation | ExposureBps | Old Share | New Share |
|----------|------------|-------------|-----------|-----------|
| A        | 500 ETH    | 10%         | 50%       | 71.4%     |
| B        | 0 ETH      | 10%         | 50%       | 0%        |

Operators with no delegation now receive no payment, aligning economic
incentives with actual security provided.

Closes #75
