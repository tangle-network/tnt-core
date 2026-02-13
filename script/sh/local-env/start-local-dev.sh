#!/usr/bin/env bash
set -euo pipefail

# start-local-dev.sh
# Sets up a COMPLETE local development environment with:
# - Anvil (local EVM chain)
# - Multicall3 contract
# - All core contracts (Tangle, MultiAssetDelegation, etc.)
# - Mock tokens (USDC, USDT, DAI, WETH, stETH, wstETH, EIGEN)
# - Registered operators with stakes
# - Test blueprint and active service
# - Delegations and seeded rewards
# - Docker (PostgreSQL + Hasura)
# - Envio indexer (fully synced)
#
# Requirements:
# - Docker and docker compose
# - Foundry (forge, anvil)
# - Node.js and npm
# - nc (netcat) for port checking
#
# Use this for dApp/indexer development. For testing deployment configs,
# use test-full-deploy.sh instead.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
INDEXER_DIR="$ROOT_DIR/indexer"

ANVIL_PORT="${ANVIL_PORT:-8545}"
ANVIL_CHAIN_ID="${ANVIL_CHAIN_ID:-31337}"
ANVIL_GAS_LIMIT="${ANVIL_GAS_LIMIT:-30000000}"
RPC_URL="${LOCAL_RPC_URL:-http://127.0.0.1:$ANVIL_PORT}"

# Multiple instances flag (creates 3 service instances instead of 1)
MULTIPLE_INSTANCES="${MULTIPLE_INSTANCES:-false}"

# Subscription mode flag (creates subscription blueprint instead of PayOnce)
SUBSCRIPTION_MODE="${SUBSCRIPTION_MODE:-false}"

# Service leavable flag (advances time past min commitment so operators can schedule exit)
SERVICE_LEAVABLE="${SERVICE_LEAVABLE:-false}"

# Rewards QA flag (seeds Tangle Payments rewards and executes claims for frontend QA)
REWARDS_QA="${REWARDS_QA:-false}"

# Default Anvil account (account 0)
ANVIL_KEY="${ANVIL_PRIVATE_KEY:-0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80}"

MULTICALL3_ADDRESS="${MULTICALL3_ADDRESS:-0xcA11bde05977b3631167028862bE2a173976CA11}"

# Indexer settings
ENVIO_PG_PORT="${ENVIO_PG_PORT:-5433}"
ENVIO_PG_USER="${ENVIO_PG_USER:-postgres}"
ENVIO_PG_PASSWORD="${ENVIO_PG_PASSWORD:-testing}"
ENVIO_PG_DATABASE="${ENVIO_PG_DATABASE:-envio-dev}"
HASURA_PORT="${HASURA_PORT:-8080}"

log() {
    echo "[local-dev] $*"
}

ANVIL_PID=""
INDEXER_PID=""

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
    # Note: Docker containers are left running for faster restarts
    # Use './start-local-dev.sh clean' to stop them
}
trap cleanup EXIT

check_prerequisites() {
    log "Checking prerequisites..."

    local missing=()

    command -v anvil >/dev/null 2>&1 || missing+=("anvil (foundry)")
    command -v forge >/dev/null 2>&1 || missing+=("forge (foundry)")
    command -v docker >/dev/null 2>&1 || missing+=("docker")
    command -v pnpm >/dev/null 2>&1 || missing+=("pnpm")
    command -v curl >/dev/null 2>&1 || missing+=("curl")

    if [[ ${#missing[@]} -gt 0 ]]; then
        log "ERROR: Missing required tools: ${missing[*]}"
        log "Please install them and try again."
        exit 1
    fi

    # Check Docker is running
    if ! docker info >/dev/null 2>&1; then
        log "ERROR: Docker is not running. Please start Docker and try again."
        exit 1
    fi

    log "All prerequisites met"
}

ensure_anvil() {
    # Use nc instead of lsof - lsof can hang on macOS
    if nc -z 127.0.0.1 "$ANVIL_PORT" 2>/dev/null; then
        log "Anvil already running on port $ANVIL_PORT"
        return
    fi

    log "Starting Anvil on port $ANVIL_PORT (chain-id $ANVIL_CHAIN_ID)..."
    # Using auto-mining (no --block-time) to minimize empty blocks during deployment.
    # For time-dependent testing, use: cast rpc evm_increaseTime <seconds> && cast rpc evm_mine
    anvil \
        --chain-id "$ANVIL_CHAIN_ID" \
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
        log "ERROR: Anvil failed to start"
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
        log "ERROR: Invalid Multicall3 bytecode; set MULTICALL3_BYTECODE_OVERRIDE to a valid 0x-prefixed even-length hex string"
        exit 1
    fi

    log "Injecting Multicall3 contract at $MULTICALL3_ADDRESS..."
    local set_result
    set_result=$(curl -s "$RPC_URL" -X POST -H "Content-Type: application/json" \
        --data "{\"jsonrpc\":\"2.0\",\"method\":\"anvil_setCode\",\"params\":[\"$MULTICALL3_ADDRESS\", \"$MULTICALL3_BYTECODE\"],\"id\":1}")

    sleep 0.5

    response=$(curl -s "$RPC_URL" -X POST -H "Content-Type: application/json" \
        --data "{\"jsonrpc\":\"2.0\",\"method\":\"eth_getCode\",\"params\":[\"$MULTICALL3_ADDRESS\", \"latest\"],\"id\":1}")
    code=$(echo "$response" | sed -n 's/.*"result":"\([^"]*\)".*/\1/p')

    if [[ "$code" != "0x" && -n "$code" && ${#code} -gt 10 ]]; then
        local probe="0x82ad56cb00000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000000"
        local probe_resp
        probe_resp=$(curl -s "$RPC_URL" -X POST -H "Content-Type: application/json" \
            --data "{\"jsonrpc\":\"2.0\",\"method\":\"eth_call\",\"params\":[{\"to\":\"$MULTICALL3_ADDRESS\",\"data\":\"$probe\"},\"latest\"],\"id\":1}")

        if echo "$probe_resp" | grep -q '"result"'; then
            log "Multicall3 deployed at $MULTICALL3_ADDRESS"
        else
            log "ERROR: Multicall3 injected but not functional (response: $probe_resp)"
            exit 1
        fi
    else
        log "ERROR: Failed to deploy Multicall3 (response: $set_result)"
        exit 1
    fi
}

run_local_testnet_setup() {
    log "Running LocalTestnetSetup..."
    log "This will deploy all contracts, mock tokens, register operators, create services, etc."
    if [[ "$MULTIPLE_INSTANCES" == "true" ]]; then
        log "Multiple instances mode: Will create 3 service instances"
    fi
    if [[ "$SUBSCRIPTION_MODE" == "true" ]]; then
        log "Subscription mode: Will create subscription blueprint (0.1 ETH per 60s interval)"
    fi
    if [[ "$SERVICE_LEAVABLE" == "true" ]]; then
        log "Service leavable mode: Will advance time past min commitment after setup"
    fi
    if [[ "$REWARDS_QA" == "true" ]]; then
        log "Rewards QA mode: Will seed Tangle Payments rewards for frontend testing"
    fi

    cd "$ROOT_DIR"

    # Run the LocalTestnetSetup script
    # Note: -vvvv for verbose output so user can see deployment progress
    # Removed --slow since Anvil auto-mines transactions immediately
    MULTIPLE_INSTANCES="$MULTIPLE_INSTANCES" \
    SUBSCRIPTION_MODE="$SUBSCRIPTION_MODE" \
    REWARDS_QA="$REWARDS_QA" \
    forge script script/LocalTestnet.s.sol:LocalTestnetSetup \
        --rpc-url "$RPC_URL" \
        --private-key "$ANVIL_KEY" \
        --broadcast \
        --non-interactive \
        -vvvv

    # Update indexer config with deployed contract addresses
    update_indexer_config
}

advance_time_for_leavable() {
    if [[ "$SERVICE_LEAVABLE" != "true" ]]; then
        return
    fi

    log "Advancing Anvil time by 1 day (86400s) so operators pass minimum commitment..."
    # MIN_COMMITMENT_DURATION is 1 day (86400 seconds) in ProtocolConfig.sol
    cast rpc evm_increaseTime 86400 --rpc-url "$RPC_URL" >/dev/null
    cast rpc evm_mine --rpc-url "$RPC_URL" >/dev/null
    log "Time advanced. Operators can now schedule exit from services."
}

update_indexer_config() {
    log "Updating indexer config with deployed contract addresses..."

    local BROADCAST_DIR="$ROOT_DIR/broadcast/LocalTestnet.s.sol/$ANVIL_CHAIN_ID"
    local LATEST_BROADCAST
    LATEST_BROADCAST=$(ls -t "$BROADCAST_DIR"/run-*.json 2>/dev/null | head -1)

    if [[ -z "$LATEST_BROADCAST" ]]; then
        log "WARNING: Could not find broadcast file, skipping config update"
        return
    fi

    log "Using broadcast file: $LATEST_BROADCAST"

    local CONFIG_FILE="$INDEXER_DIR/config.local.yaml"

    if ! command -v jq >/dev/null 2>&1; then
        log "WARNING: jq not installed, skipping automatic config update"
        log "Install jq or manually update $CONFIG_FILE with deployed addresses"
        return
    fi

    # Extract addresses by contract name from broadcast JSON
    # For proxies, we match by deployment order (consistent with LocalTestnet.s.sol)
    local STAKING_ADDR TANGLE_ADDR REGISTRY_ADDR MBSM_ADDR POD_MANAGER_ADDR
    local LIQUID_FACTORY_ADDR REWARD_VAULTS_ADDR INFLATION_POOL_ADDR

    # Get all proxy addresses in deployment order
    local PROXIES
    PROXIES=$(jq -r '[.transactions[] | select(.contractName == "ERC1967Proxy") | .contractAddress] | .[]' "$LATEST_BROADCAST" 2>/dev/null || true)

    # Map proxies by order: 0=Staking, 1=Tangle, 2=TangleToken, etc.
    STAKING_ADDR=$(echo "$PROXIES" | sed -n '1p')
    TANGLE_ADDR=$(echo "$PROXIES" | sed -n '2p')

    # Get named contracts directly
    REGISTRY_ADDR=$(jq -r '.transactions[] | select(.contractName == "OperatorStatusRegistry") | .contractAddress' "$LATEST_BROADCAST" 2>/dev/null | head -1 || true)
    MBSM_ADDR=$(jq -r '.transactions[] | select(.contractName == "MasterBlueprintServiceManager") | .contractAddress' "$LATEST_BROADCAST" 2>/dev/null | head -1 || true)
    POD_MANAGER_ADDR=$(jq -r '.transactions[] | select(.contractName == "ValidatorPodManager") | .contractAddress' "$LATEST_BROADCAST" 2>/dev/null | head -1 || true)
    LIQUID_FACTORY_ADDR=$(jq -r '.transactions[] | select(.contractName == "LiquidDelegationFactory") | .contractAddress' "$LATEST_BROADCAST" 2>/dev/null | head -1 || true)
    REWARD_VAULTS_ADDR=$(jq -r '.transactions[] | select(.contractName == "RewardVaults") | .contractAddress' "$LATEST_BROADCAST" 2>/dev/null | head -1 || true)
    INFLATION_POOL_ADDR=$(jq -r '.transactions[] | select(.contractName == "InflationPool") | .contractAddress' "$LATEST_BROADCAST" 2>/dev/null | head -1 || true)

    # Update config file using perl for cross-platform compatibility
    update_contract_address() {
        local name="$1" addr="$2"
        [[ -z "$addr" || "$addr" == "null" ]] && return
        # Convert to lowercase for consistency
        addr=$(echo "$addr" | tr '[:upper:]' '[:lower:]')
        # Update the address line following the contract name using perl (macOS compatible)
        perl -i -pe "
            if (/- name: $name\$/) { \$found = 1 }
            if (\$found && /^\\s+- \"0x[a-fA-F0-9]+\"/) {
                s/\"0x[a-fA-F0-9]+\"/\"$addr\"/;
                \$found = 0;
            }
        " "$CONFIG_FILE"
        log "  $name: $addr"
    }

    log "Updating contract addresses:"
    update_contract_address "MultiAssetDelegation" "$STAKING_ADDR"
    update_contract_address "Tangle" "$TANGLE_ADDR"
    update_contract_address "OperatorStatusRegistry" "$REGISTRY_ADDR"
    update_contract_address "MasterBlueprintServiceManager" "$MBSM_ADDR"
    update_contract_address "ValidatorPodManager" "$POD_MANAGER_ADDR"
    update_contract_address "LiquidDelegationFactory" "$LIQUID_FACTORY_ADDR"
    update_contract_address "RewardVaults" "$REWARD_VAULTS_ADDR"
    update_contract_address "InflationPool" "$INFLATION_POOL_ADDR"

    # Clean up temp files
    rm -f "$CONFIG_FILE.tmp" "$CONFIG_FILE.bak"

    log "Indexer config update complete"
}

start_docker() {
    log "Starting Docker containers (PostgreSQL + Hasura)..."

    cd "$INDEXER_DIR/generated"

    # Always start fresh to ensure clean database schema
    # (Anvil starts fresh each time, so database should match)
    log "Stopping any existing containers and removing volumes..."
    docker compose down -v 2>/dev/null || true

    # Remove persisted state file to ensure fresh sync
    rm -f "$INDEXER_DIR/generated/persisted_state.envio.json"

    log "Starting fresh containers..."
    docker compose up -d

    # Wait for containers to be healthy
    log "Waiting for containers to be healthy..."
    local retries=30
    while [[ $retries -gt 0 ]]; do
        if docker compose ps --status running 2>/dev/null | grep -q "postgres"; then
            break
        fi
        sleep 1
        retries=$((retries - 1))
    done

    if [[ $retries -eq 0 ]]; then
        log "ERROR: Docker containers failed to start"
        docker compose logs
        exit 1
    fi

    # Extra wait for PostgreSQL to be ready
    sleep 5

    log "Docker containers running:"
    log "  - PostgreSQL on port $ENVIO_PG_PORT"
    log "  - Hasura on port $HASURA_PORT"
}

setup_indexer() {
    log "Setting up indexer..."

    cd "$INDEXER_DIR"

    # Install dependencies if needed
    if [[ ! -d "node_modules" ]]; then
        log "Installing indexer dependencies..."
        pnpm install
    fi

    # Run codegen with local config for chain 31337
    log "Running codegen with local config..."
    pnpm envio codegen --config config.local.yaml

    # Fix pnpm symlink issue
    log "Fixing pnpm symlink..."
    local PNPM_GENERATED
    PNPM_GENERATED=$(find node_modules/.pnpm -type d -name "generated@file*" 2>/dev/null | head -1)
    if [[ -n "$PNPM_GENERATED" ]]; then
        rm -rf "$PNPM_GENERATED/node_modules/generated" 2>/dev/null || true
        ln -sf "$INDEXER_DIR/generated" "$PNPM_GENERATED/node_modules/generated"
        log "Symlink fixed: $PNPM_GENERATED/node_modules/generated"
    fi
}

reset_indexer_state() {
    log "Resetting indexer state for fresh sync..."

    # Remove persisted state file
    rm -f "$INDEXER_DIR/generated/persisted_state.envio.json"

    # Reset database state
    docker exec -i "$(docker ps -q --filter ancestor=postgres:17.5 2>/dev/null || docker ps -q --filter name=postgres)" \
        psql -U "$ENVIO_PG_USER" -d "$ENVIO_PG_DATABASE" -c \
        "TRUNCATE TABLE public.raw_events CASCADE; UPDATE public.chain_metadata SET start_block = 0, end_block = NULL, first_event_block_number = NULL, latest_processed_block = NULL, num_events_processed = 0, is_hyper_sync = false, num_batches_fetched = 0, latest_fetched_block_number = 0, timestamp_caught_up_to_head_or_endblock = NULL;" 2>/dev/null || true

    log "Indexer state reset"
}

start_indexer() {
    log "Starting indexer..."

    cd "$INDEXER_DIR/generated"

    # Start indexer in background
    ENVIO_RPC_URL_31337="$RPC_URL" \
    ENVIO_PG_PORT="$ENVIO_PG_PORT" \
    ENVIO_PG_USER="$ENVIO_PG_USER" \
    ENVIO_PG_PASSWORD="$ENVIO_PG_PASSWORD" \
    ENVIO_PG_DATABASE="$ENVIO_PG_DATABASE" \
    TUI_OFF=true \
    pnpm start &
    INDEXER_PID=$!

    log "Indexer started (PID $INDEXER_PID)"
}

wait_for_indexer_sync() {
    log "Waiting for indexer to sync..."

    # Increase timeout to 180 seconds (indexer storage init can take 60+ seconds)
    local retries=90
    local synced=false

    while [[ $retries -gt 0 ]]; do
        # Query GraphQL to check if data exists (using Operator entity from schema)
        local response
        response=$(curl -s --max-time 5 "http://localhost:$HASURA_PORT/v1/graphql" \
            -H "Content-Type: application/json" \
            -d '{"query": "{ Operator(limit: 1) { id } }"}' 2>/dev/null || echo "{}")

        if echo "$response" | grep -q '"Operator"'; then
            synced=true
            break
        fi

        sleep 2
        retries=$((retries - 1))

        # Check if indexer is still running
        if ! kill -0 "$INDEXER_PID" 2>/dev/null; then
            log "ERROR: Indexer process died"
            exit 1
        fi
    done

    if [[ "$synced" == "true" ]]; then
        log "Indexer synced successfully!"
    else
        log "WARNING: Indexer may not be fully synced yet. Check logs if issues occur."
    fi
}

execute_rewards_qa_claims() {
    if [[ "$REWARDS_QA" != "true" ]]; then
        return
    fi

    log "Executing reward claims for QA claim history..."

    local BROADCAST_DIR="$ROOT_DIR/broadcast/LocalTestnet.s.sol/$ANVIL_CHAIN_ID"
    local LATEST_BROADCAST
    LATEST_BROADCAST=$(ls -t "$BROADCAST_DIR"/run-*.json 2>/dev/null | head -1)

    if [[ -z "$LATEST_BROADCAST" ]]; then
        log "WARNING: Could not find broadcast file, skipping reward claims"
        return
    fi

    # Extract Tangle proxy address (2nd ERC1967Proxy deployed)
    local TANGLE_ADDR
    TANGLE_ADDR=$(jq -r '[.transactions[] | select(.contractName == "ERC1967Proxy") | .contractAddress] | .[1]' "$LATEST_BROADCAST" 2>/dev/null || true)

    if [[ -z "$TANGLE_ADDR" || "$TANGLE_ADDR" == "null" ]]; then
        log "WARNING: Could not extract Tangle address, skipping reward claims"
        return
    fi

    # Extract mock token addresses (deployment order: USDC, USDT, DAI, WETH, stETH, wstETH, EIGEN)
    local MOCK_TOKENS
    MOCK_TOKENS=$(jq -r '[.transactions[] | select(.contractName == "MockToken") | .contractAddress] | .[]' "$LATEST_BROADCAST" 2>/dev/null || true)

    local DAI_ADDR WETH_ADDR STETH_ADDR
    DAI_ADDR=$(echo "$MOCK_TOKENS" | sed -n '3p')
    WETH_ADDR=$(echo "$MOCK_TOKENS" | sed -n '4p')
    STETH_ADDR=$(echo "$MOCK_TOKENS" | sed -n '5p')

    # Operator3 private key (Anvil account 4)
    local OP3_KEY="0x47e179ec197488593b187f80a00eb0da91f1b9d0b13f8733639f19c30a34926a"

    log "Tangle: $TANGLE_ADDR"
    log "Claiming DAI ($DAI_ADDR), WETH ($WETH_ADDR), stETH ($STETH_ADDR) from Operator3..."

    # Execute 3 claims from Op3 to create RewardClaim entries in indexer
    # After these claims, Op3 will still have native + USDC + USDT = 3 tokens for batch testing
    cast send "$TANGLE_ADDR" "claimRewards(address)" "$DAI_ADDR" \
        --private-key "$OP3_KEY" --rpc-url "$RPC_URL" >/dev/null 2>&1
    log "  Claimed DAI rewards"

    cast send "$TANGLE_ADDR" "claimRewards(address)" "$WETH_ADDR" \
        --private-key "$OP3_KEY" --rpc-url "$RPC_URL" >/dev/null 2>&1
    log "  Claimed WETH rewards"

    cast send "$TANGLE_ADDR" "claimRewards(address)" "$STETH_ADDR" \
        --private-key "$OP3_KEY" --rpc-url "$RPC_URL" >/dev/null 2>&1
    log "  Claimed stETH rewards"

    log "Waiting for indexer to sync claim events..."
    sleep 5

    # Verify claims were indexed
    local claims_response
    local op3_addr="0x15d34aaf54267db7d7c367839aaf71a00a2c6a65"
    claims_response=$(curl -s --max-time 5 "http://localhost:$HASURA_PORT/v1/graphql" \
        -H "Content-Type: application/json" \
        -d "{\"query\": \"{ RewardClaim(where: {account: {_eq: \\\"$op3_addr\\\"}}) { id token amount } }\"}" 2>/dev/null || echo "{}")

    if echo "$claims_response" | grep -q '"RewardClaim"'; then
        local claim_count
        claim_count=$(echo "$claims_response" | jq '.data.RewardClaim | length' 2>/dev/null || echo "0")
        log "Reward claims indexed: $claim_count entries for Op3"
    else
        log "WARNING: Could not verify indexed claims (indexer may need more time)"
    fi

    log "Rewards QA claims complete"
}

verify_setup() {
    log "Verifying setup..."

    # Check GraphQL endpoint
    local response
    response=$(curl -s "http://localhost:$HASURA_PORT/v1/graphql" \
        -H "Content-Type: application/json" \
        -d '{"query": "{ Operator(limit: 5) { id restakingStatus } RestakingAsset(limit: 5) { id enabled } }"}')

    if echo "$response" | grep -q '"data"'; then
        # grep -c returns count (0 if no matches), || true prevents exit on no matches
        local operator_count
        operator_count=$(echo "$response" | grep -c '"id"' || true)
        log "✓ GraphQL responding (found $operator_count entities)"
        log "  Response: $response"
    else
        log "⚠ GraphQL endpoint not returning expected data"
        log "  Response: $response"
    fi
}

clean_all() {
    log "Cleaning all local development artifacts..."

    # Stop Docker containers
    cd "$INDEXER_DIR/generated" 2>/dev/null && docker compose down -v 2>/dev/null || true

    # Remove broadcast artifacts
    rm -rf "$ROOT_DIR/broadcast/LocalTestnet.s.sol" || true

    # Remove indexer state
    rm -f "$INDEXER_DIR/generated/persisted_state.envio.json" || true

    # Kill any running processes on our ports
    # Use pkill instead of lsof which can hang on macOS
    # Use specific patterns to avoid killing unrelated processes
    pkill -f "anvil.*--port.*$ANVIL_PORT" 2>/dev/null || true
    pkill -f "graphql-engine.*--server-port.*$HASURA_PORT" 2>/dev/null || true

    log "Done. Run './start-local-dev.sh' to start fresh."
}

show_summary() {
    log ""
    log "=========================================="
    log "  Local Development Environment Ready!"
    log "=========================================="
    log ""
    log "Services:"
    log "  Anvil RPC:      $RPC_URL"
    log "  GraphQL API:    http://localhost:$HASURA_PORT/v1/graphql"
    log "  Hasura Console: http://localhost:$HASURA_PORT/console"
    log ""
    log "Test Accounts (pre-funded with ETH + tokens):"
    log "  Deployer:              0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"
    log "  Operator1 (Disabled):  0x70997970C51812dc3A010C7d01b50e0d17dc79C8"
    log "  Operator2 (Open):      0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC"
    log "  Operator3 (Whitelist): 0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65"
    log "  Delegator:             0x90F79bf6EB2c4f870365E785982E1f101E93b906"
    log "  Whitelisted Delegator: 0x9965507D1a55bcC2695C58ba16FB37d819B0A4dc"
    log ""
    log "Delegation Modes:"
    log "  Operator1: Disabled - only self-stake allowed"
    log "  Operator2: Open     - anyone can delegate"
    log "  Operator3: Whitelist - only whitelisted delegators (Account 5 whitelisted)"
    log ""
    log "What's running:"
    log "  ✓ Anvil (local EVM chain)"
    log "  ✓ PostgreSQL (indexer database)"
    log "  ✓ Hasura (GraphQL engine)"
    log "  ✓ Envio indexer (syncing blockchain data)"
    log ""
    log "What's deployed:"
    log "  ✓ Core contracts (Tangle, MultiAssetDelegation, etc.)"
    log "  ✓ Mock tokens (USDC, USDT, DAI, WETH, stETH, wstETH, EIGEN)"
    log "  ✓ Incentive contracts (Metrics, RewardVaults, InflationPool)"
    log "  ✓ 3 registered operators with different delegation modes"
    if [[ "$SUBSCRIPTION_MODE" == "true" ]]; then
        log "  ✓ 1 test blueprint (Subscription: 0.1 ETH per 60s interval)"
    else
        log "  ✓ 1 test blueprint (PayOnce)"
    fi
    if [[ "$MULTIPLE_INSTANCES" == "true" ]]; then
        log "  ✓ 3 active services (multiple instances mode)"
    else
        log "  ✓ 1 active service"
    fi
    if [[ "$SUBSCRIPTION_MODE" == "true" ]]; then
        log "  ✓ Service escrow funded with 1 ETH (covers ~10 billing cycles)"
    fi
    log "  ✓ Delegations (ETH + ERC20)"
    log "  ✓ Seeded rewards for testing"
    if [[ "$SERVICE_LEAVABLE" == "true" ]]; then
        log "  ✓ Time advanced past min commitment (operators can schedule exit)"
    fi
    if [[ "$REWARDS_QA" == "true" ]]; then
        log ""
        log "Rewards QA State (Tangle Payments system):"
        log "  Operator1 (0x70997970C51812dc3A010C7d01b50e0d17dc79C8):"
        log "    Pending: 10 ETH (native only)"
        log "  Operator2 (0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC):"
        log "    Pending: 5000 USDC (ERC20 only)"
        log "  Operator3 (0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65):"
        log "    Pending: native + USDC + USDT (3 tokens, for batch claim testing)"
        log "    Claimed: DAI + WETH + stETH (3 entries in claim history)"
        log ""
        log "  Covers: RWD-001 to RWD-009 scenarios from QA plan"
        log "  Payment split: 20% dev, 5% protocol, 65% operator, 10% staker"
        log ""
        log "Earnings QA State (DeveloperPayment entries):"
        log "  Blueprint owner (deployer): 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266"
        log "  Developer payouts: 8 entries across 6 tokens (ETH, USDC, USDT, DAI, WETH, stETH)"
        log "  Payment split: 20% dev, 5% protocol, 65% operator, 10% staker"
    fi
    log ""
    log "Press Ctrl+C to stop all services"
    log ""
}

main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            clean)
                clean_all
                exit 0
                ;;
            --help|-h)
                echo "Usage: $0 [command] [options]"
                echo ""
                echo "Commands:"
                echo "  (none)    Start the full local development environment"
                echo "  clean     Stop all services and clean artifacts"
                echo "  --help    Show this help message"
                echo ""
                echo "Options:"
                echo "  --multiple-instances    Create 3 service instances instead of 1"
                echo "  --subscription          Create subscription blueprint (0.1 ETH/60s) instead of PayOnce"
                echo "  --service-leavable      Advance time past min commitment so operators can schedule exit"
                echo "  --with-rewards          Seed Tangle Payments rewards for frontend QA testing"
                echo "                          Op1=native-only, Op2=ERC20-only, Op3=multi-token + claim history"
                exit 0
                ;;
            --multiple-instances)
                MULTIPLE_INSTANCES="true"
                shift
                ;;
            --subscription)
                SUBSCRIPTION_MODE="true"
                shift
                ;;
            --service-leavable)
                SERVICE_LEAVABLE="true"
                shift
                ;;
            --with-rewards)
                REWARDS_QA="true"
                shift
                ;;
            *)
                log "Unknown argument: $1"
                log "Use --help for usage information"
                exit 1
                ;;
        esac
    done

    check_prerequisites
    ensure_anvil
    deploy_multicall3
    run_local_testnet_setup
    advance_time_for_leavable
    start_docker
    setup_indexer
    start_indexer
    wait_for_indexer_sync
    execute_rewards_qa_claims
    verify_setup
    show_summary

    # Keep running until Ctrl+C
    if [[ -n "$ANVIL_PID" ]]; then
        wait "$ANVIL_PID"
    elif [[ -n "$INDEXER_PID" ]]; then
        wait "$INDEXER_PID"
    else
        # If neither was started by us, just wait indefinitely
        log "All services running. Press Ctrl+C to stop."
        while true; do sleep 3600; done
    fi
}

main "$@"
