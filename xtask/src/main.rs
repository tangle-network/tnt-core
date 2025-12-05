use anyhow::{anyhow, Context, Result};
use std::env;
use std::fs;
use std::path::{Path, PathBuf};
use std::process::Command;

fn main() -> Result<()> {
    let mut args = env::args().skip(1);
    match args.next().as_deref() {
        Some("gen-bindings") | None => gen_bindings(),
        Some(cmd) => Err(anyhow!("unknown xtask command `{cmd}`")),
    }
}

fn gen_bindings() -> Result<()> {
    let repo_root = workspace_root()?;
    let bindings_crate = repo_root.join("bindings");
    let generated_dir = bindings_crate.join("src/bindings");
    if generated_dir.exists() {
        fs::remove_dir_all(&generated_dir)
            .with_context(|| format!("failed to clean {}", generated_dir.display()))?;
    }
    fs::create_dir_all(&generated_dir)
        .with_context(|| format!("failed to create {}", generated_dir.display()))?;

    // Rebuild contracts to make sure artifacts + ABIs reflect the latest sources.
    run(
        Command::new("forge")
            .current_dir(&repo_root)
            .arg("build")
            .arg("--force")
            .arg("--skip")
            .arg("test"),
    )?;

    // Generate alloy bindings that are compatible with alloy 1.0.
    let bindings_version = read_binding_version(&bindings_crate)?;
    run(
        Command::new("forge")
            .current_dir(&bindings_crate)
            .args([
                "bind",
                "--module",
                "--overwrite",
                "--bindings-path",
                "src/bindings",
                "--crate-name",
                "tnt_core_bindings",
                "--crate-version",
                &bindings_version,
                "--alloy-version",
                "1.0.0",
            ])
            .args([
                "--select",
                "ITangle",
                "--select",
                "IBlueprintServiceManager",
                "--select",
                "MultiAssetDelegation",
                "--select",
                "IOperatorStatusRegistry",
            ]),
    )?;

    // Copy the ABIs that blueprint-sdk consumes downstream.
    let abi_dir = bindings_crate.join("abi");
    if abi_dir.exists() {
        fs::remove_dir_all(&abi_dir)
            .with_context(|| format!("failed to clean {}", abi_dir.display()))?;
    }
    fs::create_dir_all(&abi_dir)
        .with_context(|| format!("failed to create {}", abi_dir.display()))?;

    for (name, source) in [
        ("ITangle.json", "out/ITangle.sol/ITangle.json"),
        (
            "IBlueprintServiceManager.json",
            "out/IBlueprintServiceManager.sol/IBlueprintServiceManager.json",
        ),
        (
            "IOperatorStatusRegistry.json",
            "out/OperatorStatusRegistry.sol/OperatorStatusRegistry.json",
        ),
        (
            "MultiAssetDelegation.json",
            "out/MultiAssetDelegation.sol/MultiAssetDelegation.json",
        ),
    ] {
        let src = repo_root.join(source);
        let dst = abi_dir.join(name);
        fs::copy(&src, &dst).with_context(|| {
            format!(
                "failed to copy ABI from {} to {}",
                src.display(),
                dst.display()
            )
        })?;
    }

    // Record the git commit hash so downstream consumers can detect ABI drift.
    let git_rev = Command::new("git")
        .current_dir(&repo_root)
        .args(["rev-parse", "HEAD"])
        .output()
        .context("failed to query git rev")?;
    if !git_rev.status.success() {
        return Err(anyhow!("git rev-parse failed with {}", git_rev.status));
    }
    let version = String::from_utf8(git_rev.stdout)?.trim().to_string();
    fs::write(bindings_crate.join("TNT_CORE_VERSION"), &version)
        .context("failed to write TNT_CORE_VERSION")?;

    println!(
        "✅ bindings refreshed at {} (commit {version})",
        generated_dir.display()
    );
    Ok(())
}

fn run(cmd: &mut Command) -> Result<()> {
    let status = cmd.status().with_context(|| format!("failed to run {:?}", cmd))?;
    if !status.success() {
        return Err(anyhow!(
            "command {:?} exited with status {status}",
            cmd.get_args().collect::<Vec<_>>()
        ));
    }
    Ok(())
}

fn workspace_root() -> Result<PathBuf> {
    let manifest_dir = Path::new(env!("CARGO_MANIFEST_DIR"));
    manifest_dir
        .parent()
        .map(Path::to_path_buf)
        .ok_or_else(|| anyhow!("failed to compute workspace root"))
}

fn read_binding_version(bindings_crate: &Path) -> Result<String> {
    let manifest = fs::read_to_string(bindings_crate.join("Cargo.toml"))
        .context("failed to read bindings/Cargo.toml")?;
    for line in manifest.lines() {
        let trimmed = line.trim();
        if trimmed.starts_with("version") {
            let parts: Vec<_> = trimmed.split('=').collect();
            if parts.len() == 2 {
                return Ok(parts[1].trim().trim_matches('"').to_string());
            }
        }
    }
    Err(anyhow!("failed to parse bindings version"))
}
