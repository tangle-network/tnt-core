// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { DeployV2, MissingEnv } from "./Deploy.s.sol";

import { stdJson } from "forge-std/StdJson.sol";
import { console2 } from "forge-std/console2.sol";

import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

import { Tangle } from "../../src/v2/Tangle.sol";
import { Types } from "../../src/v2/libraries/Types.sol";
import { MultiAssetDelegation } from "../../src/v2/restaking/MultiAssetDelegation.sol";
import { RewardVaults } from "../../src/v2/rewards/RewardVaults.sol";
import { TangleMetrics } from "../../src/v2/rewards/TangleMetrics.sol";
import { InflationPool } from "../../src/v2/rewards/InflationPool.sol";

/// @title FullDeploy
/// @notice Production-grade deployment orchestrator that composes all protocol modules
contract FullDeploy is DeployV2 {
    using stdJson for string;
    using Strings for uint256;

    string internal constant CONFIG_ENV = "FULL_DEPLOY_CONFIG";

    struct RolesConfig {
        address admin;
        address treasury;
    }

    struct CoreConfig {
        bool deploy;
        address tangle;
        address restaking;
        address statusRegistry;
        uint256 minOperatorStake;
        uint256 minDelegation;
        uint16 operatorCommissionBps;
        address operatorBondToken;
        uint256 operatorBondAmount;
        uint32 maxBlueprintsPerOperator;
    }

    struct RestakeAssetConfig {
        string symbol;
        address token;
        address adapter;
        uint256 minOperatorStake;
        uint256 minDelegation;
        uint256 depositCap;
        uint16 rewardMultiplierBps;
    }

    struct RewardVaultConfig {
        address asset;
        uint256 apyBps;
        uint256 depositCap;
        uint256 incentiveCap;
        uint256 boostMultiplierBps;
        bool active;
    }

    struct InflationWeights {
        uint16 stakingBps;
        uint16 operatorsBps;
        uint16 customersBps;
        uint16 developersBps;
    }

    struct IncentiveConfig {
        bool deployMetrics;
        bool deployRewardVaults;
        bool deployInflationPool;
        address metrics;
        address rewardVaults;
        address inflationPool;
        address tntToken;
        uint16 vaultOperatorCommissionBps;
        uint256 epochLength;
        InflationWeights weights;
        RewardVaultConfig[] vaults;
    }

    struct GuardsConfig {
        bool pauseRestaking;
        bool pauseTangle;
        bool requireAdapters;
        uint64 delegatorDelay;
        uint64 operatorDelay;
        uint64 bondLessDelay;
        uint32 maxBlueprintsPerOperator;
    }

    struct ManifestConfig {
        string path;
        bool logSummary;
    }

    struct MigrationConfig {
        bool emitArtifacts;
        string artifactsPath;
        string merklePath;
        string notes;
    }

    struct FullDeployConfig {
        string network;
        RolesConfig roles;
        CoreConfig core;
        RestakeAssetConfig[] restakeAssets;
        IncentiveConfig incentives;
        GuardsConfig guards;
        ManifestConfig manifest;
        MigrationConfig migration;
    }

    struct DeploymentArtifacts {
        string network;
        uint256 chainId;
        address deployer;
        address admin;
        address treasury;
        address tangle;
        address restaking;
        address statusRegistry;
        address tntToken;
        address metrics;
        address rewardVaults;
        address inflationPool;
        RestakeAssetConfig[] assets;
        RewardVaultConfig[] vaults;
        InflationWeights weights;
        uint256 epochLength;
        GuardsConfig guards;
        MigrationConfig migration;
    }

    function run() external override {
        string memory configPath = _requireConfigPath();
        FullDeployConfig memory cfg = _loadConfig(configPath);

        uint256 deployerKey = _requireEnvUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerKey);
        address admin = cfg.roles.admin == address(0) ? deployer : cfg.roles.admin;
        address treasury = cfg.roles.treasury == address(0) ? deployer : cfg.roles.treasury;

        console2.log("=== Full Deploy ===");
        console2.log("Network:", bytes(cfg.network).length == 0 ? "unknown" : cfg.network);
        console2.log("ChainId:", block.chainid);
        console2.log("Deployer:", deployer);
        console2.log("Admin:", admin);
        console2.log("Treasury:", treasury);

        _applyCoreOverrides(cfg.core);

        (address restaking, address tangle, address statusRegistry) =
            _resolveCore(cfg.core, deployerKey, deployer, admin, treasury);

        (address metrics, address rewardVaults, address inflationPool, address tntToken, uint256 epochLength) =
            _prepareIncentives(cfg.incentives, admin);

        vm.startBroadcast(deployerKey);
        _configureRestaking(restaking, cfg.restakeAssets);
        _applyRewardsManager(restaking, rewardVaults, inflationPool);
        _configureRewardVaults(rewardVaults, cfg.incentives.vaults);
        _configureInflationPool(inflationPool, cfg.incentives, metrics, rewardVaults);
        _wireTangleModules(tangle, statusRegistry, metrics, cfg.guards);
        _applyGuards(restaking, tangle, cfg.guards);
        vm.stopBroadcast();

        _runSmokeTests(restaking, tangle, rewardVaults, cfg.restakeAssets, cfg.guards);

        DeploymentArtifacts memory artifacts = DeploymentArtifacts({
            network: bytes(cfg.network).length == 0 ? "unknown" : cfg.network,
            chainId: block.chainid,
            deployer: deployer,
            admin: admin,
            treasury: treasury,
            tangle: tangle,
            restaking: restaking,
            statusRegistry: statusRegistry,
            tntToken: tntToken,
            metrics: metrics,
            rewardVaults: rewardVaults,
            inflationPool: inflationPool,
            assets: cfg.restakeAssets,
            vaults: cfg.incentives.vaults,
            weights: cfg.incentives.weights,
            epochLength: epochLength,
            guards: cfg.guards,
            migration: cfg.migration
        });

        _writeManifest(cfg.manifest, artifacts);
        _emitMigrationArtifacts(cfg.migration, artifacts);

        console2.log("\nDeployment complete.");
        console2.log("  Tangle:", tangle);
        console2.log("  Restaking:", restaking);
        if (rewardVaults != address(0)) {
            console2.log("  RewardVaults:", rewardVaults);
        }
        if (inflationPool != address(0)) {
            console2.log("  InflationPool:", inflationPool);
        }
        if (cfg.manifest.logSummary && bytes(cfg.manifest.path).length != 0) {
            console2.log("  Manifest:", cfg.manifest.path);
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // CONFIG LOADING
    // ═══════════════════════════════════════════════════════════════════════════

    function _requireConfigPath() internal view returns (string memory path) {
        try vm.envString(CONFIG_ENV) returns (string memory configured) {
            return configured;
        } catch {
            revert MissingEnv(CONFIG_ENV);
        }
    }

    function _loadConfig(string memory path) internal view returns (FullDeployConfig memory cfg) {
        string memory json = vm.readFile(path);
        if (bytes(json).length == 0) {
            revert("Empty config file");
        }

        if (json.keyExists(".network")) {
            cfg.network = json.readString(".network");
        }
        if (json.keyExists(".roles")) {
            cfg.roles = abi.decode(json.parseRaw(".roles"), (RolesConfig));
        }
        if (json.keyExists(".core")) {
            cfg.core = abi.decode(json.parseRaw(".core"), (CoreConfig));
        }
        if (json.keyExists(".restakeAssets")) {
            cfg.restakeAssets = abi.decode(json.parseRaw(".restakeAssets"), (RestakeAssetConfig[]));
        }
        if (json.keyExists(".incentives")) {
            cfg.incentives = abi.decode(json.parseRaw(".incentives"), (IncentiveConfig));
        }
        if (json.keyExists(".guards")) {
            cfg.guards = abi.decode(json.parseRaw(".guards"), (GuardsConfig));
        }
        if (json.keyExists(".manifest")) {
            cfg.manifest = abi.decode(json.parseRaw(".manifest"), (ManifestConfig));
        }
        if (json.keyExists(".migration")) {
            cfg.migration = abi.decode(json.parseRaw(".migration"), (MigrationConfig));
        }
    }

    function _applyCoreOverrides(CoreConfig memory core) internal {
        if (core.minOperatorStake != 0) {
            minOperatorStake = core.minOperatorStake;
        }
        if (core.minDelegation != 0) {
            minDelegation = core.minDelegation;
        }
        if (core.operatorCommissionBps != 0) {
            operatorCommissionBps = core.operatorCommissionBps;
        }
        if (core.operatorBondAmount != 0) {
            operatorBondAmount = core.operatorBondAmount;
        }
        if (core.operatorBondToken != address(0)) {
            operatorBondToken = core.operatorBondToken;
        }
    }

    function _resolveCore(
        CoreConfig memory core,
        uint256 deployerKey,
        address deployer,
        address admin,
        address treasury
    )
        internal
        returns (address restaking, address tangle, address statusRegistry)
    {
        bool needsDeploy = core.deploy || core.restaking == address(0) || core.tangle == address(0);
        if (needsDeploy) {
            console2.log("Deploying core stack...");
            (restaking,, tangle,, statusRegistry) = _deployCore(deployerKey, deployer, admin, treasury, true);
        } else {
            restaking = core.restaking;
            tangle = core.tangle;
            statusRegistry = core.statusRegistry;
            if (restaking == address(0) || tangle == address(0)) {
                revert("core.restaking and core.tangle must be set when deploy=false");
            }
        }
    }

    function _prepareIncentives(
        IncentiveConfig memory inc,
        address admin
    )
        internal
        returns (address metrics, address rewardVaults, address inflationPool, address tntToken, uint256 epochLength)
    {
        tntToken = inc.tntToken != address(0) ? inc.tntToken : operatorBondToken;

        if (inc.deployMetrics) {
            metrics = _deployMetricsProxy(admin);
        } else {
            metrics = inc.metrics;
        }

        if (inc.deployRewardVaults) {
            if (tntToken == address(0)) revert("Missing TNT token for RewardVaults");
            uint16 commission = inc.vaultOperatorCommissionBps == 0 ? 1500 : inc.vaultOperatorCommissionBps;
            rewardVaults = _deployRewardVaultsProxy(admin, tntToken, commission);
        } else {
            rewardVaults = inc.rewardVaults;
        }

        if (inc.deployInflationPool) {
            if (tntToken == address(0)) revert("Missing TNT token for InflationPool");
            // Epoch length is expressed in seconds (timestamp-based rewards).
            uint256 epoch = inc.epochLength == 0 ? 604_800 : inc.epochLength; // 7 days
            inflationPool = _deployInflationPoolProxy(admin, tntToken, metrics, rewardVaults, epoch);
            epochLength = epoch;
        } else {
            inflationPool = inc.inflationPool;
            epochLength = inc.epochLength;
        }
    }

    function _deployMetricsProxy(address admin) internal returns (address proxy) {
        TangleMetrics impl = new TangleMetrics();
        proxy = address(new ERC1967Proxy(address(impl), abi.encodeCall(TangleMetrics.initialize, (admin))));
        console2.log("Deployed TangleMetrics:", proxy);
    }

    function _deployRewardVaultsProxy(
        address admin,
        address tntToken,
        uint16 operatorCommissionBps
    )
        internal
        returns (address proxy)
    {
        RewardVaults impl = new RewardVaults();
        proxy = address(
            new ERC1967Proxy(
                address(impl), abi.encodeCall(RewardVaults.initialize, (admin, tntToken, operatorCommissionBps))
            )
        );
        console2.log("Deployed RewardVaults:", proxy);
    }

    function _deployInflationPoolProxy(
        address admin,
        address tntToken,
        address metrics,
        address rewardVaults,
        uint256 epochLength
    )
        internal
        returns (address proxy)
    {
        InflationPool impl = new InflationPool();
        proxy = address(
            new ERC1967Proxy(
                address(impl),
                abi.encodeCall(InflationPool.initialize, (admin, tntToken, metrics, rewardVaults, epochLength))
            )
        );
        console2.log("Deployed InflationPool:", proxy);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // CONFIGURATION TASKS
    // ═══════════════════════════════════════════════════════════════════════════

    function _configureRestaking(address restakingAddr, RestakeAssetConfig[] memory assets) internal {
        if (restakingAddr == address(0)) return;

        MultiAssetDelegation restaking = MultiAssetDelegation(payable(restakingAddr));
        for (uint256 i = 0; i < assets.length; i++) {
            RestakeAssetConfig memory asset = assets[i];
            if (asset.token == address(0)) {
                console2.log("Skipping asset with zero token (", asset.symbol, ")");
                continue;
            }

            Types.AssetConfig memory existing = restaking.getAssetConfig(asset.token);
            if (existing.enabled) {
                console2.log("Asset already enabled:", asset.symbol);
                continue;
            }

            uint16 multiplier = asset.rewardMultiplierBps == 0 ? uint16(10_000) : asset.rewardMultiplierBps;
            if (asset.adapter != address(0)) {
                restaking.enableAssetWithAdapter(
                    asset.token,
                    asset.adapter,
                    asset.minOperatorStake,
                    asset.minDelegation,
                    asset.depositCap,
                    multiplier
                );
            } else {
                restaking.enableAsset(
                    asset.token, asset.minOperatorStake, asset.minDelegation, asset.depositCap, multiplier
                );
            }

            console2.log("Enabled asset:", asset.symbol);
        }
    }

    function _applyRewardsManager(address restakingAddr, address rewardVaultsAddr, address inflationPoolAddr) internal {
        if (restakingAddr == address(0) || rewardVaultsAddr == address(0)) return;
        MultiAssetDelegation restaking = MultiAssetDelegation(payable(restakingAddr));
        restaking.setRewardsManager(rewardVaultsAddr);
        console2.log("Set RewardVaults manager on restaking");

        // RewardVaults is called by:
        // - MultiAssetDelegation (stake tracking + service rewards)
        // - InflationPool (epoch reward fan-out)
        RewardVaults vaultsContract = RewardVaults(rewardVaultsAddr);
        bytes32 role = vaultsContract.REWARDS_MANAGER_ROLE();

        if (!vaultsContract.hasRole(role, restakingAddr)) {
            vaultsContract.grantRole(role, restakingAddr);
            console2.log("Granted RewardVaults manager role to restaking");
        }
        if (inflationPoolAddr != address(0) && !vaultsContract.hasRole(role, inflationPoolAddr)) {
            vaultsContract.grantRole(role, inflationPoolAddr);
            console2.log("Granted RewardVaults manager role to InflationPool");
        }
    }

    function _configureRewardVaults(address rewardVaultsAddr, RewardVaultConfig[] memory vaults) internal {
        if (rewardVaultsAddr == address(0) || vaults.length == 0) return;
        RewardVaults vaultsContract = RewardVaults(rewardVaultsAddr);
        for (uint256 i = 0; i < vaults.length; i++) {
            RewardVaultConfig memory cfg = vaults[i];
            uint256 depositCapExisting;
            (, depositCapExisting,,,) = vaultsContract.vaultConfigs(cfg.asset);
            if (depositCapExisting != 0) {
                console2.log("Vault already exists for asset:", cfg.asset);
                continue;
            }
            vaultsContract.createVault(cfg.asset, cfg.apyBps, cfg.depositCap, cfg.incentiveCap, cfg.boostMultiplierBps);
            if (!cfg.active) {
                vaultsContract.deactivateVault(cfg.asset);
            }
            console2.log("Configured reward vault:", cfg.asset);
        }
    }

    function _configureInflationPool(
        address poolAddr,
        IncentiveConfig memory inc,
        address metrics,
        address rewardVaults
    )
        internal
    {
        if (poolAddr == address(0)) return;

        InflationPool pool = InflationPool(payable(poolAddr));

        if (metrics != address(0) || rewardVaults != address(0)) {
            pool.setContracts(address(0), metrics, rewardVaults);
        }

        InflationWeights memory weights = inc.weights;
        if (
            weights.stakingBps != 0 || weights.operatorsBps != 0 || weights.customersBps != 0
                || weights.developersBps != 0
        ) {
            uint256 total = uint256(weights.stakingBps) + uint256(weights.operatorsBps) + uint256(weights.customersBps)
                + uint256(weights.developersBps);
            require(total == 10_000, "Inflation weights must sum to 10_000 bps");
            pool.setWeights(weights.stakingBps, weights.operatorsBps, weights.customersBps, weights.developersBps);
        }

        if (inc.epochLength != 0) {
            pool.setEpochLength(inc.epochLength);
        }
    }

    function _wireTangleModules(
        address tangleAddr,
        address statusRegistry,
        address metrics,
        GuardsConfig memory guards
    )
        internal
    {
        if (tangleAddr == address(0)) return;
        Tangle tangleContract = Tangle(payable(tangleAddr));
        if (statusRegistry != address(0)) {
            tangleContract.setOperatorStatusRegistry(statusRegistry);
        }
        if (metrics != address(0)) {
            tangleContract.setMetricsRecorder(metrics);
        }
        if (guards.maxBlueprintsPerOperator != 0) {
            tangleContract.setMaxBlueprintsPerOperator(guards.maxBlueprintsPerOperator);
        }
    }

    function _applyGuards(address restakingAddr, address tangleAddr, GuardsConfig memory guards) internal {
        if (restakingAddr != address(0)) {
            MultiAssetDelegation restaking = MultiAssetDelegation(payable(restakingAddr));
            if (guards.requireAdapters) {
                restaking.setRequireAdapters(true);
            }
            if (guards.delegatorDelay != 0 || guards.operatorDelay != 0 || guards.bondLessDelay != 0) {
                restaking.setDelays(guards.bondLessDelay, guards.delegatorDelay, guards.operatorDelay);
            }
            if (guards.pauseRestaking) {
                restaking.pause();
            }
        }

        if (tangleAddr != address(0) && guards.pauseTangle) {
            Tangle(payable(tangleAddr)).pause();
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // VALIDATION & OUTPUT
    // ═══════════════════════════════════════════════════════════════════════════

    function _runSmokeTests(
        address restakingAddr,
        address tangleAddr,
        address rewardVaultsAddr,
        RestakeAssetConfig[] memory assets,
        GuardsConfig memory guards
    )
        internal
        view
    {
        if (restakingAddr != address(0)) {
            MultiAssetDelegation restaking = MultiAssetDelegation(payable(restakingAddr));
            for (uint256 i = 0; i < assets.length; i++) {
                RestakeAssetConfig memory asset = assets[i];
                if (asset.token == address(0)) continue;
                Types.AssetConfig memory cfg = restaking.getAssetConfig(asset.token);
                if (!cfg.enabled) {
                    revert(string.concat("Asset disabled: ", asset.symbol));
                }
            }
            if (rewardVaultsAddr != address(0)) {
                require(restaking.rewardsManager() == rewardVaultsAddr, "Rewards manager mismatch");
            }
        }

        if (tangleAddr != address(0) && guards.maxBlueprintsPerOperator != 0) {
            uint32 configured = Tangle(payable(tangleAddr)).maxBlueprintsPerOperator();
            require(configured == guards.maxBlueprintsPerOperator, "Max blueprint limit mismatch");
        }
    }

    function _writeManifest(ManifestConfig memory manifest, DeploymentArtifacts memory artifacts) internal {
        if (bytes(manifest.path).length == 0) return;

        _ensureParentDir(manifest.path);

        string memory json = string(
            abi.encodePacked(
                "{",
                "\"network\":\"",
                artifacts.network,
                "\",",
                "\"chainId\":",
                artifacts.chainId.toString(),
                ",",
                "\"deployer\":\"",
                _addrToString(artifacts.deployer),
                "\",",
                "\"admin\":\"",
                _addrToString(artifacts.admin),
                "\",",
                "\"treasury\":\"",
                _addrToString(artifacts.treasury),
                "\",",
                "\"tangle\":\"",
                _addrToString(artifacts.tangle),
                "\",",
                "\"restaking\":\"",
                _addrToString(artifacts.restaking),
                "\",",
                "\"statusRegistry\":\"",
                _addrToString(artifacts.statusRegistry),
                "\",",
                "\"tntToken\":\"",
                _addrToString(artifacts.tntToken),
                "\",",
                "\"metrics\":\"",
                _addrToString(artifacts.metrics),
                "\",",
                "\"rewardVaults\":\"",
                _addrToString(artifacts.rewardVaults),
                "\",",
                "\"inflationPool\":\"",
                _addrToString(artifacts.inflationPool),
                "\",",
                "\"epochLength\":",
                artifacts.epochLength.toString(),
                ",",
                "\"restakeAssets\":",
                _assetsToJson(artifacts.assets),
                ",",
                "\"rewardVaultsConfig\":",
                _vaultsToJson(artifacts.vaults),
                ",",
                "\"inflationWeights\":",
                _weightsToJson(artifacts.weights),
                ",",
                "\"guards\":",
                _guardsToJson(artifacts.guards),
                ",",
                "\"migration\":",
                _migrationToJson(artifacts.migration),
                "}"
            )
        );

        vm.writeJson(json, manifest.path);
    }

    function _emitMigrationArtifacts(MigrationConfig memory migration, DeploymentArtifacts memory artifacts) internal {
        if (!migration.emitArtifacts || bytes(migration.artifactsPath).length == 0) return;

        _ensureParentDir(migration.artifactsPath);

        string memory json = string(
            abi.encodePacked(
                "{",
                "\"tntToken\":\"",
                _addrToString(artifacts.tntToken),
                "\",",
                "\"restaking\":\"",
                _addrToString(artifacts.restaking),
                "\",",
                "\"tangle\":\"",
                _addrToString(artifacts.tangle),
                "\",",
                "\"merklePath\":\"",
                migration.merklePath,
                "\",",
                "\"notes\":\"",
                migration.notes,
                "\"",
                "}"
            )
        );
        vm.writeJson(json, migration.artifactsPath);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // JSON HELPERS
    // ═══════════════════════════════════════════════════════════════════════════

    function _assetsToJson(RestakeAssetConfig[] memory assets) internal pure returns (string memory) {
        bytes memory buffer = abi.encodePacked("[");
        for (uint256 i = 0; i < assets.length; i++) {
            RestakeAssetConfig memory asset = assets[i];
            buffer = abi.encodePacked(
                buffer,
                i == 0 ? "{" : ",{",
                '"symbol":"',
                asset.symbol,
                '",',
                '"token":"',
                _addrToString(asset.token),
                '",',
                '"adapter":"',
                _addrToString(asset.adapter),
                '",',
                '"minOperatorStake":"',
                _uintToString(asset.minOperatorStake),
                '",',
                '"minDelegation":"',
                _uintToString(asset.minDelegation),
                '",',
                '"depositCap":"',
                _uintToString(asset.depositCap),
                '",',
                '"rewardMultiplierBps":',
                uint256(asset.rewardMultiplierBps).toString(),
                "}"
            );
        }
        buffer = abi.encodePacked(buffer, "]");
        return string(buffer);
    }

    function _vaultsToJson(RewardVaultConfig[] memory vaults) internal pure returns (string memory) {
        bytes memory buffer = abi.encodePacked("[");
        for (uint256 i = 0; i < vaults.length; i++) {
            RewardVaultConfig memory vault = vaults[i];
            buffer = abi.encodePacked(
                buffer,
                i == 0 ? "{" : ",{",
                '"asset":"',
                _addrToString(vault.asset),
                '",',
                '"apyBps":',
                vault.apyBps.toString(),
                ",",
                '"depositCap":"',
                _uintToString(vault.depositCap),
                '",',
                '"incentiveCap":"',
                _uintToString(vault.incentiveCap),
                '",',
                '"boostMultiplierBps":',
                vault.boostMultiplierBps.toString(),
                ",",
                '"active":',
                _boolToString(vault.active),
                "}"
            );
        }
        buffer = abi.encodePacked(buffer, "]");
        return string(buffer);
    }

    function _weightsToJson(InflationWeights memory weights) internal pure returns (string memory) {
        return string(
            abi.encodePacked(
                "{",
                '"stakingBps":',
                uint256(weights.stakingBps).toString(),
                ",",
                '"operatorsBps":',
                uint256(weights.operatorsBps).toString(),
                ",",
                '"customersBps":',
                uint256(weights.customersBps).toString(),
                ",",
                '"developersBps":',
                uint256(weights.developersBps).toString(),
                "}"
            )
        );
    }

    function _guardsToJson(GuardsConfig memory guards) internal pure returns (string memory) {
        return string(
            abi.encodePacked(
                "{",
                '"pauseRestaking":',
                _boolToString(guards.pauseRestaking),
                ",",
                '"pauseTangle":',
                _boolToString(guards.pauseTangle),
                ",",
                '"requireAdapters":',
                _boolToString(guards.requireAdapters),
                ",",
                '"delegatorDelay":',
                uint256(guards.delegatorDelay).toString(),
                ",",
                '"operatorDelay":',
                uint256(guards.operatorDelay).toString(),
                ",",
                '"bondLessDelay":',
                uint256(guards.bondLessDelay).toString(),
                ",",
                '"maxBlueprintsPerOperator":',
                uint256(guards.maxBlueprintsPerOperator).toString(),
                "}"
            )
        );
    }

    function _migrationToJson(MigrationConfig memory migration) internal pure returns (string memory) {
        return string(
            abi.encodePacked(
                "{",
                '"emitArtifacts":',
                _boolToString(migration.emitArtifacts),
                ",",
                '"artifactsPath":"',
                migration.artifactsPath,
                '",',
                '"merklePath":"',
                migration.merklePath,
                '",',
                '"notes":"',
                migration.notes,
                '"',
                "}"
            )
        );
    }

    function _addrToString(address value) internal pure returns (string memory) {
        return Strings.toHexString(uint256(uint160(value)), 20);
    }

    function _uintToString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        return value.toString();
    }

    function _boolToString(bool value) internal pure returns (string memory) {
        return value ? "true" : "false";
    }

    function _ensureParentDir(string memory filePath) internal {
        string memory dir = _parentDir(filePath);
        if (bytes(dir).length == 0) {
            return;
        }
        vm.createDir(dir, true);
    }

    function _parentDir(string memory filePath) internal pure returns (string memory dir) {
        bytes memory pathBytes = bytes(filePath);
        if (pathBytes.length == 0) {
            return "";
        }

        for (uint256 i = pathBytes.length; i > 0; i--) {
            if (pathBytes[i - 1] == "/") {
                if (i <= 1) {
                    return "";
                }
                bytes memory dirBytes = new bytes(i - 1);
                for (uint256 j = 0; j < i - 1; j++) {
                    dirBytes[j] = pathBytes[j];
                }
                return string(dirBytes);
            }
        }

        return "";
    }
}
