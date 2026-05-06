# Changelog

All notable changes to `tnt-core-bindings` will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.11.3] - 2026-05-06

### Changed

- Updated bindings from TNT Core contracts

## [0.11.2] - 2026-05-05

### Added

- `ITangleServices.expireServiceRequest(uint64)` — declared on the public
  interface so the permissionless cleanup path is reachable via the standard
  ABI. The implementation already existed on `ServicesApprovals`; the
  declaration was missing, so off-chain consumers could not invoke it through
  the canonical interface.

## [0.11.1] - 2026-05-05

### Fixed

- `approveService` correctness: the TEE root SSTORE is now gated on
  `p.teeCommitments.length > 0` directly, not on `keccak256(...) != bytes32(0)`.
  The prior gate relied on cryptographic happenstance (any empty hash being
  non-zero) instead of input shape, which is the property we actually mean.
- `approveService` manager-hook fidelity: when an operator approves a request
  with the protocol-default TNT requirement and supplies no explicit
  commitments, the contract auto-fills at the requirement's `minExposureBps`.
  The `IBlueprintServiceManager.onApprove` hook now receives the value that
  was actually committed (`minExposureBps / 100`), not the prior `100`
  fallback. New tests in `ServicesApprovalTest` (`test_managerStakingPercent_*`)
  pin this behavior.

### Notes

- Storage layout: `_serviceTeeCommitments` mapping (legacy
  `TeeAttestationCommitment[]` value) was retired in 0.11.0 in favor of
  `_serviceTeeCommitmentRoot` (`bytes32` value). Same head-slot count, different
  shape at keyed slots — safe for greenfield deploys; live-proxy upgrades would
  require explicit migration of orphaned data, which is N/A pre-mainnet.
- Rust API: `TangleClient::approve_service(request_id)` lost its
  `restaking_percent: u8` parameter at 0.11.0 because the contract derives the
  effective exposure on-chain. Direct callers of the convenience method on
  `tangle-tools-clients-tangle` must drop the second argument; the unified
  builder `approve_service_with_params(ApprovalParams)` is also available.

## [0.11.0] - 2026-05-05

### Changed (BREAKING)

- Unified `approveService` entrypoint replaces five `approveServiceWith*` variants
  (tnt-core PR #119). The new ABI takes a single `Types.ApprovalParams` tuple
  carrying `requestId`, `securityCommitments`, `blsPubkey`, `blsPopSignature`,
  `teeCommitments`. Empty / zero fields opt out of the corresponding capability.
- TEE commitment storage moves from `TeeAttestationCommitment[]` arrays to a
  single keccak256 root per `(serviceId, operator)`. The `getTeeCommitment` view
  is replaced by `getTeeCommitmentRoot(serviceId, operator) -> bytes32`. Slashers
  / provisioning oracles supply the original commitment array as a witness and
  verify keccak match against the on-chain root.
- New event `TeeCommitmentsRecorded(requestId, operator, root, commitments)`
  emits the full commitment array for indexer reconstruction.
- Selector list on `TangleServicesFacet` shrinks from 10 → 6.

### Added

- `Types.ApprovalParams` struct exposed via the generated bindings.
- `teeNonceFor(uint64 requestId) -> bytes32` view: canonical
  `keccak256(abi.encode("tangle.tee.nonce", requestId, address(this), block.chainid))`
  that operators MUST set as `TeeAttestationCommitment.nonceBinding`.

## [0.10.9] - 2026-04-23

### Changed

- Updated bindings from TNT Core contracts

## [0.10.8] - 2026-04-19

### Changed

- Updated bindings from TNT Core contracts

## [0.10.7] - 2026-04-08

### Changed

- Updated bindings for the confidentiality field added to job quote EIP-712 signatures

## [0.10.6] - 2026-03-26

### Changed

- Updated bindings from TNT Core contracts

## [0.10.4] - 2026-02-24

### Changed

- Updated bindings from TNT Core contracts

## [0.10.3] - 2026-02-21

### Changed

- Updated bindings from TNT Core contracts

## [0.10.2] - 2026-02-18

### Changed

- Updated bindings from TNT Core contracts

## [0.10.0] - 2026-02-11

### Changed

- Updated bindings from TNT Core contracts

## [0.9.0] - 2026-02-09

### Changed

- Updated bindings from TNT Core contracts

## [0.8.2] - 2026-01-29

### Changed

- Updated bindings from TNT Core contracts

## [0.8.0] - 2026-01-29

### Changed

- Updated bindings from TNT Core contracts

## [0.7.3] - 2026-01-23

### Changed

- Updated bindings from TNT Core contracts

## [0.7.2] - 2026-01-23

### Changed

- Updated bindings from TNT Core contracts

## [0.7.0] - 2026-01-21

### Changed

- **BREAKING**: Normalized interface names to `IStaking`
- **BREAKING**: Normalized module naming to `staking`
- **BREAKING**: Normalized `PaymentSplit` staking weight field naming
- Updated all bindings from TNT Core contracts with canonical staking terminology

## [0.6.1] - 2026-01-17

### Changed

- Updated bindings from TNT Core contracts

## [0.6.0] - 2026-01-17

### Changed

- Updated bindings from TNT Core contracts

## [0.5.6] - 2026-01-16

### Changed

- Updated bindings from TNT Core contracts

## [0.5.5] - 2026-01-15

### Changed

- Updated bindings from TNT Core contracts

## [0.5.4] - 2026-01-14

### Changed

- Updated bindings from TNT Core contracts

## [0.5.3] - 2026-01-14

### Changed

- Updated bindings from TNT Core contracts

## [0.5.2] - 2026-01-12

### Changed

- Updated bindings from TNT Core contracts

## [0.5.1] - 2026-01-12

### Changed

- Updated bindings from TNT Core contracts

## [0.5.0] - 2025-12-31

### Changed

- Updated bindings from TNT Core contracts

## [0.4.10] - 2025-12-23

### Changed

- Updated bindings from TNT Core contracts

## [0.4.9] - 2025-12-23

### Changed

- Updated bindings from TNT Core contracts

## [0.4.8] - 2025-12-21

### Changed

- Updated bindings from TNT Core contracts

## [0.4.7] - 2025-12-21

### Changed

- Updated bindings from TNT Core contracts

## [0.4.6] - 2025-12-18

### Changed

- Updated bindings from TNT Core contracts

## [0.4.5] - 2025-12-17

### Changed

- Updated bindings from TNT Core contracts

## [0.4.4] - 2025-12-16

### Changed

- Updated bindings from TNT Core contracts

## [0.4.3] - 2025-12-15

### Changed

- Updated bindings from TNT Core contracts

## [0.4.2] - 2025-12-15

### Changed

- Updated bindings from TNT Core contracts

## [0.4.1] - 2025-12-15

### Changed

- Updated bindings from TNT Core contracts

## [0.4.0] - 2025-12-11

### Changed

- Updated bindings from TNT Core contracts

## [0.3.0] - 2025-12-10

### Changed

- Updated bindings from TNT Core contracts

## [0.2.0] - 2025-12-10

### Changed

- Updated bindings from TNT Core contracts

## [0.1.0] - 2024-12-10

### Added

- Initial release of TNT Core Rust bindings
- `ITangle` - Main Tangle protocol interface
- `ITangleBlueprints` - Blueprint registration and management
- `ITangleServices` - Service lifecycle management
- `ITangleJobs` - Job submission and results
- `ITangleOperators` - Operator registration and status
- `ITangleSlashing` - Slashing mechanism
- `ITangleRewards` - Reward distribution
- `MultiAssetDelegation` - Multi-asset staking and delegation
- `IBlueprintServiceManager` - Blueprint service manager interface
- `IOperatorStatusRegistry` - Operator status tracking
- Raw ABI JSON exports via `abi` module
- `TNT_CORE_VERSION` constant for commit tracking

[Unreleased]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.11.3...HEAD
[0.11.1]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.11.0...bindings-v0.11.1
[0.11.0]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.10.9...bindings-v0.11.0
[0.1.0]: https://github.com/tangle-network/tnt-core/releases/tag/bindings-v0.1.0
[0.4.1]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.4.0...bindings-v0.4.1
[0.4.2]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.4.1...bindings-v0.4.2
[0.4.3]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.4.2...bindings-v0.4.3
[0.4.4]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.4.3...bindings-v0.4.4
[0.4.5]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.4.4...bindings-v0.4.5
[0.4.6]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.4.5...bindings-v0.4.6
[0.4.7]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.4.6...bindings-v0.4.7
[0.4.8]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.4.7...bindings-v0.4.8
[0.4.9]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.4.8...bindings-v0.4.9
[0.4.10]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.4.9...bindings-v0.4.10
[0.5.0]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.4.10...bindings-v0.5.0
[0.5.1]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.5.0...bindings-v0.5.1
[0.5.2]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.5.1...bindings-v0.5.2
[0.5.3]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.5.2...bindings-v0.5.3
[0.5.4]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.5.3...bindings-v0.5.4
[0.5.5]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.5.4...bindings-v0.5.5
[0.5.6]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.5.5...bindings-v0.5.6
[0.6.0]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.5.6...bindings-v0.6.0
[0.6.1]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.6.0...bindings-v0.6.1
[0.7.0]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.6.1...bindings-v0.7.0
[0.7.2]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.7.1...bindings-v0.7.2
[0.7.3]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.7.2...bindings-v0.7.3
[0.8.0]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.7.3...bindings-v0.8.0
[0.8.2]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.8.0...bindings-v0.8.2
[0.9.0]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.8.2...bindings-v0.9.0
[0.10.0]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.9.0...bindings-v0.10.0
[0.10.2]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.10.0...bindings-v0.10.2
[0.10.3]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.10.2...bindings-v0.10.3
[0.10.4]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.10.3...bindings-v0.10.4
[0.10.7]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.10.6...bindings-v0.10.7
[0.10.6]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.10.4...bindings-v0.10.6
[0.10.8]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.10.7...bindings-v0.10.8
[0.10.9]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.10.8...bindings-v0.10.9
[0.11.2]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.11.1...bindings-v0.11.2
[0.11.3]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.11.2...bindings-v0.11.3
