#!/usr/bin/env ts-node
/**
 * Deploy TangleMigration with exact amounts from snapshot
 *
 * This script:
 * 1. Reads the Tangle snapshot
 * 2. Generates merkle tree for Substrate accounts + Native unclaimed claims
 * 3. Extracts EVM unclaimed claims for direct minting
 * 4. Deploys TNT token
 * 5. Deploys TangleMigration with correct merkle root
 * 6. Mints exact Substrate claim amount to TangleMigration
 * 7. Batch mints EVM claims directly to addresses
 *
 * Claim Types:
 * - Substrate accounts: Regular account balances → TangleMigration (ZK proof claim)
 * - Native claims: Unclaimed airdrop to SS58 addresses → TangleMigration (ZK proof claim)
 * - EVM claims: Unclaimed airdrop to EVM addresses → Direct mint
 *
 * Usage:
 *   npx ts-node scripts/deploy-with-snapshot.ts --snapshot <path> --rpc <url> --private-key <key>
 *
 * For local Anvil:
 *   npx ts-node scripts/deploy-with-snapshot.ts --snapshot ../../scripts/migration/tangle_migration_snapshot_8116528.json
 */

import { createPublicClient, createWalletClient, http, formatUnits, parseUnits } from 'viem';
import { privateKeyToAccount } from 'viem/accounts';
import { anvil } from 'viem/chains';
import { readFileSync, writeFileSync, existsSync } from 'fs';
import { decodeAddress } from '@polkadot/util-crypto';
import { dirname, resolve } from 'path';
import { fileURLToPath } from 'url';

// Get the directory of this script (packages/migration-claim/scripts)
const SCRIPT_DIR = dirname(process.argv[1]);
// Get the contract directory (packages/migration-claim)
const CONTRACT_DIR = resolve(SCRIPT_DIR, '..');

// Contract ABIs (minimal for deployment)
const TNT_ABI = [
  {
    type: 'function',
    name: 'mintInitialSupply',
    inputs: [
      { name: 'to', type: 'address' },
      { name: 'amount', type: 'uint256' },
    ],
    outputs: [],
    stateMutability: 'nonpayable',
  },
  {
    type: 'function',
    name: 'batchMint',
    inputs: [
      { name: 'recipients', type: 'address[]' },
      { name: 'amounts', type: 'uint256[]' },
    ],
    outputs: [],
    stateMutability: 'nonpayable',
  },
  {
    type: 'function',
    name: 'transfer',
    inputs: [
      { name: 'to', type: 'address' },
      { name: 'amount', type: 'uint256' },
    ],
    outputs: [{ type: 'bool' }],
    stateMutability: 'nonpayable',
  },
  {
    type: 'function',
    name: 'balanceOf',
    inputs: [{ name: 'account', type: 'address' }],
    outputs: [{ type: 'uint256' }],
    stateMutability: 'view',
  },
] as const;

interface SnapshotAccount {
  address: string;
  free: string;
}

interface SnapshotClaim {
  address: { evm?: string; native?: string };
  amount: string;
  vesting: null | unknown;
}

interface TangleSnapshot {
  metadata?: {
    chainName?: string;
    blockNumber?: number;
  };
  accounts: SnapshotAccount[];
  claims?: {
    total: string;
    claims: SnapshotClaim[];
  };
}

const SUBSTRATE_MODULE_PREFIX = '0x6d6f646c'; // "modl"

function ss58ToHex(ss58Address: string): string {
  const pubkeyBytes = decodeAddress(ss58Address);
  const hex = Array.from(pubkeyBytes)
    .map((b) => b.toString(16).padStart(2, '0'))
    .join('');
  return `0x${hex}`;
}

async function main() {
  const args = process.argv.slice(2);

  // Parse arguments
  const snapshotIndex = args.indexOf('--snapshot');
  const rpcIndex = args.indexOf('--rpc');
  const keyIndex = args.indexOf('--private-key');
  const dryRunIndex = args.indexOf('--dry-run');
  const foundationSs58Index = args.indexOf('--foundation-ss58');
  const treasuryRecipientIndex = args.indexOf('--treasury-recipient');
  const foundationRecipientIndex = args.indexOf('--foundation-recipient');
  const extraTreasuryPubkeys: string[] = [];
  for (let i = 0; i < args.length; i++) {
    if (args[i] === '--treasury-pubkey') {
      const v = args[i + 1];
      if (!v) throw new Error('--treasury-pubkey requires a value');
      extraTreasuryPubkeys.push(v.toLowerCase());
      i++;
    }
  }

  if (snapshotIndex === -1) {
    console.error('Usage: npx ts-node deploy-with-snapshot.ts --snapshot <path> [--rpc <url>] [--private-key <key>] [--dry-run]');
    process.exit(1);
  }

  const snapshotPath = args[snapshotIndex + 1];
  const rpcUrl = rpcIndex !== -1 ? args[rpcIndex + 1] : 'http://localhost:8545';
  const privateKey = keyIndex !== -1
    ? args[keyIndex + 1]
    : '0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80'; // Anvil default
  const dryRun = dryRunIndex !== -1;
  const foundationSs58 = foundationSs58Index !== -1 ? args[foundationSs58Index + 1] : undefined;
  const treasuryRecipient =
    treasuryRecipientIndex !== -1 ? (args[treasuryRecipientIndex + 1] as `0x${string}`) : undefined;
  const foundationRecipient =
    foundationRecipientIndex !== -1 ? (args[foundationRecipientIndex + 1] as `0x${string}`) : undefined;

  for (const p of extraTreasuryPubkeys) {
    if (!/^0x[0-9a-f]{64}$/.test(p)) {
      throw new Error(`Invalid --treasury-pubkey (expected 32-byte hex): ${p}`);
    }
  }

  if (!existsSync(snapshotPath)) {
    console.error(`Snapshot not found: ${snapshotPath}`);
    process.exit(1);
  }

  console.log('=== TangleMigration Deployment ===\n');
  console.log(`Snapshot: ${snapshotPath}`);
  console.log(`RPC: ${rpcUrl}`);
  console.log(`Dry run: ${dryRun}`);
  console.log('');

  // Read snapshot
  console.log('Reading snapshot...');
  const snapshot: TangleSnapshot = JSON.parse(readFileSync(snapshotPath, 'utf-8'));

  if (snapshot.metadata) {
    console.log(`  Chain: ${snapshot.metadata.chainName || 'Unknown'}`);
    console.log(`  Block: ${snapshot.metadata.blockNumber || 'Unknown'}`);
  }

  // Process Substrate accounts (regular balances)
  console.log('\nProcessing Substrate accounts...');
  const substrateAccounts = snapshot.accounts
    .filter(a => BigInt(a.free) > BigInt(0))
    .map(a => ({
      ss58Address: a.address,
      pubkey: ss58ToHex(a.address),
      balance: a.free,
      source: 'account' as const,
    }));

  const accountsTotal = substrateAccounts.reduce(
    (sum, a) => sum + BigInt(a.balance),
    BigInt(0)
  );

  console.log(`  Accounts with balance: ${substrateAccounts.length}`);
  console.log(`  Total: ${formatUnits(accountsTotal, 18)} TNT`);

  // Separate claims into EVM and Native
  const allClaims = snapshot.claims?.claims || [];

  // Process Native claims (SS58 addresses - add to merkle tree)
  console.log('\nProcessing Native unclaimed claims (SS58 addresses)...');
  const nativeClaims = allClaims
    .filter(c => c.address.native && BigInt(c.amount) > BigInt(0))
    .map(c => ({
      ss58Address: c.address.native!,
      pubkey: ss58ToHex(c.address.native!),
      balance: c.amount,
      source: 'native_claim' as const,
    }));

  const nativeClaimsTotal = nativeClaims.reduce(
    (sum, c) => sum + BigInt(c.balance),
    BigInt(0)
  );

  console.log(`  Native claims: ${nativeClaims.length}`);
  console.log(`  Total: ${formatUnits(nativeClaimsTotal, 18)} TNT`);

  // Process EVM claims (for direct minting)
  console.log('\nProcessing EVM unclaimed claims (0x addresses)...');
  const evmClaims = allClaims
    .filter(c => c.address.evm && BigInt(c.amount) > BigInt(0))
    .map(c => ({
      address: c.address.evm!.toLowerCase() as `0x${string}`,
      amount: BigInt(c.amount),
    }));

  const evmTotal = evmClaims.reduce((sum, c) => sum + c.amount, BigInt(0));

  console.log(`  EVM claims: ${evmClaims.length}`);
  console.log(`  Total: ${formatUnits(evmTotal, 18)} TNT`);

  // Combine Substrate accounts + Native claims for merkle tree
  // Need to handle potential duplicate addresses (account + native claim for same address)
  console.log('\nCombining accounts and native claims...');
  const combinedMap = new Map<string, { ss58Address: string; pubkey: string; balance: bigint }>();

  // Add substrate accounts
  for (const acc of substrateAccounts) {
    const existing = combinedMap.get(acc.pubkey.toLowerCase());
    if (existing) {
      existing.balance += BigInt(acc.balance);
    } else {
      combinedMap.set(acc.pubkey.toLowerCase(), {
        ss58Address: acc.ss58Address,
        pubkey: acc.pubkey,
        balance: BigInt(acc.balance),
      });
    }
  }

  // Add native claims (may be same address as an account)
  for (const claim of nativeClaims) {
    const existing = combinedMap.get(claim.pubkey.toLowerCase());
    if (existing) {
      existing.balance += BigInt(claim.balance);
      console.log(`  Merged: ${claim.ss58Address} (account + native claim)`);
    } else {
      combinedMap.set(claim.pubkey.toLowerCase(), {
        ss58Address: claim.ss58Address,
        pubkey: claim.pubkey,
        balance: BigInt(claim.balance),
      });
    }
  }

  // Carve out non-claimable Substrate module accounts ("modl*") so they're not stuck in the claim contract.
  const explicitTreasuryPubkeys = new Set<string>(extraTreasuryPubkeys);
  const carvedModuleAccounts: Array<{ ss58Address: string; pubkey: string; balance: bigint }> = [];
  for (const [pubkey, entry] of combinedMap.entries()) {
    if (pubkey.startsWith(SUBSTRATE_MODULE_PREFIX) || explicitTreasuryPubkeys.has(pubkey)) {
      carvedModuleAccounts.push({ ss58Address: entry.ss58Address, pubkey: entry.pubkey, balance: entry.balance });
    }
  }
  let carvedFoundation: { ss58Address: string; pubkey: string; balance: bigint } | undefined;
  if (foundationSs58) {
    for (const entry of combinedMap.values()) {
      if (entry.ss58Address === foundationSs58) {
        carvedFoundation = { ss58Address: entry.ss58Address, pubkey: entry.pubkey, balance: entry.balance };
        break;
      }
    }
    if (!carvedFoundation) {
      throw new Error(`--foundation-ss58 not found in snapshot accounts/claims: ${foundationSs58}`);
    }
    if (carvedFoundation.pubkey.toLowerCase().startsWith(SUBSTRATE_MODULE_PREFIX)) {
      throw new Error(`--foundation-ss58 resolves to a module account (unexpected): ${foundationSs58}`);
    }
    if (explicitTreasuryPubkeys.has(carvedFoundation.pubkey.toLowerCase())) {
      throw new Error(
        `Foundation pubkey is also listed for treasury carveout; carve it out via --foundation-ss58 only: ${carvedFoundation.pubkey}`,
      );
    }
  }
  if (carvedModuleAccounts.length > 0) {
    const moduleTotal = carvedModuleAccounts.reduce((sum, e) => sum + e.balance, 0n);
    console.log(
      `\nCarving out Substrate module accounts (non-claimable): ${carvedModuleAccounts.length} accounts, ${formatUnits(moduleTotal, 18)} TNT`,
    );
    for (const e of carvedModuleAccounts) {
      combinedMap.delete(e.pubkey.toLowerCase());
    }
  }
  if (carvedFoundation) {
    console.log(
      `\nCarving out foundation allocation (fully liquid): ${formatUnits(carvedFoundation.balance, 18)} TNT (${carvedFoundation.ss58Address})`,
    );
    combinedMap.delete(carvedFoundation.pubkey.toLowerCase());
  }

  const merkleEntries = Array.from(combinedMap.values()).map(e => ({
    ss58Address: e.ss58Address,
    pubkey: e.pubkey,
    balance: e.balance.toString(),
  }));

  const merkleTotal = merkleEntries.reduce(
    (sum, e) => sum + BigInt(e.balance),
    BigInt(0)
  );

  console.log(`  Combined merkle entries: ${merkleEntries.length}`);
  console.log(`  Merkle tree total: ${formatUnits(merkleTotal, 18)} TNT`);

  // Calculate totals
  const moduleTotal = carvedModuleAccounts.reduce((sum, e) => sum + e.balance, 0n);
  const foundationTotal = carvedFoundation?.balance ?? 0n;
  const grandTotal = merkleTotal + evmTotal + moduleTotal + foundationTotal;
  console.log('\n=== Totals ===');
  console.log(`Substrate accounts: ${formatUnits(accountsTotal, 18)} TNT`);
  console.log(`Native claims:      ${formatUnits(nativeClaimsTotal, 18)} TNT`);
  console.log(`Merkle tree total:  ${formatUnits(merkleTotal, 18)} TNT (accounts + native)`);
  console.log(`EVM claims:         ${formatUnits(evmTotal, 18)} TNT`);
  console.log(`Module carveout:    ${formatUnits(moduleTotal, 18)} TNT (to EVM treasury)`);
  if (foundationTotal > 0n) {
    console.log(`Foundation carveout:${formatUnits(foundationTotal, 18)} TNT`);
  }
  console.log(`Grand total:        ${formatUnits(grandTotal, 18)} TNT`);

  // Generate merkle tree for combined entries (accounts + native claims)
  console.log('\nGenerating merkle tree...');
  const { StandardMerkleTree } = await import('@openzeppelin/merkle-tree');

  const treeValues = merkleEntries.map(a => [a.pubkey, a.balance] as [string, string]);
  const tree = StandardMerkleTree.of(treeValues, ['bytes32', 'uint256']);

  console.log(`  Merkle root: ${tree.root}`);

  // Build proofs file
  const proofsEntries: Record<string, any> = {};
  const proofsEntriesByPubkey: Record<string, any> = {};
  const pubkeyToSs58 = new Map<string, string>();

  for (const entry of merkleEntries) {
    pubkeyToSs58.set(entry.pubkey.toLowerCase(), entry.ss58Address);
  }

  for (const [index, [pubkey, balance]] of tree.entries()) {
    const proof = tree.getProof(index);
    const normalizedPubkey = pubkey.toLowerCase();
    const ss58Address = pubkeyToSs58.get(normalizedPubkey)!;

    const entry = {
      pubkey: normalizedPubkey,
      balance,
      proof,
      leaf: [normalizedPubkey, balance],
    };
    proofsEntries[ss58Address] = entry;
    proofsEntriesByPubkey[normalizedPubkey] = { ...entry, ss58Address };
  }

  // Save merkle tree and proofs
  const merkleTreePath = resolve(CONTRACT_DIR, 'merkle-tree.json');
  writeFileSync(merkleTreePath, JSON.stringify({
    root: tree.root,
    totalValue: merkleTotal.toString(),
    entryCount: merkleEntries.length,
    entries: proofsEntries,
    entriesByPubkey: proofsEntriesByPubkey,
  }, null, 2));
  console.log(`  Saved: ${merkleTreePath}`);

  // Save the carved-out Substrate module allocations for separate EVM treasury minting.
  const treasuryCarveoutPath = resolve(CONTRACT_DIR, 'treasury-carveout.json');
  writeFileSync(
    treasuryCarveoutPath,
    JSON.stringify(
      {
        label: 'substrate-module-accounts',
        amount: moduleTotal.toString(),
        accounts: carvedModuleAccounts
          .map((e) => ({ ss58: e.ss58Address, pubkey: e.pubkey.toLowerCase(), amount: e.balance.toString() }))
          .sort((a, b) => (BigInt(a.amount) > BigInt(b.amount) ? -1 : BigInt(a.amount) < BigInt(b.amount) ? 1 : 0)),
      },
      null,
      2,
    ),
  );
  console.log(`  Saved: ${treasuryCarveoutPath}`);

  if (carvedFoundation) {
    const foundationPath = resolve(CONTRACT_DIR, 'foundation-carveout.json');
    writeFileSync(
      foundationPath,
      JSON.stringify(
        {
          label: 'tangle-foundation',
          ss58: carvedFoundation.ss58Address,
          pubkey: carvedFoundation.pubkey.toLowerCase(),
          amount: carvedFoundation.balance.toString(),
        },
        null,
        2,
      ),
    );
    console.log(`  Saved: ${foundationPath}`);
  }

  // Save EVM claims for reference
  const evmClaimsPath = resolve(CONTRACT_DIR, 'evm-claims.json');
  writeFileSync(evmClaimsPath, JSON.stringify({
    totalAmount: evmTotal.toString(),
    totalAccounts: evmClaims.length,
    claims: evmClaims.map(c => ({ address: c.address, amount: c.amount.toString() })),
  }, null, 2));
  console.log(`  Saved: ${evmClaimsPath}`);

  if (dryRun) {
    console.log('\n=== Dry run complete ===');
    console.log('Add --no-dry-run to actually deploy');
    return;
  }

  // Setup clients
  const account = privateKeyToAccount(privateKey as `0x${string}`);
  console.log(`\nDeployer: ${account.address}`);

  const publicClient = createPublicClient({
    chain: anvil,
    transport: http(rpcUrl),
  });

  const walletClient = createWalletClient({
    account,
    chain: anvil,
    transport: http(rpcUrl),
  });

  // Load contract artifacts
  console.log('\nLoading contract artifacts...');
  const tntArtifact = JSON.parse(readFileSync(resolve(CONTRACT_DIR, 'out/TNT.sol/TNT.json'), 'utf-8'));
  const verifierArtifact = JSON.parse(readFileSync(resolve(CONTRACT_DIR, 'out/MockZKVerifier.sol/MockZKVerifier.json'), 'utf-8'));
  const migrationArtifact = JSON.parse(readFileSync(resolve(CONTRACT_DIR, 'out/TangleMigration.sol/TangleMigration.json'), 'utf-8'));

  // Deploy using viem
  console.log('\n=== Deploying Contracts ===\n');

  // Deploy TNT
  console.log('Deploying TNT...');
  const tntHash = await walletClient.deployContract({
    abi: tntArtifact.abi,
    bytecode: tntArtifact.bytecode.object as `0x${string}`,
    args: [account.address],
  });
  const tntReceipt = await publicClient.waitForTransactionReceipt({ hash: tntHash });
  const tntAddress = tntReceipt.contractAddress as `0x${string}`;
  console.log(`  TNT: ${tntAddress}`);

  // Deploy MockZKVerifier
  console.log('Deploying MockZKVerifier...');
  const verifierHash = await walletClient.deployContract({
    abi: verifierArtifact.abi,
    bytecode: verifierArtifact.bytecode.object as `0x${string}`,
    args: [],
  });
  const verifierReceipt = await publicClient.waitForTransactionReceipt({ hash: verifierHash });
  const verifierAddress = verifierReceipt.contractAddress as `0x${string}`;
  console.log(`  MockZKVerifier: ${verifierAddress}`);

  // Deploy TangleMigration
  console.log('Deploying TangleMigration...');
  const migrationHash = await walletClient.deployContract({
    abi: migrationArtifact.abi,
    bytecode: migrationArtifact.bytecode.object as `0x${string}`,
    args: [tntAddress, tree.root as `0x${string}`, verifierAddress, account.address],
  });
  const migrationReceipt = await publicClient.waitForTransactionReceipt({ hash: migrationHash });
  const migrationAddress = migrationReceipt.contractAddress as `0x${string}`;
  console.log(`  TangleMigration: ${migrationAddress}`);

  // Mint merkle tree total to TangleMigration (accounts + native claims)
  console.log('\nMinting merkle tree total to TangleMigration...');
  const mintToMigrationTx = await walletClient.writeContract({
    address: tntAddress,
    abi: TNT_ABI,
    functionName: 'mintInitialSupply',
    args: [migrationAddress, merkleTotal],
  });
  await publicClient.waitForTransactionReceipt({ hash: mintToMigrationTx });
  console.log(`  Minted ${formatUnits(merkleTotal, 18)} TNT to TangleMigration`);

  if (moduleTotal > 0n) {
    const to = treasuryRecipient ?? account.address;
    console.log(`\nMinting module carveout to treasury recipient: ${to}`);
    const tx = await walletClient.writeContract({
      address: tntAddress,
      abi: TNT_ABI,
      functionName: 'mintInitialSupply',
      args: [to, moduleTotal],
    });
    await publicClient.waitForTransactionReceipt({ hash: tx });
    console.log(`  Minted ${formatUnits(moduleTotal, 18)} TNT to ${to}`);
  }

  if (foundationTotal > 0n) {
    const to = foundationRecipient ?? account.address;
    console.log(`\nMinting foundation carveout to foundation recipient: ${to}`);
    const tx = await walletClient.writeContract({
      address: tntAddress,
      abi: TNT_ABI,
      functionName: 'mintInitialSupply',
      args: [to, foundationTotal],
    });
    await publicClient.waitForTransactionReceipt({ hash: tx });
    console.log(`  Minted ${formatUnits(foundationTotal, 18)} TNT to ${to}`);
  }

  // Batch mint EVM claims (in chunks to avoid gas limits)
  if (evmClaims.length > 0) {
    console.log('\nBatch minting EVM claims...');
    const BATCH_SIZE = 100; // Adjust based on gas limits

    for (let i = 0; i < evmClaims.length; i += BATCH_SIZE) {
      const batch = evmClaims.slice(i, i + BATCH_SIZE);
      const addresses = batch.map(c => c.address);
      const amounts = batch.map(c => c.amount);

      const batchTx = await walletClient.writeContract({
        address: tntAddress,
        abi: TNT_ABI,
        functionName: 'batchMint',
        args: [addresses, amounts],
      });
      await publicClient.waitForTransactionReceipt({ hash: batchTx });

      const progress = Math.min(i + BATCH_SIZE, evmClaims.length);
      console.log(`  Minted ${progress}/${evmClaims.length} EVM claims`);
    }
  }

  // Verify balances
  console.log('\n=== Verification ===');

  const migrationBalance = await publicClient.readContract({
    address: tntAddress,
    abi: TNT_ABI,
    functionName: 'balanceOf',
    args: [migrationAddress],
  });
  console.log(`TangleMigration balance: ${formatUnits(migrationBalance, 18)} TNT`);
  console.log(`Expected:                ${formatUnits(merkleTotal, 18)} TNT`);
  console.log(`Match: ${migrationBalance === merkleTotal ? '✓' : '✗'}`);

  // Output deployment info
  console.log('\n=== Deployment Complete ===\n');
  console.log('Contract Addresses:');
  console.log(`  TNT:             ${tntAddress}`);
  console.log(`  MockZKVerifier:  ${verifierAddress}`);
  console.log(`  TangleMigration: ${migrationAddress}`);
  console.log(`  Merkle Root:     ${tree.root}`);
  console.log('');
  console.log('Environment Variables:');
  console.log(`  VITE_TANGLE_MIGRATION_ADDRESS=${migrationAddress}`);
  console.log('');
  console.log('Files Generated:');
  console.log('  merkle-tree.json  - Merkle tree with proofs');
  console.log('  evm-claims.json   - EVM claims for reference');
}

main().catch(console.error);
