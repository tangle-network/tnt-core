#!/usr/bin/env ts-node
/**
 * Carve out non-claimable Substrate module accounts ("modl*") from an existing merkle-tree.json.
 *
 * Motivation:
 * - The snapshot may include non-claimable Substrate module accounts (pubkeys starting with "modl"),
 *   which cannot ever produce a ZK proof and should not be part of the claim merkle tree.
 * - We remove them from the merkle tree and emit a `treasury-carveout.json` artifact so the same amount
 *   can be minted/transferred to the EVM treasury (e.g. governance timelock / multisig).
 *
 * Usage:
 *   npx ts-node scripts/carveoutTreasury.ts
 *   npx ts-node scripts/carveoutTreasury.ts --foundation-ss58 <tg...>   # also carve out foundation allocation
 *   npx ts-node scripts/carveoutTreasury.ts --in ../merkle-tree.json --out ../merkle-tree.json
 */

import { StandardMerkleTree } from '@openzeppelin/merkle-tree';
import { existsSync, readFileSync, writeFileSync } from 'fs';
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

const SUBSTRATE_MODULE_PREFIX = '0x6d6f646c'; // "modl"

type CarveoutAccount = { ss58: string | null; pubkey: string; amount: string };

function parseArgs(argv: string[]) {
  const args = argv.slice(2);
  const inIdx = args.indexOf('--in');
  const outIdx = args.indexOf('--out');
  const foundationSs58Idx = args.indexOf('--foundation-ss58');
  const input = inIdx !== -1 ? args[inIdx + 1] : resolve(__dirname, '..', 'merkle-tree.json');
  const output = outIdx !== -1 ? args[outIdx + 1] : input;
  const foundationSs58 = foundationSs58Idx !== -1 ? args[foundationSs58Idx + 1] : undefined;
  return { input, output, foundationSs58 };
}

function readExistingTreasuryCarveout(path: string): CarveoutAccount[] {
  if (!existsSync(path)) return [];
  const raw = JSON.parse(readFileSync(path, 'utf-8')) as any;
  if (raw && Array.isArray(raw.accounts)) {
    return raw.accounts
      .map((a: any) => ({
        ss58: typeof a.ss58 === 'string' ? a.ss58 : null,
        pubkey: String(a.pubkey).toLowerCase(),
        amount: String(a.amount),
      }))
      .filter((a: CarveoutAccount) => /^0x[0-9a-f]{64}$/.test(a.pubkey) && /^[0-9]+$/.test(a.amount));
  }

  // Legacy format (single account carveout)
  if (raw && raw.pubkey && raw.amount) {
    return [
      {
        ss58: typeof raw.ss58 === 'string' ? raw.ss58 : null,
        pubkey: String(raw.pubkey).toLowerCase(),
        amount: String(raw.amount),
      },
    ];
  }

  return [];
}

function main() {
  const { input, output, foundationSs58 } = parseArgs(process.argv);

  const parsed = JSON.parse(readFileSync(input, 'utf-8')) as MerkleTreeOutput;
  if (!parsed.entries || typeof parsed.entries !== 'object') {
    throw new Error(`Invalid merkle-tree.json: missing .entries (${input})`);
  }

  const entries = Object.entries(parsed.entries).map(([ss58, v]) => ({
    ss58,
    pubkey: v.pubkey.toLowerCase(),
    balance: v.balance,
  }));

  const carved = entries.filter((e) => e.pubkey.startsWith(SUBSTRATE_MODULE_PREFIX));
  const carveoutPath = resolve(output, '..', 'treasury-carveout.json');
  const existingCarved = readExistingTreasuryCarveout(carveoutPath);
  if (carved.length === 0 && existingCarved.length === 0) {
    throw new Error(
      `No Substrate module accounts found (expected pubkey prefix: ${SUBSTRATE_MODULE_PREFIX}) and no existing treasury carveout to extend`,
    );
  }

  let foundationCarveout: { ss58: string; pubkey: string; amount: string } | undefined;
  if (foundationSs58) {
    const match = entries.find((e) => e.ss58 === foundationSs58);
    if (!match) throw new Error(`Foundation ss58 not found in entries: ${foundationSs58}`);
    if (match.pubkey.startsWith(SUBSTRATE_MODULE_PREFIX)) {
      throw new Error(`Foundation ss58 is a module account (unexpected): ${foundationSs58}`);
    }
    foundationCarveout = { ss58: match.ss58, pubkey: match.pubkey, amount: match.balance };
  }

  const kept = entries.filter(
    (e) => !e.pubkey.startsWith(SUBSTRATE_MODULE_PREFIX) && (!foundationSs58 || e.ss58 !== foundationSs58),
  );
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

  const combinedByPubkey = new Map<string, CarveoutAccount>();
  for (const a of existingCarved) combinedByPubkey.set(a.pubkey, a);
  for (const e of carved) {
    combinedByPubkey.set(e.pubkey, { ss58: e.ss58, pubkey: e.pubkey, amount: e.balance });
  }
  const combined = Array.from(combinedByPubkey.values());
  const amountTotal = combined.reduce((sum, e) => sum + BigInt(e.amount), 0n).toString();
  writeFileSync(
    carveoutPath,
    JSON.stringify(
      {
        label: 'substrate-module-accounts',
        amount: amountTotal,
        accounts: combined
          .map((e) => ({ ss58: e.ss58, pubkey: e.pubkey, amount: e.amount }))
          .sort((a, b) => (BigInt(a.amount) > BigInt(b.amount) ? -1 : BigInt(a.amount) < BigInt(b.amount) ? 1 : 0)),
      },
      null,
      2,
    ),
  );

	  if (foundationCarveout) {
	    const foundationPath = resolve(output, '..', 'foundation-carveout.json');
	    writeFileSync(
	      foundationPath,
	      JSON.stringify(
	        {
	          label: 'tangle-foundation',
	          ss58: foundationCarveout.ss58,
	          pubkey: foundationCarveout.pubkey,
	          amount: foundationCarveout.amount,
	        },
	        null,
        2,
      ),
    );
    // eslint-disable-next-line no-console
    console.log(`Foundation carveout written to: ${foundationPath}`);
  }

  // eslint-disable-next-line no-console
  console.log(`Updated merkle tree written to: ${output}`);
  // eslint-disable-next-line no-console
  console.log(`Treasury carveout written to: ${carveoutPath}`);
  // eslint-disable-next-line no-console
  console.log(`New merkle root: ${out.root}`);
  // eslint-disable-next-line no-console
  console.log(`New merkle total (wei): ${out.totalValue}`);
  // eslint-disable-next-line no-console
  console.log(`Carved out module accounts total (wei): ${amountTotal}`);
}

main();
