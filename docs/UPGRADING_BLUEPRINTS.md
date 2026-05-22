# Shipping Blueprint Releases

This is the operating manual for a developer who wrote a Tangle blueprint and
wants to ship new releases to live operators. It is written for the reader
who has never used Tangle before; every command is copy-paste runnable.

You will need:

- A blueprint already registered on a live Tangle deployment (Section A walks
  through this if you don't have one yet).
- The deployer key for that blueprint (i.e. the address that signed
  `Tangle.createBlueprint`). On-chain ownership is the only credential that
  can publish a new version.
- A built release binary and somewhere to host it (IPFS, GitHub Releases,
  S3 with stable URL — any content-addressable URI works).

Conceptually the flow is:

```
  ┌──────────────┐    publishBinaryVersion()    ┌─────────────────┐
  │ blueprint    │ ───────────────────────────▶ │  on-chain       │
  │ owner (dev)  │                              │  version 0..N   │
  └──────────────┘                              └────────┬────────┘
                                                         │
        setActiveBinaryVersion()                         │
                ┌────────────────────────────────────────┘
                ▼
     ┌─────────────────────┐    AUTO   ┌───────────────────┐
     │  service N (AUTO)   │ ────────▶ │ operator pulls    │
     │  service M (APPROVE)│ ackBinary │ binary, restarts  │
     │  service P (MANUAL) │ ────────▶ │ blueprint-manager │
     └─────────────────────┘           └───────────────────┘
```

There are three roles in this doc: **blueprint owner** (publishes versions),
**operator** (runs services and decides when to adopt versions), and
**auditor** (publishes attestations). Most of the doc is written for the
blueprint owner; Sections D and E call out operator + auditor flows.

---

## A. One-Time Setup

### A.1. Register a blueprint

Blueprints are templates that operators can spin services from. Registration
puts the template on-chain and assigns it a `blueprintId`.

Every blueprint repo under `~/code/` ships with a `deploy/register-blueprint.sh`
that handles BSM deployment + `Tangle.createBlueprint(...)` in one shot.
The canonical sweep script in tnt-core wraps all of them.

```bash
# From tnt-core, register every known blueprint repo against Base Sepolia.
cd ~/code/tnt-core
export PRIVATE_KEY=0x...                  # blueprint owner key
export RPC_URL=https://sepolia.base.org
export TANGLE_CORE=0xC9b0716a187072be0f38A5D972392C6479b9Cfe3
./deploy/register-blueprints.sh
```

Output appends one row per blueprint to
`deployments/<network>/blueprints.tsv`:

```
repo               blueprint_id  bsm_address    status      binary_version_id  binary_sha256  ...
ai-trading-blueprint   42   0xBSM...   registered   -   -   -   -   no_v0_published   2026-05-22T...
llm-inference-blueprint 43  0xBSM...   registered   -   -   -   -   no_v0_published   2026-05-22T...
```

The `binary_version_id` column is `-` because no v0 was published yet — the
sweep script publishes v0 inline (see A.2). For now the blueprint exists
on-chain but has zero binaries, which means `effectiveBinaryVersion(serviceId)`
will revert until you publish at least one.

You can also register a single blueprint by running its per-repo script
directly:

```bash
cd ~/code/ai-trading-blueprint
export PRIVATE_KEY=0x...
export RPC_URL=https://sepolia.base.org
export TANGLE_CORE=0xC9b0716a187072be0f38A5D972392C6479b9Cfe3
BROADCAST=true ./deploy/register-blueprint.sh
```

The script prints `DEPLOY_BLUEPRINT_ID=<n>` to stdout — that's the
`blueprintId` you'll use everywhere else in this doc.

### A.2. Publish the v0 binary at registration time

The sweep script publishes a v0 inline when it finds an artifact and a URI.
For a single repo from CLI:

```bash
# Build a release artifact (whatever 'cargo build --release' produces)
cd ~/code/ai-trading-blueprint
cargo build --release -p trading-blueprint-bin

# Pin to IPFS and capture the CID
CID=$(ipfs add -Q target/release/trading-blueprint)
echo "CID=$CID"

# Wire it into the per-repo register script and re-run
cd ~/code/ai-trading-blueprint
export BLUEPRINT_BINARY_PATH=$(pwd)/target/release/trading-blueprint
export BLUEPRINT_BINARY_URI=ipfs://$CID
export PRIVATE_KEY=0x...
export RPC_URL=https://sepolia.base.org
export TANGLE_CORE=0xC9b0716a187072be0f38A5D972392C6479b9Cfe3
BROADCAST=true ./deploy/register-blueprint.sh
```

Expected output (registration already done, so this only re-runs the publish):

```
=== AI Trading Blueprint Registration ===
  ...
  DEPLOY_BLUEPRINT_ID=42

=== v0 Binary Publish ===
  Artifact:  /home/you/code/ai-trading-blueprint/target/release/trading-blueprint
  sha256:    0xabc...
  URI:       ipfs://Qm...
  Attest:    0x0000...0000
  Variants:  cloud
  -> publishing v0 for cloud (blueprintId=42)
  OK cloud blueprintId=42 versionId=0 (active)
```

After this, `Tangle.effectiveBinaryVersion(serviceId)` returns the row you
just published for any AUTO-policy service.

If you skip A.2, the manifest carries `no_v0_published — re-run when binary
path is configured` and operators can't run your blueprint yet.

### A.3. Operator-side bring-up

Operators run the **blueprint-manager** daemon, which:

1. Watches `Tangle.OperatorServiceAdded` for services it's been assigned to.
2. Resolves `effectiveBinaryVersion(serviceId)` to get
   `(sha256Hash, binaryUri, attestationHash)`.
3. Downloads the binary from `binaryUri`, verifies sha256 unconditionally,
   and (optionally) verifies the attestation bundle.
4. Spawns the binary with the service's runtime config.

Each operator picks a per-service **upgrade policy** (Section E):

- `AUTO` — adopt whatever the blueprint owner sets active.
- `APPROVE` — operator explicitly acks each new version before it rolls out.
- `MANUAL` — pinned to genesis (versionId=0) until policy changes.

`APPROVE` is the default and the only safe choice for operators who don't
fully trust the blueprint owner. `AUTO` is for first-party blueprints where
the owner key and the operator key roll up to the same org.

### A.4. Claim the blueprint as a publisher

The dapp and tooling treat the on-chain blueprint owner as the canonical
publisher. To wire your account into the dapp's "my blueprints" view and
unlock `cargo tangle blueprint publish-version` (Section B), run:

```bash
cargo tangle blueprint claim \
  --blueprint-id 42 \
  --rpc-url https://sepolia.base.org
```

This signs a message proving control of the owner key and posts it to the
dapp's claims indexer. No on-chain state changes — claims are dapp-side
curation only.

---

## B. Shipping a New Release

This is the loop you run every time you cut a release. The contract is
**append-only**: every new release becomes versionId N+1 where N is the
previous max. You cannot rewrite or replace a published version.

### B.1. Build the binary

```bash
cd ~/code/my-blueprint
cargo build --release -p my-blueprint
```

### B.2. Compute the sha256

```bash
sha256sum target/release/my-blueprint
# d41d8cd98f00b204e9800998ecf8427e  target/release/my-blueprint
```

`cargo tangle blueprint publish-version` does this for you — this step is
just for sanity-checking the build matches what your CI produced.

### B.3. Host the artifact

The binary must live at a content-addressed URI that operators can pull from.
Two common patterns:

```bash
# IPFS (preferred — content-addressable, no rotation risk)
ipfs add -Q target/release/my-blueprint
# QmXyz...

# GitHub Releases (works fine; URL must be stable for the version's lifetime)
gh release upload v0.2.0 target/release/my-blueprint --repo myorg/my-blueprint
# https://github.com/myorg/my-blueprint/releases/download/v0.2.0/my-blueprint
```

Mirror to a second host if uptime matters — operators fail closed on any
sha256 mismatch, but they need the bytes to verify in the first place.

### B.4. (Optional) Generate an attestation bundle

The contract stores an `attestationHash` alongside the binary. Common bundle
formats:

```bash
# sigstore/cosign predicate
cosign attest --predicate scan-report.json \
  --type custom target/release/my-blueprint > attestation.json

# SLSA provenance from GitHub Actions
gh attestation download target/release/my-blueprint \
  --repo myorg/my-blueprint > attestation.json
```

The on-chain field is just a sha256 of the bundle file. Operators (and the
dapp) re-fetch the full bundle out-of-band and verify it. Zero is accepted
on-chain and means "no bundle published with this version."

### B.5. Publish on-chain

```bash
cargo tangle blueprint publish-version \
  --blueprint-id 42 \
  --binary target/release/my-blueprint \
  --binary-uri ipfs://QmXyz... \
  --attestation-bundle attestation.json \
  --rpc-url https://sepolia.base.org

# Published versionId=5 · tx 0xabc...
# sha256 = 0xd41d...
# attestationHash = 0xfe09...
```

Equivalent raw `cast` invocation (if you're not running the CLI):

```bash
SHA=0x$(sha256sum target/release/my-blueprint | awk '{print $1}')
ATT=0x$(sha256sum attestation.json | awk '{print $1}')
cast send $TANGLE_CORE \
  "publishBinaryVersion(uint64,bytes32,string,bytes32)" \
  42 "$SHA" "ipfs://QmXyz..." "$ATT" \
  --private-key $PRIVATE_KEY --rpc-url $RPC_URL
```

The transaction emits `BinaryVersionPublished(blueprintId, versionId,
sha256Hash, binaryUri)`. The dapp indexer picks it up and surfaces the new
version in the blueprint detail view, including the trust score derived from
attestations on this version.

### B.6. Promote to active (most cases)

By default, publishing a new version does **not** auto-roll any services.
You have to call `setActiveBinaryVersion` to tell AUTO-policy services to
adopt it:

```bash
cargo tangle blueprint set-active-version \
  --blueprint-id 42 \
  --version-id 5

# or raw cast:
cast send $TANGLE_CORE \
  "setActiveBinaryVersion(uint64,uint64)" \
  42 5 \
  --private-key $PRIVATE_KEY --rpc-url $RPC_URL
```

Effect:

- `UpgradePolicy.AUTO` services pick up version 5 on the next
  `effectiveBinaryVersion(serviceId)` poll (typically the next dispatcher
  tick, single-digit seconds in production).
- `UpgradePolicy.APPROVE` services stay on whatever version they previously
  acked. They'll see the new version in the dapp and can opt in via the
  operator-side `ack-binary-version` flow (Section E.2).
- `UpgradePolicy.MANUAL` services stay pinned to versionId=0 (genesis).
  They do not move until the operator changes policy.

### B.7. Announce

Tell operators something shipped. The on-chain event is visible to anyone
running an indexer, but the dapp's "subscribe to blueprint updates" channel
is what most operators will be watching. Include:

- versionId
- sha256 (so they can sanity-check against your release page)
- changelog highlights, especially anything that changes operator
  configuration shape or wire protocol
- whether you set the version active, or are deferring to operator opt-in

---

## C. Promoting, Deprecating, and Rolling Back

### C.1. When to set-active immediately vs. defer

| Situation                                  | Recommendation                                |
|--------------------------------------------|-----------------------------------------------|
| Patch release, no behavior change          | `set-active-version` right after publish      |
| Minor release, additive features only      | `set-active-version` after smoke-test         |
| Major release, breaking config schema      | Publish, announce, defer set-active by 1 week |
| Hotfix for known critical bug              | Publish + set-active in same script           |
| Audit-blocked release                      | Publish (so auditors can attest), no set-active until audits clear |

### C.2. Deprecating a bad release

If you ship something broken, you cannot delete the version. You can flag it
as deprecated, which:

- Prevents operators from `ackBinaryVersion`-ing it under APPROVE policy.
- Surfaces a warning badge in the dapp.
- Does NOT pull the version from any service that already acked it (sticky
  by design — see G.2).

```bash
cargo tangle blueprint deprecate-version \
  --blueprint-id 42 \
  --version-id 5
```

The contract enforces one-way deprecation. There is no `un-deprecate`. If
you flag a version by accident, the path is to publish the same content as
versionId N+1 and re-announce — operators ack the new id.

### C.3. Emergency rollback

If `setActiveBinaryVersion(42, 5)` shipped a broken active version, roll
back by re-setting active to a known-good older versionId:

```bash
cargo tangle blueprint set-active-version \
  --blueprint-id 42 \
  --version-id 3
```

AUTO services adopt versionId=3 on the next poll. APPROVE services were
never moved by `set-active` in the first place, so they're unaffected unless
they had already manually acked versionId=5 — in which case they need to
re-ack 3 themselves (Section G.2).

Pair the rollback with a deprecation of the broken version so operators
running APPROVE policy can't accidentally ack it later:

```bash
cargo tangle blueprint deprecate-version --blueprint-id 42 --version-id 5
cargo tangle blueprint set-active-version --blueprint-id 42 --version-id 3
```

---

## D. Requesting Audits

The contract stores `attestationHash` per version, but the trust score
shown in the dapp is computed from a separate attestation log indexed
off-chain. Attestations are **permissionless** — anyone can attest any
version. The dapp curates which attesters it weighs based on its own
allowlist + reputation model.

### D.1. Standard auditor flow

Auditors review a published version and call:

```bash
cargo tangle attest \
  --blueprint-id 42 \
  --version-id 5 \
  --kind audit \
  --severity none \
  --predicate audit-report-v5.json
```

`kind` values the dapp recognizes:

- `audit` — full security review (use with `--severity none|low|medium|high|critical`)
- `slsa` — SLSA provenance proof
- `reproducibility` — independent rebuild that matches sha256
- `runtime` — production-soak report from a third-party operator

`severity` is required for `kind=audit`. Values are scored on the dapp side:

| Severity | Trust score impact                                   |
|----------|------------------------------------------------------|
| none     | +full credit (clean audit)                           |
| low      | +partial credit, badge in dapp                       |
| medium   | neutral, badge in dapp                               |
| high     | negative score, warn in dapp                         |
| critical | negative score, dapp recommends operators don't ack  |

### D.2. As a blueprint owner: requesting audits

Auditors are out-of-band. The dapp surfaces a "request audit" button on the
blueprint detail page that emails the auditor allowlist; the rest is human
process (statement of work, payment, etc.). On-chain, you don't need to do
anything — auditors call `cargo tangle attest` directly when they're done.

### D.3. Showing the trust score

The dapp aggregates attestations per `(blueprintId, versionId)` and renders
a trust score from 0–100. Operators see this in their service detail view
when deciding whether to ack a new version under APPROVE policy.

---

## E. Operator Side

### E.1. Choosing an upgrade policy

| Policy   | Behavior                                                       | When to use                                              |
|----------|----------------------------------------------------------------|----------------------------------------------------------|
| AUTO     | Service runs whatever the blueprint owner sets active.         | First-party blueprints, internal CI, dev/test services.  |
| APPROVE  | Service runs the latest version this operator has acked. Default. | Untrusted blueprints, prod, anything where you want a review gate. |
| MANUAL   | Service pinned to genesis (versionId=0) until policy changes.  | Hostile or unknown blueprint owner; investigation mode.  |

Set policy via:

```bash
cargo tangle service set-upgrade-policy \
  --service-id 7 \
  --policy approve

# raw cast:
# 0 = APPROVE (default), 1 = AUTO, 2 = MANUAL
cast send $TANGLE_CORE \
  "setServiceUpgradePolicy(uint64,uint8)" \
  7 0 \
  --private-key $OPERATOR_KEY --rpc-url $RPC_URL
```

The contract requires the caller to be an active operator of the service.
Policy changes do not retroactively reschedule in-flight jobs — they apply
on the next `effectiveBinaryVersion(serviceId)` resolution.

### E.2. Acking a new version (APPROVE policy)

When the blueprint owner publishes a new version, the dapp shows the
operator a card with the new versionId, sha256, URI, and trust score. The
operator clicks "Adopt" — that calls:

```bash
cargo tangle service ack-binary-version \
  --service-id 7 \
  --version-id 5

# raw cast:
cast send $TANGLE_CORE \
  "ackBinaryVersion(uint64,uint64)" \
  7 5 \
  --private-key $OPERATOR_KEY --rpc-url $RPC_URL
```

The contract rejects acks on deprecated versions — if the owner flagged the
version after the operator already saw it but before the operator clicked,
the call reverts `VersionDeprecatedCannotAck`. Refresh the dapp and ack the
next non-deprecated version.

### E.3. What happens during a swap

The blueprint-manager runs a drain-then-restart sequence when
`effectiveBinaryVersion(serviceId)` returns a different sha256 than what's
running:

1. Stop accepting new dispatches for the service.
2. Wait up to `drain_timeout` (default 60s) for in-flight jobs to finish.
3. SIGTERM the binary; SIGKILL after `kill_grace` (default 10s) if it
   doesn't exit.
4. Pull the new binary from `binaryUri`, verify sha256.
5. Spawn the new binary with the same service config.
6. Resume dispatch.

In-flight jobs that don't finish during drain are restarted on the new
binary. If your release changes job semantics in a backwards-incompatible
way, plan for this — either bump a `workflow_version` field your jobs
carry, or quiesce dispatch from the client side before publishing.

---

## F. Security Invariants

These are the rules the contract enforces. Build your release process around
them — they will not bend.

### F.1. sha256 verification is unconditional

The blueprint-manager refuses to spawn any binary whose sha256 does not
match `effectiveBinaryVersion(serviceId).sha256Hash`. The contract is the
trust root for what bytes should run. Mirror your binary anywhere you want;
operators verify what they download against the on-chain hash.

### F.2. The version log is append-only

Once you publish versionId=5, that row is permanent. You cannot edit the
sha256, URI, or attestation hash. The only way to "replace" a version is
to publish a new one (versionId=6) and deprecate the old one. The history
of every release lives on-chain forever.

### F.3. Default policy is APPROVE

`UpgradePolicy.APPROVE` is the default for new services. Operators have to
explicitly opt in to AUTO, and they should only do so for blueprints they
trust at the publisher level. This is fail-closed by design — a compromised
publisher key cannot force-roll AUTO operators to a malicious binary
*unless those operators opted into AUTO themselves*.

### F.4. Attestations are permissionless

The contract stores one attestation hash per version, but the broader
attestation log (multiple attesters, multiple kinds) is dapp-side. Anyone
can call `cargo tangle attest`. The trust score is curation, not consensus.
A blueprint with zero attestations isn't blocked; it just shows up with a
"no audits" badge.

### F.5. Operator acks are sticky across deprecation

If an operator acked versionId=5 and the publisher later deprecates 5, the
operator's service keeps running 5. The contract does not yank out from
under them. The operator decides when to re-ack a non-deprecated version.
This protects operators from a compromised publisher key flagging
known-good versions as deprecated to force operators onto a malicious
"current" version.

### F.6. Only the blueprint owner can publish / deprecate / set-active

`Tangle.publishBinaryVersion`, `setActiveBinaryVersion`, and
`deprecateBinaryVersion` all gate on `msg.sender == blueprint.owner`. If
you transfer blueprint ownership (rare), the new owner inherits all three
powers; the old owner loses them.

---

## G. Common Pitfalls

### G.1. "I published a version but operators aren't updating"

Check their upgrade policy. `setActiveBinaryVersion` only moves AUTO
services; APPROVE operators have to ack explicitly.

```bash
# View per-service policy:
cargo tangle service show-upgrade-policy --service-id 7
# Or read it from chain:
cast call $TANGLE_CORE "getServiceUpgradePolicy(uint64)(uint8)" 7 --rpc-url $RPC_URL
# 0 = APPROVE (default), 1 = AUTO, 2 = MANUAL
```

If they're APPROVE: ping them, point at the dapp, tell them to ack. If
they're MANUAL: there's nothing you as the publisher can do — the operator
intentionally pinned to genesis.

### G.2. "I deprecated a version but operators are still running it"

Acks are sticky (F.5). The operator has to re-ack a newer non-deprecated
version, or switch their policy to AUTO (which will pull the active version
on the next poll). Communicate the deprecation reason — operators won't
move just because of the badge.

### G.3. "I want to revert to an older version"

`setActiveBinaryVersion` to the older versionId. It does not matter if the
older version is deprecated or not — `set-active` accepts deprecated
versions for exactly this rollback case (a UI concern enforces "don't
ship deprecated as active under normal conditions"; the contract permits
it for emergencies).

```bash
cargo tangle blueprint set-active-version --blueprint-id 42 --version-id 3
```

### G.4. "My publish reverted with `VersionNotFound`"

This is from `setActiveBinaryVersion` or `ackBinaryVersion`, not
`publishBinaryVersion`. It means the versionId you passed doesn't exist
yet — typo, or you queried a stale `getBinaryVersionCount` before the
publish tx confirmed. Wait one block and retry.

### G.5. "My publish reverted with `EmptyBinaryUri` or `ZeroBinaryHash`"

The contract rejects publishes with empty URI or zero sha256. The CLI
validates both before sending; if you're invoking raw `cast`, make sure
your `$SHA` starts with `0x` and has exactly 64 hex chars, and that the
URI string is non-empty.

### G.6. "I set-active to a version no one has acked, but APPROVE services kept running v0"

That's working as designed. `set-active` only moves AUTO services. APPROVE
services stay on the last version their operator acked, or genesis (v0) if
they've never acked. To roll APPROVE services forward, the operator must
ack — there is no publisher-side override.

### G.7. "My operator dropped the binary and the service is stuck"

The blueprint-manager retries the binary fetch with exponential backoff.
If your URI rotated (e.g. a GitHub release got deleted), republish the
same bytes at a new URI as a new versionId and either set-active or wait
for the operator to ack. The sha256 will match (same bytes) and operators
running APPROVE policy will see "new version, same content" in the dapp.

This is one reason IPFS is preferred over GitHub Releases — IPFS URIs
don't rotate.

---

## Quick Reference

```bash
# Publisher (blueprint owner)
cargo tangle blueprint publish-version --blueprint-id 42 \
  --binary path/to/bin --binary-uri ipfs://... --attestation-bundle a.json
cargo tangle blueprint set-active-version --blueprint-id 42 --version-id 5
cargo tangle blueprint deprecate-version --blueprint-id 42 --version-id 5

# Operator
cargo tangle service set-upgrade-policy --service-id 7 --policy auto|approve|manual
cargo tangle service ack-binary-version --service-id 7 --version-id 5

# Auditor
cargo tangle attest --blueprint-id 42 --version-id 5 \
  --kind audit --severity none --predicate report.json

# Read-only
cast call $TANGLE_CORE "getBinaryVersionCount(uint64)(uint64)" 42 --rpc-url $RPC_URL
cast call $TANGLE_CORE "getActiveBinaryVersionId(uint64)(uint64)" 42 --rpc-url $RPC_URL
cast call $TANGLE_CORE "getServiceUpgradePolicy(uint64)(uint8)" 7 --rpc-url $RPC_URL
cast call $TANGLE_CORE "getServiceAckedVersionId(uint64)(uint64)" 7 --rpc-url $RPC_URL
cast call $TANGLE_CORE "effectiveBinaryVersion(uint64)((uint64,bytes32,string,bytes32,uint64,bool))" 7 --rpc-url $RPC_URL
```

For the underlying contract surface, see
`src/core/BlueprintsBinaryVersions.sol`.
