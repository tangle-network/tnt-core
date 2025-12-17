# Service Payment Flow Architecture

This document describes the payment flow for services in the Tangle Network protocol.

## Overview

Tangle supports two pricing models for services:
1. **PayOnce** - Customer pays upfront, funds stream to operators over service TTL
2. **Subscription** - Recurring billing from escrow (not yet implemented)

The PayOnce model uses native streaming via `StreamingPaymentManager`, which distributes payments proportionally over the service duration based on operator security scores.

## Contract Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         CUSTOMER REQUESTS SERVICE                           │
│  tangle.requestService(blueprintId, operators, paymentToken, paymentAmount) │
└─────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                            Services.sol                                     │
│  1. Validates service request                                               │
│  2. Calls distributor.handlePayment() with full payment amount              │
└─────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                      ServiceFeeDistributor.sol                              │
│  handlePayment():                                                           │
│  1. Split payment into platform fee vs operator allocation                  │
│  2. For each operator in service:                                           │
│     - Calculate operator's share based on security score                    │
│     - Create streaming payment via StreamingPaymentManager                  │
│  3. Send platform fee to treasury                                           │
└─────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                     StreamingPaymentManager.sol                             │
│  createStream():                                                            │
│  - Stores streaming payment record: {serviceId, operator, amount,           │
│    startTime, endTime, distributed}                                         │
│  - Tracks active streams per operator                                       │
│  - Holds tokens until dripped                                               │
└─────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      │  (Time passes...)
                                      ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                    DRIP OPERATION (called periodically)                     │
│  ServiceFeeDistributor.drip(serviceId, operator)                            │
│  or ServiceFeeDistributor.dripAll(operator)                                 │
└─────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                     StreamingPaymentManager.sol                             │
│  dripAndGetChunk():                                                         │
│  1. Calculate elapsed time since lastDripTime                               │
│  2. Compute chunk = (totalAmount * elapsed) / duration                      │
│  3. Update distributed counter and lastDripTime                             │
│  4. Transfer chunk tokens to ServiceFeeDistributor                          │
│  5. Return (amount, duration, blueprintId, paymentToken)                    │
└─────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                      ServiceFeeDistributor.sol                              │
│  _distributeChunk():                                                        │
│  1. Get operator's current security score                                   │
│  2. Calculate share for operator vs delegators                              │
│  3. Send operator's portion directly                                        │
│  4. Distribute delegator portion via DelegationRewards.distributeReward()   │
└─────────────────────────────────────────────────────────────────────────────┘
                                      │
                    ┌─────────────────┴─────────────────┐
                    ▼                                   ▼
    ┌──────────────────────────┐         ┌──────────────────────────┐
    │   OPERATOR RECEIVES      │         │   DelegationRewards.sol  │
    │   Direct payment for     │         │   Distributes to         │
    │   their portion          │         │   delegators based on    │
    │                          │         │   delegation amounts     │
    └──────────────────────────┘         └──────────────────────────┘
```

## Key Components

### StreamingPaymentManager

Handles the time-based streaming of payments:
- Creates streams when services are requested
- Calculates drip amounts based on elapsed time
- Holds tokens until they're dripped
- Supports early termination with refunds

### ServiceFeeDistributor

Orchestrates payment distribution:
- Receives initial payment from Services.sol
- Splits between platform fee and operators
- Creates streams via StreamingPaymentManager
- Distributes dripped amounts based on security scores
- Routes delegator rewards to DelegationRewards

### DelegationRewards

Handles delegator reward distribution:
- Receives operator's delegator portion
- Distributes based on stake amounts
- Allows delegators to claim accumulated rewards

## Security Score-Based Distribution

Payments are distributed proportionally to operators based on their **security score**, which represents:
- The value of assets delegated to them
- Weighted by the blueprint's security requirements

This ensures operators with more security backing receive proportionally more of the service fees.

## Future: External Streaming Adapters

The protocol includes `IStreamingPaymentAdapter` interfaces for future integration with external DeFi streaming protocols (Superfluid, Sablier, etc.). These are **optional** and independent from the native streaming implementation. The native `StreamingPaymentManager` is fully functional without any external adapters.

## Drip Triggers

Drips can be triggered by:
1. **Manual calls**: Anyone can call `drip()` or `dripAll()` on ServiceFeeDistributor
2. **Score updates**: Automatically dripped before operator delegation changes
3. **Service termination**: Final drip before refunding remaining balance
4. **Operator leaving**: Drip before operator exits a service

## Service Termination

When a service is terminated early:
1. All pending amounts are dripped
2. Remaining undistributed funds are refunded to a specified recipient
3. Stream records are cleaned up

## Token Support

The system supports:
- **Native ETH**: Sent via `msg.value` and handled with low-level calls
- **ERC20 tokens**: Transferred using SafeERC20 for compatibility
