import { randomBytes, createCipheriv, createDecipheriv } from "crypto";
import { poseidonHash } from "./poseidon.js";
import { Keypair } from "./keypair.js";
import { Utxo } from "./utxo.js";

const NONCE_LENGTH = 12;
const TAG_LENGTH = 16;

/// Derive a 32-byte AES key from a keypair's private key using Poseidon.
/// The key is deterministic for a given keypair, allowing only the owner
/// (who knows the private key) to decrypt outputs.
async function deriveEncryptionKey(keypair: Keypair): Promise<Buffer> {
  // Use the private key — the public key is in the commitment and discoverable on-chain
  const h1 = await poseidonHash([keypair.privateKey, 1n]);
  // BN254 field elements are up to 64 hex chars (32 bytes)
  const keyHex = h1.toString(16).padStart(64, "0").slice(0, 64);
  return Buffer.from(keyHex, "hex");
}

/// Encode UTXO secrets into a plaintext buffer: chainId (32B) + amount (32B) + blinding (32B)
function encodeUtxoSecrets(utxo: Utxo): Buffer {
  const buf = Buffer.alloc(96);
  const chainIdHex = utxo.chainId.toString(16).padStart(64, "0");
  const amountHex = utxo.amount.toString(16).padStart(64, "0");
  const blindingHex = utxo.blinding.toString(16).padStart(64, "0");
  Buffer.from(chainIdHex, "hex").copy(buf, 0);
  Buffer.from(amountHex, "hex").copy(buf, 32);
  Buffer.from(blindingHex, "hex").copy(buf, 64);
  return buf;
}

/// Decode UTXO secrets from a plaintext buffer
function decodeUtxoSecrets(buf: Buffer): {
  chainId: bigint;
  amount: bigint;
  blinding: bigint;
} {
  const chainId = BigInt("0x" + buf.subarray(0, 32).toString("hex"));
  const amount = BigInt("0x" + buf.subarray(32, 64).toString("hex"));
  const blinding = BigInt("0x" + buf.subarray(64, 96).toString("hex"));
  return { chainId, amount, blinding };
}

/// Encrypt UTXO secrets (chainId, amount, blinding) using AES-256-GCM.
/// The encryption key is derived from the UTXO owner's keypair.
/// Output format: nonce (12B) || ciphertext || auth tag (16B)
export async function encryptUtxo(utxo: Utxo): Promise<Uint8Array> {
  const key = await deriveEncryptionKey(utxo.keypair);
  const nonce = randomBytes(NONCE_LENGTH);
  const plaintext = encodeUtxoSecrets(utxo);

  const cipher = createCipheriv("aes-256-gcm", key, nonce);
  const encrypted = Buffer.concat([cipher.update(plaintext), cipher.final()]);
  const tag = cipher.getAuthTag();

  return new Uint8Array(Buffer.concat([nonce, encrypted, tag]));
}

/// Attempt to decrypt an encrypted output using the given keypair.
/// Returns a Utxo if decryption succeeds (the output belongs to this keypair),
/// or null if the ciphertext was not encrypted for this keypair.
export async function decryptUtxo(
  ciphertext: Uint8Array,
  keypair: Keypair,
  chainId: bigint
): Promise<Utxo | null> {
  try {
    const buf = Buffer.from(ciphertext);
    if (buf.length < NONCE_LENGTH + TAG_LENGTH + 1) {
      return null;
    }

    const key = await deriveEncryptionKey(keypair);
    const nonce = buf.subarray(0, NONCE_LENGTH);
    const encrypted = buf.subarray(NONCE_LENGTH, buf.length - TAG_LENGTH);
    const tag = buf.subarray(buf.length - TAG_LENGTH);

    const decipher = createDecipheriv("aes-256-gcm", key, nonce);
    decipher.setAuthTag(tag);
    const plaintext = Buffer.concat([
      decipher.update(encrypted),
      decipher.final(),
    ]);

    const secrets = decodeUtxoSecrets(plaintext);

    return new Utxo({
      chainId: secrets.chainId,
      amount: secrets.amount,
      keypair,
      blinding: secrets.blinding,
    });
  } catch {
    // Decryption failed — this output is not ours
    return null;
  }
}
