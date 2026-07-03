import { describe, expect, it } from "vitest";
import { SOLIDITY_ENCODED_BLUEPRINT_DEFINITION } from "./__fixtures__/blueprintDefinitionFixture";
import { decodeBlueprintDefinition } from "./blueprintDefinition";

describe("decodeBlueprintDefinition", () => {
  it("decodes a Solidity-encoded BlueprintDefinition (cross-implementation vector)", () => {
    const result = decodeBlueprintDefinition(SOLIDITY_ENCODED_BLUEPRINT_DEFINITION);
    expect(result.succeeded).toBe(true);
    if (!result.succeeded) return;
    const display = result.value;
    // Expected values come from BlueprintDefinitionHelper._blueprintDefinition —
    // the canonical fixture the LocalTestnet seeding uses.
    expect(display.metadataUri).toBe("ipfs://fixture-metadata");
    expect(display.name).toBe("Test Blueprint");
    expect(display.description).toBe("Test blueprint definition");
    expect(display.author).toBe("Tangle");
    expect(display.category).toBe("Test");
    expect(display.codeRepository).toBe("https://github.com/webb-tools/tnt-core");
    expect(display.logo).toBe("");
    expect(display.website).toBe("https://tangle.network");
    expect(display.license).toBe("MIT");
    expect(display.jobNames).toHaveLength(8);
    expect(display.jobNames[0]).toBe("Test Job");
    expect(display.jobDescriptions).toHaveLength(8);
  });

  it("returns a typed failure (not a throw) on a malformed payload", () => {
    const result = decodeBlueprintDefinition("0xdeadbeef");
    expect(result.succeeded).toBe(false);
    if (result.succeeded) return;
    expect(result.error.length).toBeGreaterThan(0);
  });
});
