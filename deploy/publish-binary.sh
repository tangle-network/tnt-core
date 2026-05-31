#!/usr/bin/env bash
# Publish ONE blueprint's operator binary version on-chain.
#
# Closes the `no_v0_published` gap: a blueprint can be registered yet have no
# runnable binary, so no operator can serve it. This records the version
# (sha256 + content-addressed URI) via Tangle.publishBinaryVersion and, by
# default, makes it the active version so AUTO services adopt it immediately.
#
# Append-only + idempotent: if the blueprint already has >=1 published version,
# this is a no-op (bump new releases with `cargo tangle blueprint publish-version`).
#
# publishBinaryVersion requires msg.sender == blueprint owner, so PRIVATE_KEY
# must be the owner key (kept in ONE place — tnt-core CI secrets — never spread
# across the per-blueprint repos, which only build + host the artifact).
#
# Required env:
#   TANGLE_CORE     — Tangle core proxy address
#   RPC_URL         — chain RPC
#   PRIVATE_KEY     — blueprint owner key (0x-prefixed)
#   BLUEPRINT_ID    — uint64 on-chain blueprint id
#   BINARY_PATH     — local path to the artifact (used to compute sha256)
#   BINARY_URI      — content-addressed pointer operators fetch (https:// or ipfs://)
# Optional env:
#   ATTESTATION     — bytes32 attestation digest (default 0x0…0)
#   SET_ACTIVE      — "true" (default) to call setActiveBinaryVersion after publish
#   ACTIVE_VERSION_ID — activate this existing version and skip publish
set -euo pipefail

: "${TANGLE_CORE:?set TANGLE_CORE}"
: "${RPC_URL:?set RPC_URL}"
: "${PRIVATE_KEY:?set PRIVATE_KEY}"
: "${BLUEPRINT_ID:?set BLUEPRINT_ID}"
ATTESTATION="${ATTESTATION:-0x0000000000000000000000000000000000000000000000000000000000000000}"
SET_ACTIVE="${SET_ACTIVE:-true}"
ACTIVE_VERSION_ID="${ACTIVE_VERSION_ID:-}"
# ALLOW_BUMP=true publishes a NEW version even when a genesis already exists
# (the per-release CD path bumps on every release). Default false keeps the
# original genesis-only, idempotent behavior for manual one-shot publishes.
ALLOW_BUMP="${ALLOW_BUMP:-false}"

set_active_version() {
    local version_id="$1"
    local out=""
    local delay=3

    for attempt in 1 2 3 4 5; do
        echo "  -> setActiveBinaryVersion($BLUEPRINT_ID, $version_id) attempt $attempt"
        if out="$(cast send "$TANGLE_CORE" \
            'setActiveBinaryVersion(uint64,uint64)' \
            "$BLUEPRINT_ID" "$version_id" \
            --private-key "$PRIVATE_KEY" --rpc-url "$RPC_URL" 2>&1)"; then
            echo "  active version set."
            return 0
        fi

        if echo "$out" | grep -Eqi 'replacement transaction underpriced|transaction underpriced|nonce too low|already known'; then
            echo "  retryable activation send error: $(echo "$out" | tail -1)" >&2
            sleep "$delay"
            delay=$((delay * 2))
            continue
        fi

        echo "$out" >&2
        return 1
    done

    echo "$out" >&2
    return 1
}

if [ -n "$ACTIVE_VERSION_ID" ]; then
    echo "== publish-binary =="
    echo "  blueprint:   $BLUEPRINT_ID"
    echo "  tangle:      $TANGLE_CORE"
    echo "  activate:    $ACTIVE_VERSION_ID"
    set_active_version "$ACTIVE_VERSION_ID"
    echo "  done: blueprint $BLUEPRINT_ID active -> v$ACTIVE_VERSION_ID"
    exit 0
fi

: "${BINARY_PATH:?set BINARY_PATH}"
: "${BINARY_URI:?set BINARY_URI}"

[ -f "$BINARY_PATH" ] || { echo "ERROR: BINARY_PATH not found: $BINARY_PATH" >&2; exit 1; }

echo "== publish-binary =="
echo "  blueprint:   $BLUEPRINT_ID"
echo "  tangle:      $TANGLE_CORE"
echo "  artifact:    $BINARY_PATH"
echo "  uri:         $BINARY_URI"

# Genesis guard: by default never double-publish when a version already exists.
# ALLOW_BUMP=true opts into publishing a new (append-only) version — the CD path.
count="$(cast call "$TANGLE_CORE" 'getBinaryVersionCount(uint64)(uint64)' "$BLUEPRINT_ID" --rpc-url "$RPC_URL" 2>/dev/null || echo 0)"
count="${count%% *}" # cast may suffix the decoded type
if [ -n "$count" ] && [ "$count" != "0" ] && [ "$ALLOW_BUMP" != "true" ]; then
    echo "  already has $count published version(s) — skipping (set ALLOW_BUMP=true to publish a new version)."
    exit 0
fi

# sha256 of the exact artifact operators will download from BINARY_URI.
if command -v sha256sum >/dev/null 2>&1; then
    digest="$(sha256sum "$BINARY_PATH" | awk '{print $1}')"
else
    digest="$(shasum -a 256 "$BINARY_PATH" | awk '{print $1}')"
fi
sha256="0x${digest}"
echo "  sha256:      $sha256"

echo "  -> publishBinaryVersion"
cast send "$TANGLE_CORE" \
    'publishBinaryVersion(uint64,bytes32,string,bytes32)' \
    "$BLUEPRINT_ID" "$sha256" "$BINARY_URI" "$ATTESTATION" \
    --private-key "$PRIVATE_KEY" --rpc-url "$RPC_URL" >/dev/null

new_count=""
for _ in 1 2 3 4 5; do
    new_count="$(cast call "$TANGLE_CORE" 'getBinaryVersionCount(uint64)(uint64)' "$BLUEPRINT_ID" --rpc-url "$RPC_URL" 2>/dev/null | awk '{print $1}')"
    if [ -n "$new_count" ] && [ "$new_count" -gt 0 ] 2>/dev/null; then
        break
    fi
done
if [ -z "$new_count" ] || [ "$new_count" -lt 1 ] 2>/dev/null; then
    echo "ERROR: publish receipt confirmed but getBinaryVersionCount still 0 after retries — investigate manually." >&2
    exit 1
fi
version_id=$(( new_count - 1 ))
echo "  published version_id=$version_id"

if [ "$SET_ACTIVE" = "true" ]; then
    set_active_version "$version_id"
fi

echo "  done: blueprint $BLUEPRINT_ID -> v$version_id ($sha256)"
