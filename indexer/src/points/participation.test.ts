import { describe, expect, it } from "vitest";

import { ZERO_ADDRESS } from "../lib/handlerUtils";
import { registerAssetMetadata } from "./assets";
import { PointsManager } from "../points";
import { convertAmountToUsd, pointsContext, processParticipation } from "./participation";
import { PRICE_SCALE } from "./prices";

const createStore = <T extends { id: string }>(initial: T[] = []) => {
  const map = new Map(initial.map((entity) => [entity.id, entity]));
  return {
    async get(id: string) {
      return map.get(id);
    },
    set(entity: T) {
      map.set(entity.id, entity);
    },
    getWhere: new Proxy(
      {},
      {
        get: (_target, field: string) => ({
          eq: async (value: unknown) => {
            const matches: T[] = [];
            map.forEach((entity) => {
              if ((entity as any)[field] === value) {
                matches.push(entity);
              }
            });
            return matches;
          },
        }),
      }
    ),
    values: () => Array.from(map.values()),
  };
};

describe("convertAmountToUsd", () => {
  it("resolves derived assets using fallback prices", async () => {
    registerAssetMetadata({
      address: "0xbase",
      symbol: "BASE",
      decimals: 18,
      fallbackPriceUsd: 2,
      category: "RESTAKING",
    });
    registerAssetMetadata({
      address: "0xvault",
      symbol: "VAULT",
      decimals: 18,
      category: "VAULT",
      derivedFrom: "0xbase",
      derivedScale: 1.5,
    });
    const context = {
      AssetPrice: {
        async get() {
          return null;
        },
        set() {
          return undefined;
        },
      },
      AssetPriceSample: {
        set() {
          return undefined;
        },
      },
    };
    const usdValue = await convertAmountToUsd(context, 10n ** 18n, "0xvault", 1n, 1n);
    expect(usdValue).toEqual(3n * 10n ** 18n);
  });
});

describe("processParticipation", () => {
  it("records usdBasis on snapshots and hourly totals", async () => {
    const participationState = createStore([
      {
        id: "delegator-hourly:0xabc",
        entityId: "0xabc",
        program_id: "delegator-hourly",
        category: "DELEGATOR",
        active: true,
        lastAwardAt: 0n,
      } as any,
    ]);
    const context: any = {
      PointsProgram: createStore(),
      PointsAccount: createStore(),
      PointsEvent: createStore(),
      PointsSnapshot: createStore(),
      PointsHourlyTotal: createStore(),
      ParticipationState: participationState,
      Delegator: createStore([
        { id: "0xabc", totalDeposited: 0n, totalDelegated: 0n } as any,
      ]),
      DelegatorAssetPosition: createStore([
        {
          id: "position-1",
          delegator_id: "0xabc",
          token: ZERO_ADDRESS,
          totalDeposited: 5n * 10n ** 18n,
        } as any,
      ]),
      LiquidVaultPosition: createStore(),
      LiquidDelegationVault: createStore(),
      AssetPrice: {
        async get() {
          return { price: PRICE_SCALE };
        },
      },
      AssetPriceSample: {
        set() {
          return undefined;
        },
      },
    };
    const points = new PointsManager(pointsContext(context), 10n, 3600n, "0xtest");
    await processParticipation(context, "delegator-hourly", 10n, 3600n, points);
    const snapshots = context.PointsSnapshot.values();
    expect(snapshots).toHaveLength(1);
    expect(snapshots[0].usdBasis).toEqual(5n * 10n ** 18n);
    const hourlyTotals = context.PointsHourlyTotal.values();
    expect(hourlyTotals).toHaveLength(1);
    expect(hourlyTotals[0].usdBasis).toEqual(5n * 10n ** 18n);
    expect(hourlyTotals[0].hourTimestamp).toEqual(3600n);
  });

  it("scales operator service hourly points using sqrt of active services", async () => {
    const participationState = createStore([
      {
        id: "operator-service-hourly:0xop",
        entityId: "0xop",
        program_id: "operator-service-hourly",
        category: "OPERATOR",
        active: true,
        lastAwardAt: 0n,
      } as any,
    ]);
    const context: any = {
      PointsProgram: createStore(),
      PointsAccount: createStore(),
      PointsEvent: createStore(),
      PointsSnapshot: createStore(),
      PointsHourlyTotal: createStore(),
      ParticipationState: participationState,
      ServiceOperator: createStore([
        { id: "s1-0xop", operator_id: "0xop", service_id: "s1", active: true } as any,
        { id: "s2-0xop", operator_id: "0xop", service_id: "s2", active: true } as any,
        { id: "s3-0xop", operator_id: "0xop", service_id: "s3", active: true } as any,
        { id: "s4-0xop", operator_id: "0xop", service_id: "s4", active: true } as any,
      ]),
      Operator: createStore([{ id: "0xop", restakingStake: 0n } as any]),
    };
    const points = new PointsManager(pointsContext(context), 20n, 7200n, "0xsvc");
    await processParticipation(context, "operator-service-hourly", 20n, 7200n, points);
    const snapshots = context.PointsSnapshot.values();
    expect(snapshots).toHaveLength(1);
    expect(snapshots[0].serviceUsdBasis).toEqual(2n * 10n ** 18n);
  });
});
