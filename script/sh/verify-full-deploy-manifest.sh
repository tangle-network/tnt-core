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
  script/sh/verify-full-deploy-manifest.sh --manifest <path> --rpc-url <url> [--chain-id <id>]

Checks that a FullDeploy manifest exists, has the expected chain id, and that each deployed
contract address in the manifest has non-empty bytecode on the target RPC.
EOF
}

MANIFEST_PATH=""
RPC_URL=""
EXPECTED_CHAIN_ID=""

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

check_code() {
  local label="$1"
  local address="$2"
  if [[ -z "$address" || "$address" == "null" || "$address" == "0x0000000000000000000000000000000000000000" ]]; then
    return 0
  fi

  local code
  code="$(cast code "$address" --rpc-url "$RPC_URL" 2>/dev/null || true)"
  if [[ ! "$code" =~ ^0x[0-9a-fA-F]{10,}$ ]]; then
    fail "No deployed bytecode for $label at $address"
  fi

  echo "Verified $label: $address"
}

check_code "tangle" "$(jq -r '.tangle // empty' "$MANIFEST_PATH")"
check_code "staking" "$(jq -r '.staking // .restaking // empty' "$MANIFEST_PATH")"
check_code "statusRegistry" "$(jq -r '.statusRegistry // empty' "$MANIFEST_PATH")"
check_code "tntToken" "$(jq -r '.tntToken // empty' "$MANIFEST_PATH")"
check_code "metrics" "$(jq -r '.metrics // empty' "$MANIFEST_PATH")"
check_code "rewardVaults" "$(jq -r '.rewardVaults // empty' "$MANIFEST_PATH")"
check_code "inflationPool" "$(jq -r '.inflationPool // empty' "$MANIFEST_PATH")"
check_code "credits" "$(jq -r '.credits // empty' "$MANIFEST_PATH")"
check_code "tangleMigration" "$(jq -r '.migration.tangleMigration // empty' "$MANIFEST_PATH")"
check_code "zkVerifier" "$(jq -r '.migration.zkVerifier // empty' "$MANIFEST_PATH")"

echo "Manifest verification passed."
