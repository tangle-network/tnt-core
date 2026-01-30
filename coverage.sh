#!/usr/bin/env bash
set -euo pipefail
FOUNDRY_PROFILE=coverage forge coverage "$@"
