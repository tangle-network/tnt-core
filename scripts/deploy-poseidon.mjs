#!/usr/bin/env node
/**
 * Deploy Poseidon hash libraries via circomlibjs bytecode injection.
 * These CANNOT be deployed from Forge — the Solidity stubs are empty.
 * circomlibjs generates the actual Poseidon circuit bytecode at runtime.
 *
 * Usage:
 *   RPC_URL=https://sepolia.base.org PRIVATE_KEY=0x... node scripts/deploy-poseidon.mjs
 *
 * Output:
 *   Writes deployed addresses to deploy/output/poseidon-<chainId>.json
 */
import { ethers } from "ethers";
import { writeFileSync, mkdirSync } from "fs";
import { dirname, join } from "path";
import { fileURLToPath } from "url";

const __dirname = dirname(fileURLToPath(import.meta.url));

async function main() {
  const rpcUrl = process.env.RPC_URL || "http://localhost:8545";
  const privateKey = process.env.PRIVATE_KEY;
  if (!privateKey) {
    console.error("Set PRIVATE_KEY env var");
    process.exit(1);
  }

  const provider = new ethers.JsonRpcProvider(rpcUrl);
  const signer = new ethers.Wallet(privateKey, provider);
  const chainId = (await provider.getNetwork()).chainId;

  console.log(`Deploying Poseidon libraries on chain ${chainId}...`);
  console.log(`Deployer: ${signer.address}`);

  // Dynamic import — circomlibjs is CJS
  const circomlibjs = await import("circomlibjs");
  const genContract = circomlibjs.poseidon_gencontract || circomlibjs.default?.poseidon_gencontract;

  if (!genContract) {
    console.error("circomlibjs.poseidon_gencontract not found. Install: npm i circomlibjs@0.0.8");
    process.exit(1);
  }

  const addresses = {};

  for (let nInputs = 1; nInputs <= 5; nInputs++) {
    const name = `PoseidonT${nInputs + 1}`;
    console.log(`  Deploying ${name} (${nInputs} inputs)...`);

    const abi = genContract.generateABI(nInputs);
    const bytecode = genContract.createCode(nInputs);

    const factory = new ethers.ContractFactory(abi, bytecode, signer);
    const contract = await factory.deploy();
    await contract.waitForDeployment();
    const addr = await contract.getAddress();

    addresses[name] = addr;
    console.log(`    ${name}: ${addr}`);
  }

  // Now deploy PoseidonHasher that links to the libraries
  // PoseidonHasher uses PoseidonT3 for hashLeftRight (2-input Poseidon)
  // For the VAnchor system, the hasher contract is what gets passed to VAnchorTree
  // We need to deploy it with the library addresses linked
  //
  // Since PoseidonHasher references libraries by their deployed address,
  // and Forge can't link libraries at deploy time easily,
  // we deploy a simple wrapper that delegates to the deployed PoseidonT3

  // For now, output the library addresses — the Forge deploy script
  // will use POSEIDON_HASHER env var pointing to a separately deployed hasher
  // that was compiled with forge and linked to these library addresses.

  const outDir = join(__dirname, "../deploy/output");
  mkdirSync(outDir, { recursive: true });
  const outFile = join(outDir, `poseidon-${chainId}.json`);
  writeFileSync(outFile, JSON.stringify(addresses, null, 2));

  console.log(`\nAddresses written to: ${outFile}`);
  console.log(JSON.stringify(addresses, null, 2));

  console.log(`\nNext: deploy PoseidonHasher with forge, linking these libraries:`);
  console.log(`  forge create src/... --libraries PoseidonT2:${addresses.PoseidonT2} ...`);
  console.log(`  Or set POSEIDON_HASHER=<addr> when running DeployShieldedPool.s.sol`);
}

main().catch(err => { console.error(err); process.exit(1); });
