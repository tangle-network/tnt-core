#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Wait for funding, then deploy migration contracts to Base Sepolia.

Usage:
  scripts/deploy-migration-base-sepolia-wait.sh [options] [-- <deploy args>]

Options:
  --private-key <hex>    Deployer private key (or set PRIVATE_KEY)
  --rpc-url <url>        Base Sepolia RPC URL (or set BASE_SEPOLIA_RPC)
  --gas-estimate <n>     Gas units estimate (default: 12000000)
  --buffer-percent <n>   Extra % buffer on top of estimate (default: 20)
  --interval <sec>       Poll interval in seconds (default: 10)
  --gas-price <wei>      Override gas price in wei (default: rpc gas price)
  --airdrop              Pass --airdrop to deploy script
  -h, --help             Show this help

Env (used by deploy script):
  PRIVATE_KEY, BASE_SEPOLIA_RPC, TNT_TOKEN, ALLOW_STANDALONE_TOKEN,
  TREASURY_RECIPIENT, FOUNDATION_RECIPIENT, USE_MOCK_VERIFIER, PROGRAM_VKEY,
  SP1_VERIFIER, MIGRATION_OWNER, FULL_DEPLOY_MANIFEST

Examples:
  PRIVATE_KEY=0xabc BASE_SEPOLIA_RPC=https://... \
    scripts/deploy-migration-base-sepolia-wait.sh --airdrop

  scripts/deploy-migration-base-sepolia-wait.sh \
    --private-key 0xabc --rpc-url https://... --buffer-percent 30
EOF
}

PRIVATE_KEY="${PRIVATE_KEY:-}"
RPC_URL="${BASE_SEPOLIA_RPC:-${RPC_URL:-}}"
GAS_ESTIMATE="${GAS_ESTIMATE:-12000000}"
BUFFER_PERCENT="${BUFFER_PERCENT:-20}"
INTERVAL="${INTERVAL:-10}"
GAS_PRICE_OVERRIDE="${GAS_PRICE_OVERRIDE:-}"
DEPLOY_ARGS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --private-key)
      PRIVATE_KEY="$2"
      shift 2
      ;;
    --rpc-url)
      RPC_URL="$2"
      shift 2
      ;;
    --gas-estimate)
      GAS_ESTIMATE="$2"
      shift 2
      ;;
    --buffer-percent)
      BUFFER_PERCENT="$2"
      shift 2
      ;;
    --interval)
      INTERVAL="$2"
      shift 2
      ;;
    --gas-price)
      GAS_PRICE_OVERRIDE="$2"
      shift 2
      ;;
    --airdrop)
      DEPLOY_ARGS+=("--airdrop")
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      DEPLOY_ARGS+=("$@")
      break
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ -z "$PRIVATE_KEY" ]]; then
  echo "Missing PRIVATE_KEY (use --private-key or env)." >&2
  exit 1
fi

if [[ -z "$RPC_URL" ]]; then
  echo "Missing BASE_SEPOLIA_RPC (use --rpc-url or env)." >&2
  exit 1
fi

if ! command -v cast >/dev/null 2>&1; then
  echo "Missing 'cast' (Foundry). Install: https://getfoundry.sh" >&2
  exit 1
fi

if ! command -v node >/dev/null 2>&1; then
  echo "Missing 'node'." >&2
  exit 1
fi

chain_id="$(cast chain-id --rpc-url "$RPC_URL" 2>/dev/null || true)"
if [[ -n "$chain_id" && "$chain_id" != "84532" ]]; then
  echo "Warning: RPC chain-id is $chain_id (expected 84532 for Base Sepolia)." >&2
fi

address="$(cast wallet address --private-key "$PRIVATE_KEY")"
if [[ -z "$address" ]]; then
  echo "Failed to derive address from private key." >&2
  exit 1
fi

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
treasury_amount="$(node -e "const fs=require('fs');const f='${root_dir}/packages/migration-claim/treasury-carveout.json';if(!fs.existsSync(f)){process.stdout.write('0');process.exit(0);}const j=JSON.parse(fs.readFileSync(f,'utf8'));process.stdout.write(String(j.amount||'0'));" || echo "0")"
foundation_amount="$(node -e "const fs=require('fs');const f='${root_dir}/packages/migration-claim/foundation-carveout.json';if(!fs.existsSync(f)){process.stdout.write('0');process.exit(0);}const j=JSON.parse(fs.readFileSync(f,'utf8'));process.stdout.write(String(j.amount||'0'));" || echo "0")"

if [[ "$treasury_amount" != "0" && -z "${TREASURY_RECIPIENT:-}" ]]; then
  echo "Missing TREASURY_RECIPIENT (treasury carveout exists)." >&2
  exit 1
fi

if [[ "$foundation_amount" != "0" && -z "${FOUNDATION_RECIPIENT:-}" ]]; then
  echo "Missing FOUNDATION_RECIPIENT (foundation carveout exists)." >&2
  exit 1
fi

if [[ "${USE_MOCK_VERIFIER:-false}" == "true" ]]; then
  echo "USE_MOCK_VERIFIER=true is not allowed for this flow. Unset it or set USE_MOCK_VERIFIER=false." >&2
  exit 1
fi

if [[ -z "${TNT_TOKEN:-}" && "${ALLOW_STANDALONE_TOKEN:-false}" != "true" && -z "${FULL_DEPLOY_MANIFEST:-}" ]]; then
  echo "Missing TNT token address. Set TNT_TOKEN, FULL_DEPLOY_MANIFEST, or ALLOW_STANDALONE_TOKEN=true." >&2
  exit 1
fi

if [[ -z "${PROGRAM_VKEY:-}" ]]; then
  echo "Missing PROGRAM_VKEY (required for real SP1 verifier)." >&2
  exit 1
fi

gas_price="${GAS_PRICE_OVERRIDE:-}"
if [[ -z "$gas_price" ]]; then
  gas_price="$(cast gas-price --rpc-url "$RPC_URL")"
fi

required_wei="$(node -e "
const gas=BigInt('${GAS_ESTIMATE}');
const price=BigInt('${gas_price}');
const buffer=BigInt('${BUFFER_PERCENT}');
const required=(gas*price*(100n+buffer)+99n)/100n;
process.stdout.write(required.toString());
")"

format_ether() {
  node -e "const w=BigInt(process.argv[1]);const eth=Number(w)/1e18;process.stdout.write(eth.toFixed(6));" "$1"
}

required_eth="$(format_ether "$required_wei")"
gas_price_gwei="$(node -e "const w=BigInt('${gas_price}');process.stdout.write((Number(w)/1e9).toFixed(2));")"

echo "Deployer address: $address"
echo "RPC: $RPC_URL"
echo "Gas price: ${gas_price_gwei} gwei"
echo "Estimate: ${GAS_ESTIMATE} gas + ${BUFFER_PERCENT}% buffer"
echo "Estimated required: ${required_eth} ETH (${required_wei} wei)"
echo "Waiting for funds..."

while true; do
  balance="$(cast balance "$address" --rpc-url "$RPC_URL")"
  balance_eth="$(format_ether "$balance")"
  if [[ "$(node -e "console.log(BigInt('${balance}') >= BigInt('${required_wei}') ? 'yes' : 'no')")" == "yes" ]]; then
    echo "Balance OK: ${balance_eth} ETH (${balance} wei). Proceeding with deployment..."
    break
  fi
  echo "Balance: ${balance_eth} ETH (${balance} wei) - waiting..."
  sleep "$INTERVAL"
done

PRIVATE_KEY="$PRIVATE_KEY" \
BASE_SEPOLIA_RPC="$RPC_URL" \
bash "$root_dir/scripts/deploy-migration-base-sepolia.sh" "${DEPLOY_ARGS[@]}"
