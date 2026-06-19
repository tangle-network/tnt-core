# Tangle mainnet launch runbook

The full protocol deploys as a sequence of standalone scripts, orchestrated by
`deploy/deploy-all.sh`. Core + liquid-staking vaults are turnkey. Beacon native-restaking and
L2 slashing are a cross-chain system that additionally needs operational infra and post-deploy
timelock actions — they are gated `deploy: false` in `base-mainnet.json` until those are ready.

## 0. Prerequisites
- `PRIVATE_KEY` (deployer), `L2_RPC` (the core chain), and for beacon/L2 slashing `L1_RPC`
  (Ethereum mainnet) + pinned bridge infra (mailbox/endpoint, **ISM/DVN**) + an off-chain
  slashing oracle address.
- Governance + token deployed first (step 0b) so `roles.timelock` and `incentives.tntToken` can be
  pinned. `FullDeploy` does **not** deploy the Governor/Timelock — it consumes the timelock address.
- `base-mainnet.json` then filled with the real **admin / treasury / timelock / multisig** plus the
  governance/slashing/payments blocks (see `deploy/MAINNET-PARAMETERS.md`). The `FullDeploy`
  production guard reverts on unset roles.

## 0b. Deploy governance (BEFORE the orchestrator)
```bash
# Reuse an existing TNT token (TOKEN=...) or deploy a fresh one (INITIAL_SUPPLY=<wei>).
PRIVATE_KEY=0x... [TOKEN=0x... | INITIAL_SUPPLY=...] \
FULL_DEPLOY_CONFIG=deploy/config/base-mainnet.json \
forge script script/DeployGovernance.s.sol:DeployGovernance --rpc-url <L2_RPC> --broadcast --slow
```
Reads the `governance` block (votingDelay / votingPeriod / proposalThreshold / quorumPercent /
timelockDelay), deploys token (or reuses) + `TangleTimelock` + `TangleGovernor`, wires the Governor
as PROPOSER/EXECUTOR/CANCELLER, and renounces the deployer's bootstrap timelock admin. Take the
`TangleTimelock` and `TangleToken` addresses from `deployments/governance.json` and set
`roles.timelock` + `incentives.tntToken` (and `roles.admin/treasury/multisig`) in the config.

## 1. Run the orchestrator
```bash
PRIVATE_KEY=0x... L2_RPC=<core-rpc> [L1_RPC=<eth-rpc>] \
FULL_DEPLOY_CONFIG=deploy/config/base-mainnet.json \
deploy/deploy-all.sh
```
Order (enforced by the script): **FullDeploy → liquid vaults → beacon L1 → L2 slashing**. Each
later step reads core addresses from `deployments/<network>/latest.json`. The subsystem scripts
**fail closed on production chains** if `admin`/`oracle` is the deployer or a mock bridge/oracle is
selected.

## 2. What deploys
| Subsystem | Unit | Chain | Turnkey? |
|---|---|---|---|
| Governance (TNT token, TangleTimelock, TangleGovernor) | proxies | L2 | step 0b (separate) |
| Core (Tangle, MultiAssetDelegation, incentives) | proxies | L2 | yes |
| Liquid staking | `LiquidDelegationFactory` (vaults created on demand) | L2 | yes |
| Beacon restaking | `ValidatorPodManager` + EIP4788 oracle + connector + messenger (pods on demand) | L1 | needs infra |
| L2 slashing | `TangleL2Slasher` + `L2SlashingReceiver` + bridge adapter | L2 | needs infra |

## 3. Bridge choice — use OP-Stack native for Base (default)
For Base ↔ Ethereum the default is `bridge: "opstack"`: the L1 leg deploys `BaseCrossChainMessenger`
wrapping Base's canonical `L1CrossDomainMessenger`, and the L2 `L2SlashingReceiver` runs in
`opStackMessengerMode` authenticating via `xDomainMessageSender()`. **This inherits Base/Ethereum
security with NO third-party bridge and NO ISM/DVN to pin** — strictly simpler and more trustless
than Hyperlane/LayerZero, and L1→L2 (the slash direction) is fast. Only set `bridge` to
`hyperlane`/`layerzero` if deploying to a non-OP chain; those additionally require pinning the
ISM / DVN+executor out-of-band.

## 3b. REQUIRED post-deploy timelock/multisig actions (beacon + L2 slashing only)
Slashing is **inert** until all of these are done by the timelock/multisig — no deploy key can do
them (by design):
1. `MultiAssetDelegation.addSlasher(TangleL2Slasher)` — authorize the L2 slasher (sent by the
   staking ASSET_MANAGER/admin = timelock). **Without this, every beacon-originated slash reverts.**
2. After `SENDER_ACTIVATION_DELAY` (2 days): activate the scheduled trust anchor —
   OP-Stack: `L2SlashingReceiver.activateOpStackL1Sender(srcChain, l1BaseMessenger)`;
   Hyperlane/LayerZero: `*Receiver.activateTrustedSender/activatePeer(...)` +
   `L2SlashingReceiver.activateAuthorizedSender(...)`. The deploy only *schedules* these.
3. `ConfigureL2SlashingConnector` (on L1) wiring the L1 connector → the L2 receiver address.
4. `L2SlashingConnector.registerPodOperator(...)` for each onboarded pod (else slash propagation
   reverts `UnknownPod`).
5. (Hyperlane/LayerZero only) pin the **ISM** / **DVN+executor** out-of-band before activation.
   Not needed for OP-Stack.

## 3c. Price oracle bring-up (turn ON USD normalization) — optional, deferred at genesis
The protocol ships with **no price oracle wired** (`incentives.priceOracle` unset). With no oracle,
`PaymentsDistribution` / `PaymentsBilling` / `PaymentsEffectiveExposure` / `ServiceFeeDistributor`
all fall back to **raw token amounts** — correct for a single homogeneous asset, but it mis-weights
payouts/exposure across heterogeneous assets. This is intentional at launch: the exposure-weighted
rail is dormant (`incentives.weights.stakersBps = 0`). Do this step only when you turn that rail on.

`FullDeploy` never deploys or configures an oracle — it only wires a pre-existing address. Use
`script/ConfigureOracle.s.sol`, which deploys a `ChainlinkOracle` or `UniswapV3Oracle`, configures
every feed/pool + staleness + the L2 sequencer gate, optionally wires the two consumers, and hands
the oracle's `Ownable` ownership to the timelock/multisig. It reads the `oracle` block of the deploy
config (see `deploy/config/base-mainnet.json`).

```
PRIVATE_KEY=<pk> FULL_DEPLOY_CONFIG=deploy/config/base-mainnet.json \
  forge script script/ConfigureOracle.s.sol:ConfigureOracle --rpc-url "$L2_RPC" --broadcast --slow
```

Wiring (`Tangle.setPriceOracle` + `ServiceFeeDistributor.setPriceOracle`) needs ADMIN_ROLE:
- During the bootstrap window (before role handoff) set `oracle.wire=true` and the deployer wires it.
- After handoff, leave `oracle.wire=false` and execute the two `setPriceOracle` calls the script
  prints **through governance** (the timelock).

Required for a production run (the script's `_requireProductionConfig` enforces these, bypass on
anvil with `TANGLE_DEPLOY_LOCAL=1`):
- `oracle.owner` = timelock/multisig (the oracle must not stay EOA-owned),
- `oracle.maxAgeSeconds` > 0, and at least one feed (chainlink) / pool (uniswap),
- on Base/OP/Arbitrum, `oracle.sequencerUptimeFeed` set (Base: `0xBCF85224fc0756B9Fa45aA7892530B47e10b6433`)
  so the oracle cannot serve frozen prices during a sequencer outage.

Then flip `incentives.weights.stakersBps` to a non-zero value via a governance migration (pre-commit
to e.g. staking 3500 / stakers 1500, per the `incentives._note_weights` in the config).

## 4. Verification after launch
- `forge test` (or CI `Foundry CI` workflow) green; facet sizes within EIP-170 (the `size` CI job).
- `_assertGovernanceConfiguration` runs inside `FullDeploy` (roles handed to timelock/multisig,
  bootstrap revoked).
- Confirm `LiquidDelegationFactory.owner() == timelock`.
- For slashing: end-to-end test a slash on testnet first; confirm `addSlasher` + activations landed.

## Notes
- Liquid-vault creation in prod should be restricted to real ERC20 assets — the native-ETH vault
  path is not yet live.
- Beacon SSZ proof verification is Pectra (post-May-2025 L1) only; validated against EigenLayer
  v1.12.0 + a real Deneb fixture (`BeaconChainProofsRealFixtureTest`). A live-node Pectra fixture
  is the remaining belt-and-suspenders check before enabling restaking.
