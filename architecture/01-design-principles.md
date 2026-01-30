# Design Principles & L3 Architecture

## Core Principles

### 1. Shared Security Agnosticism

The protocol MUST NOT be coupled to any specific staking mechanism. A clean abstraction layer allows:

- **Native Tangle Staking** - Our own multi-asset delegation system
- **EigenLayer** - ETH restaking, existing operator set
- **Symbiotic** - Multi-asset, flexible collateral
- **Future protocols** - Any new shared security system

```
┌─────────────────────────────────────────────────────────────────┐
│                     Tangle Protocol                              │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │                   ISecurityManager                         │  │
│  │  - getOperatorStake(operator, asset)                      │  │
│  │  - slash(operator, amount, serviceId)                     │  │
│  │  - isOperatorActive(operator)                             │  │
│  │  - getDelegation(delegator, operator)                     │  │
│  └───────────────────────────────────────────────────────────┘  │
│          ▲              ▲               ▲                       │
│          │              │               │                       │
│  ┌───────┴───┐  ┌───────┴────┐  ┌───────┴─────┐                │
│  │  Native   │  │ EigenLayer │  │  Symbiotic  │                │
│  │  Manager  │  │  Adapter   │  │   Adapter   │                │
│  └───────────┘  └────────────┘  └─────────────┘                │
└─────────────────────────────────────────────────────────────────┘
```

### 2. Efficiency First

Every design decision optimizes for:

| Priority | Technique | Application |
|----------|-----------|-------------|
| 1 | **Batch operations** | Job submissions, results, claims |
| 2 | **Lazy evaluation** | Rewards calculated on claim, not deposit |
| 3 | **Minimal storage** | Events > storage, merkle proofs for large data |
| 4 | **Packed structs** | uint64 over uint256 where possible |

### 3. Modularity

Components are independently upgradeable and replaceable:

```
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│  Blueprints  │  │   Services   │  │    Jobs      │
│   Registry   │  │   Manager    │  │   Manager    │
└──────┬───────┘  └──────┬───────┘  └──────┬───────┘
       │                 │                 │
       └─────────────────┼─────────────────┘
                         │
                   ┌─────┴─────┐
                   │  Security │
                   │  Manager  │
                   └───────────┘
```

### 4. Developer Experience Preservation

The hook interface (`IBlueprintServiceManager`) remains familiar. Blueprint developers should NOT need to learn a new paradigm.

## L3 Architecture

### Why L3?

| Benefit | Description |
|---------|-------------|
| **Custom gas token** | Use TNT or stablecoin for fees |
| **Dedicated blockspace** | No competition with other dApps |
| **Lower costs** | L3 fees are fraction of L2 |
| **Sovereignty** | Control over sequencer, DA, upgrades |
| **Composability** | Bridge to L2 for DeFi access |

### L3 Stack Options

#### Option A: Arbitrum Orbit

```
Ethereum L1
    ↓ (Rollup)
Arbitrum One (L2)
    ↓ (AnyTrust or Rollup)
Tangle L3
```

**Pros:**
- Mature Nitro stack
- AnyTrust option for cheaper DA
- Native Arbitrum ecosystem composability

**Cons:**
- Less brand alignment with Base/Coinbase ecosystem

#### Option B: OP Stack (Base)

```
Ethereum L1
    ↓ (Rollup)
Base (L2)
    ↓ (OP Stack L3)
Tangle L3
```

**Pros:**
- Coinbase ecosystem, growing fast
- OP Stack well documented
- Superchain vision alignment

**Cons:**
- L3 tooling less mature than Orbit

### Recommended: Arbitrum Orbit with AnyTrust

**Rationale:**
- AnyTrust DA is sufficient for service coordination (not high-value DeFi)
- Much cheaper than full rollup
- Orbit tooling is production-ready
- Can upgrade to full rollup later if needed

### L3 Configuration

```yaml
# Recommended L3 parameters
chain:
  name: "Tangle Network"
  id: TBD

sequencer:
  mode: centralized  # Start simple, decentralize later

data_availability:
  mode: anytrust     # Cheaper, sufficient for our use case
  committee_size: 5  # Initial DAC

gas:
  token: native      # L3 native token (bridged TNT)

bridge:
  l2: arbitrum_one   # Bridge to Arbitrum for liquidity
```

## State Architecture

### On-Chain (Minimal)

```solidity
// Only what's needed for verification and coordination
struct OnChainState {
    bytes32 blueprintsRoot;    // Merkle root of all blueprints
    bytes32 servicesRoot;      // Merkle root of active services
    bytes32 operatorsRoot;     // Merkle root of registered operators

    uint64 nextBlueprintId;
    uint64 nextServiceId;
    uint64 nextJobCallId;

    address securityManager;   // Current security manager implementation
}
```

### Off-Chain (Full State)

```
┌─────────────────────────────────────────────────────────────────┐
│                     Off-Chain State Layer                        │
│                                                                  │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────────┐   │
│  │   Indexer    │  │    IPFS      │  │   Operator Nodes     │   │
│  │  (TheGraph)  │  │  (Metadata)  │  │  (Full State Cache)  │   │
│  └──────────────┘  └──────────────┘  └──────────────────────┘   │
│                                                                  │
│  - Full blueprint metadata                                       │
│  - Service configurations                                        │
│  - Historical job data                                          │
│  - Operator preferences                                         │
└─────────────────────────────────────────────────────────────────┘
```

### Merkle State Pattern

```solidity
library MerkleState {
    function verifyAndUpdate(
        bytes32 currentRoot,
        bytes32 oldLeaf,
        bytes32 newLeaf,
        bytes32[] calldata proof,
        uint256 index
    ) internal pure returns (bytes32 newRoot) {
        require(MerkleProof.verify(proof, currentRoot, oldLeaf), "Invalid proof");
        return MerkleProof.computeNewRoot(proof, newLeaf, index);
    }
}
```

## Event-Driven Architecture

### Events as Primary Data Source

```solidity
// Rich events for indexers - minimal storage
event BlueprintCreated(
    uint64 indexed blueprintId,
    address indexed owner,
    bytes32 metadataHash,
    address manager
);

event ServiceActivated(
    uint64 indexed serviceId,
    uint64 indexed blueprintId,
    address indexed owner,
    address[] operators,
    bytes32 configHash
);

event JobCalled(
    uint64 indexed serviceId,
    uint8 indexed jobId,
    uint64 callId,
    address caller,
    bytes32 inputsHash  // Full inputs in calldata or IPFS
);

event ResultSubmitted(
    uint64 indexed serviceId,
    uint64 indexed callId,
    address indexed operator,
    bytes32 outputsHash,
    bytes signature
);
```

### Indexer Schema

```graphql
type Blueprint @entity {
  id: ID!
  blueprintId: BigInt!
  owner: Bytes!
  manager: Bytes!
  metadataURI: String!
  operators: [Operator!]! @derivedFrom(field: "blueprints")
  services: [Service!]! @derivedFrom(field: "blueprint")
  createdAt: BigInt!
}

type Service @entity {
  id: ID!
  serviceId: BigInt!
  blueprint: Blueprint!
  owner: Bytes!
  operators: [Bytes!]!
  status: ServiceStatus!
  jobCalls: [JobCall!]! @derivedFrom(field: "service")
}

type JobCall @entity {
  id: ID!
  service: Service!
  jobId: Int!
  callId: BigInt!
  caller: Bytes!
  inputsHash: Bytes!
  results: [JobResult!]! @derivedFrom(field: "jobCall")
}
```

## Security Model

### Trust Assumptions

| Component | Trust Level | Rationale |
|-----------|-------------|-----------|
| L3 Sequencer | Liveness only | Can't forge txs, can censor temporarily |
| Security Manager | High | Controls slashing - audited, timelocked |
| Blueprint Managers | Per-blueprint | Isolated, can't affect other blueprints |
| Operators | Economic | Slashing provides accountability |

### Upgrade Pattern

```solidity
// UUPS Proxy with timelock
contract TangleCore is UUPSUpgradeable, AccessControlUpgradeable {
    uint256 public constant UPGRADE_TIMELOCK = 7 days;

    mapping(bytes32 => uint256) public pendingUpgrades;

    function proposeUpgrade(address newImplementation) external onlyRole(UPGRADER_ROLE) {
        bytes32 id = keccak256(abi.encode(newImplementation));
        pendingUpgrades[id] = block.timestamp + UPGRADE_TIMELOCK;
        emit UpgradeProposed(newImplementation, pendingUpgrades[id]);
    }

    function _authorizeUpgrade(address newImplementation) internal override {
        bytes32 id = keccak256(abi.encode(newImplementation));
        require(pendingUpgrades[id] != 0 && block.timestamp >= pendingUpgrades[id], "Timelock");
        delete pendingUpgrades[id];
    }
}
```

## Gas Optimization Targets

| Operation | Target Gas | Technique |
|-----------|------------|-----------|
| Register blueprint | < 100k | Emit event, store root update |
| Register operator | < 80k | Single storage slot |
| Request service | < 150k | Commitment only |
| Activate service | < 200k | Batch verification |
| Call job | < 50k | Event + minimal state |
| Submit result | < 60k | Signature verification |
| Claim rewards | < 80k | Lazy calculation |
