# Genesis distributions

Provenance for the TNT genesis allocation. The protocol normalizes the raw Substrate migration
snapshot **down** to a clean **100,000,000 TNT** target (`TangleToken.MAX_SUPPLY`), so genesis mints
exactly the cap → true fixed supply. These files are the audit trail of that derivation; the raw
snapshot is preserved so the normalization is fully reproducible and swappable.

## Files

- **`raw-snapshot.json`** — the original, unnormalized Substrate migration snapshot (~109.26M TNT).
  History/provenance only; **not deployed**. Sourced from `packages/migration-claim/`.
- **`normalized-100m.json`** — the **live** genesis distribution. Total == 100M == `MAX_SUPPLY`.

## How the normalize-down works (two steps)

1. **Drop the expired OG airdrop claims** (`unclaimed-accounts.json`, 3,190,747.92 TNT). These had a
   1-year claim window on the Substrate chain that expired; they are **not allocated** at genesis (no
   decay, no re-add) and are already excluded from `merkle-tree.json`. OG grand total 109.26M → allocated
   106.06M.
2. **Reduce ONLY the Treasury bucket** to land on a round 100M. The active claimant buckets — Substrate
   (zk+merkle claims) and Foundation — are byte-identical to the raw snapshot (real obligations); active
   EVM is 0. Treasury is the protocol's own bucket and absorbs the rest:

```
treasury_normalized = 100,000,000 TNT − (substrate + evm + foundation)
                    = 100M − (49.32M + 0 + 15.04M) = 35,637,007.34 TNT
```

The total `109.26M → 100M` reduction (9,255,636.92 TNT) = **3,190,747.92 dropped-expired + 6,064,889.70
treasury-haircut**. No active claimant is affected. 1% annual emission is then a clean **1,000,000
TNT/yr**, treasury-funded (not minted). Run `python3 deploy/distributions/reconcile.py` to verify the
buckets sum to exactly 100M.

## Swapping / regenerating

`MAX_SUPPLY` (100M) is fixed in the contract. The amounts here are taken from the current
`packages/migration-claim/` outputs (`merkle-tree.json` block 8116528, treasury/foundation carveouts,
empty `evm-claims.json`, expired set excluded). The expired-unclaimed policy is **decided: not
allocated** — there is no decay knob. When the canonical mainnet snapshot is confirmed/regenerated:

1. Update Substrate/EVM/Foundation in `normalized-100m.json` from the regenerated
   `merkle-tree.json` + carveouts (expired stays excluded).
2. Recompute `treasury = 100M − (substrate + evm + foundation)` — Treasury is always the balancing bucket.
3. Mirror the four amounts into `deploy/config/base-mainnet.json` `migration.*` (and the carveout files),
   set `migration.deploy: true`, pin `merkleRoot` + `programVKey`.
4. Run `python3 deploy/distributions/reconcile.py` — it fails unless the buckets sum to exactly 100M.

The 100M total and `MAX_SUPPLY` never change; only the split inside the 100M envelope does. To revert to
the un-normalized snapshot you would deploy `raw-snapshot.json`'s amounts and set `MAX_SUPPLY` to its
total — kept here precisely so that remains possible and auditable.
