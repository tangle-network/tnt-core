//! Output the verification key for the SR25519 program
//!
//! This is used to get the vkey for deploying the SP1ZKVerifier contract.

use anyhow::Result;
use sp1_sdk::blocking::{Prover, ProverClient};
use sp1_sdk::{include_elf, HashableKey, ProvingKey};

const ELF: sp1_sdk::Elf = include_elf!("sr25519-claim-program");

fn main() -> Result<()> {
    println!("SR25519 Claim Program - Verification Key");
    println!("=========================================");

    let client = ProverClient::from_env();
    let pk = client.setup(ELF)?;

    let vkey_hex = pk.verifying_key().bytes32();

    println!("\nVerification Key (bytes32):");
    println!("{}", vkey_hex);

    println!("\nUse this value as the `sr25519Vkey` constructor parameter");
    println!("when deploying the SP1ZKVerifier contract.");

    Ok(())
}
