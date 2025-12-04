# TanglePod CLI

Command-line tool for generating beacon chain proofs for TanglePod contracts.

## Who Is This For?

**Ethereum validators who want to restake** their beacon chain ETH through Tangle's restaking protocol. Similar to EigenLayer's `eigenpod-proofs-generation` tool.

**Use cases:**
- **Stakers**: Prove your validators' withdrawal credentials point to your TanglePod
- **Pod Operators**: Submit checkpoint proofs to sync validator balances
- **Third Parties**: Enforce slashing when validators are slashed on beacon chain

## Quick Start

```bash
# Build
cd script/tanglepod-cli
go build -o tanglepod-cli .

# Check validator status (works without beacon node)
./tanglepod-cli status --network holesky --validators 100000,200000

# Check mainnet validators
./tanglepod-cli status --network mainnet --validators 1000000
```

## Commands

### status

Check validator status using beaconcha.in API (no beacon node required):

```bash
# Check Holesky validators
./tanglepod-cli status --network holesky --validators 100000,200000

# Check mainnet validators
./tanglepod-cli status --network mainnet --validators 1000000

# Check pod status (requires beacon node)
./tanglepod-cli status --beaconNode http://localhost:5052 --podAddress 0x...
```

### credentials

Generate withdrawal credential proofs for restaking validators:

```bash
./tanglepod-cli credentials \
  --beaconNode http://localhost:5052 \
  --podAddress 0x1234... \
  --validators 123456,789012 \
  --output credential_proof.json
```

### checkpoint

Generate checkpoint proofs to sync validator balances:

```bash
./tanglepod-cli checkpoint \
  --beaconNode http://localhost:5052 \
  --podAddress 0x1234... \
  --validators 123456,789012 \
  --output checkpoint_proof.json
```

### stale-balance

Generate proof for slashing enforcement when a validator is slashed:

```bash
./tanglepod-cli stale-balance \
  --beaconNode http://localhost:5052 \
  --podAddress 0x1234... \
  --validator 123456 \
  --output stale_balance_proof.json
```

## Network Support

| Network | Status Command | Proof Generation |
|---------|---------------|------------------|
| Mainnet | ✅ beaconcha.in | Requires beacon node |
| Holesky | ✅ beaconcha.in | Requires beacon node |
| Sepolia | ✅ beaconcha.in | Requires beacon node |

## Beacon Node Requirements

**The `status --validators` command works without a beacon node** (uses beaconcha.in API).

**For proof generation**, you need a beacon node with full state API access:

1. **Run your own node**: Lighthouse, Prysm, Teku, Nimbus, or Lodestar
2. **Paid providers**: QuickNode, Infura, Alchemy
3. **Lodestar prover**: Use `--use-prover` flag with Lodestar

**Why no free public endpoints?**
Full state SSZ (`/eth/v2/debug/beacon/states`) is ~100MB+ and resource-intensive. No free public APIs provide this.

### Beacon Node Setup

```bash
# Lighthouse
lighthouse bn --http --http-enable-debug-endpoints

# Prysm
prysm beacon-chain --grpc-gateway-enabled

# Lodestar
lodestar beacon --api.rest.enabled
```

## Output Format

Proofs are output as JSON compatible with TanglePod contract calls:

```json
{
  "beaconTimestamp": 1704067200,
  "beaconBlockRoot": "0x...",
  "stateRootProof": {
    "beaconStateRoot": "0x...",
    "proof": ["0x...", "0x...", "0x..."]
  },
  "validatorProofs": [
    {
      "validatorIndex": 123456,
      "validatorFields": ["0x...", ...],
      "proof": ["0x...", ...]
    }
  ]
}
```

## Using with Foundry

```solidity
string memory json = vm.readFile("credential_proof.json");
uint64 timestamp = uint64(json.readUint(".beaconTimestamp"));
bytes32 blockRoot = json.readBytes32(".beaconBlockRoot");
// ... parse and submit to TanglePod
```

## Features

- [x] Network selection (mainnet, holesky, sepolia)
- [x] Status queries via beaconcha.in (no beacon node needed)
- [x] EIP-4788 beacon root validation
- [x] Full beacon state SSZ parsing
- [x] Merkle proof generation for validators and balances
- [x] Support for 0x01 and 0x02 (Pectra compounding) credentials

## Architecture

```
tanglepod-cli/
├── cmd/
│   ├── root.go           # CLI root + network config
│   ├── credentials.go    # Withdrawal credential proofs
│   ├── checkpoint.go     # Checkpoint proofs
│   ├── status.go         # Validator/pod status (beaconcha.in)
│   └── stale_balance.go  # Stale balance proofs
├── pkg/
│   ├── proofs/
│   │   ├── types.go      # Proof data structures
│   │   └── generator.go  # Proof generation logic
│   ├── ssz/
│   │   ├── types.go      # SSZ types (Validator, etc.)
│   │   ├── state.go      # Beacon state parsing
│   │   └── merkle.go     # Merkle tree implementation
│   └── execution/
│       └── client.go     # EIP-4788 beacon root oracle
├── main.go
├── go.mod
└── README.md
```

## Development

```bash
# Build
go build -o tanglepod-cli .

# Test
go test ./...

# Format
go fmt ./...
```
