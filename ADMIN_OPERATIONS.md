# Admin Operations Guide

This document covers administrative operations for the Tangle staking protocol, including asset onboarding, adapter management, and governance workflows.

## Asset Onboarding

### Standard ERC-20 Tokens (No Adapter Required)

For standard ERC-20 tokens like USDC, WETH, wstETH, cbETH, rETH:

```bash
# Using forge script
PRIVATE_KEY=<admin_pk> \
RESTAKING=<MultiAssetDelegation_address> \
ASSET_TOKEN=<token_address> \
MIN_OPERATOR_STAKE=1000000000000000000 \
MIN_DELEGATION=100000000000000000 \
DEPOSIT_CAP=0 \
REWARD_MULTIPLIER_BPS=10000 \
forge script script/AddStakingAsset.s.sol:AddStakingAsset \
  --rpc-url <rpc_url> \
  --broadcast
```

Or via direct contract call:

```solidity
MultiAssetDelegation(restaking).enableAsset(
    tokenAddress,      // ERC-20 token
    minOperatorStake,  // Minimum stake for operators (0 to use global)
    minDelegation,     // Minimum delegation amount
    depositCap,        // 0 for unlimited
    rewardMultiplierBps // 10000 = 1x, 15000 = 1.5x
);
```

### Rebasing Tokens (Adapter Required)

For rebasing tokens like stETH that change balance automatically:

#### Step 1: Deploy AssetAdapterFactory (if not already deployed)

```solidity
AssetAdapterFactory factory = new AssetAdapterFactory(admin);
factory.setDelegationManager(address(multiAssetDelegation));
```

#### Step 2: Deploy Rebasing Adapter

```solidity
// Option A: Use factory
address adapter = factory.deployRebasingAdapter(stETH);

// Option B: Deploy manually
RebasingAssetAdapter adapter = new RebasingAssetAdapter(stETH, admin);
adapter.setDelegationManager(address(multiAssetDelegation));
adapter.transferOwnership(admin);
```

#### Step 3: Register Adapter with MultiAssetDelegation

```solidity
MultiAssetDelegation(restaking).registerAdapter(stETH, adapter);
```

#### Step 4: Enable the Asset

```solidity
MultiAssetDelegation(restaking).enableAssetWithAdapter(
    stETH,
    adapter,
    minOperatorStake,
    minDelegation,
    depositCap,
    rewardMultiplierBps
);
```

## Adapter Types

| Adapter Type | Use Case | Share Behavior |
|--------------|----------|----------------|
| `StandardAssetAdapter` | Normal ERC-20s (wstETH, USDC) | 1:1 shares to assets |
| `RebasingAssetAdapter` | Rebasing tokens (stETH) | Proportional ownership |

### When to Use Each

- **No Adapter**: Standard ERC-20s where balance only changes via transfers
- **StandardAssetAdapter**: When you want consistent adapter interface but 1:1 accounting
- **RebasingAssetAdapter**: Tokens where `balanceOf()` changes without transfers (stETH, aTokens)

## Security Considerations

### Before Deploying an Adapter

1. **Audit the token**: Understand how the token rebases, any fees, transfer restrictions
2. **Test thoroughly**: Use testnet with realistic rebase scenarios
3. **Check decimals**: Ensure adapter handles token decimals correctly
4. **Verify ownership**: Adapter ownership should be transferred to governance/multisig

### Known Risks

1. **First Depositor Attack**: First deposit should be meaningful (not 1 wei)
2. **Donation Attack**: Direct token transfers can skew exchange rates
3. **Approval Target**: Users must approve the ADAPTER, not MultiAssetDelegation

### Recommended Mitigations

- Deploy adapters through factory to ensure consistent setup
- Use timelock for adapter registration in production
- Monitor exchange rates for anomalies
- Set reasonable minimum deposits

## Governance Flow (Production)

For mainnet deployments with governance:

```
1. Submit Proposal
   └─► "Add stETH as staking asset with RebasingAssetAdapter"

2. Community Review (3-7 days)
   └─► Security team audits adapter code
   └─► Community discusses parameters

3. Voting Period (3-7 days)
   └─► Token holders vote

4. Timelock Queue (24-48 hours)
   └─► Proposal queued for execution

5. Execution
   └─► Timelock executes:
       - factory.deployRebasingAdapter(stETH)
       - mad.registerAdapter(stETH, adapter)
       - mad.enableAsset(stETH, params...)
```

## Monitoring

### Key Metrics to Watch

```graphql
# Query adapter status
{
  AssetConfig(where: { token: "0x..." }) {
    enabled
    currentDeposits
    depositCap
    adapter
  }
}
```

### Exchange Rate Monitoring (for rebasing adapters)

```solidity
// Check exchange rate hasn't deviated unexpectedly
uint256 rate = RebasingAssetAdapter(adapter).exchangeRate();
// Should be ~1e18 initially, grows with rebases
```

## Emergency Procedures

### Disable a Compromised Asset

```solidity
// Immediate: Disable new deposits
MultiAssetDelegation(restaking).disableAsset(tokenAddress);

// Note: Existing deposits can still withdraw
```

### Remove a Compromised Adapter

```solidity
// Remove adapter (reverts to direct mode if requireAdapters=false)
MultiAssetDelegation(restaking).removeAdapter(tokenAddress);

// If requireAdapters=true, must register replacement adapter first
```

## Local Testing

### Using LocalTestnet.s.sol

```bash
# Start anvil
anvil --chain-id 31337

# Deploy everything including mock tokens
forge script script/LocalTestnet.s.sol:LocalTestnetSetup \
  --rpc-url http://127.0.0.1:8545 \
  --broadcast

# Mock tokens are auto-enabled without adapters (standard ERC-20s)
```

### Testing Rebasing Behavior

See `test/staking/AssetAdapterTest.t.sol` for examples of:
- Simulating rebases with `MockRebasingToken`
- Testing multi-depositor scenarios
- Verifying share calculations

## Related Scripts

| Script | Purpose |
|--------|---------|
| `script/Deploy.s.sol` | Deploy core contracts |
| `script/AddStakingAsset.s.sol` | Add new asset to whitelist |
| `script/LocalTestnet.s.sol` | Full local dev environment |

## FAQ

**Q: Can users deposit without an adapter?**
A: Yes, if `requireAdapters` is false (default). The deposit goes directly to MultiAssetDelegation.

**Q: What happens if I register an adapter for an existing asset?**
A: New deposits go through the adapter. Existing deposits remain as-is until withdrawn.

**Q: How do users know which contract to approve?**
A: UI should detect if adapter exists and prompt for correct approval target.

**Q: Can I upgrade an adapter?**
A: Not directly. Deploy new adapter, migrate (carefully), update registration.
