#!/usr/bin/env bash
#
# One-click registration of every blueprint repo under $BLUEPRINT_ROOT
# against a live Tangle deployment. Idempotent and safe to re-run.
#
# What it does, per blueprint repo:
#   1. cd into the repo and sync its default branch to origin
#   2. Invoke that repo's ./deploy/register-blueprint.sh with the right
#      env vars (PRIVATE_KEY, RPC_URL, TANGLE_CORE, PAYMENT_TOKEN)
#   3. Capture blueprint id + BSM address from the script's stdout
#   4. Append the result to a deployments manifest at
#      $DEPLOY_MANIFEST (default: deployments/<network>/blueprints.tsv)
#
# Repos that already have a successful entry in the manifest are
# skipped so the script can run as a top-up.
#
# Usage (Base Sepolia, real broadcast):
#
#   export PRIVATE_KEY=0x...
#   export RPC_URL=https://sepolia.base.org
#   export TANGLE_CORE=0xC9b0716a187072be0f38A5D972392C6479b9Cfe3
#   export PAYMENT_TOKEN=0x036CbD53842c5426634e7929541eC2318f3dCF7e
#   ./deploy/register-blueprints.sh
#
# Or, pulling the shared testnet deployer key from dotenvx:
#
#   export PRIVATE_KEY=$(dotenvx get BASE_SEPOLIA_DEPLOYER_PRIVATE_KEY \
#       -f ~/company/devops/secrets/shared-testnet-deployer.env)
#   ./deploy/register-blueprints.sh
#
# Restrict to specific repos on retry:
#
#   ONLY_REPOS="llm-inference-blueprint voice-inference-blueprint" \
#     ./deploy/register-blueprints.sh
#

set -uo pipefail

: "${PRIVATE_KEY:?Set PRIVATE_KEY (or via dotenvx; see header).}"
: "${RPC_URL:=https://sepolia.base.org}"
: "${TANGLE_CORE:=0xC9b0716a187072be0f38A5D972392C6479b9Cfe3}"
: "${PAYMENT_TOKEN:=0x036CbD53842c5426634e7929541eC2318f3dCF7e}"
: "${TSUSD_ADDRESS:=$PAYMENT_TOKEN}"
BLUEPRINT_ROOT="${BLUEPRINT_ROOT:-$HOME/code}"

network_slug() {
    case "$1" in
        84532)  echo "base-sepolia" ;;
        8453)   echo "base-mainnet" ;;
        421614) echo "arbitrum-sepolia" ;;
        42161)  echo "arbitrum-one" ;;
        1)      echo "ethereum-mainnet" ;;
        *)      echo "chain-$1" ;;
    esac
}

CHAIN_ID=$(cast chain-id --rpc-url "$RPC_URL" 2>/dev/null || echo "0")
NETWORK=$(network_slug "$CHAIN_ID")
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DEPLOY_MANIFEST="${DEPLOY_MANIFEST:-$REPO_ROOT/deployments/$NETWORK/blueprints.tsv}"
mkdir -p "$(dirname "$DEPLOY_MANIFEST")"
if [ ! -f "$DEPLOY_MANIFEST" ]; then
    printf 'repo\tblueprint_id\tbsm_address\tstatus\ttimestamp\n' > "$DEPLOY_MANIFEST"
fi

# All blueprint repos we know about. Flag column:
#   register — registration is part of normal launch
#   skip     — utility/MPC blueprint that doesn't have an on-chain BSM yet
#   pending  — has a register script but is gated (e.g. ai-trading still
#              depends on its feature branch landing on main)
REPOS=(
    "ai-agent-sandbox-blueprint:register"
    "llm-inference-blueprint:register"
    "modal-inference-blueprint:register"
    "image-gen-inference-blueprint:register"
    "training-blueprint:register"
    "vector-store-blueprint:register"
    "distributed-inference-blueprint:register"
    "voice-inference-blueprint:register"
    "avatar-inference-blueprint:register"
    "embedding-inference-blueprint:register"
    "video-gen-inference-blueprint:register"
    "openclaw-sandbox-blueprint:register"
    "ai-trading-blueprint:pending"
    "microvm-blueprint:skip"
    "bls-blueprint:skip"
    "frost-blueprint:skip"
    "wsts-blueprint:skip"
)

echo "=== Tangle blueprint registration sweep ==="
echo "Network:    $NETWORK (chainId $CHAIN_ID)"
echo "Tangle:     $TANGLE_CORE"
echo "RPC:        $RPC_URL"
echo "Manifest:   $DEPLOY_MANIFEST"
deployer_addr=$(cast wallet address --private-key "$PRIVATE_KEY")
echo "Deployer:   $deployer_addr"
echo "Balance:    $(cast balance --ether "$deployer_addr" --rpc-url "$RPC_URL") ETH"
echo ""

LOG_DIR=$(mktemp -d --suffix=-register-blueprints)
RESULTS=()

filter_in() {
    [ -z "${ONLY_REPOS:-}" ] && return 0
    for needle in $ONLY_REPOS; do
        [ "$needle" = "$1" ] && return 0
    done
    return 1
}

already_registered() {
    grep -qE "^$1\\b.+\\bregistered\\b" "$DEPLOY_MANIFEST" 2>/dev/null
}

for entry in "${REPOS[@]}"; do
    repo="${entry%%:*}"
    flag="${entry##*:}"
    filter_in "$repo" || continue

    case "$flag" in
        skip)
            RESULTS+=("$repo: SKIP (utility blueprint, no on-chain BSM yet)")
            continue
            ;;
        pending)
            RESULTS+=("$repo: PENDING (gated on upstream; see repo CHANGELOG)")
            continue
            ;;
    esac

    if already_registered "$repo"; then
        existing=$(grep "^$repo\\b" "$DEPLOY_MANIFEST" | tail -1)
        RESULTS+=("$repo: SKIP (already registered: $existing)")
        continue
    fi

    repo_path="$BLUEPRINT_ROOT/$repo"
    if [ ! -d "$repo_path" ]; then
        RESULTS+=("$repo: MISSING (no checkout at $repo_path)")
        continue
    fi
    if [ ! -x "$repo_path/deploy/register-blueprint.sh" ]; then
        RESULTS+=("$repo: NO_SCRIPT (deploy/register-blueprint.sh missing)")
        continue
    fi

    echo "============================================================"
    echo "=== $repo"
    echo "============================================================"

    # Sync to default branch so we register against the latest merged script.
    (
        cd "$repo_path"
        branch=$(git remote show origin 2>/dev/null | awk '/HEAD branch/{print $NF}')
        git fetch origin --quiet 2>&1 | tail -2
        git stash -u >/dev/null 2>&1 || true
        git checkout "$branch" 2>&1 | tail -1
        git reset --hard "origin/$branch" 2>&1 | tail -1
    )

    log="$LOG_DIR/$repo.log"
    if (
        cd "$repo_path"
        PRIVATE_KEY="$PRIVATE_KEY" \
            RPC_URL="$RPC_URL" \
            TANGLE_CORE="$TANGLE_CORE" \
            PAYMENT_TOKEN="$PAYMENT_TOKEN" \
            TSUSD_ADDRESS="$TSUSD_ADDRESS" \
            ./deploy/register-blueprint.sh
    ) > "$log" 2>&1; then
        bp=$(grep -oE 'DEPLOY_[A-Z_]*BLUEPRINT_ID=[0-9]+|Blueprint ID:[[:space:]]*[0-9]+' "$log" | grep -oE '[0-9]+' | tail -1)
        bsm=$(grep -oE 'DEPLOY_[A-Z_]*BSM[A-Z_]*=0x[0-9a-fA-F]{40}|(BSM[A-Za-z]*|BSM proxy)[^=:]*[=:][[:space:]]*0x[0-9a-fA-F]{40}' "$log" | grep -oE '0x[0-9a-fA-F]{40}' | tail -1)
        if [ -n "$bp" ]; then
            printf '%s\t%s\t%s\tregistered\t%s\n' \
                "$repo" "$bp" "${bsm:-}" "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
                >> "$DEPLOY_MANIFEST"
            RESULTS+=("$repo: OK id=$bp bsm=${bsm:-?}")
            echo "OK id=$bp bsm=${bsm:-?}"
        else
            printf '%s\t-\t-\tunknown_output\t%s\n' \
                "$repo" "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
                >> "$DEPLOY_MANIFEST"
            RESULTS+=("$repo: UNKNOWN_OUTPUT (rc=0 but no id parsed; log=$log)")
        fi
    else
        rc=$?
        printf '%s\t-\t-\tfailed_rc_%d\t%s\n' \
            "$repo" "$rc" "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
            >> "$DEPLOY_MANIFEST"
        RESULTS+=("$repo: FAILED rc=$rc log=$log")
        echo "FAILED (rc=$rc) — last 10 lines:"
        tail -10 "$log"
    fi
    echo ""

    sleep 5
done

echo ""
echo "============== SUMMARY =============="
printf '%s\n' "${RESULTS[@]}"
echo ""
echo "Manifest:   $DEPLOY_MANIFEST"
echo "Per-repo logs: $LOG_DIR"
