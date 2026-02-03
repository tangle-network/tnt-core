#!/usr/bin/env ts-node
/**
 * Extract unclaimed airdrop accounts from snapshot
 * These accounts had a 1-year claim window on the original Substrate chain that expired.
 */

import { readFileSync, writeFileSync } from 'fs';
import { decodeAddress } from '@polkadot/util-crypto';
import { formatUnits } from 'viem';
import { dirname, resolve } from 'path';

const SCRIPT_DIR = dirname(process.argv[1]);
const CONTRACT_DIR = resolve(SCRIPT_DIR, '..');

interface SnapshotClaim {
  address: { evm?: string; native?: string };
  amount: string;
  vesting: null | unknown;
}

interface TangleSnapshot {
  metadata?: { chainName?: string; blockNumber?: number };
  accounts: { address: string; free: string }[];
  claims?: {
    total: string;
    claims: SnapshotClaim[];
  };
}

function ss58ToHex(ss58Address: string): string {
  const pubkeyBytes = decodeAddress(ss58Address);
  const hex = Array.from(pubkeyBytes)
    .map((b) => b.toString(16).padStart(2, '0'))
    .join('');
  return `0x${hex}`;
}

async function main() {
  const snapshotPath = process.argv[2] || '/Users/drew/webb/dapp/scripts/migration/tangle_migration_snapshot_8116528.json';

  console.log('Reading snapshot...');
  const snapshot: TangleSnapshot = JSON.parse(readFileSync(snapshotPath, 'utf-8'));

  const allClaims = snapshot.claims?.claims || [];

  // Native claims (SS58 addresses)
  console.log('\nProcessing native claims (SS58 addresses)...');
  const nativeClaims = allClaims
    .filter((c) => c.address.native && BigInt(c.amount) > BigInt(0))
    .map((c) => ({
      ss58Address: c.address.native!,
      pubkey: ss58ToHex(c.address.native!),
      amount: c.amount,
    }));

  const nativeClaimsTotal = nativeClaims.reduce(
    (sum, c) => sum + BigInt(c.amount),
    BigInt(0)
  );

  console.log(`  Count: ${nativeClaims.length}`);
  console.log(`  Total: ${formatUnits(nativeClaimsTotal, 18)} TNT`);

  // EVM claims (0x addresses)
  console.log('\nProcessing EVM claims (0x addresses)...');
  const evmClaims = allClaims
    .filter((c) => c.address.evm && BigInt(c.amount) > BigInt(0))
    .map((c) => ({
      address: c.address.evm!.toLowerCase(),
      amount: c.amount,
    }));

  const evmClaimsTotal = evmClaims.reduce(
    (sum, c) => sum + BigInt(c.amount),
    BigInt(0)
  );

  console.log(`  Count: ${evmClaims.length}`);
  console.log(`  Total: ${formatUnits(evmClaimsTotal, 18)} TNT`);

  const totalUnclaimed = nativeClaimsTotal + evmClaimsTotal;
  const decayedAmount = totalUnclaimed / 10n; // 90% decay = 10% remaining

  console.log('\n=== Summary ===');
  console.log(`Total unclaimed: ${formatUnits(totalUnclaimed, 18)} TNT`);
  console.log(`If re-added with 90% decay: ${formatUnits(decayedAmount, 18)} TNT`);

  const result = {
    description: 'Unclaimed airdrop accounts from original Substrate chain (1-year claim window expired)',
    snapshotBlock: snapshot.metadata?.blockNumber || 8116528,
    totalAmount: totalUnclaimed.toString(),
    totalAmountFormatted: `${formatUnits(totalUnclaimed, 18)} TNT`,
    nativeClaimsTotal: nativeClaimsTotal.toString(),
    nativeClaimsTotalFormatted: `${formatUnits(nativeClaimsTotal, 18)} TNT`,
    nativeClaimsCount: nativeClaims.length,
    evmClaimsTotal: evmClaimsTotal.toString(),
    evmClaimsTotalFormatted: `${formatUnits(evmClaimsTotal, 18)} TNT`,
    evmClaimsCount: evmClaims.length,
    decay: {
      percentage: '90%',
      note: 'If re-added in future, apply 90% decay (only 10% of original amount)',
      decayedTotal: decayedAmount.toString(),
      decayedTotalFormatted: `${formatUnits(decayedAmount, 18)} TNT`,
    },
    nativeClaims,
    evmClaims,
  };

  const outputPath = resolve(CONTRACT_DIR, 'unclaimed-accounts.json');
  writeFileSync(outputPath, JSON.stringify(result, null, 2));
  console.log(`\nSaved: ${outputPath}`);
}

main().catch(console.error);
