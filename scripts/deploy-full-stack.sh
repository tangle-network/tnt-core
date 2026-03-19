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

# Read ALL Poseidon library addresses (needed by the Forge script via env vars)
POSEIDON_T2=$(jq -r '.PoseidonT2' "$POSEIDON_FILE")
POSEIDON_T3=$(jq -r '.PoseidonT3' "$POSEIDON_FILE")
POSEIDON_T4=$(jq -r '.PoseidonT4' "$POSEIDON_FILE")
POSEIDON_T5=$(jq -r '.PoseidonT5' "$POSEIDON_FILE")
POSEIDON_T6=$(jq -r '.PoseidonT6' "$POSEIDON_FILE")
export POSEIDON_T2 POSEIDON_T3 POSEIDON_T4 POSEIDON_T5 POSEIDON_T6
echo "  PoseidonT2: $POSEIDON_T2"
echo "  PoseidonT3: $POSEIDON_T3"
echo "  PoseidonT4: $POSEIDON_T4"
echo "  PoseidonT5: $POSEIDON_T5"
echo "  PoseidonT6: $POSEIDON_T6"

# ─── Step 2: Deploy Verifiers ──────────────────────────────────────────────
echo ""
echo "Step 2: Deploying Verifier contracts..."
VERIFIER_FILE="$ROOT_DIR/deploy/output/verifiers-${CHAIN_ID}.json"

if [ -f "$VERIFIER_FILE" ]; then
    echo "  Verifiers already deployed (found $VERIFIER_FILE)"
    V2_2=$(jq -r '.v2_2' "$VERIFIER_FILE")
    V2_16=$(jq -r '.v2_16' "$VERIFIER_FILE")
    V8_2=$(jq -r '.v8_2' "$VERIFIER_FILE")
    V8_16=$(jq -r '.v8_16' "$VERIFIER_FILE")
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

    # Deploy 2-edge verifiers if available, otherwise reuse 8-edge verifiers
    # The Forge script requires non-zero addresses for all verifier slots
    V2_2_SOL="$VERIFIERS_DIR/poseidon_vanchor_2_2_verifier.sol"
    V2_16_SOL="$VERIFIERS_DIR/poseidon_vanchor_16_2_verifier.sol"

    if [ -f "$V2_2_SOL" ]; then
        echo "  Deploying Verifier2_2..."
        V2_2=$(forge create --rpc-url "$RPC_URL" --private-key "$PRIVATE_KEY" --json \
            "$V2_2_SOL:Verifier2_2" \
            | jq -r '.deployedTo')
    else
        echo "  No 2-edge 2-input verifier found, reusing Verifier8_2"
        V2_2="$V8_2"
    fi

    if [ -f "$V2_16_SOL" ]; then
        echo "  Deploying Verifier2_16..."
        V2_16=$(forge create --rpc-url "$RPC_URL" --private-key "$PRIVATE_KEY" --json \
            "$V2_16_SOL:Verifier2_16" \
            | jq -r '.deployedTo')
    else
        echo "  No 2-edge 16-input verifier found, reusing Verifier8_16"
        V2_16="$V8_16"
    fi

    mkdir -p "$(dirname "$VERIFIER_FILE")"
    echo "{\"v2_2\": \"$V2_2\", \"v2_16\": \"$V2_16\", \"v8_2\": \"$V8_2\", \"v8_16\": \"$V8_16\"}" > "$VERIFIER_FILE"
    echo "  Verifier2_2:  $V2_2"
    echo "  Verifier2_16: $V2_16"
    echo "  Verifier8_2:  $V8_2"
    echo "  Verifier8_16: $V8_16"
fi

# Export verifier addresses for the Forge script
export VERIFIER_2_2="$V2_2"
export VERIFIER_2_16="$V2_16"
export VERIFIER_8_2="$V8_2"
export VERIFIER_8_16="$V8_16"

# ─── Step 3: Deploy pool stack via Forge script ────────────────────────────
echo ""
echo "Step 3: Deploying pool stack (TokenWrapper, VAnchor, Credits, Gateway)..."

export TANGLE="$TANGLE"
export MAX_EDGES=7

CONFIG_FILE="$ROOT_DIR/deploy/config/${CHAIN_NAME}-shielded.json"
if [ -f "$CONFIG_FILE" ]; then
    export SHIELDED_CONFIG="$CONFIG_FILE"
    echo "  Using config: $CONFIG_FILE"
fi

# The Forge script deploys PoseidonHasher which links to Poseidon T2-T6 libraries.
# These libraries must be linked via --libraries flags at the CLI level.
forge script script/DeployShieldedPool.s.sol:DeployShieldedPool \
    --rpc-url "$RPC_URL" \
    --private-key "$PRIVATE_KEY" \
    --broadcast \
    --slow \
    --libraries "protocol-solidity/hashers/Poseidon.sol:PoseidonT2:$POSEIDON_T2" \
    --libraries "protocol-solidity/hashers/Poseidon.sol:PoseidonT3:$POSEIDON_T3" \
    --libraries "protocol-solidity/hashers/Poseidon.sol:PoseidonT4:$POSEIDON_T4" \
    --libraries "protocol-solidity/hashers/Poseidon.sol:PoseidonT5:$POSEIDON_T5" \
    --libraries "protocol-solidity/hashers/Poseidon.sol:PoseidonT6:$POSEIDON_T6" \
    2>&1 | tee "$ROOT_DIR/deploy/output/deploy-${CHAIN_ID}.log"

# ─── Step 4: Verify deployment ────────────────────────────────────────────
echo ""
echo "Step 4: Verifying deployment..."
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
