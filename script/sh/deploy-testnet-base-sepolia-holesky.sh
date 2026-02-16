#!/usr/bin/env bash
set -euo pipefail

# Deploy orchestrator for a Holesky (L1) ↔ Base Sepolia (L2) testnet environment.
# - Base Sepolia: deploy protocol core (FullDeploy) + L2 slashing receiver
# - Holesky: deploy beacon slashing connector + messenger, then wire to Base Sepolia receiver
#
# Prereqs:
# - jq installed
# - env: PRIVATE_KEY, BASE_SEPOLIA_RPC, HOLESKY_RPC
# - env (optional): FULL_DEPLOY_CONFIG (defaults to deploy/config/base-sepolia-holesky.json)
# - env (optional): SLASHING_BRIDGE=hyperlane|layerzero (defaults: hyperlane)
#
# LayerZero note: you likely need to set LAYERZERO_SOURCE_EID for Holesky.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

: "${PRIVATE_KEY:?Missing PRIVATE_KEY}"
: "${BASE_SEPOLIA_RPC:?Missing BASE_SEPOLIA_RPC}"
: "${HOLESKY_RPC:?Missing HOLESKY_RPC}"

FULL_DEPLOY_CONFIG="${FULL_DEPLOY_CONFIG:-deploy/config/base-sepolia-holesky.json}"
SLASHING_BRIDGE="${SLASHING_BRIDGE:-hyperlane}"
DEPLOY_MIGRATION="${DEPLOY_MIGRATION:-false}"

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required" >&2
  exit 1
fi

if [[ ! -f "$FULL_DEPLOY_CONFIG" ]]; then
  echo "Config not found: $FULL_DEPLOY_CONFIG" >&2
  exit 1
fi

MANIFEST_PATH="$(jq -r '.manifest.path' "$FULL_DEPLOY_CONFIG")"
if [[ -z "$MANIFEST_PATH" || "$MANIFEST_PATH" == "null" ]]; then
  echo "Missing .manifest.path in $FULL_DEPLOY_CONFIG" >&2
  exit 1
fi

L1_MANIFEST_PATH="${L1_MANIFEST_PATH:-deployments/base-sepolia-holesky/beacon-slashing.json}"
L2_SLASHING_MANIFEST_PATH="${L2_SLASHING_MANIFEST_PATH:-deployments/base-sepolia-holesky/l2-slashing.json}"

if [[ "$DEPLOY_MIGRATION" == "true" && -z "${TNT_INITIAL_SUPPLY:-}" ]]; then
  # If we plan to deploy the migration system on Base Sepolia, ensure the default TNT supply
  # is large enough to fund Substrate claims + EVM airdrop + treasury carveout.
  TNT_INITIAL_SUPPLY="$(node -e \"const fs=require('fs');const m=JSON.parse(fs.readFileSync('packages/migration-claim/merkle-tree.json','utf8'));const e=JSON.parse(fs.readFileSync('packages/migration-claim/evm-claims.json','utf8'));let t=0n;let f=0n;try{t=BigInt(JSON.parse(fs.readFileSync('packages/migration-claim/treasury-carveout.json','utf8')).amount||'0');}catch{};try{f=BigInt(JSON.parse(fs.readFileSync('packages/migration-claim/foundation-carveout.json','utf8')).amount||'0');}catch{};process.stdout.write((BigInt(m.totalValue)+BigInt(e.totalAmount)+t+f).toString());\")"
  export TNT_INITIAL_SUPPLY
  echo "DEPLOY_MIGRATION=true: defaulting TNT_INITIAL_SUPPLY=$TNT_INITIAL_SUPPLY"
fi

echo "==> 1/4 Deploy protocol core on Base Sepolia"
FULL_DEPLOY_CONFIG="$FULL_DEPLOY_CONFIG" \
forge script script/FullDeploy.s.sol:FullDeploy \
  --rpc-url "$BASE_SEPOLIA_RPC" \
  --broadcast \
  --non-interactive

RESTAKING_ADDR="$(jq -r '.restaking' "$MANIFEST_PATH")"
if [[ -z "$RESTAKING_ADDR" || "$RESTAKING_ADDR" == "null" || "$RESTAKING_ADDR" == "0x0000000000000000000000000000000000000000" ]]; then
  echo "Missing restaking address in manifest: $MANIFEST_PATH" >&2
  exit 1
fi

echo "==> 2/4 Deploy beacon slashing infra on Holesky (no L2 wiring yet)"
L1_SCRIPT="DeployBeaconSlashingL1Holesky"
if [[ "$SLASHING_BRIDGE" == "layerzero" ]]; then
  L1_SCRIPT="DeployBeaconSlashingL1HoleskyLayerZero"
fi

SKIP_CHAIN_CONFIG=true \
TANGLE_CHAIN_ID=84532 \
BEACON_SLASHING_MANIFEST="$L1_MANIFEST_PATH" \
forge script "script/DeployBeaconSlashing.s.sol:$L1_SCRIPT" \
  --rpc-url "$HOLESKY_RPC" \
  --broadcast \
  --non-interactive

L1_CONNECTOR_ADDR="$(jq -r '.connector' "$L1_MANIFEST_PATH")"
L1_MESSENGER_ADDR="$(jq -r '.messenger' "$L1_MANIFEST_PATH")"
if [[ "$L1_CONNECTOR_ADDR" == "null" || "$L1_MESSENGER_ADDR" == "null" ]]; then
  echo "Missing connector/messenger in L1 manifest: $L1_MANIFEST_PATH" >&2
  exit 1
fi

echo "==> 3/4 Deploy L2 slashing receiver on Base Sepolia"
case "$SLASHING_BRIDGE" in
  hyperlane) L2_BRIDGE_CONTRACT="DeployL2SlashingHyperlane" ;;
  layerzero)
    if [[ -z "${LAYERZERO_SOURCE_EID:-}" ]]; then
      echo "Missing LAYERZERO_SOURCE_EID (required for Holesky source)" >&2
      exit 1
    fi
    L2_BRIDGE_CONTRACT="DeployL2SlashingLayerZero"
    ;;
  *)
    echo "Unsupported SLASHING_BRIDGE: $SLASHING_BRIDGE (expected hyperlane|layerzero)" >&2
    exit 1
    ;;
esac

RESTAKING="$RESTAKING_ADDR" \
SOURCE_CHAIN_ID=17000 \
L1_CONNECTOR="$L1_CONNECTOR_ADDR" \
L1_MESSENGER="$L1_MESSENGER_ADDR" \
L2_SLASHING_MANIFEST="$L2_SLASHING_MANIFEST_PATH" \
forge script "script/DeployL2Slashing.s.sol:$L2_BRIDGE_CONTRACT" \
  --rpc-url "$BASE_SEPOLIA_RPC" \
  --broadcast \
  --non-interactive

L2_RECEIVER_ADDR="$(jq -r '.receiver' "$L2_SLASHING_MANIFEST_PATH")"
if [[ -z "$L2_RECEIVER_ADDR" || "$L2_RECEIVER_ADDR" == "null" || "$L2_RECEIVER_ADDR" == "0x0000000000000000000000000000000000000000" ]]; then
  echo "Missing L2 receiver in manifest: $L2_SLASHING_MANIFEST_PATH" >&2
  exit 1
fi

echo "==> 4/4 Wire Holesky connector -> Base Sepolia receiver"
CONNECTOR="$L1_CONNECTOR_ADDR" \
MESSENGER="$L1_MESSENGER_ADDR" \
TANGLE_CHAIN_ID=84532 \
L2_RECEIVER="$L2_RECEIVER_ADDR" \
forge script script/DeployBeaconSlashing.s.sol:ConfigureL2SlashingConnector \
  --rpc-url "$HOLESKY_RPC" \
  --broadcast \
  --non-interactive

if [[ "$DEPLOY_MIGRATION" == "true" ]]; then
  echo "==> Migration is handled by FullDeploy (migration.deploy=true); skipping standalone deploy."
fi

echo ""
echo "Done."
echo "Base Sepolia core manifest: $MANIFEST_PATH"
echo "Holesky slashing manifest:  $L1_MANIFEST_PATH"
echo "Base Sepolia slashing manifest: $L2_SLASHING_MANIFEST_PATH"
