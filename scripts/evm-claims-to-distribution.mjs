#!/usr/bin/env node
/**
 * Convert `packages/migration-claim/evm-claims.json` into one or more distribution JSON files compatible with:
 *   `script/v2/DistributeTNTWithLockup.s.sol:DistributeTNTWithLockup`
 *
 * Usage:
 *   node scripts/evm-claims-to-distribution.mjs \
 *     --input packages/migration-claim/evm-claims.json \
 *     --token 0xYourTNTToken \
 *     --out-dir deployments/base-sepolia/evm-airdrop \
 *     --chunk-size 200 \
 *     --unlock-timestamp 1760000000 \
 *     --unlocked-bps 1000 \
 *     --lock-factory 0xYourLockFactory \
 *     --prefix evm-distribution
 */

import { existsSync, mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { join, resolve } from 'node:path';

function getArg(flag) {
  const args = process.argv.slice(2);
  const idx = args.indexOf(flag);
  if (idx === -1) return undefined;
  return args[idx + 1];
}

function getArgInt(flag) {
  const v = getArg(flag);
  if (v === undefined) return undefined;
  const n = Number(v);
  if (!Number.isFinite(n) || !Number.isInteger(n) || n < 0) {
    throw new Error(`Invalid ${flag}: ${v}`);
  }
  return n;
}

function usageAndExit(message) {
  if (message) console.error(message);
  console.error(
    [
      'Usage:',
      '  node scripts/evm-claims-to-distribution.mjs --input <evm-claims.json> --token <0x...> --out-dir <dir>',
      '',
      'Optional:',
      '  --chunk-size <n>         (default: 200)',
      '  --unlock-timestamp <ts>  (include lock config for DistributeTNTWithLockup)',
      '  --unlocked-bps <bps>     (default: 1000 when --unlock-timestamp is set)',
      '  --lock-factory <0x...>   (optional)',
      '  --prefix <name>          (default: evm-distribution)',
    ].join('\n'),
  );
  process.exit(1);
}

function isDigits(value) {
  return /^[0-9]+$/.test(value);
}

function isAddress(value) {
  return /^0x[0-9a-fA-F]{40}$/.test(value);
}

function chunk(arr, size) {
  const out = [];
  for (let i = 0; i < arr.length; i += size) out.push(arr.slice(i, i + size));
  return out;
}

function renderDistributionJson(input) {
  const parts = [];
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
    const comma = i === input.transfers.length - 1 ? '' : ',';
    parts.push(`    { "to": "${t.to}", "amount": ${t.amount} }${comma}`);
  }
  parts.push('  ]');
  parts.push('}');
  parts.push('');
  return parts.join('\n');
}

function main() {
  const input = getArg('--input');
  const token = getArg('--token');
  const outDir = getArg('--out-dir');
  if (!input || !token || !outDir) usageAndExit();
  if (!isAddress(token)) usageAndExit(`Invalid --token: ${token}`);

  const chunkSize = getArgInt('--chunk-size') ?? 200;
  if (chunkSize === 0) usageAndExit('--chunk-size must be > 0');

  const unlockTimestamp = getArgInt('--unlock-timestamp');
  const unlockedBps = getArgInt('--unlocked-bps') ?? (unlockTimestamp ? 1000 : undefined);
  const lockFactory = getArg('--lock-factory');
  if (lockFactory !== undefined && !isAddress(lockFactory)) {
    usageAndExit(`Invalid --lock-factory: ${lockFactory}`);
  }
  const prefix = getArg('--prefix') ?? 'evm-distribution';

  const inputPath = resolve(input);
  const outPath = resolve(outDir);
  if (!existsSync(inputPath)) usageAndExit(`Input not found: ${inputPath}`);

  const parsed = JSON.parse(readFileSync(inputPath, 'utf-8'));
  const claims = Array.isArray(parsed) ? parsed : parsed.claims;
  if (!Array.isArray(claims)) throw new Error('Invalid evm-claims.json format');

  const transfers = claims
    .map((c) => ({
      to: String(c.address).toLowerCase(),
      amount: String(c.amount),
    }))
    .filter((t) => isAddress(t.to) && isDigits(t.amount) && BigInt(t.amount) > 0n);

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

main();

