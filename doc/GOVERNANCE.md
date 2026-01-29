# Tangle Governance

## Architecture

```
TNT Token (ERC20Votes)
       ↓
TangleGovernor
       ↓
TangleTimelock (holds protocol roles)
       ↓
Tangle.sol / MultiAssetDelegation.sol
```

## Contracts

| Contract | Path | Purpose |
|----------|------|---------|
| TangleToken | `src/governance/TangleToken.sol` | TNT governance token with ERC20Votes |
| TangleGovernor | `src/governance/TangleGovernor.sol` | On-chain voting and proposal management |
| TangleTimelock | `src/governance/TangleTimelock.sol` | Execution delay, holds protocol roles |
| GovernanceDeployer | `src/governance/GovernanceDeployer.sol` | Deployment helper |

## Parameters

### Mainnet (Recommended)

| Parameter | Value |
|-----------|-------|
| Initial Supply | 50M TNT |
| Max Supply | ~109.26M TNT (snapshot cap) |
| Timelock Delay | 2 days |
| Voting Delay | 7200 blocks (~1 day) |
| Voting Period | 50400 blocks (~1 week) |
| Proposal Threshold | 100,000 TNT |
| Quorum | 4% of supply |

### Testnet

| Parameter | Value |
|-----------|-------|
| Timelock Delay | 1 day |
| Voting Delay | 100 blocks |
| Voting Period | 1000 blocks |
| Proposal Threshold | 1,000 TNT |
| Quorum | 1% |

## Roles & Powers

### Role Hierarchy

`DEFAULT_ADMIN_ROLE` (bytes32(0)) is the root role on all contracts. Whoever holds this role can:
- Grant any role to any address
- Revoke any role from any address
- Transfer the DEFAULT_ADMIN_ROLE itself

For full decentralization, governance (timelock) should hold DEFAULT_ADMIN_ROLE on all contracts.

### Tangle.sol

| Role | Controls |
|------|----------|
| DEFAULT_ADMIN_ROLE | Grant/revoke all roles |
| ADMIN_ROLE | `setPaymentSplit()`, `setTreasury()`, `setSlashConfig()` |
| PAUSER_ROLE | `pause()`, `unpause()` |
| UPGRADER_ROLE | UUPS contract upgrades |
| SLASH_ADMIN_ROLE | `cancelSlash()`, `disputeSlash()` override |

### MultiAssetDelegation.sol

| Role | Controls |
|------|----------|
| DEFAULT_ADMIN_ROLE | Grant/revoke all roles |
| ADMIN_ROLE | `addSlasher()`, `removeSlasher()`, `setOperatorCommission()`, `setDelays()`, `pause()`, `unpause()`, upgrades |
| ASSET_MANAGER_ROLE | `enableAsset()`, `disableAsset()` - controls which tokens can be staked/used for payments |
| SLASHER_ROLE | `slash()` execution |

### TangleToken.sol

| Role | Controls |
|------|----------|
| DEFAULT_ADMIN_ROLE | Grant/revoke all roles |
| MINTER_ROLE | `mint()` (capped at 100M) |
| UPGRADER_ROLE | UUPS contract upgrades |

## Deployment

```solidity
GovernanceDeployer deployer = new GovernanceDeployer();

GovernanceDeployer.DeployParams memory params = deployer.getDefaultMainnetParams(admin);
// or: deployer.getDefaultTestnetParams(admin);

GovernanceDeployer.DeployedContracts memory c = deployer.deployGovernance(params);
// c.token, c.timelock, c.governor

// To reuse an existing TNT deployment, set:
// params.existingToken = 0xYourTNT;
// params.initialTokenSupply = 0;
```

## Role Transfer to Governance

### Using GovernanceDeployer (Recommended)

```solidity
GovernanceDeployer deployer = new GovernanceDeployer();

// Get all roles for each contract (includes DEFAULT_ADMIN_ROLE)
bytes32[] memory tangleRoles = deployer.getTangleRoles();
bytes32[] memory madRoles = deployer.getMultiAssetDelegationRoles();
bytes32[] memory tokenRoles = deployer.getTokenRoles();

// Full transfer with optional revocation from original admin
deployer.transferFullControl(timelock, address(tangle), tangleRoles, admin);
deployer.transferFullControl(timelock, address(multiAssetDelegation), madRoles, admin);
deployer.transferFullControl(timelock, address(tangleToken), tokenRoles, admin);
```

### Manual Transfer

```solidity
bytes32 DEFAULT_ADMIN = bytes32(0);

// Grant DEFAULT_ADMIN_ROLE first (enables role management)
tangle.grantRole(DEFAULT_ADMIN, timelock);
multiAssetDelegation.grantRole(DEFAULT_ADMIN, timelock);
tangleToken.grantRole(DEFAULT_ADMIN, timelock);

// Grant operational roles
tangle.grantRole(keccak256("ADMIN_ROLE"), timelock);
tangle.grantRole(keccak256("PAUSER_ROLE"), timelock);
tangle.grantRole(keccak256("UPGRADER_ROLE"), timelock);
tangle.grantRole(keccak256("SLASH_ADMIN_ROLE"), timelock);

multiAssetDelegation.grantRole(keccak256("ADMIN_ROLE"), timelock);
multiAssetDelegation.grantRole(keccak256("ASSET_MANAGER_ROLE"), timelock);

tangleToken.grantRole(keccak256("MINTER_ROLE"), timelock);
tangleToken.grantRole(keccak256("UPGRADER_ROLE"), timelock);

// Revoke from admin for full decentralization (optional)
tangle.renounceRole(DEFAULT_ADMIN, admin);
// ... etc
```

### Governance-Managed Role Assignment

Once timelock has DEFAULT_ADMIN_ROLE, governance can assign roles via proposals:

```solidity
// Proposal to grant ASSET_MANAGER_ROLE to a new address
targets[0] = address(multiAssetDelegation);
calldatas[0] = abi.encodeCall(
    IAccessControl.grantRole,
    (keccak256("ASSET_MANAGER_ROLE"), newAssetManager)
);
governor.propose(targets, values, calldatas, "Grant ASSET_MANAGER to newAssetManager");
```

## Proposal Lifecycle

1. **Propose** - Holder with ≥threshold tokens creates proposal
2. **Delay** - Wait `votingDelay` blocks
3. **Vote** - `votingPeriod` blocks to vote (For/Against/Abstain)
4. **Succeed/Defeat** - Passes if For > Against AND quorum met
5. **Queue** - Successful proposals queued in timelock
6. **Wait** - `timelockDelay` before execution
7. **Execute** - Anyone can execute after delay

## Voting

```solidity
// Delegate to self (required to vote)
token.delegate(msg.sender);

// Vote on proposal
governor.castVote(proposalId, 1); // 0=Against, 1=For, 2=Abstain

// Vote with reason
governor.castVoteWithReason(proposalId, 1, "Reason here");
```

## Creating Proposals

```solidity
address[] memory targets = new address[](1);
uint256[] memory values = new uint256[](1);
bytes[] memory calldatas = new bytes[](1);

targets[0] = address(tangle);
values[0] = 0;
calldatas[0] = abi.encodeCall(tangle.setTreasury, (newTreasury));

uint256 proposalId = governor.propose(targets, values, calldatas, "Update treasury");
```

## Executing Proposals

```solidity
bytes32 descHash = keccak256(bytes("Update treasury"));

// After voting succeeds
governor.queue(targets, values, calldatas, descHash);

// After timelock delay
governor.execute(targets, values, calldatas, descHash);
```

## Emergency Actions

Timelock can be bypassed only if admin roles are retained separately. For full decentralization, all admin roles should be held exclusively by the timelock.

For emergency response with decentralized governance:
1. Create expedited proposal
2. Rally community vote
3. Wait minimum timelock delay (1 day minimum)

## Upgrading Governance

Governor and Timelock are UUPS upgradeable:
- Governor upgrades require governance approval (`onlyGovernance`)
- Timelock upgrades require self-call (via governance proposal)
- Token upgrades require UPGRADER_ROLE

## Multi-Asset Management

Governance controls which assets can be used for staking and payments via `ASSET_MANAGER_ROLE`.

### Enabling New Assets

```solidity
// Proposal to enable a new ERC20 for staking
targets[0] = address(multiAssetDelegation);
calldatas[0] = abi.encodeCall(
    MultiAssetDelegation.enableAsset,
    (
        newTokenAddress,
        1000 ether,  // minOperatorStake
        100 ether,   // minDelegation
        0,           // depositCap (0 = unlimited)
        10000        // rewardMultiplierBps (100% = 10000)
    )
);
governor.propose(targets, values, calldatas, "Enable NEW_TOKEN for staking");
```

### Disabling Assets

```solidity
targets[0] = address(multiAssetDelegation);
calldatas[0] = abi.encodeCall(
    MultiAssetDelegation.disableAsset,
    (tokenAddress)
);
```

### TNT as Primary Token

TNT (governance token) can be enabled as a staking asset, making it the primary token in the ecosystem:

```solidity
// Enable TNT for staking with favorable parameters
multiAssetDelegation.enableAsset(
    address(tangleToken),
    10000 * 1e18,  // 10k TNT min operator stake
    1000 * 1e18,   // 1k TNT min delegation
    0,             // no cap
    12000          // 120% reward multiplier (bonus for TNT stakers)
);
```

## TNT Incentives (Rewards System)

Separate from payment distribution, TNT incentives are distributed from a pre-funded InflationPool to reward protocol participants. This architecture isolates token risk from protocol risk - even if protocol contracts have bugs, attackers cannot mint unlimited tokens.

### Architecture

```
Governance (TangleTimelock)
       ↓ funds via proposal
InflationPool (pre-funded)
       ↓ distributes per epoch
TangleMetrics (lightweight recorder)
       ↓ records events
RewardVaults (receives transfers)
       ↓ distributes to users
```

### Contracts

| Contract | Path | Purpose |
|----------|------|---------|
| InflationPool | `src/rewards/InflationPool.sol` | Pre-funded pool for epoch-based distribution |
| TangleMetrics | `src/rewards/TangleMetrics.sol` | Records protocol activity events |
| RewardVaults | `src/rewards/RewardVaults.sol` | Vault-based reward distribution |

### Reward Triggers

- **Staking/Delegation**: Time-weighted rewards based on stake amount and lock duration
- **Operator Activity**: Heartbeats, job completion, service uptime
- **Service Usage**: Fees paid, jobs called, services created
- **Lock Multipliers**: 1.0x (no lock) → 1.6x (6 months)

### Vault Configuration

Each asset has its own reward vault with a deposit cap:

```solidity
vaults.createVault(address(token), 1_000_000 ether);
```

### Operator Commission

Operators earn commission on delegator rewards (default 15%):

```solidity
vaults.setOperatorCommission(1500); // 15%
```

### Claiming Rewards

```solidity
// Delegators claim their share from operator pool
vaults.claimDelegatorRewards(asset, operator);

// Operators claim their commission
vaults.claimOperatorCommission(asset);
```

### Governance Controls

| Function | Role | Purpose |
|----------|------|---------|
| `createVault()` | ADMIN_ROLE | Create new reward vault |
| `updateVaultConfig()` | ADMIN_ROLE | Update deposit cap |
| `deactivateVault()` | ADMIN_ROLE | Stop new deposits |
| `setOperatorCommission()` | ADMIN_ROLE | Change commission rate |

### Integration with Core Contracts

Tangle.sol has optional metrics recording via `setMetricsRecorder()`:

```solidity
tangle.setMetricsRecorder(address(metrics));
metrics.grantRecorderRole(address(tangle));
```

Events recorded:
- Service creation/termination
- Job calls/completions
- Payments
- Blueprint creation
- Operator registrations
- Slashing

## Inflation Pool

The InflationPool is a pre-funded pool that distributes TNT rewards over time. Unlike mint-on-demand systems, this architecture isolates token risk from protocol risk.

### Security Model

- **MINTER_ROLE**: Only held by governance (TangleTimelock)
- **Protocol contracts cannot mint**: InflationPool, RewardVaults receive tokens via transfer
- **Bounded risk**: Attackers can only steal pool balance, never mint unlimited tokens
- **Emergency withdraw**: Pool can migrate funds to upgraded versions

### Funding the Pool

```solidity
// Governance proposal to fund inflation pool
// 1. Mint TNT to treasury (requires MINTER_ROLE via proposal)
tangleToken.mint(treasury, yearlyInflation);

// 2. Fund pool from treasury
pool.fund(yearlyInflation);
```

### Configuration

```solidity
 pool.setWeights(
    4000,   // 40% to stakers
    2500,   // 25% to operators
    1000,   // 10% to customers
    2500,   // 25% to developers
    0       // 0% to restakers (optional)
 );

 // Epoch length is in seconds (timestamp-based)
 pool.setEpochLength(7 days);
```

### Distribution Categories

| Category | Default | Metric Basis |
|----------|---------|--------------|
| Stakers | 40% | Vault deposits, lock multipliers |
| Operators | 25% | Jobs completed × stake, heartbeats |
| Customers | 10% | Fees paid, services used |
| Developers | 25% | Blueprint creation, jobs, fees |
| Restakers | 0% | Exposure-weighted inflation via ServiceFeeDistributor |

### Epoch Distribution

```solidity
// Anyone can trigger when epoch is ready
 if (pool.isEpochReady()) {
    pool.distributeEpoch();
 }
// If restaker inflation is enabled, a keeper should call:
// pool.distributeEpochWithServices(activeServiceIds);

// Claim rewards
pool.claimOperatorRewards();
pool.claimCustomerRewards();
```

### Emergency Migration

If bugs are found, governance can migrate to a new pool:

```solidity
// Emergency withdraw to new pool (requires DEFAULT_ADMIN_ROLE)
pool.emergencyWithdraw(newPoolAddress);
```

### Governance Controls

| Function | Role | Purpose |
|----------|------|---------|
| `fund()` | FUNDER_ROLE | Add tokens to pool budget |
| `setWeights()` | ADMIN_ROLE | Adjust distribution weights (stakers/operators/customers/developers/restakers) |
| `setEpochLength()` | ADMIN_ROLE | Change distribution frequency (seconds) |
| `emergencyWithdraw()` | DEFAULT_ADMIN_ROLE | Migrate to new pool |

## Security Considerations

1. **Timelock Delay**: Minimum 1 day gives users time to exit
2. **Quorum**: 4% prevents low-turnout attacks
3. **Proposal Threshold**: 100k TNT prevents spam
4. **Role Separation**: Different roles for different powers
5. **No Admin Backdoor**: Once roles transferred, only governance controls protocol
6. **Asset Vetting**: ASSET_MANAGER_ROLE should vet tokens before enabling (check for reentrancy, fee-on-transfer, etc.)
7. **Token Isolation**: Protocol contracts cannot mint tokens - only governance can mint via proposals
8. **Bounded Inflation Risk**: InflationPool distributes from funded balance, not minting - attackers can only steal pool funds
9. **Merit-Based**: Operator rewards weighted by stake to prevent gaming
