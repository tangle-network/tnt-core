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
set -euo pipefail

: "${TANGLE_CORE:?set TANGLE_CORE}"
: "${RPC_URL:?set RPC_URL}"
: "${PRIVATE_KEY:?set PRIVATE_KEY}"
: "${BLUEPRINT_ID:?set BLUEPRINT_ID}"
: "${BINARY_PATH:?set BINARY_PATH}"
: "${BINARY_URI:?set BINARY_URI}"
ATTESTATION="${ATTESTATION:-0x0000000000000000000000000000000000000000000000000000000000000000}"
SET_ACTIVE="${SET_ACTIVE:-true}"

[ -f "$BINARY_PATH" ] || { echo "ERROR: BINARY_PATH not found: $BINARY_PATH" >&2; exit 1; }

echo "== publish-binary =="
echo "  blueprint:   $BLUEPRINT_ID"
echo "  tangle:      $TANGLE_CORE"
echo "  artifact:    $BINARY_PATH"
echo "  uri:         $BINARY_URI"

# Append-only guard: never double-publish a genesis version.
count="$(cast call "$TANGLE_CORE" 'getBinaryVersionCount(uint64)(uint64)' "$BLUEPRINT_ID" --rpc-url "$RPC_URL" 2>/dev/null || echo 0)"
count="${count%% *}" # cast may suffix the decoded type
if [ -n "$count" ] && [ "$count" != "0" ]; then
    echo "  already has $count published version(s) — skipping (bump via cargo tangle)."
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

new_count="$(cast call "$TANGLE_CORE" 'getBinaryVersionCount(uint64)(uint64)' "$BLUEPRINT_ID" --rpc-url "$RPC_URL")"
new_count="${new_count%% *}"
version_id=$(( new_count - 1 ))
echo "  published version_id=$version_id"

if [ "$SET_ACTIVE" = "true" ]; then
    echo "  -> setActiveBinaryVersion($BLUEPRINT_ID, $version_id)"
    cast send "$TANGLE_CORE" \
        'setActiveBinaryVersion(uint64,uint64)' \
        "$BLUEPRINT_ID" "$version_id" \
        --private-key "$PRIVATE_KEY" --rpc-url "$RPC_URL" >/dev/null
    echo "  active version set."
fi

echo "  done: blueprint $BLUEPRINT_ID -> v$version_id ($sha256)"
