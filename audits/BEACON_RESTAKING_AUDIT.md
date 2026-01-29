# Beacon Native Staking Audit: Tangle vs EigenLayer

**Date:** 2026-01-17
**Auditor:** Claude Opus 4.5
**Scope:** Native ETH staking architecture comparison and deployment verification

---

## Executive Summary

Tangle's beacon native staking system is architecturally similar to EigenLayer's EigenPod design with several key differences optimized for L2 deployment. The core cryptographic verification and checkpoint system are sound. However, **critical gaps exist in the deployment scripts** for L2 deployment with L1 beacon chain requirements.

| Category | Status |
|----------|--------|
| Core Architecture | ✅ Sound |
| Proof Verification | ✅ Correct |
| Cross-Chain Messaging | ✅ Multi-bridge support |
| L2 Deployment Scripts | ⚠️ Gaps identified |
| L1 Beacon Deployment | ⚠️ Separate orchestration required |

---

## 1. Architecture Comparison

### 1.1 Pod System

| Component | EigenLayer | Tangle | Notes |
|-----------|------------|--------|-------|
| Pod Contract | EigenPod | ValidatorPod | Functionally equivalent |
| Factory | EigenPodManager | ValidatorPodManager | Similar pattern |
| Deployment | One per user | One per user | Same model |
| Proof Library | BeaconChainProofs | BeaconChainProofs | Same SSZ/Merkle approach |

### 1.2 Withdrawal Credentials

| Feature | EigenLayer | Tangle | Status |
|---------|------------|--------|--------|
| 0x01 prefix (BLS) | ✅ | ✅ | Both supported |
| 0x02 prefix (Pectra) | ✅ | ✅ | C-2 fix added this |
| Credential binding | Pod address | Pod address | Same approach |

**Tangle Implementation (ValidatorPod.sol:~L180):**
```solidity
bytes32 expected0x01 = ValidatorTypes.computeWithdrawalCredentials(address(this));
bytes32 expected0x02 = ValidatorTypes.computeWithdrawalCredentials02(address(this));
if (credentials != expected0x01 && credentials != expected0x02) revert InvalidCredentials();
```

### 1.3 Balance Proof System

| Feature | EigenLayer | Tangle | Notes |
|---------|------------|--------|-------|
| Checkpoint model | ✅ | ✅ | Both use checkpoint-based updates |
| State root verification | Against block root | Against block root | M-11 fix added validation |
| Balance container | Separate proof step | Separate proof step | C-3 fix corrected this |
| Proof staleness | ~27 hours (8191 slots) | ~27 hours (8191 slots) | Same EIP-4788 window |

**Critical Fix Verified (C-3):** Tangle correctly verifies balance container against state root, NOT beacon block root:
```solidity
// Step 1: Verify state root in beacon block
BeaconChainProofs.verifyStateRoot(beaconBlockRoot, stateRootProof);
// Step 2: Verify balance container in state (not block!)
BeaconChainProofs.verifyBalanceContainer(stateRootProof.beaconStateRoot, balanceContainerProof);
```

### 1.4 Slashing Factor

| Feature | EigenLayer | Tangle | Notes |
|---------|------------|--------|-------|
| Name | BCSF (BeaconChainSlashingFactor) | beaconChainSlashingFactor | Same concept |
| Precision | 1e18 (WAD) | 1e18 (WAD) | Same |
| Monotonicity | Decreases only | Decreases only | Correct |
| Formula | `newFactor = oldFactor * currentBalance / priorBalance` | Same | ELIP-004 compliant |

### 1.5 EIP-4788 Integration

| Feature | EigenLayer | Tangle | Notes |
|---------|------------|--------|-------|
| Oracle address | 0x000F3df6D732807Ef1319fB7B8bB8522d0Beac02 | Same | Standard precompile |
| Ring buffer | 8191 slots | 8191 slots | ~27 hours |
| Proof age validation | ✅ | ✅ (M-11 fix) | MAX_PROOF_AGE enforced |

---

## 2. Cross-Chain Architecture (Key Differentiator)

### 2.1 EigenLayer Approach

EigenLayer has **limited L2 support**:
- Core protocol runs on Ethereum mainnet only
- L2 deployments (Base) only support task verification
- No native ETH staking from L2s
- Uses Succinct Labs beacon oracle for off-chain relay

### 2.2 Tangle Approach

Tangle is **designed for L2 deployment** with L1 beacon integration:

```
┌─────────────────────────────────────────────────────────────────┐
│ L1: Ethereum / Holesky                                          │
│                                                                 │
│  EIP4788Oracle (direct precompile access)                       │
│        ↓                                                        │
│  ValidatorPodManager (32 ETH validator stakes)                  │
│        ↓                                                        │
│  L2SlashingConnector (cross-chain dispatcher)                   │
│        ↓                                                        │
│  ICrossChainMessenger (Hyperlane/LayerZero/Arbitrum/Base)       │
└─────────────────────────────────────────────────────────────────┘
                            ↓ (cross-chain message)
┌─────────────────────────────────────────────────────────────────┐
│ L2: Base / Tangle / Arbitrum                                    │
│                                                                 │
│  Bridge Receiver (HyperlaneReceiver/LayerZeroReceiver/etc.)     │
│        ↓                                                        │
│  L2SlashingReceiver (message decoder)                           │
│        ↓                                                        │
│  TangleL2Slasher (slash executor)                               │
│        ↓                                                        │
│  MultiAssetDelegation (restaking layer)                         │
│        ↓                                                        │
│  Tangle (core protocol)                                         │
└─────────────────────────────────────────────────────────────────┘
```

### 2.3 Bridge Support Comparison

| Bridge | EigenLayer | Tangle | Notes |
|--------|------------|--------|-------|
| Arbitrum | ❌ | ✅ | Retryable tickets |
| Base | Limited | ✅ | CrossDomainMessenger |
| Hyperlane | ❌ | ✅ | Mailbox + IGP |
| LayerZero | ❌ | ✅ | V2 Endpoint |

**Tangle Advantage:** Multi-bridge flexibility allows deployment to any EVM L2.

---

## 3. Security Pattern Comparison

### 3.1 Inflation Attack Protection

| Pattern | EigenLayer | Tangle | Notes |
|---------|------------|--------|-------|
| Virtual shares | SHARES_OFFSET = 1e3 | VIRTUAL_SHARES = 1e8 | C-1 fix |
| Virtual assets | BALANCE_OFFSET = 1e3 | VIRTUAL_ASSETS = 1 | C-1 fix |
| First depositor protection | ✅ | ✅ | Both follow ERC4626 pattern |

### 3.2 Replay Protection

| Layer | EigenLayer | Tangle | Notes |
|-------|------------|--------|-------|
| Proof replay | Validator status tracking | Validator status tracking | Same |
| Cross-chain replay | N/A (no cross-chain) | Nonce + processedMessages | Multi-layered |
| Message ID | N/A | keccak256(chainId, sender, payload, nonce) | Per-bridge |

### 3.3 Slashing Proportionality

| Feature | EigenLayer | Tangle | Notes |
|---------|------------|--------|-------|
| Delegator slashing | Via DSF/MM factors | Direct proportional | H-4 fix |
| Self-stake first | ✅ | ✅ | Same pattern |
| Delegator tracking | AllocationManager | `_operatorDelegators` array | H-4 fix added this |

---

## 4. Deployment Script Audit

### 4.1 Current State

The deployment is split across **three separate scripts**:

| Script | Target | Deploys |
|--------|--------|---------|
| FullDeploy.s.sol | L2 | Tangle, MultiAssetDelegation, governance, rewards |
| DeployBeaconSlashing.s.sol | L1 | ValidatorPodManager, L2SlashingConnector, bridges |
| DeployL2Slashing.s.sol | L2 | L2SlashingReceiver, TangleL2Slasher |

### 4.2 Critical Gaps

#### GAP-1: Circular Dependency (HIGH)

**Problem:** L1 deployment requires L2 receiver address, but L2 receiver doesn't exist yet.

**Evidence (DeployBeaconSlashing.s.sol:44-46):**
```solidity
address l2Receiver = vm.envOr("L2_RECEIVER", address(0));
if (!skipChainConfig && l2Receiver == address(0)) {
    revert MissingEnv("L2_RECEIVER");
}
```

**Workaround:** Use `SKIP_CHAIN_CONFIG=true` and run ConfigureL2SlashingConnector after L2 deployment.

**Recommendation:** Document the 4-phase deployment process clearly.

#### GAP-2: No BeaconRootReceiver for L2 (HIGH)

**Problem:** EIP-4788 precompile is NOT available on L2s (Base, Arbitrum, etc.). Tangle has `BeaconRootReceiver.sol` but no deployment script.

**Impact:** ValidatorPod cannot verify proofs if deployed on L2 without beacon root relay.

**Current Code (BeaconRootReceiver.sol exists but unused):**
```solidity
interface IBeaconOracle {
    function getBeaconBlockRoot(uint64 timestamp) external view returns (bytes32);
}
```

**Recommendation:**
1. Deploy ValidatorPodManager on L1 only (current architecture)
2. OR create `DeployBeaconRootRelay.s.sol` for L2 beacon root bridging

#### GAP-3: Missing Unified Orchestration Script (MEDIUM)

**Problem:** No single script deploys the full L1+L2+bridge stack.

**Recommendation:** Create `DeployFullStack.s.sol` that:
1. Deploys L2 core (Tangle + MultiAssetDelegation)
2. Deploys L1 beacon (ValidatorPodManager + Connector)
3. Deploys L2 slashing receiver
4. Wires cross-chain connections
5. Produces unified manifest

#### GAP-4: LocalTestnet Uses MockBeaconOracle (LOW)

**Evidence (LocalTestnet.s.sol:798):**
```solidity
MockBeaconOracle beaconOracle = new MockBeaconOracle();
```

**Impact:** Local testing doesn't exercise real EIP-4788 integration.

**Recommendation:** Add integration tests against Holesky fork.

---

## 5. Deployment Verification

### 5.1 Required Deployment Order

```bash
# Phase 1: L2 Core Protocol
forge script script/FullDeploy.s.sol:FullDeploy \
  --rpc-url $L2_RPC --broadcast
# Outputs: Tangle, MultiAssetDelegation addresses

# Phase 2: L1 Beacon Infrastructure
SKIP_CHAIN_CONFIG=true forge script script/DeployBeaconSlashing.s.sol:DeployBeaconSlashingL1 \
  --rpc-url $L1_RPC --broadcast
# Outputs: ValidatorPodManager, L2SlashingConnector addresses

# Phase 3: L2 Slashing Receiver
RESTAKING=<MultiAssetDelegation> L1_CONNECTOR=<L2SlashingConnector> \
forge script script/DeployL2Slashing.s.sol:DeployL2SlashingHyperlane \
  --rpc-url $L2_RPC --broadcast
# Outputs: L2SlashingReceiver address

# Phase 4: Wire L1→L2
L2_RECEIVER=<L2SlashingReceiver> forge script script/DeployBeaconSlashing.s.sol:ConfigureL2SlashingConnector \
  --rpc-url $L1_RPC --broadcast
```

### 5.2 Bridge Address Verification

The scripts have hardcoded bridge addresses that must be verified:

| Chain | Component | Hardcoded Address | Status |
|-------|-----------|-------------------|--------|
| Holesky | Hyperlane Mailbox | 0x5b6CFf85442B851A8e6eaBd2A4E4507B5135B3B0 | ⚠️ Verify |
| Holesky | Hyperlane IGP | 0x6f2756380FD49228ae25Aa7F2817993cB74Ecc56 | ⚠️ Verify |
| Holesky | LayerZero Endpoint | 0x6EDCE65403992e310A62460808c4b910D972f10f | ⚠️ Verify |
| Base Sepolia | Hyperlane Mailbox | 0x5b6CFf85442B851A8e6eaBd2A4E4507B5135B3B0 | ⚠️ Verify |

**Recommendation:** Add runtime verification that bridge contracts exist and match expected interfaces.

---

## 6. Findings Summary

### Critical

| ID | Finding | Impact | Recommendation |
|----|---------|--------|----------------|
| C-1 | L1↔L2 circular dependency | Cannot deploy without workaround | Document 4-phase process |
| C-2 | No BeaconRootReceiver deployment | L2-only pods can't verify proofs | Keep pods on L1 only |

### High

| ID | Finding | Impact | Recommendation |
|----|---------|--------|----------------|
| H-1 | No unified deployment script | Error-prone manual orchestration | Create DeployFullStack.s.sol |
| H-2 | Bridge addresses unverified at runtime | Could deploy with wrong bridges | Add existence checks |

### Medium

| ID | Finding | Impact | Recommendation |
|----|---------|--------|----------------|
| M-1 | Sepolia/Holesky share LZ endpoint | Potential mainnet misconfiguration | Separate configurations |
| M-2 | No Arbitrum in hardcoded addresses | Arbitrum deployment requires manual setup | Add Arbitrum addresses |
| M-3 | Missing adapters silently fail | requireAdapters=false hides issues | Enable and provide adapters |

### Low

| ID | Finding | Impact | Recommendation |
|----|---------|--------|----------------|
| L-1 | LocalTestnet uses mock oracle | Testing gap | Add Holesky fork tests |
| L-2 | No unified deployment manifest | Hard to audit | Create manifest generator |

---

## 7. Recommendations

### Immediate Actions

1. **Document the 4-phase deployment process** in README or deployment guide
2. **Verify bridge addresses** against official documentation before mainnet
3. **Keep ValidatorPodManager on L1 only** - don't attempt L2 beacon proofs without relay

### Short-term Improvements

4. **Create `DeployFullStack.s.sol`** that orchestrates all phases
5. **Add runtime bridge verification** in deployment scripts
6. **Create deployment manifest** that tracks all addresses across chains

### Long-term Enhancements

7. **Implement BeaconRootRelay** if L2-native beacon proofs are needed
8. **Add Arbitrum bridge addresses** to hardcoded mappings
9. **Create integration tests** against Holesky/Base Sepolia forks

---

## 8. Fixes Applied

The following tactical improvements were made:

### 8.1 Deployment Documentation
- Created `docs/BEACON_DEPLOYMENT.md` with complete 4-phase deployment guide
- Documents all environment variables, bridge addresses, and verification steps

### 8.2 Bridge Contract Verification
Added runtime verification to deployment scripts:
- `script/DeployBeaconSlashing.s.sol` - verifies Hyperlane/LayerZero contracts exist before deployment
- `script/DeployL2Slashing.s.sol` - verifies bridge contracts on L2 before deployment

```solidity
function _verifyBridgeContract(string memory name, address addr) internal view {
    if (addr == address(0)) revert BridgeContractNotFound(name, addr);
    uint256 codeSize;
    assembly { codeSize := extcodesize(addr) }
    if (codeSize == 0) revert BridgeContractNotFound(name, addr);
}
```

### 8.3 Orchestration Script
Created `scripts/deploy-beacon-stack.sh`:
- Automates 4-phase deployment
- Generates manifests for each phase
- Supports both Hyperlane and LayerZero bridges
- Includes dry-run mode for verification

Usage:
```bash
./scripts/deploy-beacon-stack.sh \
  --bridge hyperlane \
  --config deploy/config/base-sepolia.json
```

---

## 9. Conclusion

Tangle's beacon native staking architecture is **fundamentally sound** and correctly implements the EigenLayer-style EigenPod pattern with additional cross-chain capabilities. The core cryptographic verification (withdrawal credentials, balance proofs, slashing factors) is correct following the security audit fixes.

The **primary risk area** is deployment orchestration. The separation of L1 beacon infrastructure from L2 core protocol is architecturally correct but requires careful multi-phase deployment. Teams deploying this should:

1. Follow the 4-phase deployment order strictly
2. Verify all bridge addresses before broadcast
3. Maintain a unified manifest of all deployed addresses
4. Test cross-chain slashing flow end-to-end on testnet

**Overall Assessment:** Ready for testnet deployment with documented orchestration. Mainnet deployment should await bridge address verification and integration testing.
