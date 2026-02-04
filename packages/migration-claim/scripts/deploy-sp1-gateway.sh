#!/bin/bash
# Deploy SP1 infrastructure (Gateway + Verifier v5.0.0) to any EVM chain
#
# This is a one-time deployment per chain. The deployed SP1VerifierGateway address
# should be used as SP1_VERIFIER when deploying the migration contracts.
#
# Prerequisites:
# - Foundry installed
# - Native tokens for gas (KITE for KiteAI, ETH for Base Sepolia, etc.)
#
# Environment Variables:
#   PRIVATE_KEY (required) - Deployer private key
#   OWNER (optional) - Gateway owner address, defaults to deployer
#   RPC_URL (required) - RPC endpoint for the target chain
#
# Usage:
#   # KiteAI Testnet
#   PRIVATE_KEY=0x... RPC_URL=https://rpc-testnet.gokite.ai/ ./scripts/deploy-sp1-gateway.sh
#
#   # Base Sepolia (already has SP1 deployed, but can deploy custom if needed)
#   PRIVATE_KEY=0x... RPC_URL=https://sepolia.base.org ./scripts/deploy-sp1-gateway.sh
#
#   # Local Anvil
#   PRIVATE_KEY=0x... RPC_URL=http://localhost:8545 ./scripts/deploy-sp1-gateway.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

echo "============================================"
echo "SP1 Infrastructure Deployment"
echo "============================================"

# Check prerequisites
command -v forge >/dev/null 2>&1 || { echo "Error: Foundry not installed"; exit 1; }

# Validate required environment variables
if [ -z "$PRIVATE_KEY" ]; then
    echo "Error: PRIVATE_KEY environment variable is required"
    echo ""
    echo "Usage:"
    echo "  PRIVATE_KEY=0x... RPC_URL=<rpc-url> $0"
    exit 1
fi

if [ -z "$RPC_URL" ]; then
    echo "Error: RPC_URL environment variable is required"
    echo ""
    echo "Usage:"
    echo "  PRIVATE_KEY=0x... RPC_URL=<rpc-url> $0"
    exit 1
fi

echo ""
echo "Configuration:"
echo "  RPC URL: $RPC_URL"
if [ -n "$OWNER" ]; then
    echo "  Owner: $OWNER"
else
    echo "  Owner: (deployer address)"
fi
echo ""

# Check RPC connection
if ! cast block-number --rpc-url "$RPC_URL" >/dev/null 2>&1; then
    echo "Error: Cannot connect to RPC at $RPC_URL"
    exit 1
fi

# Get chain ID for logging
CHAIN_ID=$(cast chain-id --rpc-url "$RPC_URL")
echo "Connected to chain ID: $CHAIN_ID"
echo ""

cd "$ROOT_DIR"

# Check dependencies exist (managed at repo root level)
DEPS_DIR="$ROOT_DIR/../../dependencies"
if [ ! -d "$DEPS_DIR/forge-std" ]; then
    echo "Error: forge-std not found in $DEPS_DIR"
    echo "Run 'forge soldeer update' from the repository root first."
    exit 1
fi

# Build contracts
echo "Building contracts..."
forge build

# Deploy
echo ""
echo "Deploying SP1 infrastructure..."

PRIVATE_KEY="$PRIVATE_KEY" \
OWNER="${OWNER:-}" \
forge script script/DeploySP1Infrastructure.s.sol:DeploySP1Infrastructure \
    --rpc-url "$RPC_URL" \
    --broadcast \
    -vvv

# Extract deployed addresses from broadcast
BROADCAST_FILE=$(ls -t broadcast/DeploySP1Infrastructure.s.sol/*/run-latest.json 2>/dev/null | head -1)

if [ -f "$BROADCAST_FILE" ]; then
    GATEWAY_ADDRESS=$(grep -o '"contractName": "SP1VerifierGateway"' -A5 "$BROADCAST_FILE" | grep '"contractAddress"' | head -1 | grep -o '0x[a-fA-F0-9]\{40\}')
    VERIFIER_ADDRESS=$(grep -o '"contractName": "SP1Verifier"' -A5 "$BROADCAST_FILE" | grep '"contractAddress"' | head -1 | grep -o '0x[a-fA-F0-9]\{40\}')

    echo ""
    echo "============================================"
    echo "Deployment Summary"
    echo "============================================"
    echo ""
    echo "Chain ID: $CHAIN_ID"
    echo ""
    echo "Deployed Contracts:"
    echo "  SP1VerifierGateway: $GATEWAY_ADDRESS"
    echo "  SP1Verifier v5.0.0: $VERIFIER_ADDRESS"
    echo ""
    echo "============================================"
    echo "Next Steps"
    echo "============================================"
    echo ""
    echo "Use the gateway address when deploying migration contracts:"
    echo ""
    echo "  export SP1_VERIFIER=$GATEWAY_ADDRESS"
    echo ""
    echo "Then run:"
    echo "  PRIVATE_KEY=0x... PROGRAM_VKEY=0x... SP1_VERIFIER=$GATEWAY_ADDRESS \\"
    echo "    ./scripts/deploy-tangle-migration.sh --kite"
    echo ""
fi
