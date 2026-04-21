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

read_config_value() {
  local query="$1"
  [[ -n "$CONFIG_PATH" ]] || return 1
  jq -r "$query // empty" "$CONFIG_PATH"
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

normalize_bool_result() {
  local value
  value="$(echo "${1:-}" | tr '[:upper:]' '[:lower:]' | tr -d '\n\r[:space:]')"
  [[ "$value" == "true" || "$value" == "0x0000000000000000000000000000000000000000000000000000000000000001" ]]
}

check_has_role() {
  local label="$1"
  local address="$2"
  local role="$3"
  local account="$4"
  [[ -n "$address" && "$address" != "0x0000000000000000000000000000000000000000" ]] || return 0
  [[ -n "$account" && "$account" != "0x0000000000000000000000000000000000000000" ]] || return 0

  local result
  result="$(cast call "$address" "hasRole(bytes32,address)(bool)" "$role" "$account" --rpc-url "$RPC_URL")"
  normalize_bool_result "$result" || fail "$label missing role $role for $account"
  echo "Verified $label role $role for $account"
}

check_missing_role() {
  local label="$1"
  local address="$2"
  local role="$3"
  local account="$4"
  [[ -n "$address" && "$address" != "0x0000000000000000000000000000000000000000" ]] || return 0
  [[ -n "$account" && "$account" != "0x0000000000000000000000000000000000000000" ]] || return 0

  local result
  result="$(cast call "$address" "hasRole(bytes32,address)(bool)" "$role" "$account" --rpc-url "$RPC_URL")"
  normalize_bool_result "$result" && fail "$label unexpectedly retains role $role for $account"
  echo "Verified $label does not grant role $role to $account"
}

check_owner() {
  local label="$1"
  local address="$2"
  local expected_owner="$3"
  [[ -n "$address" && "$address" != "0x0000000000000000000000000000000000000000" ]] || return 0
  [[ -n "$expected_owner" && "$expected_owner" != "0x0000000000000000000000000000000000000000" ]] || return 0

  local owner
  owner="$(cast call "$address" "owner()(address)" --rpc-url "$RPC_URL" | tr -d '\n\r[:space:]')"
  [[ "${owner,,}" == "${expected_owner,,}" ]] || fail "$label owner mismatch: expected $expected_owner, got $owner"
  echo "Verified $label owner: $owner"
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

if [[ -n "$CONFIG_PATH" ]]; then
  DEFAULT_ADMIN_ROLE="0x0000000000000000000000000000000000000000000000000000000000000000"
  ADMIN_ROLE="$(cast keccak "ADMIN_ROLE")"
  PAUSER_ROLE="$(cast keccak "PAUSER_ROLE")"
  UPGRADER_ROLE="$(cast keccak "UPGRADER_ROLE")"
  SLASH_ADMIN_ROLE="$(cast keccak "SLASH_ADMIN_ROLE")"
  ASSET_MANAGER_ROLE="$(cast keccak "ASSET_MANAGER_ROLE")"
  MINTER_ROLE="$(cast keccak "MINTER_ROLE")"

  CONFIG_ADMIN="$(read_config_value '.roles.admin')"
  [[ -n "$CONFIG_ADMIN" ]] || CONFIG_ADMIN="$(read_manifest_address '.admin')"
  CONFIG_TIMELOCK="$(read_config_value '.roles.timelock')"
  CONFIG_MULTISIG="$(read_config_value '.roles.multisig')"
  CONFIG_REVOKE_BOOTSTRAP="$(jq -r '.roles.revokeBootstrap // false' "$CONFIG_PATH")"

  [[ -n "$CONFIG_TIMELOCK" && "$CONFIG_TIMELOCK" != "0x0000000000000000000000000000000000000000" ]] || CONFIG_TIMELOCK="$CONFIG_ADMIN"
  [[ -n "$CONFIG_MULTISIG" && "$CONFIG_MULTISIG" != "0x0000000000000000000000000000000000000000" ]] || CONFIG_MULTISIG="$CONFIG_ADMIN"

  TANGLE_ADDR="$(read_manifest_address '.tangle')"
  STAKING_ADDR="$(read_manifest_address '.staking // .restaking')"
  STATUS_REGISTRY_ADDR="$(read_manifest_address '.statusRegistry')"
  TNT_TOKEN_ADDR="$(read_manifest_address '.tntToken')"
  METRICS_ADDR="$(read_manifest_address '.metrics')"
  REWARD_VAULTS_ADDR="$(read_manifest_address '.rewardVaults')"
  INFLATION_POOL_ADDR="$(read_manifest_address '.inflationPool')"
  SERVICE_FEE_DISTRIBUTOR_ADDR="$(read_manifest_address '.serviceFeeDistributor')"
  STREAMING_PAYMENT_MANAGER_ADDR="$(read_manifest_address '.streamingPaymentManager')"
  CREDITS_ADDR="$(read_manifest_address '.credits')"
  MIGRATION_ADDR="$(read_manifest_address '.migration.tangleMigration')"

  check_has_role "tangle" "$TANGLE_ADDR" "$DEFAULT_ADMIN_ROLE" "$CONFIG_TIMELOCK"
  check_has_role "tangle" "$TANGLE_ADDR" "$ADMIN_ROLE" "$CONFIG_TIMELOCK"
  check_has_role "tangle" "$TANGLE_ADDR" "$UPGRADER_ROLE" "$CONFIG_TIMELOCK"
  check_has_role "tangle" "$TANGLE_ADDR" "$PAUSER_ROLE" "$CONFIG_MULTISIG"
  check_has_role "tangle" "$TANGLE_ADDR" "$SLASH_ADMIN_ROLE" "$CONFIG_MULTISIG"

  check_has_role "staking" "$STAKING_ADDR" "$DEFAULT_ADMIN_ROLE" "$CONFIG_TIMELOCK"
  check_has_role "staking" "$STAKING_ADDR" "$ADMIN_ROLE" "$CONFIG_TIMELOCK"
  check_has_role "staking" "$STAKING_ADDR" "$ASSET_MANAGER_ROLE" "$CONFIG_MULTISIG"

  check_has_role "tntToken" "$TNT_TOKEN_ADDR" "$DEFAULT_ADMIN_ROLE" "$CONFIG_TIMELOCK"
  check_has_role "tntToken" "$TNT_TOKEN_ADDR" "$MINTER_ROLE" "$CONFIG_TIMELOCK"
  check_has_role "tntToken" "$TNT_TOKEN_ADDR" "$UPGRADER_ROLE" "$CONFIG_TIMELOCK"

  check_has_role "metrics" "$METRICS_ADDR" "$DEFAULT_ADMIN_ROLE" "$CONFIG_TIMELOCK"
  check_has_role "metrics" "$METRICS_ADDR" "$UPGRADER_ROLE" "$CONFIG_TIMELOCK"

  check_has_role "rewardVaults" "$REWARD_VAULTS_ADDR" "$DEFAULT_ADMIN_ROLE" "$CONFIG_TIMELOCK"
  check_has_role "rewardVaults" "$REWARD_VAULTS_ADDR" "$ADMIN_ROLE" "$CONFIG_TIMELOCK"
  check_has_role "rewardVaults" "$REWARD_VAULTS_ADDR" "$UPGRADER_ROLE" "$CONFIG_TIMELOCK"

  check_has_role "inflationPool" "$INFLATION_POOL_ADDR" "$DEFAULT_ADMIN_ROLE" "$CONFIG_TIMELOCK"
  check_has_role "inflationPool" "$INFLATION_POOL_ADDR" "$ADMIN_ROLE" "$CONFIG_TIMELOCK"
  check_has_role "inflationPool" "$INFLATION_POOL_ADDR" "$UPGRADER_ROLE" "$CONFIG_TIMELOCK"

  check_has_role "serviceFeeDistributor" "$SERVICE_FEE_DISTRIBUTOR_ADDR" "$DEFAULT_ADMIN_ROLE" "$CONFIG_TIMELOCK"
  check_has_role "serviceFeeDistributor" "$SERVICE_FEE_DISTRIBUTOR_ADDR" "$ADMIN_ROLE" "$CONFIG_TIMELOCK"
  check_has_role "serviceFeeDistributor" "$SERVICE_FEE_DISTRIBUTOR_ADDR" "$UPGRADER_ROLE" "$CONFIG_TIMELOCK"

  check_has_role "streamingPaymentManager" "$STREAMING_PAYMENT_MANAGER_ADDR" "$DEFAULT_ADMIN_ROLE" "$CONFIG_TIMELOCK"
  check_has_role "streamingPaymentManager" "$STREAMING_PAYMENT_MANAGER_ADDR" "$ADMIN_ROLE" "$CONFIG_TIMELOCK"
  check_has_role "streamingPaymentManager" "$STREAMING_PAYMENT_MANAGER_ADDR" "$UPGRADER_ROLE" "$CONFIG_TIMELOCK"

  check_owner "statusRegistry" "$STATUS_REGISTRY_ADDR" "$CONFIG_TIMELOCK"

  CREDITS_OWNER="$(read_config_value '.credits.owner')"
  [[ -n "$CREDITS_OWNER" && "$CREDITS_OWNER" != "0x0000000000000000000000000000000000000000" ]] || CREDITS_OWNER="$CONFIG_TIMELOCK"
  check_owner "credits" "$CREDITS_ADDR" "$CREDITS_OWNER"

  MIGRATION_OWNER="$(read_config_value '.migration.migrationOwner')"
  [[ -n "$MIGRATION_OWNER" && "$MIGRATION_OWNER" != "0x0000000000000000000000000000000000000000" ]] || MIGRATION_OWNER="$CONFIG_TIMELOCK"
  check_owner "tangleMigration" "$MIGRATION_ADDR" "$MIGRATION_OWNER"

  if [[ "$CONFIG_REVOKE_BOOTSTRAP" == "true" && "${CONFIG_ADMIN,,}" != "${CONFIG_TIMELOCK,,}" && "${CONFIG_ADMIN,,}" != "${CONFIG_MULTISIG,,}" ]]; then
    check_missing_role "tangle" "$TANGLE_ADDR" "$DEFAULT_ADMIN_ROLE" "$CONFIG_ADMIN"
    check_missing_role "tangle" "$TANGLE_ADDR" "$ADMIN_ROLE" "$CONFIG_ADMIN"
    check_missing_role "tangle" "$TANGLE_ADDR" "$UPGRADER_ROLE" "$CONFIG_ADMIN"
    check_missing_role "tangle" "$TANGLE_ADDR" "$PAUSER_ROLE" "$CONFIG_ADMIN"
    check_missing_role "tangle" "$TANGLE_ADDR" "$SLASH_ADMIN_ROLE" "$CONFIG_ADMIN"

    check_missing_role "staking" "$STAKING_ADDR" "$DEFAULT_ADMIN_ROLE" "$CONFIG_ADMIN"
    check_missing_role "staking" "$STAKING_ADDR" "$ADMIN_ROLE" "$CONFIG_ADMIN"
    check_missing_role "staking" "$STAKING_ADDR" "$ASSET_MANAGER_ROLE" "$CONFIG_ADMIN"

    check_missing_role "tntToken" "$TNT_TOKEN_ADDR" "$DEFAULT_ADMIN_ROLE" "$CONFIG_ADMIN"
    check_missing_role "tntToken" "$TNT_TOKEN_ADDR" "$MINTER_ROLE" "$CONFIG_ADMIN"
    check_missing_role "tntToken" "$TNT_TOKEN_ADDR" "$UPGRADER_ROLE" "$CONFIG_ADMIN"
  fi
fi
echo "Manifest verification passed."
