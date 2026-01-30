# Changelog

All notable changes to `tnt-core-bindings` will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

- **BREAKING**: Renamed `IRestaking` to `IStaking` interface
- **BREAKING**: Renamed `restaking` module to `staking`
- **BREAKING**: Renamed `PaymentSplit.restakerBps` to `stakerBps`
- Updated all bindings from TNT Core contracts with restaking→staking terminology refactoring

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

[Unreleased]: https://github.com/tangle-network/tnt-core/compare/bindings-v0.8.2...HEAD
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
