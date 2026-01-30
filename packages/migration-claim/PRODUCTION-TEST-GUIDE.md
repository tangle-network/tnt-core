# Claim Migration Production Test Guide

This guide provides step-by-step instructions for setting up the claim migration system on a production or testnet environment.

## Table of Contents

1. [Prerequisites](#step-1-prerequisites)
2. [Build SP1 Program](#step-2-build-sp1-program)
3. [Generate Verification Key](#step-3-generate-verification-key)
4. [Deploy Contracts](#step-4-deploy-contracts)
5. [Configure & Start Services](#step-5-configure--start-services)
6. [Run Local Frontend](#step-6-run-local-frontend)

---

## Step 1: Prerequisites

### Required Tools

```bash
# Foundry (cast, forge)
curl -L https://foundry.paradigm.xyz | bash
foundryup

# Rust toolchain with RISC-V target (for SP1)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
rustup target add riscv32im-unknown-none-elf

# SP1 toolchain
curl -L https://sp1up.dev | bash
sp1up

# Node.js 18+ (for claim-relayer)
node --version  # Should be >= 18

# jq (for JSON parsing)
brew install jq  # macOS
# or: apt-get install jq  # Linux
```

### Required Accounts & Funds

| Account                | Purpose                 | Required Funds                      |
| ---------------------- | ----------------------- | ----------------------------------- |
| Deployer               | Deploy contracts        | ETH for gas (~0.1 ETH)              |
| Relayer                | Submit claims for users | ETH for gas (~0.05 ETH per claim)   |
| Succinct Network       | Generate ZK proofs      | PROVE tokens (~0.5 PROVE per proof) |
| Test Substrate Account | Claim tokens            | Must be in merkle tree              |

> **Deposit PROVE to Succinct:** Follow this [guide](https://docs.succinct.xyz/docs/sp1/prover-network/quickstart)

### Directory Structure

```
packages/migration-claim/
├── src/                    # Solidity contracts
├── script/                 # Deployment scripts
├── sp1/
│   ├── program/           # ZK circuit (guest program)
│   ├── lib/               # Shared types
│   ├── prover-api/        # HTTP API for proof generation
│   └── script/            # VKey generation tool
├── scripts/               # Shell scripts
├── merkle-tree.json       # Generated merkle tree
└── evm-claims.json        # EVM airdrop data
```

---

## Step 2: Build SP1 Program

The SP1 program is the ZK circuit that proves SR25519 signature ownership. Building it generates the ELF binary that defines the verification key.

### Build the ZK Program

```bash
cd packages/migration-claim/sp1

# Set macOS-specific environment (skip on Linux)
export SDKROOT=$(xcrun --show-sdk-path)
export CXXFLAGS="-isysroot $SDKROOT -I$SDKROOT/usr/include/c++/v1 -stdlib=libc++"

# Build the SP1 guest program (generates ELF)
cd program
cargo prove build

# Verify ELF was generated
ls -la elf/
# Should show: riscv32im-succinct-zkvm-elf
```

### Build the Prover API and Tools

```bash
cd packages/migration-claim/sp1

# Build the host script
cargo +succinct build --release -p sr25519-claim-script
```

> **Important:** The ELF binary at `sp1/program/elf/riscv32im-succinct-zkvm-elf` is embedded in the prover-api. If you modify the ZK program, you must rebuild both the program AND the prover-api.

---

## Step 3: Generate Verification Key

The verification key (vkey) is derived from the ELF binary and uniquely identifies the ZK program. This key must be deployed on-chain for proof verification.

### Generate VKey

```bash
cd packages/migration-claim/sp1

# Run vkey generator
cargo +succinct run --release -p sr25519-claim-script --bin vkey
```

**Expected Output:**

```
SR25519 Claim Program - Verification Key
=========================================

Verification Key (bytes32):
0x0043b75837095121e5cfc178612414bddea823bad5aa08f3061b15b49c63a99f

Use this value as the `PROGRAM_VKEY` parameter
when deploying contract with `deploy-tangle-migration.sh` (this is for the SP1ZKVerifier contract)
```

---

## Step 4: Deploy Contracts

Deploy the TNT token, ZK verifier, and TangleMigration contracts.

For production testing with real ZK verification on Base Sepolia:

```bash
cd packages/migration-claim

# Deploy with SP1 verifier
PRIVATE_KEY=$PRIVATE_KEY \
PROGRAM_VKEY=$PROGRAM_VKEY \
./scripts/deploy-tangle-migration.sh --production
```

### Deployment Output

```
============================================
Deployment Complete!
============================================

Contract Addresses:
  TNT Token: 0x49f94d5515d43ff9e32b7101ba17b1f76ee74e95
  TangleMigration: 0xe3c3381d0f23166af129fa1fd7e8f370444128e9
  ZK Verifier: 0xd8ec641f843c937b952a29771e1f5fc8d5927ffa

Merkle Root: 0x54ec5497e0a2f43ec721c1ec5392cb224cf710b1210b579dcaefea002bb51adb

Frontend Environment Variables (.env.local):
  VITE_TNT_TOKEN_ADDRESS=0x49f94d5515d43ff9e32b7101ba17b1f76ee74e95
  VITE_TANGLE_MIGRATION_ADDRESS=0xe3c3381d0f23166af129fa1fd7e8f370444128e9
  VITE_ZK_VERIFIER_ADDRESS=0xd8ec641f843c937b952a29771e1f5fc8d5927ffa
  VITE_MIGRATION_MERKLE_ROOT=0x54ec5497e0a2f43ec721c1ec5392cb224cf710b1210b579dcaefea002bb51adb
```

---

## Step 5: Configure & Start Services

### Start Prover API

**Terminal 1:**

```bash
cd packages/migration-claim/sp1

PORT=8081 \
SP1_PROVER=network \
NETWORK_PRIVATE_KEY=<0x... - the private key for the account you deposited PROVE on Succinct> \
VERIFY_ONCHAIN=true \
VERIFY_ONCHAIN_RPC_URL=https://sepolia.base.org \
SP1_PROGRAM_VKEY=<0x... - the verification key you get from Step 3> \
cargo run -p tnt-claim-prover-api --release
```

### Claim Relayer Configuration

The claim relayer allows gasless claims by submitting transactions on behalf of users.

```bash
cd apps/claim-relayer

# Create .env file
cat > .env << EOF
PORT=3001
RPC_URL=https://sepolia.base.org
PRIVATE_KEY=0x<private key of the account to pay for the gas fees>
MIGRATION_CONTRACT=0x<Tangle Migration Contract address get from Step 4>
EOF
```

### Start Claim Relayer

**Terminal 2:**

```bash
cd apps/claim-relayer
pnpm dev
```

---

## Step 6: Run Local Frontend

Start the Tangle dApp frontend to test the claim functionality through the UI.

### Configure Environment Variables

Create or update the `.env.local` file in the frontend repository with the contract addresses from Step 4:

```bash
cd <frontend path>/apps/tangle-dapp

# Add deployed contract addresses to .env.local file on tangle-dapp
VITE_TNT_TOKEN_ADDRESS=0x<TNT Token address from Step 4>
VITE_TANGLE_MIGRATION_ADDRESS=0x<TangleMigration address from Step 4>
VITE_ZK_VERIFIER_ADDRESS=0x<ZK Verifier address from Step 4>
VITE_MIGRATION_MERKLE_ROOT=0x<Merkle Root from Step 4>
```

### Start Frontend

**Terminal 3:**

```bash
yarn start:tangle-dapp
```

### Access the Application

Once the development server is running, open your browser and navigate to:

```
http://localhost:4200
```

### Test Claim Functionality

1. Connect your wallet (MetaMask or other Web3 wallet)
2. Switch to the correct network (Base Sepolia)
3. Navigate to the claim page
4. Connect your Substrate wallet
5. Sign the challenge message with your SR25519 key
6. Wait for the ZK proof to be generated (2-5 minutes)
7. Submit the claim transaction
8. Verify tokens are received in your EVM wallet
