import test from "node:test";
import assert from "node:assert/strict";
import { PointsManager } from "../../points";
import type { PointsAccount, PointsEvent, PointsProgram, PointsSnapshot } from "generated/src/Types.gen";

type Store<T> = Map<string, T>;

const createStore = <T>() => {
  const map: Store<T> = new Map();
  return {
    get: async (id: string) => map.get(id),
    set: (entity: T & { id: string }) => {
      map.set(entity.id, entity);
    },
    values: () => [...map.values()],
  };
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
  };
};

test("PointsManager awards new programs and updates accounts", async () => {
  const context = createMockContext();
  const manager = new PointsManager(context, 1n, 100n, "0xabc");
  await manager.award("0x123", "developer-blueprint", 50n, "blueprint");
  const account = (await context.PointsAccount.get("0x123"))!;
  assert.equal(account.totalPoints, 50n);
  assert.equal(account.leaderboardPoints, 50n);
  assert.equal(context.PointsEvent.values().length, 1);

  await manager.award("0x123", "developer-blueprint", 25n, "update");
  const updated = (await context.PointsAccount.get("0x123"))!;
  assert.equal(updated.totalPoints, 75n);
  assert.equal(context.PointsEvent.values().length, 2);
  assert.ok(await context.PointsProgram.get("developer-blueprint"), "program stored");
});
