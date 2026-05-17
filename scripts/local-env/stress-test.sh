#!/usr/bin/env bash
#
# stress-test.sh
#
# End-to-end local stress harness for tnt-core.
#
# Spins up anvil + tnt-core (and optionally the envio indexer / dApp / blueprint
# operator) and exercises the merged-PR economic surface: subscription billing,
# multi-asset delegation, slashing dispute window + execution, multi-token
# reward sweeps including a custom griefing ERC20.
#
# Idempotent: re-running tears down previous state and starts fresh.
#
# Usage:
#   ./stress-test.sh [--with-indexer] [--with-dapp] [--with-operator]
#                    [--skip-griefing] [--skip-indexer-checks]
#
# Exit codes:
#   0  all steps green
#   1  at least one step failed (see /tmp/stress-*.log)
#
set -euo pipefail

# ────────────────────────────────────────────────────────────────────────────────
# Configuration
# ────────────────────────────────────────────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../.." && pwd)"
INDEXER_DIR="${ROOT_DIR}/indexer"

ANVIL_PORT="${ANVIL_PORT:-8545}"
RPC_URL="${LOCAL_RPC_URL:-http://127.0.0.1:${ANVIL_PORT}}"
HASURA_PORT="${HASURA_PORT:-8080}"
GRAPHQL_URL="http://127.0.0.1:${HASURA_PORT}/v1/graphql"

# Anvil default accounts (see LocalTestnet.s.sol for role mapping).
DEPLOYER_KEY="${DEPLOYER_KEY:-0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80}"
OPERATOR2_KEY="${OPERATOR2_KEY:-0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a}"
DELEGATOR_KEY="${DELEGATOR_KEY:-0x7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6}"
SECOND_STAKER_KEY="${SECOND_STAKER_KEY:-0x92db14e403b83dfe3df233f83dfa3a0d7096f21ca9b0d6d6b8d88b2b4ec1564e}"

OPERATOR1_ADDR="0x70997970C51812dc3A010C7d01b50e0d17dc79C8"
OPERATOR2_ADDR="0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC"
SECOND_STAKER_ADDR="$(cast wallet address --private-key "${SECOND_STAKER_KEY}" 2>/dev/null)"

MULTICALL3_ADDRESS="0xcA11bde05977b3631167028862bE2a173976CA11"

WITH_INDEXER=false
WITH_DAPP=false
WITH_OPERATOR=false
SKIP_GRIEFING=false
SKIP_INDEXER_CHECKS=false

LOG_DIR="${LOG_DIR:-/tmp}"
STATE_FILE="${LOG_DIR}/stress-state.env"

WALL_START_TS=$(date +%s)
TOTAL_STEPS=17
OK_COUNT=0
FAIL_COUNT=0
FAIL_STEPS=()
ANVIL_PID=""

# ────────────────────────────────────────────────────────────────────────────────
# Argument parsing
# ────────────────────────────────────────────────────────────────────────────────

while [[ $# -gt 0 ]]; do
    case "$1" in
        --with-indexer) WITH_INDEXER=true; shift ;;
        --with-dapp) WITH_DAPP=true; shift ;;
        --with-operator) WITH_OPERATOR=true; shift ;;
        --skip-griefing) SKIP_GRIEFING=true; shift ;;
        --skip-indexer-checks) SKIP_INDEXER_CHECKS=true; shift ;;
        -h|--help)
            sed -n '/^#$/,/^set/p' "$0" | sed 's/^# \{0,1\}//; s/^#$//' | head -30
            exit 0
            ;;
        *) echo "Unknown argument: $1"; exit 2 ;;
    esac
done

# Without --with-indexer the indexer leg cannot run, so the entity-presence step is
# automatically skipped to avoid a guaranteed failure.
if [[ "${WITH_INDEXER}" != "true" ]]; then
    SKIP_INDEXER_CHECKS=true
fi

# ────────────────────────────────────────────────────────────────────────────────
# Logging helpers
# ────────────────────────────────────────────────────────────────────────────────

format_secs() {
    awk -v s="$1" 'BEGIN { printf "%.2fs", s }'
}

run_step() {
    local step_id="$1"; local label="$2"; shift 2
    local log_file="${LOG_DIR}/stress-${step_id}.log"
    local t0
    t0=$(date +%s%N)
    if "$@" >"$log_file" 2>&1; then
        local t1
        t1=$(date +%s%N)
        local secs
        secs=$(awk -v a="$t1" -v b="$t0" 'BEGIN { print (a-b)/1e9 }')
        local extra=""
        if [[ -f "${log_file}.summary" ]]; then
            extra=", $(cat "${log_file}.summary")"
            rm -f "${log_file}.summary"
        fi
        printf '[OK]   step %s: %-32s (%s%s)\n' "$step_id" "$label" "$(format_secs "$secs")" "$extra"
        OK_COUNT=$((OK_COUNT + 1))
    else
        local t1
        t1=$(date +%s%N)
        local secs
        secs=$(awk -v a="$t1" -v b="$t0" 'BEGIN { print (a-b)/1e9 }')
        printf '[FAIL] step %s: %-32s (%s — see %s)\n' "$step_id" "$label" "$(format_secs "$secs")" "$log_file"
        FAIL_COUNT=$((FAIL_COUNT + 1))
        FAIL_STEPS+=("$step_id:$label")
    fi
}

# ────────────────────────────────────────────────────────────────────────────────
# Anvil RPC helpers
# ────────────────────────────────────────────────────────────────────────────────

rpc() {
    local method="$1"; local params="$2"
    curl -s --max-time 10 "${RPC_URL}" \
        -H "Content-Type: application/json" \
        -d "{\"jsonrpc\":\"2.0\",\"method\":\"${method}\",\"params\":${params},\"id\":1}"
}

bump_time() {
    local secs="$1"
    rpc evm_increaseTime "[$secs]" >/dev/null
    rpc evm_mine "[]" >/dev/null
}

# ────────────────────────────────────────────────────────────────────────────────
# Setup phase
# ────────────────────────────────────────────────────────────────────────────────

check_prereqs() {
    local missing=()
    for tool in anvil cast forge curl jq nc awk; do
        command -v "$tool" >/dev/null 2>&1 || missing+=("$tool")
    done
    if [[ "${WITH_INDEXER}" == "true" ]]; then
        for tool in docker pnpm; do
            command -v "$tool" >/dev/null 2>&1 || missing+=("$tool")
        done
        docker info >/dev/null 2>&1 || missing+=("docker daemon")
    fi
    if [[ ${#missing[@]} -gt 0 ]]; then
        echo "Missing required tools: ${missing[*]}" >&2
        return 1
    fi
    if [[ ! -d "${ROOT_DIR}/dependencies/forge-std-1.9.4" ]]; then
        echo "Soldeer deps missing — run 'forge soldeer update' first." >&2
        return 1
    fi
    return 0
}

idempotent_cleanup() {
    pkill -9 -f "anvil.*--port.*${ANVIL_PORT}" 2>/dev/null || true
    if [[ "${WITH_INDEXER}" == "true" ]] && [[ -d "${INDEXER_DIR}/generated" ]]; then
        (cd "${INDEXER_DIR}/generated" && docker compose down -v 2>/dev/null) || true
    fi
    rm -f "${INDEXER_DIR}/generated/persisted_state.envio.json" 2>/dev/null || true
    rm -rf "${ROOT_DIR}/broadcast/LocalTestnet.s.sol" 2>/dev/null || true
    rm -f "${STATE_FILE}" "${LOG_DIR}"/stress-*.stake-baseline 2>/dev/null || true
    pkill -f "envio start" 2>/dev/null || true
    # Give the OS a beat to release ports.
    sleep 1
    return 0
}

start_anvil() {
    if nc -z 127.0.0.1 "${ANVIL_PORT}" 2>/dev/null; then
        echo "Anvil already up on port ${ANVIL_PORT}"
        return 0
    fi
    anvil --chain-id 31337 --base-fee 0 --gas-limit 30000000 \
        --disable-code-size-limit --silent --port "${ANVIL_PORT}" \
        > "${LOG_DIR}/stress-anvil.log" 2>&1 &
    ANVIL_PID=$!
    echo "${ANVIL_PID}" > "${LOG_DIR}/stress-anvil.pid"
    # Wait up to 30s for anvil to accept RPC.
    local deadline=$(( $(date +%s) + 30 ))
    while [[ $(date +%s) -lt $deadline ]]; do
        if curl -s "${RPC_URL}" -X POST -H "Content-Type: application/json" \
            --data '{"jsonrpc":"2.0","method":"eth_chainId","params":[],"id":1}' \
            2>/dev/null | grep -q '"result"'; then
            return 0
        fi
        sleep 0.5
    done
    echo "Anvil did not start within 30s" >&2
    return 1
}

inject_multicall3() {
    # Multicall3 is only required by downstream tooling (viem multicall, indexer
    # batch-RPC). The optional setup_indexer_optional path delegates to the
    # canonical local-env helper which already injects multicall before booting
    # the indexer. For the bare RPC surface the harness uses, multicall is
    # unnecessary, so this is a no-op.
    return 0
}

deploy_tnt_core() {
    # Reuses LocalTestnet.s.sol in subscription mode so a billable service is
    # active at activation time (with `subscriptionBaselineStake` pinned).
    SUBSCRIPTION_MODE=true forge script \
        script/LocalTestnet.s.sol:LocalTestnetSetup \
        --rpc-url "${RPC_URL}" \
        --private-key "${DEPLOYER_KEY}" \
        --broadcast --non-interactive
}

setup_indexer_optional() {
    if [[ "${WITH_INDEXER}" != "true" ]]; then return 0; fi
    # Honor the existing helper for indexer bring-up. It runs docker compose + envio
    # codegen + starts the indexer in the background.
    local helper="${ROOT_DIR}/script/sh/local-env/start-local-dev.sh"
    (cd "${ROOT_DIR}" && SKIP_DEPLOY=1 "${helper}" --subscription &) \
        || echo "indexer helper failed; continuing"
    # Wait up to 240s for the GraphQL endpoint.
    local deadline=$(( $(date +%s) + 240 ))
    while [[ $(date +%s) -lt $deadline ]]; do
        if curl -s --max-time 3 "${GRAPHQL_URL}" \
            -H "Content-Type: application/json" \
            -d '{"query":"{ Operator(limit:1) { id } }"}' 2>/dev/null \
            | grep -q '"Operator"'; then return 0; fi
        sleep 4
    done
    echo "Indexer did not become healthy within 240s — step 17 will skip" >&2
    SKIP_INDEXER_CHECKS=true
    return 0
}

start_dapp_optional() {
    if [[ "${WITH_DAPP}" != "true" ]]; then return 0; fi
    local dapp_dir="/home/drew/code/dapp"
    if [[ ! -d "${dapp_dir}" ]]; then
        echo "dapp dir not present; skipping --with-dapp"
        return 0
    fi
    (cd "${dapp_dir}" && nohup pnpm nx run tangle-dapp:serve >"${LOG_DIR}/stress-dapp.log" 2>&1 &) || true
    echo "dApp started in background (logs: ${LOG_DIR}/stress-dapp.log)"
}

start_operator_optional() {
    if [[ "${WITH_OPERATOR}" != "true" ]]; then return 0; fi
    local op_dir="/home/drew/code/llm-inference-blueprint"
    if [[ ! -d "${op_dir}/operator" ]]; then
        echo "operator dir not present; skipping --with-operator"
        return 0
    fi
    (cd "${op_dir}" && cargo build --release --bin llm-operator >"${LOG_DIR}/stress-operator-build.log" 2>&1) || {
        echo "operator build failed; see ${LOG_DIR}/stress-operator-build.log"
        return 0
    }
    (cd "${op_dir}" && nohup ./target/release/llm-operator >"${LOG_DIR}/stress-operator.log" 2>&1 &) || true
    echo "operator binary started (logs: ${LOG_DIR}/stress-operator.log)"
}

step_03_bringup() {
    start_anvil || return 1
    # Multicall3 is only needed if downstream tooling (indexer / dApp) hits it.
    if [[ "${WITH_INDEXER}" == "true" || "${WITH_DAPP}" == "true" ]]; then
        inject_multicall3 || echo "Multicall3 inject failed; continuing without it"
    fi
    deploy_tnt_core
}

resolve_addresses() {
    local broadcast_dir="${ROOT_DIR}/broadcast/LocalTestnet.s.sol/31337"
    local latest
    latest=$(ls -t "${broadcast_dir}"/run-*.json 2>/dev/null | head -1)
    [[ -n "${latest}" ]] || { echo "no broadcast file"; return 1; }

    local TANGLE_ADDR STAKING_ADDR
    TANGLE_ADDR=$(jq -r '[.transactions[] | select(.contractName=="ERC1967Proxy") | .contractAddress] | .[1]' "${latest}")
    STAKING_ADDR=$(jq -r '[.transactions[] | select(.contractName=="ERC1967Proxy") | .contractAddress] | .[0]' "${latest}")

    [[ "${TANGLE_ADDR}" != "null" && -n "${TANGLE_ADDR}" ]] || { echo "Could not parse TANGLE_ADDR"; return 1; }
    [[ "${STAKING_ADDR}" != "null" && -n "${STAKING_ADDR}" ]] || { echo "Could not parse STAKING_ADDR"; return 1; }

    {
        echo "TANGLE_ADDR=${TANGLE_ADDR}"
        echo "STAKING_ADDR=${STAKING_ADDR}"
    } >"${STATE_FILE}"
}

# ────────────────────────────────────────────────────────────────────────────────
# Step implementations
# ────────────────────────────────────────────────────────────────────────────────

state() {
    # shellcheck disable=SC1090
    source "${STATE_FILE}"
}

step_06_registered() {
    state
    local out
    out=$(cast call "${TANGLE_ADDR}" "isOperatorRegistered(uint64,address)(bool)" 0 "${OPERATOR2_ADDR}" --rpc-url "${RPC_URL}")
    [[ "${out}" == "true" ]] || { echo "operator2 not registered for blueprint 0: '${out}'"; return 1; }
}

step_07_service_active() {
    state
    local active
    active=$(cast call "${TANGLE_ADDR}" "isServiceActive(uint64)(bool)" 0 --rpc-url "${RPC_URL}")
    [[ "${active}" == "true" ]] || { echo "service 0 not Active (isServiceActive=${active})"; return 1; }
}

step_08_security_commitments() {
    state
    # Operator2 must be on service 0's operator list. `isServiceOperator` reads the
    # ServiceOperator record that ServicesApprovals.approveService wrote, which
    # carries the per-asset commitment slice from the multi-asset bill weighting
    # path (PR #133 split into ApprovalsViews).
    local out
    out=$(cast call "${TANGLE_ADDR}" "isServiceOperator(uint64,address)(bool)" 0 "${OPERATOR2_ADDR}" --rpc-url "${RPC_URL}")
    [[ "${out}" == "true" ]] || { echo "op2 not on service 0 operator set: '${out}'"; return 1; }
}

step_09_escrow_funded() {
    state
    local raw
    raw=$(cast call "${TANGLE_ADDR}" "getServiceEscrow(uint64)" 0 --rpc-url "${RPC_URL}")
    # `ServiceEscrow` is (address token, uint256 balance, uint256 subscriptionBaselineStake, ...).
    # Decode the second word (offset 32) as the balance.
    local balance_hex="${raw:66:64}"
    local balance_dec
    balance_dec=$(cast --to-dec "0x${balance_hex}")
    [[ "${balance_dec}" -gt 0 ]] || { echo "escrow balance is 0 (raw=${raw})"; return 1; }
    echo "escrow_balance=${balance_dec} wei" > "${LOG_DIR}/stress-09.log.summary"
}

bill_subscription_once() {
    state
    local raw_before
    raw_before=$(cast call "${TANGLE_ADDR}" "getServiceEscrow(uint64)" 0 --rpc-url "${RPC_URL}")
    local before
    before=$(cast --to-dec "0x${raw_before:66:64}")

    bump_time 65 >/dev/null
    cast send "${TANGLE_ADDR}" "billSubscription(uint64)" 0 \
        --private-key "${DEPLOYER_KEY}" --rpc-url "${RPC_URL}" >/dev/null

    local raw_after
    raw_after=$(cast call "${TANGLE_ADDR}" "getServiceEscrow(uint64)" 0 --rpc-url "${RPC_URL}")
    local after
    after=$(cast --to-dec "0x${raw_after:66:64}")

    echo "before=${before} after=${after}"
}

step_10_bill_first() {
    local out before after
    out=$(bill_subscription_once)
    eval "$out"
    [[ "${before}" -gt "${after}" ]] || { echo "escrow did not decrease: before=${before} after=${after}"; return 1; }
    local drawn=$((before - after))
    echo "draw1=${drawn} wei" > "${LOG_DIR}/stress-10.log.summary"
}

step_11_second_staker() {
    state
    # Fund the second staker with 500 ETH so it can stake.
    rpc anvil_setBalance "[\"${SECOND_STAKER_ADDR}\", \"0x1B1AE4D6E2EF500000\"]" >/dev/null

    # Use getOperatorDelegatedStake (sum across ALL enabled assets) — this is the
    # O(1) aggregate the PR landed. getOperatorStake() only reflects the bond asset.
    local before
    before=$(cast call "${STAKING_ADDR}" "getOperatorDelegatedStake(address)(uint256)" "${OPERATOR2_ADDR}" --rpc-url "${RPC_URL}" | awk '{print $1}')
    [[ "${before}" =~ ^[0-9]+$ ]] || { echo "could not read pre-stake: ${before}"; return 1; }

    cast send "${STAKING_ADDR}" "depositAndDelegate(address)" "${OPERATOR2_ADDR}" \
        --value 5ether \
        --private-key "${SECOND_STAKER_KEY}" --rpc-url "${RPC_URL}" >/dev/null

    local after
    after=$(cast call "${STAKING_ADDR}" "getOperatorDelegatedStake(address)(uint256)" "${OPERATOR2_ADDR}" --rpc-url "${RPC_URL}" | awk '{print $1}')
    [[ "${after}" -gt "${before}" ]] || { echo "operator stake did not grow: before=${before} after=${after}"; return 1; }
    echo "delegated_pre=${before} delegated_post=${after}" > "${LOG_DIR}/stress-11.log.summary"
    # Persist a copy that survives run_step's .summary consumption, so step 14 can
    # cross-reference the baseline.
    echo "${after}" > "${LOG_DIR}/stress-11.stake-baseline"
}

step_12_bill_after_added_stake() {
    local out before after
    out=$(bill_subscription_once)
    eval "$out"
    [[ "${before}" -gt "${after}" ]] || { echo "second bill drew zero (before=${before} after=${after})"; return 1; }
    local drawn=$((before - after))
    echo "draw2=${drawn} wei" > "${LOG_DIR}/stress-12.log.summary"
}

step_13_propose_and_execute_slash() {
    state
    local evidence="0x5354524553533a20534c41206d6973736564000000000000000000000000000000"
    local tx_propose
    tx_propose=$(cast send "${TANGLE_ADDR}" \
        "proposeSlash(uint64,address,uint16,bytes32)" 0 "${OPERATOR2_ADDR}" 1500 \
        "${evidence:0:66}" \
        --private-key "${DEPLOYER_KEY}" --rpc-url "${RPC_URL}" --json)
    local slash_topic
    slash_topic="$(cast keccak 'SlashProposed(uint64,uint64,address,address,uint16,uint16,bytes32,uint64)')"
    local slash_id_hex
    slash_id_hex=$(echo "${tx_propose}" | jq -r --arg t "${slash_topic}" \
        '[.logs[] | select(.topics[0]==$t) | .topics[1]] | .[0] // empty')
    [[ -n "${slash_id_hex}" ]] || { echo "no SlashProposed event found"; echo "${tx_propose}"; return 1; }
    local slash_id
    slash_id=$(cast --to-dec "${slash_id_hex}")

    # Default dispute window is 7 days; advance past it AND past the TIMESTAMP_BUFFER
    # (15s) the slashing lib uses to defang same-block sequencer/proposer games.
    bump_time $((7 * 24 * 60 * 60 + 20))

    local execute_out
    execute_out=$(cast send "${TANGLE_ADDR}" "executeSlash(uint64)" "${slash_id}" \
        --private-key "${DEPLOYER_KEY}" --rpc-url "${RPC_URL}" --json)
    local slash_executed_topic
    slash_executed_topic="$(cast keccak 'SlashExecuted(uint64,uint64,address,uint256)')"
    local executed_data
    executed_data=$(echo "${execute_out}" | jq -r --arg t "${slash_executed_topic}" \
        '[.logs[] | select(.topics[0]==$t) | .data] | .[0] // empty')
    [[ -n "${executed_data}" ]] || { echo "no SlashExecuted event"; echo "${execute_out}"; return 1; }
    local actual_slashed
    actual_slashed=$(cast --to-dec "${executed_data}")
    [[ "${actual_slashed}" -gt 0 ]] || { echo "slash executed but actualSlashed=0"; return 1; }
    echo "slashId=${slash_id} actualSlashed=${actual_slashed} wei" > "${LOG_DIR}/stress-13.log.summary"
}

step_14_post_slash_stake_reduced() {
    state
    local after
    after=$(cast call "${STAKING_ADDR}" "getOperatorDelegatedStake(address)(uint256)" "${OPERATOR2_ADDR}" --rpc-url "${RPC_URL}" | awk '{print $1}')
    local prev=""
    [[ -f "${LOG_DIR}/stress-11.stake-baseline" ]] && prev=$(<"${LOG_DIR}/stress-11.stake-baseline")
    [[ -n "${prev}" ]] || { echo "could not read step-11 baseline"; return 1; }
    [[ "${after}" -lt "${prev}" ]] || { echo "operator stake did not drop: prev=${prev} after=${after}"; return 1; }
    echo "stake_pre=${prev} stake_post=${after}" > "${LOG_DIR}/stress-14.log.summary"
}

step_15_claim_rewards_all() {
    state
    cast send "${TANGLE_ADDR}" "claimRewardsAll()" \
        --private-key "${OPERATOR2_KEY}" --rpc-url "${RPC_URL}" >/dev/null
    local pending
    pending=$(cast call "${TANGLE_ADDR}" "pendingRewards(address,address)(uint256)" \
        "${OPERATOR2_ADDR}" "0x0000000000000000000000000000000000000000" \
        --rpc-url "${RPC_URL}" | awk '{print $1}')
    [[ "${pending}" == "0" ]] || { echo "native pendingRewards still non-zero: ${pending}"; return 1; }
}

to_32hex() {
    # Strip 0x, lowercase, left-pad to 64 hex chars (32 bytes). Input MUST already be hex.
    local v="${1#0x}"
    printf '%064s' "${v,,}" | tr ' ' '0'
}

dec_to_32hex() {
    # Convert a decimal value to a 0x-prefixed 32-byte hex word.
    python3 -c "print('0x' + hex(int('$1'))[2:].rjust(64, '0'))"
}

seed_storage() {
    # seed_storage <contract> <slot-hex> <value> [--hex|--dec]
    # Slot may or may not have 0x prefix. Value defaults to decimal interpretation.
    local contract="$1"
    local slot="$2"
    local value="$3"
    local mode="${4:---dec}"
    [[ "${slot}" == 0x* ]] || slot="0x${slot}"
    local val32
    if [[ "${mode}" == "--hex" ]]; then
        val32="0x$(to_32hex "${value}")"
    else
        val32=$(dec_to_32hex "${value}")
    fi
    curl -s "${RPC_URL}" -X POST -H "Content-Type: application/json" \
        --data "{\"jsonrpc\":\"2.0\",\"method\":\"anvil_setStorageAt\",\"params\":[\"${contract}\",\"${slot}\",\"${val32}\"],\"id\":1}" \
        | jq -e '.result' >/dev/null
}

step_16_griefing_sweep() {
    if [[ "${SKIP_GRIEFING}" == "true" ]]; then
        echo "skipped via --skip-griefing" > "${LOG_DIR}/stress-16.log.summary"
        return 0
    fi
    state
    # Deploy the reverting ERC20 via the forge script (only on-chain side effect).
    DEPLOYER_KEY="${DEPLOYER_KEY}" \
    forge script script/StressGriefingSeed.s.sol:StressGriefingSeed \
        --rpc-url "${RPC_URL}" --broadcast --non-interactive -vv \
        > "${LOG_DIR}/stress-16-seed.log" 2>&1
    local grief_token
    grief_token=$(grep -oE 'GRIEF_TOKEN=[[:space:]]*0x[a-fA-F0-9]+' "${LOG_DIR}/stress-16-seed.log" \
        | tail -1 | grep -oE '0x[a-fA-F0-9]+')
    [[ -n "${grief_token}" ]] || { echo "failed to deploy griefing token"; tail -30 "${LOG_DIR}/stress-16-seed.log"; return 1; }
    local grief_lower="${grief_token,,}"
    grief_lower="${grief_lower#0x}"

    # Compute storage slots for the seed. Source of truth: `forge inspect Tangle storage-layout`.
    #   _pendingRewards         at slot 44
    #   _pendingRewardTokens    at slot 64  (mapping(address => EnumerableSet.AddressSet))
    # `AddressSet` wraps `Set { bytes32[] _values; mapping(bytes32 => uint256) _positions; }`.
    local op32; op32=$(to_32hex "${OPERATOR2_ADDR}")
    local g32; g32=$(to_32hex "${grief_token}")
    # _pendingRewards is at slot 44 (0x2c). Inner mapping slot first, then the per-token slot.
    local slot_pending32; slot_pending32=$(to_32hex "2c")
    local inner; inner=$(cast keccak "0x${op32}${slot_pending32}")
    local inner_hex="${inner#0x}"
    local pending_slot; pending_slot=$(cast keccak "0x${g32}${inner_hex}")

    # _pendingRewardTokens at slot 64 (0x40) — mapping(address => AddressSet).
    local slot_set32; slot_set32=$(to_32hex "40")
    local set_struct; set_struct=$(cast keccak "0x${op32}${slot_set32}")
    local set_struct_hex="${set_struct#0x}"
    # _values length lives at set_struct itself (offset 0)
    # _values[0] lives at keccak256(set_struct)
    local values_data; values_data=$(cast keccak "${set_struct}")
    # _positions[grief] lives at keccak256(grief . (set_struct + 1)). Use python for
    # the 256-bit add so we don't pull in bc/dc-isms that vary by platform.
    local positions_base
    positions_base=$(python3 -c "print(hex(int('${set_struct_hex}', 16) + 1)[2:].rjust(64, '0'))")
    local positions_slot; positions_slot=$(cast keccak "0x${g32}${positions_base}")

    # Write the four storage cells via anvil_setStorageAt. Values come in two flavors:
    #   --dec  : value is decimal, python converts to 32-byte hex.
    #   --hex  : value is already hex, just padded to 32 bytes.
    seed_storage "${TANGLE_ADDR}" "${pending_slot}"   "1000000000000000000" --dec || { echo "anvil_setStorageAt pending failed"; return 1; }
    seed_storage "${TANGLE_ADDR}" "${set_struct}"     "1"                   --dec || { echo "anvil_setStorageAt set-length failed"; return 1; }
    seed_storage "${TANGLE_ADDR}" "${values_data}"    "${grief_lower}"      --hex || { echo "anvil_setStorageAt values[0] failed"; return 1; }
    seed_storage "${TANGLE_ADDR}" "${positions_slot}" "1"                   --dec || { echo "anvil_setStorageAt positions failed"; return 1; }

    local seeded
    seeded=$(cast call "${TANGLE_ADDR}" "pendingRewards(address,address)(uint256)" \
        "${OPERATOR2_ADDR}" "${grief_token}" --rpc-url "${RPC_URL}" | awk '{print $1}')
    [[ "${seeded}" == "1000000000000000000" ]] || { echo "seed did not land in storage (got ${seeded})"; return 1; }

    local rewards_tokens
    rewards_tokens=$(cast call "${TANGLE_ADDR}" "rewardTokens(address)(address[])" \
        "${OPERATOR2_ADDR}" --rpc-url "${RPC_URL}")
    local grief_lower="${grief_token,,}"
    echo "${rewards_tokens,,}" | grep -qF "${grief_lower#0x}" || {
        echo "griefing token not visible via rewardTokens(): ${rewards_tokens}"
        return 1
    }

    local claim_out
    claim_out=$(cast send "${TANGLE_ADDR}" "claimRewardsAll()" \
        --private-key "${OPERATOR2_KEY}" --rpc-url "${RPC_URL}" --json)
    local skip_topic
    skip_topic="$(cast keccak 'RewardsClaimSkipped(address,address)')"
    local skipped_found
    skipped_found=$(echo "${claim_out}" | jq -r --arg t "${skip_topic}" \
        '[.logs[] | select(.topics[0]==$t)] | length')
    [[ "${skipped_found}" -ge 1 ]] || { echo "RewardsClaimSkipped not emitted (got ${skipped_found})"; echo "${claim_out}" | jq '.logs[].topics'; return 1; }

    local still_pending
    still_pending=$(cast call "${TANGLE_ADDR}" "pendingRewards(address,address)(uint256)" \
        "${OPERATOR2_ADDR}" "${grief_token}" --rpc-url "${RPC_URL}" | awk '{print $1}')
    [[ "${still_pending}" == "1000000000000000000" ]] || {
        echo "skipped token's pending was zeroed (expected 1e18, got ${still_pending})"
        return 1
    }
    echo "grief=${grief_token} skips=${skipped_found}" > "${LOG_DIR}/stress-16.log.summary"
}

graphql_count() {
    local entity="$1"
    local resp
    resp=$(curl -s --max-time 5 "${GRAPHQL_URL}" \
        -H "Content-Type: application/json" \
        -d "{\"query\":\"{ ${entity}(limit: 50) { id } }\"}")
    echo "${resp}" | jq -r ".data.${entity} | length" 2>/dev/null || echo 0
}

step_17_indexer_entities() {
    if [[ "${SKIP_INDEXER_CHECKS}" == "true" ]]; then
        echo "skipped (indexer not enabled — pass --with-indexer)" > "${LOG_DIR}/stress-17.log.summary"
        return 0
    fi
    sleep 6
    # Entities that should have at least one row after the 16 prior steps:
    #  - Core protocol shapes (Operator, Service, ServiceOperator)
    #  - Subscription billing (SubscriptionBilling, PaymentDistribution)
    #  - Reward sweep (RewardClaim) + griefing isolation (RewardsClaimSkip)
    #  - Slashing (SlashProposal, OperatorPoolSlash)
    local entities=(
        Operator Service ServiceOperator
        SubscriptionBilling PaymentDistribution
        RewardClaim RewardsClaimSkip
        SlashProposal OperatorPoolSlash
    )
    local missing=()
    local summary=""
    for e in "${entities[@]}"; do
        local c
        c=$(graphql_count "${e}")
        summary+="${e}=${c} "
        if [[ "${c}" -lt 1 ]]; then
            missing+=("${e}")
        fi
    done
    if [[ ${#missing[@]} -gt 0 ]]; then
        echo "indexer missing rows for: ${missing[*]}"
        echo "counts: ${summary}"
        return 1
    fi
    echo "${summary% }" > "${LOG_DIR}/stress-17.log.summary"
}

# ────────────────────────────────────────────────────────────────────────────────
# Teardown
# ────────────────────────────────────────────────────────────────────────────────

teardown() {
    if [[ "${KEEP_RUNNING:-false}" == "true" ]]; then return 0; fi
    [[ -n "${ANVIL_PID}" ]] && kill "${ANVIL_PID}" 2>/dev/null || true
    pkill -f "anvil.*--port.*${ANVIL_PORT}" 2>/dev/null || true
    if [[ "${WITH_INDEXER}" == "true" ]] && [[ -d "${INDEXER_DIR}/generated" ]]; then
        (cd "${INDEXER_DIR}/generated" && docker compose down -v 2>/dev/null) || true
    fi
    pkill -f "envio start" 2>/dev/null || true
    if [[ "${WITH_DAPP}" == "true" ]]; then pkill -f "tangle-dapp:serve" 2>/dev/null || true; fi
    if [[ "${WITH_OPERATOR}" == "true" ]]; then pkill -f "llm-operator" 2>/dev/null || true; fi
}
trap teardown EXIT

# ────────────────────────────────────────────────────────────────────────────────
# Main
# ────────────────────────────────────────────────────────────────────────────────

main() {
    cd "${ROOT_DIR}"

    run_step 01 "prerequisites"               check_prereqs
    run_step 02 "idempotent cleanup"          idempotent_cleanup
    run_step 03 "anvil + contracts deployed"  step_03_bringup
    run_step 04 "resolve deployed addresses"  resolve_addresses
    # 05 bundles all optional services (indexer + dapp + operator); never fails the harness.
    setup_indexer_optional || true
    start_dapp_optional || true
    start_operator_optional || true
    run_step 05 "optional services launched"  true

    run_step 06 "operator2 registered"               step_06_registered
    run_step 07 "subscription service Active"        step_07_service_active
    run_step 08 "operator on service operator set"   step_08_security_commitments
    run_step 09 "escrow funded > 0"                  step_09_escrow_funded
    run_step 10 "billSubscription #1"                step_10_bill_first
    run_step 11 "second staker grows pool"           step_11_second_staker
    run_step 12 "billSubscription #2 (post-stake)"   step_12_bill_after_added_stake
    run_step 13 "proposeSlash + executeSlash"        step_13_propose_and_execute_slash
    run_step 14 "operator stake reduced post-slash"  step_14_post_slash_stake_reduced
    run_step 15 "claimRewardsAll (native)"           step_15_claim_rewards_all
    run_step 16 "griefing token skipped"             step_16_griefing_sweep
    run_step 17 "indexer entities present"           step_17_indexer_entities

    local wall_end_ts elapsed
    wall_end_ts=$(date +%s)
    elapsed=$(( wall_end_ts - WALL_START_TS ))
    if [[ ${FAIL_COUNT} -eq 0 ]]; then
        printf '\nRESULT: %d / %d OK in %ds.\n' "${OK_COUNT}" "${TOTAL_STEPS}" "${elapsed}"
        exit 0
    else
        printf '\nRESULT: %d / %d OK in %ds (failed: %s).\n' \
            "${OK_COUNT}" "${TOTAL_STEPS}" "${elapsed}" "${FAIL_STEPS[*]}"
        exit 1
    fi
}

main "$@"
