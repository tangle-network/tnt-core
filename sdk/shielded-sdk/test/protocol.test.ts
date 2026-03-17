import { describe, it, expect } from "vitest";
import {
  Keypair,
  Utxo,
  MerkleTree,
  poseidonHash,
  poseidonHash2,
  FIELD_SIZE,
  ZERO_VALUE,
  ChainType,
  typedChainId,
  parseTypedChainId,
} from "../src/protocol/index.js";

describe("poseidonHash", () => {
  it("should return a bigint in the BN254 field", async () => {
    const h = await poseidonHash([1n, 2n]);
    expect(typeof h).toBe("bigint");
    expect(h).toBeGreaterThan(0n);
    expect(h).toBeLessThan(FIELD_SIZE);
  });

  it("should be deterministic", async () => {
    const a = await poseidonHash([42n, 100n]);
    const b = await poseidonHash([42n, 100n]);
    expect(a).toBe(b);
  });

  it("should produce different hashes for different inputs", async () => {
    const a = await poseidonHash([1n]);
    const b = await poseidonHash([2n]);
    expect(a).not.toBe(b);
  });

  it("poseidonHash2 should match poseidonHash with two inputs", async () => {
    const a = await poseidonHash([3n, 7n]);
    const b = await poseidonHash2(3n, 7n);
    expect(a).toBe(b);
  });
});

describe("Keypair", () => {
  it("should generate a random keypair", () => {
    const kp = new Keypair();
    expect(kp.privateKey).toBeGreaterThan(0n);
    expect(kp.privateKey).toBeLessThan(FIELD_SIZE);
  });

  it("should derive public key deterministically", async () => {
    const kp = new Keypair(123n);
    const pub1 = await kp.getPublicKey();
    const pub2 = await kp.getPublicKey();
    expect(pub1).toBe(pub2);
    expect(pub1).toBeGreaterThan(0n);
  });

  it("should derive public key as poseidon(privateKey)", async () => {
    const kp = new Keypair(42n);
    const pub = await kp.getPublicKey();
    const expected = await poseidonHash([42n]);
    expect(pub).toBe(expected);
  });

  it("should roundtrip through toString/fromString", async () => {
    const kp = new Keypair(999n);
    const str = kp.toString();
    const restored = Keypair.fromString(str);
    expect(restored.privateKey).toBe(kp.privateKey);
    const pub1 = await kp.getPublicKey();
    const pub2 = await restored.getPublicKey();
    expect(pub1).toBe(pub2);
  });

  it("two random keypairs should differ", () => {
    const a = new Keypair();
    const b = new Keypair();
    expect(a.privateKey).not.toBe(b.privateKey);
  });
});

describe("Utxo", () => {
  it("should compute a commitment deterministically", async () => {
    const kp = new Keypair(10n);
    const chainId = typedChainId(ChainType.EVM, 1);
    const utxo = new Utxo({
      chainId,
      amount: 1000n,
      keypair: kp,
      blinding: 777n,
    });

    const c1 = await utxo.getCommitment();
    const c2 = await utxo.getCommitment();
    expect(c1).toBe(c2);
    expect(c1).toBeGreaterThan(0n);
    expect(c1).toBeLessThan(FIELD_SIZE);
  });

  it("commitment = poseidon(chainId, amount, pubKey, blinding)", async () => {
    const kp = new Keypair(10n);
    const chainId = typedChainId(ChainType.EVM, 1);
    const blinding = 777n;
    const amount = 1000n;
    const utxo = new Utxo({ chainId, amount, keypair: kp, blinding });

    const pubKey = await kp.getPublicKey();
    const expected = await poseidonHash([chainId, amount, pubKey, blinding]);
    const commitment = await utxo.getCommitment();
    expect(commitment).toBe(expected);
  });

  it("different amounts should produce different commitments", async () => {
    const kp = new Keypair(10n);
    const chainId = typedChainId(ChainType.EVM, 1);
    const a = new Utxo({ chainId, amount: 100n, keypair: kp, blinding: 1n });
    const b = new Utxo({ chainId, amount: 200n, keypair: kp, blinding: 1n });
    expect(await a.getCommitment()).not.toBe(await b.getCommitment());
  });

  it("should throw when computing nullifier without index", async () => {
    const kp = new Keypair(10n);
    const utxo = new Utxo({
      chainId: 1n,
      amount: 100n,
      keypair: kp,
      blinding: 1n,
    });
    await expect(utxo.getNullifier()).rejects.toThrow("index must be set");
  });

  it("should compute nullifier when index is set", async () => {
    const kp = new Keypair(10n);
    const utxo = new Utxo({
      chainId: 1n,
      amount: 100n,
      keypair: kp,
      blinding: 1n,
      index: 0,
    });
    const nullifier = await utxo.getNullifier();
    expect(nullifier).toBeGreaterThan(0n);
    expect(nullifier).toBeLessThan(FIELD_SIZE);
  });
});

describe("MerkleTree", () => {
  it("empty tree should have deterministic root", async () => {
    const t1 = await MerkleTree.create(20);
    const t2 = await MerkleTree.create(20);
    expect(t1.root).toBe(t2.root);
  });

  it("should insert leaves and update root", async () => {
    const tree = await MerkleTree.create(20);
    const emptyRoot = tree.root;
    await tree.insert(42n);
    expect(tree.root).not.toBe(emptyRoot);
    expect(tree.nextIndex).toBe(1);
  });

  it("should produce consistent root after multiple inserts", async () => {
    const t1 = await MerkleTree.create(10);
    const t2 = await MerkleTree.create(10);
    await t1.insert(1n);
    await t1.insert(2n);
    await t2.insert(1n);
    await t2.insert(2n);
    expect(t1.root).toBe(t2.root);
  });

  it("should generate valid Merkle proofs", async () => {
    const tree = await MerkleTree.create(10);
    await tree.insert(100n);
    await tree.insert(200n);
    await tree.insert(300n);

    const proof = await tree.proof(1);
    expect(proof.root).toBe(tree.root);
    expect(proof.pathElements).toHaveLength(10);

    // Verify proof by recomputing root from leaf
    let current = 200n; // leaf at index 1
    let idx = 1;
    for (let i = 0; i < proof.pathElements.length; i++) {
      const isRight = (proof.pathIndices >> i) & 1;
      const [left, right] = isRight
        ? [proof.pathElements[i], current]
        : [current, proof.pathElements[i]];
      current = await poseidonHash2(left, right);
      idx = Math.floor(idx / 2);
    }
    expect(current).toBe(proof.root);
  });

  it("should throw for out-of-bounds proof index", async () => {
    const tree = await MerkleTree.create(10);
    await tree.insert(1n);
    await expect(tree.proof(5)).rejects.toThrow("not found");
  });

  it("fromLeaves should match sequential inserts", async () => {
    const leaves = [10n, 20n, 30n];
    const t1 = await MerkleTree.fromLeaves(10, leaves);

    const t2 = await MerkleTree.create(10);
    for (const l of leaves) await t2.insert(l);

    expect(t1.root).toBe(t2.root);
    expect(t1.leaves).toEqual(t2.leaves);
  });

  it("indexOf should find inserted leaves", async () => {
    const tree = await MerkleTree.create(10);
    await tree.insert(111n);
    await tree.insert(222n);
    expect(tree.indexOf(111n)).toBe(0);
    expect(tree.indexOf(222n)).toBe(1);
    expect(tree.indexOf(333n)).toBe(-1);
  });
});

describe("typedChainId", () => {
  it("should encode and decode EVM chain id", () => {
    const typed = typedChainId(ChainType.EVM, 1);
    const { chainType, chainId } = parseTypedChainId(typed);
    expect(chainType).toBe(ChainType.EVM);
    expect(chainId).toBe(1);
  });

  it("should encode and decode Substrate chain id", () => {
    const typed = typedChainId(ChainType.Substrate, 5000);
    const { chainType, chainId } = parseTypedChainId(typed);
    expect(chainType).toBe(ChainType.Substrate);
    expect(chainId).toBe(5000);
  });
});
