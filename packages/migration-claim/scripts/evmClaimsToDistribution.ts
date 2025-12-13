#!/usr/bin/env ts-node
/**
 * Convert `evm-claims.json` into one or more distribution JSON files compatible with
 * `tnt-core/script/v2/DistributeTNTWithLockup.s.sol`.
 *
 * Usage:
 *   npx ts-node scripts/evmClaimsToDistribution.ts \
 *     --input ../evm-claims.json \
 *     --token 0xYourTNTToken \
 *     --unlock-timestamp 1760000000 \
 *     --unlocked-bps 1000 \
 *     --chunk-size 200 \
 *     --out-dir ../../deploy/config/evm-airdrop
 */

import { existsSync, mkdirSync, readFileSync, writeFileSync } from 'fs';
import { join, resolve } from 'path';

type EvmClaimsFile =
  | {
      claims: Array<{ address: string; amount: string }>;
    }
  | Array<{ address: string; amount: string }>;

function getArg(flag: string): string | undefined {
  const args = process.argv.slice(2);
  const idx = args.indexOf(flag);
  if (idx === -1) return undefined;
  return args[idx + 1];
}

function getArgInt(flag: string): number | undefined {
  const v = getArg(flag);
  if (v === undefined) return undefined;
  const n = Number(v);
  if (!Number.isFinite(n) || !Number.isInteger(n) || n < 0) {
    throw new Error(`Invalid ${flag}: ${v}`);
  }
  return n;
}

function usageAndExit(message?: string): never {
  if (message) console.error(message);
  console.error(
    [
      'Usage:',
      '  npx ts-node scripts/evmClaimsToDistribution.ts --input <evm-claims.json> --token <0x...> --out-dir <dir>',
      '',
      'Optional:',
      '  --chunk-size <n>         (default: 200)',
      '  --unlock-timestamp <ts>  (include lock config for DistributeTNTWithLockup)',
      '  --unlocked-bps <bps>     (default: 1000 when --unlock-timestamp is set)',
      '  --lock-factory <0x...>   (optional, for DistributeTNTWithLockup)',
      '  --prefix <name>          (default: evm-distribution)',
    ].join('\n'),
  );
  process.exit(1);
}

function isDigits(value: string): boolean {
  return /^[0-9]+$/.test(value);
}

function chunk<T>(arr: T[], size: number): T[][] {
  const out: T[][] = [];
  for (let i = 0; i < arr.length; i += size) out.push(arr.slice(i, i + size));
  return out;
}

function main() {
  const input = getArg('--input');
  const token = getArg('--token');
  const outDir = getArg('--out-dir');
  if (!input || !token || !outDir) usageAndExit();

  const chunkSize = getArgInt('--chunk-size') ?? 200;
  if (chunkSize === 0) usageAndExit('--chunk-size must be > 0');

  const unlockTimestamp = getArgInt('--unlock-timestamp');
  const unlockedBps = getArgInt('--unlocked-bps') ?? (unlockTimestamp ? 1000 : undefined);
  const lockFactory = getArg('--lock-factory');
  const prefix = getArg('--prefix') ?? 'evm-distribution';

  const inputPath = resolve(input);
  const outPath = resolve(outDir);
  if (!existsSync(inputPath)) usageAndExit(`Input not found: ${inputPath}`);

  const raw = readFileSync(inputPath, 'utf-8');
  const parsed: EvmClaimsFile = JSON.parse(raw);
  const claims = Array.isArray(parsed) ? parsed : parsed.claims;

  const transfers = claims
    .map((c) => ({ to: String(c.address).toLowerCase(), amount: String(c.amount) }))
    .filter((t) => isDigits(t.amount) && BigInt(t.amount) > 0n);

  if (transfers.length === 0) throw new Error('No non-zero claims found');

  mkdirSync(outPath, { recursive: true });

  const batches = chunk(transfers, chunkSize);
  for (let i = 0; i < batches.length; i++) {
    const fileName = `${prefix}-part-${String(i + 1).padStart(4, '0')}.json`;
    const filePath = join(outPath, fileName);
    const json = renderDistributionJson({
      token,
      lockFactory,
      unlockTimestamp,
      unlockedBps,
      transfers: batches[i],
    });
    writeFileSync(filePath, json);
  }

  const total = transfers.reduce((sum, t) => sum + BigInt(t.amount), 0n);
  console.log(`Wrote ${batches.length} file(s) to: ${outPath}`);
  console.log(`Transfers: ${transfers.length}`);
  console.log(`Total (wei): ${total.toString()}`);
}

function renderDistributionJson(input: {
  token: string;
  lockFactory?: string;
  unlockTimestamp?: number;
  unlockedBps?: number;
  transfers: Array<{ to: string; amount: string }>;
}): string {
  const parts: string[] = [];
  parts.push('{');
  parts.push(`  "token": "${input.token}",`);

  if (input.unlockTimestamp !== undefined) {
    parts.push(`  "unlockTimestamp": ${input.unlockTimestamp},`);
    parts.push(`  "unlockedBps": ${input.unlockedBps ?? 1000},`);
    if (input.lockFactory) {
      parts.push(`  "lockFactory": "${input.lockFactory}",`);
    }
  }

  parts.push('  "transfers": [');
  for (let i = 0; i < input.transfers.length; i++) {
    const t = input.transfers[i];
    if (!/^0x[0-9a-fA-F]{40}$/.test(t.to)) {
      throw new Error(`Invalid recipient address: ${t.to}`);
    }
    if (!isDigits(t.amount)) {
      throw new Error(`Invalid amount: ${t.amount}`);
    }
    const comma = i === input.transfers.length - 1 ? '' : ',';
    parts.push(`    { "to": "${t.to}", "amount": ${t.amount} }${comma}`);
  }
  parts.push('  ]');
  parts.push('}');
  parts.push('');
  return parts.join('\n');
}

main();

