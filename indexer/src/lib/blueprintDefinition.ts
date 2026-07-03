import { decodeAbiParameters } from "viem";
import { BLUEPRINT_DEFINITION_ABI_PARAMETER } from "./blueprintDefinitionAbi";

export type DecodedBlueprintDisplay = {
  metadataUri: string;
  name: string;
  description: string;
  author: string;
  category: string;
  codeRepository: string;
  logo: string;
  website: string;
  license: string;
  jobNames: string[];
  jobDescriptions: string[];
};

export type DecodeBlueprintDefinitionResult =
  | { succeeded: true; value: DecodedBlueprintDisplay }
  | { succeeded: false; error: string };

/**
 * Decode the display fields out of `BlueprintDefinitionRecorded.encodedDefinition`.
 *
 * tnt-core 0.18 stores only `keccak256(abi.encode(definition))` on-chain and
 * zeroes the display metadata in storage, so this event payload is the ONLY
 * on-chain source of blueprint/job names and descriptions. The emitter is the
 * configured MasterBlueprintServiceManager address (envio filters by address),
 * which is the same trust anchor the rest of the indexer uses.
 *
 * Returns a typed outcome — callers inspect `succeeded` and must surface a
 * loud error on failure (a payload that does not decode means the ABI spec
 * drifted from the deployed struct, not a normal condition).
 */
export function decodeBlueprintDefinition(
  encodedDefinition: `0x${string}`,
): DecodeBlueprintDefinitionResult {
  try {
    const [definition] = decodeAbiParameters(
      [BLUEPRINT_DEFINITION_ABI_PARAMETER],
      encodedDefinition,
    );
    const metadata = definition.metadata;
    const jobs = definition.jobs ?? [];
    return {
      succeeded: true,
      value: {
        metadataUri: definition.metadataUri,
        name: metadata.name,
        description: metadata.description,
        author: metadata.author,
        category: metadata.category,
        codeRepository: metadata.codeRepository,
        logo: metadata.logo,
        website: metadata.website,
        license: metadata.license,
        jobNames: jobs.map((job) => job.name),
        jobDescriptions: jobs.map((job) => job.description),
      },
    };
  } catch (error) {
    return {
      succeeded: false,
      error: error instanceof Error ? error.message : String(error),
    };
  }
}
