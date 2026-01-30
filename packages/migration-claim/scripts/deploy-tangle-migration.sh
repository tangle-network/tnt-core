#!/bin/bash
# Deploy Tangle Migration contracts to local testnet or Base Sepolia
#
# This deploys:
# 1. TNT Token (ERC20)
# 2. ZK Verifier (Mock for testing, SP1 for production)
# 3. TangleMigration contract (with merkle root and funding)
#
# Prerequisites:
# - Foundry installed
# - Local testnet running (or Base Sepolia RPC URL)
#
# Usage:
#   ./scripts/deploy-tangle-migration.sh              # Local testnet with mock verifier
#   ./scripts/deploy-tangle-migration.sh --production # Base Sepolia with SP1 verifier

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

# Check for production flag
PRODUCTION=false
if [[ "$1" == "--production" ]]; then
    PRODUCTION=true
fi

echo "============================================"
echo "Tangle Migration Deployment"
echo "============================================"

# Check prerequisites
command -v forge >/dev/null 2>&1 || { echo "Error: Foundry not installed"; exit 1; }

# Configuration
if [ "$PRODUCTION" = true ]; then
    RPC_URL="${RPC_URL:-https://sepolia.base.org}"
    USE_MOCK_VERIFIER=false
    echo "Mode: PRODUCTION (Base Sepolia)"
else
    RPC_URL="${RPC_URL:-http://localhost:8545}"
    USE_MOCK_VERIFIER=true
    echo "Mode: LOCAL TESTING (Mock Verifier)"
fi

# PRIVATE_KEY is required
if [ -z "$PRIVATE_KEY" ]; then
    echo "Error: PRIVATE_KEY environment variable is required"
    echo "Usage: PRIVATE_KEY=0x... $0 [--production]"
    exit 1
fi

# PROGRAM_VKEY is required in production mode
if [ "$PRODUCTION" = true ] && [ -z "$PROGRAM_VKEY" ]; then
    echo "Error: PROGRAM_VKEY environment variable is required in production mode"
    echo "Usage: PRIVATE_KEY=0x... PROGRAM_VKEY=0x... $0 --production"
    exit 1
fi

echo ""
echo "Configuration:"
echo "  RPC URL: $RPC_URL"
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

# Read total EVM allocation from evm-claims.json
if [ -f "$ROOT_DIR/evm-claims.json" ]; then
    TOTAL_EVM=$(grep -o '"totalAmount": "[0-9]*"' "$ROOT_DIR/evm-claims.json" | grep -o '[0-9]*')
    echo "Total EVM: $TOTAL_EVM"
else
    echo "Error: evm-claims.json not found at $ROOT_DIR"
    echo "Please run the migration snapshot generator first."
    exit 1
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
USE_MOCK_VERIFIER="$USE_MOCK_VERIFIER" \
ALLOW_STANDALONE_TOKEN="true" \
PRIVATE_KEY="$PRIVATE_KEY" \
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
echo "Next Steps:"
echo "  1. Copy entries from merkle-tree.json to frontend (note: just entries field): "
echo "     jq '.entries' $ROOT_DIR/merkle-tree.json > <path to frontend repo>/apps/tangle-dapp/public/data/migration-proofs.json"
echo ""
echo "  2. Execute EVM airdrop (separate step):"
echo "     The evm-airdrop.json contains 7,124 accounts totaling ~1.13M TNT"
echo "     Use a batch transfer tool to distribute these tokens."
echo ""
