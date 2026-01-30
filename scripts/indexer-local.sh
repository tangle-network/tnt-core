#!/usr/bin/env bash
set -euo pipefail

# Local Envio indexer helper for TNT Core.
#
# This is intended to be called by external repos (e.g. the dApp) so there is a single
# source of truth for starting/stopping/resetting the indexer against a local Anvil chain.
#
# Usage:
#   ./scripts/indexer-local.sh start  --rpc-url http://127.0.0.1:8545 --chain-id 31337
#   ./scripts/indexer-local.sh stop
#   ./scripts/indexer-local.sh reset
#   ./scripts/indexer-local.sh status
#
# Env overrides:
#   ENVIO_PG_PORT (default 5433)
#   ENVIO_INDEXER_PORT (default 9898)
#   ENVIO_PG_USER (default postgres)
#   ENVIO_PG_PASSWORD (default testing)
#   ENVIO_PG_DATABASE (default envio-dev)
#   GRAPHQL_PORT (default 8080)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
INDEXER_DIR="$ROOT_DIR/indexer"
STATE_DIR="${STATE_DIR:-/tmp/tnt-core-indexer-local}"
PID_FILE="$STATE_DIR/indexer.pid"
LOG_FILE="$STATE_DIR/indexer.log"
PORTS_FILE="$STATE_DIR/ports.env"

ENVIO_PG_PORT="${ENVIO_PG_PORT:-5433}"
ENVIO_INDEXER_PORT="${ENVIO_INDEXER_PORT:-9898}"
GRAPHQL_PORT="${GRAPHQL_PORT:-8080}"
HASURA_EXTERNAL_PORT="${HASURA_EXTERNAL_PORT:-$GRAPHQL_PORT}"
ENVIO_PG_USER="${ENVIO_PG_USER:-postgres}"
ENVIO_PG_PASSWORD="${ENVIO_PG_PASSWORD:-testing}"
ENVIO_PG_DATABASE="${ENVIO_PG_DATABASE:-envio-dev}"

RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
BLUE=$'\033[0;34m'
NC=$'\033[0m'

log_info() { echo -e "${BLUE}[indexer]${NC} $*"; }
log_success() { echo -e "${GREEN}[indexer]${NC} $*"; }
log_warn() { echo -e "${YELLOW}[indexer]${NC} $*"; }
log_error() { echo -e "${RED}[indexer]${NC} $*"; }

usage() {
  cat <<EOF
Usage:
  $0 start  --rpc-url <url> --chain-id <id>
  $0 stop
  $0 reset
  $0 status
EOF
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || { log_error "Missing required command: $1"; exit 1; }
}

port_pid() {
  local port="$1"
  lsof -ti:"$port" 2>/dev/null | head -1 || true
}

find_free_port() {
  local port="$1"
  while [[ -n "$(port_pid "$port")" ]]; do
    port=$((port + 1))
  done
  echo "$port"
}

ensure_free_port_var() {
  local name="$1"
  local value="$2"

  local pid
  pid="$(port_pid "$value")"
  if [[ -z "$pid" ]]; then
    echo "$value"
    return 0
  fi

  local new_port
  new_port="$(find_free_port "$value")"
  log_warn "$name port $value is in use by PID $pid; using $new_port instead" >&2
  echo "$new_port"
}

ensure_state_dir() {
  mkdir -p "$STATE_DIR"
}

load_ports_if_present() {
  if [[ -f "$PORTS_FILE" ]]; then
    # shellcheck disable=SC1090
    source "$PORTS_FILE"
  fi
}

pid_running() {
  local pid="$1"
  [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null
}

read_pid() {
  if [[ -f "$PID_FILE" ]]; then
    cat "$PID_FILE"
  else
    echo ""
  fi
}

kill_indexer_pid() {
  local pid
  pid="$(read_pid)"
  if pid_running "$pid"; then
    log_info "Stopping indexer (PID: $pid)..."
    kill "$pid" 2>/dev/null || true
    sleep 1
    if pid_running "$pid"; then
      log_warn "Indexer still running; sending SIGKILL..."
      kill -9 "$pid" 2>/dev/null || true
    fi
  fi
  rm -f "$PID_FILE"
}

ensure_generated_symlink() {
  cd "$INDEXER_DIR"
  rm -rf node_modules/.pnpm/generated@* 2>/dev/null || true
  rm -rf node_modules/generated 2>/dev/null || true
  ln -sfn ../generated node_modules/generated
}

codegen_if_needed() {
  cd "$INDEXER_DIR"
  cp config.local.yaml config.yaml

  local needs_codegen=true
  if [[ -f "$INDEXER_DIR/generated/src/EventHandlers.res.js" ]]; then
    local config_mtime gen_mtime
    config_mtime=$(stat -f %m config.yaml 2>/dev/null || stat -c %Y config.yaml 2>/dev/null || echo 0)
    gen_mtime=$(stat -f %m "$INDEXER_DIR/generated/src/EventHandlers.res.js" 2>/dev/null || stat -c %Y "$INDEXER_DIR/generated/src/EventHandlers.res.js" 2>/dev/null || echo 0)
    if [[ "$gen_mtime" -gt "$config_mtime" ]]; then
      needs_codegen=false
    fi
  fi

  if [[ "$needs_codegen" == "true" ]]; then
    log_info "Running Envio codegen..."
    pnpm codegen
  else
    log_info "Skipping codegen (up to date)"
  fi
}

docker_up() {
  cd "$INDEXER_DIR/generated"
  log_info "Starting docker services..."
  docker compose down -v 2>/dev/null || true
  ENVIO_PG_PORT="$ENVIO_PG_PORT" HASURA_EXTERNAL_PORT="$HASURA_EXTERNAL_PORT" docker compose up -d
}

db_setup() {
  cd "$INDEXER_DIR/generated"
  log_info "Running DB migrations..."
  pnpm db-setup

  log_info "Clearing chain progress..."
  PGPASSWORD="$ENVIO_PG_PASSWORD" psql -h localhost -p "$ENVIO_PG_PORT" -U "$ENVIO_PG_USER" -d "$ENVIO_PG_DATABASE" -c \
    "TRUNCATE TABLE public.persisted_state, public.chain_metadata, public.dynamic_contract_registry CASCADE;" 2>/dev/null || true
}

wait_hasura_schema() {
  local url="http://localhost:$HASURA_EXTERNAL_PORT/v1/graphql"
  log_info "Waiting for Hasura schema at $url ..."
  for i in {1..60}; do
    local result
    result="$(curl -s "$url" -H "Content-Type: application/json" -d '{"query":"{ __schema { types { name } } }"}' 2>/dev/null || true)"
    if echo "$result" | grep -q "Operator"; then
      log_success "Hasura schema is ready"
      return 0
    fi
    [[ $((i % 10)) -eq 0 ]] && log_info "Waiting... ($i/60)"
    sleep 2
  done
  log_warn "Hasura schema did not become ready within timeout"
}

start_indexer() {
  local rpc_url="" chain_id=""
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --rpc-url) rpc_url="$2"; shift 2 ;;
      --chain-id) chain_id="$2"; shift 2 ;;
      *) log_error "Unknown arg: $1"; usage; exit 1 ;;
    esac
  done
  if [[ -z "$rpc_url" || -z "$chain_id" ]]; then
    log_error "Missing --rpc-url or --chain-id"
    usage
    exit 1
  fi

  require_cmd docker
  require_cmd pnpm
  require_cmd psql
  require_cmd curl

  ensure_state_dir

  # If we already started once, prefer the persisted ports unless the caller explicitly overrides.
  load_ports_if_present

  ENVIO_PG_PORT="$(ensure_free_port_var ENVIO_PG_PORT "$ENVIO_PG_PORT")"
  HASURA_EXTERNAL_PORT="$(ensure_free_port_var HASURA_EXTERNAL_PORT "$HASURA_EXTERNAL_PORT")"
  ENVIO_INDEXER_PORT="$(ensure_free_port_var ENVIO_INDEXER_PORT "$ENVIO_INDEXER_PORT")"

  # Keep compatibility: callers may use GRAPHQL_PORT (external port). HASURA_EXTERNAL_PORT is what docker-compose consumes.
  GRAPHQL_PORT="$HASURA_EXTERNAL_PORT"
  export ENVIO_PG_PORT ENVIO_PG_USER ENVIO_PG_PASSWORD ENVIO_PG_DATABASE
  export ENVIO_INDEXER_PORT GRAPHQL_PORT HASURA_EXTERNAL_PORT

  cat >"$PORTS_FILE" <<EOF
ENVIO_PG_PORT=$ENVIO_PG_PORT
ENVIO_INDEXER_PORT=$ENVIO_INDEXER_PORT
GRAPHQL_PORT=$GRAPHQL_PORT
HASURA_EXTERNAL_PORT=$HASURA_EXTERNAL_PORT
EOF

  if [[ -f "$PID_FILE" ]]; then
    local existing
    existing="$(read_pid)"
    if pid_running "$existing"; then
      log_warn "Indexer already running (PID: $existing)."
      exit 0
    fi
    rm -f "$PID_FILE"
  fi

  cd "$INDEXER_DIR"
  codegen_if_needed
  ensure_generated_symlink

  rm -f "$INDEXER_DIR/generated/persisted_state.envio.json" 2>/dev/null || true

  docker_up
  sleep 3
  db_setup
  ensure_generated_symlink

  log_info "Starting indexer process..."
  cd "$INDEXER_DIR/generated"
  local env_rpc_key="ENVIO_RPC_URL_${chain_id}"
  env "$env_rpc_key=$rpc_url" \
    ENVIO_INDEXER_PORT="$ENVIO_INDEXER_PORT" \
    METRICS_PORT="$ENVIO_INDEXER_PORT" \
    HASURA_EXTERNAL_PORT="$HASURA_EXTERNAL_PORT" \
    TUI_OFF=true pnpm start >"$LOG_FILE" 2>&1 &
  local pid=$!
  echo "$pid" >"$PID_FILE"
  log_success "Indexer started (PID: $pid)"
  log_info "Logs: $LOG_FILE"

  sleep 3
  if ! pid_running "$pid"; then
    log_error "Indexer exited immediately. See logs: $LOG_FILE"
    exit 1
  fi

  wait_hasura_schema
}

status() {
  ensure_state_dir
  load_ports_if_present
  local pid
  pid="$(read_pid)"
  if pid_running "$pid"; then
    log_success "Indexer running (PID: $pid)"
  else
    log_warn "Indexer not running"
  fi
  log_info "GraphQL: http://localhost:$HASURA_EXTERNAL_PORT/v1/graphql"
  log_info "Metrics/indexer port: $ENVIO_INDEXER_PORT"
  log_info "Postgres port: $ENVIO_PG_PORT"
}

stop() {
  require_cmd docker
  ensure_state_dir
  load_ports_if_present
  kill_indexer_pid
  if [[ -d "$INDEXER_DIR/generated" ]]; then
    (cd "$INDEXER_DIR/generated" && docker compose down -v 2>/dev/null) || true
  fi
  rm -f "$PORTS_FILE" 2>/dev/null || true
  log_success "Stopped"
}

reset() {
  stop
  log_info "Reset complete. Run '$0 start --rpc-url ... --chain-id ...' to restart."
}

cmd="${1:-}"
shift || true
case "$cmd" in
  start) start_indexer "$@" ;;
  stop) stop ;;
  reset) reset ;;
  status) status ;;
  *) usage; exit 1 ;;
esac
