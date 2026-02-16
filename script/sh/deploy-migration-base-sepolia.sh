#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

RPC_URL="${BASE_SEPOLIA_RPC:-${RPC_URL:-}}"
if [[ -z "${RPC_URL}" ]]; then
  echo "Missing BASE_SEPOLIA_RPC (or RPC_URL)" >&2
  exit 1
fi

: "${PRIVATE_KEY:?Missing PRIVATE_KEY}"

USE_MOCK_VERIFIER="${USE_MOCK_VERIFIER:-false}"
if [[ "${USE_MOCK_VERIFIER}" != "true" && "${USE_MOCK_VERIFIER}" != "false" ]]; then
  echo "USE_MOCK_VERIFIER must be true|false (got: ${USE_MOCK_VERIFIER})" >&2
  exit 1
fi

if [[ "${USE_MOCK_VERIFIER}" != "true" ]]; then
  : "${PROGRAM_VKEY:?Missing PROGRAM_VKEY (required when USE_MOCK_VERIFIER=false)}"
fi

MERKLE_TREE_FILE="${MERKLE_TREE_FILE:-$ROOT_DIR/packages/migration-claim/merkle-tree.json}"
EVM_CLAIMS_FILE="${EVM_CLAIMS_FILE:-$ROOT_DIR/packages/migration-claim/evm-claims.json}"
TREASURY_CARVEOUT_FILE="${TREASURY_CARVEOUT_FILE:-$ROOT_DIR/packages/migration-claim/treasury-carveout.json}"
FOUNDATION_CARVEOUT_FILE="${FOUNDATION_CARVEOUT_FILE:-$ROOT_DIR/packages/migration-claim/foundation-carveout.json}"

for f in "$MERKLE_TREE_FILE" "$EVM_CLAIMS_FILE"; do
  if [[ ! -f "$f" ]]; then
    echo "Missing required artifact: $f" >&2
    exit 1
  fi
done

if ! command -v forge >/dev/null 2>&1 || ! command -v cast >/dev/null 2>&1 || ! command -v node >/dev/null 2>&1; then
  echo "Missing required tooling: forge + cast + node" >&2
  exit 1
fi

read_merkle_root() {
  node -e "const d=require('fs').readFileSync(process.argv[1],'utf8');const j=JSON.parse(d);process.stdout.write(String(j.root||''));" "$MERKLE_TREE_FILE"
}

read_substrate_total() {
  node -e "const d=require('fs').readFileSync(process.argv[1],'utf8');const j=JSON.parse(d);process.stdout.write(String(j.totalValue||'0'));" "$MERKLE_TREE_FILE"
}

read_evm_total() {
  node -e "const d=require('fs').readFileSync(process.argv[1],'utf8');const j=JSON.parse(d);process.stdout.write(String(j.totalAmount||'0'));" "$EVM_CLAIMS_FILE"
}

read_treasury_amount() {
  if [[ ! -f "$TREASURY_CARVEOUT_FILE" ]]; then
    echo "0"
    return
  fi
  node -e "const d=require('fs').readFileSync(process.argv[1],'utf8');const j=JSON.parse(d);process.stdout.write(String(j.amount||'0'));" "$TREASURY_CARVEOUT_FILE"
}

read_foundation_amount() {
  if [[ ! -f "$FOUNDATION_CARVEOUT_FILE" ]]; then
    echo "0"
    return
  fi
  node -e "const d=require('fs').readFileSync(process.argv[1],'utf8');const j=JSON.parse(d);process.stdout.write(String(j.amount||'0'));" "$FOUNDATION_CARVEOUT_FILE"
}

MERKLE_ROOT="$(read_merkle_root)"
TOTAL_SUBSTRATE="$(read_substrate_total)"
TOTAL_EVM="$(read_evm_total)"
TREASURY_AMOUNT="$(read_treasury_amount)"
FOUNDATION_AMOUNT="$(read_foundation_amount)"

if [[ -z "$MERKLE_ROOT" || "$MERKLE_ROOT" == "null" || "$MERKLE_ROOT" == "0x" ]]; then
  echo "Failed to read Merkle root from $MERKLE_TREE_FILE" >&2
  exit 1
fi

if [[ "$TREASURY_AMOUNT" != "0" ]]; then
  : "${TREASURY_RECIPIENT:?Missing TREASURY_RECIPIENT (required when treasury carveout exists)}"
fi

if [[ "$FOUNDATION_AMOUNT" != "0" ]]; then
  : "${FOUNDATION_RECIPIENT:?Missing FOUNDATION_RECIPIENT (required when foundation carveout exists)}"
fi

MIGRATION_OWNER="${MIGRATION_OWNER:-}"
MIGRATION_MANIFEST_PATH="${MIGRATION_MANIFEST_PATH:-$ROOT_DIR/deployments/base-sepolia/migration.json}"
mkdir -p "$(dirname "$MIGRATION_MANIFEST_PATH")"

TNT_TOKEN_ADDRESS="${TNT_TOKEN_ADDRESS:-${TNT_TOKEN:-}}"
FULL_DEPLOY_MANIFEST="${FULL_DEPLOY_MANIFEST:-}"

if [[ -z "${TNT_TOKEN_ADDRESS}" ]]; then
  if [[ -n "$FULL_DEPLOY_MANIFEST" && -f "$FULL_DEPLOY_MANIFEST" ]]; then
    TNT_TOKEN_ADDRESS="$(node -e "const j=JSON.parse(require('fs').readFileSync(process.argv[1],'utf8'));process.stdout.write(String(j.tntToken||''));" "$FULL_DEPLOY_MANIFEST")"
  fi
fi

ALLOW_STANDALONE_TOKEN="${ALLOW_STANDALONE_TOKEN:-false}"
if [[ -z "${TNT_TOKEN_ADDRESS}" && "$ALLOW_STANDALONE_TOKEN" != "true" ]]; then
  echo "Missing TNT token address." >&2
  echo "Set TNT_TOKEN (preferred for feature parity) or set FULL_DEPLOY_MANIFEST to a FullDeploy manifest containing .tntToken." >&2
  echo "To allow deploying a standalone test token, set ALLOW_STANDALONE_TOKEN=true." >&2
  exit 1
fi

echo "==> Deploying migration to Base Sepolia"
echo "RPC:              $RPC_URL"
echo "Merkle root:       $MERKLE_ROOT"
echo "TOTAL_SUBSTRATE:   $TOTAL_SUBSTRATE"
echo "TOTAL_EVM:         $TOTAL_EVM"
echo "TREASURY_AMOUNT:   $TREASURY_AMOUNT"
echo "FOUNDATION_AMOUNT: $FOUNDATION_AMOUNT"
echo "TNT token:         ${TNT_TOKEN_ADDRESS:-<deploy-standalone>}"
echo "Migration owner:   ${MIGRATION_OWNER:-<deployer>}"
echo "Manifest path:     $MIGRATION_MANIFEST_PATH"
echo "Mock verifier:     $USE_MOCK_VERIFIER"

pushd "$ROOT_DIR/packages/migration-claim" >/dev/null

MERKLE_ROOT="$MERKLE_ROOT" \
TOTAL_SUBSTRATE="$TOTAL_SUBSTRATE" \
TOTAL_EVM="$TOTAL_EVM" \
TREASURY_AMOUNT="$TREASURY_AMOUNT" \
TREASURY_RECIPIENT="${TREASURY_RECIPIENT:-}" \
FOUNDATION_AMOUNT="$FOUNDATION_AMOUNT" \
FOUNDATION_RECIPIENT="${FOUNDATION_RECIPIENT:-}" \
MIGRATION_OWNER="${MIGRATION_OWNER:-}" \
MIGRATION_MANIFEST_PATH="$MIGRATION_MANIFEST_PATH" \
USE_MOCK_VERIFIER="$USE_MOCK_VERIFIER" \
PROGRAM_VKEY="${PROGRAM_VKEY:-}" \
SP1_VERIFIER="${SP1_VERIFIER:-}" \
TNT_TOKEN="$TNT_TOKEN_ADDRESS" \
PRIVATE_KEY="$PRIVATE_KEY" \
forge script script/DeployTangleMigration.s.sol:DeployTangleMigration \
  --rpc-url "$RPC_URL" \
  --broadcast \
  --non-interactive

popd >/dev/null

if [[ ! -f "$MIGRATION_MANIFEST_PATH" ]]; then
  echo "Expected manifest not found: $MIGRATION_MANIFEST_PATH" >&2
  exit 1
fi

TNT_TOKEN_ADDRESS="$(node -e "const j=JSON.parse(require('fs').readFileSync(process.argv[1],'utf8'));process.stdout.write(String(j.tntToken||''));" "$MIGRATION_MANIFEST_PATH")"
LOCK_FACTORY="$(node -e "const j=JSON.parse(require('fs').readFileSync(process.argv[1],'utf8'));process.stdout.write(String(j.lockFactory||''));" "$MIGRATION_MANIFEST_PATH")"
UNLOCK_TIMESTAMP="$(node -e "const j=JSON.parse(require('fs').readFileSync(process.argv[1],'utf8'));process.stdout.write(String(j.unlockTimestamp||''));" "$MIGRATION_MANIFEST_PATH")"
UNLOCKED_BPS="$(node -e "const j=JSON.parse(require('fs').readFileSync(process.argv[1],'utf8'));process.stdout.write(String(j.unlockedBps||''));" "$MIGRATION_MANIFEST_PATH")"

echo ""
echo "==> Migration deployed"
echo "Manifest:        $MIGRATION_MANIFEST_PATH"
echo "TNT token:        $TNT_TOKEN_ADDRESS"
echo "Lock factory:     $LOCK_FACTORY"
echo "Unlock timestamp: $UNLOCK_TIMESTAMP"
echo "Unlocked bps:     $UNLOCKED_BPS"

AIRDROP=false
CHUNK_SIZE="${CHUNK_SIZE:-200}"
OUT_DIR="${OUT_DIR:-$ROOT_DIR/deployments/base-sepolia/evm-airdrop}"

for arg in "$@"; do
  case "$arg" in
    --airdrop) AIRDROP=true ;;
    *) ;;
  esac
done

if [[ "$AIRDROP" != "true" ]]; then
  echo ""
  echo "Skipping EVM airdrop (pass --airdrop to execute)."
  echo "To generate batches only:"
  echo "  node scripts/evm-claims-to-distribution.mjs --input \"$EVM_CLAIMS_FILE\" --token \"$TNT_TOKEN_ADDRESS\" --out-dir \"$OUT_DIR\" --chunk-size $CHUNK_SIZE --unlock-timestamp \"$UNLOCK_TIMESTAMP\" --unlocked-bps \"$UNLOCKED_BPS\" --lock-factory \"$LOCK_FACTORY\""
  exit 0
fi

echo ""
echo "==> Generating EVM airdrop batches: $OUT_DIR"
mkdir -p "$OUT_DIR"
node "$ROOT_DIR/scripts/evm-claims-to-distribution.mjs" \
  --input "$EVM_CLAIMS_FILE" \
  --token "$TNT_TOKEN_ADDRESS" \
  --out-dir "$OUT_DIR" \
  --chunk-size "$CHUNK_SIZE" \
  --unlock-timestamp "$UNLOCK_TIMESTAMP" \
  --unlocked-bps "$UNLOCKED_BPS" \
  --lock-factory "$LOCK_FACTORY" \
  --prefix "evm-airdrop"

echo ""
echo "==> Executing EVM airdrop (this can take a while / cost gas)"
shopt -s nullglob
FILES=("$OUT_DIR"/evm-airdrop-part-*.json)
if [[ "${#FILES[@]}" -eq 0 ]]; then
  echo "No airdrop batch files found in: $OUT_DIR" >&2
  exit 1
fi

for f in "${FILES[@]}"; do
  echo "Airdrop batch: $f"
  DISTRIBUTION_FILE="$f" \
  TNT_TOKEN="$TNT_TOKEN_ADDRESS" \
  PRIVATE_KEY="$PRIVATE_KEY" \
  LOCK_FACTORY="$LOCK_FACTORY" \
  forge script script/DistributeTNTWithLockup.s.sol:DistributeTNTWithLockup \
    --rpc-url "$RPC_URL" \
    --broadcast \
    --non-interactive
done

echo ""
echo "Done."
