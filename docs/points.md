## Points Allocation Overview

All reward programs are defined in `indexer/src/points/programs.ts`. Each entry specifies an id, category, description, and weight. The current programs are grouped by persona:

| Program ID | Description | Category | Weight |
|------------|-------------|----------|--------|
| `developer-blueprint` | Creating or defining blueprints (core + MBSM) | BONUS | 100 |
| `customer-service` | Requesting or activating services | SERVICE | 25 / 50 |
| `customer-escrow` | Funding service escrows (amount‑scaled) | SERVICE | 4 |
| `service-activity` | Submitting jobs / aggregates | SERVICE | 2 |
| `operator-registration` | Registering validator operators | OPERATOR | 100 |
| `operator-stake` | Increasing operator stake | OPERATOR | 10 |
| `operator-uptime` | Heartbeat reports | OPERATOR | 1 |
| `operator-service` | Joining a service | OPERATOR | 15 |
| `operator-service-hourly` | Staying in services (hourly, √active services) | OPERATOR | 1 |
| `operator-hourly` | General operator uptime (stake-based) | OPERATOR | 1 |
| `delegator-deposit` | Depositing restaking assets | DELEGATOR | 5 |
| `delegation` | Delegating stake (MultiAsset + native pods) | DELEGATOR | 8 |
| `restaker-vault` | Staking via reward vaults or liquid delegation vaults | DELEGATOR | 6 |
| `native-pod` | Creating validator pods | DELEGATOR | 25 |
| `delegator-hourly` | Hourly delegation participation | DELEGATOR | 1 |
| `service-hourly` | Active services (owner participation) | SERVICE | 1 |

Hourly participation awards are driven by `indexer/src/points/participation.ts`, which computes a USD-scaled basis for each category before converting to points via `toPointsValue`. For operator service uptime we take the square root of the number of active services (min 1) so that running more services has diminishing returns rather than scaling linearly.

The hourly worker is registered in `handlers/hourly.ts`. Every `HOURLY_BLOCK_INTERVAL` blocks it loads the `HOURLY_PROGRAMS` array, pulls every active `ParticipationState`, and awards `operator-hourly`, `operator-service-hourly`, `delegator-hourly`, and `service-hourly` based on the USD basis that `participation.ts` calculates. When an entity leaves the participation set (operator leaves a service, delegator exits, etc.), the relevant handler calls `deactivateParticipation` so the hourly loop stops awarding points automatically.

### Award Hooks

Reusable award helpers live in `indexer/src/points/awards.ts`. Contract handler modules invoke these helpers when specific events fire (see `indexer/src/handlers/*.ts`). The helpers encode the exact amounts noted above so reviewers can audit a single file instead of scanning every handler.

Every helper uses the constants defined at the top of `awards.ts`. To update the award amounts:

1. Edit the constants (e.g., `SERVICE_REQUEST_BONUS`) and rerun `pnpm typecheck` / `pnpm test`.
2. If you need a new program, add it to `points/programs.ts` (keeping the table above in sync) and create a helper that references it.
3. Wire that helper into the appropriate handler module.

### Testing

We added a lightweight test (`src/points/__tests__/points.test.ts`) that exercises `PointsManager.award` to ensure new programs initialize correctly. Run it via:

```bash
cd indexer
pnpm test
```

Extend this suite if you tweak conversion logic (`math.ts`) or add more award helpers.
