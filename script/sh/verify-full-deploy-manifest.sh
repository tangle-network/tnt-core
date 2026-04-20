#!/usr/bin/env bash
set -euo pipefail

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

usage() {
  cat <<'EOF'
Usage:
  script/sh/verify-full-deploy-manifest.sh --manifest <path> --rpc-url <url> [--config <path>] [--chain-id <id>]

Checks that a FullDeploy manifest exists, has the expected chain id, and that each deployed
contract address in the manifest has non-empty bytecode on the target RPC.
EOF
}

MANIFEST_PATH=""
RPC_URL=""
EXPECTED_CHAIN_ID=""
CONFIG_PATH=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --manifest)
      MANIFEST_PATH="${2:-}"
      shift 2
      ;;
    --rpc-url)
      RPC_URL="${2:-}"
      shift 2
      ;;
    --config)
      CONFIG_PATH="${2:-}"
      shift 2
      ;;
    --chain-id)
      EXPECTED_CHAIN_ID="${2:-}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      fail "Unknown argument: $1"
      ;;
  esac
done

[[ -n "$MANIFEST_PATH" ]] || fail "Missing --manifest"
[[ -n "$RPC_URL" ]] || fail "Missing --rpc-url"
[[ -f "$MANIFEST_PATH" ]] || fail "Manifest not found: $MANIFEST_PATH"
if [[ -n "$CONFIG_PATH" ]]; then
  [[ -f "$CONFIG_PATH" ]] || fail "Config not found: $CONFIG_PATH"
fi

require_cmd jq
require_cmd cast

CHAIN_ID_IN_MANIFEST="$(jq -er '.chainId' "$MANIFEST_PATH")"
if [[ -n "$EXPECTED_CHAIN_ID" && "$CHAIN_ID_IN_MANIFEST" != "$EXPECTED_CHAIN_ID" ]]; then
  fail "Manifest chain id mismatch: expected $EXPECTED_CHAIN_ID, got $CHAIN_ID_IN_MANIFEST"
fi

RPC_CHAIN_ID="$(cast chain-id --rpc-url "$RPC_URL")"
if [[ "$CHAIN_ID_IN_MANIFEST" != "$RPC_CHAIN_ID" ]]; then
  fail "RPC chain id mismatch: manifest has $CHAIN_ID_IN_MANIFEST, RPC returned $RPC_CHAIN_ID"
fi

NETWORK="$(jq -er '.network' "$MANIFEST_PATH")"
DEPLOYER="$(jq -er '.deployer' "$MANIFEST_PATH")"

echo "==> Verifying FullDeploy manifest"
echo "Manifest:  $MANIFEST_PATH"
echo "Network:   $NETWORK"
echo "Chain id:  $CHAIN_ID_IN_MANIFEST"
echo "Deployer:  $DEPLOYER"

read_manifest_address() {
  local query="$1"
  jq -r "$query // empty" "$MANIFEST_PATH"
}

check_code() {
  local label="$1"
  local address="$2"
  local required="${3:-false}"
  if [[ -z "$address" || "$address" == "null" || "$address" == "0x0000000000000000000000000000000000000000" ]]; then
    [[ "$required" == "true" ]] && fail "Missing required address for $label in manifest"
    return 0
  fi

  local code
  code="$(cast code "$address" --rpc-url "$RPC_URL" 2>/dev/null || true)"
  if [[ ! "$code" =~ ^0x[0-9a-fA-F]{10,}$ ]]; then
    fail "No deployed bytecode for $label at $address"
  fi

  echo "Verified $label: $address"
}

require_from_config() {
  local query="$1"
  [[ -n "$CONFIG_PATH" ]] || return 1
  local value
  value="$(jq -r "$query // false" "$CONFIG_PATH")"
  [[ "$value" == "true" ]]
}

CORE_REQUIRED=false
METRICS_REQUIRED=false
REWARD_VAULTS_REQUIRED=false
INFLATION_POOL_REQUIRED=false
MIGRATION_REQUIRED=false
CREDITS_REQUIRED=false
if require_from_config '.core.deploy'; then CORE_REQUIRED=true; fi
if require_from_config '.incentives.deployMetrics'; then METRICS_REQUIRED=true; fi
if require_from_config '.incentives.deployRewardVaults'; then REWARD_VAULTS_REQUIRED=true; fi
if require_from_config '.incentives.deployInflationPool'; then INFLATION_POOL_REQUIRED=true; fi
if require_from_config '.migration.deploy'; then MIGRATION_REQUIRED=true; fi
if require_from_config '.credits.deploy'; then CREDITS_REQUIRED=true; fi

check_code "tangle" "$(read_manifest_address '.tangle')" "$CORE_REQUIRED"
check_code "staking" "$(read_manifest_address '.staking // .restaking')" "$CORE_REQUIRED"
check_code "statusRegistry" "$(read_manifest_address '.statusRegistry')" "$CORE_REQUIRED"
check_code "tntToken" "$(read_manifest_address '.tntToken')" "$CORE_REQUIRED"
check_code "metrics" "$(read_manifest_address '.metrics')" "$METRICS_REQUIRED"
check_code "rewardVaults" "$(read_manifest_address '.rewardVaults')" "$REWARD_VAULTS_REQUIRED"
check_code "inflationPool" "$(read_manifest_address '.inflationPool')" "$INFLATION_POOL_REQUIRED"
check_code "credits" "$(read_manifest_address '.credits')" "$CREDITS_REQUIRED"
check_code "tangleMigration" "$(read_manifest_address '.migration.tangleMigration')" "$MIGRATION_REQUIRED"
check_code "zkVerifier" "$(read_manifest_address '.migration.zkVerifier')" "$MIGRATION_REQUIRED"

echo "Manifest verification passed."
