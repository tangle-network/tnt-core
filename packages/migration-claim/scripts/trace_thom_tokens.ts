#!/usr/bin/env ts-node
/**
 * Trace the source of Thom Ivy's extra tokens
 *
 * Thom has 282,905 TNT but only 149,900 in vesting locks.
 * This script traces incoming transfers to find the source of the extra 133,005 TNT.
 */

import { ApiPromise, WsProvider } from '@polkadot/api';
import { decodeAddress, encodeAddress } from '@polkadot/util-crypto';

const TANGLE_PREFIX = 5845;
const RPC_URL = 'wss://rpc.tangle.tools';

// Thom Ivy's address
const THOM_ADDRESS = 'tgDhkcoQaPqWM9NSKr8WjyRmy2gFCnt1tym4RuUR8SUNEH5vD';

// Known addresses for context
const KNOWN_ADDRESSES: Record<string, string> = {
  'tgDbdrEEpQzwCHfS1FCJcWE4QJWXQeTVGhip9HG5Pjwy9wS17': 'Commonwealth Labs',
  'tgDZfvqFUyQJchJL9ank9xt8F4TmCwMV7DmfyGaUqBvvJyHRd': 'Treasury',
};

async function main() {
  console.log('Tracing Thom Ivy token sources...\n');

  const provider = new WsProvider(RPC_URL);
  const api = await ApiPromise.create({ provider });

  const thomPubkey = decodeAddress(THOM_ADDRESS);

  console.log('Target Address:', THOM_ADDRESS);
  console.log('');

  // Get current balance
  const accountInfo = await api.query.system.account(thomPubkey);
  const currentFree = (accountInfo as any).data.free.toBigInt();
  const currentFrozen = (accountInfo as any).data.frozen.toBigInt();
  console.log('Current free balance:', (Number(currentFree) / 1e18).toLocaleString(), 'TNT');
  console.log('Current frozen:', (Number(currentFrozen) / 1e18).toLocaleString(), 'TNT');
  console.log('');

  // Search through recent blocks for transfers to Thom
  // This is limited - for full history we'd need an indexer
  // But we can check the most recent blocks

  const latestHeader = await api.rpc.chain.getHeader();
  const latestBlock = latestHeader.number.toNumber();
  console.log('Latest block:', latestBlock);
  console.log('');

  // Let's try a different approach - query system events for transfer events
  // We'll scan backwards from latest block looking for transfers to Thom

  console.log('=== Scanning recent blocks for transfers to Thom ===\n');

  const BLOCKS_TO_SCAN = 10000; // Scan last 10k blocks
  const startBlock = Math.max(0, latestBlock - BLOCKS_TO_SCAN);

  let totalReceived = BigInt(0);
  const transfers: Array<{block: number, from: string, amount: bigint}> = [];

  for (let blockNum = latestBlock; blockNum >= startBlock; blockNum -= 100) {
    process.stdout.write(`Scanning block ${blockNum}...\r`);

    try {
      const blockHash = await api.rpc.chain.getBlockHash(blockNum);
      const events = await api.query.system.events.at(blockHash);

      for (const record of events as any) {
        const { event } = record;

        if (event.section === 'balances' && event.method === 'Transfer') {
          const [from, to, amount] = event.data;
          const toAddr = encodeAddress(to.toU8a(), TANGLE_PREFIX);

          if (toAddr === THOM_ADDRESS) {
            const fromAddr = encodeAddress(from.toU8a(), TANGLE_PREFIX);
            const amountBigInt = BigInt(amount.toString());
            totalReceived += amountBigInt;
            transfers.push({ block: blockNum, from: fromAddr, amount: amountBigInt });

            const fromLabel = KNOWN_ADDRESSES[fromAddr] || fromAddr.slice(0, 20) + '...';
            console.log(`\nBlock ${blockNum}: Received ${(Number(amountBigInt) / 1e18).toLocaleString()} TNT from ${fromLabel}`);
          }
        }
      }
    } catch (e) {
      // Skip blocks with errors
    }
  }

  console.log('\n\n=== Summary of recent transfers ===');
  console.log(`Scanned blocks ${startBlock} to ${latestBlock}`);
  console.log(`Found ${transfers.length} transfers to Thom`);
  console.log(`Total received in scanned period: ${(Number(totalReceived) / 1e18).toLocaleString()} TNT`);

  // Alternative: Let's also check if there were any claims
  console.log('\n=== Checking claims pallet ===');
  try {
    if (api.query.claims) {
      // Check if Thom has any unclaimed balance
      const claim = await api.query.claims.claims(thomPubkey);
      console.log('Unclaimed balance:', claim.toString());
    }
  } catch (e) {
    console.log('Claims check failed:', (e as Error).message);
  }

  // Check vesting schedules in detail
  console.log('\n=== Vesting Schedules ===');
  try {
    const vesting = await api.query.vesting.vesting(thomPubkey);
    if ((vesting as any).isSome) {
      const schedules = (vesting as any).unwrap();
      console.log('Number of schedules:', schedules.length);
      for (let i = 0; i < schedules.length; i++) {
        const s = schedules[i];
        console.log(`\nSchedule ${i + 1}:`);
        console.log('  Locked:', (Number(s.locked.toBigInt()) / 1e18).toLocaleString(), 'TNT');
        console.log('  Per block:', s.perBlock.toString(), 'wei');
        console.log('  Starting block:', s.startingBlock.toString());
      }
    }
  } catch (e) {
    console.log('Vesting check failed:', (e as Error).message);
  }

  // Let's also check staking rewards
  console.log('\n=== Checking staking status ===');
  try {
    const ledger = await api.query.staking.ledger(thomPubkey);
    if ((ledger as any).isSome) {
      const l = (ledger as any).unwrap();
      console.log('Stash:', l.stash.toString());
      console.log('Total staked:', (Number(l.total.toBigInt()) / 1e18).toLocaleString(), 'TNT');
      console.log('Active:', (Number(l.active.toBigInt()) / 1e18).toLocaleString(), 'TNT');
    } else {
      console.log('No staking ledger found');
    }
  } catch (e) {
    console.log('Staking check failed:', (e as Error).message);
  }

  await api.disconnect();
}

main().catch(console.error);
