#!/usr/bin/env bash
#
# Production launch orchestrator — runs the full Tangle protocol deploy as a sequence of
# standalone forge scripts, threading core addresses between them via the deployment manifest.
#
#   FullDeploy (core: Tangle, staking, incentives, governance)   [this chain, L2_RPC]
#     -> DeployLiquidDelegation (liquid-staking vault factory)    [this chain]   turnkey
#     -> DeployBeaconSlashing   (L1 beacon slash bridge)          [L1_RPC]       cross-chain
#     -> DeployL2Slashing       (L2 slash receiver + slasher)     [this chain]   cross-chain
#
# Liquid vaults are fully turnkey. Beacon + L2 slashing are a cross-chain system: this script
# wires the on-chain pieces, but mainnet activation requires operational inputs (bridge ISM/DVN
# pinning, an off-chain slashing oracle) and post-deploy TIMELOCK actions that NO deploy key can
# perform. Those are enumerated at the end and in deploy/RUNBOOK-launch.md. The subsystem scripts
# fail closed on production chains if admin/oracle are the deployer or a mock bridge/oracle is used.
#
# Usage:
#   PRIVATE_KEY=0x... L2_RPC=<core-chain-rpc> [L1_RPC=<ethereum-rpc>] \
#   FULL_DEPLOY_CONFIG=deploy/config/base-mainnet.json \
#   deploy/deploy-all.sh
#
set -euo pipefail

CONFIG="${FULL_DEPLOY_CONFIG:?set FULL_DEPLOY_CONFIG (e.g. deploy/config/base-mainnet.json)}"
: "${PRIVATE_KEY:?set PRIVATE_KEY}"
: "${L2_RPC:?set L2_RPC (the core/Tangle chain RPC)}"
command -v jq >/dev/null || { echo "jq is required"; exit 1; }
test -f "$CONFIG" || { echo "config not found: $CONFIG"; exit 1; }

NETWORK="$(jq -r '.network // "unknown"' "$CONFIG")"
MANIFEST="$(jq -r '.manifest.path // ("deployments/" + .network + "/latest.json")' "$CONFIG")"
cfg() { jq -r "$1 // empty" "$CONFIG"; }

echo "=== Tangle full launch orchestrator ==="
echo "network=$NETWORK  config=$CONFIG  manifest=$MANIFEST"

# 1) Core — produces the manifest the rest read.
echo "--- [1/4] FullDeploy (core) on L2_RPC ---"
FULL_DEPLOY_CONFIG="$CONFIG" forge script script/FullDeploy.s.sol:FullDeploy --rpc-url "$L2_RPC" --broadcast --slow
test -f "$MANIFEST" || { echo "manifest not written: $MANIFEST"; exit 1; }

STAKING="$(jq -r '.staking' "$MANIFEST")"
TIMELOCK="$(jq -r '.timelock' "$MANIFEST")"
echo "core staking=$STAKING  timelock=$TIMELOCK"

# 2) Liquid-staking vault factory (turnkey; depends only on staking).
if [ "$(cfg '.liquidVaults.deploy')" = "true" ]; then
  echo "--- [2/4] DeployLiquidDelegation (vault factory) on L2_RPC ---"
  OWNER="$(cfg '.liquidVaults.owner')"; [ -z "$OWNER" ] || [ "$OWNER" = "0x0000000000000000000000000000000000000000" ] && OWNER="$TIMELOCK"
  STAKING="$STAKING" TIMELOCK="$OWNER" \
    forge script script/DeployLiquidDelegation.s.sol:DeployLiquidDelegation --rpc-url "$L2_RPC" --broadcast --slow
else
  echo "--- [2/4] liquidVaults.deploy=false — skipped ---"
fi

# 3) Beacon L1 slash bridge (cross-chain; needs L1_RPC + bridge + oracle).
#    Default bridge is OP-Stack canonical messenger (Base/Optimism) — native, no ISM/DVN to pin.
if [ "$(cfg '.beacon.deploy')" = "true" ]; then
  echo "--- [3/4] DeployBeaconSlashing (L1 leg) on L1_RPC ---"
  : "${L1_RPC:?beacon.deploy=true requires L1_RPC (Ethereum mainnet)}"
  BRIDGE="$(cfg '.beacon.bridge')"; BRIDGE="${BRIDGE:-opstack}"
  case "$BRIDGE" in
    opstack)   BEACON_ENTRY="DeployBeaconSlashingOpStack" ;;
    *)         BEACON_ENTRY="DeployBeaconSlashingOpStack" ;;  # OP-Stack-native; HL/LZ removed
  esac
  echo "    bridge=$BRIDGE entry=$BEACON_ENTRY"
  ADMIN="$(cfg '.beacon.admin')" \
  SLASHING_ORACLE="$(cfg '.beacon.slashingOracle')" \
  BEACON_ORACLE="$(cfg '.beacon.beaconOracle')" \
  L1_CROSS_DOMAIN_MESSENGER="$(cfg '.beacon.l1CrossDomainMessenger')" \
  TANGLE_CHAIN_ID="$(jq -r '.chainId' "$MANIFEST")" \
  SKIP_CHAIN_CONFIG=true \
  BEACON_SLASHING_MANIFEST="deployments/$NETWORK/beacon-l1.json" \
    forge script "script/DeployBeaconSlashing.s.sol:$BEACON_ENTRY" --rpc-url "$L1_RPC" --broadcast --slow
else
  echo "--- [3/4] beacon.deploy=false — skipped ---"
fi

# 4) L2 slash receiver + slasher (cross-chain; needs the L1 connector/messenger from step 3).
#    For OP-Stack, L1_MESSENGER is the L1 BaseCrossChainMessenger (xDomainMessageSender on L2).
if [ "$(cfg '.l2Slashing.deploy')" = "true" ]; then
  echo "--- [4/4] DeployL2Slashing (L2 leg) on L2_RPC ---"
  BRIDGE="$(cfg '.l2Slashing.bridge')"; BRIDGE="${BRIDGE:-opstack}"
  case "$BRIDGE" in
    opstack)   L2_ENTRY="DeployL2SlashingOpStack" ;;
    *)         L2_ENTRY="DeployL2SlashingOpStack" ;;  # OP-Stack-native; HL/LZ removed
  esac
  echo "    bridge=$BRIDGE entry=$L2_ENTRY"
  ADMIN="$(cfg '.l2Slashing.admin')" \
  STAKING="$STAKING" \
  SOURCE_CHAIN_ID="$(cfg '.l2Slashing.sourceChainId')" \
  L1_CONNECTOR="$(cfg '.l2Slashing.l1Connector')" \
  L1_MESSENGER="$(cfg '.l2Slashing.l1Messenger')" \
  L2_CROSS_DOMAIN_MESSENGER="$(cfg '.l2Slashing.l2CrossDomainMessenger')" \
  L2_SLASHING_MANIFEST="deployments/$NETWORK/l2-slashing.json" \
    forge script "script/DeployL2Slashing.s.sol:$L2_ENTRY" --rpc-url "$L2_RPC" --broadcast --slow
else
  echo "--- [4/4] l2Slashing.deploy=false — skipped ---"
fi

cat <<'EOF'

=== Deploy complete. REQUIRED post-deploy actions (must be done by the TIMELOCK/multisig) ===
If beacon + l2Slashing were deployed, slashing is INERT until ALL of the following:
  1. staking.addSlasher(TangleL2Slasher)      — authorize the L2 slasher on MultiAssetDelegation
                                                 (must be sent by the staking ASSET_MANAGER/admin = timelock).
  2. Bridge is OP-Stack-native (Base/Optimism canonical CrossDomainMessenger) — no third-party ISM/DVN to pin.
  3. After SENDER_ACTIVATION_DELAY (2 days): L2SlashingReceiver.activateOpStackL1Sender(srcChain, l1Messenger)
                                              (l1Messenger = the L1 BaseCrossChainMessenger adapter).
  4. Wire the L1 connector -> L2 receiver: ConfigureL2SlashingConnector (L1_RPC) with L2_RECEIVER from the L2 manifest.
  5. Register pod->operator mappings (L2SlashingConnector.registerPodOperator) for onboarded pods.
See deploy/RUNBOOK-launch.md for the full checklist.
EOF
