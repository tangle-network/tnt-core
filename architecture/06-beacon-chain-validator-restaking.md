# Beacon Chain Validator Restaking Implementation Plan

## Executive Summary

This document outlines the implementation of **Ethereum Beacon Chain Native Restaking** for Tangle Protocol deployed on **Base L2** (or any OP Stack L2 like Tempo). Ethereum validators can restake their ETH by pointing their withdrawal credentials to Tangle's ValidatorPod contracts.

**Architecture**: Minimal L1 footprint (beacon root relay only) + Full L2 deployment

**Key Difference from Current "Native Restaking":**
- **Current**: Direct smart contract deposits of L2 native tokens
- **New**: Ethereum mainnet validators restaking their 32 ETH via withdrawal credential proofs

---

## 0. Deployment Architecture (Base L2 / OP Stack)

```
┌─────────────────────────────────────────────────────────────────┐
│                   ETHEREUM MAINNET                               │
│                                                                  │
│  ┌──────────────┐    ┌─────────────────────────────────────┐   │
│  │  EIP-4788    │───▶│      BeaconRootRelayer.sol          │   │
│  │  Precompile  │    │      (~50 lines, minimal gas)       │   │
│  └──────────────┘    └──────────────┬──────────────────────┘   │
│                                     │                           │
│                      OP Stack Canonical Bridge                  │
│                      (L1CrossDomainMessenger)                   │
└─────────────────────────────────────┼───────────────────────────┘
                                      │ Trust: Inherits L2 security
                                      ▼
┌─────────────────────────────────────────────────────────────────┐
│                   BASE L2 / TEMPO / OP STACK                     │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │           BeaconRootReceiver.sol (IBeaconOracle)         │   │
│  │           Receives roots via L2CrossDomainMessenger      │   │
│  └───────────────────────────┬─────────────────────────────┘   │
│                              │                                   │
│  ┌───────────────────────────▼─────────────────────────────┐   │
│  │              BeaconChainProofs.sol                       │   │
│  │              Merkle proof verification library           │   │
│  └───────────────────────────┬─────────────────────────────┘   │
│                              │                                   │
│  ┌───────────────────────────▼─────────────────────────────┐   │
│  │    ValidatorPodManager.sol (Factory + IRestaking)        │   │
│  │    ├── createPod() - Deploy user's ValidatorPod          │   │
│  │    ├── recordBeaconChainEthBalanceUpdate()               │   │
│  │    └── Implements IRestaking for Tangle integration      │   │
│  └───────────────────────────┬─────────────────────────────┘   │
│                              │                                   │
│  ┌───────────────────────────▼─────────────────────────────┐   │
│  │              ValidatorPod.sol (per-user)                 │   │
│  │    ├── verifyWithdrawalCredentials()                     │   │
│  │    ├── startCheckpoint() / verifyCheckpointProofs()      │   │
│  │    └── One pod per staker, multiple validators per pod   │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                  │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │         Tangle Core + MultiAssetDelegation               │   │
│  │         (Existing v2 contracts, unchanged)               │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

### Trust Model

**No additional trust assumptions beyond being on Base/OP Stack:**
- EIP-4788 is native to Ethereum (trustless)
- OP Stack canonical bridge inherits L2 security guarantees
- If you trust Base, you trust the beacon root relay

### Latency Considerations

| Operation | Latency | Acceptable? |
|-----------|---------|-------------|
| Beacon root relay | ~7 days (challenge period) | ✅ Validators don't change credentials often |
| Credential verification | After root arrives | ✅ One-time per validator |
| Checkpoint proofs | Every ~2 weeks recommended | ✅ Batching saves gas |

---

## 1. Background: How EigenLayer Native Restaking Works

### 1.1 Withdrawal Credentials Overview

Ethereum validators have immutable withdrawal credentials:
- **0x00 (BLS)**: Legacy format, can be changed once to 0x01
- **0x01 (Execution)**: Points to an Ethereum address, immutable once set

For native restaking, validators change their withdrawal credentials to point to a **ValidatorPod** smart contract.

### 1.2 EigenLayer Architecture

```
                    ┌─────────────────────┐
                    │   Beacon Chain      │
                    │   (Consensus Layer) │
                    └──────────┬──────────┘
                               │
                    ┌──────────▼──────────┐
                    │   EIP-4788 Oracle   │
                    │  (beacon_roots())   │
                    └──────────┬──────────┘
                               │
     ┌─────────────────────────▼─────────────────────────┐
     │              BeaconChainProofs.sol                 │
     │  - verifyStateRoot()                              │
     │  - verifyValidatorFields()                        │
     │  - verifyValidatorBalance()                       │
     │  - verifyBalanceContainer()                       │
     └─────────────────────────┬─────────────────────────┘
                               │
     ┌─────────────────────────▼─────────────────────────┐
     │                  EigenPod.sol                      │
     │  - verifyWithdrawalCredentials()                  │
     │  - startCheckpoint() / verifyCheckpointProofs()   │
     │  - withdrawNonBeaconChainEth()                    │
     └─────────────────────────┬─────────────────────────┘
                               │
     ┌─────────────────────────▼─────────────────────────┐
     │              EigenPodManager.sol                   │
     │  - createPod() / stake()                          │
     │  - recordBeaconChainEthBalanceUpdate()            │
     │  - podOwnerShares tracking                        │
     └───────────────────────────────────────────────────┘
```

### 1.3 Key Proof Types

1. **Withdrawal Credential Proof**: Proves validator exists and points to the pod
2. **Balance Proof**: Proves validator's current balance
3. **Checkpoint Proof**: Batch updates validator balances

### 1.4 Merkle Tree Structure (Beacon State)

```
Beacon Block Root
    └── Beacon State Root (BEACON_BLOCK_HEADER_TREE_HEIGHT = 3)
            ├── validators[i] (VALIDATOR_TREE_HEIGHT = 40)
            │       ├── pubkey (index 0)
            │       ├── withdrawal_credentials (index 1)
            │       ├── effective_balance (index 2)
            │       ├── slashed (index 3)
            │       ├── activation_eligibility_epoch (index 4)
            │       ├── activation_epoch (index 5)
            │       ├── exit_epoch (index 6)
            │       └── withdrawable_epoch (index 7)
            └── balances[i] (BALANCE_TREE_HEIGHT = 38)
```

---

## 2. Tangle Implementation Design

### 2.1 New Module Structure

```
src/v2/beacon/
├── BeaconChainProofs.sol       # Merkle proof verification library
├── ValidatorPod.sol            # Per-user pod (like EigenPod)
├── ValidatorPodManager.sol     # Factory + share accounting
├── IBeaconOracle.sol           # Beacon root oracle interface
├── MockBeaconOracle.sol        # For testing (simulates EIP-4788)
└── ValidatorTypes.sol          # Beacon-specific types

test/v2/beacon/
├── BeaconChainProofsTest.t.sol # Unit tests for proof library
├── ValidatorPodTest.t.sol      # Pod functionality tests
├── ValidatorPodManagerTest.t.sol
├── BeaconTestHarness.sol       # Test utilities
├── ProofGenerator.sol          # Generate test proofs
└── fixtures/                   # Pre-generated proof fixtures
    ├── validator_proofs.json
    └── balance_proofs.json
```

### 2.2 Integration with Existing System

The beacon chain module will implement `IRestaking`, allowing it to plug into Tangle's existing infrastructure:

```solidity
// ValidatorPodManager implements IRestaking
contract ValidatorPodManager is IRestaking {
    // Operator queries delegate to underlying pod shares
    function getOperatorStake(address operator) external view returns (uint256) {
        return _podOwnerShares[operator] + _operatorDelegations[operator];
    }

    // Slashing reduces pod shares
    function slash(...) external returns (uint256) {
        // Reduce podOwnerShares for the operator
        // Propagates to all validators in that operator's pods
    }
}
```

---

## 3. Contract Specifications

### 3.1 BeaconChainProofs.sol

```solidity
library BeaconChainProofs {
    // ═══════════════════════════════════════════════════════════════
    // CONSTANTS
    // ═══════════════════════════════════════════════════════════════

    // Validator field indices
    uint256 constant VALIDATOR_PUBKEY_INDEX = 0;
    uint256 constant VALIDATOR_WITHDRAWAL_CREDENTIALS_INDEX = 1;
    uint256 constant VALIDATOR_EFFECTIVE_BALANCE_INDEX = 2;
    uint256 constant VALIDATOR_SLASHED_INDEX = 3;
    uint256 constant VALIDATOR_ACTIVATION_EPOCH_INDEX = 5;
    uint256 constant VALIDATOR_EXIT_EPOCH_INDEX = 6;

    // Tree heights
    uint256 constant BEACON_BLOCK_HEADER_TREE_HEIGHT = 3;
    uint256 constant BEACON_STATE_TREE_HEIGHT = 5; // Deneb
    uint256 constant VALIDATOR_TREE_HEIGHT = 40;
    uint256 constant BALANCE_TREE_HEIGHT = 38;

    // ═══════════════════════════════════════════════════════════════
    // STRUCTS
    // ═══════════════════════════════════════════════════════════════

    struct StateRootProof {
        bytes32 beaconStateRoot;
        bytes proof; // Against beacon block root
    }

    struct ValidatorFieldsProof {
        bytes32[] validatorFields;  // 8 fields
        bytes proof;                // Against beacon state root
    }

    struct BalanceContainerProof {
        bytes32 balanceContainerRoot;
        bytes proof;
    }

    struct BalanceProof {
        bytes32 pubkeyHash;
        bytes32 balanceRoot;
        bytes proof;
    }

    // ═══════════════════════════════════════════════════════════════
    // VERIFICATION FUNCTIONS
    // ═══════════════════════════════════════════════════════════════

    /// @notice Verify beacon state root against beacon block root
    function verifyStateRoot(
        bytes32 beaconBlockRoot,
        StateRootProof calldata proof
    ) internal pure returns (bool);

    /// @notice Verify validator fields against beacon state root
    function verifyValidatorFields(
        bytes32 beaconStateRoot,
        uint40 validatorIndex,
        ValidatorFieldsProof calldata proof
    ) internal pure returns (bool);

    /// @notice Verify validator balance against balance container
    function verifyValidatorBalance(
        bytes32 balanceContainerRoot,
        uint40 validatorIndex,
        BalanceProof calldata proof
    ) internal pure returns (uint64 balance);

    // ═══════════════════════════════════════════════════════════════
    // FIELD EXTRACTORS
    // ═══════════════════════════════════════════════════════════════

    function getPubkeyHash(bytes32[] calldata fields) internal pure returns (bytes32);
    function getWithdrawalCredentials(bytes32[] calldata fields) internal pure returns (bytes32);
    function getEffectiveBalance(bytes32[] calldata fields) internal pure returns (uint64);
    function getActivationEpoch(bytes32[] calldata fields) internal pure returns (uint64);
    function getExitEpoch(bytes32[] calldata fields) internal pure returns (uint64);
    function isValidatorSlashed(bytes32[] calldata fields) internal pure returns (bool);
}
```

### 3.2 ValidatorPod.sol

```solidity
contract ValidatorPod {
    // ═══════════════════════════════════════════════════════════════
    // STATE
    // ═══════════════════════════════════════════════════════════════

    address public immutable podOwner;
    ValidatorPodManager public immutable podManager;
    IBeaconOracle public immutable beaconOracle;

    bool public hasRestaked;  // True after first successful credential verification

    // Validator tracking
    mapping(bytes32 pubkeyHash => ValidatorInfo) public validatorInfo;
    uint256 public activeValidatorCount;

    // Checkpoint state
    Checkpoint public currentCheckpoint;
    uint64 public lastCheckpointTimestamp;

    struct ValidatorInfo {
        uint64 validatorIndex;
        uint64 restakedBalanceGwei;
        uint64 lastCheckpointedAt;
        ValidatorStatus status;
    }

    enum ValidatorStatus {
        INACTIVE,           // Not yet verified
        ACTIVE,             // Verified and restaked
        WITHDRAWN           // Fully exited
    }

    struct Checkpoint {
        bytes32 beaconBlockRoot;
        uint24 proofsRemaining;
        uint64 podBalanceGwei;
        int128 balanceDeltasGwei;
        uint64 prevBeaconBalanceGwei;
    }

    // ═══════════════════════════════════════════════════════════════
    // CORE FUNCTIONS
    // ═══════════════════════════════════════════════════════════════

    /// @notice Verify withdrawal credentials for validators
    /// @dev First step - prove validators point to this pod
    function verifyWithdrawalCredentials(
        uint64 beaconTimestamp,
        BeaconChainProofs.StateRootProof calldata stateRootProof,
        uint40[] calldata validatorIndices,
        bytes[] calldata validatorFieldsProofs,
        bytes32[][] calldata validatorFields
    ) external;

    /// @notice Start a checkpoint to prove current validator balances
    function startCheckpoint(bool revertIfNoBalance) external;

    /// @notice Verify checkpoint proofs for validators
    function verifyCheckpointProofs(
        BeaconChainProofs.BalanceContainerProof calldata balanceContainerProof,
        BeaconChainProofs.BalanceProof[] calldata proofs
    ) external;

    /// @notice Withdraw ETH that was sent to pod outside beacon chain
    function withdrawNonBeaconChainEth(address recipient, uint256 amount) external;

    /// @notice Recover ERC20 tokens sent to pod by mistake
    function recoverTokens(IERC20 token, address recipient, uint256 amount) external;

    // ═══════════════════════════════════════════════════════════════
    // VIEW FUNCTIONS
    // ═══════════════════════════════════════════════════════════════

    function getValidatorInfo(bytes32 pubkeyHash) external view returns (ValidatorInfo memory);
    function getTotalRestakedGwei() external view returns (uint64);
    function withdrawableRestakedGwei() external view returns (uint64);
}
```

### 3.3 ValidatorPodManager.sol

```solidity
contract ValidatorPodManager is IRestaking, Ownable {
    // ═══════════════════════════════════════════════════════════════
    // STATE
    // ═══════════════════════════════════════════════════════════════

    IBeaconOracle public beaconOracle;

    // Pod registry
    mapping(address owner => address pod) public ownerToPod;
    mapping(address pod => address owner) public podToOwner;

    // Share accounting (similar to MultiAssetDelegation but for beacon ETH)
    mapping(address owner => int256) public podOwnerShares;

    // Delegation to operators (optional - pod owners can delegate)
    mapping(address delegator => mapping(address operator => uint256)) public delegations;
    mapping(address operator => uint256) public operatorDelegatedStake;

    // Slashing
    mapping(address => bool) public isSlasher;

    // ═══════════════════════════════════════════════════════════════
    // POD MANAGEMENT
    // ═══════════════════════════════════════════════════════════════

    /// @notice Create a new ValidatorPod for the caller
    function createPod() external returns (address pod);

    /// @notice Stake ETH through the pod (sent to beacon deposit contract)
    /// @dev For new validators - not needed if validator already exists
    function stake(
        bytes calldata pubkey,
        bytes calldata signature,
        bytes32 depositDataRoot
    ) external payable;

    /// @notice Get or create pod for an address
    function getPod(address owner) external returns (address);

    // ═══════════════════════════════════════════════════════════════
    // SHARE MANAGEMENT (called by pods)
    // ═══════════════════════════════════════════════════════════════

    /// @notice Record balance update from pod verification
    /// @dev Called by ValidatorPod after credential/checkpoint verification
    function recordBeaconChainEthBalanceUpdate(
        address podOwner,
        int256 sharesDelta
    ) external onlyPod;

    // ═══════════════════════════════════════════════════════════════
    // DELEGATION (pod owners can delegate to operators)
    // ═══════════════════════════════════════════════════════════════

    /// @notice Delegate beacon chain ETH shares to an operator
    function delegateTo(address operator, uint256 shares) external;

    /// @notice Undelegate from operator
    function undelegate(address operator, uint256 shares) external;

    // ═══════════════════════════════════════════════════════════════
    // IRESTAKING IMPLEMENTATION
    // ═══════════════════════════════════════════════════════════════

    function isOperator(address operator) external view returns (bool);
    function getOperatorStake(address operator) external view returns (uint256);
    function slashForBlueprint(...) external returns (uint256);
    function slash(...) external returns (uint256);
}
```

### 3.4 IBeaconOracle.sol

```solidity
interface IBeaconOracle {
    /// @notice Get beacon block root for a given timestamp
    /// @dev On mainnet, uses EIP-4788 precompile at 0x000F3df6D732807Ef1319fB7B8bB8522d0Beac02
    function getBeaconBlockRoot(uint64 timestamp) external view returns (bytes32);

    /// @notice Check if oracle has root for timestamp
    function hasBeaconBlockRoot(uint64 timestamp) external view returns (bool);
}

/// @notice EIP-4788 compatible oracle (mainnet)
contract EIP4788Oracle is IBeaconOracle {
    address constant BEACON_ROOTS = 0x000F3df6D732807Ef1319fB7B8bB8522d0Beac02;

    function getBeaconBlockRoot(uint64 timestamp) external view returns (bytes32) {
        (bool success, bytes memory data) = BEACON_ROOTS.staticcall(abi.encode(timestamp));
        require(success && data.length == 32, "Invalid beacon root");
        return abi.decode(data, (bytes32));
    }
}

/// @notice Mock oracle for testing and L2/L3 deployments
contract MockBeaconOracle is IBeaconOracle, Ownable {
    mapping(uint64 timestamp => bytes32 root) public roots;

    function setBeaconBlockRoot(uint64 timestamp, bytes32 root) external onlyOwner {
        roots[timestamp] = root;
    }

    function getBeaconBlockRoot(uint64 timestamp) external view returns (bytes32) {
        return roots[timestamp];
    }
}
```

---

## 4. Test Strategy

### 4.1 Unit Tests

```solidity
// test/v2/beacon/BeaconChainProofsTest.t.sol
contract BeaconChainProofsTest is Test {
    // Test Merkle proof verification
    function test_verifyStateRoot_validProof() external;
    function test_verifyStateRoot_invalidProof_reverts() external;
    function test_verifyValidatorFields_validProof() external;
    function test_verifyValidatorBalance_extractsCorrectBalance() external;

    // Test field extraction
    function test_getWithdrawalCredentials() external;
    function test_getEffectiveBalance() external;
    function test_isValidatorSlashed() external;
}

// test/v2/beacon/ValidatorPodTest.t.sol
contract ValidatorPodTest is Test {
    // Credential verification
    function test_verifyWithdrawalCredentials_setsValidatorActive() external;
    function test_verifyWithdrawalCredentials_wrongPod_reverts() external;
    function test_verifyWithdrawalCredentials_duplicateValidator_reverts() external;

    // Checkpoints
    function test_startCheckpoint_snapshotsBalance() external;
    function test_verifyCheckpointProofs_updatesBalances() external;
    function test_checkpoint_detectsSlashing() external;

    // Withdrawals
    function test_withdrawNonBeaconChainEth_onlyOwner() external;
}
```

### 4.2 Integration Tests

```solidity
// test/v2/beacon/ValidatorRestakingE2E.t.sol
contract ValidatorRestakingE2ETest is Test {
    function test_fullRestakingFlow() external {
        // 1. Create pod
        // 2. Verify withdrawal credentials
        // 3. Start checkpoint
        // 4. Verify checkpoint proofs
        // 5. Delegate to operator
        // 6. Operator joins blueprint
        // 7. Slashing reduces shares
    }

    function test_multipleValidatorsSamePod() external;
    function test_validatorExitAndWithdraw() external;
}
```

### 4.3 EigenLayer Test Primitive Ports

Port key test utilities from EigenLayer:

```solidity
// test/v2/beacon/BeaconTestHarness.sol
contract BeaconTestHarness is Test {
    using BeaconChainProofs for *;

    // Proof generation utilities (adapted from eigenpod-proofs-generation)
    function generateWithdrawalCredentialProof(
        bytes32 beaconStateRoot,
        uint40 validatorIndex,
        bytes32 withdrawalCredentials
    ) internal returns (bytes memory proof, bytes32[] memory validatorFields);

    function generateBalanceProof(
        bytes32 balanceContainerRoot,
        uint40 validatorIndex,
        uint64 balance
    ) internal returns (bytes memory proof);

    // Mock beacon state generation
    function createMockBeaconState(
        ValidatorData[] memory validators
    ) internal returns (bytes32 stateRoot, bytes32 blockRoot);
}
```

---

## 5. Separation from Existing Protocol

### 5.1 No Changes to Core Contracts

The beacon chain module is **completely separate**:
- New directory: `src/v2/beacon/`
- New test directory: `test/v2/beacon/`
- Does NOT modify `MultiAssetDelegation.sol`
- Does NOT modify `Tangle.sol`

### 5.2 Optional Integration Points

If/when ready to integrate:

```solidity
// Option 1: Register ValidatorPodManager as an IRestaking implementation
tangle.setRestakingModule(address(validatorPodManager));

// Option 2: Use alongside MultiAssetDelegation
// Operators can have stake from both:
// - MultiAssetDelegation (direct deposits)
// - ValidatorPodManager (beacon chain validators)
```

---

## 6. Implementation Phases

### Phase 1: Core Infrastructure
- [ ] `BeaconChainProofs.sol` - Merkle verification library
- [ ] `ValidatorTypes.sol` - Type definitions
- [ ] `IBeaconOracle.sol` + `MockBeaconOracle.sol`
- [ ] Unit tests for proof verification

### Phase 2: Pod Contracts
- [ ] `ValidatorPod.sol` - Core pod functionality
- [ ] `ValidatorPodManager.sol` - Factory and share tracking
- [ ] Integration tests

### Phase 3: IRestaking Implementation
- [ ] Implement IRestaking interface on ValidatorPodManager
- [ ] Delegation mechanics
- [ ] Slashing integration

### Phase 4: Test Suite Completion
- [ ] Port EigenLayer test primitives
- [ ] Fuzz tests
- [ ] E2E integration tests

---

## 7. Key Differences from EigenLayer

| Aspect | EigenLayer | Tangle Implementation |
|--------|------------|----------------------|
| Deployment | Mainnet only | L2/L3 via oracle bridge |
| Oracle | EIP-4788 native | Pluggable (mock for testing) |
| Share System | DelegationManager | IRestaking interface |
| Slashing | Via slasher contracts | Via Tangle core |
| Integration | Standalone | Plugs into blueprint system |

---

## 8. Security Considerations

1. **Proof Verification**: SHA256 merkle proofs must be gas-efficient
2. **Oracle Trust**: Mock oracle requires trusted operator for L2/L3
3. **Re-entrancy**: Pod withdrawals must be protected
4. **Share Accounting**: Balance deltas can be negative (slashing)
5. **Checkpoint Timing**: Prevent griefing via excessive checkpoints

---

## 9. Gas Optimization Notes

1. Use `sha256` precompile for merkle verification (cheaper than keccak)
2. Batch validator proofs in single transaction
3. Checkpoint proofs should be batched (EigenLayer recommends every 2 weeks)
4. Consider calldata compression for proofs

---

## 10. References

- [EigenLayer Native Restaking Guide](https://medium.com/@jenpaff/eigenlayer-native-restaking-under-the-hood-an-in-depth-guide-to-native-restaking-on-eigenlayer-70b5ae6d9e55)
- [EigenLayer Contracts (Layr-Labs)](https://github.com/Layr-Labs/eigenlayer-contracts)
- [EigenPod Documentation](https://docs.eigenlayer.xyz/restaking-guides/restaking-user-guide/native-restaking/)
- [EIP-4788: Beacon Block Root in EVM](https://eips.ethereum.org/EIPS/eip-4788)
- [Beacon Chain Spec](https://github.com/ethereum/consensus-specs)
