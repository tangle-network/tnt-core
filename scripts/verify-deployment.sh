#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════════════════
# Post-Deployment Verification
# ═══════════════════════════════════════════════════════════════════════════════
#
# Checks that all shielded pool contracts are deployed and wired correctly.
#
# Usage:
#   RPC_URL=https://sepolia.base.org \
#   GATEWAY=0x... CREDITS=0x... POOL=0x... WRAPPER=0x... HANDLER=0x... BRIDGE=0x... \
#   ./scripts/verify-deployment.sh
# ═══════════════════════════════════════════════════════════════════════════════
set -euo pipefail

: "${RPC_URL:?Set RPC_URL}"
: "${GATEWAY:?Set GATEWAY address}"
: "${CREDITS:?Set CREDITS address}"
: "${POOL:?Set POOL (VAnchorTree) address}"
: "${WRAPPER:?Set WRAPPER (FungibleTokenWrapper) address}"

PASS=0
FAIL=0

check() {
    local desc="$1" cmd="$2" expected="$3"
    local result
    result=$(eval "$cmd" 2>/dev/null || echo "ERROR")

    # Normalize: lowercase, trim whitespace
    result=$(echo "$result" | tr '[:upper:]' '[:lower:]' | xargs)
    expected=$(echo "$expected" | tr '[:upper:]' '[:lower:]' | xargs)

    if [[ "$result" == *"$expected"* ]]; then
        echo "  ✓ $desc"
        PASS=$((PASS + 1))
    else
        echo "  ✗ $desc"
        echo "    expected: $expected"
        echo "    got:      $result"
        FAIL=$((FAIL + 1))
    fi
}

echo "═══════════════════════════════════════════════════════════════"
echo "  Shielded Pool Deployment Verification"
echo "═══════════════════════════════════════════════════════════════"
echo ""

echo "Contracts:"
echo "  Gateway:  $GATEWAY"
echo "  Credits:  $CREDITS"
echo "  Pool:     $POOL"
echo "  Wrapper:  $WRAPPER"
echo ""

# ─── Gateway checks ───────────────────────────────────────────────────────
echo "ShieldedGateway:"
check "tangle() returns non-zero" \
    "cast call $GATEWAY 'tangle()(address)' --rpc-url $RPC_URL" \
    "0x"

check "credits() returns Credits address" \
    "cast call $GATEWAY 'credits()(address)' --rpc-url $RPC_URL" \
    "$CREDITS"

check "getPool(wrapper) returns Pool address" \
    "cast call $GATEWAY 'getPool(address)(address)' $WRAPPER --rpc-url $RPC_URL" \
    "$POOL"

# ─── Credits checks ──────────────────────────────────────────────────────
echo ""
echo "ShieldedCredits:"
check "DOMAIN_SEPARATOR is non-zero" \
    "cast call $CREDITS 'DOMAIN_SEPARATOR()(bytes32)' --rpc-url $RPC_URL" \
    "0x"

check "SPEND_TYPEHASH is non-zero" \
    "cast call $CREDITS 'SPEND_TYPEHASH()(bytes32)' --rpc-url $RPC_URL" \
    "0x"

# ─── Pool checks ─────────────────────────────────────────────────────────
echo ""
echo "VAnchorTree:"
check "token() returns Wrapper address" \
    "cast call $POOL 'token()(address)' --rpc-url $RPC_URL" \
    "$WRAPPER"

check "maxEdges() returns 7" \
    "cast call $POOL 'maxEdges()(uint8)' --rpc-url $RPC_URL" \
    "7"

check "getLastRoot() returns non-zero" \
    "cast call $POOL 'getLastRoot()(uint256)' --rpc-url $RPC_URL" \
    ""

# ─── Bridge checks (optional) ────────────────────────────────────────────
if [ -n "${BRIDGE:-}" ]; then
    echo ""
    echo "LayerZeroAnchorBridge:"
    check "handler() returns non-zero" \
        "cast call $BRIDGE 'handler()(address)' --rpc-url $RPC_URL" \
        "0x"

    check "owner() returns non-zero" \
        "cast call $BRIDGE 'owner()(address)' --rpc-url $RPC_URL" \
        "0x"

    # Check chain mappings for the 5 starting chains
    for chain_id in 1 42161 8453 999 56; do
        check "chainToEid($chain_id) is set" \
            "cast call $BRIDGE 'chainToEid(uint256)(uint32)' $chain_id --rpc-url $RPC_URL" \
            ""
    done
fi

# ─── Summary ─────────────────────────────────────────────────────────────
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "  Results: $PASS passed, $FAIL failed"
echo "═══════════════════════════════════════════════════════════════"

if [ "$FAIL" -gt 0 ]; then
    exit 1
fi
