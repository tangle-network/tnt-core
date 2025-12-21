#!/usr/bin/env bash
set -euo pipefail

# Foundry will eventually overflow the default macOS thread stack once the full
# suite is executed. This script ensures we bump stack limits consistently.

ulimit -S -s unlimited >/dev/null 2>&1 || true
ulimit -s unlimited >/dev/null 2>&1 || true
export RUST_MIN_STACK="${RUST_MIN_STACK:-268435456}"

if [[ "$#" -eq 0 ]]; then
  mapfile -t test_files < <(find test/v2 -type f -name '*.t.sol' | LC_ALL=C sort)
  if [[ "${#test_files[@]}" -eq 0 ]]; then
    echo "No test files found under test/v2" >&2
    exit 1
  fi

  for f in "${test_files[@]}"; do
    echo "==> forge test --threads 1 --match-path ${f}"
    forge test --threads 1 --match-path "${f}"
  done
  exit 0
fi

if [[ "${1:-}" == "forge" && "${2:-}" == "test" ]]; then
  for arg in "$@"; do
    if [[ "${arg}" == "--threads" ]]; then
      exec "$@"
    fi
  done
  exec "$@" --threads 1
fi

exec "$@"

