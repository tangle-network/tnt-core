//! Output the verification key for the SR25519 program
//!
//! This is used to get the vkey for deploying the SP1ZKVerifier contract.

use anyhow::Result;
use sp1_sdk::{HashableKey, ProverClient};

const ELF: &[u8] = include_bytes!("../../program/elf/riscv32im-succinct-zkvm-elf");

fn main() -> Result<()> {
    println!("SR25519 Claim Program - Verification Key");
    println!("=========================================");

    let client = ProverClient::from_env();
    let (_pk, vk) = client.setup(ELF);

    let vkey_hex = vk.bytes32();

    println!("\nVerification Key (bytes32):");
    println!("{}", vkey_hex);

    println!("\nUse this value as the `sr25519Vkey` constructor parameter");
    println!("when deploying the SP1ZKVerifier contract.");

    Ok(())
}
