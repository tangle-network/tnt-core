import { Credits } from "generated";
import type { CreditBalance, CreditOperation } from "generated/src/Types.gen";
import {
  ensureCreditLedger,
  ensureCreditLedgerAccount,
  getBlockNumber,
  getEventId,
  getTimestamp,
  getTxHash,
  normalizeAddress,
  toBigInt,
  toHexString,
} from "../lib/handlerUtils";

export function registerCreditHandlers() {
  Credits.CreditsClaimed.handler(async ({ event, context }) => {
    const timestamp = getTimestamp(event);
    const account = normalizeAddress(event.params.account);
    const offchainAccountId = toHexString(event.params.offchainAccountId) || "0x";
    let balance = await context.CreditBalance.get(account);
    if (!balance) {
      balance = {
        id: account,
        account,
        amount: 0n,
        lastUpdatedAt: timestamp,
        claimCount: 0n,
      } as CreditBalance;
    }
    const amount = toBigInt(event.params.amount);
    const updatedBalance: CreditBalance = {
      ...balance,
      amount: (balance.amount ?? 0n) + amount,
      lastUpdatedAt: timestamp,
      claimCount: (balance.claimCount ?? 0n) + 1n,
      firstClaimAt: balance.firstClaimAt ?? timestamp,
      lastClaimAt: timestamp,
    } as CreditBalance;
    context.CreditBalance.set(updatedBalance);
    let ledger = await ensureCreditLedger(context, offchainAccountId, timestamp);
    ledger = {
      ...ledger,
      totalClaimed: (ledger.totalClaimed ?? 0n) + amount,
      claimCount: (ledger.claimCount ?? 0n) + 1n,
      lastClaimAt: timestamp,
    };
    context.CreditLedger.set(ledger);
    let ledgerAccount = await ensureCreditLedgerAccount(context, ledger.id, account, timestamp);
    ledgerAccount = {
      ...ledgerAccount,
      totalClaimed: (ledgerAccount.totalClaimed ?? 0n) + amount,
      claimCount: (ledgerAccount.claimCount ?? 0n) + 1n,
      lastClaimAt: timestamp,
    };
    context.CreditLedgerAccount.set(ledgerAccount);
    const operation: CreditOperation = {
      id: getEventId(event),
      balance_id: account,
      operationType: "CLAIM",
      amount,
      blockNumber: getBlockNumber(event),
      timestamp,
      txHash: getTxHash(event),
      offchainAccountId,
      ledger_id: ledger.id,
      from: offchainAccountId,
      to: account,
    } as CreditOperation;
    context.CreditOperation.set(operation);
  });
}
