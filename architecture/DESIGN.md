# Tangle v2 Design

## Design Philosophy

1. **Minimal surface area** - One core contract, clear boundaries
2. **Separation of concerns** - Staking is abstract, hooks are per-blueprint
3. **Gas efficiency** - Pack structs, events over storage, batch ops
4. **Professional interfaces** - Clear, documented, intuitive

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         Tangle.sol                               │
│            Single source of truth for protocol state            │
│                                                                  │
│  Blueprints ────────────────────────────────────────────────    │
│  Services ──────────────────────────────────────────────────    │
│  Jobs ──────────────────────────────────────────────────────    │
│  Rewards ───────────────────────────────────────────────────    │
│                                                                  │
└───────────────────────────────┬─────────────────────────────────┘
                                │
        ┌───────────────────────┼───────────────────────┐
        │                       │                       │
        ▼                       ▼                       ▼
┌───────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  IRestaking   │     │  IBlueprintHook │     │   Protocol      │
│   (abstract)  │     │  (per-blueprint)│     │   Treasury      │
└───────────────┘     └─────────────────┘     └─────────────────┘
        ▲
        │
┌───────┴─────────────────────────────────────────────────────────┐
│       │                   │                    │                 │
│  ┌────┴────┐       ┌──────┴──────┐      ┌─────┴─────┐          │
│  │ Native  │       │ EigenLayer  │      │ Symbiotic │          │
│  │Restaking│       │  Restaking  │      │ Restaking │          │
│  └─────────┘       └─────────────┘      └───────────┘          │
└─────────────────────────────────────────────────────────────────┘
```

## Why This Design?

### Single Core Contract (Tangle.sol)
- **Atomic operations** - No cross-contract reentrancy risks
- **Gas efficient** - No delegate calls or external state reads for core ops
- **Simple mental model** - One place for all protocol logic
- **Upgradeable** - UUPS pattern allows fixes

### Abstract Restaking
- **Pluggable backends** - Native, EigenLayer, Symbiotic, future protocols
- **Clean interface** - Core protocol doesn't care about stake implementation
- **Easy migration** - Switch backends without core changes

### Per-Blueprint Hooks
- **Developer freedom** - Custom logic per blueprint
- **Isolated risk** - Bad hook can't affect other blueprints
- **Optional** - Hooks are opt-in, default behavior works

## Data Model

### Identifiers
```
blueprintId: uint64  (max ~18 quintillion)
serviceId:   uint64
callId:      uint64  (per-service job call counter)
```

### Blueprint
```solidity
struct Blueprint {
    address owner;       // Can update metadata, transfer ownership
    address hook;        // IBlueprintHook (0x0 = no hook)
    uint64 createdAt;    // Timestamp
    bool active;         // Can be deactivated by owner
    // metadataUri stored in event, not state (gas optimization)
}
// 1 slot: owner(20) + createdAt(8) + active(1) = 29 bytes, fits in 1 slot with hook
// Actually: owner(20) + hook(20) = 40 bytes = 2 slots
// Optimize: Pack createdAt and active with something else
```

### Operator (per-blueprint)
```solidity
// Mapping: blueprintId => operator => OperatorStatus
struct OperatorStatus {
    bool registered;
    uint64 registeredAt;
    // Preferences stored in event
}
// Can pack into 1 slot
```

### Service
```solidity
struct Service {
    uint64 blueprintId;
    address owner;
    uint64 createdAt;
    uint64 terminatedAt;  // 0 if active
    uint64 ttl;           // 0 = no expiry
    // operators[] and permittedCallers[] stored in mappings
}
// 2 slots
```

### Job
```solidity
// Minimal on-chain state
struct JobCall {
    uint8 jobIndex;
    address caller;
    uint64 createdAt;
    bool completed;
    // inputs and outputs in events
}
// 1 slot
```

## Key Operations

### 1. Create Blueprint
```
Developer calls: createBlueprint(metadataUri, hook)
  → Assigns blueprintId
  → Stores Blueprint struct
  → Emits BlueprintCreated(id, owner, hook, metadataUri)
  → Calls hook.onBlueprintCreated() if hook != 0
```

### 2. Register Operator
```
Operator calls: registerOperator(blueprintId, preferences)
  → Checks operator has stake via IRestaking
  → Records registration
  → Emits OperatorRegistered(blueprintId, operator, preferences)
  → Calls hook.onRegister() if hook != 0
```

### 3. Request Service
```
User calls: requestService(blueprintId, operators[], config, callers[], ttl) payable
  → Validates all operators registered and active
  → Escrows payment
  → Creates pending ServiceRequest
  → Emits ServiceRequested(requestId, ...)
  → Calls hook.onRequest() if hook != 0
```

### 4. Approve Service (Operators)
```
Operator calls: approveService(requestId)
  → Records approval
  → If all approved:
    → Creates Service
    → Distributes payment
    → Emits ServiceActivated(serviceId, ...)
    → Calls hook.onServiceInitialized() if hook != 0
```

### 5. Submit Job
```
Caller calls: submitJob(serviceId, jobIndex, inputs) payable
  → Validates caller permitted
  → Creates JobCall record
  → Emits JobSubmitted(serviceId, callId, jobIndex, caller, inputs)
  → Calls hook.onJobCall() if hook != 0
```

### 6. Submit Result
```
Operator calls: submitResult(serviceId, callId, result)
  → Validates operator in service
  → Records result
  → Emits ResultSubmitted(serviceId, callId, operator, result)
  → Calls hook.onJobResult() if hook != 0
  → Updates rewards
```

## Payment Flow

```
User Payment (requestService)
        │
        ▼
┌───────────────┐
│    Escrow     │
│  (in Tangle)  │
└───────┬───────┘
        │ All operators approve
        ▼
┌───────────────────────────────────────────────────────────┐
│                    Payment Split                          │
│  ┌─────────┐ ┌─────────┐ ┌──────────┐ ┌──────────────┐  │
│  │Developer│ │Protocol │ │Operators │ │  Restakers   │  │
│  │  50%    │ │  10%    │ │   20%    │ │     20%      │  │
│  └────┬────┘ └────┬────┘ └────┬─────┘ └──────┬───────┘  │
│       │           │           │              │          │
│       ▼           ▼           ▼              ▼          │
│    Owner      Treasury    Reward Pool    Reward Pool    │
└───────────────────────────────────────────────────────────┘
```

## Reward Mechanism

**Masterchef-style accumulator for gas efficiency:**

```solidity
struct RewardPool {
    uint256 accRewardPerShare;  // Accumulated reward per share, scaled 1e18
    uint256 totalShares;        // Total staked/delegated
}

// Per-user debt tracking
mapping(address => uint256) rewardDebt;

// Claim calculation (O(1)):
pending = (userShares * accRewardPerShare / 1e18) - rewardDebt[user]
```

## Slashing

```
Evidence submitted (by anyone or hook)
        │
        ▼
┌───────────────┐
│ Tangle.slash()│
└───────┬───────┘
        │
        ▼
┌───────────────┐
│IRestaking     │
│.slash(op,amt) │
└───────┬───────┘
        │
        ▼
  Stake reduced
  Delegators affected proportionally
```

## Gas Optimizations

| Technique | Application |
|-----------|-------------|
| Pack structs | Fit related data in single slots |
| Events over storage | Store large data (metadata, inputs, outputs) in events |
| Mappings over arrays | O(1) lookups, no iteration gas |
| Batch operations | submitJobs(), submitResults() |
| Lazy evaluation | Calculate rewards on claim, not on deposit |

## Security Measures

1. **Reentrancy** - ReentrancyGuard on all external calls
2. **Access control** - Explicit checks, no implicit assumptions
3. **Integer overflow** - Solidity 0.8+ automatic checks
4. **Front-running** - Commit-reveal for sensitive operations (optional)
5. **Upgrade safety** - Timelock on upgrades
6. **Hook isolation** - Hooks can't affect core state directly

## File Structure

```
src/
├── Tangle.sol              # Core protocol
├── interfaces/
│   ├── ITangle.sol         # Core interface
│   ├── IRestaking.sol      # Staking abstraction
│   └── IBlueprintHook.sol  # Hook interface
├── restaking/
│   ├── NativeRestaking.sol
│   ├── EigenLayerRestaking.sol
│   └── SymbioticRestaking.sol
└── libraries/
    ├── Types.sol           # Shared types
    └── Errors.sol          # Custom errors
```
