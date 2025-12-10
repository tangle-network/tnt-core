# xtask

Development automation tasks for tnt-core. Uses the [cargo xtask](https://github.com/matklad/cargo-xtask) pattern.

## Commands

### Generate Bindings (default)

Regenerates Rust bindings from Solidity contracts using Foundry's `forge bind`.

```bash
cargo xtask
# or explicitly:
cargo xtask gen-bindings
```

**What it does:**
1. Cleans `bindings/src/bindings/` directory
2. Builds Solidity contracts with `forge build`
3. Generates Alloy Rust bindings with `forge bind`
4. Copies ABI JSON files to `bindings/abi/`
5. Records the git commit hash in `bindings/TNT_CORE_VERSION`

**Output:**
- `bindings/src/bindings/*.rs` - Generated Rust modules
- `bindings/abi/*.json` - Contract ABIs
- `bindings/TNT_CORE_VERSION` - Source commit hash

### Bump Version

Updates the bindings crate version for a new release.

```bash
cargo xtask bump-version <VERSION>
# Example:
cargo xtask bump-version 0.3.0
```

**What it does:**
1. Validates semver format (MAJOR.MINOR.PATCH)
2. Updates version in `bindings/Cargo.toml`
3. Adds a new entry to `bindings/CHANGELOG.md`
4. Prints next steps for committing and tagging

### Publish

Publishes the bindings crate to crates.io.

```bash
cargo xtask publish
```

**What it does:**
1. Verifies `bindings/` has no uncommitted changes
2. Verifies the git tag exists (e.g., `bindings-v0.3.0`)
3. Runs `cargo publish --dry-run` to validate
4. Publishes to crates.io

**Prerequisites:**
- Run `cargo login` with your crates.io API token
- Commit and tag the release first

## Release Workflow

```bash
# 1. Regenerate bindings if contracts changed
cargo xtask gen-bindings

# 2. Bump version
cargo xtask bump-version 0.3.0

# 3. Review and commit
git diff bindings/
git add bindings/
git commit -m "chore(bindings): release v0.3.0"

# 4. Tag and push
git tag bindings-v0.3.0
git push origin main --tags

# 5. Publish
cargo xtask publish
```

## Requirements

- [Foundry](https://getfoundry.sh/) (`forge` must be in PATH)
- Rust toolchain
