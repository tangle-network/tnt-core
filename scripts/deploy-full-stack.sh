#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════════
# One-Click Shielded Pool Deployment
# ═══════════════════════════════════════════════════════════════════════════════
#
# Deploys the complete shielded payment stack to a single chain:
#   1. Poseidon libraries (circomlibjs bytecode)
#   2. PoseidonHasher (Forge, linked to Poseidon libraries)
#   3. Verifier contracts (Forge, from ceremony output)
#   4. VAnchorVerifier (Forge, routes to sub-verifiers)
#   5. Full pool stack (Forge: TokenWrapper, AnchorHandler, VAnchorTree,
#      ShieldedCredits, ShieldedGateway)
#   6. Register stablecoins
#
# Prerequisites:
#   - Circuit artifacts: run scripts/trusted-setup/ceremony.sh first
#   - Node.js + circomlibjs: npm i -g circomlibjs ethers
#   - Forge installed
#   - Environment variables set (see below)
#
# Usage:
#   export RPC_URL=https://sepolia.base.org
#   export PRIVATE_KEY=0x...
#   export TANGLE=0x...  # Tangle proxy address on this chain
#   export CHAIN_NAME=base-sepolia  # for config file lookup
#   ./scripts/deploy-full-stack.sh
#
# ═══════════════════════════════════════════════════════════════════════════════
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

# ─── Validate env ──────────────────────────────────────────────────────────
: "${RPC_URL:?Set RPC_URL}"
: "${PRIVATE_KEY:?Set PRIVATE_KEY}"
: "${TANGLE:?Set TANGLE (Tangle proxy address)}"
CHAIN_NAME="${CHAIN_NAME:-base-sepolia}"
CEREMONY_DIR="${CEREMONY_DIR:-$ROOT_DIR/build/trusted-setup}"

echo "═══════════════════════════════════════════════════════════════"
echo "  Shielded Pool Full Stack Deployment"
echo "═══════════════════════════════════════════════════════════════"
echo "  Chain:    $CHAIN_NAME"
echo "  RPC:      $RPC_URL"
echo "  Tangle:   $TANGLE"
echo ""

# ─── Step 1: Deploy Poseidon libraries ─────────────────────────────────────
echo "Step 1: Deploying Poseidon libraries..."
CHAIN_ID=$(cast chain-id --rpc-url "$RPC_URL")
POSEIDON_FILE="$ROOT_DIR/deploy/output/poseidon-${CHAIN_ID}.json"

if [ -f "$POSEIDON_FILE" ]; then
    echo "  Poseidon already deployed (found $POSEIDON_FILE)"
else
    RPC_URL="$RPC_URL" PRIVATE_KEY="$PRIVATE_KEY" \
        node "$SCRIPT_DIR/deploy-poseidon.mjs"
fi

# Read Poseidon addresses
POSEIDON_T3=$(jq -r '.PoseidonT3' "$POSEIDON_FILE")
echo "  PoseidonT3: $POSEIDON_T3"

# ─── Step 2: Deploy PoseidonHasher ─────────────────────────────────────────
echo ""
echo "Step 2: Deploying PoseidonHasher..."
HASHER_FILE="$ROOT_DIR/deploy/output/hasher-${CHAIN_ID}.json"

if [ -f "$HASHER_FILE" ]; then
    POSEIDON_HASHER=$(jq -r '.address' "$HASHER_FILE")
    echo "  PoseidonHasher already deployed: $POSEIDON_HASHER"
else
    # Deploy PoseidonHasher with library linking
    # The PoseidonHasher uses PoseidonT2-T6 as libraries
    POSEIDON_T2=$(jq -r '.PoseidonT2' "$POSEIDON_FILE")
    POSEIDON_T4=$(jq -r '.PoseidonT4' "$POSEIDON_FILE")
    POSEIDON_T5=$(jq -r '.PoseidonT5' "$POSEIDON_FILE")
    POSEIDON_T6=$(jq -r '.PoseidonT6' "$POSEIDON_FILE")

    POSEIDON_HASHER=$(forge create \
        --rpc-url "$RPC_URL" \
        --private-key "$PRIVATE_KEY" \
        --json \
        --libraries "protocol-solidity/hashers/Poseidon.sol:PoseidonT2:$POSEIDON_T2" \
        --libraries "protocol-solidity/hashers/Poseidon.sol:PoseidonT3:$POSEIDON_T3" \
        --libraries "protocol-solidity/hashers/Poseidon.sol:PoseidonT4:$POSEIDON_T4" \
        --libraries "protocol-solidity/hashers/Poseidon.sol:PoseidonT5:$POSEIDON_T5" \
        --libraries "protocol-solidity/hashers/Poseidon.sol:PoseidonT6:$POSEIDON_T6" \
        "protocol-solidity/hashers/PoseidonHasher.sol:PoseidonHasher" \
        | jq -r '.deployedTo')

    mkdir -p "$(dirname "$HASHER_FILE")"
    echo "{\"address\": \"$POSEIDON_HASHER\"}" > "$HASHER_FILE"
    echo "  PoseidonHasher deployed: $POSEIDON_HASHER"
fi

# ─── Step 3: Deploy Verifiers ──────────────────────────────────────────────
echo ""
echo "Step 3: Deploying Verifier contracts..."
VERIFIER_FILE="$ROOT_DIR/deploy/output/verifiers-${CHAIN_ID}.json"

if [ -f "$VERIFIER_FILE" ]; then
    echo "  Verifiers already deployed (found $VERIFIER_FILE)"
    VANCHOR_VERIFIER=$(jq -r '.vanchorVerifier' "$VERIFIER_FILE")
else
    VERIFIERS_DIR="$CEREMONY_DIR/verifiers"
    if [ ! -d "$VERIFIERS_DIR" ]; then
        echo "  ERROR: No verifier contracts found at $VERIFIERS_DIR"
        echo "  Run scripts/trusted-setup/ceremony.sh first"
        exit 1
    fi

    # Deploy individual verifiers (2-input and 16-input for 8-edge circuits)
    echo "  Deploying Verifier8_2..."
    V8_2=$(forge create --rpc-url "$RPC_URL" --private-key "$PRIVATE_KEY" --json \
        "$VERIFIERS_DIR/poseidon_vanchor_2_8_verifier.sol:Verifier8_2" \
        | jq -r '.deployedTo')

    echo "  Deploying Verifier8_16..."
    V8_16=$(forge create --rpc-url "$RPC_URL" --private-key "$PRIVATE_KEY" --json \
        "$VERIFIERS_DIR/poseidon_vanchor_16_8_verifier.sol:Verifier8_16" \
        | jq -r '.deployedTo')

    # Deploy VAnchorVerifier (routes to sub-verifiers)
    echo "  Deploying VAnchorVerifier..."
    # Constructor: (v2_2, v2_16, v8_2, v8_16)
    # We only have 8-edge verifiers; 2-edge slots get zero address
    VANCHOR_VERIFIER=$(forge create --rpc-url "$RPC_URL" --private-key "$PRIVATE_KEY" --json \
        "protocol-solidity/verifiers/VAnchorVerifier.sol:VAnchorVerifier" \
        --constructor-args "0x0000000000000000000000000000000000000000" "0x0000000000000000000000000000000000000000" "$V8_2" "$V8_16" \
        | jq -r '.deployedTo')

    mkdir -p "$(dirname "$VERIFIER_FILE")"
    echo "{\"v8_2\": \"$V8_2\", \"v8_16\": \"$V8_16\", \"vanchorVerifier\": \"$VANCHOR_VERIFIER\"}" > "$VERIFIER_FILE"
    echo "  VAnchorVerifier: $VANCHOR_VERIFIER"
fi

# ─── Step 4: Deploy pool stack via Forge script ────────────────────────────
echo ""
echo "Step 4: Deploying pool stack (TokenWrapper, VAnchor, Credits, Gateway)..."

export TANGLE="$TANGLE"
export POSEIDON_HASHER="$POSEIDON_HASHER"
export VANCHOR_VERIFIER="$VANCHOR_VERIFIER"
export MAX_EDGES=7

CONFIG_FILE="$ROOT_DIR/deploy/config/${CHAIN_NAME}-shielded.json"
if [ -f "$CONFIG_FILE" ]; then
    export SHIELDED_CONFIG="$CONFIG_FILE"
    echo "  Using config: $CONFIG_FILE"
fi

forge script script/DeployShieldedPool.s.sol:DeployShieldedPool \
    --rpc-url "$RPC_URL" \
    --private-key "$PRIVATE_KEY" \
    --broadcast \
    --slow \
    2>&1 | tee "$ROOT_DIR/deploy/output/deploy-${CHAIN_ID}.log"

# ─── Step 5: Verify deployment ────────────────────────────────────────────
echo ""
echo "Step 5: Verifying deployment..."
echo "  Check deploy/output/deploy-${CHAIN_ID}.log for contract addresses"
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  Deployment Complete!"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "  Next steps:"
echo "    1. Record deployed addresses from the log above"
echo "    2. Configure LZ peers on other chains:"
echo "       BRIDGE=0x... forge script script/ConfigureLZPeers.s.sol --rpc-url \$RPC --broadcast"
echo "    3. Test with the CLI:"
echo "       npx tsx sdk/shielded-sdk/src/cli.ts keygen"
echo "       npx tsx sdk/shielded-sdk/src/cli.ts balance --credits 0x... --commitment 0x..."
echo ""
