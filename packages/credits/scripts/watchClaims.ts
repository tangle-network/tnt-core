/**
 * Watch CreditsClaimed events (polling).
 *
 * Env:
 * - RPC_URL
 * - CREDITS_ADDRESS
 */
import { createPublicClient, http, parseAbiItem } from "viem";

const abiItem = parseAbiItem(
  "event CreditsClaimed(address indexed account, uint256 amount, bytes32 offchainAccountId)"
);

async function main() {
  const rpcUrl = process.env.RPC_URL;
  const creditsAddress = process.env.CREDITS_ADDRESS as `0x${string}` | undefined;
  if (!rpcUrl) throw new Error("RPC_URL required");
  if (!creditsAddress) throw new Error("CREDITS_ADDRESS required");

  const client = createPublicClient({ transport: http(rpcUrl) });

  let fromBlock = await client.getBlockNumber();
  // eslint-disable-next-line no-console
  console.log(`Starting from block ${fromBlock}`);

  // Poll every ~5s
  // eslint-disable-next-line no-constant-condition
  while (true) {
    const toBlock = await client.getBlockNumber();
    if (toBlock >= fromBlock) {
      const logs = await client.getLogs({
        address: creditsAddress,
        event: abiItem,
        fromBlock,
        toBlock,
      });
      for (const log of logs) {
        const { account, amount, offchainAccountId } = log.args as any;
        // eslint-disable-next-line no-console
        console.log(
          JSON.stringify(
            {
              blockNumber: log.blockNumber?.toString(),
              txHash: log.transactionHash,
              account,
              amount: amount?.toString?.() ?? String(amount),
              offchainAccountId,
            },
            null,
            2
          )
        );
      }
      fromBlock = toBlock + 1n;
    }
    await new Promise((r) => setTimeout(r, 5000));
  }
}

main().catch((err) => {
  // eslint-disable-next-line no-console
  console.error(err);
  process.exit(1);
});

