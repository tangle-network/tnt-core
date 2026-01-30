# TNT SP1 Prover API

Minimal HTTP wrapper around the SP1 prover for SR25519 migration claims.

## Endpoints

- `POST /` -> `{ jobId }`
- `GET /status/:jobId` -> `{ status, zkProof? , error? }`
- `GET /health` -> `{ status, prover_mode, verify_proof, jobs }`

## Environment

```env
PORT=8080
SP1_PROVER=network
NETWORK_PRIVATE_KEY=0x...
VERIFY_PROOF=false
VERIFY_ONCHAIN=false
VERIFY_ONCHAIN_RPC_URL=https://sepolia.base.org
SP1_VERIFIER_ADDRESS=0x397A5f7f3dBd538f23DE225B51f532c34448dA9B
SP1_PROGRAM_VKEY=0x...
ALLOW_MOCK=false
CORS_ALLOWED_ORIGINS=http://localhost:3000
```

`SP1_PROVER=network` uses the Succinct Prover Network. `NETWORK_PRIVATE_KEY` is required in that mode.
`VERIFY_ONCHAIN=true` performs an `eth_call` against the SP1 verifier gateway using the same public values, so no gas or funds are required (it uses `VERIFY_ONCHAIN_RPC_URL` or falls back to `RPC_URL`).
If `SP1_VERIFIER_ADDRESS` is omitted it defaults to `0x397A5f7f3dBd538f23DE225B51f532c34448dA9B` (Base Sepolia & Base Mainnet gateway). `SP1_PROGRAM_VKEY` is required when `VERIFY_ONCHAIN=true`.
`CORS_ALLOWED_ORIGINS` restricts which origins can access the API. Accepts comma-separated values (e.g., `https://app.tangle.tools,https://staging.tangle.tools`). If not set, all origins are allowed.

## Run (local)

```bash
cd packages/migration-claim/sp1
cargo run -p tnt-claim-prover-api --release
```

## Run (Docker)

From repo root:

```bash
docker build -f packages/migration-claim/sp1/prover-api/Dockerfile -t tnt-claim-prover-api .
docker run --rm -p 8080:8080 \
  -e SP1_PROVER=network \
  -e NETWORK_PRIVATE_KEY=0x... \
  -e SP1_PROGRAM_VKEY=0x... \
  -e VERIFY_ONCHAIN=true \
  -e VERIFY_ONCHAIN_RPC_URL=https://sepolia.base.org \
  -e CORS_ALLOWED_ORIGINS=https://app.tangle.tools \
  tnt-claim-prover-api
```

Or pull from GHCR (replace `ORG`):

```bash
docker run --rm -p 8080:8080 \
  -e SP1_PROVER=network \
  -e NETWORK_PRIVATE_KEY=0x... \
  -e SP1_PROGRAM_VKEY=0x... \
  -e VERIFY_ONCHAIN=true \
  -e VERIFY_ONCHAIN_RPC_URL=https://sepolia.base.org \
  -e CORS_ALLOWED_ORIGINS=https://app.tangle.tools \
  ghcr.io/ORG/tnt-claim-prover-api:latest
```
