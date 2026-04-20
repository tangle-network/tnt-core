#!/usr/bin/env bash
set -euo pipefail

# Deploy the TNT protocol stack to Base Sepolia using the config-driven FullDeploy flow.
#
# Required env:
# - PRIVATE_KEY
# - BASE_SEPOLIA_RPC
#
# Optional env:
# - FULL_DEPLOY_CONFIG (defaults to deploy/config/base-sepolia.json)

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

: "${PRIVATE_KEY:?Missing PRIVATE_KEY}"
: "${BASE_SEPOLIA_RPC:?Missing BASE_SEPOLIA_RPC}"

FULL_DEPLOY_CONFIG="${FULL_DEPLOY_CONFIG:-deploy/config/base-sepolia.json}"

if [[ ! -f "$FULL_DEPLOY_CONFIG" ]]; then
  echo "Config not found: $FULL_DEPLOY_CONFIG" >&2
  exit 1
fi

if ! command -v forge >/dev/null 2>&1 || ! command -v jq >/dev/null 2>&1; then
  echo "forge and jq are required" >&2
  exit 1
fi

MANIFEST_PATH="$(jq -r '.manifest.path' "$FULL_DEPLOY_CONFIG")"
if [[ -z "$MANIFEST_PATH" || "$MANIFEST_PATH" == "null" ]]; then
  echo "Missing .manifest.path in $FULL_DEPLOY_CONFIG" >&2
  exit 1
fi

echo "==> Deploying TNT protocol to Base Sepolia"
echo "Config:    $FULL_DEPLOY_CONFIG"
echo "Manifest:  $MANIFEST_PATH"

FULL_DEPLOY_CONFIG="$FULL_DEPLOY_CONFIG" \
forge script script/FullDeploy.s.sol:FullDeploy \
  --rpc-url "$BASE_SEPOLIA_RPC" \
  --broadcast \
  --non-interactive

echo ""
echo "Done."
echo "Manifest: $MANIFEST_PATH"
