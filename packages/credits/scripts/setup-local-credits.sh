#!/usr/bin/env bash
set -euo pipefail

# setup-local-credits.sh
# Sets up a complete local environment for testing credits claiming:
# - Anvil (local EVM chain)
# - All core contracts (Tangle, MultiAssetDelegation, Credits, TNT, etc.)
# - Docker (PostgreSQL + Hasura)
# - Envio indexer
# - Funds and delegates TNT for the specified claim account
# - Advances time by 1 week (epoch duration)
# - Generates merkle tree and publishes root on-chain
#
# After running, the claim account can immediately call claim() on the Credits contract.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../../.." && pwd)"
INDEXER_DIR="$ROOT_DIR/indexer"

# Configuration
ANVIL_PORT="${ANVIL_PORT:-8545}"
ANVIL_CHAIN_ID="${ANVIL_CHAIN_ID:-31337}"
ANVIL_GAS_LIMIT="${ANVIL_GAS_LIMIT:-30000000}"
RPC_URL="${LOCAL_RPC_URL:-http://127.0.0.1:$ANVIL_PORT}"

# Default Anvil deployer account (account 0)
ANVIL_KEY="0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"
DEPLOYER_ADDRESS="0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"

# Operator 1 from LocalTestnet (account 1)
OPERATOR1_ADDRESS="0x70997970C51812dc3A010C7d01b50e0d17dc79C8"

MULTICALL3_ADDRESS="0xcA11bde05977b3631167028862bE2a173976CA11"

# Indexer settings
ENVIO_PG_PORT="${ENVIO_PG_PORT:-5433}"
ENVIO_PG_USER="${ENVIO_PG_USER:-postgres}"
ENVIO_PG_PASSWORD="${ENVIO_PG_PASSWORD:-testing}"
ENVIO_PG_DATABASE="${ENVIO_PG_DATABASE:-envio-dev}"
HASURA_PORT="${HASURA_PORT:-8080}"
GRAPHQL_URL="http://localhost:$HASURA_PORT/v1/graphql"

# Credits configuration
TNT_DELEGATION_AMOUNT="1000000000000000000000"  # 1000 TNT in wei
EPOCH_SECONDS="604800"  # 1 week
EPOCH_ID="1"

# Script state
OUTPUT_FILE=""
CLAIM_PRIVATE_KEY=""
CLAIM_ADDRESS=""

# Contract addresses (populated after deployment)
TNT_TOKEN=""
CREDITS_ADDRESS=""
RESTAKING_PROXY=""

# Process IDs
ANVIL_PID=""
INDEXER_PID=""

log() {
    echo "[setup-credits] $*"
}

error() {
    echo "[setup-credits] ERROR: $*" >&2
}

usage() {
    cat <<EOF
Usage: $0 --private-key <key> [--output <path>]

Sets up a complete local environment for testing credits claiming.

Required:
  --private-key, -k   Private key for the account that will claim credits
                      (hex string starting with 0x)

Optional:
  --output, -o        Path to merkle tree JSON output (default: ./credits-tree.json)
  --help, -h          Show this help message

Example:
  $0 --private-key 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d

After running, you can claim credits using the printed cast command.
EOF
    exit 1
}

parse_args() {
    OUTPUT_FILE="$SCRIPT_DIR/credits-tree.json"

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --private-key|-k)
                CLAIM_PRIVATE_KEY="$2"
                shift 2
                ;;
            --output|-o)
                OUTPUT_FILE="$2"
                shift 2
                ;;
            --help|-h)
                usage
                ;;
            *)
                error "Unknown option: $1"
                usage
                ;;
        esac
    done

    if [[ -z "$CLAIM_PRIVATE_KEY" ]]; then
        error "Missing required --private-key argument"
        usage
    fi

    # Ensure the output file's parent directory exists
    local output_dir
    output_dir="$(dirname "$OUTPUT_FILE")"
    if [[ ! -d "$output_dir" ]]; then
        mkdir -p "$output_dir"
    fi

    # Create the output file if it doesn't exist (for later require() calls)
    if [[ ! -f "$OUTPUT_FILE" ]]; then
        echo "{}" > "$OUTPUT_FILE"
    fi

    # Validate private key format
    if [[ ! "$CLAIM_PRIVATE_KEY" =~ ^0x[0-9a-fA-F]{64}$ ]]; then
        error "Invalid private key format. Must be 0x followed by 64 hex characters."
        exit 1
    fi

    # Derive address from private key
    CLAIM_ADDRESS=$(cast wallet address "$CLAIM_PRIVATE_KEY")
    log "Claim account address: $CLAIM_ADDRESS"
}

cleanup() {
    log "Cleaning up..."
    if [[ -n "$INDEXER_PID" ]]; then
        log "Stopping indexer (PID $INDEXER_PID)..."
        kill "$INDEXER_PID" 2>/dev/null || true
    fi
    if [[ -n "$ANVIL_PID" ]]; then
        log "Stopping Anvil (PID $ANVIL_PID)..."
        kill "$ANVIL_PID" 2>/dev/null || true
    fi
}
trap cleanup EXIT

check_prerequisites() {
    log "Checking prerequisites..."

    local missing=()

    command -v anvil >/dev/null 2>&1 || missing+=("anvil (foundry)")
    command -v forge >/dev/null 2>&1 || missing+=("forge (foundry)")
    command -v cast >/dev/null 2>&1 || missing+=("cast (foundry)")
    command -v docker >/dev/null 2>&1 || missing+=("docker")
    command -v pnpm >/dev/null 2>&1 || missing+=("pnpm")
    command -v node >/dev/null 2>&1 || missing+=("node")
    command -v curl >/dev/null 2>&1 || missing+=("curl")

    if [[ ${#missing[@]} -gt 0 ]]; then
        error "Missing required tools: ${missing[*]}"
        error "Please install them and try again."
        exit 1
    fi

    # Check Docker daemon is running, try to start if not
    if ! docker ps >/dev/null 2>&1; then
        log "Docker daemon not running, attempting to start Docker Desktop..."
        open -a Docker 2>/dev/null || true

        # Wait up to 60 seconds for Docker to start
        local docker_retries=12
        while [[ $docker_retries -gt 0 ]]; do
            sleep 5
            if docker ps >/dev/null 2>&1; then
                log "Docker Desktop started successfully"
                break
            fi
            docker_retries=$((docker_retries - 1))
        done

        if ! docker ps >/dev/null 2>&1; then
            error "Docker daemon failed to start. Please start Docker Desktop manually."
            error "You can verify by running: docker ps"
            exit 1
        fi
    fi

    log "All prerequisites met"

    local node_major
    node_major=$(node -p "process.versions.node.split('.')[0]" 2>/dev/null || echo "0")
    if [[ "$node_major" -lt 18 ]]; then
        error "Node.js >= 18 is required (found $(node -v)). Please upgrade Node and rerun."
        exit 1
    fi
}

ensure_anvil() {
    # Always start fresh to ensure deterministic contract addresses
    if lsof -iTCP:"$ANVIL_PORT" -sTCP:LISTEN >/dev/null 2>&1; then
        log "Stopping existing Anvil on port $ANVIL_PORT to ensure clean state..."
        # Kill existing Anvil process
        lsof -iTCP:"$ANVIL_PORT" -sTCP:LISTEN -t | xargs kill -9 2>/dev/null || true
        sleep 2
    fi

    # Start Anvil with timestamp from 1 week ago so after advancing time we match real wall-clock
    local initial_timestamp
    initial_timestamp=$(($(date +%s) - EPOCH_SECONDS))
    log "Starting fresh Anvil on port $ANVIL_PORT (chain-id $ANVIL_CHAIN_ID)..."
    log "Initial timestamp: $initial_timestamp (1 week ago from now)"
    anvil \
        --host 0.0.0.0 \
        --chain-id "$ANVIL_CHAIN_ID" \
        --timestamp "$initial_timestamp" \
        --base-fee 0 \
        --gas-limit "$ANVIL_GAS_LIMIT" \
        --disable-code-size-limit \
        --silent \
        --port "$ANVIL_PORT" &
    ANVIL_PID=$!
    sleep 2

    # Verify Anvil is responding
    if ! curl -s "$RPC_URL" -X POST -H "Content-Type: application/json" \
        --data '{"jsonrpc":"2.0","method":"eth_chainId","params":[],"id":1}' >/dev/null; then
        error "Anvil failed to start"
        exit 1
    fi
    log "Anvil started successfully"
}

deploy_multicall3() {
    local response
    response=$(curl -s "$RPC_URL" -X POST -H "Content-Type: application/json" \
        --data "{\"jsonrpc\":\"2.0\",\"method\":\"eth_getCode\",\"params\":[\"$MULTICALL3_ADDRESS\", \"latest\"],\"id\":1}")
    local code
    code=$(echo "$response" | sed -n 's/.*"result":"\([^"]*\)".*/\1/p')

    if [[ "$code" != "0x" && -n "$code" && ${#code} -gt 10 ]]; then
        local probe="0x82ad56cb00000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000"
        local probe_resp
        probe_resp=$(curl -s "$RPC_URL" -X POST -H "Content-Type: application/json" \
            --data "{\"jsonrpc\":\"2.0\",\"method\":\"eth_call\",\"params\":[{\"to\":\"$MULTICALL3_ADDRESS\",\"data\":\"$probe\"},\"latest\"],\"id\":1}")

        if echo "$probe_resp" | grep -q '"result"'; then
            log "Multicall3 already deployed at $MULTICALL3_ADDRESS"
            return
        fi

        log "Multicall3 code present but not functional; re-injecting runtime bytecode..."
    fi

    local MULTICALL3_BYTECODE="${MULTICALL3_BYTECODE_OVERRIDE:-}"
    if [[ -z "$MULTICALL3_BYTECODE" ]]; then
        MULTICALL3_BYTECODE="$(cat <<'EOF'
0x6080604052600436106100f35760003560e01c80634d2301cc1161008a578063a8b0574e11610059578063a8b0574e1461025a578063bce38bd714
610275578063c3077fa914610288578063ee82ac5e1461029b57600080fd5b80634d2301cc146101ec57806372425d9d1461022157806382ad56cb14
61023457806386d516e81461024757600080fd5b80633408e470116100c65780633408e47014610191578063399542e9146101a45780633e64a69614
6101c657806342cbb15c146101d957600080fd5b80630f28c97d146100f8578063174dea711461011a578063252dba421461013a57806327e86d6e14
61015b575b600080fd5b34801561010457600080fd5b50425b6040519081526020015b60405180910390f35b61012d610128366004610a85565b6102
ba565b6040516101119190610bbe565b61014d610148366004610a85565b6104ef565b604051610111929190610bd8565b34801561016757600080fd
5b50437fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0140610107565b34801561019d57600080fd5b5046610107
565b6101b76101b2366004610c60565b610690565b60405161011193929190610cba565b3480156101d257600080fd5b5048610107565b3480156101
e557600080fd5b5043610107565b3480156101f857600080fd5b50610107610207366004610ce2565b73ffffffffffffffffffffffffffffffffffff
ffff163190565b34801561022d57600080fd5b5044610107565b61012d610242366004610a85565b6106ab565b34801561025357600080fd5b504561
0107565b34801561026657600080fd5b50604051418152602001610111565b61012d610283366004610c60565b61085a565b6101b761029636600461
0a85565b610a1a565b3480156102a757600080fd5b506101076102b6366004610d18565b4090565b60606000828067ffffffffffffffff8111156102
d8576102d8610d31565b60405190808252806020026020018201604052801561031e57816020015b6040805180820190915260008152606060208201
528152602001906001900390816102f65790505b5092503660005b8281101561047757600085828151811061034157610341610d60565b6020026020
010151905087878381811061035d5761035d610d60565b905060200281019061036f9190610d8f565b60408101359586019590935061038860208501
85610ce2565b73ffffffffffffffffffffffffffffffffffffffff16816103ac6060870187610dcd565b6040516103ba929190610e32565b60006040
518083038185875af1925050503d80600081146103f7576040519150601f19603f3d011682016040523d82523d6000602084013e6103fc565b606091
505b50602080850191909152901515808452908501351761046d577f08c379a000000000000000000000000000000000000000000000000000000000
600052602060045260176024527f4d756c746963616c6c333a2063616c6c206661696c656400000000000000000060445260846000fd5b5050600101
610325565b508234146104e6576040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152601a
60248201527f4d756c746963616c6c333a2076616c7565206d69736d6174636800000000000060448201526064015b60405180910390fd5b50505092
915050565b436060828067ffffffffffffffff81111561050c5761050c610d31565b60405190808252806020026020018201604052801561053f5781
6020015b606081526020019060019003908161052a5790505b5091503660005b8281101561068657600087878381811061056257610562610d60565b
90506020028101906105749190610e42565b92506105836020840184610ce2565b73ffffffffffffffffffffffffffffffffffffffff166105a66020
850185610dcd565b6040516105b4929190610e32565b6000604051808303816000865af19150503d80600081146105f1576040519150601f19603f3d
011682016040523d82523d6000602084013e6105f6565b606091505b5086848151811061060957610609610d60565b60209081029190910101529050
8061067d576040517f08c379a000000000000000000000000000000000000000000000000000000000815260206004820152601760248201527f4d75
6c746963616c6c333a2063616c6c206661696c656400000000000000000060448201526064016104dd565b50600101610546565b5050509250929050
565b43804060606106a086868661085a565b905093509350939050565b6060818067ffffffffffffffff8111156106c7576106c7610d31565b604051
90808252806020026020018201604052801561070d57816020015b604080518082019091526000815260606020820152815260200190600190039081
6106e55790505b5091503660005b828110156104e657600084828151811061073057610730610d60565b602002602001015190508686838181106107
4c5761074c610d60565b905060200281019061075e9190610e76565b925061076d6020840184610ce2565b73ffffffffffffffffffffffffffffffff
ffffffff166107906040850185610dcd565b60405161079e929190610e32565b6000604051808303816000865af19150503d80600081146107db5760
40519150601f19603f3d011682016040523d82523d6000602084013e6107e0565b606091505b50602080840191909152901515808352908401351761
0851577f08c379a000000000000000000000000000000000000000000000000000000000600052602060045260176024527f4d756c746963616c6c33
3a2063616c6c206661696c656400000000000000000060445260646000fd5b50600101610714565b6060818067ffffffffffffffff81111561087657
610876610d31565b6040519080825280602002602001820160405280156108bc57816020015b60408051808201909152600081526060602082015281
52602001906001900390816108945790505b5091503660005b82811015610a105760008482815181106108df576108df610d60565b60200260200101
5190508686838181106108fb576108fb610d60565b905060200281019061090d9190610e42565b925061091c6020840184610ce2565b73ffffffffff
ffffffffffffffffffffffffffffff1661093f6020850185610dcd565b60405161094d929190610e32565b6000604051808303816000865af1915050
3d806000811461098a576040519150601f19603f3d011682016040523d82523d6000602084013e61098f565b606091505b5060208301521515815287
15610a07578051610a07576040517f08c379a00000000000000000000000000000000000000000000000000000000081526020600482015260176024
8201527f4d756c746963616c6c333a2063616c6c206661696c656400000000000000000060448201526064016104dd565b506001016108c3565b5050
509392505050565b6000806060610a2b60018686610690565b919790965090945092505050565b60008083601f840112610a4b57600080fd5b508135
67ffffffffffffffff811115610a6357600080fd5b6020830191508360208260051b8501011115610a7e57600080fd5b9250929050565b6000806020
8385031215610a9857600080fd5b823567ffffffffffffffff811115610aaf57600080fd5b610abb85828601610a39565b9096909550935050505056
5b6000815180845260005b81811015610aed57602081850181015186830182015201610ad1565b81811115610aff576000602083870101525b50601f
017fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe0169290920160200192915050565b600082825180855260208086
019550808260051b84010181860160005b84811015610bb1578583037fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
e001895281518051151584528401516040858501819052610b9d81860183610ac7565b9a86019a9450505090830190600101610b4f565b5090979650
505050505050565b602081526000610bd16020830184610b32565b9392505050565b6000604082018483526020604081850152818551808452606086
01915060608160051b870101935082870160005b82811015610c52577fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
a0888703018452610c40868351610ac7565b95509284019290840190600101610c06565b509398975050505050505050565b60008060006040848603
1215610c7557600080fd5b83358015158114610c8557600080fd5b9250602084013567ffffffffffffffff811115610ca157600080fd5b610cad8682
8701610a39565b9497909650939450505050565b838152826020820152606060408201526000610cd96060830184610b32565b95945050505050565b
600060208284031215610cf457600080fd5b813573ffffffffffffffffffffffffffffffffffffffff81168114610bd157600080fd5b600060208284
031215610d2a57600080fd5b5035919050565b7f4e487b71000000000000000000000000000000000000000000000000000000006000526041600452
60246000fd5b7f4e487b7100000000000000000000000000000000000000000000000000000000600052603260045260246000fd5b600082357fffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffff81833603018112610dc357600080fd5b9190910192915050565b6000808335
7fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe1843603018112610e0257600080fd5b83018035915067ffffffffff
ffffff821115610e1d57600080fd5b602001915036819003821315610a7e57600080fd5b8183823760009101908152919050565b600082357fffffff
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffc1833603018112610dc357600080fd5b600082357fffffffffffffffffffffff
ffffffffffffffffffffffffffffffffffffffffa1833603018112610dc357600080fdfea2646970667358221220bb2b5c71a328032f97c676ae39a1
ec2148d3e5d6f73d95e9b17910152d61f16264736f6c634300080c0033
EOF
)"
        MULTICALL3_BYTECODE="${MULTICALL3_BYTECODE//$'\n'/}"
    fi

    if [[ "$MULTICALL3_BYTECODE" != 0x* ]] || (( (${#MULTICALL3_BYTECODE} - 2) % 2 != 0 )); then
        error "Invalid Multicall3 bytecode; set MULTICALL3_BYTECODE_OVERRIDE to a valid 0x-prefixed even-length hex string"
        exit 1
    fi

    log "Injecting Multicall3 contract at $MULTICALL3_ADDRESS..."
    local set_result
    set_result=$(curl -s "$RPC_URL" -X POST -H "Content-Type: application/json" \
        --data "{\"jsonrpc\":\"2.0\",\"method\":\"anvil_setCode\",\"params\":[\"$MULTICALL3_ADDRESS\", \"$MULTICALL3_BYTECODE\"],\"id\":1}")

    sleep 0.5

    if echo "$set_result" | grep -q '"error"'; then
        error "anvil_setCode failed: $set_result"
        exit 1
    fi

    local probe="0x82ad56cb00000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000"
    local probe_resp
    probe_resp=$(curl -s "$RPC_URL" -X POST -H "Content-Type: application/json" \
        --data "{\"jsonrpc\":\"2.0\",\"method\":\"eth_call\",\"params\":[{\"to\":\"$MULTICALL3_ADDRESS\",\"data\":\"$probe\"},\"latest\"],\"id\":1}")

    if ! echo "$probe_resp" | grep -q '"result"'; then
        error "Multicall3 probe failed after deployment: $probe_resp"
        exit 1
    fi

    log "Multicall3 deployed"
}

run_local_testnet_setup() {
    log "Deploying contracts via LocalTestnet.s.sol..."
    log "This will deploy: Tangle, MultiAssetDelegation, Credits, TNT, etc."

    cd "$ROOT_DIR"

    # Capture deployment output to extract addresses
    local deploy_output
    deploy_output=$(forge script script/v2/LocalTestnet.s.sol:LocalTestnetSetup \
        --rpc-url "$RPC_URL" \
        --private-key "$ANVIL_KEY" \
        --broadcast \
        --non-interactive \
        --slow 2>&1) || {
        error "Contract deployment failed"
        echo "$deploy_output"
        exit 1
    }

    # Extract addresses from deployment output (macOS compatible)
    TNT_TOKEN=$(echo "$deploy_output" | sed -n 's/.*TangleToken: \(0x[a-fA-F0-9]\{40\}\).*/\1/p' | head -1)
    CREDITS_ADDRESS=$(echo "$deploy_output" | sed -n 's/.*Credits: \(0x[a-fA-F0-9]\{40\}\).*/\1/p' | head -1)
    RESTAKING_PROXY=$(echo "$deploy_output" | sed -n 's/.*MultiAssetDelegation: \(0x[a-fA-F0-9]\{40\}\).*/\1/p' | head -1)

    if [[ -z "$TNT_TOKEN" || -z "$CREDITS_ADDRESS" || -z "$RESTAKING_PROXY" ]]; then
        error "Failed to extract contract addresses from deployment output"
        log "TNT_TOKEN: $TNT_TOKEN"
        log "CREDITS_ADDRESS: $CREDITS_ADDRESS"
        log "RESTAKING_PROXY: $RESTAKING_PROXY"
        exit 1
    fi

    log "Contracts deployed:"
    log "  TNT Token: $TNT_TOKEN"
    log "  Credits: $CREDITS_ADDRESS"
    log "  Restaking: $RESTAKING_PROXY"
}

start_docker() {
    log "Starting Docker containers (PostgreSQL + Hasura)..."

    cd "$INDEXER_DIR/generated"

    # Stop any existing containers and remove volumes for clean state
    log "Stopping any existing containers..."
    docker compose down -v 2>/dev/null || true

    # Remove persisted state file
    rm -f "$INDEXER_DIR/generated/persisted_state.envio.json"

    log "Starting fresh containers..."
    docker compose up -d

    # Wait for containers to be healthy
    log "Waiting for containers to be ready..."
    local retries=30
    while [[ $retries -gt 0 ]]; do
        if docker compose ps --status running 2>/dev/null | grep -q "postgres"; then
            break
        fi
        sleep 1
        retries=$((retries - 1))
    done

    if [[ $retries -eq 0 ]]; then
        error "Docker containers failed to start"
        docker compose logs
        exit 1
    fi

    # Extra wait for PostgreSQL to be ready
    sleep 5

    log "Docker containers running"
}

setup_indexer() {
    log "Setting up indexer..."

    cd "$INDEXER_DIR"

    # Install dependencies if needed
    if [[ ! -d "node_modules" ]]; then
        log "Installing indexer dependencies..."
        pnpm install
    fi

    # Run codegen with local config
    log "Running codegen with local config..."
    pnpm envio codegen --config config.local.yaml

    # Fix pnpm symlink issue
    log "Fixing pnpm symlink..."
    local PNPM_GENERATED
    PNPM_GENERATED=$(find node_modules/.pnpm -type d -name "generated@file*" 2>/dev/null | head -1)
    if [[ -n "$PNPM_GENERATED" ]]; then
        rm -rf "$PNPM_GENERATED/node_modules/generated" 2>/dev/null || true
        ln -sf "$INDEXER_DIR/generated" "$PNPM_GENERATED/node_modules/generated"
    fi
}

start_indexer() {
    log "Starting indexer..."

    cd "$INDEXER_DIR/generated"

    ENVIO_RPC_URL_31337="$RPC_URL" \
    ENVIO_PG_PORT="$ENVIO_PG_PORT" \
    ENVIO_PG_USER="$ENVIO_PG_USER" \
    ENVIO_PG_PASSWORD="$ENVIO_PG_PASSWORD" \
    ENVIO_PG_DATABASE="$ENVIO_PG_DATABASE" \
    TUI_OFF=true \
    pnpm start &
    INDEXER_PID=$!

    log "Indexer started (PID $INDEXER_PID)"

    # Give indexer time to start
    sleep 5
}

fund_claim_account() {
    log "Funding claim account with ETH and TNT..."

    # Send ETH for gas
    cast send "$CLAIM_ADDRESS" --value 10ether \
        --private-key "$ANVIL_KEY" \
        --rpc-url "$RPC_URL" >/dev/null

    log "Sent 10 ETH to claim account for gas"

    # Send TNT tokens (2x delegation amount to have some buffer)
    local tnt_amount="2000000000000000000000"  # 2000 TNT
    cast send "$TNT_TOKEN" "transfer(address,uint256)" "$CLAIM_ADDRESS" "$tnt_amount" \
        --private-key "$ANVIL_KEY" \
        --rpc-url "$RPC_URL" >/dev/null

    log "Sent 2000 TNT to claim account"

    # Verify balance
    local balance
    balance=$(cast call "$TNT_TOKEN" "balanceOf(address)(uint256)" "$CLAIM_ADDRESS" --rpc-url "$RPC_URL")
    log "Claim account TNT balance: $balance wei"
}

delegate_tnt() {
    log "Delegating TNT from claim account..."

    # Approve TNT to restaking contract
    cast send "$TNT_TOKEN" "approve(address,uint256)" "$RESTAKING_PROXY" "$TNT_DELEGATION_AMOUNT" \
        --private-key "$CLAIM_PRIVATE_KEY" \
        --rpc-url "$RPC_URL" >/dev/null

    log "Approved TNT for restaking"

    # Deposit TNT
    cast send "$RESTAKING_PROXY" "depositERC20(address,uint256)" "$TNT_TOKEN" "$TNT_DELEGATION_AMOUNT" \
        --private-key "$CLAIM_PRIVATE_KEY" \
        --rpc-url "$RPC_URL" >/dev/null

    log "Deposited $TNT_DELEGATION_AMOUNT wei TNT"

    # Delegate to operator1 with BlueprintSelectionMode.All (0) and empty blueprints array
    cast send "$RESTAKING_PROXY" \
        "delegateWithOptions(address,address,uint256,uint8,uint64[])" \
        "$OPERATOR1_ADDRESS" "$TNT_TOKEN" "$TNT_DELEGATION_AMOUNT" 0 "[]" \
        --private-key "$CLAIM_PRIVATE_KEY" \
        --rpc-url "$RPC_URL" >/dev/null

    log "Delegated $TNT_DELEGATION_AMOUNT wei TNT to operator $OPERATOR1_ADDRESS"
}

advance_time() {
    log "Advancing blockchain time by 1 week ($EPOCH_SECONDS seconds)..."

    # Advance time
    cast rpc evm_increaseTime "$EPOCH_SECONDS" --rpc-url "$RPC_URL" >/dev/null

    # Mine a block to apply the time change
    cast rpc evm_mine --rpc-url "$RPC_URL" >/dev/null

    log "Time advanced by 1 week"
}

wait_for_indexer_sync() {
    log "Waiting for indexer to sync delegation data..."

    local retries=60
    local synced=false

    while [[ $retries -gt 0 ]]; do
        local response
        local claim_addr_lower
        claim_addr_lower=$(echo "$CLAIM_ADDRESS" | tr '[:upper:]' '[:lower:]')
        response=$(curl -s "$GRAPHQL_URL" \
            -H "Content-Type: application/json" \
            -d "{\"query\": \"{ DelegationBalanceDelta(where: {delegator: {_eq: \\\"${claim_addr_lower}\\\"}}, limit: 1) { id delegator delta } }\"}" 2>/dev/null || echo "{}")

        if echo "$response" | grep -q '"delegator"'; then
            synced=true
            break
        fi

        sleep 2
        retries=$((retries - 1))

        # Check if indexer is still running
        if ! kill -0 "$INDEXER_PID" 2>/dev/null; then
            error "Indexer process died"
            exit 1
        fi
    done

    if [[ "$synced" == "true" ]]; then
        log "Indexer synced delegation data"
    else
        error "Timeout waiting for indexer to sync. Check indexer logs."
        exit 1
    fi
}

generate_merkle_tree() {
    log "Generating merkle tree and publishing root..."

    cd "$SCRIPT_DIR"

    # Install dependencies if needed
    if [[ ! -d "node_modules" ]]; then
        log "Installing credits scripts dependencies..."
        npm install
    fi

    # Get current block timestamp for time window
    local current_ts
    current_ts=$(cast block latest --rpc-url "$RPC_URL" -f timestamp)
    local start_ts=$((current_ts - EPOCH_SECONDS))

    log "Time window: $start_ts to $current_ts"

    # Run the epoch script with --publish flag
    # Use tsx for reliable ESM TypeScript execution
    GRAPHQL_URL="$GRAPHQL_URL" \
    RPC_URL="$RPC_URL" \
    PRIVATE_KEY="$ANVIL_KEY" \
    CREDITS_ADDRESS="$CREDITS_ADDRESS" \
    npx tsx runEpoch.ts \
        --epoch-id "$EPOCH_ID" \
        --tnt-token "$TNT_TOKEN" \
        --start-ts "$start_ts" \
        --end-ts "$current_ts" \
        --epoch-seconds "$EPOCH_SECONDS" \
        --credits-per-tnt 1 \
        --min-credits 1 \
        --out "$OUTPUT_FILE" \
        --publish

    log "Merkle tree generated and root published on-chain"
}

print_summary() {
    log ""
    log "==========================================="
    log "  Credits Local Setup Complete!"
    log "==========================================="
    log ""
    log "Contract Addresses:"
    log "  Credits:    $CREDITS_ADDRESS"
    log "  TNT Token:  $TNT_TOKEN"
    log "  Restaking:  $RESTAKING_PROXY"
    log ""
    log "Claim Account:"
    log "  Address:    $CLAIM_ADDRESS"
    log ""
    log "Merkle Tree:"
    log "  File:       $OUTPUT_FILE"
    log "  Epoch ID:   $EPOCH_ID"
    log ""
    log "GraphQL API:  $GRAPHQL_URL"
    log "RPC URL:      $RPC_URL"
    log ""

    # Extract claim info from merkle tree
    if [[ -f "$OUTPUT_FILE" ]]; then
        local claim_address_lower
        claim_address_lower=$(echo "$CLAIM_ADDRESS" | tr '[:upper:]' '[:lower:]')
        local amount
        local proof

        amount=$(node -e "const t=require('$OUTPUT_FILE'); const e=t.entries['$claim_address_lower']; if(e) console.log(e.amount); else console.log('NOT_FOUND');")
        proof=$(node -e "const t=require('$OUTPUT_FILE'); const e=t.entries['$claim_address_lower']; if(e) console.log(JSON.stringify(e.proof)); else console.log('[]');")

        if [[ "$amount" != "NOT_FOUND" ]]; then
            # Convert proof from JSON array to cast-compatible format: ["0x..."] -> [0x...]
            local proof_cast
            proof_cast=$(echo "$proof" | sed 's/"//g')

            log "Your Claim Info:"
            log "  Amount:     $amount credits"
            log "  Proof:      $proof"
            log ""
            log "To claim your credits, run:"
            log ""
            echo "cast send $CREDITS_ADDRESS \"claim(uint256,uint256,bytes32,bytes32[])\" \\"
            echo "  $EPOCH_ID $amount 0x0000000000000000000000000000000000000000000000000000000000000000 \"$proof_cast\" \\"
            echo "  --private-key $CLAIM_PRIVATE_KEY \\"
            echo "  --rpc-url $RPC_URL"
            log ""
        else
            error "Claim account not found in merkle tree!"
            log "This may indicate an issue with the delegation or time window."
        fi
    fi

    log "==========================================="
    log "Press Ctrl+C to stop all services"
    log "==========================================="
}

main() {
    parse_args "$@"
    check_prerequisites
    ensure_anvil
    deploy_multicall3
    run_local_testnet_setup
    start_docker
    setup_indexer
    start_indexer
    fund_claim_account
    delegate_tnt
    advance_time
    wait_for_indexer_sync
    generate_merkle_tree
    print_summary

    # Keep running until Ctrl+C
    if [[ -n "$ANVIL_PID" ]]; then
        wait "$ANVIL_PID"
    elif [[ -n "$INDEXER_PID" ]]; then
        wait "$INDEXER_PID"
    else
        while true; do sleep 3600; done
    fi
}

main "$@"
