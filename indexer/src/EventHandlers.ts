/**
 * Indexer entrypoint. In v3, handler files self-register at module load —
 * `indexer.onEvent({...}, ...)` and `indexer.onBlock({...}, ...)` calls at
 * module top level append to a global registration table the runtime
 * consumes during boot. So this file's only job is to import each handler
 * module for its side effects.
 *
 * Files are imported in dependency order: blueprint metadata first (so the
 * tangle/staking handlers can reference resolved blueprint identity), then
 * the transactional surface, then liquid-delegation (which depends on
 * staking entities), then the block-tick handlers last.
 */
import "./handlers/blueprintManager";
import "./handlers/credits";
import "./handlers/rewardVaults";
import "./handlers/staking";
import "./handlers/tangle";
import "./handlers/validatorPods";
import "./handlers/liquidDelegation";
import "./handlers/hourly";
