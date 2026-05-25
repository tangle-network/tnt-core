# Envio HyperIndex v2.32.3 → v3.0.2 Migration Report

## Scope

Migrated `indexer/` from `envio@2.32.3` to `envio@3.0.2` per the
[official v3 migration guide](https://docs.envio.dev/docs/HyperIndex/migrate-to-v3).
114 event handlers + 2 block handlers + 6 `getWhere` query sites + 1 dynamic
contract registration converted. All TypeScript builds clean, all 5 unit tests
pass (`vitest run`), and `envio codegen` produces a valid `.envio/types.d.ts`.

## What changed

### Tooling

- `indexer/package.json`
  - `envio: ^2.32.3` → `^3.0.0` (resolves to `3.0.2`).
  - `engines.node: >=18.0.0` → `>=22.0.0` (v3 requires Node 22+).
  - `type: "commonjs"` → `"module"` (v3 ships ESM-only).
- `indexer/tsconfig.json`
  - `module: commonjs` → `esnext`; added `moduleResolution: bundler`.
  - `target/lib: es2020` → `es2022`.
  - Dropped `paths: { generated, generated/* }` — v3 no longer emits a
    `generated/` package; types now flow through the `envio` module via
    declaration merging.
  - `include` now picks up `envio-env.d.ts` and `.envio/**/*.d.ts`.
  - `exclude` no longer ignores `src/handlers` (v2 carried this exclusion
    because the v2 codegen target paralleled handlers — v3 does not).
- `indexer/.envio/` directory now exists. It contains `.gitignore` (envio
  writes one to keep `types.d.ts` out of git) and the generated
  `types.d.ts` (~175 KB, gitignored).
- `indexer/envio-env.d.ts` is a small generated stub that loads
  `.envio/types.d.ts` into the `envio` module. **Checked in.**

### Config

- `indexer/config.yaml` and `indexer/config.local.yaml`
  - `networks:` → `chains:` (v3 rename).
  - Per-chain `rpc_config: { url }` → `rpc: [{ url }]` (v3 list-of-rpcs).
  - Removed `unordered_multichain_mode: true` (no longer a v3 key; default
    behaviour is already unordered).
  - Removed `preload_handlers: true` (v3 default; key no longer supported).

### Handler API conversion

Bulk-converted via a Python re.MULTILINE substitution for safety; per-file
totals:

| File | Handlers |
|------|----------|
| `src/handlers/blueprintManager.ts` | 1 |
| `src/handlers/credits.ts` | 1 |
| `src/handlers/rewardVaults.ts` | 14 |
| `src/handlers/validatorPods.ts` | 10 |
| `src/handlers/staking.ts` | 32 |
| `src/handlers/liquidDelegation.ts` | 6 |
| `src/handlers/tangle.ts` | 50 |
| **Total** | **114** |

Each handler went from:

```ts
import { ContractName } from "generated";
ContractName.EventName.handler(async ({ event, context }) => { ... });
```

to:

```ts
import { indexer } from "envio";
indexer.onEvent({ contract: "ContractName", event: "EventName" },
  async ({ event, context }) => { ... });
```

### Block handlers

`src/handlers/hourly.ts` rewritten. The v2 `onBlock({ name, chain, interval })`
became `indexer.onBlock({ name, where })`. Chain filtering moved into the
`where` callback (`where: ({ chain }) => chain.id !== INDEXER_CHAIN_ID ? false
: { block: { number: { _every: HOURLY_BLOCK_INTERVAL } } }`). The old
`generated/src/Types.gen` chain alias was dropped — v3 chain IDs are plain
numbers.

### Query API (`getWhere`)

6 call sites converted via a small AST-aware Python pass that respects nested
parentheses:

```ts
// v2
await context.LiquidRedeemRequest.getWhere.vault_id.eq(vaultId)
// v3
await context.LiquidRedeemRequest.getWhere({ vault_id: { _eq: vaultId } })
```

Touched files:
- `src/handlers/liquidDelegation.ts` (1, vault redemption lookup)
- `src/lib/handlerUtils.ts` (1, delegator vault positions)
- `src/points/participation.ts` (4, position + membership lookups)

The mock store in `src/points/participation.test.ts` was upgraded from the
v2 fluent `.getWhere.<field>.eq(...)` proxy to a v3-shaped GraphQL filter
function that recognises `_eq`. All 3 tests in that file still pass.

### Dynamic contract registration (LiquidDelegationFactory → LiquidDelegationVault)

Added a v3-native `indexer.contractRegister({ contract:
"LiquidDelegationFactory", event: "VaultCreated" }, ...)` that calls
`context.chain.LiquidDelegationVault.add(vaultAddress)`. The legacy inline
`(context as any).contracts.addLiquidDelegationVault(...)` try/catch is
preserved (now reaching through `context.chain`) so existing handler-time
adds still work if the factory event is replayed.

### Type imports

Replaced `from "generated/src/Types.gen"` with `from "envio"` across 12
files (`src/handlers/*.ts`, `src/lib/handlerUtils.ts`, `src/points.ts`,
`src/points/participation.ts`, `src/points/programs.ts`,
`src/points/__tests__/points.test.ts`). v3 augments the `envio` module with
project entity types, so every `RewardVault`, `Operator`, `JobCall`, etc.
import resolves through the augmentation.

### Type-system fix

`JobCall` in v3 lists `completedAt` as a non-optional field (it can be
`undefined`, but the property must be present on the object literal that's
cast `as JobCall`). The `JobSubmittedFromQuote` handler in
`src/handlers/tangle.ts` now explicitly sets `completedAt: undefined`.

## Verification

```
$ pnpm install        # envio 3.0.2 + envio-linux-x64@3.0.2 resolved
$ pnpm run codegen    # exit 0, .envio/types.d.ts written (~175 KB)
$ pnpm run typecheck  # exit 0, no errors
$ pnpm run build      # exit 0, tsc --build clean
$ pnpm run test       # 3 files, 5 tests passing in ~250 ms
```

## What I did not do

- **No schema.graphql changes.** v3 codegen consumed the existing schema
  without complaint; entity shapes are unchanged.
- **No `createTestIndexer` smoke test.** The repo's existing unit tests
  (`vitest`) exercise the pure helpers and the participation accounting
  with in-memory stores. Adding `createTestIndexer` would require
  duplicating that wiring with a postgres backend (or its in-memory
  equivalent) for marginal value; punted.
- **No `full_batch_size`, `block_lag`, or `max_reorg_depth` tuning.**
  Defaults inherited; revisit if backfill speed regresses.
- **ClickHouse storage** — not enabled; `postgres: true` remains the only
  storage backend.
- **`ENVIO_API_TOKEN`** — required at runtime for HyperSync but not at
  codegen / typecheck / build / test time, so the migration completes
  without one. Configure in your deploy environment before `envio start`.
- **`envio dev` / `envio start` smoke run.** Requires Postgres + Docker;
  not exercised in this migration.

## Known follow-ups (not blocking)

- `pnpm` reports 2 deprecated transitive subdependencies pulled in by
  envio (`@fuel-ts/interfaces@0.96.1`, `string-similarity@4.0.4`). Upstream.
- `package-lock.json` is still in the tree alongside `pnpm-lock.yaml`. v3
  ran via pnpm so the npm lockfile is stale; consider deleting it in a
  follow-up.
