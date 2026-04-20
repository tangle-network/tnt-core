#!/usr/bin/env bash
set -euo pipefail

# Release-oriented deploy wrapper for the Base Sepolia FullDeploy flow.
#
# Required env:
# - PRIVATE_KEY
# - BASE_SEPOLIA_RPC
#
# Optional env:
# - FULL_DEPLOY_CONFIG      defaults to deploy/config/base-sepolia.json
# - FOUNDRY_PROFILE         defaults to deploy_size
# - RELEASE_TAG             defaults to UTC timestamp (YYYYmmdd-HHMMSS)
# - DRY_RUN                 true|false, defaults to false
# - SKIP_VERIFY             true|false, defaults to false
#
# Behavior:
# - Writes manifests into deployments/base-sepolia/releases/<tag>/
# - Refreshes deployments/base-sepolia/latest.json only after a verified broadcast
# - Leaves prior release snapshots intact for rollback/auditability

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

fail() {
  echo "ERROR: $*" >&2
  exit 1
}

require_cmd() {
  local cmd="$1"
  command -v "$cmd" >/dev/null 2>&1 || fail "Missing required command: $cmd"
}

json_get() {
  local file="$1"
  local query="$2"
  jq -er "$query" "$file"
}

bool_env() {
  local value="${1:-false}"
  [[ "$value" == "1" || "$value" == "true" || "$value" == "TRUE" || "$value" == "yes" || "$value" == "YES" ]]
}

FULL_DEPLOY_CONFIG="${FULL_DEPLOY_CONFIG:-deploy/config/base-sepolia.json}"
FOUNDRY_PROFILE="${FOUNDRY_PROFILE:-deploy_size}"
RELEASE_TAG="${RELEASE_TAG:-$(date -u +%Y%m%d-%H%M%S)}"
DRY_RUN="${DRY_RUN:-false}"
SKIP_VERIFY="${SKIP_VERIFY:-false}"
EXPECTED_CHAIN_ID=84532

: "${PRIVATE_KEY:?Missing PRIVATE_KEY}"
: "${BASE_SEPOLIA_RPC:?Missing BASE_SEPOLIA_RPC}"

require_cmd forge
require_cmd jq
require_cmd cast
require_cmd cp
require_cmd mktemp

[[ -f "$FULL_DEPLOY_CONFIG" ]] || fail "Config not found: $FULL_DEPLOY_CONFIG"

CONFIG_NETWORK="$(json_get "$FULL_DEPLOY_CONFIG" '.network')"
[[ "$CONFIG_NETWORK" == "base-sepolia" ]] || fail "Expected .network=base-sepolia, found: $CONFIG_NETWORK"

CONFIG_CHAIN_ID="$(json_get "$FULL_DEPLOY_CONFIG" '._chainId')"
[[ "$CONFIG_CHAIN_ID" == "$EXPECTED_CHAIN_ID" ]] || fail "Expected ._chainId=$EXPECTED_CHAIN_ID, found: $CONFIG_CHAIN_ID"

MANIFEST_PATH="$(json_get "$FULL_DEPLOY_CONFIG" '.manifest.path')"
[[ -n "$MANIFEST_PATH" && "$MANIFEST_PATH" != "null" ]] || fail "Missing .manifest.path in $FULL_DEPLOY_CONFIG"

MIGRATION_DEPLOY="$(jq -r '.migration.deploy // false' "$FULL_DEPLOY_CONFIG")"
MIGRATION_ARTIFACTS_PATH="$(jq -r '.migration.artifactsPath // empty' "$FULL_DEPLOY_CONFIG")"

MANIFEST_DIR="$(dirname "$MANIFEST_PATH")"
RELEASE_DIR="$MANIFEST_DIR/releases/$RELEASE_TAG"
RELEASE_MANIFEST_PATH="$RELEASE_DIR/manifest.json"
LATEST_PATH="$MANIFEST_PATH"

RELEASE_MIGRATION_PATH=""
LATEST_MIGRATION_PATH=""
if [[ "$MIGRATION_DEPLOY" == "true" && -n "$MIGRATION_ARTIFACTS_PATH" && "$MIGRATION_ARTIFACTS_PATH" != "null" ]]; then
  LATEST_MIGRATION_PATH="$MIGRATION_ARTIFACTS_PATH"
  RELEASE_MIGRATION_PATH="$RELEASE_DIR/migration.json"
fi

mkdir -p "$RELEASE_DIR"

TEMP_CONFIG="$(mktemp "$ROOT_DIR/.base-sepolia-deploy.XXXXXX.json")"
cleanup() {
  rm -f "$TEMP_CONFIG"
}
trap cleanup EXIT

if [[ -n "$RELEASE_MIGRATION_PATH" ]]; then
  jq \
    --arg manifest_path "$RELEASE_MANIFEST_PATH" \
    --arg migration_path "$RELEASE_MIGRATION_PATH" \
    '.manifest.path = $manifest_path | .migration.artifactsPath = $migration_path' \
    "$FULL_DEPLOY_CONFIG" >"$TEMP_CONFIG"
else
  jq \
    --arg manifest_path "$RELEASE_MANIFEST_PATH" \
    '.manifest.path = $manifest_path' \
    "$FULL_DEPLOY_CONFIG" >"$TEMP_CONFIG"
fi

RPC_CHAIN_ID="$(cast chain-id --rpc-url "$BASE_SEPOLIA_RPC")"
[[ "$RPC_CHAIN_ID" == "$EXPECTED_CHAIN_ID" ]] || fail "RPC chain id mismatch: expected $EXPECTED_CHAIN_ID, got $RPC_CHAIN_ID"

DEPLOYER_ADDRESS="$(cast wallet address --private-key "$PRIVATE_KEY")"
CONFIG_ADMIN="$(json_get "$FULL_DEPLOY_CONFIG" '.roles.admin')"

if [[ "${ALLOW_ADMIN_MISMATCH:-false}" != "true" && "$CONFIG_ADMIN" != "$DEPLOYER_ADDRESS" ]]; then
  fail "Config admin ($CONFIG_ADMIN) does not match deployer key ($DEPLOYER_ADDRESS). FullDeploy performs privileged setup during deployment, so PRIVATE_KEY must currently control .roles.admin."
fi

echo "==> Base Sepolia launch"
echo "Config:            $FULL_DEPLOY_CONFIG"
echo "Temp config:       $TEMP_CONFIG"
echo "Release tag:       $RELEASE_TAG"
echo "Release dir:       $RELEASE_DIR"
echo "Release manifest:  $RELEASE_MANIFEST_PATH"
echo "Stable manifest:   $LATEST_PATH"
if [[ -n "$RELEASE_MIGRATION_PATH" ]]; then
  echo "Release migration: $RELEASE_MIGRATION_PATH"
  echo "Stable migration:  $LATEST_MIGRATION_PATH"
fi
echo "Profile:           $FOUNDRY_PROFILE"
echo "Deployer:          $DEPLOYER_ADDRESS"

FORGE_ARGS=(
  script script/FullDeploy.s.sol:FullDeploy
  --rpc-url "$BASE_SEPOLIA_RPC"
  --non-interactive
)

if bool_env "$DRY_RUN"; then
  echo "Mode:              dry-run"
else
  echo "Mode:              broadcast"
  FORGE_ARGS+=(--broadcast)
fi

FULL_DEPLOY_CONFIG="$TEMP_CONFIG" \
FOUNDRY_PROFILE="$FOUNDRY_PROFILE" \
forge "${FORGE_ARGS[@]}"

[[ -f "$RELEASE_MANIFEST_PATH" ]] || fail "Expected manifest not written: $RELEASE_MANIFEST_PATH"

if bool_env "$DRY_RUN"; then
  echo
  echo "Dry-run completed."
  echo "Release manifest: $RELEASE_MANIFEST_PATH"
  echo "Stable manifest unchanged: $LATEST_PATH"
  exit 0
fi

if ! bool_env "$SKIP_VERIFY"; then
  "$ROOT_DIR/script/sh/verify-full-deploy-manifest.sh" \
    --manifest "$RELEASE_MANIFEST_PATH" \
    --rpc-url "$BASE_SEPOLIA_RPC" \
    --chain-id "$EXPECTED_CHAIN_ID"
else
  echo "Skipping manifest verification because SKIP_VERIFY=true"
fi

cp "$RELEASE_MANIFEST_PATH" "$LATEST_PATH"
if [[ -n "$RELEASE_MIGRATION_PATH" && -f "$RELEASE_MIGRATION_PATH" ]]; then
  cp "$RELEASE_MIGRATION_PATH" "$LATEST_MIGRATION_PATH"
fi

echo
echo "Deployment verified."
echo "Release manifest: $RELEASE_MANIFEST_PATH"
echo "Stable manifest:  $LATEST_PATH"
if [[ -n "$RELEASE_MIGRATION_PATH" && -f "$RELEASE_MIGRATION_PATH" ]]; then
  echo "Stable migration: $LATEST_MIGRATION_PATH"
fi
