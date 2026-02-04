#!/bin/bash
# Deploy Tangle Migration contracts to local testnet, Base Sepolia, or KiteAI Testnet
#
# This deploys:
# 1. TNT Token (ERC20)
# 2. ZK Verifier (Mock for testing, SP1 for production)
# 3. TangleMigration contract (with merkle root and funding)
# 4. Treasury vesting (if TREASURY_RECIPIENT set)
# 5. Foundation vesting (if FOUNDATION_RECIPIENT set)
# 6. Liquidity ops transfer (if LIQUIDITY_OPS_RECIPIENT set)
#
# Reads allocations from JSON files:
# - merkle-tree.json: Substrate claims (merkle root + total)
# - evm-claims.json: EVM claims (may be 0 if excluded)
# - treasury-carveout.json: Treasury allocation
# - foundation-carveout.json: Foundation allocation
# - liquidity-ops-carveout.json: Liquidity ops allocation
#
# Prerequisites:
# - Foundry installed
# - Local testnet running (or Base Sepolia/KiteAI RPC URL)
# - Run deploy-with-snapshot.ts first to generate JSON files
#
# Environment Variables:
#   PRIVATE_KEY (required)
#   TREASURY_RECIPIENT - Address to receive treasury allocation (vested)
#   FOUNDATION_RECIPIENT - Address to receive foundation allocation
#   LIQUIDITY_OPS_RECIPIENT - Address to receive liquidity ops allocation
#   PROGRAM_VKEY - SP1 program verification key (required for --base-sepolia, --kite-testnet)
#   SP1_VERIFIER - SP1 verifier gateway address (required for --kite-testnet)
#
# Usage:
#   ./scripts/deploy-tangle-migration.sh                  # Local testnet with mock verifier
#   ./scripts/deploy-tangle-migration.sh --base-sepolia    # Base Sepolia with SP1 verifier
#   ./scripts/deploy-tangle-migration.sh --kite-testnet   # KiteAI Testnet with SP1 verifier

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

# Default network is local
NETWORK="local"
USE_MOCK_VERIFIER=true

# Parse arguments
for arg in "$@"; do
    case $arg in
        --base-sepolia)
            NETWORK="base-sepolia"
            USE_MOCK_VERIFIER=false
            ;;
        --kite-testnet)
            NETWORK="kite-testnet"
            USE_MOCK_VERIFIER=false
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --base-sepolia    Deploy to Base Sepolia testnet"
            echo "  --kite-testnet    Deploy to KiteAI Testnet (Chain ID: 2368)"
            echo "  --help, -h       Show this help message"
            echo ""
            echo "Default: Deploy to local testnet with mock verifier"
            echo ""
            echo "Required environment variables:"
            echo "  PRIVATE_KEY      Deployer private key"
            echo ""
            echo "Required for --base-sepolia and --kite-testnet:"
            echo "  PROGRAM_VKEY     SP1 program verification key"
            echo ""
            echo "Required for --kite-testnet:"
            echo "  SP1_VERIFIER     SP1 verifier gateway address"
            echo "                   Deploy with: ./scripts/deploy-sp1-gateway.sh"
            exit 0
            ;;
    esac
done

# Network-specific configuration
case $NETWORK in
    local)
        RPC_URL="${RPC_URL:-http://localhost:8545}"
        SP1_VERIFIER_DEFAULT=""
        CHAIN_NAME="Local Testnet"
        ;;
    base-sepolia)
        RPC_URL="${RPC_URL:-https://sepolia.base.org}"
        # Base Sepolia has SP1 verifier gateway deployed by Succinct
        SP1_VERIFIER_DEFAULT="0x397A5f7f3dBd538f23DE225B51f532c34448dA9B"
        CHAIN_NAME="Base Sepolia"
        ;;
    kite-testnet)
        RPC_URL="${RPC_URL:-https://rpc-testnet.gokite.ai/}"
        # KiteAI requires custom SP1 deployment - no default
        SP1_VERIFIER_DEFAULT="${SP1_VERIFIER:-}"
        CHAIN_NAME="KiteAI Testnet"
        ;;
esac

echo "============================================"
echo "Tangle Migration Deployment"
echo "============================================"
echo "Network: $CHAIN_NAME"

if [ "$USE_MOCK_VERIFIER" = true ]; then
    echo "Mode: LOCAL TESTING (Mock Verifier)"
else
    echo "Mode: PRODUCTION (SP1 Verifier)"
fi

# Check prerequisites
command -v forge >/dev/null 2>&1 || { echo "Error: Foundry not installed"; exit 1; }

# PRIVATE_KEY is required
if [ -z "$PRIVATE_KEY" ]; then
    echo "Error: PRIVATE_KEY environment variable is required"
    echo "Usage: PRIVATE_KEY=0x... $0 [--base-sepolia|--kite]"
    exit 1
fi

# PROGRAM_VKEY is required in production mode
if [ "$USE_MOCK_VERIFIER" = false ] && [ -z "$PROGRAM_VKEY" ]; then
    echo "Error: PROGRAM_VKEY environment variable is required for $CHAIN_NAME"
    echo ""
    echo "Generate the vkey with:"
    echo "  cd sp1/program && cargo prove build"
    echo "  cd .. && cargo +succinct run --release -p sr25519-claim-script --bin vkey"
    echo ""
    echo "Usage: PRIVATE_KEY=0x... PROGRAM_VKEY=0x... $0 --$NETWORK"
    exit 1
fi

# SP1_VERIFIER is required for KiteAI (no default)
if [ "$NETWORK" = "kite-testnet" ] && [ -z "$SP1_VERIFIER_DEFAULT" ]; then
    echo "Error: SP1_VERIFIER environment variable is required for KiteAI Testnet"
    echo ""
    echo "KiteAI doesn't have a pre-deployed SP1 verifier. Deploy one first:"
    echo "  PRIVATE_KEY=0x... RPC_URL=https://rpc-testnet.gokite.ai/ \\"
    echo "    ./scripts/deploy-sp1-gateway.sh"
    echo ""
    echo "Then use the deployed gateway address:"
    echo "  PRIVATE_KEY=0x... PROGRAM_VKEY=0x... SP1_VERIFIER=0x<gateway> \\"
    echo "    $0 --kite-testnet"
    exit 1
fi

# Use environment SP1_VERIFIER if set, otherwise use default for the network
SP1_VERIFIER="${SP1_VERIFIER:-$SP1_VERIFIER_DEFAULT}"

echo ""
echo "Configuration:"
echo "  RPC URL: $RPC_URL"
if [ "$USE_MOCK_VERIFIER" = false ]; then
    echo "  SP1 Verifier: $SP1_VERIFIER"
fi
echo ""

# Check RPC connection
if ! cast block-number --rpc-url "$RPC_URL" >/dev/null 2>&1; then
    echo "Error: Cannot connect to RPC at $RPC_URL"
    exit 1
fi

# Read merkle root and total substrate allocation from the generated tree
if [ -f "$ROOT_DIR/merkle-tree.json" ]; then
    MERKLE_ROOT=$(grep -o '"root": "0x[a-fA-F0-9]\{64\}"' "$ROOT_DIR/merkle-tree.json" | grep -o '0x[a-fA-F0-9]\{64\}')
    TOTAL_SUBSTRATE=$(grep -o '"totalValue": "[0-9]*"' "$ROOT_DIR/merkle-tree.json" | grep -o '[0-9]*')
    echo "Merkle Root: $MERKLE_ROOT"
    echo "Total Substrate: $TOTAL_SUBSTRATE"
else
    echo "Error: merkle-tree.json not found at $ROOT_DIR"
    echo "Please run the migration snapshot generator first."
    exit 1
fi

# Read total EVM allocation from evm-claims.json (may be 0 if claims excluded)
if [ -f "$ROOT_DIR/evm-claims.json" ]; then
    TOTAL_EVM=$(grep -o '"totalAmount": "[0-9]*"' "$ROOT_DIR/evm-claims.json" | grep -o '[0-9]*')
    if [ -z "$TOTAL_EVM" ]; then
        TOTAL_EVM="0"
    fi
    echo "Total EVM: $TOTAL_EVM"
else
    echo "Warning: evm-claims.json not found, setting TOTAL_EVM=0"
    TOTAL_EVM="0"
fi

# Read treasury carveout from treasury-carveout.json
if [ -f "$ROOT_DIR/treasury-carveout.json" ]; then
    TREASURY_AMOUNT=$(grep -o '"amount": "[0-9]*"' "$ROOT_DIR/treasury-carveout.json" | grep -o '[0-9]*')
    echo "Treasury Amount: $TREASURY_AMOUNT"
else
    echo "Warning: treasury-carveout.json not found"
    TREASURY_AMOUNT="0"
fi

# Read foundation carveout from foundation-carveout.json
if [ -f "$ROOT_DIR/foundation-carveout.json" ]; then
    FOUNDATION_AMOUNT=$(grep -o '"amount": "[0-9]*"' "$ROOT_DIR/foundation-carveout.json" | grep -o '[0-9]*')
    echo "Foundation Amount: $FOUNDATION_AMOUNT"
else
    echo "Warning: foundation-carveout.json not found"
    FOUNDATION_AMOUNT="0"
fi

# Read liquidity ops carveout from liquidity-ops-carveout.json
if [ -f "$ROOT_DIR/liquidity-ops-carveout.json" ]; then
    LIQUIDITY_OPS_AMOUNT=$(grep -o '"amount": "[0-9]*"' "$ROOT_DIR/liquidity-ops-carveout.json" | grep -o '[0-9]*')
    echo "Liquidity Ops Amount: $LIQUIDITY_OPS_AMOUNT"
else
    LIQUIDITY_OPS_AMOUNT="0"
fi

cd "$ROOT_DIR"

# Check dependencies exist (managed at repo root level)
DEPS_DIR="$ROOT_DIR/../../dependencies"
if [ ! -d "$DEPS_DIR/forge-std" ]; then
    echo "Error: forge-std not found in $DEPS_DIR"
    echo "Run 'forge soldeer update' from the repository root first."
    exit 1
fi

# Build contracts
echo ""
echo "Building contracts..."
forge build

# Deploy
echo ""
echo "Deploying contracts..."

MERKLE_ROOT="$MERKLE_ROOT" \
TOTAL_SUBSTRATE="$TOTAL_SUBSTRATE" \
TOTAL_EVM="$TOTAL_EVM" \
TREASURY_AMOUNT="$TREASURY_AMOUNT" \
TREASURY_RECIPIENT="${TREASURY_RECIPIENT:-}" \
FOUNDATION_AMOUNT="$FOUNDATION_AMOUNT" \
FOUNDATION_RECIPIENT="${FOUNDATION_RECIPIENT:-}" \
LIQUIDITY_OPS_AMOUNT="$LIQUIDITY_OPS_AMOUNT" \
LIQUIDITY_OPS_RECIPIENT="${LIQUIDITY_OPS_RECIPIENT:-}" \
USE_MOCK_VERIFIER="$USE_MOCK_VERIFIER" \
ALLOW_STANDALONE_TOKEN="true" \
PRIVATE_KEY="$PRIVATE_KEY" \
SP1_VERIFIER="${SP1_VERIFIER:-0x397A5f7f3dBd538f23DE225B51f532c34448dA9B}" \
PROGRAM_VKEY="${PROGRAM_VKEY:-0x0043b75837095121e5cfc178612414bddea823bad5aa08f3061b15b49c63a99f}" \
forge script script/DeployTangleMigration.s.sol:DeployTangleMigration \
    --rpc-url "$RPC_URL" \
    --broadcast \
    -vvv

# Extract deployed addresses
BROADCAST_FILE=$(ls -t broadcast/DeployTangleMigration.s.sol/*/run-latest.json 2>/dev/null | head -1)

if [ -f "$BROADCAST_FILE" ]; then
    TNT_ADDRESS=$(grep -o '"contractName": "TNT"' -A5 "$BROADCAST_FILE" | grep '"contractAddress"' | head -1 | grep -o '0x[a-fA-F0-9]\{40\}')
    MIGRATION_ADDRESS=$(grep -o '"contractName": "TangleMigration"' -A5 "$BROADCAST_FILE" | grep '"contractAddress"' | head -1 | grep -o '0x[a-fA-F0-9]\{40\}')
    VERIFIER_ADDRESS=$(grep -o '"contractName": "MockZKVerifier\|SP1ZKVerifier"' -A5 "$BROADCAST_FILE" | grep '"contractAddress"' | head -1 | grep -o '0x[a-fA-F0-9]\{40\}')
fi

echo ""
echo "============================================"
echo "Deployment Complete!"
echo "============================================"
echo ""
echo "Network: $CHAIN_NAME"
echo ""
echo "Contract Addresses:"
echo "  TNT Token: $TNT_ADDRESS"
echo "  TangleMigration: $MIGRATION_ADDRESS"
echo "  ZK Verifier: $VERIFIER_ADDRESS"
echo ""
echo "Merkle Root: $MERKLE_ROOT"
echo ""
echo "Frontend Environment Variables (.env.local):"
echo "  VITE_TNT_TOKEN_ADDRESS=$TNT_ADDRESS"
echo "  VITE_TANGLE_MIGRATION_ADDRESS=$MIGRATION_ADDRESS"
echo "  VITE_ZK_VERIFIER_ADDRESS=$VERIFIER_ADDRESS"
echo "  VITE_MIGRATION_MERKLE_ROOT=$MERKLE_ROOT"
echo ""

# Network-specific next steps
case $NETWORK in
    kite-testnet)
        echo "Claim Relayer Configuration:"
        echo "  CHAIN_ID=2368"
        echo "  RPC_URL=https://rpc-testnet.gokite.ai/"
        echo "  MIGRATION_CONTRACT=$MIGRATION_ADDRESS"
        echo ""
        echo "Block Explorer:"
        echo "  https://testnet.kitescan.ai/address/$MIGRATION_ADDRESS"
        echo ""
        ;;
    base-sepolia)
        echo "Claim Relayer Configuration:"
        echo "  CHAIN_ID=84532"
        echo "  RPC_URL=https://sepolia.base.org"
        echo "  MIGRATION_CONTRACT=$MIGRATION_ADDRESS"
        echo ""
        echo "Block Explorer:"
        echo "  https://sepolia.basescan.org/address/$MIGRATION_ADDRESS"
        echo ""
        ;;
esac

echo "Next Steps:"
echo "  1. Copy entries from merkle-tree.json to frontend (note: just entries field): "
echo "     jq '.entries' $ROOT_DIR/merkle-tree.json > <path to frontend repo>/apps/tangle-dapp/public/data/migration-proofs.json"
echo ""
if [ "$TOTAL_EVM" != "0" ]; then
    echo "  2. Execute EVM airdrop (separate step):"
    echo "     The evm-claims.json contains accounts for direct minting."
    echo "     Use a batch transfer tool to distribute these tokens."
    echo ""
else
    echo "  2. No EVM airdrop needed (TOTAL_EVM=0, claims excluded)"
    echo ""
fi
