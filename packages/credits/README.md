# Credits (Merkle Claims)

This package provides a standalone, protocol-independent credits claim contract plus off-chain tooling to:

- Compute per-epoch TNT-delegation credit entitlements off-chain.
- Publish a Merkle root on-chain.
- Let users claim once per epoch and emit `CreditsClaimed` for downstream systems (indexer + product backend).

## Contracts

- `src/Credits.sol`: Merkle-root based claim registry (no token transfers).

### Merkle format

Each Merkle value is `(uint256 epochId, address account, uint256 amount)`.

Leaf hash (matches the contract):
`keccak256(bytes.concat(keccak256(abi.encode(epochId, account, amount))))`

The contract verifies proofs via OpenZeppelin `MerkleProof` (sorted pairs).

## Scripts

Scripts live in `packages/credits/scripts`.

### End-to-end (compute → tree → publish)

- `cd packages/credits/scripts && npm i`
- `GRAPHQL_URL=http://localhost:8080/v1/graphql \`
  `RPC_URL=... PRIVATE_KEY=... CREDITS_ADDRESS=0x... \`
  `npx ts-node runEpoch.ts --epoch-id 1 --tnt-token 0xYourTNT --credits-per-tnt 1 --out ../credits-tree.json --publish`

You can also pass `--manifest deployments/<network>/latest.json` to reuse the `tntToken` and `credits` addresses written by `FullDeploy`.

### Generate a Merkle tree

1) Install deps:
- `cd packages/credits/scripts && npm i`

2) Generate:
- `npx ts-node generateMerkleTree.ts --epoch-id 1 --input ./entitlements.json --output ../credits-tree.json`

Input format (`entitlements.json`):
```json
[
  { "account": "0x...", "amount": "1230000000000000000" }
]
```

### Compute entitlements from the indexer

This uses the indexer’s current `DelegationPosition` state for the TNT token (snapshot-based).

- `GRAPHQL_URL=http://localhost:8080/v1/graphql \`
  `npx ts-node computeEntitlementsFromIndexer.ts --tnt-token 0xYourTNT --credits-per-tnt 1 --output ./entitlements.json`

Or, if you have a `FullDeploy` manifest:
- `GRAPHQL_URL=... npx ts-node computeEntitlementsFromIndexer.ts --manifest ../../deployments/base-sepolia/latest.json --credits-per-tnt 1 --output ./entitlements.json`

### Publish a root on-chain

- `npx ts-node publishRoot.ts --epoch-id 1 --root 0x...`

Env vars required:
- `RPC_URL`
- `PRIVATE_KEY`
- `CREDITS_ADDRESS`

### Watch claims

- `npx ts-node watchClaims.ts`

Env vars:
- `RPC_URL`
- `CREDITS_ADDRESS`

## Testing

- `cd packages/credits && forge test`
