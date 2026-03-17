import { randomBytes } from "crypto";
import { poseidonHash } from "./poseidon.js";
import { Keypair } from "./keypair.js";
import { FIELD_SIZE } from "./constants.js";

/// A UTXO (Unspent Transaction Output) in the VAnchor shielded pool.
///
/// commitment = Poseidon(chainId, amount, pubKey, blinding)
/// nullifier  = Poseidon(commitment, merklePath, sign(privKey, commitment, merklePath))
export interface UtxoConfig {
  /// The typed chain ID where this UTXO can be spent
  chainId: bigint;
  /// The token amount
  amount: bigint;
  /// The owner's keypair
  keypair: Keypair;
  /// Random blinding factor (generated if not provided)
  blinding?: bigint;
  /// Merkle tree leaf index (set after deposit confirmation)
  index?: number;
}

export class Utxo {
  readonly chainId: bigint;
  readonly amount: bigint;
  readonly keypair: Keypair;
  readonly blinding: bigint;
  index: number | null;

  private _commitment: bigint | null = null;
  private _nullifier: bigint | null = null;

  constructor(config: UtxoConfig) {
    this.chainId = config.chainId;
    this.amount = config.amount;
    this.keypair = config.keypair;
    this.index = config.index ?? null;

    if (config.blinding !== undefined) {
      this.blinding = config.blinding;
    } else {
      const bytes = randomBytes(31);
      this.blinding =
        BigInt("0x" + Buffer.from(bytes).toString("hex")) % FIELD_SIZE;
    }
  }

  /// Generate a new UTXO with random blinding
  static create(config: UtxoConfig): Utxo {
    return new Utxo(config);
  }

  /// Generate a zero-amount UTXO (used as dummy inputs)
  static async zero(chainId: bigint, keypair: Keypair): Promise<Utxo> {
    return new Utxo({ chainId, amount: 0n, keypair });
  }

  /// Compute the UTXO commitment: Poseidon(chainId, amount, pubKey, blinding)
  async getCommitment(): Promise<bigint> {
    if (this._commitment === null) {
      const pubKey = await this.keypair.getPublicKey();
      this._commitment = await poseidonHash([
        this.chainId,
        this.amount,
        pubKey,
        this.blinding,
      ]);
    }
    return this._commitment;
  }

  /// Compute the nullifier: Poseidon(commitment, pathIndex, signature)
  /// where signature = Poseidon(privKey, commitment, pathIndex)
  async getNullifier(): Promise<bigint> {
    if (this.index === null) {
      throw new Error("Utxo: index must be set to compute nullifier");
    }
    if (this._nullifier === null) {
      const commitment = await this.getCommitment();
      const pathIndex = BigInt(this.index);
      // signature = Poseidon(privKey, commitment, pathIndex)
      const signature = await poseidonHash([
        this.keypair.privateKey,
        commitment,
        pathIndex,
      ]);
      // nullifier = Poseidon(commitment, pathIndex, signature)
      this._nullifier = await poseidonHash([commitment, pathIndex, signature]);
    }
    return this._nullifier;
  }

  /// Serialize the UTXO secrets for storage/backup
  serialize(): string {
    return [
      this.chainId.toString(),
      this.amount.toString(),
      this.keypair.toString(),
      "0x" + this.blinding.toString(16).padStart(62, "0"),
      this.index?.toString() ?? "",
    ].join(":");
  }

  /// Deserialize from a colon-separated string
  static deserialize(str: string): Utxo {
    const [chainId, amount, privKey, blinding, index] = str.split(":");
    return new Utxo({
      chainId: BigInt(chainId),
      amount: BigInt(amount),
      keypair: Keypair.fromString(privKey),
      blinding: BigInt(blinding),
      index: index ? Number(index) : undefined,
    });
  }
}
