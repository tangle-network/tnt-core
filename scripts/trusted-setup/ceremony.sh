#!/usr/bin/env bash
# Groth16 trusted setup ceremony for VAnchor circuits.
#
# Compiles the VAnchor circuits from protocol-solidity, downloads the
# Hermez powers-of-tau file, runs phase 2 contributions, and exports
# verification keys + Solidity verifier contracts.
#
# Prerequisites:
#   - Node.js >= 18 (for snarkjs)
#   - Rust toolchain (for circom compiler)
#   - ~8 GB RAM for the larger circuits
#
# Usage:
#   ./scripts/trusted-setup/ceremony.sh [--skip-compile] [--ptau-size 22]
#
# Output:
#   build/trusted-setup/
#     ├── circuits/           (compiled R1CS + WASM)
#     ├── zkeys/              (final zkey files)
#     ├── verification_keys/  (JSON verification keys)
#     └── verifiers/          (Solidity verifier contracts)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
PROTOCOL_SOL_DIR="$ROOT_DIR/dependencies/protocol-solidity"
CIRCUITS_DIR="$PROTOCOL_SOL_DIR/circuits"

BUILD_DIR="$ROOT_DIR/build/trusted-setup"
CIRCUITS_OUT="$BUILD_DIR/circuits"
ZKEYS_OUT="$BUILD_DIR/zkeys"
VKEYS_OUT="$BUILD_DIR/verification_keys"
VERIFIERS_OUT="$BUILD_DIR/verifiers"

# Default powers-of-tau size (2^22 constraints, sufficient for VAnchor circuits)
PTAU_SIZE="${PTAU_SIZE:-22}"
SKIP_COMPILE="${SKIP_COMPILE:-false}"

# Parse flags
while [[ $# -gt 0 ]]; do
    case "$1" in
        --skip-compile) SKIP_COMPILE=true; shift ;;
        --ptau-size)    PTAU_SIZE="$2"; shift 2 ;;
        --ptau-size=*)  PTAU_SIZE="${1#*=}"; shift ;;
        *)              echo "Unknown flag: $1"; exit 1 ;;
    esac
done

# The four VAnchor circuits needed for VAnchorVerifier:
#   poseidon_vanchor_2_2   (2 inputs, 2 edges)
#   poseidon_vanchor_16_2  (16 inputs, 2 edges)
#   poseidon_vanchor_2_8   (2 inputs, 8 edges)
#   poseidon_vanchor_16_8  (16 inputs, 8 edges)
CIRCUITS=(
    "poseidon_vanchor_2_2"
    "poseidon_vanchor_16_2"
    "poseidon_vanchor_2_8"
    "poseidon_vanchor_16_8"
)

# ============================================================================
# Dependency checks
# ============================================================================

check_deps() {
    echo "Checking dependencies..."

    if ! command -v node &>/dev/null; then
        echo "ERROR: Node.js not found. Install Node.js >= 18."
        exit 1
    fi

    if ! command -v npx &>/dev/null; then
        echo "ERROR: npx not found. Install Node.js >= 18."
        exit 1
    fi

    # Check snarkjs is available
    if ! npx snarkjs --version &>/dev/null 2>&1; then
        echo "Installing snarkjs..."
        npm install -g snarkjs@latest
    fi
    echo "  snarkjs: $(npx snarkjs --version 2>/dev/null || echo 'installed')"

    # Check circom
    CIRCOM_BIN="${CIRCOM_BIN:-}"
    if command -v circom &>/dev/null; then
        CIRCOM_BIN="circom"
    elif [ -x "$HOME/.cargo/bin/circom" ]; then
        CIRCOM_BIN="$HOME/.cargo/bin/circom"
    else
        echo "ERROR: circom not found."
        echo "Install: git clone https://github.com/iden3/circom.git && cd circom && cargo build --release && cargo install --path circom"
        exit 1
    fi
    echo "  circom: $($CIRCOM_BIN --version 2>/dev/null || echo 'installed')"

    # Check protocol-solidity circuits exist
    if [ ! -d "$CIRCUITS_DIR/main" ]; then
        echo "ERROR: protocol-solidity circuits not found at $CIRCUITS_DIR/main"
        echo "Run: git submodule update --init dependencies/protocol-solidity"
        exit 1
    fi
    echo "  circuits: $CIRCUITS_DIR/main"

    echo "All dependencies OK."
    echo ""
}

# ============================================================================
# Step 1: Download powers-of-tau (Hermez ceremony)
# ============================================================================

download_ptau() {
    local ptau_file="$BUILD_DIR/powersOfTau28_hez_final_${PTAU_SIZE}.ptau"

    if [ -f "$ptau_file" ]; then
        echo "Powers of tau already downloaded: $ptau_file"
        return
    fi

    echo "Downloading Hermez powers-of-tau (2^${PTAU_SIZE})..."
    mkdir -p "$BUILD_DIR"

    local url="https://storage.googleapis.com/zkevm/ptau/powersOfTau28_hez_final_${PTAU_SIZE}.ptau"
    if command -v curl &>/dev/null; then
        curl -L --progress-bar -o "$ptau_file" "$url"
    elif command -v wget &>/dev/null; then
        wget -q --show-progress -O "$ptau_file" "$url"
    else
        echo "ERROR: curl or wget required to download ptau file."
        exit 1
    fi

    echo "Downloaded: $ptau_file"
    echo ""
}

# ============================================================================
# Step 2: Compile circuits
# ============================================================================

compile_circuit() {
    local circuit_name="$1"
    local out_dir="$CIRCUITS_OUT/$circuit_name"

    if [ -f "$out_dir/${circuit_name}.r1cs" ] && [ -f "$out_dir/${circuit_name}_js/${circuit_name}.wasm" ]; then
        echo "  Circuit already compiled: $circuit_name"
        return
    fi

    echo "  Compiling: $circuit_name"
    mkdir -p "$out_dir"

    "$CIRCOM_BIN" \
        --r1cs --wasm --sym \
        -o "$out_dir" \
        "$CIRCUITS_DIR/main/${circuit_name}.circom"

    echo "    R1CS: $out_dir/${circuit_name}.r1cs"
    echo "    WASM: $out_dir/${circuit_name}_js/${circuit_name}.wasm"
}

compile_all_circuits() {
    if [ "$SKIP_COMPILE" = "true" ]; then
        echo "Skipping circuit compilation (--skip-compile)."
        return
    fi

    echo "Compiling VAnchor circuits..."
    for circuit in "${CIRCUITS[@]}"; do
        compile_circuit "$circuit"
    done
    echo "All circuits compiled."
    echo ""
}

# ============================================================================
# Step 3: Phase 2 ceremony (per circuit)
# ============================================================================

phase2_ceremony() {
    local circuit_name="$1"
    local ptau_file="$BUILD_DIR/powersOfTau28_hez_final_${PTAU_SIZE}.ptau"
    local r1cs="$CIRCUITS_OUT/$circuit_name/${circuit_name}.r1cs"
    local zkey_dir="$ZKEYS_OUT/$circuit_name"
    local final_zkey="$zkey_dir/circuit_final.zkey"

    if [ -f "$final_zkey" ]; then
        echo "  Phase 2 already complete: $circuit_name"
        return
    fi

    echo "  Running phase 2 for: $circuit_name"
    mkdir -p "$zkey_dir"

    if [ ! -f "$r1cs" ]; then
        echo "ERROR: R1CS not found: $r1cs"
        echo "Run without --skip-compile first."
        exit 1
    fi

    # Initial setup
    echo "    Groth16 setup..."
    npx snarkjs groth16 setup \
        "$r1cs" "$ptau_file" \
        "$zkey_dir/circuit_0000.zkey"

    # Contribution (deterministic for dev; use real entropy in production)
    echo "    Contributing..."
    echo "tangle-shielded-setup" | npx snarkjs zkey contribute \
        "$zkey_dir/circuit_0000.zkey" \
        "$zkey_dir/circuit_0001.zkey" \
        --name="Tangle contribution" -v

    # Verify contribution
    echo "    Verifying contribution..."
    npx snarkjs zkey verify "$r1cs" "$ptau_file" "$zkey_dir/circuit_0001.zkey"

    # Apply random beacon
    echo "    Applying beacon..."
    npx snarkjs zkey beacon \
        "$zkey_dir/circuit_0001.zkey" \
        "$final_zkey" \
        0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f 10 \
        -n="Final Beacon phase2"

    # Final verification
    echo "    Final verification..."
    npx snarkjs zkey verify "$r1cs" "$ptau_file" "$final_zkey"

    # Export verification key
    mkdir -p "$VKEYS_OUT"
    npx snarkjs zkey export verificationkey \
        "$final_zkey" \
        "$VKEYS_OUT/${circuit_name}_verification_key.json"

    # Export Solidity verifier
    mkdir -p "$VERIFIERS_OUT"
    npx snarkjs zkey export solidityverifier \
        "$final_zkey" \
        "$VERIFIERS_OUT/${circuit_name}_verifier.sol"

    # Rename the contract to match protocol-solidity convention.
    # poseidon_vanchor_2_2  => Verifier2_2   (edges=2, inputs=2)
    # poseidon_vanchor_16_2 => Verifier2_16  (edges=2, inputs=16)
    # poseidon_vanchor_2_8  => Verifier8_2   (edges=8, inputs=2)
    # poseidon_vanchor_16_8 => Verifier8_16  (edges=8, inputs=16)
    local verifier_name
    verifier_name=$(echo "$circuit_name" | sed -E 's/poseidon_vanchor_([0-9]+)_([0-9]+)/Verifier\2_\1/')
    sed -i "s/contract Verifier/contract ${verifier_name}/" \
        "$VERIFIERS_OUT/${circuit_name}_verifier.sol"
    sed -i 's/pragma solidity ^0.6.11;/pragma solidity ^0.8.18;/' \
        "$VERIFIERS_OUT/${circuit_name}_verifier.sol"

    # Clean up intermediate zkeys to save disk space
    rm -f "$zkey_dir/circuit_0000.zkey" "$zkey_dir/circuit_0001.zkey"

    echo "    Done: $circuit_name"
}

run_all_phase2() {
    echo "Running phase 2 ceremonies..."
    for circuit in "${CIRCUITS[@]}"; do
        phase2_ceremony "$circuit"
    done
    echo "All phase 2 ceremonies complete."
    echo ""
}

# ============================================================================
# Poseidon deployment instructions
# ============================================================================

print_poseidon_deploy_instructions() {
    cat <<'POSEIDON_INSTRUCTIONS'
============================================================
NEXT STEPS: Deploy Poseidon libraries
============================================================

Poseidon hash functions require bytecode generated by circomlibjs.
They cannot be compiled from Solidity source alone.

Deploy them using this Node.js snippet:

  const { ethers } = require("ethers");
  const { buildPoseidon } = require("circomlibjs");

  async function deployPoseidon(signer) {
    const poseidon = await buildPoseidon();
    for (let nInputs = 1; nInputs <= 5; nInputs++) {
      const abi = poseidon.contract.generateABI(nInputs);
      const bytecode = poseidon.contract.createCode(nInputs);
      const factory = new ethers.ContractFactory(abi, bytecode, signer);
      const contract = await factory.deploy();
      await contract.waitForDeployment();
      console.log(`PoseidonT${nInputs + 1}: ${await contract.getAddress()}`);
    }
  }

Then set the addresses in your deploy-config JSON or env vars.

POSEIDON_INSTRUCTIONS
}

# ============================================================================
# Summary
# ============================================================================

print_summary() {
    echo "============================================================"
    echo "TRUSTED SETUP COMPLETE"
    echo "============================================================"
    echo ""
    echo "Artifacts:"
    echo "  Circuits:           $CIRCUITS_OUT/"
    echo "  ZKeys:              $ZKEYS_OUT/"
    echo "  Verification keys:  $VKEYS_OUT/"
    echo "  Solidity verifiers: $VERIFIERS_OUT/"
    echo ""
    echo "Generated verifier contracts:"
    for circuit in "${CIRCUITS[@]}"; do
        echo "  $VERIFIERS_OUT/${circuit}_verifier.sol"
    done
    echo ""
    echo "To use with DeployShieldedPool.s.sol:"
    echo "  1. Deploy the Solidity verifier contracts above"
    echo "  2. Deploy Poseidon libraries (see instructions above)"
    echo "  3. Set addresses in script/deploy-config/*-shielded.json"
    echo "  4. Run: forge script script/DeployShieldedPool.s.sol:DeployShieldedPool --rpc-url \$RPC --broadcast --slow"
    echo ""
}

# ============================================================================
# Main
# ============================================================================

main() {
    echo "============================================================"
    echo "Tangle Shielded Pool - Groth16 Trusted Setup Ceremony"
    echo "============================================================"
    echo ""

    check_deps
    download_ptau
    compile_all_circuits
    run_all_phase2
    print_poseidon_deploy_instructions
    print_summary
}

main
