#!/usr/bin/env bash
set -euo pipefail

# End-to-end local testnet script
# Starts Anvil, deploys contracts, runs the indexer, and tests the API

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
INDEXER_DIR="$ROOT_DIR/indexer"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() { echo -e "${BLUE}[e2e]${NC} $1"; }
success() { echo -e "${GREEN}[e2e]${NC} $1"; }
warn() { echo -e "${YELLOW}[e2e]${NC} $1"; }
error() { echo -e "${RED}[e2e]${NC} $1"; }

cleanup() {
    log "Cleaning up..."
    if [[ -n "${ANVIL_PID:-}" ]]; then
        kill "$ANVIL_PID" 2>/dev/null || true
    fi
    if [[ -n "${INDEXER_PID:-}" ]]; then
        kill "$INDEXER_PID" 2>/dev/null || true
    fi
    # Kill any process on the indexer metrics port
    lsof -ti:9898 | xargs kill 2>/dev/null || true
}
trap cleanup EXIT

# Kill any leftover processes from previous runs
pkill -f "ts-node src/Index" 2>/dev/null || true
lsof -ti:9898 | xargs kill 2>/dev/null || true
sleep 1

# Parse arguments
SKIP_DEPLOY=${SKIP_DEPLOY:-false}
KEEP_RUNNING=${KEEP_RUNNING:-false}
RUN_TESTS=${RUN_TESTS:-true}

while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-deploy) SKIP_DEPLOY=true; shift ;;
        --keep-running) KEEP_RUNNING=true; shift ;;
        --no-tests) RUN_TESTS=false; shift ;;
        *) error "Unknown option: $1"; exit 1 ;;
    esac
done

# Step 1: Start Anvil
# Use chain ID 31337 (Anvil default) to match config.local.yaml and hourly.ts handlers
log "Starting Anvil on chain ID 31337 (local development)..."
anvil --chain-id 31337 --block-time 1 --base-fee 0 --gas-limit 30000000 --disable-code-size-limit --silent &
ANVIL_PID=$!
sleep 2

# Verify Anvil is running
if ! curl -s http://127.0.0.1:8545 -X POST -H "Content-Type: application/json" \
    --data '{"jsonrpc":"2.0","method":"eth_chainId","params":[],"id":1}' > /dev/null; then
    error "Failed to start Anvil"
    exit 1
fi
success "Anvil running (PID: $ANVIL_PID)"

# Step 2: Deploy contracts
if [[ "$SKIP_DEPLOY" != "true" ]]; then
    log "Deploying contracts with LocalTestnet.s.sol..."
    cd "$ROOT_DIR"
    # Use Anvil's default deployer private key
    ANVIL_PRIVATE_KEY="0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"
    forge script script/LocalTestnet.s.sol:LocalTestnetSetup \
        --rpc-url http://127.0.0.1:8545 \
        --private-key "$ANVIL_PRIVATE_KEY" \
        --broadcast \
        --non-interactive \
        --slow 2>&1 | tee /tmp/deploy.log

    # Check if deployment actually succeeded by verifying contract code exists
    if ! cast code 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512 --rpc-url http://127.0.0.1:8545 2>/dev/null | grep -q "^0x[0-9a-f]\{10,\}$"; then
        error "Deployment failed - no contract code at expected address"
        cat /tmp/deploy.log
        exit 1
    fi

    success "Contracts deployed and verified!"

    # Use deterministic addresses (from Anvil default deployer nonce sequence)
    TANGLE_ADDR="0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9"
    RESTAKING_ADDR="0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512"
    STATUS_REG_ADDR="0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9"
    CREDITS_ADDR=$(grep -Eo "Credits: 0x[0-9a-fA-F]{40}" /tmp/deploy.log | awk '{print $2}' | tail -n 1 || true)
    BLUEPRINT_ID="0"
    SERVICE_ID="0"

    log "Deployed addresses:"
    log "  Tangle: $TANGLE_ADDR"
    log "  MultiAssetDelegation: $RESTAKING_ADDR"
    log "  OperatorStatusRegistry: $STATUS_REG_ADDR"
    if [[ -n "${CREDITS_ADDR:-}" ]]; then
        log "  Credits: $CREDITS_ADDR"
    else
        warn "Credits address not found in deploy output; credits indexing will be disabled"
    fi
    log "  Blueprint ID: $BLUEPRINT_ID"
    log "  Service ID: $SERVICE_ID"
fi

# Step 3: Setup indexer with local config
log "Setting up indexer with local config..."
cd "$INDEXER_DIR"

# Use the local config
cp config.local.yaml config.yaml.bak 2>/dev/null || true
cp config.local.yaml config.yaml
if [[ -n "${CREDITS_ADDR:-}" ]]; then
    # Replace the placeholder Credits address for local indexing.
    sed -i.bak "s/0x0000000000000000000000651234512121212666/${CREDITS_ADDR}/g" config.yaml
fi

# Run codegen
log "Running Envio codegen..."
pnpm codegen

# Use a direct symlink instead of pnpm file: protocol
# pnpm's file: copies packages and breaks nested dependency resolution
log "Setting up generated package symlink..."
rm -rf node_modules/.pnpm/generated@* 2>/dev/null || true
rm -rf node_modules/generated 2>/dev/null || true
ln -sfn ../generated node_modules/generated
success "Created symlink: node_modules/generated -> ../generated"

# Clear any persisted indexer state to ensure fresh sync from block 0
log "Clearing persisted indexer state..."
rm -f "$INDEXER_DIR/generated/persisted_state.envio.json"

# Start the indexer database (fresh volumes)
log "Starting indexer database..."
cd "$INDEXER_DIR/generated"
docker compose down -v 2>/dev/null || true
docker compose up -d
sleep 3
cd "$INDEXER_DIR"

# Step 4: Run DB migrations manually (instead of envio dev which overwrites our symlink)
log "Running DB migrations..."
cd "$INDEXER_DIR/generated"
pnpm db-setup
cd "$INDEXER_DIR"

# Clear chain progress to force indexer to start from block 0
log "Clearing chain progress to force sync from block 0..."
PGPASSWORD=testing psql -h localhost -p 5433 -U postgres -d envio-dev -c \
    "TRUNCATE TABLE public.persisted_state, public.chain_metadata, public.dynamic_contract_registry CASCADE;" 2>/dev/null || true

# Re-create symlink (pnpm install during codegen might have overwritten it)
log "Ensuring generated package symlink exists..."
rm -rf node_modules/.pnpm/generated@* 2>/dev/null || true
rm -rf node_modules/generated 2>/dev/null || true
ln -sfn ../generated node_modules/generated

# Step 5: Start the indexer directly (bypass envio dev to avoid re-codegen)
log "Starting indexer..."
cd "$INDEXER_DIR/generated"
TUI_OFF=true ENVIO_RPC_URL_31337=http://127.0.0.1:8545 pnpm start &
INDEXER_PID=$!
cd "$INDEXER_DIR"
sleep 5

success "Indexer started (PID: $INDEXER_PID)"

# Step 6: Wait for indexing to catch up and Hasura to track tables
log "Waiting for indexer to process blocks and Hasura to track tables..."
CURRENT_BLOCK=$(cast block-number --rpc-url http://127.0.0.1:8545)
log "Current block: $CURRENT_BLOCK"

# Wait for Hasura to be ready and have tables tracked
log "Waiting for Hasura GraphQL schema to be ready..."
HASURA_URL="http://localhost:8080/v1/graphql"
for i in {1..30}; do
    RESULT=$(curl -s "$HASURA_URL" -H "Content-Type: application/json" -d '{"query": "{ __schema { types { name } } }"}' 2>/dev/null)
    if echo "$RESULT" | grep -q "Operator"; then
        success "Hasura schema is ready!"
        break
    fi
    log "Waiting for Hasura schema... ($i/30)"
    sleep 2
done

# Give indexer more time to process blocks from block 0
log "Giving indexer time to sync from block 0..."
sleep 30

# Step 7: Run tests against the GraphQL API
if [[ "$RUN_TESTS" == "true" ]]; then
    log "Running API tests..."

    HASURA_URL="http://localhost:8080/v1/graphql"

    # Test 1: Query operators
    log "Testing: Query operators..."
    OPERATORS=$(curl -s "$HASURA_URL" \
        -H "Content-Type: application/json" \
        -d '{"query": "{ Operator { id restakingStake } }"}')

    if echo "$OPERATORS" | grep -q '"Operator"'; then
        success "Operators query successful"
        echo "$OPERATORS" | jq '.data.Operator | length' 2>/dev/null && \
            log "Found $(echo "$OPERATORS" | jq '.data.Operator | length') operators"
    else
        warn "Operators query returned: $OPERATORS"
    fi

    # Test 2: Query blueprints
    log "Testing: Query blueprints..."
    BLUEPRINTS=$(curl -s "$HASURA_URL" \
        -H "Content-Type: application/json" \
        -d '{"query": "{ Blueprint { id owner } }"}')

    if echo "$BLUEPRINTS" | grep -q '"Blueprint"'; then
        success "Blueprints query successful"
        echo "$BLUEPRINTS" | jq '.data.Blueprint | length' 2>/dev/null && \
            log "Found $(echo "$BLUEPRINTS" | jq '.data.Blueprint | length') blueprints"
    else
        warn "Blueprints query returned: $BLUEPRINTS"
    fi

    # Test 3: Query services
    log "Testing: Query services..."
    SERVICES=$(curl -s "$HASURA_URL" \
        -H "Content-Type: application/json" \
        -d '{"query": "{ Service { id blueprint_id status } }"}')

    if echo "$SERVICES" | grep -q '"Service"'; then
        success "Services query successful"
        echo "$SERVICES" | jq '.data.Service | length' 2>/dev/null && \
            log "Found $(echo "$SERVICES" | jq '.data.Service | length') services"
    else
        warn "Services query returned: $SERVICES"
    fi

    # Test 4: Query delegators
    log "Testing: Query delegators..."
    DELEGATORS=$(curl -s "$HASURA_URL" \
        -H "Content-Type: application/json" \
        -d '{"query": "{ Delegator { id address } }"}')

    if echo "$DELEGATORS" | grep -q '"Delegator"'; then
        success "Delegators query successful"
    else
        warn "Delegators query returned: $DELEGATORS"
    fi

    success "API tests completed!"
fi

# Step 8: Keep running or cleanup
if [[ "$KEEP_RUNNING" == "true" ]]; then
    success "Setup complete! Services are running:"
    log "  Anvil: http://127.0.0.1:8545 (PID: $ANVIL_PID)"
    log "  Hasura GraphQL: http://localhost:8080/v1/graphql"
    log "  Indexer PID: $INDEXER_PID"
    log ""
    log "Press Ctrl+C to stop all services"

    # Export addresses for use by other scripts
    export TANGLE_PROXY="${TANGLE_ADDR:-0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9}"
    export RESTAKING_PROXY="${RESTAKING_ADDR:-0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512}"
    export STATUS_REGISTRY="${STATUS_REG_ADDR:-0xDc64a140Aa3E981100a9becA4E685f962f0cF6C9}"
    export BLUEPRINT_ID="${BLUEPRINT_ID:-1}"
    export SERVICE_ID="${SERVICE_ID:-1}"

    wait
else
    success "E2E test completed successfully!"

    # Restore original config
    if [[ -f config.yaml.bak ]]; then
        mv config.yaml.bak config.yaml
    fi
fi
