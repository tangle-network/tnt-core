# Tangle Network - L2 Slashing Architecture

This document describes how slashing works across the Ethereum beacon chain and Tangle L2.

## Overview

There are **two independent sources of slashing** in the Tangle staking system:

1. **Beacon Chain Slashing** - Validators penalized on Ethereum for misbehavior (inactivity, double-signing)
2. **Tangle L2 Slashing** - Operators penalized on Tangle for blueprint/service failures

These must work together to ensure operators can't escape slashing by having assets on one chain but misbehaving on another.

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                        ETHEREUM L1                                   │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌──────────────────┐     ┌─────────────────────────────────────┐  │
│  │   Beacon Chain   │     │         ValidatorPodManager         │  │
│  │                  │     │                                     │  │
│  │ - Validator Set  │     │ - Operator Registry                 │  │
│  │ - Balances       │────▶│ - Delegations (stake tracking)      │  │
│  │ - Slashing       │     │ - Withdrawal Queue                  │  │
│  │                  │     │ - Slasher Authorization              │  │
│  └──────────────────┘     └───────────────┬─────────────────────┘  │
│                                           │                         │
│  ┌──────────────────────────────────────┐ │                         │
│  │           ValidatorPod               │ │                         │
│  │                                      │ │                         │
│  │ - beaconChainSlashingFactor (ELIP-004)│◀┘                         │
│  │ - Validator Proofs                   │                           │
│  │ - verifyStaleBalance()               │                           │
│  │ - Checkpoint accounting              │                           │
│  └──────────────────────────────────────┘                           │
│                                                                      │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │              EIP-4788 Beacon Root Oracle                     │   │
│  │              (Beacon block roots accessible in EVM)          │   │
│  └──────────────────────────────────────────────────────────────┘   │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
                                   │
                                   │ Bridge/Message
                                   ▼
┌─────────────────────────────────────────────────────────────────────┐
│                         TANGLE L2                                    │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌────────────────────┐    ┌────────────────────────────────────┐  │
│  │  Blueprint Services │    │         StakingManager           │  │
│  │                     │    │                                    │  │
│  │  - Job execution    │───▶│  - L1 stake mirror (via oracle)   │  │
│  │  - Slashing reports │    │  - Operator registration          │  │
│  │                     │    │  - slash() for L2 misbehavior     │  │
│  └────────────────────┘    └────────────────────────────────────┘  │
│                                                                      │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │              L1 → L2 Oracle / Bridge                          │   │
│  │   - Sync operator stake from L1 ValidatorPodManager          │   │
│  │   - Sync beaconChainSlashingFactor                           │   │
│  └──────────────────────────────────────────────────────────────┘   │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

## Slashing Types

### 1. Beacon Chain Slashing (Ethereum L1)

**Cause**: Validator misbehavior on Ethereum beacon chain
- Attestation slashing (double voting)
- Proposer slashing (double blocks)
- Inactivity leak (prolonged offline)

**Effect**:
- Validator's effective balance reduced on beacon chain
- `beaconChainSlashingFactor` decreases proportionally
- Pod owner's shares affected through slashing factor

**Flow**:
```
1. Validator slashed on beacon chain
2. Anyone calls verifyStaleBalance() with proof
3. ValidatorPod computes new beaconChainSlashingFactor
4. Pod owner's effective shares = shares * slashingFactor
5. Delegators' effective stake reduced proportionally
```

**Code Path**:
```solidity
// ValidatorPod.sol
function verifyStaleBalance(...) external {
    // Verify validator was slashed via Merkle proof
    // Update beaconChainSlashingFactor
    // Emit BeaconChainSlashingFactorDecreased event
}

function getSlashingFactor() external view returns (uint64) {
    return beaconChainSlashingFactor; // 1e18 = 100%, decreasing
}

function applySlashingFactor(int256 shares) external view returns (int256) {
    return (shares * int256(uint256(beaconChainSlashingFactor))) / 1e18;
}
```

### 2. Tangle L2 Slashing

**Cause**: Operator misbehavior on Tangle network
- Blueprint execution failures
- Service unavailability
- Provable misbehavior (fraud proofs)

**Effect**:
- Operator's stake slashed via ValidatorPodManager
- Self-stake slashed first, then delegated stake proportionally
- Slashed funds go to slasher/protocol

**Flow**:
```
1. Blueprint detects operator misbehavior
2. Slasher submits evidence to ValidatorPodManager
3. slash() reduces operatorStake and delegations
4. DelegatorSlashed events emitted
5. Slashed ETH distributed
```

**Code Path**:
```solidity
// ValidatorPodManager.sol
function slash(
    address operator,
    uint64 serviceId,
    uint256 amount,
    bytes32 evidence
) external returns (uint256 actualSlashed) {
    // Verify caller is authorized slasher
    // Slash from self-stake first
    // Then proportionally from delegations
}
```

## Interaction Between Slashing Types

### Scenario 1: Beacon Slashing First, Then L2 Query

```
1. Validator slashed on beacon chain (loses 1 ETH)
2. beaconChainSlashingFactor drops from 1e18 to 0.96875e18
3. L2 queries operator stake via oracle/bridge
4. Effective stake = rawStake * slashingFactor
5. L2 sees reduced stake, may affect service eligibility
```

### Scenario 2: L2 Slashing First

```
1. Operator slashed on L2 for misbehavior
2. ValidatorPodManager.slash() reduces operatorStake
3. Delegators' shares reduced proportionally
4. Beacon chain unaffected (ETH still with validators)
5. Pod owner can't withdraw slashed amount
```

### Scenario 3: Double Slashing (Both Sources)

```
1. Validator slashed on beacon chain
2. beaconChainSlashingFactor reduced
3. Operator also slashed on L2
4. Both reductions compound
5. Effective stake = (rawStake - L2Slash) * beaconSlashingFactor
```

## Oracle/Bridge Design

For L2 to know L1 stake accurately, we need an oracle:

### Option A: Pull-Based Oracle
```solidity
// On L2
interface IL1StakeOracle {
    function getOperatorStake(address operator) external view returns (uint256);
    function getSlashingFactor(address podOwner) external view returns (uint64);
}

// Implementation queries L1 via cross-chain message
```

### Option B: Push-Based Bridge
```solidity
// On L1 - emit events
event StakeUpdated(address indexed operator, uint256 newStake);
event SlashingFactorUpdated(address indexed podOwner, uint64 newFactor);

// Relayer bridges events to L2
// L2 contract stores mirrored state
```

### Option C: Merkle Root Bridge (Most Secure)
```solidity
// L1 periodically posts merkle root of all stakes
// L2 verifies stake via merkle proof
// Similar to how ValidatorPod verifies beacon chain state
```

## Recommended Design

### Phase 1: L1-Only Slashing (Current)
- ValidatorPodManager handles all slashing on L1
- beaconChainSlashingFactor tracked per pod
- L2 queries L1 state via simple oracle

### Phase 2: L2 Slashing with L1 Settlement
- L2 collects slashing reports
- Batched slashing submitted to L1
- L1 ValidatorPodManager executes actual slashing
- Provides unified slashing history

### Phase 3: Native Cross-Chain Slashing
- L2 can directly trigger L1 slashing via bridge
- Fraud proof window for L2 slashing disputes
- Atomic cross-chain slash-and-distribute

## Integration Points

### ValidatorPodManager Changes Needed
```solidity
// Add L2 slasher bridge authorization
mapping(address => bool) public l2SlashingBridges;

function slashFromL2(
    address operator,
    uint64 serviceId,
    uint256 amount,
    bytes32 l2TxHash,
    bytes memory bridgeProof
) external {
    require(l2SlashingBridges[msg.sender], "NotL2Bridge");
    // Verify bridge proof
    // Execute slash
}
```

### L2 StakingManager Interface
```solidity
interface IL2StakingManager {
    function getEffectiveStake(address operator) external view returns (uint256);
    function reportSlashing(address operator, uint256 amount, bytes32 evidence) external;
    function syncFromL1(bytes calldata stateProof) external;
}
```

## Slashing Factor Propagation

The `beaconChainSlashingFactor` must be considered when:

1. **Calculating available shares for withdrawal**
   ```solidity
   effectiveShares = rawShares * slashingFactor / 1e18
   ```

2. **Determining operator stake for service requirements**
   ```solidity
   effectiveStake = (selfStake + delegatedStake) * avgSlashingFactor / 1e18
   ```

3. **Distributing rewards**
   ```solidity
   // Rewards should be based on effective stake, not raw stake
   reward = totalReward * effectiveStake / totalEffectiveStake
   ```

## Security Considerations

1. **Slashing Factor Can Only Decrease** - Prevents manipulation
2. **Third-Party Enforcement** - `verifyStaleBalance()` ensures pod owners can't hide slashing
3. **Withdrawal Delay** - 7-day delay allows time to detect and process slashing
4. **Proportional Delegator Slashing** - Fair distribution of losses
5. **Cross-Chain Latency** - L2 may have stale stake data; oracle should refresh frequently

## Open Questions

1. Should L2 slashing be able to exceed L1 stake? (Currently: no, capped)
2. How to handle slashing during pending withdrawals?
3. Should there be a global slashing cap per epoch?
4. Insurance/protection fund for delegators?

## References

- [EigenLayer ELIP-004 Slashing Factor](https://github.com/Layr-Labs/eigenlayer-contracts/blob/dev/docs/core/proofs/BeaconChainProofs.md)
- [EIP-4788 Beacon Block Root in EVM](https://eips.ethereum.org/EIPS/eip-4788)
- [Symbiotic Slashing Design](https://docs.symbiotic.fi/concepts/slashing)
