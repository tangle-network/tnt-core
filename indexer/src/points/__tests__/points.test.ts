import { describe, expect, it } from "vitest";

import { PointsManager } from "../../points";
import type { PointsAccount, PointsEvent, PointsHourlyTotal, PointsProgram, PointsSnapshot } from "generated/src/Types.gen";

type Store<T> = Map<string, T>;

const createStore = <T>() => {
  const map: Store<T> = new Map();
  const store = {
    get: async (id: string) => map.get(id),
    set: (entity: T & { id: string }) => {
      map.set(entity.id, entity);
    },
    values: () => [...map.values()],
  };
  return store;
};

const createMockContext = () => {
  const programStore = createStore<PointsProgram>();
  const accountStore = createStore<PointsAccount>();
  const eventStore = createStore<PointsEvent>();
  const snapshotStore = createStore<PointsSnapshot>();
  return {
    PointsProgram: programStore,
    PointsAccount: accountStore,
    PointsEvent: eventStore,
    PointsSnapshot: snapshotStore,
    PointsHourlyTotal: createStore<PointsHourlyTotal>(),
  };
};

describe("PointsManager", () => {
  it("awards new programs and updates accounts", async () => {
    const context = createMockContext();
    const manager = new PointsManager(context, 1n, 100n, "0xabc");
    await manager.award("0x123", "developer-blueprint", 50n, "blueprint");
    const account = (await context.PointsAccount.get("0x123"))!;
    expect(account.totalPoints).toBe(50n);
    expect(account.leaderboardPoints).toBe(50n);
    expect(context.PointsEvent.values().length).toBe(1);

    await manager.award("0x123", "developer-blueprint", 25n, "update");
    const updated = (await context.PointsAccount.get("0x123"))!;
    expect(updated.totalPoints).toBe(75n);
    expect(context.PointsEvent.values().length).toBe(2);
    expect(await context.PointsProgram.get("developer-blueprint")).toBeTruthy();
  });
});
