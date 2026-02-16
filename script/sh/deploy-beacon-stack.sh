#!/usr/bin/env bash
# Deploy Beacon Native Restaking Stack
# Orchestrates the 4-phase deployment across L1 and L2

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
BRIDGE="hyperlane"
DRY_RUN=false
SKIP_PHASE=""

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Deploy the Tangle beacon native restaking stack across L1 and L2."
    echo ""
    echo "Required environment variables:"
    echo "  PRIVATE_KEY         Deployer private key"
    echo "  L1_RPC_URL          L1 RPC endpoint (Ethereum/Holesky)"
    echo "  L2_RPC_URL          L2 RPC endpoint (Base/Tangle)"
    echo ""
    echo "Optional environment variables:"
    echo "  ADMIN               Admin address (defaults to deployer)"
    echo "  TREASURY            Treasury address (for L2 core)"
    echo "  SLASHING_ORACLE     Oracle that triggers slashing (defaults to deployer)"
    echo "  L2_CHAIN_ID         L2 chain ID (default: auto-detect)"
    echo "  L1_CHAIN_ID         L1 chain ID (default: auto-detect)"
    echo ""
    echo "Options:"
    echo "  --bridge BRIDGE     Bridge protocol: hyperlane or layerzero (default: hyperlane)"
    echo "  --config FILE       L2 deploy config JSON (for Phase 1)"
    echo "  --dry-run           Print commands without executing"
    echo "  --skip-phase N      Skip phase N (1-4)"
    echo "  -h, --help          Show this help message"
    echo ""
    echo "Phases:"
    echo "  1. Deploy L2 Core (Tangle + MultiAssetDelegation)"
    echo "  2. Deploy L1 Beacon (ValidatorPodManager + L2SlashingConnector)"
    echo "  3. Deploy L2 Slashing (L2SlashingReceiver + TangleL2Slasher)"
    echo "  4. Wire L1→L2 (Configure connector with receiver address)"
    exit 0
}

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

run_cmd() {
    if [[ "$DRY_RUN" == "true" ]]; then
        echo -e "${YELLOW}[DRY-RUN]${NC} $*"
    else
        log_info "Running: $*"
        "$@"
    fi
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --bridge) BRIDGE="$2"; shift 2 ;;
        --config) CONFIG="$2"; shift 2 ;;
        --dry-run) DRY_RUN=true; shift ;;
        --skip-phase) SKIP_PHASE="$2"; shift 2 ;;
        -h|--help) usage ;;
        *) log_error "Unknown option: $1"; usage ;;
    esac
done

# Validate required env vars
[[ -z "${PRIVATE_KEY:-}" ]] && { log_error "PRIVATE_KEY not set"; exit 1; }
[[ -z "${L1_RPC_URL:-}" ]] && { log_error "L1_RPC_URL not set"; exit 1; }
[[ -z "${L2_RPC_URL:-}" ]] && { log_error "L2_RPC_URL not set"; exit 1; }

# Set defaults
ADMIN="${ADMIN:-}"
TREASURY="${TREASURY:-}"
SLASHING_ORACLE="${SLASHING_ORACLE:-}"

# Manifest directory
MANIFEST_DIR="deploy/manifests/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$MANIFEST_DIR"

log_info "=== Tangle Beacon Native Restaking Deployment ==="
log_info "Bridge: $BRIDGE"
log_info "Manifests: $MANIFEST_DIR"
echo ""

# ============================================================================
# PHASE 1: Deploy L2 Core Protocol
# ============================================================================
phase1() {
    log_info "=== PHASE 1: Deploy L2 Core Protocol ==="

    if [[ -z "${CONFIG:-}" ]]; then
        log_warn "No --config specified, skipping Phase 1"
        log_warn "Set RESTAKING env var to existing MultiAssetDelegation address"
        return
    fi

    export FULL_DEPLOY_CONFIG="$CONFIG"

    run_cmd forge script script/FullDeploy.s.sol:FullDeploy \
        --rpc-url "$L2_RPC_URL" \
        --broadcast \
        --slow

    log_success "Phase 1 complete - L2 core deployed"
    echo ""
}

# ============================================================================
# PHASE 2: Deploy L1 Beacon Infrastructure
# ============================================================================
phase2() {
    log_info "=== PHASE 2: Deploy L1 Beacon Infrastructure ==="

    # Detect L2 chain ID if not set
    if [[ -z "${L2_CHAIN_ID:-}" ]]; then
        L2_CHAIN_ID=$(cast chain-id --rpc-url "$L2_RPC_URL")
        log_info "Detected L2 chain ID: $L2_CHAIN_ID"
    fi

    export TANGLE_CHAIN_ID="$L2_CHAIN_ID"
    export SKIP_CHAIN_CONFIG=true  # We'll configure in Phase 4
    export BEACON_SLASHING_MANIFEST="$MANIFEST_DIR/beacon-l1.json"

    local script_name
    if [[ "$BRIDGE" == "layerzero" ]]; then
        script_name="DeployBeaconSlashingL1LayerZero"
    else
        script_name="DeployBeaconSlashingL1"
    fi

    run_cmd forge script "script/DeployBeaconSlashing.s.sol:$script_name" \
        --rpc-url "$L1_RPC_URL" \
        --broadcast \
        --slow

    log_success "Phase 2 complete - L1 beacon infrastructure deployed"
    log_info "Manifest: $MANIFEST_DIR/beacon-l1.json"
    echo ""
}

# ============================================================================
# PHASE 3: Deploy L2 Slashing Receiver
# ============================================================================
phase3() {
    log_info "=== PHASE 3: Deploy L2 Slashing Receiver ==="

    # Require RESTAKING address (from Phase 1 or env)
    if [[ -z "${RESTAKING:-}" ]]; then
        log_error "RESTAKING address not set. Run Phase 1 or set RESTAKING env var."
        exit 1
    fi

    # Detect L1 chain ID if not set
    if [[ -z "${L1_CHAIN_ID:-}" ]]; then
        L1_CHAIN_ID=$(cast chain-id --rpc-url "$L1_RPC_URL")
        log_info "Detected L1 chain ID: $L1_CHAIN_ID"
    fi

    export SOURCE_CHAIN_ID="$L1_CHAIN_ID"
    export L2_SLASHING_MANIFEST="$MANIFEST_DIR/slashing-l2.json"

    # Get L1 connector and messenger from Phase 2 manifest
    if [[ -f "$MANIFEST_DIR/beacon-l1.json" ]]; then
        L1_CONNECTOR=$(jq -r '.connector' "$MANIFEST_DIR/beacon-l1.json")
        L1_MESSENGER=$(jq -r '.messenger' "$MANIFEST_DIR/beacon-l1.json")
        export L1_CONNECTOR
        export L1_MESSENGER
        log_info "L1 Connector: $L1_CONNECTOR"
        log_info "L1 Messenger: $L1_MESSENGER"
    elif [[ -z "${L1_CONNECTOR:-}" ]] || [[ -z "${L1_MESSENGER:-}" ]]; then
        log_error "L1_CONNECTOR and L1_MESSENGER required. Run Phase 2 or set env vars."
        exit 1
    fi

    local script_name
    if [[ "$BRIDGE" == "layerzero" ]]; then
        script_name="DeployL2SlashingLayerZero"
    else
        script_name="DeployL2SlashingHyperlane"
    fi

    run_cmd forge script "script/DeployL2Slashing.s.sol:$script_name" \
        --rpc-url "$L2_RPC_URL" \
        --broadcast \
        --slow

    log_success "Phase 3 complete - L2 slashing receiver deployed"
    log_info "Manifest: $MANIFEST_DIR/slashing-l2.json"
    echo ""
}

# ============================================================================
# PHASE 4: Wire L1→L2
# ============================================================================
phase4() {
    log_info "=== PHASE 4: Wire L1 Connector to L2 Receiver ==="

    # Get addresses from manifests
    if [[ -f "$MANIFEST_DIR/beacon-l1.json" ]]; then
        CONNECTOR=$(jq -r '.connector' "$MANIFEST_DIR/beacon-l1.json")
        MESSENGER=$(jq -r '.messenger' "$MANIFEST_DIR/beacon-l1.json")
        export CONNECTOR
        export MESSENGER
    elif [[ -z "${CONNECTOR:-}" ]] || [[ -z "${MESSENGER:-}" ]]; then
        log_error "CONNECTOR and MESSENGER required. Run Phase 2 or set env vars."
        exit 1
    fi

    if [[ -f "$MANIFEST_DIR/slashing-l2.json" ]]; then
        L2_RECEIVER=$(jq -r '.receiver' "$MANIFEST_DIR/slashing-l2.json")
        export L2_RECEIVER
    elif [[ -z "${L2_RECEIVER:-}" ]]; then
        log_error "L2_RECEIVER required. Run Phase 3 or set L2_RECEIVER env var."
        exit 1
    fi

    # Get L2 chain ID
    if [[ -z "${TANGLE_CHAIN_ID:-}" ]]; then
        TANGLE_CHAIN_ID=$(cast chain-id --rpc-url "$L2_RPC_URL")
    fi
    export TANGLE_CHAIN_ID

    log_info "Connector: $CONNECTOR"
    log_info "Messenger: $MESSENGER"
    log_info "L2 Receiver: $L2_RECEIVER"
    log_info "Target Chain: $TANGLE_CHAIN_ID"

    run_cmd forge script script/DeployBeaconSlashing.s.sol:ConfigureL2SlashingConnector \
        --rpc-url "$L1_RPC_URL" \
        --broadcast

    log_success "Phase 4 complete - L1→L2 connection established"
    echo ""
}

# ============================================================================
# Run Phases
# ============================================================================
[[ "$SKIP_PHASE" != "1" ]] && phase1
[[ "$SKIP_PHASE" != "2" ]] && phase2
[[ "$SKIP_PHASE" != "3" ]] && phase3
[[ "$SKIP_PHASE" != "4" ]] && phase4

log_success "=== Deployment Complete ==="
log_info "Manifests saved to: $MANIFEST_DIR"
echo ""
log_info "Next steps:"
echo "  1. Verify contracts on block explorers"
echo "  2. Test cross-chain slashing flow"
echo "  3. Transfer ownership to multisig"
