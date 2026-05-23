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
#   4. If a v0 binary artifact is configured for the repo, publish it
#      on-chain via Tangle.publishBinaryVersion + setActiveBinaryVersion
#      and capture the assigned versionId (see "v0 binary publish" below)
#   5. Append the result to a deployments manifest at
#      $DEPLOY_MANIFEST (default: deployments/<network>/blueprints.tsv)
#
# Repos that already have a successful entry in the manifest are
# skipped so the script can run as a top-up.
#
# v0 binary publish (per repo, optional):
#   This sweep only publishes the GENESIS version. New releases ship via
#   `cargo tangle blueprint publish-version` (see docs/UPGRADING_BLUEPRINTS.md).
#
#   To publish a v0 here, set EITHER a per-repo or per-run binary path:
#     <repo>/dist/blueprint-binary             — convention; auto-detected
#     BLUEPRINT_BINARY_PATH=/abs/path/to/bin   — env override (single repo)
#     BLUEPRINT_BINARY_URI=ipfs://<cid>        — required if a binary is
#                                                 found / configured
#     BLUEPRINT_ATTESTATION_PATH=/abs/path     — optional sigstore/SLSA bundle
#
#   The script computes sha256 locally, calls publishBinaryVersion(...) and
#   then setActiveBinaryVersion(...) so AUTO services adopt it immediately.
#   If on-chain already has >=1 published version for the blueprint, the
#   sweep does NOT publish again — bump versions via cargo-tangle.
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
# Manifest schema (TSV, append-only):
#   repo                — short blueprint repo name (matches REPOS entries)
#   blueprint_id        — uint64 returned by Tangle.createBlueprint
#   bsm_address         — per-blueprint BSM proxy address
#   status              — registered | failed_rc_<N> | unknown_output | etc.
#   binary_version_id   — uint64 returned by publishBinaryVersion, or '-'
#   binary_sha256       — 0x-prefixed sha256 of the published artifact, or '-'
#   binary_uri          — content-addressed pointer (ipfs:// or https://), or '-'
#   binary_attestation  — bytes32 attestation bundle digest, or '-'
#   note                — free-form (e.g. "no_v0_published — re-run when binary path is configured")
#   timestamp           — UTC RFC3339
if [ ! -f "$DEPLOY_MANIFEST" ]; then
    printf 'repo\tblueprint_id\tbsm_address\tstatus\tbinary_version_id\tbinary_sha256\tbinary_uri\tbinary_attestation\tnote\ttimestamp\n' \
        > "$DEPLOY_MANIFEST"
fi

# All blueprint repos we know about. Flag column:
#   register — registration is part of normal launch
#   skip     — utility/MPC blueprint that doesn't have an on-chain BSM yet
#   pending  — has a register script but is gated (e.g. ai-trading still
#              depends on its feature branch landing on main)
#
# v0 binary publish migration TODO (tracked in docs/UPGRADING_BLUEPRINTS.md):
# ai-trading-blueprint  — PENDING: register-blueprint.sh wired but the
#                          remote broadcast reverts at eth_estimateGas
#                          (`gas required exceeds allowance (0)`).
#                          Dry-run succeeds. Local anvil unaffected.
#                          Needs investigation in the trading repo's
#                          RegisterBlueprint.s.sol — one of the bundled
#                          setVaultFactory / onOperatorJoined / inline
#                          createBlueprint calls reverts under the Base
#                          Sepolia simulator. Flip back to `register`
#                          once fixed.
#                                 to BLUEPRINT_BINARY_PATH (cloud variant by
#                                 default; pin BLUEPRINT_TARGET_VARIANTS for
#                                 instance/tee/validator).
#   llm-inference-blueprint     — TODO: wire BLUEPRINT_BINARY_PATH into the
#                                 per-repo register script.
#   modal-inference-blueprint   — TODO: wire BLUEPRINT_BINARY_PATH.
#   image-gen-inference-blueprint — TODO: wire BLUEPRINT_BINARY_PATH.
#   training-blueprint          — TODO: wire BLUEPRINT_BINARY_PATH.
#   vector-store-blueprint      — TODO: wire BLUEPRINT_BINARY_PATH.
#   distributed-inference-blueprint — TODO: wire BLUEPRINT_BINARY_PATH.
#   voice-inference-blueprint   — TODO: wire BLUEPRINT_BINARY_PATH.
#   avatar-inference-blueprint  — TODO: wire BLUEPRINT_BINARY_PATH.
#   embedding-inference-blueprint — TODO: wire BLUEPRINT_BINARY_PATH.
#   video-gen-inference-blueprint — TODO: wire BLUEPRINT_BINARY_PATH.
#   openclaw-sandbox-blueprint  — TODO: wire BLUEPRINT_BINARY_PATH.
#   ai-agent-sandbox-blueprint  — TODO: wire BLUEPRINT_BINARY_PATH.
# Until each repo's per-blueprint register script supports the publish hook,
# the sweep falls back to the convention path (<repo>/dist/blueprint-binary)
# in publish_v0_binary(). If neither is present the manifest row carries
# "no_v0_published — re-run when binary path is configured" and the sweep
# continues — single missing artifact does not block the rest of the run.
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

# ─────────────────────────────────────────────────────────────────────────────
# v0 binary publish helper
#
# Resolves the artifact path for a repo (env override > repo convention),
# computes the sha256, and calls Tangle.publishBinaryVersion(...) followed by
# Tangle.setActiveBinaryVersion(...). All output goes to a per-repo log so the
# sweep stays tidy.
#
# Args:  $1 = repo name (matches REPOS entries)
#        $2 = repo path (BLUEPRINT_ROOT/$repo)
#        $3 = blueprint id (uint64)
# Sets globals (caller reads these to populate the manifest row):
#   BIN_VERSION_ID      — assigned version index, '-' if not published
#   BIN_SHA256          — 0x-prefixed digest, '-' if not published
#   BIN_URI             — published URI, '-' if not published
#   BIN_ATTEST          — bytes32 attestation hash, '-' if not used
#   BIN_NOTE            — short status line for the manifest's note column
publish_v0_binary() {
    local repo="$1" repo_path="$2" bp_id="$3"
    BIN_VERSION_ID="-"
    BIN_SHA256="-"
    BIN_URI="-"
    BIN_ATTEST="-"
    BIN_NOTE="no_v0_published — re-run when binary path is configured"

    # Resolve artifact path.
    #   1. BLUEPRINT_BINARY_PATH env wins (per-run override; targets a single repo)
    #   2. Per-repo convention: <repo>/dist/blueprint-binary
    local artifact=""
    if [ -n "${BLUEPRINT_BINARY_PATH:-}" ] && [ -f "$BLUEPRINT_BINARY_PATH" ]; then
        artifact="$BLUEPRINT_BINARY_PATH"
    elif [ -f "$repo_path/dist/blueprint-binary" ]; then
        artifact="$repo_path/dist/blueprint-binary"
    fi

    if [ -z "$artifact" ]; then
        return 0
    fi

    local bin_uri="${BLUEPRINT_BINARY_URI:-}"
    if [ -z "$bin_uri" ]; then
        BIN_NOTE="no_v0_published — artifact found at $artifact but BLUEPRINT_BINARY_URI not set"
        return 0
    fi

    # Probe on-chain version count first — append-only, so we don't re-publish.
    local count
    count=$(cast call "$TANGLE_CORE" "getBinaryVersionCount(uint64)(uint64)" "$bp_id" \
        --rpc-url "$RPC_URL" 2>/dev/null || echo "0")
    # cast may return decoded number directly, e.g. "0" or "3"; strip whitespace.
    count="${count// /}"
    if [ -n "$count" ] && [ "$count" != "0" ]; then
        BIN_NOTE="v0_already_published (on-chain count=$count) — use cargo tangle blueprint publish-version to ship a new release"
        # Best-effort capture of existing genesis row for the manifest.
        local row
        if row=$(cast call "$TANGLE_CORE" "getBinaryVersion(uint64,uint64)((uint64,bytes32,string,bytes32,uint64,bool))" \
                "$bp_id" 0 --rpc-url "$RPC_URL" 2>/dev/null); then
            BIN_VERSION_ID="0"
            # Decoded tuple looks like: (0, 0xsha..., "ipfs://...", 0xattest..., 1716000000, false)
            BIN_SHA256=$(echo "$row" | grep -oE '0x[0-9a-fA-F]{64}' | head -1 || echo "-")
            BIN_URI=$(echo "$row" | grep -oE '"[^"]+"' | head -1 | tr -d '"' || echo "-")
            local att
            att=$(echo "$row" | grep -oE '0x[0-9a-fA-F]{64}' | sed -n '2p')
            [ -n "$att" ] && BIN_ATTEST="$att"
        fi
        return 0
    fi

    # Compute sha256. macOS uses `shasum -a 256`; Linux uses `sha256sum`.
    local digest_hex=""
    if command -v sha256sum >/dev/null 2>&1; then
        digest_hex=$(sha256sum "$artifact" | awk '{print $1}')
    elif command -v shasum >/dev/null 2>&1; then
        digest_hex=$(shasum -a 256 "$artifact" | awk '{print $1}')
    else
        BIN_NOTE="no_v0_published — neither sha256sum nor shasum found"
        return 0
    fi
    local sha_arg="0x${digest_hex}"

    # Attestation: caller supplies the bundle file; we hash it. Treat anything
    # missing as zero (meaning "no bundle"), which the contract accepts.
    local attest_arg="0x0000000000000000000000000000000000000000000000000000000000000000"
    if [ -n "${BLUEPRINT_ATTESTATION_PATH:-}" ] && [ -f "$BLUEPRINT_ATTESTATION_PATH" ]; then
        local att_hex=""
        if command -v sha256sum >/dev/null 2>&1; then
            att_hex=$(sha256sum "$BLUEPRINT_ATTESTATION_PATH" | awk '{print $1}')
        elif command -v shasum >/dev/null 2>&1; then
            att_hex=$(shasum -a 256 "$BLUEPRINT_ATTESTATION_PATH" | awk '{print $1}')
        fi
        if [ -n "$att_hex" ]; then
            attest_arg="0x${att_hex}"
        fi
    fi

    echo ">>> Publishing v0 binary for $repo (blueprintId=$bp_id)"
    echo "    artifact: $artifact"
    echo "    sha256:   $sha_arg"
    echo "    uri:      $bin_uri"
    echo "    attest:   $attest_arg"

    local pub_log="$LOG_DIR/$repo.publish.log"
    if ! cast send "$TANGLE_CORE" \
            "publishBinaryVersion(uint64,bytes32,string,bytes32)" \
            "$bp_id" "$sha_arg" "$bin_uri" "$attest_arg" \
            --private-key "$PRIVATE_KEY" --rpc-url "$RPC_URL" \
            > "$pub_log" 2>&1; then
        BIN_NOTE="publishBinaryVersion_failed — see $pub_log"
        echo "    !! publishBinaryVersion failed (see $pub_log)"
        return 0
    fi

    # Re-read the count to discover the freshly assigned versionId. The first
    # publish for a blueprint always lands at index 0; subsequent ones at N-1.
    local new_count
    new_count=$(cast call "$TANGLE_CORE" "getBinaryVersionCount(uint64)(uint64)" "$bp_id" \
        --rpc-url "$RPC_URL" 2>/dev/null || echo "1")
    new_count="${new_count// /}"
    if [ -z "$new_count" ] || [ "$new_count" = "0" ]; then
        BIN_NOTE="publishBinaryVersion_unexpected — version count still 0"
        return 0
    fi
    local new_version_id=$((new_count - 1))

    # Promote to active so AUTO services pick it up on the next resolution.
    if ! cast send "$TANGLE_CORE" \
            "setActiveBinaryVersion(uint64,uint64)" \
            "$bp_id" "$new_version_id" \
            --private-key "$PRIVATE_KEY" --rpc-url "$RPC_URL" \
            >> "$pub_log" 2>&1; then
        BIN_VERSION_ID="$new_version_id"
        BIN_SHA256="$sha_arg"
        BIN_URI="$bin_uri"
        BIN_ATTEST="$attest_arg"
        BIN_NOTE="setActiveBinaryVersion_failed — see $pub_log"
        return 0
    fi

    BIN_VERSION_ID="$new_version_id"
    BIN_SHA256="$sha_arg"
    BIN_URI="$bin_uri"
    BIN_ATTEST="$attest_arg"
    BIN_NOTE="v0_published_and_active"
    echo "    -> versionId=$new_version_id (set active)"
}

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
            # Globals set by publish_v0_binary: BIN_VERSION_ID, BIN_SHA256,
            # BIN_URI, BIN_ATTEST, BIN_NOTE. Each defaults to '-' when no v0
            # publish was attempted.
            publish_v0_binary "$repo" "$repo_path" "$bp"
            printf '%s\t%s\t%s\tregistered\t%s\t%s\t%s\t%s\t%s\t%s\n' \
                "$repo" "$bp" "${bsm:-}" \
                "$BIN_VERSION_ID" "$BIN_SHA256" "$BIN_URI" "$BIN_ATTEST" "$BIN_NOTE" \
                "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
                >> "$DEPLOY_MANIFEST"
            RESULTS+=("$repo: OK id=$bp bsm=${bsm:-?} bin=$BIN_VERSION_ID ($BIN_NOTE)")
            echo "OK id=$bp bsm=${bsm:-?} bin=$BIN_VERSION_ID"
        else
            printf '%s\t-\t-\tunknown_output\t-\t-\t-\t-\t-\t%s\n' \
                "$repo" "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
                >> "$DEPLOY_MANIFEST"
            RESULTS+=("$repo: UNKNOWN_OUTPUT (rc=0 but no id parsed; log=$log)")
        fi
    else
        rc=$?
        printf '%s\t-\t-\tfailed_rc_%d\t-\t-\t-\t-\t-\t%s\n' \
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
