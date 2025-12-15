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
    address internal constant TNT_ADDRESS_SENTINEL = address(1);

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
        uint16 defaultTntMinExposureBps;
        uint16 tntRestakerFeeBps;
        uint16 tntPaymentDiscountBps;
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

        if (cfg.incentives.tntToken != address(0) && cfg.core.operatorBondToken != address(0)) {
            require(cfg.incentives.tntToken == cfg.core.operatorBondToken, "TNT token mismatch");
        }
        if (cfg.core.operatorBondToken == address(0) && cfg.incentives.tntToken != address(0)) {
            cfg.core.operatorBondToken = cfg.incentives.tntToken;
        }

        _applyCoreOverrides(cfg.core);

        (address restaking, address tangle, address statusRegistry) =
            _resolveCore(cfg.core, deployerKey, deployer, admin, treasury);

        (address metrics, address rewardVaults, address inflationPool, address tntToken, uint256 epochLength) =
            _prepareIncentives(cfg.incentives, admin);

        _substituteTntSentinel(cfg.restakeAssets, cfg.incentives.vaults, tntToken);

        vm.startBroadcast(deployerKey);
        _configureRestaking(restaking, cfg.restakeAssets);
        _applyRewardsManager(restaking, rewardVaults, inflationPool);
        _configureRewardVaults(rewardVaults, cfg.incentives.vaults);
        _configureInflationPool(inflationPool, cfg.incentives, metrics, rewardVaults);
        _wireTangleModules(tangle, statusRegistry, metrics, rewardVaults, tntToken, cfg.incentives, cfg.guards);
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
        string memory jsonBlob = vm.readFile(path);
        if (bytes(jsonBlob).length == 0) {
            revert("Empty config file");
        }

        if (jsonBlob.keyExists(".network")) cfg.network = jsonBlob.readString(".network");

        if (jsonBlob.keyExists(".roles.admin")) cfg.roles.admin = jsonBlob.readAddress(".roles.admin");
        if (jsonBlob.keyExists(".roles.treasury")) cfg.roles.treasury = jsonBlob.readAddress(".roles.treasury");

        if (jsonBlob.keyExists(".core.deploy")) cfg.core.deploy = jsonBlob.readBool(".core.deploy");
        if (jsonBlob.keyExists(".core.tangle")) cfg.core.tangle = jsonBlob.readAddress(".core.tangle");
        if (jsonBlob.keyExists(".core.restaking")) cfg.core.restaking = jsonBlob.readAddress(".core.restaking");
        if (jsonBlob.keyExists(".core.statusRegistry")) cfg.core.statusRegistry = jsonBlob.readAddress(".core.statusRegistry");
        if (jsonBlob.keyExists(".core.minOperatorStake")) {
            cfg.core.minOperatorStake = jsonBlob.readUint(".core.minOperatorStake");
        }
        if (jsonBlob.keyExists(".core.minDelegation")) cfg.core.minDelegation = jsonBlob.readUint(".core.minDelegation");
        if (jsonBlob.keyExists(".core.operatorCommissionBps")) {
            cfg.core.operatorCommissionBps = uint16(jsonBlob.readUint(".core.operatorCommissionBps"));
        }
        if (jsonBlob.keyExists(".core.operatorBondToken")) {
            cfg.core.operatorBondToken = jsonBlob.readAddress(".core.operatorBondToken");
        }
        if (jsonBlob.keyExists(".core.operatorBondAmount")) cfg.core.operatorBondAmount = jsonBlob.readUint(".core.operatorBondAmount");
        if (jsonBlob.keyExists(".core.maxBlueprintsPerOperator")) {
            cfg.core.maxBlueprintsPerOperator = uint32(jsonBlob.readUint(".core.maxBlueprintsPerOperator"));
        }

        cfg.restakeAssets = _loadRestakeAssets(jsonBlob);

        if (jsonBlob.keyExists(".incentives.deployMetrics")) {
            cfg.incentives.deployMetrics = jsonBlob.readBool(".incentives.deployMetrics");
        }
        if (jsonBlob.keyExists(".incentives.deployRewardVaults")) {
            cfg.incentives.deployRewardVaults = jsonBlob.readBool(".incentives.deployRewardVaults");
        }
        if (jsonBlob.keyExists(".incentives.deployInflationPool")) {
            cfg.incentives.deployInflationPool = jsonBlob.readBool(".incentives.deployInflationPool");
        }
        if (jsonBlob.keyExists(".incentives.metrics")) cfg.incentives.metrics = jsonBlob.readAddress(".incentives.metrics");
        if (jsonBlob.keyExists(".incentives.rewardVaults")) {
            cfg.incentives.rewardVaults = jsonBlob.readAddress(".incentives.rewardVaults");
        }
        if (jsonBlob.keyExists(".incentives.inflationPool")) {
            cfg.incentives.inflationPool = jsonBlob.readAddress(".incentives.inflationPool");
        }
        if (jsonBlob.keyExists(".incentives.tntToken")) cfg.incentives.tntToken = jsonBlob.readAddress(".incentives.tntToken");
        if (jsonBlob.keyExists(".incentives.defaultTntMinExposureBps")) {
            cfg.incentives.defaultTntMinExposureBps = uint16(jsonBlob.readUint(".incentives.defaultTntMinExposureBps"));
        }
        if (jsonBlob.keyExists(".incentives.tntRestakerFeeBps")) {
            cfg.incentives.tntRestakerFeeBps = uint16(jsonBlob.readUint(".incentives.tntRestakerFeeBps"));
        }
        if (jsonBlob.keyExists(".incentives.tntPaymentDiscountBps")) {
            cfg.incentives.tntPaymentDiscountBps = uint16(jsonBlob.readUint(".incentives.tntPaymentDiscountBps"));
        }
        if (jsonBlob.keyExists(".incentives.vaultOperatorCommissionBps")) {
            cfg.incentives.vaultOperatorCommissionBps = uint16(jsonBlob.readUint(".incentives.vaultOperatorCommissionBps"));
        }
        if (jsonBlob.keyExists(".incentives.epochLength")) cfg.incentives.epochLength = jsonBlob.readUint(".incentives.epochLength");

        if (jsonBlob.keyExists(".incentives.weights.stakingBps")) {
            cfg.incentives.weights.stakingBps = uint16(jsonBlob.readUint(".incentives.weights.stakingBps"));
        }
        if (jsonBlob.keyExists(".incentives.weights.operatorsBps")) {
            cfg.incentives.weights.operatorsBps = uint16(jsonBlob.readUint(".incentives.weights.operatorsBps"));
        }
        if (jsonBlob.keyExists(".incentives.weights.customersBps")) {
            cfg.incentives.weights.customersBps = uint16(jsonBlob.readUint(".incentives.weights.customersBps"));
        }
        if (jsonBlob.keyExists(".incentives.weights.developersBps")) {
            cfg.incentives.weights.developersBps = uint16(jsonBlob.readUint(".incentives.weights.developersBps"));
        }

        cfg.incentives.vaults = _loadVaults(jsonBlob);

        if (jsonBlob.keyExists(".guards.pauseRestaking")) cfg.guards.pauseRestaking = jsonBlob.readBool(".guards.pauseRestaking");
        if (jsonBlob.keyExists(".guards.pauseTangle")) cfg.guards.pauseTangle = jsonBlob.readBool(".guards.pauseTangle");
        if (jsonBlob.keyExists(".guards.requireAdapters")) cfg.guards.requireAdapters = jsonBlob.readBool(".guards.requireAdapters");
        if (jsonBlob.keyExists(".guards.delegatorDelay")) cfg.guards.delegatorDelay = uint64(jsonBlob.readUint(".guards.delegatorDelay"));
        if (jsonBlob.keyExists(".guards.operatorDelay")) cfg.guards.operatorDelay = uint64(jsonBlob.readUint(".guards.operatorDelay"));
        if (jsonBlob.keyExists(".guards.bondLessDelay")) cfg.guards.bondLessDelay = uint64(jsonBlob.readUint(".guards.bondLessDelay"));
        if (jsonBlob.keyExists(".guards.maxBlueprintsPerOperator")) {
            cfg.guards.maxBlueprintsPerOperator = uint32(jsonBlob.readUint(".guards.maxBlueprintsPerOperator"));
        }

        if (jsonBlob.keyExists(".manifest.path")) cfg.manifest.path = jsonBlob.readString(".manifest.path");
        if (jsonBlob.keyExists(".manifest.logSummary")) cfg.manifest.logSummary = jsonBlob.readBool(".manifest.logSummary");

        if (jsonBlob.keyExists(".migration.emitArtifacts")) cfg.migration.emitArtifacts = jsonBlob.readBool(".migration.emitArtifacts");
        if (jsonBlob.keyExists(".migration.artifactsPath")) cfg.migration.artifactsPath = jsonBlob.readString(".migration.artifactsPath");
        if (jsonBlob.keyExists(".migration.merklePath")) cfg.migration.merklePath = jsonBlob.readString(".migration.merklePath");
        if (jsonBlob.keyExists(".migration.notes")) cfg.migration.notes = jsonBlob.readString(".migration.notes");
    }

    function _loadRestakeAssets(string memory jsonBlob) internal view returns (RestakeAssetConfig[] memory assets) {
        uint256 count;
        while (jsonBlob.keyExists(string.concat(".restakeAssets[", count.toString(), "].symbol"))) {
            count++;
        }
        assets = new RestakeAssetConfig[](count);
        for (uint256 i = 0; i < count; i++) {
            string memory base = string.concat(".restakeAssets[", i.toString(), "]");
            assets[i].symbol = jsonBlob.readString(string.concat(base, ".symbol"));
            assets[i].token = jsonBlob.readAddress(string.concat(base, ".token"));
            if (jsonBlob.keyExists(string.concat(base, ".adapter"))) {
                assets[i].adapter = jsonBlob.readAddress(string.concat(base, ".adapter"));
            }
            if (jsonBlob.keyExists(string.concat(base, ".minOperatorStake"))) {
                assets[i].minOperatorStake = jsonBlob.readUint(string.concat(base, ".minOperatorStake"));
            }
            if (jsonBlob.keyExists(string.concat(base, ".minDelegation"))) {
                assets[i].minDelegation = jsonBlob.readUint(string.concat(base, ".minDelegation"));
            }
            if (jsonBlob.keyExists(string.concat(base, ".depositCap"))) {
                assets[i].depositCap = jsonBlob.readUint(string.concat(base, ".depositCap"));
            }
            if (jsonBlob.keyExists(string.concat(base, ".rewardMultiplierBps"))) {
                assets[i].rewardMultiplierBps = uint16(jsonBlob.readUint(string.concat(base, ".rewardMultiplierBps")));
            }
        }
    }

    function _loadVaults(string memory jsonBlob) internal view returns (RewardVaultConfig[] memory vaults) {
        uint256 count;
        while (jsonBlob.keyExists(string.concat(".incentives.vaults[", count.toString(), "].asset"))) {
            count++;
        }
        vaults = new RewardVaultConfig[](count);
        for (uint256 i = 0; i < count; i++) {
            string memory base = string.concat(".incentives.vaults[", i.toString(), "]");
            vaults[i].asset = jsonBlob.readAddress(string.concat(base, ".asset"));
            if (jsonBlob.keyExists(string.concat(base, ".apyBps"))) {
                vaults[i].apyBps = jsonBlob.readUint(string.concat(base, ".apyBps"));
            }
            if (jsonBlob.keyExists(string.concat(base, ".depositCap"))) {
                vaults[i].depositCap = jsonBlob.readUint(string.concat(base, ".depositCap"));
            }
            if (jsonBlob.keyExists(string.concat(base, ".incentiveCap"))) {
                vaults[i].incentiveCap = jsonBlob.readUint(string.concat(base, ".incentiveCap"));
            }
            if (jsonBlob.keyExists(string.concat(base, ".boostMultiplierBps"))) {
                vaults[i].boostMultiplierBps = jsonBlob.readUint(string.concat(base, ".boostMultiplierBps"));
            }
            if (jsonBlob.keyExists(string.concat(base, ".active"))) {
                vaults[i].active = jsonBlob.readBool(string.concat(base, ".active"));
            }
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

    function _substituteTntSentinel(
        RestakeAssetConfig[] memory assets,
        RewardVaultConfig[] memory vaults,
        address tntToken
    )
        internal
        pure
    {
        if (tntToken == address(0)) return;

        for (uint256 i = 0; i < assets.length; i++) {
            if (assets[i].token == TNT_ADDRESS_SENTINEL) {
                assets[i].token = tntToken;
            }
        }
        for (uint256 i = 0; i < vaults.length; i++) {
            if (vaults[i].asset == TNT_ADDRESS_SENTINEL) {
                vaults[i].asset = tntToken;
            }
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
        address rewardVaults,
        address tntToken,
        IncentiveConfig memory inc,
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
        if (tntToken != address(0)) {
            tangleContract.setTntToken(tntToken);
            if (inc.defaultTntMinExposureBps != 0) {
                tangleContract.setDefaultTntMinExposureBps(inc.defaultTntMinExposureBps);
            }
        }
        if (rewardVaults != address(0)) {
            tangleContract.setRewardVaults(rewardVaults);
        }
        if (inc.tntRestakerFeeBps != 0) {
            tangleContract.setTntRestakerFeeBps(inc.tntRestakerFeeBps);
        }
        if (inc.tntPaymentDiscountBps != 0) {
            tangleContract.setTntPaymentDiscountBps(inc.tntPaymentDiscountBps);
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
