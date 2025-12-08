# Testing Infra Notes

- Full suite must be executed via `./scripts/run_forge_tests.sh forge test`. The script:
  - Raises the shell soft stack limit (default `unlimited`) and exports `RUST_MIN_STACK=268435456` to stop Foundry worker threads from overflowing macOS stacks.
  - Invokes `forge test --threads 1` with the provided command. When no command is supplied it enumerates every `test/v2/**/*.t.sol` file and runs them sequentially (one file per Forge invocation) to keep the runner shallow.
- Running `forge test` directly without the script will eventually abort with `thread '<unknown>' ... has overflowed its stack` once the 900+ tests start, because Foundry’s harness inherits the OS default 8 MB stack.
- For targeted suites you can still pass them through the script (e.g. `./scripts/run_forge_tests.sh forge test --match-path test/v2/Integration.t.sol`). This ensures the stack bump is applied even when only a subset is executed.
