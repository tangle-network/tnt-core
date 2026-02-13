#!/usr/bin/env bash
set -euo pipefail

# submit-job-result.sh
# Submits a job result as an operator on the local Anvil testnet.
# This simulates what the operator node does automatically in production.
#
# Usage:
#   ./submit-job-result.sh result -s <id> -c <id> [-o <1|2|3>] [options]
#   ./submit-job-result.sh job    -s <id> [options]
#
# Subcommands:
#   result    Submit a job result as an operator (default if omitted)
#   job       Submit a new job as the deployer (to get a callId for testing)
#
# Options:
#   -s, --service-id <id>        Service ID (required)
#   -c, --call-id <id>           Job call ID (required for 'result' subcommand)
#   -o, --operator <1|2|3>       Operator number (default: 1)
#       --output <text>          Result output data (default: "test result")
#       --tangle <address>       Override Tangle contract address (auto-detected from broadcast)
#       --rpc-url <url>          RPC URL (default: http://127.0.0.1:8545)
#   -h, --help                   Show this help message
#
# Operator Accounts (Anvil defaults):
#   1 = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8  (Account 1)
#   2 = 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC  (Account 2)
#   3 = 0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65  (Account 4)
#
# Note: Only operators 1 and 2 are registered for the blueprint in the default
# LocalTestnet setup. Operator 3 is registered in restaking but NOT for the blueprint.
#
# Examples:
#   # Submit a job first (to get a callId):
#   ./submit-job-result.sh job -s 0
#
#   # Submit result as operator 1:
#   ./submit-job-result.sh result -s 0 -c 0 -o 1
#
#   # Submit result with custom output text:
#   ./submit-job-result.sh result -s 0 -c 0 --output "hello world"
#
#   # Use custom contract address:
#   ./submit-job-result.sh result -s 0 -c 0 --tangle 0xABC...

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
ANVIL_PORT="${ANVIL_PORT:-8545}"
RPC_URL="${LOCAL_RPC_URL:-http://127.0.0.1:$ANVIL_PORT}"

# Anvil default private keys
DEPLOYER_KEY="0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"
OPERATOR1_KEY="0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d"
OPERATOR2_KEY="0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a"
OPERATOR3_KEY="0x47e179ec197488593b187f80a00eb0da91f1b9d0b13f8733639f19c30a34926a"

# Deterministic Tangle contract address (Anvil default deployer, fresh chain)
DEFAULT_TANGLE_ADDR="0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9"

log() {
    echo "[submit-job-result] $*"
}

log_error() {
    echo "[submit-job-result] ERROR: $*" >&2
}

show_help() {
    # Print the header comment block from this script
    sed -n '3,/^$/p' "${BASH_SOURCE[0]}" | sed 's/^# \?//'
    exit 0
}

check_prerequisites() {
    if ! command -v cast >/dev/null 2>&1; then
        log_error "cast (foundry) not found. Install foundry: https://getfoundry.sh"
        exit 1
    fi

    if ! command -v jq >/dev/null 2>&1; then
        log_error "jq not found. Install jq: https://jqlang.github.io/jq/"
        exit 1
    fi
}

check_anvil() {
    if ! curl -s --max-time 3 "$RPC_URL" -X POST -H "Content-Type: application/json" \
        --data '{"jsonrpc":"2.0","method":"eth_chainId","params":[],"id":1}' >/dev/null 2>&1; then
        log_error "Anvil is not running at $RPC_URL"
        log_error "Start the local environment first: ./start-local-dev.sh"
        exit 1
    fi
}

get_tangle_address() {
    # If user provided an address, use it
    if [[ -n "${TANGLE_ADDR_OVERRIDE:-}" ]]; then
        echo "$TANGLE_ADDR_OVERRIDE"
        return
    fi

    # Try to read from broadcast file
    local BROADCAST_FILE="$ROOT_DIR/broadcast/LocalTestnet.s.sol/31337/run-latest.json"

    if [[ -f "$BROADCAST_FILE" ]]; then
        local PROXIES
        PROXIES=$(jq -r '[.transactions[] | select(.contractName == "ERC1967Proxy") | .contractAddress] | .[]' "$BROADCAST_FILE" 2>/dev/null || echo "")

        local TANGLE_ADDR
        TANGLE_ADDR=$(echo "$PROXIES" | sed -n '2p')

        if [[ -n "$TANGLE_ADDR" ]]; then
            echo "$TANGLE_ADDR"
            return
        fi
    fi

    # Fallback to deterministic default
    log "Broadcast file not found, using default address: $DEFAULT_TANGLE_ADDR" >&2
    echo "$DEFAULT_TANGLE_ADDR"
}

get_operator_key() {
    local operator_num="$1"
    case "$operator_num" in
        1) echo "$OPERATOR1_KEY" ;;
        2) echo "$OPERATOR2_KEY" ;;
        3) echo "$OPERATOR3_KEY" ;;
        *)
            log_error "Invalid operator number: $operator_num (must be 1, 2, or 3)"
            exit 1
            ;;
    esac
}

get_operator_address() {
    local operator_num="$1"
    case "$operator_num" in
        1) echo "0x70997970C51812dc3A010C7d01b50e0d17dc79C8" ;;
        2) echo "0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC" ;;
        3) echo "0x15d34AAf54267DB7D7c367839AAf71A00a2C6A65" ;;
    esac
}

verify_operator_on_service() {
    local tangle_addr="$1"
    local service_id="$2"
    local operator_num="$3"
    local operator_addr
    operator_addr=$(get_operator_address "$operator_num")

    log "Checking if operator $operator_num ($operator_addr) is on service $service_id..."

    local operators_result
    operators_result=$(cast call "$tangle_addr" \
        "getServiceOperators(uint64)(address[])" \
        "$service_id" \
        --rpc-url "$RPC_URL" 2>&1) || {
        log_error "Failed to query service operators. Is service $service_id valid?"
        log_error "Response: $operators_result"
        exit 1
    }

    # Check if the operator address is in the result (case-insensitive)
    local operator_lower
    operator_lower=$(echo "$operator_addr" | tr '[:upper:]' '[:lower:]')
    local operators_lower
    operators_lower=$(echo "$operators_result" | tr '[:upper:]' '[:lower:]')

    if ! echo "$operators_lower" | grep -q "$operator_lower"; then
        log_error "Operator $operator_num ($operator_addr) is NOT an active operator on service $service_id"
        log_error "Active operators: $operators_result"
        if [[ "$operator_num" == "3" ]]; then
            log_error "Hint: Operator 3 is registered in restaking but not for the blueprint in the default LocalTestnet setup."
            log_error "Only operators 1 and 2 are registered for the blueprint."
        fi
        exit 1
    fi

    log "Operator $operator_num confirmed as active on service $service_id"
}

do_submit_result() {
    local tangle_addr="$1"
    local service_id="$2"
    local call_id="$3"
    local operator_num="$4"
    local output_text="$5"

    local operator_key
    operator_key=$(get_operator_key "$operator_num")
    local operator_addr
    operator_addr=$(get_operator_address "$operator_num")

    # Verify operator is on the service
    verify_operator_on_service "$tangle_addr" "$service_id" "$operator_num"

    # Encode the output as ABI-encoded bytes
    local output_hex
    output_hex=$(cast abi-encode "f(string)" "$output_text" 2>&1) || {
        log_error "Failed to ABI-encode output: $output_hex"
        exit 1
    }

    log "Submitting result..."
    log "  Tangle:     $tangle_addr"
    log "  Service ID: $service_id"
    log "  Call ID:    $call_id"
    log "  Operator:   $operator_num ($operator_addr)"
    log "  Output:     \"$output_text\""

    local tx_result
    tx_result=$(cast send "$tangle_addr" \
        "submitResult(uint64,uint64,bytes)" \
        "$service_id" "$call_id" "$output_hex" \
        --private-key "$operator_key" \
        --rpc-url "$RPC_URL" \
        --json 2>&1) || {
        # Try to extract a human-readable error
        if echo "$tx_result" | grep -qi "revert"; then
            local reason
            reason=$(echo "$tx_result" | grep -oP '(?<=revert: ).*|(?<=reverted with: ).*' || echo "$tx_result")
            log_error "Transaction reverted: $reason"
        elif echo "$tx_result" | grep -qi "already submitted\|AlreadySubmitted"; then
            log_error "Operator $operator_num has already submitted a result for this job (service=$service_id, callId=$call_id)"
        elif echo "$tx_result" | grep -qi "not.*operator\|NotAnOperator"; then
            log_error "Operator $operator_num is not an active operator for service $service_id"
        elif echo "$tx_result" | grep -qi "completed\|JobCompleted"; then
            log_error "Job (callId=$call_id) is already completed"
        else
            log_error "Transaction failed: $tx_result"
        fi
        exit 1
    }

    local tx_status
    tx_status=$(echo "$tx_result" | jq -r '.status // empty' 2>/dev/null || echo "")

    if [[ "$tx_status" == "0x0" ]]; then
        log_error "Transaction was mined but reverted (status=0x0)"
        log_error "Full receipt: $tx_result"
        exit 1
    fi

    local tx_hash
    tx_hash=$(echo "$tx_result" | jq -r '.transactionHash // empty' 2>/dev/null || echo "unknown")

    log "Result submitted successfully!"
    log "  TX Hash: $tx_hash"
}

do_submit_job() {
    local tangle_addr="$1"
    local service_id="$2"

    # Encode empty input
    local input_hex
    input_hex=$(cast abi-encode "f(string)" "test input" 2>&1) || {
        log_error "Failed to ABI-encode input: $input_hex"
        exit 1
    }

    log "Submitting job..."
    log "  Tangle:     $tangle_addr"
    log "  Service ID: $service_id"
    log "  Job Index:  0"
    log "  Submitter:  deployer (Account 0)"

    local tx_result
    tx_result=$(cast send "$tangle_addr" \
        "submitJob(uint64,uint8,bytes)" \
        "$service_id" 0 "$input_hex" \
        --private-key "$DEPLOYER_KEY" \
        --rpc-url "$RPC_URL" \
        --json 2>&1) || {
        if echo "$tx_result" | grep -qi "revert"; then
            local reason
            reason=$(echo "$tx_result" | grep -oP '(?<=revert: ).*|(?<=reverted with: ).*' || echo "$tx_result")
            log_error "Transaction reverted: $reason"
        elif echo "$tx_result" | grep -qi "not.*permitted\|NotPermitted"; then
            log_error "Deployer is not a permitted caller for service $service_id"
        elif echo "$tx_result" | grep -qi "terminated\|ServiceTerminated"; then
            log_error "Service $service_id is terminated"
        else
            log_error "Transaction failed: $tx_result"
        fi
        exit 1
    }

    local tx_status
    tx_status=$(echo "$tx_result" | jq -r '.status // empty' 2>/dev/null || echo "")

    if [[ "$tx_status" == "0x0" ]]; then
        log_error "Transaction was mined but reverted (status=0x0)"
        log_error "Full receipt: $tx_result"
        exit 1
    fi

    local tx_hash
    tx_hash=$(echo "$tx_result" | jq -r '.transactionHash // empty' 2>/dev/null || echo "unknown")

    # Extract callId from the JobSubmitted event logs
    # JobSubmitted event: event JobSubmitted(uint64 indexed serviceId, uint64 indexed callId, ...)
    # Topic[0] = event signature hash, Topic[1] = serviceId, Topic[2] = callId
    local call_id=""
    local logs
    logs=$(echo "$tx_result" | jq -r '.logs // []' 2>/dev/null || echo "[]")
    local num_logs
    num_logs=$(echo "$logs" | jq 'length' 2>/dev/null || echo "0")
    local job_submitted_topic0
    job_submitted_topic0=$(cast keccak "JobSubmitted(uint64,uint64,uint8,address,bytes)" 2>/dev/null | tr '[:upper:]' '[:lower:]')

    for ((i = 0; i < num_logs; i++)); do
        local topics
        topics=$(echo "$logs" | jq -r ".[$i].topics // []" 2>/dev/null)
        local num_topics
        num_topics=$(echo "$topics" | jq 'length' 2>/dev/null || echo "0")

        if [[ "$num_topics" -ge 3 ]]; then
            local topic0_hex
            topic0_hex=$(echo "$topics" | jq -r '.[0]' 2>/dev/null | tr '[:upper:]' '[:lower:]')
            if [[ -z "$topic0_hex" || "$topic0_hex" == "null" || "$topic0_hex" != "$job_submitted_topic0" ]]; then
                continue
            fi

            local topic2_hex
            topic2_hex=$(echo "$topics" | jq -r '.[2]' 2>/dev/null || echo "")
            if [[ -n "$topic2_hex" && "$topic2_hex" != "null" ]]; then
                # Convert hex topic to decimal (the callId)
                call_id=$(cast to-dec "$topic2_hex" 2>/dev/null || echo "")
                if [[ -n "$call_id" ]]; then
                    break
                fi
            fi
        fi
    done

    log "Job submitted successfully!"
    log "  TX Hash: $tx_hash"

    if [[ -n "$call_id" ]]; then
        log "  Call ID: $call_id"
        log ""
        log "To submit a result for this job, run:"
        log "  $0 result -s $service_id -c $call_id -o 1"
    else
        log "  Call ID: (could not extract from logs - check transaction receipt)"
        log ""
        log "Get the callId from the transaction logs or GraphQL, then run:"
        log "  $0 result -s $service_id -c <CALL_ID> -o 1"
    fi
}

main() {
    # Defaults
    local subcommand="result"
    local service_id=""
    local call_id=""
    local operator_num="1"
    local output_text="test result"
    TANGLE_ADDR_OVERRIDE=""

    # Parse subcommand (first non-flag argument)
    if [[ $# -gt 0 && "$1" != "--"* && "$1" != "-"* ]]; then
        case "$1" in
            result|job)
                subcommand="$1"
                shift
                ;;
            --help|-h)
                show_help
                ;;
            *)
                log_error "Unknown subcommand: $1 (expected 'result' or 'job')"
                echo "Run '$0 --help' for usage information"
                exit 1
                ;;
        esac
    fi

    # Parse flags
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -s|--service-id)
                [[ $# -lt 2 ]] && { log_error "-s/--service-id requires a value"; exit 1; }
                service_id="$2"
                shift 2
                ;;
            -c|--call-id)
                [[ $# -lt 2 ]] && { log_error "-c/--call-id requires a value"; exit 1; }
                call_id="$2"
                shift 2
                ;;
            -o|--operator)
                [[ $# -lt 2 ]] && { log_error "-o/--operator requires a value"; exit 1; }
                operator_num="$2"
                shift 2
                ;;
            --output)
                [[ $# -lt 2 ]] && { log_error "--output requires a value"; exit 1; }
                output_text="$2"
                shift 2
                ;;
            --tangle)
                [[ $# -lt 2 ]] && { log_error "--tangle requires a value"; exit 1; }
                TANGLE_ADDR_OVERRIDE="$2"
                shift 2
                ;;
            --rpc-url)
                [[ $# -lt 2 ]] && { log_error "--rpc-url requires a value"; exit 1; }
                RPC_URL="$2"
                shift 2
                ;;
            -h|--help)
                show_help
                ;;
            *)
                log_error "Unknown flag: $1"
                echo "Run '$0 --help' for usage information"
                exit 1
                ;;
        esac
    done

    # Validate required params
    if [[ -z "$service_id" ]]; then
        log_error "--service-id is required"
        echo "Run '$0 --help' for usage information"
        exit 1
    fi

    if [[ "$subcommand" == "result" && -z "$call_id" ]]; then
        log_error "-c/--call-id is required for the 'result' subcommand"
        echo ""
        echo "If you don't have a callId yet, submit a job first:"
        echo "  $0 job -s $service_id"
        exit 1
    fi

    # Validate operator number
    if [[ ! "$operator_num" =~ ^[1-3]$ ]]; then
        log_error "--operator must be 1, 2, or 3 (got: $operator_num)"
        exit 1
    fi

    # Check prerequisites
    check_prerequisites
    check_anvil

    # Get contract address
    local tangle_addr
    tangle_addr=$(get_tangle_address)
    log "Tangle contract: $tangle_addr"

    # Verify contract has code
    local code
    code=$(cast code "$tangle_addr" --rpc-url "$RPC_URL" 2>/dev/null || echo "0x")
    if [[ "$code" == "0x" || -z "$code" ]]; then
        log_error "No contract found at $tangle_addr"
        log_error "Have you run start-local-dev.sh to deploy contracts?"
        exit 1
    fi

    # Execute subcommand
    case "$subcommand" in
        result)
            do_submit_result "$tangle_addr" "$service_id" "$call_id" "$operator_num" "$output_text"
            ;;
        job)
            do_submit_job "$tangle_addr" "$service_id"
            ;;
    esac
}

main "$@"
