# TNT Substrate → EVM Migration (SP1)

This subpackage (`packages/migration-claim`) contains the SP1/ZK-based migration claim system for TNT, plus scripts and snapshot outputs used by deployment rehearsals.

Mainnet genesis is normalized to exactly 100,000,000 TNT in `deploy/distributions/normalized-100m.json`.
That file is the distribution source of truth: active Substrate claims, active EVM claims, the foundation
bucket, and the treasury balancer must sum to `TangleToken.MAX_SUPPLY`.

## What’s Included

**Contracts**
- `src/TangleMigration.sol`: Merkle + ZK gated claim contract (distributes any ERC20 you fund it with).
- `src/SP1ZKVerifier.sol`: SP1 verifier adapter.
- `src/lockups/TNTVestingFactory.sol` + `src/lockups/TNTLinearVesting.sol`: per-beneficiary linear vesting contracts.
- `src/TNT.sol`: simple mintable ERC20 used for local testing only (production can use the canonical TNT token from `tnt-core`).

**Snapshot outputs (kept in-repo for reproducible testing)**
- `packages/migration-claim/merkle-tree.json`: Merkle root + per-SS58 proofs.
- `packages/migration-claim/evm-claims.json`: EVM recipient list + amounts.
- `packages/migration-claim/treasury-carveout.json`: Treasury bucket input before normalization.
- `packages/migration-claim/foundation-carveout.json`: Foundation bucket input before deployment vesting policy is applied.

If you regenerate the snapshot, update `deploy/distributions/normalized-100m.json` and run
`python3 deploy/distributions/reconcile.py`. Treasury is the balancing bucket; the 100M cap does not move.

## Vesting Schedule (default)

Claims split into:
- `unlockedBps = 1000` (10%) transferred immediately to the recipient at claim time.
- `vestedAmount` (90%) transferred to a deterministic `TNTLinearVesting` contract for the recipient.

**Default vesting parameters:**
- 12-month cliff (365 days) - no tokens vest during this period
- 24-month linear vesting (730 days) after cliff ends
- **Total: 3 years (36 months)**

You can update vesting config via `TangleMigration.setVestingConfig(...)` only while `totalClaimed == 0` (before the first claim).

Vesting contracts are created with `delegatee = recipient` so (if the token supports `IVotes`) the recipient can use voting power while tokens are locked.

`FullDeploy` handles the treasury and foundation buckets separately from user claims:

- Treasury: 0% unlocked, 6-month cliff, 30-month linear vest.
- Foundation: 30% unlocked, 6-month cliff, 30-month linear vest.

## Merkle Format

Each Merkle value is `(bytes32 pubkey, uint256 amount)` where `pubkey` is the 32-byte SR25519 public key (derived from SS58).

Leaf hash (matches `TangleMigration.sol`):
`keccak256(bytes.concat(keccak256(abi.encode(pubkey, amount))))`

## Common Tasks

**Get the Merkle root from the checked-in tree**
- `jq -r '.root' packages/migration-claim/merkle-tree.json`

**Regenerate a Merkle tree from a snapshot**
- `cd packages/migration-claim/scripts && npm i`
- `npx ts-node generateMerkleTree.ts --input <snapshot.json> --output ../merkle-tree.json`

**Generate batched distribution files for EVM airdrop**
- `cd packages/migration-claim/scripts && npm i`
- `npx ts-node evmClaimsToDistribution.ts --input ../evm-claims.json --token 0xYourTNT --unlock-timestamp <unix> --unlocked-bps 1000 --chunk-size 200 --out-dir ../../deploy/config/evm-airdrop`

Then run distributions from repo root with `script/DistributeTNTWithLockup.s.sol`.

## Testing

- `cd packages/migration-claim && forge test`

## SP1 Program

The SP1 Rust workspace lives in `packages/migration-claim/sp1/`.
|----------|---------|
| TNT | TBD |
| TangleMigration | TBD |
| SP1 Verifier Gateway | `0x397A5f7f3dBd538f23DE225B51f532c34448dA9B` |

### Base Mainnet

| Contract | Address |
|----------|---------|
| TNT | TBD |
| TangleMigration | TBD |
| SP1 Verifier Gateway | `0x397A5f7f3dBd538f23DE225B51f532c34448dA9B` |

## Local Development Setup

1. **Deploy contracts to local testnet:**
   ```bash
   cd packages/migration-claim
   ./scripts/deploy-tangle-migration.sh
   ```

2. **Copy proofs to frontend:**
   ```bash
   cp /Users/drew/webb/tangle/types/migration_output/proofs.json \
      apps/tangle-dapp/public/data/migration-proofs.json
   ```

3. **Configure environment variables** in `apps/tangle-dapp/.env.local`:
   ```env
   VITE_TNT_TOKEN_ADDRESS=0x...
   VITE_TANGLE_MIGRATION_ADDRESS=0x...
   VITE_ZK_VERIFIER_ADDRESS=0x...
   VITE_MIGRATION_PROOFS_URL=/data/migration-proofs.json
   ```

4. **Start the dApp:**
   ```bash
   yarn start:tangle-dapp
   ```

5. Navigate to `/claim/migration` to test the claim flow.
