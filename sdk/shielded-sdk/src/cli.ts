#!/usr/bin/env node
/**
 * Tangle Shielded Payments CLI
 *
 * Usage:
 *   npx tsx sdk/shielded-sdk/src/cli.ts <command> [options]
 *
 * Commands:
 *   keygen              Generate ephemeral credit account keys
 *   authorize-spend     Sign a spend authorization for a job
 *   claim               Claim payment as an operator
 *   withdraw            Withdraw remaining credits
 *   balance             Check credit account balance
 *   setup-circuits      Download and cache circuit artifacts
 */

import { ethers } from "ethers";
import {
  generateCreditKeys,
  signSpendAuthorization,
  signWithdrawal,
  ShieldedCreditsClient,
} from "./contract/credits-client.js";
import { getCircuitArtifacts } from "./proof/artifacts.js";

const CREDITS_ABI = [
  "function getAccount(bytes32 commitment) external view returns (tuple(address spendingKey, address token, uint256 balance, uint256 totalFunded, uint256 totalSpent, uint256 nonce))",
  "function DOMAIN_SEPARATOR() external view returns (bytes32)",
];

// ─── Helpers ──────────────────────────────────────────────────────────────

function getArg(args: string[], flag: string): string | undefined {
  const idx = args.indexOf(flag);
  return idx >= 0 ? args[idx + 1] : undefined;
}

function requireArg(args: string[], flag: string, desc: string): string {
  const val = getArg(args, flag);
  if (!val) {
    console.error(`Missing required argument: ${flag} (${desc})`);
    process.exit(1);
  }
  return val;
}

function getProvider(args: string[]): ethers.JsonRpcProvider {
  const rpc = getArg(args, "--rpc") ?? process.env.RPC_URL ?? "http://localhost:8545";
  return new ethers.JsonRpcProvider(rpc);
}

function getSigner(args: string[]): ethers.Wallet {
  const key = getArg(args, "--private-key") ?? process.env.PRIVATE_KEY;
  if (!key) {
    console.error("Missing --private-key or PRIVATE_KEY env var");
    process.exit(1);
  }
  return new ethers.Wallet(key, getProvider(args));
}

// ─── Commands ─────────────────────────────────────────────────────────────

async function cmdKeygen() {
  const keys = generateCreditKeys();
  console.log(JSON.stringify(keys, null, 2));
  console.log("\nSave the spendingPrivateKey securely. The commitment goes on-chain.");
}

async function cmdBalance(args: string[]) {
  const credits = requireArg(args, "--credits", "ShieldedCredits contract address");
  const commitment = requireArg(args, "--commitment", "Credit account commitment");
  const provider = getProvider(args);

  const contract = new ethers.Contract(credits, CREDITS_ABI, provider);
  const acct = await contract.getAccount(commitment);

  console.log({
    spendingKey: acct.spendingKey,
    token: acct.token,
    balance: ethers.formatEther(acct.balance),
    totalFunded: ethers.formatEther(acct.totalFunded),
    totalSpent: ethers.formatEther(acct.totalSpent),
    nonce: acct.nonce.toString(),
  });
}

async function cmdAuthorizeSpend(args: string[]) {
  const creditsAddr = requireArg(args, "--credits", "ShieldedCredits contract address");
  const privKey = requireArg(args, "--spending-key", "Ephemeral spending private key");
  const commitment = requireArg(args, "--commitment", "Credit account commitment");
  const serviceId = BigInt(requireArg(args, "--service-id", "Service ID"));
  const jobIndex = Number(requireArg(args, "--job-index", "Job index"));
  const amount = ethers.parseEther(requireArg(args, "--amount", "Amount in tokens"));
  const operator = requireArg(args, "--operator", "Designated operator address");
  const expirySeconds = Number(getArg(args, "--expiry") ?? "3600");

  const signer = getSigner(args);
  const client = new ShieldedCreditsClient(creditsAddr, signer);

  const { authHash, spendAuth } = await client.authorizeSpend({
    spendingPrivateKey: privKey,
    commitment,
    serviceId,
    jobIndex,
    amount,
    operator,
    expirySeconds,
  });

  console.log({
    authHash,
    nonce: spendAuth.nonce.toString(),
    amount: ethers.formatEther(spendAuth.amount),
    operator: spendAuth.operator,
    expiry: new Date(Number(spendAuth.expiry) * 1000).toISOString(),
  });
}

async function cmdClaim(args: string[]) {
  const creditsAddr = requireArg(args, "--credits", "ShieldedCredits contract address");
  const authHash = requireArg(args, "--auth-hash", "Spend authorization hash");
  const recipient = requireArg(args, "--recipient", "Payment recipient address");

  const signer = getSigner(args);
  const client = new ShieldedCreditsClient(creditsAddr, signer);
  const receipt = await client.claimPayment(authHash, recipient);
  console.log("Payment claimed. TX:", receipt.hash);
}

async function cmdWithdraw(args: string[]) {
  const creditsAddr = requireArg(args, "--credits", "ShieldedCredits contract address");
  const privKey = requireArg(args, "--spending-key", "Ephemeral spending private key");
  const commitment = requireArg(args, "--commitment", "Credit account commitment");
  const recipient = requireArg(args, "--recipient", "Withdrawal recipient");
  const amount = ethers.parseEther(requireArg(args, "--amount", "Amount to withdraw"));

  const signer = getSigner(args);
  const client = new ShieldedCreditsClient(creditsAddr, signer);
  const receipt = await client.withdraw({
    spendingPrivateKey: privKey,
    commitment,
    recipient,
    amount,
  });
  console.log("Withdrawal complete. TX:", receipt.hash);
}

async function cmdSetupCircuits(args: string[]) {
  const inputs = (Number(getArg(args, "--inputs") ?? "2") as 2 | 16);
  const maxEdges = (Number(getArg(args, "--max-edges") ?? "2") as 2 | 8);
  const cacheDir = getArg(args, "--cache-dir");

  console.log(`Downloading circuit artifacts (${inputs}-input, ${maxEdges}-edge)...`);
  const artifacts = await getCircuitArtifacts(inputs, maxEdges, cacheDir);
  console.log("WASM:", artifacts.wasmPath);
  console.log("ZKey:", artifacts.zkeyPath);
}

// ─── Main ─────────────────────────────────────────────────────────────────

const HELP = `
Tangle Shielded Payments CLI

Usage: npx tsx cli.ts <command> [options]

Commands:
  keygen                  Generate ephemeral credit account keys
  balance                 Check credit account balance
  authorize-spend         Sign and submit a spend authorization
  claim                   Claim payment for a completed job
  withdraw                Withdraw remaining credits
  setup-circuits          Download and cache circuit artifacts

Global options:
  --rpc <url>             RPC endpoint (default: $RPC_URL or localhost:8545)
  --private-key <key>     Transaction signer private key (default: $PRIVATE_KEY)

Examples:
  # Generate keys for a new credit account
  npx tsx cli.ts keygen

  # Check balance
  npx tsx cli.ts balance --credits 0x... --commitment 0x... --rpc https://sepolia.base.org

  # Authorize a 1 ETH spend for a job
  npx tsx cli.ts authorize-spend \\
    --credits 0x... --spending-key 0x... --commitment 0x... \\
    --service-id 1 --job-index 0 --amount 1 --operator 0x... \\
    --private-key 0x... --rpc https://sepolia.base.org
`;

async function main() {
  const args = process.argv.slice(2);
  const command = args[0];

  switch (command) {
    case "keygen":
      await cmdKeygen();
      break;
    case "balance":
      await cmdBalance(args);
      break;
    case "authorize-spend":
      await cmdAuthorizeSpend(args);
      break;
    case "claim":
      await cmdClaim(args);
      break;
    case "withdraw":
      await cmdWithdraw(args);
      break;
    case "setup-circuits":
      await cmdSetupCircuits(args);
      break;
    default:
      console.log(HELP);
      break;
  }
}

main().catch((err) => {
  console.error("Error:", err.message);
  process.exit(1);
});
