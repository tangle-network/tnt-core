# Genesis distributions

Provenance for the TNT genesis allocation. The protocol normalizes the raw Substrate migration
snapshot **down** to a clean **100,000,000 TNT** target (`TangleToken.MAX_SUPPLY`), so genesis mints
exactly the cap → true fixed supply. These files are the audit trail of that derivation; the raw
snapshot is preserved so the normalization is fully reproducible and swappable.

## Files

- **`raw-snapshot.json`** — the original, unnormalized Substrate migration snapshot (~109.26M TNT).
  History/provenance only; **not deployed**. Sourced from `packages/migration-claim/`.
- **`normalized-100m.json`** — the **live** genesis distribution. Total == 100M == `MAX_SUPPLY`.

## How the normalize-down works

Only the **Treasury** bucket changes. The three claimant buckets — Substrate (zk+merkle claims), EVM,
and Foundation — are byte-identical to the raw snapshot because they are real obligations to real
holders. The Treasury is the protocol's own bucket and absorbs the entire reduction:

```
treasury_normalized = 100,000,000 TNT − (substrate + evm + foundation)
```

The reduction equals exactly `109.26M − 100M = 9,255,636.92 TNT` removed from Treasury. No claimant is
affected. 1% annual emission is then a clean **1,000,000 TNT/yr**, treasury-funded (not minted).

## Swapping / regenerating

`MAX_SUPPLY` (100M) is fixed in the contract. The claimant amounts are **estimates pending the
canonical mainnet snapshot regen** (the Sepolia config and the raw `merkle-tree.json` differ slightly,
and ~3.19M expired-unclaimed needs the 90%-decay decision). When the canonical snapshot is regenerated:

1. Update Substrate/EVM/Foundation in `normalized-100m.json` from the regenerated
   `merkle-tree.json` + carveouts.
2. Recompute `treasury = 100M − (substrate + evm + foundation)` — Treasury is always the balancing bucket.
3. Mirror the four amounts into `deploy/config/base-mainnet.json` `migration.*` (and the carveout files),
   set `migration.deploy: true`, pin `merkleRoot` + `programVKey`.

The 100M total and `MAX_SUPPLY` never change; only the split inside the 100M envelope does. To revert to
the un-normalized snapshot you would deploy `raw-snapshot.json`'s amounts and set `MAX_SUPPLY` to its
total — kept here precisely so that remains possible and auditable.
