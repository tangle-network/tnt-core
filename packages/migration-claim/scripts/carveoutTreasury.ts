#!/usr/bin/env ts-node
/**
 * Carve out the Substrate "module treasury" account from an existing merkle-tree.json.
 *
 * Motivation:
 * - The snapshot currently includes a non-claimable Substrate module account (pubkey = "modlpy/trsry"),
 *   which cannot ever produce a ZK proof and should not be part of the claim merkle tree.
 * - We remove it from the merkle tree and emit a `treasury-carveout.json` artifact so the same amount
 *   can be minted/transferred to the EVM treasury (e.g. governance timelock / multisig).
 *
 * Usage:
 *   npx ts-node scripts/carveoutTreasury.ts
 *   npx ts-node scripts/carveoutTreasury.ts --in ../merkle-tree.json --out ../merkle-tree.json
 */

import { StandardMerkleTree } from '@openzeppelin/merkle-tree';
import { readFileSync, writeFileSync } from 'fs';
import { resolve } from 'path';

type MerkleTreeEntry = {
  pubkey: string;
  balance: string;
  proof: string[];
  leaf: [string, string];
};

type MerkleTreeOutput = {
  root: string;
  totalValue: string;
  entryCount: number;
  entries: Record<string, MerkleTreeEntry>;
  entriesByPubkey?: Record<string, MerkleTreeEntry & { ss58Address: string }>;
};

const SUBSTRATE_TREASURY_PUBKEY =
  '0x6d6f646c70792f74727372790000000000000000000000000000000000000000';

function parseArgs(argv: string[]) {
  const args = argv.slice(2);
  const inIdx = args.indexOf('--in');
  const outIdx = args.indexOf('--out');
  const input = inIdx !== -1 ? args[inIdx + 1] : resolve(__dirname, '..', 'merkle-tree.json');
  const output = outIdx !== -1 ? args[outIdx + 1] : input;
  return { input, output };
}

function main() {
  const { input, output } = parseArgs(process.argv);

  const parsed = JSON.parse(readFileSync(input, 'utf-8')) as MerkleTreeOutput;
  if (!parsed.entries || typeof parsed.entries !== 'object') {
    throw new Error(`Invalid merkle-tree.json: missing .entries (${input})`);
  }

  const entries = Object.entries(parsed.entries).map(([ss58, v]) => ({
    ss58,
    pubkey: v.pubkey.toLowerCase(),
    balance: v.balance,
  }));

  const carveout = entries.find((e) => e.pubkey === SUBSTRATE_TREASURY_PUBKEY);
  if (!carveout) {
    throw new Error(`Treasury pubkey not found in entries: ${SUBSTRATE_TREASURY_PUBKEY}`);
  }

  const kept = entries.filter((e) => e.pubkey !== SUBSTRATE_TREASURY_PUBKEY);
  const values = kept.map((e) => [e.pubkey, e.balance] as [string, string]);

  const tree = StandardMerkleTree.of(values, ['bytes32', 'uint256']);

  const pubkeyToSs58 = new Map(kept.map((e) => [e.pubkey, e.ss58]));
  const outEntries: Record<string, MerkleTreeEntry> = {};
  const outEntriesByPubkey: NonNullable<MerkleTreeOutput['entriesByPubkey']> = {};

  for (const [index, [pubkey, balance]] of tree.entries()) {
    const proof = tree.getProof(index) as string[];
    const normalizedPubkey = pubkey.toLowerCase();
    const ss58 = pubkeyToSs58.get(normalizedPubkey);
    if (!ss58) throw new Error(`Missing ss58 for pubkey: ${normalizedPubkey}`);

    const entry: MerkleTreeEntry = {
      pubkey: normalizedPubkey,
      balance,
      proof,
      leaf: [normalizedPubkey, balance],
    };
    outEntries[ss58] = entry;
    outEntriesByPubkey[normalizedPubkey] = { ...entry, ss58Address: ss58 };
  }

  const totalValue = kept.reduce((sum, e) => sum + BigInt(e.balance), 0n).toString();
  const out: MerkleTreeOutput = {
    root: tree.root,
    totalValue,
    entryCount: kept.length,
    entries: outEntries,
    entriesByPubkey: outEntriesByPubkey,
  };

  writeFileSync(output, JSON.stringify(out, null, 2));

  const carveoutPath = resolve(output, '..', 'treasury-carveout.json');
  writeFileSync(
    carveoutPath,
    JSON.stringify(
      {
        label: 'substrate-module-treasury',
        ss58: carveout.ss58,
        pubkey: carveout.pubkey,
        amount: carveout.balance,
      },
      null,
      2,
    ),
  );

  // eslint-disable-next-line no-console
  console.log(`Updated merkle tree written to: ${output}`);
  // eslint-disable-next-line no-console
  console.log(`Treasury carveout written to: ${carveoutPath}`);
  // eslint-disable-next-line no-console
  console.log(`New merkle root: ${out.root}`);
  // eslint-disable-next-line no-console
  console.log(`New merkle total (wei): ${out.totalValue}`);
  // eslint-disable-next-line no-console
  console.log(`Carved out treasury amount (wei): ${carveout.balance}`);
}

main();

