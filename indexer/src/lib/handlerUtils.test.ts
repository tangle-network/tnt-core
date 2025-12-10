import { describe, expect, it } from "vitest";

import { mapLockDuration } from "./handlerUtils";

describe("mapLockDuration", () => {
  it("maps numeric values to the correct enum labels", () => {
    expect(mapLockDuration(0)).toBe("NONE");
    expect(mapLockDuration(1)).toBe("ONE_MONTH");
    expect(mapLockDuration(2)).toBe("TWO_MONTHS");
    expect(mapLockDuration(3)).toBe("THREE_MONTHS");
    expect(mapLockDuration(4)).toBe("SIX_MONTHS");
    expect(mapLockDuration(999)).toBe("NONE");
  });
});
