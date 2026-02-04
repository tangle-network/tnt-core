# KiteAI Testnet Deployment & Testing Guide

This guide walks through deploying the Tangle Migration contracts to KiteAI Testnet and testing claims with the Alice test account.

## KiteAI Testnet Info

- **Chain ID:** 2368
- **RPC URL:** https://rpc-testnet.gokite.ai/
- **Block Explorer:** https://testnet.kitescan.ai/
- **Native Token:** KITE
- **Faucet:** https://faucet.gokite.ai

## Alice Test Account

Alice is included in the merkle tree for testing:

- **SS58 Address:** `tgGmBRR5yM53bvq8tTzgsUirpPtfCXngYYU7uiihmWFJhmYGM`
- **Public Key:** `0xd43593c715fdd31c61141abd04a99fd6822c8558854ccde39a5684e7a56da27d`
- **Balance:** `5009550328826873592` wei (~5.01 TNT)

## Prerequisites

1. **Tools:**
   - Foundry (`forge`, `cast`)
   - Rust with SP1 toolchain (`cargo prove`)
   - Node.js 18+
   - `jq` for JSON processing

2. **Accounts:**
   - Deployer wallet with KITE tokens (get from faucet)
   - Relayer wallet with KITE tokens for gas

3. **SP1 Prover:**
   - SP1 Prover Network access (or use mock verifier for testing)

## Step 1: Deploy SP1 Infrastructure

KiteAI doesn't have a pre-deployed SP1 verifier, so we deploy our own.

```bash
cd packages/migration-claim

# Get KITE tokens for deployer from faucet
# https://faucet.gokite.ai

# Deploy SP1 Gateway + Verifier
PRIVATE_KEY=0x... \
RPC_URL=https://rpc-testnet.gokite.ai/ \
  ./scripts/deploy-sp1-gateway.sh
```

Save the `SP1VerifierGateway` address from the output.

## Step 2: Build SP1 Program & Get VKey

```bash
cd sp1/program

# Build the SP1 program
cargo prove build

# Get the verification key
cd ..
cargo +succinct run --release -p sr25519-claim-script --bin vkey
```

Save the `PROGRAM_VKEY` from the output.

## Step 3: Deploy Migration Contracts

The migration includes token allocations for the foundation and liquidity operations. For testnet, use your deployer address as the recipient for both.

```bash
cd packages/migration-claim

PRIVATE_KEY=0x... \
PROGRAM_VKEY=0x<from-step-2> \
SP1_VERIFIER=0x<gateway-from-step-1> \
FOUNDATION_RECIPIENT=0x<your-deployer-address> \
LIQUIDITY_OPS_RECIPIENT=0x<your-deployer-address> \
  ./scripts/deploy-tangle-migration.sh --kite
```

**Environment variables:**
- `FOUNDATION_RECIPIENT`: EVM address to receive foundation tokens (~15M TNT)
- `LIQUIDITY_OPS_RECIPIENT`: EVM address to receive liquidity/ops tokens (5M TNT)

Save the deployed addresses:
- `TNT_TOKEN`
- `MIGRATION_CONTRACT`

## Step 4: Start the Prover API

For testing, you can use mock mode:

```bash
cd sp1/prover-api

# Mock mode (no real ZK proofs)
SP1_PROVER=mock \
ALLOW_MOCK=true \
  cargo run --release
```

For production proofs:

```bash
cd sp1/prover-api

# Network mode (requires SP1 Prover Network access)
SP1_PROVER=network \
NETWORK_PRIVATE_KEY=0x... \
VERIFY_PROOF=true \
CORS_ALLOWED_ORIGINS=http://localhost:3000 \
  cargo run --release
```

**Environment variables for network mode:**
- `NETWORK_PRIVATE_KEY`: Your SP1 Prover Network private key
- `VERIFY_PROOF=true`: Required for production safety
- `CORS_ALLOWED_ORIGINS`: Allowed origins (e.g., your frontend URL)

The prover API runs on `http://localhost:8080`.

## Step 5: Start the Claim Relayer

```bash
cd apps/claim-relayer

npm install

RELAYER_PRIVATE_KEY=0x... \
RPC_URL=https://rpc-testnet.gokite.ai/ \
CHAIN_ID=2368 \
MIGRATION_CONTRACT=0x<from-step-3> \
  npm run dev
```

The relayer runs on `http://localhost:3001`.

## Step 6: Test Claim as Alice

### 6.1 Generate the Challenge

The challenge is `keccak256(abi.encode(contractAddress, chainId, recipient, amount))`:

```bash
# Variables
CONTRACT=0x<migration-contract>
CHAIN_ID=2368
RECIPIENT=0x<your-evm-address>
AMOUNT=5009550328826873592

# Generate challenge
CHALLENGE=$(cast keccak256 $(cast abi-encode "f(address,uint256,address,uint256)" $CONTRACT $CHAIN_ID $RECIPIENT $AMOUNT))
echo "Challenge: $CHALLENGE"
```

### 6.2 Sign with Alice's Key

Using `subkey` (from Substrate):

```bash
# Sign the challenge with Alice's key
# Alice's dev seed: "//Alice"
SIGNATURE=$(subkey sign --suri "//Alice" --message-hex ${CHALLENGE#0x})
echo "Signature: 0x$SIGNATURE"
```

### 6.3 Get Merkle Proof

```bash
# Extract Alice's merkle proof
ALICE_SS58="tgGmBRR5yM53bvq8tTzgsUirpPtfCXngYYU7uiihmWFJhmYGM"
MERKLE_PROOF=$(jq -r ".entries[\"$ALICE_SS58\"].proof | @json" merkle-tree.json)
echo "Merkle Proof: $MERKLE_PROOF"
```

### 6.4 Request ZK Proof from Prover

```bash
curl -X POST http://localhost:8080 \
  -H "Content-Type: application/json" \
  -d '{
    "pubkey": "0xd43593c715fdd31c61141abd04a99fd6822c8558854ccde39a5684e7a56da27d",
    "signature": "0x<signature-from-6.2>",
    "recipient": "'$RECIPIENT'",
    "amount": "'$AMOUNT'",
    "chain_id": 2368,
    "contract_address": "'$CONTRACT'"
  }'
```

Save the `proof` from the response.

### 6.5 Submit Claim via Relayer

```bash
curl -X POST http://localhost:3001/claim \
  -H "Content-Type: application/json" \
  -d '{
    "pubkey": "0xd43593c715fdd31c61141abd04a99fd6822c8558854ccde39a5684e7a56da27d",
    "amount": "'$AMOUNT'",
    "merkleProof": '$MERKLE_PROOF',
    "zkProof": "0x<proof-from-6.4>",
    "recipient": "'$RECIPIENT'"
  }'
```

### 6.6 Verify Claim

Check recipient's TNT balance:

```bash
cast call $TNT_TOKEN "balanceOf(address)" $RECIPIENT \
  --rpc-url https://rpc-testnet.gokite.ai/
```

Check claim status:

```bash
curl http://localhost:3001/status/0xd43593c715fdd31c61141abd04a99fd6822c8558854ccde39a5684e7a56da27d
```

## Troubleshooting

### "RouteNotFound" Error

The SP1 verifier route wasn't added. Ensure the gateway owner called `addRoute()`:

```bash
cast send $SP1_GATEWAY "addRoute(address)" $SP1_VERIFIER \
  --private-key $OWNER_PRIVATE_KEY \
  --rpc-url https://rpc-testnet.gokite.ai/
```

### "InvalidZKProof" Error

- Check the proof was generated for the correct chain ID (2368)
- Check the contract address matches
- Verify the signature is valid for Alice's pubkey

### "InvalidMerkleProof" Error

- Verify Alice's entry exists in merkle-tree.json
- Ensure the amount matches exactly
- Check the pubkey format (0x + 64 hex chars)

### Relayer Returns 429

Rate limit hit. Wait 60 seconds and try again.

### Low KITE Balance

Get more KITE tokens from the faucet: https://faucet.gokite.ai

## Quick Reference

| Component | URL/Address |
|-----------|-------------|
| RPC | https://rpc-testnet.gokite.ai/ |
| Explorer | https://testnet.kitescan.ai/ |
| Faucet | https://faucet.gokite.ai |
| Prover API | http://localhost:8080 |
| Claim Relayer | http://localhost:3001 |

## Environment Variables Summary

```bash
# Deployer
export PRIVATE_KEY=0x...
export PROGRAM_VKEY=0x...
export SP1_VERIFIER=0x...
export FOUNDATION_RECIPIENT=0x...      # Receives ~15M TNT (use deployer address for testnet)
export LIQUIDITY_OPS_RECIPIENT=0x...   # Receives 5M TNT (use deployer address for testnet)

# Relayer
export RELAYER_PRIVATE_KEY=0x...
export RPC_URL=https://rpc-testnet.gokite.ai/
export CHAIN_ID=2368
export MIGRATION_CONTRACT=0x...

# Prover (mock mode for testing)
export SP1_PROVER=mock
export ALLOW_MOCK=true

# Prover (network mode for production)
export SP1_PROVER=network
export NETWORK_PRIVATE_KEY=0x...
export VERIFY_PROOF=true
export CORS_ALLOWED_ORIGINS=http://localhost:3000
```
