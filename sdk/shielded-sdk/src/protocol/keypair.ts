import { randomBytes } from "crypto";
import { poseidonHash } from "./poseidon.js";
import { FIELD_SIZE } from "./constants.js";

/// A shielded keypair for VAnchor UTXO ownership.
///
/// - Private key: random 32-byte scalar in the BN254 field
/// - Public key: poseidon(privateKey)
/// - The private key is used to sign nullifiers (proving ownership)
/// - The public key is embedded in UTXO commitments
export class Keypair {
  readonly privateKey: bigint;

  private _publicKey: bigint | null = null;

  constructor(privateKey?: bigint | string) {
    if (privateKey === undefined) {
      // Generate a random private key in the field
      const bytes = randomBytes(32);
      this.privateKey =
        BigInt("0x" + Buffer.from(bytes).toString("hex")) % FIELD_SIZE;
    } else if (typeof privateKey === "string") {
      this.privateKey = BigInt(privateKey) % FIELD_SIZE;
    } else {
      this.privateKey = privateKey % FIELD_SIZE;
    }
  }

  /// Derive the public key (lazy, cached)
  async getPublicKey(): Promise<bigint> {
    if (this._publicKey === null) {
      this._publicKey = await poseidonHash([this.privateKey]);
    }
    return this._publicKey;
  }

  /// Serialize the keypair for storage
  toString(): string {
    return "0x" + this.privateKey.toString(16).padStart(64, "0");
  }

  /// Deserialize from a hex string
  static fromString(hex: string): Keypair {
    return new Keypair(BigInt(hex));
  }
}
