#!/usr/bin/env bash
# Publish v0 (genesis binary version) on-chain for the four ai-trading
# blueprints registered on Base Sepolia:
#
#   13 trading           -> trading-blueprint-x86_64-unknown-linux-gnu.tar.xz
#   14 instance          -> trading-instance-blueprint-x86_64-unknown-linux-gnu.tar.xz
#   15 tee-instance      -> trading-tee-instance-blueprint-x86_64-unknown-linux-gnu.tar.xz
#   16 validator         -> trading-validator-x86_64-unknown-linux-gnu.tar.xz
#
# Closes the `no_v0_published` column in deployments/base-sepolia/blueprints.tsv
# for the trading row(s). Append-only + idempotent — re-running is a no-op if
# a version is already published (see deploy/publish-binary.sh for the guard).
#
# Required env (loaded from the secrets repo, NOT baked here):
#   PRIVATE_KEY  - blueprint owner key (shared-testnet-deployer; 0x2420…)
#
# Optional env (sensible defaults):
#   TAG          - GitHub release tag to publish (default v0.1.3)
#   TANGLE_CORE  - default loaded from deployments/base-sepolia/latest.json
#   RPC_URL      - default https://sepolia.base.org
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TAG="${TAG:-v0.1.3}"
RPC_URL="${RPC_URL:-https://sepolia.base.org}"
TANGLE_CORE="${TANGLE_CORE:-$(jq -r '.tangle' "$ROOT_DIR/deployments/base-sepolia/latest.json")}"
: "${PRIVATE_KEY:?set PRIVATE_KEY (blueprint owner key)}"

REPO="tangle-network/ai-trading-blueprint"
TGT="x86_64-unknown-linux-gnu"
TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

# id  binary
publish_pairs=(
  "13 trading-blueprint"
  "14 trading-instance-blueprint"
  "15 trading-tee-instance-blueprint"
  "16 trading-validator"
)

for pair in "${publish_pairs[@]}"; do
  read -r BID BIN <<<"$pair"
  A="${BIN}-${TGT}.tar.xz"
  URL="https://github.com/${REPO}/releases/download/${TAG}/${A}"
  echo
  echo "=== publishing blueprint $BID ($BIN) from ${TAG} ==="
  curl -fsSL "$URL" -o "$TMPDIR/$A"

  # sha256 is computed by publish-binary.sh against BINARY_PATH; pass the
  # tarball itself (operators verify the same artifact they downloaded).
  TANGLE_CORE="$TANGLE_CORE" \
  RPC_URL="$RPC_URL" \
  PRIVATE_KEY="$PRIVATE_KEY" \
  BLUEPRINT_ID="$BID" \
  BINARY_PATH="$TMPDIR/$A" \
  BINARY_URI="$URL" \
    "$ROOT_DIR/deploy/publish-binary.sh"
done

echo
echo "all four ai-trading blueprints published on-chain (or already had v0)."
echo "verify with:"
echo "  for id in 13 14 15 16; do"
echo "    cast call $TANGLE_CORE 'getBinaryVersionCount(uint64)(uint64)' \$id --rpc-url $RPC_URL"
echo "  done"
