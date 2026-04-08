# Pursuit: Protocol Launch Readiness

Generation: 1
Date: 2026-03-22
Status: building

## System Audit

### What exists and works
- tnt-core contracts: staking, payments, slashing, governance, QuotesCreate/QuotesExtend RFQ
- Blueprint SDK: EVM-based TangleProducer/Consumer, BlueprintRunner, BlueprintHarness, GPU requirements
- BPM: full lifecycle (register → activate → job → result → terminate), pricing engine, remote providers
- vLLM blueprint: x402 payments, ShieldedCredits billing (real on-chain authorize+claim), streaming SSE, metrics, watchdog, harness E2E test
- Voice blueprint: same architecture for TTS, x402, per-character billing
- Shielded gateway: 121 forge tests, LayerZero bridge for 8 chains, TypeScript SDK (51 tests), SP1 batch verifier contract
- RFQ: works locally on Anvil (confirmed by user), off-chain mechanism with on-chain commitment

### What exists but isn't integrated
- RFQ pricing TOMLs not defined for inference blueprints (BPM pricing engine hosts them)
- Operator binary doesn't call BSM.configureModel() at startup (pricing stays local, not on-chain)
- BSM getOperatorPricing() exists but nothing queries it for discovery
- Shielded gateway deploy configs are empty templates (all 0x0000...)
- SP1 batch sequencer is scaffold (~50 lines needed)
- 15 shielded SDK integration tests disabled

### What was tested and failed
- crates.io batch-publish.sh: dependency ordering failure (blueprint-std not published before dependents)
- bincode 3.0.0 upgrade: breaking API (xkcd compile_error), closed PR

### What doesn't exist yet
- Operator discovery frontend/API
- KMS/HSM integration for operator keys
- Foundry deploy scripts for inference blueprints (bash only)
- UUPS proxy on inference BSM contracts
- Mainnet deploy configs for shielded gateway
- Circuit composition audit (external)
- Trusted setup ceremony (external)

### User feedback
- "RFQ stuff works, just need pricing TOMLs for blueprints"
- "No Co-Authored-By lines ever"
- "No path deps, use published or git deps"
- "Release-plz should not be disabled"

## Current Baselines

| System | Tests | Compiles | CI Green | Published |
|--------|-------|----------|----------|-----------|
| Blueprint SDK | 100/100 manager, 21/21 metadata | yes | yes (2 pre-existing flakes) | no (0.2.0-alpha.1 tags exist, crates.io failed) |
| vLLM blueprint | 14/14 (harness + unit) | yes | yes (git deps) | n/a |
| Voice blueprint | 24 contract + server tests | yes | yes | n/a |
| Shielded gateway | 121/121 forge, 51/51 SDK | yes | yes | n/a |
| tnt-core | full suite | yes | yes | n/a (contracts, not crate) |

## Generation 1 Checklist

### P0 — Release Engineering (unblocks everything)

- [x] **1. Fix batch-publish.sh dependency ordering** — PR #1341
  - Topological sort via cargo metadata, retry logic, continues on failure
  - Owner: claude — DONE

- [ ] **2. Switch vllm-inference-blueprint to published deps** — blocked on #1341 merge + publish
  - Owner: claude

- [ ] **3. Switch voice-inference-blueprint to published deps** — blocked on #1341 merge + publish
  - Owner: claude

### P1 — RFQ Pricing (operator pricing on-chain)

- [x] **4. Define pricing TOML for vLLM blueprint** — pushed to main
  - `config/pricing.toml` with GPU/CPU/memory resources + per-job base fee
  - Owner: claude — DONE

- [x] **5. Define pricing TOML for voice blueprint** — pushed to master
  - `config/pricing.toml` with TTS-specific pricing
  - Owner: claude — DONE

- [x] **6. Operator registration mode with BSM payload** — pushed to main
  - ABI-encodes (model, gpuCount, totalVramMib, gpuModel, endpoint) for onRegister
  - BPM uses this when registering operator on-chain
  - Owner: claude — DONE

- [ ] **7. Verify RFQ E2E on Anvil** — customer requests quotes, operator responds, service created
  - Verify: full flow works with pricing TOML → BPM → on-chain quote → service activation
  - Owner: drew (confirmed working locally)

### P2 — Operational Hardening

- [x] **8. Default nonce store to persistent** — pushed to vllm main
  - `nonce_store_path` defaults to `data/nonces.json`
  - Owner: claude — DONE

- [x] **9. Same for voice blueprint** — pushed to voice master
  - Owner: claude — DONE

- [x] **10. Production key guard** — pushed to both repos
  - `PRODUCTION=1` + plaintext key → hard error, refuses to start
  - Owner: claude — DONE

- [x] **11. Import tnt-core as soldeer dep in BSM contracts** — pushed to vllm main
  - Replaced inline stub with BlueprintServiceManagerBase, 38/38 tests pass
  - Owner: claude — DONE

- [x] **12. UUPS proxy on InferenceBSM** — pushed to vllm main
  - UUPSUpgradeable + Initializable, proxy deploy in tests + script
  - Owner: claude — DONE

### P3 — Deployment

- [x] **13. Foundry deploy scripts for vllm blueprint** — pushed to main
  - `contracts/script/Deploy.s.sol` deploying BSM + ShieldedCredits + RLN
  - Owner: claude — DONE

- [ ] **14. Populate shielded gateway mainnet deploy configs**
  - Files: `shielded-payment-gateway/script/deploy-config/base-mainnet-shielded.json`
  - Requires: deployed Poseidon libs, VAnchor pools, verifier contracts
  - Owner: drew (depends on ceremony)

- [x] **15. Complete SP1 batch sequencer** — pushed to main
  - Full implementation: read proofs → pack BatchInput → SP1 prove → save/submit
  - Feature-gated ELF include (needs `cargo prove build` first)
  - Owner: claude — DONE

### P4 — Testing & CI

- [x] **16. Voice harness E2E test already exists** — confirmed by audit
  - Owner: claude — DONE

- [x] **17. Shielded SDK tests** — 51/51 pass, none skipped
  - Audit was wrong about 15 skipped tests
  - Owner: claude — VERIFIED

- [x] **18. Add cargo-audit to CI for both inference blueprints** — pushed to both repos
  - Owner: claude — DONE

### P5 — Frontend / Discovery (post-launch enhancement)

- [x] **19. Operator discovery API endpoint** — pushed to vllm main
  - `GET /v1/operator` returns model, pricing, GPU caps, payment info
  - Owner: claude — DONE

- [ ] **20. Pricing comparison webapp** — displays operator/model/price grid
  - Repo: new or in existing frontend
  - Uses: BSM.getOperators() + BSM.getOperatorPricing()
  - Owner: drew/claude

### External Dependencies (not in our control)

- [ ] **E1. Circuit composition audit** — ~50 constraints, external auditor
  - Blocks: shielded gateway mainnet
  - Owner: drew (engage auditor)

- [ ] **E2. Trusted setup ceremony** — multi-party, 2+ days
  - Blocks: shielded gateway mainnet
  - Owner: drew

- [ ] **E3. Poseidon library deployment** — circomlibjs bytecode generation
  - Blocks: shielded gateway mainnet
  - Owner: drew

## Success Criteria

- [ ] `cargo search blueprint-sdk` returns `0.2.0-alpha.1`
- [ ] Both inference blueprints compile with published deps (no git/path deps)
- [ ] Operators can set pricing via TOML → visible on-chain via getOperatorPricing()
- [ ] RFQ flow works end-to-end on Anvil
- [ ] Nonce stores default to persistent
- [ ] BSM contracts use real tnt-core interfaces (not inline stubs)
- [ ] Harness E2E tests pass for both inference blueprints
- [ ] Shielded gateway deploys to testnet with real configs

## Next Steps

Start with P0 (release engineering) since it unblocks P1-P4.
P1 (pricing TOMLs) is the highest-impact user-facing item.
P2-P4 can be parallelized.
P5 is post-launch enhancement.
E1-E3 are external and on drew's timeline.
