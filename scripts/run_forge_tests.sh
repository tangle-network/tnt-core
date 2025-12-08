#!/usr/bin/env bash
set -euo pipefail

# Allow overriding the stack size via STACK_SOFT_LIMIT (in kilobytes).
# Accept kilobytes or the literal string "unlimited".
STACK_SOFT_LIMIT="${STACK_SOFT_LIMIT:-unlimited}"
# Allow overriding the Rust per-thread stack via RUST_MIN_STACK (bytes).
RUST_MIN_STACK_VALUE="${RUST_MIN_STACK_VALUE:-268435456}" # 256 MB default

# Try to raise the shell soft stack size; ignore failures (e.g., limited shells).
if command -v ulimit >/dev/null 2>&1; then
    if [[ "${STACK_SOFT_LIMIT}" == "unlimited" ]]; then
        # shellcheck disable=SC3045
        ulimit -S -s unlimited 2>/dev/null || true
    else
        # shellcheck disable=SC3045
        ulimit -S -s "${STACK_SOFT_LIMIT}" 2>/dev/null || true
    fi
fi

export RUST_MIN_STACK="${RUST_MIN_STACK_VALUE}"

# Default to single-threaded Forge to avoid spawning extra worker stacks.
if [[ $# -gt 0 ]]; then
    exec "$@"
fi

# No custom command supplied: run the entire suite file-by-file so each Forge
# invocation remains lightweight (prevents stack overflows on macOS).
TEST_FILES=()
while IFS= read -r file; do
    TEST_FILES+=("$file")
done < <(find test/v2 -type f -name '*.t.sol' | sort)

run_segment() {
    local pattern="$1"
    echo "=== Running forge test --match-path '${pattern}' ==="
    forge test --threads 1 --match-path "${pattern}"
}

for test_file in "${TEST_FILES[@]}"; do
    run_segment "${test_file}" || exit 1
done
