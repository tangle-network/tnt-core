# Local Credits Testing Guide

This guide walks through testing the credits claiming flow locally, from setting up the environment to verifying credits sync.

## Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation) (anvil, forge, cast)
- Docker Desktop
- Node.js >= 18
- pnpm

## Step 1: Run the Local Credits Setup Script

The `setup-local-credits.sh` script sets up a complete local environment for testing credits claiming.

### What the Script Does

1. **Starts Anvil** - Local EVM chain on port 8545 (configurable via `ANVIL_PORT`)
2. **Deploys Multicall3** - Injects the Multicall3 contract at the canonical address
3. **Deploys Core Contracts** - Runs `LocalTestnet.s.sol` which deploys:
   - TangleToken (TNT)
   - MultiAssetDelegation (restaking)
   - Credits contract
   - And other supporting contracts
4. **Starts Docker Containers** - PostgreSQL and Hasura for the indexer
5. **Sets Up Indexer** - Configures and starts the Envio indexer with local config
6. **Funds Claim Account** - Sends 10 ETH (for gas) and 2000 TNT to your claim account
7. **Delegates TNT** - Deposits and delegates 1000 TNT from your account to an operator
8. **Advances Time** - Moves blockchain time forward by 1 week (epoch duration)
9. **Waits for Indexer Sync** - Ensures delegation data is indexed
10. **Generates Merkle Tree** - Creates the merkle tree and publishes the root on-chain

After completion, your claim account can immediately call `claim()` on the Credits contract.

### Running the Script

```bash
# Use a custom PostgreSQL port to avoid conflicts with other services (e.g., blueprint-agent)
ENVIO_PG_PORT=5435 ./packages/credits/scripts/setup-local-credits.sh \
  --private-key <private-key> \
  --output <path-to-dapp-repo>/apps/tangle-dapp/public/data/credits-tree.json
```

**Arguments:**
- `--private-key, -k` (required): Private key for the account that will claim credits
- `--output, -o` (optional): Path to merkle tree JSON output (default: `./credits-tree.json`)

**Environment Variables:**
- `ENVIO_PG_PORT`: PostgreSQL port for Envio (default: 5433). Use 5435 to avoid conflicts with blueprint-agent's PostgreSQL port on Docker.
- `ANVIL_PORT`: Anvil RPC port (default: 8545)
- `ANVIL_CHAIN_ID`: Chain ID (default: 31337)

The script will output contract addresses and a `cast send` command you can use to claim credits manually if needed.

**Keep the script running** - it maintains Anvil and the indexer. Press Ctrl+C to stop all services.

## Step 2: Run Tangle DApp

In a separate terminal, start the tangle-dapp:

```bash
cd /path/to/dapp/repo
yarn start:tangle-dapp
```

The dapp should be available at `http://localhost:4200` (or similar port).

## Step 3: Claim Credits on Tangle DApp

1. Open the tangle-dapp in your browser
2. Connect your wallet using the same account from the private key you provided to the setup script
3. Make sure your wallet is connected to the local Anvil network:
   - RPC URL: `http://127.0.0.1:8545`
   - Chain ID: 31337
5. Click the claim button to claim your credits on the dashboard page
6. Confirm the transaction in your wallet
7. Verify that you cannot claim again

## Step 4: Run Blueprint Agent and Check Credits

Start the blueprint-agent project locally:

```bash
cd /path/to/blueprint-agent
pnpm dx up
```

Open the blueprint-agent app in your browser and check the current credits balance for your account.

## Step 5: Run Credit Sync Script

This step simulates the Cloudflare cronjob that runs daily to sync credits from the indexer to the blueprint-agent database.

```bash
cd /apps/web

npx tsx -e "
import postgres from 'postgres';
import { drizzle } from 'drizzle-orm/postgres-js';
import { createTntCreditSyncService } from './src/lib/.server/services/tnt-credit-sync.ts';

const databaseUrl = process.env.DATABASE_URL || 'postgresql://postgres:postgres@localhost:5433/blueprint_agent';
const graphqlEndpoint = process.env.TNT_GRAPHQL_ENDPOINT || 'http://localhost:8080/v1/graphql';

console.log('=== TNT Credit Sync ===');
console.log('Database:', databaseUrl);
console.log('GraphQL:', graphqlEndpoint);

const sql = postgres(databaseUrl);
const db = drizzle(sql);

(async () => {
  try {
    const service = createTntCreditSyncService(db, graphqlEndpoint);
    const result = await service.syncCredits();
    console.log('\\n=== Results ===');
    console.log('Fetched:', result.totalFetched, 'operations');
    console.log('Processed:', result.totalProcessed, 'users');
    console.log('Users with credits:', result.userIdsWithCredits.join(', ') || 'none');
  } finally {
    await sql.end();
  }
})();
"
```

**Note:** Ensure the `DATABASE_URL` points to the blueprint-agent database and `TNT_GRAPHQL_ENDPOINT` points to the local Hasura instance (default: `http://localhost:8080/v1/graphql`).

## Step 6: Verify Credits Increased

1. Refresh the blueprint-agent page in your browser
2. Check that the credits balance has increased to reflect the claimed amount

## Troubleshooting

### Port Conflicts
If you see port conflicts, check that:
- Port 8545 is free for Anvil (or set `ANVIL_PORT`)
- Port 5435 (or your chosen `ENVIO_PG_PORT`) is free for PostgreSQL
- Port 8080 is free for Hasura

### Docker Not Running
The script will attempt to start Docker Desktop automatically on macOS. If it fails, start Docker Desktop manually and re-run the script.

### Indexer Not Syncing
If the indexer times out waiting for sync:
1. Check the indexer logs in the terminal
2. Verify Docker containers are running: `docker ps`
3. Try stopping everything and running the setup script again

### Merkle Tree Not Generated
If the merkle tree generation fails:
1. Ensure the indexer has synced the delegation data
2. Check that the GraphQL endpoint is accessible at `http://localhost:8080/v1/graphql`
3. Verify the time window covers your delegation (script advances time by 1 week)