use anyhow::{anyhow, Context, Result};
use std::env;
use std::fs;
use std::io::{self, Write};
use std::path::{Path, PathBuf};
use std::process::Command;
use std::time::Instant;

fn main() -> Result<()> {
    let mut args = env::args().skip(1);
    match args.next().as_deref() {
        Some("gen-bindings") | None => gen_bindings(),
        Some("bump-version") => {
            let version = args
                .next()
                .ok_or_else(|| anyhow!("usage: cargo xtask bump-version <version>"))?;
            bump_version(&version)
        }
        Some("publish") => publish(),
        Some(cmd) => Err(anyhow!("unknown xtask command `{cmd}`")),
    }
}

fn gen_bindings() -> Result<()> {
    let total_start = Instant::now();

    println!("╔════════════════════════════════════════════════════════════╗");
    println!("║           TNT-CORE BINDINGS GENERATOR                      ║");
    println!("╚════════════════════════════════════════════════════════════╝");
    println!();

    let repo_root = workspace_root()?;
    let bindings_crate = repo_root.join("bindings");
    let generated_dir = bindings_crate.join("src/bindings");

    // Step 1: Clean directories
    print_step(1, 5, "Cleaning generated directories...");
    if generated_dir.exists() {
        fs::remove_dir_all(&generated_dir)
            .with_context(|| format!("failed to clean {}", generated_dir.display()))?;
    }
    fs::create_dir_all(&generated_dir)
        .with_context(|| format!("failed to create {}", generated_dir.display()))?;
    print_done();

    // Step 2: Build contracts
    print_step(
        2,
        5,
        "Building Solidity contracts (this may take a while)...",
    );
    let build_start = Instant::now();
    run_with_progress(
        Command::new("forge")
            .current_dir(&repo_root)
            .arg("build")
            .arg("--skip")
            .arg("test")
            .arg("-j")
            .arg("0")
            .args([
                "src/v2/interfaces/ITangle.sol",
                "src/v2/interfaces/ITangleBlueprints.sol",
                "src/v2/interfaces/IBlueprintServiceManager.sol",
                "src/v2/restaking/OperatorStatusRegistry.sol",
                "src/v2/restaking/MultiAssetDelegation.sol",
            ]),
        "forge build",
    )?;
    println!(
        "   ✓ Compiled in {:.1}s",
        build_start.elapsed().as_secs_f64()
    );

    // Step 3: Generate bindings
    print_step(3, 5, "Generating Alloy Rust bindings...");
    let bind_start = Instant::now();
    let bindings_version = read_binding_version(&bindings_crate)?;
    run_with_progress(
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
                "ITangleBlueprints",
                "--select",
                "IBlueprintServiceManager",
                "--select",
                "MultiAssetDelegation",
                "--select",
                "IOperatorStatusRegistry",
            ]),
        "forge bind",
    )?;
    println!(
        "   ✓ Generated bindings in {:.1}s",
        bind_start.elapsed().as_secs_f64()
    );

    // Step 4: Copy ABIs
    print_step(4, 5, "Copying ABI files...");
    let abi_dir = bindings_crate.join("abi");
    if abi_dir.exists() {
        fs::remove_dir_all(&abi_dir)
            .with_context(|| format!("failed to clean {}", abi_dir.display()))?;
    }
    fs::create_dir_all(&abi_dir)
        .with_context(|| format!("failed to create {}", abi_dir.display()))?;

    let abi_files = [
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
    ];

    for (i, (name, source)) in abi_files.iter().enumerate() {
        let src = repo_root.join(source);
        let dst = abi_dir.join(name);
        fs::copy(&src, &dst).with_context(|| {
            format!(
                "failed to copy ABI from {} to {}",
                src.display(),
                dst.display()
            )
        })?;
        print!("\r   Copied {}/{} ABIs", i + 1, abi_files.len());
        let _ = io::stdout().flush();
    }
    println!();
    print_done();

    // Step 5: Record version
    print_step(5, 5, "Recording git version...");
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
    print_done();

    // Summary
    println!();
    println!("╔════════════════════════════════════════════════════════════╗");
    println!("║                    ✅ COMPLETE                             ║");
    println!("╚════════════════════════════════════════════════════════════╝");
    println!();
    println!("   📁 Bindings: {}", generated_dir.display());
    println!("   📁 ABIs:     {}", abi_dir.display());
    println!("   🔖 Commit:   {}", &version[..12]);
    println!(
        "   ⏱️  Total:    {:.1}s",
        total_start.elapsed().as_secs_f64()
    );
    println!();

    Ok(())
}

fn run_with_progress(cmd: &mut Command, description: &str) -> Result<()> {
    use std::process::Stdio;
    use std::sync::atomic::{AtomicBool, Ordering};
    use std::sync::Arc;
    use std::thread;

    let running = Arc::new(AtomicBool::new(true));
    let running_clone = running.clone();

    // Spinner thread
    let spinner_handle = thread::spawn(move || {
        let frames = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"];
        let mut i = 0;
        while running_clone.load(Ordering::Relaxed) {
            print!("\r   {} Working...", frames[i % frames.len()]);
            let _ = io::stdout().flush();
            thread::sleep(std::time::Duration::from_millis(100));
            i += 1;
        }
        print!("\r                    \r"); // Clear spinner
        let _ = io::stdout().flush();
    });

    // Run the command
    let child = cmd
        .stdout(Stdio::piped())
        .stderr(Stdio::piped())
        .spawn()
        .with_context(|| format!("failed to spawn {}", description))?;

    // Wait for completion
    let output = child
        .wait_with_output()
        .with_context(|| format!("failed to wait for {}", description))?;

    // Stop spinner
    running.store(false, Ordering::Relaxed);
    let _ = spinner_handle.join();

    if !output.status.success() {
        // Print stderr on failure
        let stderr = String::from_utf8_lossy(&output.stderr);
        if !stderr.is_empty() {
            eprintln!("\n   Error output:\n{}", stderr);
        }
        return Err(anyhow!(
            "{} failed with status {}",
            description,
            output.status
        ));
    }

    Ok(())
}

fn print_step(step: usize, total: usize, message: &str) {
    println!("[{}/{}] {}", step, total, message);
}

fn print_done() {
    println!("   ✓ Done");
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

fn bump_version(version: &str) -> Result<()> {
    // Validate semver format
    let parts: Vec<&str> = version.split('.').collect();
    if parts.len() != 3 || !parts.iter().all(|p| p.parse::<u32>().is_ok()) {
        return Err(anyhow!(
            "invalid version format: expected MAJOR.MINOR.PATCH (e.g., 0.2.0)"
        ));
    }

    let repo_root = workspace_root()?;
    let bindings_crate = repo_root.join("bindings");
    let old_version = read_binding_version(&bindings_crate)?;

    println!("╔════════════════════════════════════════════════════════════╗");
    println!("║           TNT-CORE VERSION BUMP                            ║");
    println!("╚════════════════════════════════════════════════════════════╝");
    println!();

    // Step 1: Update Cargo.toml version
    print_step(1, 3, "Updating Cargo.toml version...");
    let cargo_toml_path = bindings_crate.join("Cargo.toml");
    let cargo_toml = fs::read_to_string(&cargo_toml_path).context("failed to read Cargo.toml")?;

    let mut updated_toml = String::new();
    let mut in_package = false;
    let mut version_updated = false;

    for line in cargo_toml.lines() {
        if line.trim() == "[package]" {
            in_package = true;
        } else if line.trim().starts_with('[') {
            in_package = false;
        }

        if in_package && line.trim().starts_with("version") && !version_updated {
            updated_toml.push_str(&format!("version = \"{}\"\n", version));
            version_updated = true;
        } else {
            updated_toml.push_str(line);
            updated_toml.push('\n');
        }
    }

    if !version_updated {
        return Err(anyhow!("failed to find version field in Cargo.toml"));
    }

    fs::write(&cargo_toml_path, updated_toml).context("failed to write Cargo.toml")?;
    print_done();

    // Step 2: Update CHANGELOG.md
    print_step(2, 3, "Updating CHANGELOG.md...");
    let changelog_path = bindings_crate.join("CHANGELOG.md");
    let changelog = fs::read_to_string(&changelog_path).context("failed to read CHANGELOG.md")?;

    let today = chrono_lite_today();
    let new_entry = format!(
        "## [{}] - {}\n\n### Changed\n\n- Updated bindings from TNT Core contracts\n",
        version, today
    );

    let updated_changelog = changelog.replace(
        "## [Unreleased]\n",
        &format!("## [Unreleased]\n\n{}", new_entry),
    );

    // Update the links at the bottom.
    // - Always set Unreleased to compare from the new tag.
    // - Ensure the new version link exists, comparing old -> new.
    let mut lines: Vec<String> = updated_changelog.lines().map(|l| l.to_string()).collect();
    for line in &mut lines {
        if line.starts_with("[Unreleased]: ") {
            *line = format!(
                "[Unreleased]: https://github.com/tangle-network/tnt-core/compare/bindings-v{}...HEAD",
                version
            );
        }
    }
    let release_link_prefix = format!("[{}]: ", version);
    if !lines.iter().any(|l| l.starts_with(&release_link_prefix)) {
        lines.push(format!(
            "[{}]: https://github.com/tangle-network/tnt-core/compare/bindings-v{}...bindings-v{}",
            version, old_version, version
        ));
    }
    let updated_changelog = format!("{}\n", lines.join("\n"));

    fs::write(&changelog_path, updated_changelog).context("failed to write CHANGELOG.md")?;
    print_done();

    // Step 3: Create git tag suggestion
    print_step(3, 3, "Preparing release...");
    print_done();

    println!();
    println!("╔════════════════════════════════════════════════════════════╗");
    println!("║                    ✅ VERSION BUMPED                       ║");
    println!("╚════════════════════════════════════════════════════════════╝");
    println!();
    println!("   📦 New version: {}", version);
    println!();
    println!("   Next steps:");
    println!("   1. Review changes: git diff bindings/");
    println!(
        "   2. Commit: git commit -am \"chore(bindings): release v{}\"",
        version
    );
    println!("   3. Tag: git tag bindings-v{}", version);
    println!("   4. Push: git push origin v2 --tags");
    println!("   5. Publish: cargo xtask publish");
    println!();

    Ok(())
}

fn publish() -> Result<()> {
    let repo_root = workspace_root()?;
    let bindings_crate = repo_root.join("bindings");

    println!("╔════════════════════════════════════════════════════════════╗");
    println!("║           TNT-CORE PUBLISH TO CRATES.IO                    ║");
    println!("╚════════════════════════════════════════════════════════════╝");
    println!();

    let version = read_binding_version(&bindings_crate)?;
    println!("   Publishing version: {}", version);
    println!();

    // Step 1: Verify we have a clean git state
    print_step(1, 4, "Checking git status...");
    let status = Command::new("git")
        .current_dir(&repo_root)
        .args(["status", "--porcelain", "bindings/"])
        .output()
        .context("failed to run git status")?;

    if !status.stdout.is_empty() {
        return Err(anyhow!(
            "bindings/ has uncommitted changes. Commit them first."
        ));
    }
    print_done();

    // Step 2: Verify the tag exists
    print_step(2, 4, "Checking git tag...");
    let tag_name = format!("bindings-v{}", version);
    let tag_check = Command::new("git")
        .current_dir(&repo_root)
        .args(["tag", "-l", &tag_name])
        .output()
        .context("failed to check git tag")?;

    if tag_check.stdout.is_empty() {
        println!();
        println!("   ⚠️  Tag {} not found. Create it with:", tag_name);
        println!("      git tag {}", tag_name);
        println!("      git push origin {}", tag_name);
        return Err(anyhow!("missing git tag for release"));
    }
    print_done();

    // Step 3: Run cargo publish --dry-run
    print_step(3, 4, "Running publish dry-run...");
    run_with_progress(
        Command::new("cargo")
            .current_dir(&bindings_crate)
            .args(["publish", "--dry-run"]),
        "cargo publish --dry-run",
    )?;
    print_done();

    // Step 4: Actually publish
    print_step(4, 4, "Publishing to crates.io...");
    run_with_progress(
        Command::new("cargo")
            .current_dir(&bindings_crate)
            .args(["publish"]),
        "cargo publish",
    )?;
    print_done();

    println!();
    println!("╔════════════════════════════════════════════════════════════╗");
    println!("║                    ✅ PUBLISHED                            ║");
    println!("╚════════════════════════════════════════════════════════════╝");
    println!();
    println!("   📦 tnt-core-bindings v{} is now on crates.io!", version);
    println!("   🔗 https://crates.io/crates/tnt-core-bindings");
    println!();

    Ok(())
}

/// Simple date helper (avoids chrono dependency)
fn chrono_lite_today() -> String {
    let output = Command::new("date")
        .args(["+%Y-%m-%d"])
        .output()
        .expect("failed to get date");
    String::from_utf8(output.stdout)
        .expect("invalid utf8")
        .trim()
        .to_string()
}
