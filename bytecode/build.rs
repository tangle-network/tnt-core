use std::env;
use std::fs;
use std::path::Path;
use std::process::Command;

fn to_screaming_snake_case(name: &str) -> String {
    let mut result = String::new();
    let mut prev_char_is_lowercase = false;

    for (i, c) in name.chars().enumerate() {
        if i > 0
            && c.is_uppercase()
            && (prev_char_is_lowercase
                || (i + 1 < name.len() && name.chars().nth(i + 1).unwrap().is_lowercase()))
        {
            result.push('_');
        }
        result.push(c.to_ascii_uppercase());
        prev_char_is_lowercase = c.is_lowercase();
    }
    result
}

fn main() {
    // Only run the build script if the build-script feature is enabled
    if env::var("CARGO_FEATURE_BUILD_SCRIPT").is_err() {
        return;
    }

    // Your existing build script logic here
    println!("cargo:rerun-if-changed=build.rs");
    println!("cargo:rerun-if-changed=../src");

    // Run forge build
    let status = Command::new("forge")
        .arg("build")
        .current_dir("..")
        .status()
        .expect("Failed to build contracts");

    if !status.success() {
        panic!("Failed to build contracts");
    }

    // List of contracts to generate bytecode for
    let contracts = vec!["MasterBlueprintServiceManager"];

    let mut rust_code = String::from(
        r#"//! TNT Core contract bytecode exports
//!
//! This crate exports the bytecode of TNT Core contracts as constant byte vectors
//! that can be easily imported and used in other Rust projects.

/// Module containing all contract bytecodes
#[rustfmt::skip]
pub mod bytecode {
"#,
    );

    for contract in contracts {
        let json_path = Path::new("..")
            .join("out")
            .join(format!("{}.sol", contract))
            .join(format!("{}.json", contract));

        let json_str = fs::read_to_string(&json_path)
            .unwrap_or_else(|_| panic!("Failed to read {}", json_path.display()));

        let json: serde_json::Value =
            serde_json::from_str(&json_str).expect("Failed to parse JSON");

        let bytecode = json["bytecode"]
            .as_object()
            .and_then(|obj| obj.get("object"))
            .and_then(|obj| obj.as_str())
            .unwrap_or_else(|| json["bytecode"].as_str().expect("Failed to get bytecode"));

        let bytecode = bytecode.strip_prefix("0x").unwrap_or(bytecode);
        let bytes: Vec<String> = bytecode
            .as_bytes()
            .chunks(2)
            .map(|chunk| {
                let hex = std::str::from_utf8(chunk).unwrap();
                format!("0x{}", hex)
            })
            .collect();

        let const_name = to_screaming_snake_case(contract);

        rust_code.push_str(&format!(
            r#"    /// Bytecode for the {} contract
    pub const {}: &[u8] = &[{}];

"#,
            contract,
            const_name,
            bytes.join(", ")
        ));
    }

    rust_code.push_str(
        r#"}
"#,
    );

    // Write directly to lib.rs
    fs::write(Path::new("src").join("lib.rs"), rust_code).expect("Failed to write to lib.rs");
}
