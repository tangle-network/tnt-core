//! SR25519 signature verification
//!
//! Verifies signatures using the same logic as the SP1 program to ensure
//! early rejection of invalid signatures before expensive proof generation.

use schnorrkel::{signing_context, PublicKey, Signature};

/// The signing context used by Substrate for SR25519 signatures
/// This must match what the polkadot.js extension uses
const SUBSTRATE_CONTEXT: &[u8] = b"substrate";

/// Substrate wallet extensions wrap messages with <Bytes>...</Bytes> when signing
/// with signRaw({ type: 'bytes' }). We must wrap the challenge the same way.
const WRAP_PREFIX: &[u8] = b"<Bytes>";
const WRAP_POSTFIX: &[u8] = b"</Bytes>";

/// Verify an SR25519 signature over a challenge
///
/// The signature verification matches exactly what the SP1 program does:
/// 1. Create signing context with "substrate"
/// 2. Wrap challenge with <Bytes>...</Bytes>
/// 3. Verify signature against wrapped challenge
///
/// # Arguments
/// * `pubkey` - 32-byte SR25519 public key (derived from SS58 address)
/// * `signature` - 64-byte SR25519 signature
/// * `challenge` - 32-byte challenge (the keccak256 hash that was signed)
///
/// # Returns
/// * `Ok(())` - Signature is valid
/// * `Err(String)` - Signature verification failed with reason
pub fn verify_signature(
    pubkey: &[u8; 32],
    signature: &[u8; 64],
    challenge: &[u8; 32],
) -> Result<(), String> {
    // Parse the SR25519 public key
    let public_key =
        PublicKey::from_bytes(pubkey).map_err(|e| format!("Invalid public key: {}", e))?;

    // Parse the signature
    let sig =
        Signature::from_bytes(signature).map_err(|e| format!("Invalid signature format: {}", e))?;

    // Create the signing context (must match what was used to sign)
    let ctx = signing_context(SUBSTRATE_CONTEXT);

    // Wrap the challenge with <Bytes>...</Bytes> as Substrate wallet extensions do
    // when using signRaw with type: 'bytes'
    //
    // IMPORTANT: This must match exactly what the SP1 program does.
    // The SP1 program wraps the raw challenge bytes, not the hex string.
    // See: sp1/program/src/main.rs lines 56-63
    let mut wrapped_challenge =
        Vec::with_capacity(WRAP_PREFIX.len() + challenge.len() + WRAP_POSTFIX.len());
    wrapped_challenge.extend_from_slice(WRAP_PREFIX);
    wrapped_challenge.extend_from_slice(challenge);
    wrapped_challenge.extend_from_slice(WRAP_POSTFIX);

    // Verify the signature over the wrapped challenge
    public_key
        .verify(ctx.bytes(&wrapped_challenge), &sig)
        .map_err(|_| "Signature verification failed".to_string())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_wrapping_format() {
        // The wrapping should match SP1 program exactly
        let challenge: [u8; 4] = [0x12, 0x34, 0x56, 0x78];
        let mut wrapped = Vec::new();
        wrapped.extend_from_slice(WRAP_PREFIX);
        wrapped.extend_from_slice(&challenge);
        wrapped.extend_from_slice(WRAP_POSTFIX);

        // Should be: <Bytes> + raw bytes + </Bytes>
        assert_eq!(wrapped.len(), 7 + 4 + 8); // "<Bytes>" + 4 bytes + "</Bytes>"
        assert!(wrapped.starts_with(b"<Bytes>"));
        assert!(wrapped.ends_with(b"</Bytes>"));
    }

    #[test]
    fn test_invalid_pubkey() {
        let invalid_pubkey = [0u8; 32]; // All zeros is not a valid curve point
        let signature = [0u8; 64];
        let challenge = [0u8; 32];

        let result = verify_signature(&invalid_pubkey, &signature, &challenge);
        // Should fail with invalid public key or signature verification failed
        assert!(result.is_err());
    }
}
