#!/usr/bin/env bash
set -euo pipefail

# advance-rounds.sh
# Advances the blockchain time and rounds to allow testing of time-locked operations
# like redemption requests in liquid staking vaults.
#
# Usage:
#   ./advance-rounds.sh [rounds]
#
# Arguments:
#   rounds  Number of rounds to advance (default: 28, which is 7 days)
#
# Each round is 6 hours (21600 seconds).
# 28 rounds = 7 days = delegationBondLessDelay

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
ANVIL_PORT="${ANVIL_PORT:-8545}"
RPC_URL="${LOCAL_RPC_URL:-http://127.0.0.1:$ANVIL_PORT}"

# Default Anvil account (account 0) - deployer
ANVIL_KEY="${ANVIL_PRIVATE_KEY:-0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80}"

# Round duration in seconds (6 hours)
ROUND_DURATION=21600

# Default to 28 rounds (7 days / 1 epoch)
ROUNDS="${1:-28}"

log() {
    echo "[advance-rounds] $*"
}

get_restaking_address() {
    # Try to get from latest broadcast file
    local BROADCAST_FILE="$ROOT_DIR/broadcast/LocalTestnet.s.sol/31337/run-latest.json"

    if [[ -f "$BROADCAST_FILE" ]]; then
        # Find the MultiAssetDelegation proxy (ERC1967Proxy created after MultiAssetDelegation impl)
        # The pattern: MultiAssetDelegation impl is created, then ERC1967Proxy with init call
        local RESTAKING_ADDR
        RESTAKING_ADDR=$(jq -r '
            .transactions |
            to_entries |
            map(select(.value.contractName == "ERC1967Proxy")) |
            map(select(.value.transaction.input | contains("cbb6d6bd"))) |
            .[0].value.contractAddress // empty
        ' "$BROADCAST_FILE" 2>/dev/null || echo "")

        if [[ -n "$RESTAKING_ADDR" ]]; then
            echo "$RESTAKING_ADDR"
            return
        fi
    fi

    # Fallback: try manifest file
    local MANIFEST_FILE="$ROOT_DIR/deployments/anvil/manifest.json"
    if [[ -f "$MANIFEST_FILE" ]]; then
        local ADDR
        ADDR=$(jq -r '.restaking // empty' "$MANIFEST_FILE" 2>/dev/null || echo "")
        if [[ -n "$ADDR" ]]; then
            echo "$ADDR"
            return
        fi
    fi

    log "ERROR: Could not find MultiAssetDelegation address."
    log "Make sure you've run start-local-dev.sh first."
    exit 1
}

check_anvil() {
    if ! curl -s "$RPC_URL" -X POST -H "Content-Type: application/json" \
        --data '{"jsonrpc":"2.0","method":"eth_chainId","params":[],"id":1}' >/dev/null 2>&1; then
        log "ERROR: Anvil is not running at $RPC_URL"
        log "Please start the local environment first: ./start-local-dev.sh"
        exit 1
    fi
}

get_current_round() {
    local RESTAKING_ADDR="$1"
    # currentRound() selector: 0x8a19c8bc
    local RESULT
    RESULT=$(cast call "$RESTAKING_ADDR" "currentRound()(uint64)" --rpc-url "$RPC_URL" 2>/dev/null || echo "0")
    echo "$RESULT"
}

advance_single_round() {
    local RESTAKING_ADDR="$1"

    # 1. Increase time by round duration
    cast rpc evm_increaseTime "$ROUND_DURATION" --rpc-url "$RPC_URL" >/dev/null 2>&1

    # 2. Mine a block to apply the time change
    cast rpc evm_mine --rpc-url "$RPC_URL" >/dev/null 2>&1

    # 3. Call advanceRound() on the restaking contract
    cast send "$RESTAKING_ADDR" "advanceRound()" \
        --private-key "$ANVIL_KEY" \
        --rpc-url "$RPC_URL" \
        >/dev/null 2>&1
}

main() {
    log "Checking prerequisites..."
    check_anvil

    command -v cast >/dev/null 2>&1 || { log "ERROR: cast (foundry) not found"; exit 1; }
    command -v jq >/dev/null 2>&1 || { log "ERROR: jq not found"; exit 1; }

    local RESTAKING_ADDR
    RESTAKING_ADDR=$(get_restaking_address)
    log "MultiAssetDelegation address: $RESTAKING_ADDR"

    local INITIAL_ROUND
    INITIAL_ROUND=$(get_current_round "$RESTAKING_ADDR")
    log "Current round: $INITIAL_ROUND"
    log "Advancing $ROUNDS rounds ($(( ROUNDS * 6 )) hours / $(( ROUNDS * 6 / 24 )) days)..."

    for ((i = 1; i <= ROUNDS; i++)); do
        advance_single_round "$RESTAKING_ADDR"
        if (( i % 7 == 0 )) || (( i == ROUNDS )); then
            local CURRENT_ROUND
            CURRENT_ROUND=$(get_current_round "$RESTAKING_ADDR")
            log "  Progress: $i/$ROUNDS rounds (current round: $CURRENT_ROUND)"
        fi
    done

    local FINAL_ROUND
    FINAL_ROUND=$(get_current_round "$RESTAKING_ADDR")

    log ""
    log "Done!"
    log "  Initial round: $INITIAL_ROUND"
    log "  Final round:   $FINAL_ROUND"
    log "  Rounds advanced: $((FINAL_ROUND - INITIAL_ROUND))"
    log "  Time advanced: $(( (FINAL_ROUND - INITIAL_ROUND) * 6 )) hours"
    log ""
    log "Redeem requests created before round $((FINAL_ROUND - 28 + 1)) should now be claimable."
}

main "$@"
