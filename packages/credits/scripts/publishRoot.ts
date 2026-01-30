/**
 * Publish a Credits Merkle root on-chain.
 *
 * Env:
 * - RPC_URL
 * - PRIVATE_KEY
 * - CREDITS_ADDRESS
 *
 * Args:
 * - --epoch-id <uint>
 * - --root <bytes32>
 */
import { createWalletClient, createPublicClient, http, parseAbi } from "viem";
import { privateKeyToAccount } from "viem/accounts";

const parseArgs = () => {
  const args = process.argv.slice(2);
  const out: Record<string, string> = {};
  for (let i = 0; i < args.length; i++) {
    const key = args[i];
    if (!key.startsWith("--")) continue;
    const value = args[i + 1];
    if (!value || value.startsWith("--")) continue;
    out[key.slice(2)] = value;
    i++;
  }
  return out;
};

const abi = parseAbi([
  "function setMerkleRoot(uint256 epochId, bytes32 root) external",
]);

async function main() {
  const rpcUrl = process.env.RPC_URL;
  const pk = process.env.PRIVATE_KEY;
  const creditsAddress = process.env.CREDITS_ADDRESS as `0x${string}` | undefined;
  if (!rpcUrl) throw new Error("RPC_URL required");
  if (!pk) throw new Error("PRIVATE_KEY required");
  if (!creditsAddress) throw new Error("CREDITS_ADDRESS required");

  const args = parseArgs();
  const epochId = args["epoch-id"];
  const root = args["root"] as `0x${string}` | undefined;
  if (!epochId) throw new Error("--epoch-id required");
  if (!root) throw new Error("--root required");

  const account = privateKeyToAccount(pk as `0x${string}`);
  const publicClient = createPublicClient({ transport: http(rpcUrl) });
  const walletClient = createWalletClient({ account, transport: http(rpcUrl) });

  const hash = await walletClient.writeContract({
    address: creditsAddress,
    abi,
    functionName: "setMerkleRoot",
    args: [BigInt(epochId), root],
  });

  // eslint-disable-next-line no-console
  console.log(`tx=${hash}`);
  const receipt = await publicClient.waitForTransactionReceipt({ hash });
  // eslint-disable-next-line no-console
  console.log(`status=${receipt.status}`);
}

main().catch((err) => {
  // eslint-disable-next-line no-console
  console.error(err);
  process.exit(1);
});

