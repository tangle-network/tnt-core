#!/usr/bin/env bash
set -euo pipefail
FOUNDRY_PROFILE=coverage ./scripts/run_forge_tests.sh forge coverage "$@"
