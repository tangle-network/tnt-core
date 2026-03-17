#!/usr/bin/env bash
# Setup script for shielded payments dependencies.
# Run this after cloning the repo to install the OZ 4.x compat layer
# needed by protocol-solidity contracts.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
DEPS_DIR="$ROOT_DIR/dependencies"

echo "Setting up shielded payments dependencies..."

# 0. Install soldeer dependencies (OZ 5.x, forge-std)
echo "  Running soldeer update..."
cd "$ROOT_DIR"
forge soldeer update 2>/dev/null || echo "  (soldeer update skipped — run manually if needed)"

# 1. Initialize protocol-solidity submodule
echo "  Initializing protocol-solidity submodule..."
cd "$ROOT_DIR"
git submodule update --init dependencies/protocol-solidity

# 2. Install OZ 4.x for protocol-solidity compatibility
OZ4_DIR="$DEPS_DIR/openzeppelin-contracts-4.9.6"
if [ ! -d "$OZ4_DIR" ]; then
    echo "  Installing OpenZeppelin Contracts v4.9.6..."
    git clone --depth 1 --branch v4.9.6 \
        https://github.com/OpenZeppelin/openzeppelin-contracts.git \
        "$OZ4_DIR"
    rm -rf "$OZ4_DIR/.git"
else
    echo "  OpenZeppelin Contracts v4.9.6 already installed."
fi

# 3. Create OZ 4.x/5.x compatibility shims
# protocol-solidity imports paths that were removed/moved in OZ 5.x.
# These tiny shim files re-export from OZ 4.x so the audited contracts
# compile unmodified.

SHIM_RG="$DEPS_DIR/@openzeppelin-contracts-5.1.0/security"
if [ ! -f "$SHIM_RG/ReentrancyGuard.sol" ]; then
    echo "  Creating OZ compatibility shim: security/ReentrancyGuard.sol"
    mkdir -p "$SHIM_RG"
    cat > "$SHIM_RG/ReentrancyGuard.sol" << 'EOF'
// SPDX-License-Identifier: MIT
// Compatibility shim: protocol-solidity (OZ 4.x) imports this path.
// OZ 5.x moved ReentrancyGuard to utils/. This re-exports the OZ 4.x version
// so that the audited protocol-solidity contracts compile unmodified.
pragma solidity ^0.8.18;

import { ReentrancyGuard } from "@openzeppelin-v4/contracts/security/ReentrancyGuard.sol";
EOF
fi

SHIM_PRESET="$DEPS_DIR/@openzeppelin-contracts-5.1.0/token/ERC20/presets"
if [ ! -f "$SHIM_PRESET/ERC20PresetMinterPauser.sol" ]; then
    echo "  Creating OZ compatibility shim: token/ERC20/presets/ERC20PresetMinterPauser.sol"
    mkdir -p "$SHIM_PRESET"
    cat > "$SHIM_PRESET/ERC20PresetMinterPauser.sol" << 'EOF'
// SPDX-License-Identifier: MIT
// Compatibility shim: protocol-solidity (OZ 4.x) imports this path.
// OZ 5.x removed ERC20PresetMinterPauser. This re-exports the OZ 4.x version
// so that the audited protocol-solidity contracts compile unmodified.
pragma solidity ^0.8.18;

import { ERC20PresetMinterPauser } from "@openzeppelin-v4/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol";
EOF
fi

echo "  Done! Run 'forge build' to verify compilation."
