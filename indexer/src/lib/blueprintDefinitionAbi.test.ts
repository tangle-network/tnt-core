import { readFileSync } from "node:fs";
import { resolve } from "node:path";
import { describe, expect, it } from "vitest";
import { BLUEPRINT_DEFINITION_ABI_PARAMETER } from "./blueprintDefinitionAbi";

type AbiComponent = {
  type: string;
  name?: string;
  components?: AbiComponent[];
};

// Same normalization the generator applies: keep type/name/components,
// drop internalType (viem ignores it for decoding).
const normalize = (component: {
  type: string;
  name?: string;
  components?: AbiComponent[];
}): AbiComponent => {
  const out: AbiComponent = { type: component.type };
  if (component.name) out.name = component.name;
  if (component.components) {
    out.components = component.components.map(normalize);
  }
  return out;
};

describe("BLUEPRINT_DEFINITION_ABI_PARAMETER drift guard", () => {
  it("matches Types.BlueprintDefinition in the machine-generated bindings ABI", () => {
    // The checked-in spec exists because envio's bundler cannot import JSON
    // from outside the indexer package; this test makes drift a red test
    // instead of a silent decode break: when the on-chain struct changes,
    // regenerate blueprintDefinitionAbi.ts (and the Solidity fixture) from
    // bindings/abi/ITangleFull.json.
    const abiPath = resolve(__dirname, "../../../bindings/abi/ITangleFull.json");
    const parsed = JSON.parse(readFileSync(abiPath, "utf-8")) as {
      abi: Array<{
        type: string;
        name?: string;
        outputs?: Array<{ type: string; name?: string; components?: AbiComponent[] }>;
      }>;
    };
    const abi = parsed.abi;
    const fn = abi.find(
      (entry) => entry.type === "function" && entry.name === "getBlueprintDefinition",
    );
    expect(fn?.outputs).toHaveLength(1);
    if (!fn?.outputs) return;

    const derived = { ...normalize(fn.outputs[0]), name: "definition" };
    expect(BLUEPRINT_DEFINITION_ABI_PARAMETER).toEqual(derived);
  });
});
