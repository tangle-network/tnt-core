#!/usr/bin/env bash
set -euo pipefail

# Generic orchestrator for an Ethereum L1 -> destination EVM chain slashing deployment.
#
# Steps:
# 1) Deploy protocol core on destination (FullDeploy)
# 2) Deploy beacon slashing infra on L1 with SKIP_CHAIN_CONFIG=true (connector + messenger)
# 3) Deploy L2 slashing receiver on destination (receiver + bridge receiver adapter)
# 4) Wire L1 connector -> destination receiver
# 5) (Optional) Deploy TNT migration on destination
#
# Required env:
#   PRIVATE_KEY
#   L1_RPC
#   DEST_RPC
#   DEST_CHAIN_ID          (destination chainId, e.g. 8453 Base, 42161 Arbitrum, Tempo chainId, etc.)
#   SOURCE_CHAIN_ID        (L1 chainId, e.g. 1 mainnet, 11155111 sepolia, 17000 holesky)
#
# Optional env:
#   FULL_DEPLOY_CONFIG     (defaults: deploy/config/base-sepolia-holesky.json)
#   SLASHING_BRIDGE        (hyperlane|layerzero, default: hyperlane)
#   L1_MANIFEST_PATH       (default: <manifestDir>/beacon-slashing.json)
#   L2_SLASHING_MANIFEST_PATH (default: <manifestDir>/l2-slashing.json)
#   DEPLOY_MIGRATION       (true|false, default: false)
#
# Bridge overrides for unsupported chains:
#   Hyperlane (L1 messenger): L1_HYPERLANE_MAILBOX + L1_HYPERLANE_IGP
#   LayerZero (L1 messenger): L1_LAYERZERO_ENDPOINT
#   Hyperlane (dest receiver): HYPERLANE_MAILBOX
#   LayerZero (dest receiver): LAYERZERO_ENDPOINT + LAYERZERO_SOURCE_EID
#
# Migration deploy (if DEPLOY_MIGRATION=true):
#   TREASURY_RECIPIENT required (treasury carveout exists in snapshot artifacts)
#   PROGRAM_VKEY required unless USE_MOCK_VERIFIER=true

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

: "${PRIVATE_KEY:?Missing PRIVATE_KEY}"
: "${L1_RPC:?Missing L1_RPC}"
: "${DEST_RPC:?Missing DEST_RPC}"
: "${DEST_CHAIN_ID:?Missing DEST_CHAIN_ID}"
: "${SOURCE_CHAIN_ID:?Missing SOURCE_CHAIN_ID}"

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

MANIFEST_DIR="$(dirname "$MANIFEST_PATH")"
L1_MANIFEST_PATH="${L1_MANIFEST_PATH:-$MANIFEST_DIR/beacon-slashing.json}"
L2_SLASHING_MANIFEST_PATH="${L2_SLASHING_MANIFEST_PATH:-$MANIFEST_DIR/l2-slashing.json}"

echo "==> 1/4 Deploy protocol core on destination (chainId=$DEST_CHAIN_ID)"
FULL_DEPLOY_CONFIG="$FULL_DEPLOY_CONFIG" \
forge script script/v2/FullDeploy.s.sol:FullDeploy \
  --rpc-url "$DEST_RPC" \
  --broadcast \
  --non-interactive

RESTAKING_ADDR="$(jq -r '.restaking' "$MANIFEST_PATH")"
if [[ -z "$RESTAKING_ADDR" || "$RESTAKING_ADDR" == "null" || "$RESTAKING_ADDR" == "0x0000000000000000000000000000000000000000" ]]; then
  echo "Missing restaking address in manifest: $MANIFEST_PATH" >&2
  exit 1
fi

echo "==> 2/4 Deploy beacon slashing infra on L1 (chainId=$SOURCE_CHAIN_ID) (no dest wiring yet)"
L1_SCRIPT="DeployBeaconSlashingL1"
if [[ "$SLASHING_BRIDGE" == "layerzero" ]]; then
  L1_SCRIPT="DeployBeaconSlashingL1LayerZero"
fi

SKIP_CHAIN_CONFIG=true \
TANGLE_CHAIN_ID="$DEST_CHAIN_ID" \
BEACON_SLASHING_MANIFEST="$L1_MANIFEST_PATH" \
forge script "script/v2/DeployBeaconSlashing.s.sol:$L1_SCRIPT" \
  --rpc-url "$L1_RPC" \
  --broadcast \
  --non-interactive

L1_CONNECTOR_ADDR="$(jq -r '.connector' "$L1_MANIFEST_PATH")"
L1_MESSENGER_ADDR="$(jq -r '.messenger' "$L1_MANIFEST_PATH")"
if [[ "$L1_CONNECTOR_ADDR" == "null" || "$L1_MESSENGER_ADDR" == "null" ]]; then
  echo "Missing connector/messenger in L1 manifest: $L1_MANIFEST_PATH" >&2
  exit 1
fi

echo "==> 3/4 Deploy destination slashing receiver (bridge=$SLASHING_BRIDGE)"
case "$SLASHING_BRIDGE" in
  hyperlane) L2_BRIDGE_CONTRACT="DeployL2SlashingHyperlane" ;;
  layerzero) L2_BRIDGE_CONTRACT="DeployL2SlashingLayerZero" ;;
  *) echo "Unsupported SLASHING_BRIDGE: $SLASHING_BRIDGE (expected hyperlane|layerzero)" >&2; exit 1 ;;
esac

RESTAKING="$RESTAKING_ADDR" \
SOURCE_CHAIN_ID="$SOURCE_CHAIN_ID" \
L1_CONNECTOR="$L1_CONNECTOR_ADDR" \
L1_MESSENGER="$L1_MESSENGER_ADDR" \
L2_SLASHING_MANIFEST="$L2_SLASHING_MANIFEST_PATH" \
forge script "script/v2/DeployL2Slashing.s.sol:$L2_BRIDGE_CONTRACT" \
  --rpc-url "$DEST_RPC" \
  --broadcast \
  --non-interactive

L2_RECEIVER_ADDR="$(jq -r '.receiver' "$L2_SLASHING_MANIFEST_PATH")"
if [[ -z "$L2_RECEIVER_ADDR" || "$L2_RECEIVER_ADDR" == "null" || "$L2_RECEIVER_ADDR" == "0x0000000000000000000000000000000000000000" ]]; then
  echo "Missing destination receiver in manifest: $L2_SLASHING_MANIFEST_PATH" >&2
  exit 1
fi

echo "==> 4/4 Wire L1 connector -> destination receiver"
CONNECTOR="$L1_CONNECTOR_ADDR" \
MESSENGER="$L1_MESSENGER_ADDR" \
TANGLE_CHAIN_ID="$DEST_CHAIN_ID" \
L2_RECEIVER="$L2_RECEIVER_ADDR" \
forge script script/v2/DeployBeaconSlashing.s.sol:ConfigureL2SlashingConnector \
  --rpc-url "$L1_RPC" \
  --broadcast \
  --non-interactive

if [[ "$DEPLOY_MIGRATION" == "true" ]]; then
  echo "==> Migration is handled by FullDeploy (migration.deploy=true); skipping standalone deploy."
fi

echo ""
echo "Done."
echo "Core manifest:      $MANIFEST_PATH"
echo "L1 slashing:        $L1_MANIFEST_PATH"
echo "Destination slashing: $L2_SLASHING_MANIFEST_PATH"
