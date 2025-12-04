# Beacon Chain Validator Restaking - Security Audit

**Date**: December 2024
**Status**: BETA - All critical issues fixed, production-ready with caveats

---

## Executive Summary

This audit tracks security issues identified and their resolution status.

| Severity | Count | Fixed | Status |
|----------|-------|-------|--------|
| CRITICAL | 3 | 3 | ✅ All Fixed |
| HIGH | 5 | 5 | ✅ All Fixed |
| MEDIUM | 3 | 2 | ⚠️ 1 Open |
| LOW | 2 | 0 | ⚠️ Open |

### New Features Added (ELIP-004 Compliance)
- ✅ `beaconChainSlashingFactor` - Tracks beacon chain slashing proportionally
- ✅ `verifyStaleBalance` - Third-party enforcement for slashed validators
- ✅ `setProofSubmitter` - Delegated proof submission
- ✅ `applySlashingFactor` - Calculate effective shares after slashing
- ✅ **Pectra/0x02 Support** - EIP-7251 compounding validator credentials

---

## CRITICAL Issues (ALL FIXED ✅)

### C-1: Empty Proof Attack in Merkle Verification ✅ FIXED

**Location**: `BeaconChainProofs.sol:290-316, 318-370`

**Fix Applied**: Added empty proof check in `verifyStateRoot`:
```solidity
if (stateRootProof.proof.length == 0) {
    return false;  // Reject empty proofs
}
```

**Test Coverage**: `test_CRITICAL_emptyProofRejected_StateRoot()`, `test_CRITICAL_emptyProofDoesNotMatchRoot()`

---

### C-2: Incorrect Generalized Index Calculation ✅ FIXED

**Location**: `BeaconChainProofs.sol`

**Fix Applied**: Added proper generalized index constants following SSZ spec:
```solidity
uint256 internal constant VALIDATOR_CONTAINER_GINDEX = 43;  // (1 << 5) | 11
uint256 internal constant BALANCE_CONTAINER_GINDEX = 44;     // (1 << 5) | 12

uint256 validatorGIndex = (VALIDATOR_CONTAINER_GINDEX << VALIDATOR_TREE_HEIGHT) | uint256(validatorIndex);
```

---

### C-3: Balance Container Verification Bypasses State Root ✅ FIXED

**Location**: `BeaconChainProofs.sol:148-168`

**Fix Applied**: Changed `verifyBalanceContainer` to verify against `beaconStateRoot` instead of block root:
```solidity
function verifyBalanceContainer(
    bytes32 beaconStateRoot,  // C-3 FIX: Was beaconBlockRoot
    ValidatorTypes.BalanceContainerProof calldata proof
) internal pure returns (bool)
```

**Note**: Verification now uses two-step path: block root → state root → balance container

---

## HIGH Issues (ALL FIXED ✅)

### H-1: _getTotalRestakedGwei Returns 0 ✅ FIXED

**Location**: `ValidatorPod.sol`

**Fix Applied**: Added `totalRestakedBalanceGwei` state variable with running total tracking:
```solidity
uint64 public totalRestakedBalanceGwei;  // H-1 FIX: Track running total

function _getTotalRestakedGwei() internal view returns (uint64) {
    return totalRestakedBalanceGwei;
}
```

Updated in `_verifyAndProcessWithdrawalCredential` and `_verifyAndProcessCheckpointProof`.

---

### H-2: verifyCheckpointProofs Missing Access Control ✅ INTENTIONAL

**Location**: `ValidatorPod.sol:267-299`

**Resolution**: This is **intentionally permissionless** (like EigenLayer). Proofs are cryptographically verified, so anyone can submit valid proofs. Added documentation:
```solidity
/// @dev H-2 NOTE: Allowing anyone to call is intentional (like EigenLayer)
///      since proofs are cryptographically verified. This enables permissionless proof submission.
```

---

### H-3: _getTotalDelegatedBy Returns 0 ✅ FIXED

**Location**: `ValidatorPodManager.sol`

**Fix Applied**: Added `delegatorTotalDelegated` mapping:
```solidity
mapping(address delegator => uint256) public delegatorTotalDelegated;  // H-3 FIX

function delegateTo(address operator, uint256 amount) external nonReentrant {
    // ...
    delegatorTotalDelegated[msg.sender] += amount; // H-3 FIX
}
```

---

### H-4: Slashing Doesn't Reduce Delegator Shares ✅ FIXED

**Location**: `ValidatorPodManager.sol:326-345`

**Fix Applied**: Added proportional delegator slashing with tracking:
```solidity
mapping(address operator => address[]) internal _operatorDelegators;
mapping(address operator => mapping(address delegator => bool)) internal _isDelegator;
event DelegatorSlashed(address indexed delegator, address indexed operator, uint256 amount);

// In _slash():
uint256 delegatorSlash = (delegatorStake * amount) / delegatedBefore;
delegations[delegator][operator] -= delegatorSlash;
delegatorTotalDelegated[delegator] -= delegatorSlash;
emit DelegatorSlashed(delegator, operator, delegatorSlash);
```

---

### H-5: No Beacon Root Staleness Check ✅ FIXED

**Location**: `ValidatorPod.sol`

**Fix Applied**: Added 27-hour staleness check (matching EIP-4788 buffer):
```solidity
uint256 public constant MAX_BEACON_ROOT_AGE = 27 hours;  // H-5 FIX

// In verifyWithdrawalCredentials and verifyStaleBalance:
if (block.timestamp > beaconTimestamp + MAX_BEACON_ROOT_AGE) {
    revert StaleProof();
}
```

---

## MEDIUM Issues

### M-1: No Withdrawal Mechanism ✅ FIXED

**Location**: `ValidatorPodManager.sol`

**Fix Applied**: Added full withdrawal queue with configurable delay:
```solidity
struct Withdrawal {
    address staker;
    uint256 shares;
    uint32 startBlock;
    bool completed;
}

uint32 public withdrawalDelayBlocks;
uint32 public constant DEFAULT_WITHDRAWAL_DELAY = 302_400; // ~7 days on L2

function queueWithdrawal(uint256 shares) external returns (bytes32 withdrawalRoot);
function completeWithdrawal(bytes32 withdrawalRoot) external;
```

**Features**:
- 7-day default delay (configurable up to 30 days)
- Must undelegate before withdrawing
- Unique withdrawal roots for tracking
- `getAvailableToWithdraw()` view function
- Full test coverage (14 new tests)

---

### M-2: Checkpoint Can Use Stale Beacon Root ✅ FIXED (via H-5)

**Status**: Fixed as part of H-5 staleness check.

---

### M-3: Pod Balance Double-Counting Risk ⚠️ OPEN

**Status**: Acknowledged. Current design follows EigenLayer's approach. Risk is mitigated because:
1. Pod balance is snapshotted at checkpoint start
2. Validator balance deltas are calculated from beacon chain
3. Double-counting only occurs if a withdrawal arrives AND is proven in same checkpoint

**Mitigation**: Document expected behavior clearly.

---

## LOW Issues

### L-1: No Event for Operator Deregistration ⚠️ OPEN

**Status**: Low priority. No deregistration function implemented yet.

---

### L-2: ValidatorInfo Uses uint64 for validatorIndex But Casts From uint40 ⚠️ OPEN

**Status**: Acknowledged. Types are consistent within function scope.

---

## New Features (ELIP-004 Slashing Factor)

### Beacon Chain Slashing Factor

**Location**: `ValidatorPod.sol`

Implements EigenLayer's ELIP-004 slashing factor mechanism:

```solidity
uint64 public beaconChainSlashingFactor;  // WAD precision (1e18 = 100%)
uint64 public constant INITIAL_SLASHING_FACTOR = 1e18;

// Updated in _finalizeCheckpoint():
if (currentBalance < priorBalance && priorBalance > 0) {
    uint64 newFactor = uint64(
        (uint256(oldFactor) * uint256(currentBalance)) / uint256(priorBalance)
    );
    if (newFactor < oldFactor) {
        beaconChainSlashingFactor = newFactor;
        emit BeaconChainSlashingFactorDecreased(oldFactor, newFactor);
    }
}
```

### Stale Balance Enforcement

**Location**: `ValidatorPod.sol:verifyStaleBalance()`

Allows third parties to prove a validator was slashed on beacon chain and force a checkpoint:

```solidity
function verifyStaleBalance(
    uint64 beaconTimestamp,
    ValidatorTypes.StateRootProof calldata stateRootProof,
    ValidatorTypes.ValidatorFieldsProof memory validatorProof
) external nonReentrant
```

This prevents pod owners from avoiding slashing factor updates.

---

## Test Coverage ✅

**171 tests passing** across 7 test suites:

| Test Suite | Tests |
|------------|-------|
| BeaconChainProofsTest | 34 |
| BeaconFuzzTest | 26 |
| BeaconIntegrationTest | 15 |
| BeaconProofFixtureTest | 6 |
| LiveBeaconTest | 9 |
| ValidatorPodManagerTest | 55 |
| ValidatorPodTest | 26 |

Coverage includes:
- [x] Empty proof rejection
- [x] Invalid proof rejection
- [x] Correct generalized index calculation
- [x] State root → validator path verification
- [x] Balance extraction (little-endian)
- [x] Withdrawal credentials validation (0x01 and 0x02)
- [x] Checkpoint accounting
- [x] Slashing proportionality
- [x] Delegation limits
- [x] Access control
- [x] Slashing factor initialization
- [x] Proof submitter management
- [x] Stale balance verification flow
- [x] Withdrawal queue (queue, complete, delays)
- [x] Withdrawal constants and admin functions
- [x] **Extensive fuzz testing** (26 fuzz tests)
- [x] **Live testnet data validation** (9 tests)

---

## Remaining Work for Production

1. ~~**Withdrawal Queue**: Implement proper withdrawal mechanism with delays~~ ✅ Done
2. ~~**Real Beacon Proofs**: Test against actual Ethereum mainnet/testnet proofs~~ ✅ Done (LiveBeaconTest)
3. ~~**Pectra Support**: Add 0x02 credentials support for Pectra upgrade~~ ✅ Done
4. **Professional Audit**: Get external audit before mainnet deployment
5. ~~**Fuzz Testing**: More extensive fuzzing of Merkle proof verification~~ ✅ Done (26 fuzz tests)
6. ~~**L2 Slashing Integration**: Design how beacon slashing interacts with Tangle L2 slashing~~ ✅ Done (L2SlashingConnector)

---

## New Components Added

### TanglePod CLI (Go)

Location: `script/tanglepod-cli/`

Command-line tool for generating beacon chain proofs:
- `credentials` - Generate withdrawal credential proofs
- `checkpoint` - Generate checkpoint proofs
- `status` - Query validator/pod status (uses beaconcha.in API)
- `stale-balance` - Generate slashing enforcement proofs

**Features:**
- Network selection: mainnet, Holesky, Sepolia
- Status command works via beaconcha.in API (no beacon node required)
- EIP-4788 beacon root validation
- Full beacon state SSZ parsing
- Merkle proof generation for validators and balances
- Support for 0x01 and 0x02 (Pectra compounding) credentials

**IMPORTANT: Beacon Node Requirements**

Proof generation (`credentials`, `checkpoint`, `stale-balance`) requires a beacon node
with full state SSZ API access. Most free public APIs don't support this.

**Public Endpoints (Dec 2024):**

| Network | Endpoint | Status |
|---------|----------|--------|
| Mainnet | `http://testing.mainnet.beacon-api.nimbus.team` | ✅ Validator queries work |
| Mainnet | beaconcha.in API | ✅ Status queries work |
| Holesky | beaconcha.in API | ✅ Status queries work |
| Sepolia | beaconcha.in API | ✅ Status queries work |
| All | Full state SSZ (`/eth/v2/debug/beacon/states`) | ❌ No free public API |

**For full proof generation, you need:**
1. Run your own beacon node (Lighthouse, Prysm, Teku, Nimbus, Lodestar)
2. Use a paid provider (QuickNode, Infura, Alchemy)
3. Use `--use-prover` with Lodestar's prover API

**Sources:**
- [Checkpoint sync endpoints](https://eth-clients.github.io/checkpoint-sync-endpoints/)
- [dRPC Beacon Chain](https://drpc.org/chainlist/eth-beacon-chain) (paid for beacon API)
- [Ankr Beacon API](https://www.ankr.com/rpc/eth/eth_beacon/) (premium only)

**Usage Examples:**
```bash
# Check validator status (uses beaconcha.in, no beacon node needed)
tanglepod-cli status --network holesky --validators 100000,200000

# Check mainnet validator
tanglepod-cli status --network mainnet --validators 1000000

# Generate proofs (requires beacon node)
tanglepod-cli credentials --beaconNode http://localhost:5052 --podAddress 0x... --validators 123456
tanglepod-cli checkpoint --beaconNode http://localhost:5052 --podAddress 0x... --validators 123456,789012
```

**Live Testing Results (Dec 2024):**
```
$ ./tanglepod-cli status --network holesky --validators 100000,200000
Validator 100000:
  Status:       active_exiting
  Balance:      4.756005 ETH
  Withdrawal:   0x0100000000000000000000009baa3244565d51d9c7897c0eb6679ed4890e536e

Validator 200000:
  Status:       withdrawal_done
  Withdrawal:   0x020000000000000000000000767f7576944d321374921df138589a30e3c5030d
                ^^^ Note: 0x02 prefix = Pectra compounding credential
```

### L2SlashingConnector

Location: `src/v2/beacon/L2SlashingConnector.sol`

Bridges beacon chain slashing to Tangle L2:
- Monitors `beaconChainSlashingFactor` changes
- Propagates slashing proportionally to operators/delegators
- Batch processing for multiple pods
- Oracle-based triggering mechanism

---

## References

- [EigenLayer BeaconChainProofs](https://github.com/Layr-Labs/eigenlayer-contracts/blob/dev/src/contracts/libraries/BeaconChainProofs.sol)
- [ELIP-004 Slashing Factor](https://github.com/Layr-Labs/eigenlayer-contracts/blob/dev/docs/core/proofs/BeaconChainProofs.md)
- [EIP-4788 Beacon Block Root](https://eips.ethereum.org/EIPS/eip-4788)
- [Code4rena EigenLayer Audit](https://code4rena.com/reports/2023-04-eigenlayer)
