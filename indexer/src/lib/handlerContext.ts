/**
 * Re-export of the v3 handler context type, aliased to the short name we use
 * across helper functions. Centralizing this lets us swap `EvmOnEventContext`
 * for a project-specific narrower type (or add a wrapper) without rewriting
 * every helper signature.
 *
 * `EvmOnEventContext` is the union of base context (log/effect/isPreload/
 * chain) and every entity's operations (get/set/getOrThrow/getWhere/...).
 * `EvmOnBlockContext` is an alias of the same shape — onBlock handlers receive
 * the same context as onEvent handlers minus the per-event params.
 *
 * Replaces the dozens of `context: any` signatures the mechanical v2→v3
 * migration left in helper code (entity-level helpers in `handlers/*` and
 * `points/*`, the participation tracker, the price refresher).
 */
import type { AssetPrice, AssetPriceSample, EvmOnEventContext } from "envio";

export type HandlerContext = EvmOnEventContext;

/**
 * Narrow context type for the price helpers (`prices.ts`) and anything that
 * threads through them (`convertAmountToUsd` in `participation.ts`). They
 * only read AssetPrice and write AssetPriceSample — exposing the whole
 * `HandlerContext` from a backfill script or unit test would force the
 * caller to fabricate ~75 entity-op records they never touch.
 *
 * Production handlers pass `HandlerContext`, which is assignable to
 * `PriceContext` because the entity-op shapes match.
 */
export type PriceContext = {
  readonly AssetPrice: {
    readonly get: (id: string) => Promise<AssetPrice | undefined | null>;
    readonly set: (entity: AssetPrice) => void;
  };
  readonly AssetPriceSample: {
    readonly set: (entity: AssetPriceSample) => void;
  };
};
