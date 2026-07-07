import { indexer } from "envio";
import type { BinaryVersion, BinaryVersionAttestation, BlueprintDefinition } from "envio";
import { decodeBlueprintDefinition } from "../lib/blueprintDefinition";
import {
  getEventId,
  getPointsManager,
  getTimestamp,
  getTxHash,
  normalizeAddress,
  toBigInt,
  toHexString,
  toNumber,
} from "../lib/handlerUtils";

// Types.AttestationKind — append-only on-chain enum. Keep in sync with
// src/libraries/Types.sol; unknown ordinals fall through to UNKNOWN so a new
// on-chain variant never breaks indexing.
const ATTESTATION_KINDS = ["AUDIT", "FUZZ", "FORMAL", "BUG_BOUNTY", "SELF"] as const;
const mapAttestationKind = (value: bigint | number | undefined | null): string => {
  const numeric = typeof value === "bigint" ? Number(value) : value ?? -1;
  return ATTESTATION_KINDS[numeric] ?? "UNKNOWN";
};
import { pointsContext } from "../points/participation";
import { awardDeveloperBlueprint } from "../points/awards";

indexer.onEvent({ contract: "MasterBlueprintServiceManager", event: "BlueprintDefinitionRecorded" }, async ({ event, context }) => {
  const timestamp = getTimestamp(event);
  const blueprintId = toBigInt(event.params.blueprintId);
  const owner = normalizeAddress(event.params.owner);
  const encodedDefinition = toHexString(event.params.encodedDefinition);

  // 0.18 stores only the definition hash on-chain; this payload is the sole
  // on-chain source of blueprint/job display prose. Raw hex is persisted
  // regardless so a decode regression never loses data.
  const decoded = decodeBlueprintDefinition(encodedDefinition as `0x${string}`);
  if (!decoded.succeeded) {
    context.log.error(
      `BlueprintDefinitionRecorded decode failed for blueprint ${blueprintId} (ABI spec drift from the deployed struct?): ${decoded.error}`,
    );
  }
  const display = decoded.succeeded ? decoded.value : undefined;

  const definition: BlueprintDefinition = {
    id: getEventId(event),
    blueprintId,
    owner,
    encodedDefinition,
    metadataUri: display?.metadataUri || undefined,
    name: display?.name || undefined,
    description: display?.description || undefined,
    author: display?.author || undefined,
    category: display?.category || undefined,
    codeRepository: display?.codeRepository || undefined,
    logo: display?.logo || undefined,
    website: display?.website || undefined,
    license: display?.license || undefined,
    jobNames: display?.jobNames,
    jobDescriptions: display?.jobDescriptions,
    decodeError: decoded.succeeded ? undefined : decoded.error,
    recordedAt: timestamp,
    txHash: getTxHash(event),
  } as BlueprintDefinition;
  context.BlueprintDefinition.set(definition);

  // Mirror the display name onto the Blueprint entity so catalog queries
  // don't need a join. Newest recording wins, matching on-chain semantics.
  if (display) {
    const blueprint = await context.Blueprint.get(blueprintId.toString());
    if (blueprint) {
      context.Blueprint.set({
        ...blueprint,
        name: display.name || undefined,
        description: display.description || undefined,
        updatedAt: timestamp,
      });
    }
  }

  const points = getPointsManager(pointsContext(context), event);
  await awardDeveloperBlueprint(points, owner, blueprintId.toString());
});

indexer.onEvent({ contract: "MasterBlueprintServiceManager", event: "BinaryVersionRecorded" }, async ({ event, context }) => {
  const blueprintId = toBigInt(event.params.blueprintId);
  const versionId = toBigInt(event.params.versionId);
  const version: BinaryVersion = {
    id: `${blueprintId}-${versionId}`,
    blueprintId,
    versionId,
    sha256Hash: toHexString(event.params.sha256Hash),
    binaryUri: event.params.binaryUri,
    recordedAt: getTimestamp(event),
    txHash: getTxHash(event),
  } as BinaryVersion;
  context.BinaryVersion.set(version);
});

indexer.onEvent({ contract: "MasterBlueprintServiceManager", event: "BinaryVersionAttested" }, async ({ event, context }) => {
  const blueprintId = toBigInt(event.params.blueprintId);
  const versionId = toBigInt(event.params.versionId);
  const attestationId = toBigInt(event.params.attestationId);
  const attestation: BinaryVersionAttestation = {
    id: `${blueprintId}-${versionId}-${attestationId}`,
    // reportUri lives only in this event on 0.19+ (dropped from the on-chain
    // struct), so the indexer is the sole source of it for the dapp.
    binaryVersion_id: `${blueprintId}-${versionId}`,
    blueprintId,
    versionId,
    attestationId,
    attester: normalizeAddress(event.params.attester),
    kind: mapAttestationKind(event.params.kind),
    severityFound: toNumber(event.params.severityFound),
    reportUri: event.params.reportUri,
    revoked: false,
    revocationReasonUri: undefined,
    attestedAt: getTimestamp(event),
    revokedAt: undefined,
    txHash: getTxHash(event),
  } as BinaryVersionAttestation;
  context.BinaryVersionAttestation.set(attestation);
});

indexer.onEvent({ contract: "MasterBlueprintServiceManager", event: "BinaryVersionAttestationRevoked" }, async ({ event, context }) => {
  const blueprintId = toBigInt(event.params.blueprintId);
  const versionId = toBigInt(event.params.versionId);
  const attestationId = toBigInt(event.params.attestationId);
  const id = `${blueprintId}-${versionId}-${attestationId}`;
  const existing = await context.BinaryVersionAttestation.get(id);
  if (!existing) {
    // Revocation without a prior attest row is only possible if the attest
    // event was missed (reorg/gap); log rather than silently drop the reason.
    context.log.error(`BinaryVersionAttestationRevoked for unknown attestation ${id} (missing BinaryVersionAttested?)`);
    return;
  }
  context.BinaryVersionAttestation.set({
    ...existing,
    revoked: true,
    revocationReasonUri: event.params.reasonUri,
    revokedAt: getTimestamp(event),
  });
});
