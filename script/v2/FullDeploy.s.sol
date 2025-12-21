// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { DeployV2, MissingEnv } from "./Deploy.s.sol";

import { stdJson } from "forge-std/StdJson.sol";
import { console2 } from "forge-std/console2.sol";

import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import { IAccessControl } from "@openzeppelin/contracts/access/IAccessControl.sol";
import { Tangle } from "../../src/v2/Tangle.sol";
import { Types } from "../../src/v2/libraries/Types.sol";
import { IMultiAssetDelegation } from "../../src/v2/interfaces/IMultiAssetDelegation.sol";
import { MultiAssetDelegation } from "../../src/v2/restaking/MultiAssetDelegation.sol";
import { RewardVaults } from "../../src/v2/rewards/RewardVaults.sol";
import { TangleMetrics } from "../../src/v2/rewards/TangleMetrics.sol";
import { InflationPool } from "../../src/v2/rewards/InflationPool.sol";
import { ServiceFeeDistributor } from "../../src/v2/rewards/ServiceFeeDistributor.sol";
import { StreamingPaymentManager } from "../../src/v2/rewards/StreamingPaymentManager.sol";
import { TangleMigration } from "../../packages/migration-claim/src/TangleMigration.sol";
import { SP1ZKVerifier } from "../../packages/migration-claim/src/SP1ZKVerifier.sol";
import { Credits } from "../../packages/credits/src/Credits.sol";

/// @title FullDeploy
/// @notice Production-grade deployment orchestrator that composes all protocol modules
contract FullDeploy is DeployV2 {
    using stdJson for string;
    using Strings for uint256;
    using SafeERC20 for IERC20;

    string internal constant CONFIG_ENV = "FULL_DEPLOY_CONFIG";
    address internal constant TNT_ADDRESS_SENTINEL = address(1);
    address internal constant SP1_VERIFIER_BASE = 0x397A5f7f3dBd538f23DE225B51f532c34448dA9B;

    struct RolesConfig {
        address admin;
        address treasury;
        address timelock;
        address multisig;
        bool revokeBootstrap;
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
        uint16 restakersBps;
    }

    struct IncentiveConfig {
        bool deployMetrics;
        bool deployRewardVaults;
        bool deployInflationPool;
        bool deployServiceFeeDistributor;
        bool deployStreamingPaymentManager;
        address metrics;
        address rewardVaults;
        address inflationPool;
        address serviceFeeDistributor;
        address streamingPaymentManager;
        address tntToken;
        address priceOracle;
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
        bool deploy;
        bool emitArtifacts;
        bool useMockVerifier;
        string artifactsPath;
        string merklePath;
        string evmClaimsPath;
        string treasuryCarveoutPath;
        string foundationCarveoutPath;
        string notes;
        address migrationOwner;
        address sp1VerifierGateway;
        bytes32 programVKey;
        bytes32 merkleRoot;
        uint256 substrateAllocation;
        uint256 evmAllocation;
        address treasuryRecipient;
        uint256 treasuryAmount;
        address foundationRecipient;
        uint256 foundationAmount;
        uint256 claimDeadline;
        uint16 unlockedBps;
        uint64 unlockTimestamp;
        address tangleMigration;
        address zkVerifier;
    }

    struct CreditsConfig {
        bool deploy;
        address owner;
        address credits;
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
        CreditsConfig credits;
    }

    struct DeploymentArtifacts {
        string network;
        uint256 chainId;
        address deployer;
        address admin;
        address treasury;
        address timelock;
        address multisig;
        address tangle;
        address restaking;
        address statusRegistry;
        address tntToken;
        address metrics;
        address rewardVaults;
        address inflationPool;
        address credits;
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
        address timelock = cfg.roles.timelock == address(0) ? admin : cfg.roles.timelock;
        address multisig = cfg.roles.multisig == address(0) ? admin : cfg.roles.multisig;

        console2.log("=== Full Deploy ===");
        console2.log("Network:", bytes(cfg.network).length == 0 ? "unknown" : cfg.network);
        console2.log("ChainId:", block.chainid);
        console2.log("Deployer:", deployer);
        console2.log("Admin:", admin);
        console2.log("Treasury:", treasury);
        console2.log("Timelock:", timelock);
        console2.log("Multisig:", multisig);

        MigrationConfig memory migration = cfg.migration;
        if (migration.deploy) {
            migration = _resolveMigrationConfig(migration);
            require(!migration.useMockVerifier, "Mock verifier disabled");
            uint256 totalSupply =
                migration.substrateAllocation + migration.evmAllocation + migration.treasuryAmount + migration.foundationAmount;
            if (cfg.core.operatorBondToken == address(0) && cfg.incentives.tntToken == address(0)) {
                tntInitialSupply = totalSupply;
            }
        }

        if (cfg.incentives.tntToken != address(0) && cfg.core.operatorBondToken != address(0)) {
            require(cfg.incentives.tntToken == cfg.core.operatorBondToken, "TNT token mismatch");
        }
        if (cfg.core.operatorBondToken == address(0) && cfg.incentives.tntToken != address(0)) {
            cfg.core.operatorBondToken = cfg.incentives.tntToken;
        }

        _applyCoreOverrides(cfg.core);

        (address restaking, address tangle, address statusRegistry) =
            _resolveCore(cfg.core, deployerKey, deployer, admin, treasury);

        vm.startBroadcast(deployerKey);

        (address metrics, address rewardVaults, address inflationPool, address tntToken, uint256 epochLength) =
            _prepareIncentives(cfg.incentives, admin);

        address priceOracle = cfg.incentives.priceOracle;
        address serviceFeeDistributor = cfg.incentives.serviceFeeDistributor;
        if (cfg.incentives.deployServiceFeeDistributor) {
            serviceFeeDistributor = _deployServiceFeeDistributorProxy(admin, restaking, tangle, priceOracle);
        }

        address streamingPaymentManager = cfg.incentives.streamingPaymentManager;
        if (cfg.incentives.deployStreamingPaymentManager) {
            streamingPaymentManager = _deployStreamingPaymentManagerProxy(admin, tangle, serviceFeeDistributor);
        }

        _substituteTntSentinel(cfg.restakeAssets, cfg.incentives.vaults, tntToken);
        _configureRestaking(restaking, cfg.restakeAssets);
        _applyRewardsManager(restaking, rewardVaults, inflationPool);
        _wireServiceFeeDistributor(restaking, tangle, serviceFeeDistributor, streamingPaymentManager, priceOracle);
        _configureRewardVaults(rewardVaults, cfg.incentives.vaults);
        _configureInflationPool(inflationPool, cfg.incentives, metrics, rewardVaults);
        _wireTangleModules(tangle, statusRegistry, metrics, rewardVaults, tntToken, cfg.incentives, cfg.guards);
        _applyGuards(restaking, tangle, cfg.guards);
        if (migration.deploy) {
            migration = _deployMigration(migration, tntToken, deployer, timelock, treasury);
        }
        address credits = _resolveCredits(cfg.credits, admin, timelock);
        _applyRoleHandoff(
            cfg.roles,
            admin,
            timelock,
            multisig,
            tangle,
            restaking,
            tntToken,
            metrics,
            rewardVaults,
            inflationPool,
            serviceFeeDistributor,
            streamingPaymentManager,
            treasury
        );
        vm.stopBroadcast();

        _runSmokeTests(restaking, tangle, rewardVaults, cfg.restakeAssets, cfg.guards);

        DeploymentArtifacts memory artifacts = DeploymentArtifacts({
            network: bytes(cfg.network).length == 0 ? "unknown" : cfg.network,
            chainId: block.chainid,
            deployer: deployer,
            admin: admin,
            treasury: treasury,
            timelock: timelock,
            multisig: multisig,
            tangle: tangle,
            restaking: restaking,
            statusRegistry: statusRegistry,
            tntToken: tntToken,
            metrics: metrics,
            rewardVaults: rewardVaults,
            inflationPool: inflationPool,
            credits: credits,
            assets: cfg.restakeAssets,
            vaults: cfg.incentives.vaults,
            weights: cfg.incentives.weights,
            epochLength: epochLength,
            guards: cfg.guards,
            migration: migration
        });

        _writeManifest(cfg.manifest, artifacts);
        _emitMigrationArtifacts(migration, artifacts);

        console2.log("\nDeployment complete.");
        console2.log("  Tangle:", tangle);
        console2.log("  Restaking:", restaking);
        if (rewardVaults != address(0)) {
            console2.log("  RewardVaults:", rewardVaults);
        }
        if (inflationPool != address(0)) {
            console2.log("  InflationPool:", inflationPool);
        }
        if (credits != address(0)) {
            console2.log("  Credits:", credits);
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
        if (jsonBlob.keyExists(".roles.timelock")) cfg.roles.timelock = jsonBlob.readAddress(".roles.timelock");
        if (jsonBlob.keyExists(".roles.multisig")) cfg.roles.multisig = jsonBlob.readAddress(".roles.multisig");
        if (jsonBlob.keyExists(".roles.revokeBootstrap")) {
            cfg.roles.revokeBootstrap = jsonBlob.readBool(".roles.revokeBootstrap");
        }

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
        if (jsonBlob.keyExists(".incentives.deployServiceFeeDistributor")) {
            cfg.incentives.deployServiceFeeDistributor = jsonBlob.readBool(".incentives.deployServiceFeeDistributor");
        }
        if (jsonBlob.keyExists(".incentives.deployStreamingPaymentManager")) {
            cfg.incentives.deployStreamingPaymentManager = jsonBlob.readBool(".incentives.deployStreamingPaymentManager");
        }
        if (jsonBlob.keyExists(".incentives.metrics")) cfg.incentives.metrics = jsonBlob.readAddress(".incentives.metrics");
        if (jsonBlob.keyExists(".incentives.rewardVaults")) {
            cfg.incentives.rewardVaults = jsonBlob.readAddress(".incentives.rewardVaults");
        }
        if (jsonBlob.keyExists(".incentives.inflationPool")) {
            cfg.incentives.inflationPool = jsonBlob.readAddress(".incentives.inflationPool");
        }
        if (jsonBlob.keyExists(".incentives.serviceFeeDistributor")) {
            cfg.incentives.serviceFeeDistributor = jsonBlob.readAddress(".incentives.serviceFeeDistributor");
        }
        if (jsonBlob.keyExists(".incentives.streamingPaymentManager")) {
            cfg.incentives.streamingPaymentManager = jsonBlob.readAddress(".incentives.streamingPaymentManager");
        }
        if (jsonBlob.keyExists(".incentives.tntToken")) cfg.incentives.tntToken = jsonBlob.readAddress(".incentives.tntToken");
        if (jsonBlob.keyExists(".incentives.priceOracle")) {
            cfg.incentives.priceOracle = jsonBlob.readAddress(".incentives.priceOracle");
        }
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
        if (jsonBlob.keyExists(".incentives.weights.restakersBps")) {
            cfg.incentives.weights.restakersBps = uint16(jsonBlob.readUint(".incentives.weights.restakersBps"));
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

        if (jsonBlob.keyExists(".migration.deploy")) cfg.migration.deploy = jsonBlob.readBool(".migration.deploy");
        if (jsonBlob.keyExists(".migration.emitArtifacts")) cfg.migration.emitArtifacts = jsonBlob.readBool(".migration.emitArtifacts");
        if (jsonBlob.keyExists(".migration.useMockVerifier")) {
            cfg.migration.useMockVerifier = jsonBlob.readBool(".migration.useMockVerifier");
        }
        if (jsonBlob.keyExists(".migration.artifactsPath")) cfg.migration.artifactsPath = jsonBlob.readString(".migration.artifactsPath");
        if (jsonBlob.keyExists(".migration.merklePath")) cfg.migration.merklePath = jsonBlob.readString(".migration.merklePath");
        if (jsonBlob.keyExists(".migration.evmClaimsPath")) cfg.migration.evmClaimsPath = jsonBlob.readString(".migration.evmClaimsPath");
        if (jsonBlob.keyExists(".migration.treasuryCarveoutPath")) {
            cfg.migration.treasuryCarveoutPath = jsonBlob.readString(".migration.treasuryCarveoutPath");
        }
        if (jsonBlob.keyExists(".migration.foundationCarveoutPath")) {
            cfg.migration.foundationCarveoutPath = jsonBlob.readString(".migration.foundationCarveoutPath");
        }
        if (jsonBlob.keyExists(".migration.notes")) cfg.migration.notes = jsonBlob.readString(".migration.notes");
        if (jsonBlob.keyExists(".migration.migrationOwner")) {
            cfg.migration.migrationOwner = jsonBlob.readAddress(".migration.migrationOwner");
        }
        if (jsonBlob.keyExists(".migration.sp1VerifierGateway")) {
            cfg.migration.sp1VerifierGateway = jsonBlob.readAddress(".migration.sp1VerifierGateway");
        }
        if (jsonBlob.keyExists(".migration.programVKey")) {
            cfg.migration.programVKey = _readBytes32Flexible(jsonBlob, ".migration.programVKey");
        }
        if (jsonBlob.keyExists(".migration.merkleRoot")) {
            cfg.migration.merkleRoot = jsonBlob.readBytes32(".migration.merkleRoot");
        }
        if (jsonBlob.keyExists(".migration.substrateAllocation")) {
            cfg.migration.substrateAllocation = _readUintFlexible(jsonBlob, ".migration.substrateAllocation");
        }
        if (jsonBlob.keyExists(".migration.evmAllocation")) {
            cfg.migration.evmAllocation = _readUintFlexible(jsonBlob, ".migration.evmAllocation");
        }
        if (jsonBlob.keyExists(".migration.treasuryRecipient")) {
            cfg.migration.treasuryRecipient = jsonBlob.readAddress(".migration.treasuryRecipient");
        }
        if (jsonBlob.keyExists(".migration.treasuryAmount")) {
            cfg.migration.treasuryAmount = _readUintFlexible(jsonBlob, ".migration.treasuryAmount");
        }
        if (jsonBlob.keyExists(".migration.foundationRecipient")) {
            cfg.migration.foundationRecipient = jsonBlob.readAddress(".migration.foundationRecipient");
        }
        if (jsonBlob.keyExists(".migration.foundationAmount")) {
            cfg.migration.foundationAmount = _readUintFlexible(jsonBlob, ".migration.foundationAmount");
        }
        if (jsonBlob.keyExists(".migration.claimDeadline")) {
            cfg.migration.claimDeadline = _readUintFlexible(jsonBlob, ".migration.claimDeadline");
        }
        if (jsonBlob.keyExists(".migration.unlockedBps")) {
            cfg.migration.unlockedBps = uint16(_readUintFlexible(jsonBlob, ".migration.unlockedBps"));
        }
        if (jsonBlob.keyExists(".migration.unlockTimestamp")) {
            cfg.migration.unlockTimestamp = uint64(_readUintFlexible(jsonBlob, ".migration.unlockTimestamp"));
        }

        if (jsonBlob.keyExists(".credits.deploy")) cfg.credits.deploy = jsonBlob.readBool(".credits.deploy");
        if (jsonBlob.keyExists(".credits.owner")) cfg.credits.owner = jsonBlob.readAddress(".credits.owner");
        if (jsonBlob.keyExists(".credits.credits")) cfg.credits.credits = jsonBlob.readAddress(".credits.credits");
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

    function _resolveCredits(
        CreditsConfig memory cfg,
        address admin,
        address timelock
    ) internal returns (address credits) {
        if (!cfg.deploy) {
            return cfg.credits;
        }
        address owner = cfg.owner;
        if (owner == address(0)) {
            owner = timelock != address(0) ? timelock : admin;
        }
        credits = address(new Credits(owner));
        console2.log("Deployed Credits:", credits);
        console2.log("Credits owner:", owner);
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

    function _deployServiceFeeDistributorProxy(
        address admin,
        address restaking,
        address tangle,
        address oracle
    ) internal returns (address proxy) {
        ServiceFeeDistributor impl = new ServiceFeeDistributor();
        proxy = address(
            new ERC1967Proxy(
                address(impl),
                abi.encodeCall(ServiceFeeDistributor.initialize, (admin, restaking, tangle, oracle))
            )
        );
        console2.log("Deployed ServiceFeeDistributor:", proxy);
    }

    function _deployStreamingPaymentManagerProxy(
        address admin,
        address tangle,
        address distributorAddr
    ) internal returns (address proxy) {
        StreamingPaymentManager impl = new StreamingPaymentManager();
        proxy = address(
            new ERC1967Proxy(
                address(impl),
                abi.encodeCall(StreamingPaymentManager.initialize, (admin, tangle, distributorAddr))
            )
        );
        console2.log("Deployed StreamingPaymentManager:", proxy);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // CONFIGURATION TASKS
    // ═══════════════════════════════════════════════════════════════════════════

    function _configureRestaking(address restakingAddr, RestakeAssetConfig[] memory assets) internal {
        if (restakingAddr == address(0)) return;

        IMultiAssetDelegation restaking = IMultiAssetDelegation(payable(restakingAddr));
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
        IMultiAssetDelegation restaking = IMultiAssetDelegation(payable(restakingAddr));
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
                || weights.developersBps != 0 || weights.restakersBps != 0
        ) {
            uint256 total = uint256(weights.stakingBps) + uint256(weights.operatorsBps) + uint256(weights.customersBps)
                + uint256(weights.developersBps) + uint256(weights.restakersBps);
            require(total == 10_000, "Inflation weights must sum to 10_000 bps");
            pool.setWeights(weights.stakingBps, weights.operatorsBps, weights.customersBps, weights.developersBps, weights.restakersBps);
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

    function _wireServiceFeeDistributor(
        address restakingAddr,
        address tangleAddr,
        address distributor,
        address streamingMgr,
        address oracle
    ) internal {
        if (distributor == address(0)) return;
        if (tangleAddr != address(0)) {
            Tangle(payable(tangleAddr)).setServiceFeeDistributor(distributor);
            if (oracle != address(0)) {
                Tangle(payable(tangleAddr)).setPriceOracle(oracle);
            }
        }
        if (restakingAddr != address(0)) {
            IMultiAssetDelegation(payable(restakingAddr)).setServiceFeeDistributor(distributor);
        }
        if (streamingMgr != address(0)) {
            ServiceFeeDistributor(payable(distributor)).setStreamingManager(streamingMgr);
            console2.log("Configured StreamingPaymentManager on ServiceFeeDistributor");
        }
    }

    function _applyGuards(address restakingAddr, address tangleAddr, GuardsConfig memory guards) internal {
        if (restakingAddr != address(0)) {
            IMultiAssetDelegation restaking = IMultiAssetDelegation(payable(restakingAddr));
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

    function _applyRoleHandoff(
        RolesConfig memory roles,
        address bootstrapAdmin,
        address timelock,
        address multisig,
        address tangleAddr,
        address restakingAddr,
        address tntToken,
        address metricsAddr,
        address rewardVaultsAddr,
        address inflationPoolAddr,
        address serviceFeeDistributorAddr,
        address streamingPaymentManagerAddr,
        address treasury
    )
        internal
    {
        bool requested = roles.timelock != address(0) || roles.multisig != address(0) || roles.revokeBootstrap;
        if (!requested) return;

        if (tangleAddr != address(0)) {
            Tangle tangle = Tangle(payable(tangleAddr));
            _grantRole(tangleAddr, bytes32(0), timelock);
            _grantRole(tangleAddr, tangle.ADMIN_ROLE(), timelock);
            _grantRole(tangleAddr, tangle.UPGRADER_ROLE(), timelock);

            _grantRole(tangleAddr, tangle.PAUSER_ROLE(), multisig);
            _grantRole(tangleAddr, tangle.SLASH_ADMIN_ROLE(), multisig);

            if (roles.revokeBootstrap && _shouldRevokeBootstrap(bootstrapAdmin, timelock, multisig)) {
                _revokeRole(tangleAddr, bytes32(0), bootstrapAdmin);
                _revokeRole(tangleAddr, tangle.ADMIN_ROLE(), bootstrapAdmin);
                _revokeRole(tangleAddr, tangle.UPGRADER_ROLE(), bootstrapAdmin);
                _revokeRole(tangleAddr, tangle.PAUSER_ROLE(), bootstrapAdmin);
                _revokeRole(tangleAddr, tangle.SLASH_ADMIN_ROLE(), bootstrapAdmin);
            }
        }

        if (restakingAddr != address(0)) {
            MultiAssetDelegation restaking = MultiAssetDelegation(payable(restakingAddr));
            _grantRole(restakingAddr, bytes32(0), timelock);
            _grantRole(restakingAddr, restaking.ADMIN_ROLE(), timelock);
            _grantRole(restakingAddr, restaking.ASSET_MANAGER_ROLE(), multisig);

            if (roles.revokeBootstrap && _shouldRevokeBootstrap(bootstrapAdmin, timelock, multisig)) {
                _revokeRole(restakingAddr, bytes32(0), bootstrapAdmin);
                _revokeRole(restakingAddr, restaking.ADMIN_ROLE(), bootstrapAdmin);
                _revokeRole(restakingAddr, restaking.ASSET_MANAGER_ROLE(), bootstrapAdmin);
            }
        }

        if (tntToken != address(0)) {
            _grantRole(tntToken, bytes32(0), timelock);
            _grantRole(tntToken, keccak256("MINTER_ROLE"), timelock);
            _grantRole(tntToken, keccak256("UPGRADER_ROLE"), timelock);

            if (roles.revokeBootstrap && _shouldRevokeBootstrap(bootstrapAdmin, timelock, multisig)) {
                _revokeRole(tntToken, bytes32(0), bootstrapAdmin);
                _revokeRole(tntToken, keccak256("MINTER_ROLE"), bootstrapAdmin);
                _revokeRole(tntToken, keccak256("UPGRADER_ROLE"), bootstrapAdmin);
            }
        }

        if (metricsAddr != address(0)) {
            _grantRole(metricsAddr, bytes32(0), timelock);
            _grantRole(metricsAddr, keccak256("UPGRADER_ROLE"), timelock);

            if (roles.revokeBootstrap && _shouldRevokeBootstrap(bootstrapAdmin, timelock, multisig)) {
                _revokeRole(metricsAddr, bytes32(0), bootstrapAdmin);
                _revokeRole(metricsAddr, keccak256("UPGRADER_ROLE"), bootstrapAdmin);
            }
        }

        if (rewardVaultsAddr != address(0)) {
            RewardVaults vaults = RewardVaults(rewardVaultsAddr);
            _grantRole(rewardVaultsAddr, bytes32(0), timelock);
            _grantRole(rewardVaultsAddr, vaults.ADMIN_ROLE(), timelock);
            _grantRole(rewardVaultsAddr, vaults.UPGRADER_ROLE(), timelock);

            if (roles.revokeBootstrap && _shouldRevokeBootstrap(bootstrapAdmin, timelock, multisig)) {
                _revokeRole(rewardVaultsAddr, bytes32(0), bootstrapAdmin);
                _revokeRole(rewardVaultsAddr, vaults.ADMIN_ROLE(), bootstrapAdmin);
                _revokeRole(rewardVaultsAddr, vaults.UPGRADER_ROLE(), bootstrapAdmin);
                _revokeRole(rewardVaultsAddr, vaults.REWARDS_MANAGER_ROLE(), bootstrapAdmin);
            }
        }

        if (inflationPoolAddr != address(0)) {
            InflationPool pool = InflationPool(payable(inflationPoolAddr));
            _grantRole(inflationPoolAddr, bytes32(0), timelock);
            _grantRole(inflationPoolAddr, pool.ADMIN_ROLE(), timelock);
            _grantRole(inflationPoolAddr, pool.UPGRADER_ROLE(), timelock);
            _grantRole(inflationPoolAddr, pool.FUNDER_ROLE(), treasury);

            if (roles.revokeBootstrap && _shouldRevokeBootstrap(bootstrapAdmin, timelock, multisig)) {
                _revokeRole(inflationPoolAddr, bytes32(0), bootstrapAdmin);
                _revokeRole(inflationPoolAddr, pool.ADMIN_ROLE(), bootstrapAdmin);
                _revokeRole(inflationPoolAddr, pool.UPGRADER_ROLE(), bootstrapAdmin);
                if (bootstrapAdmin != treasury) {
                    _revokeRole(inflationPoolAddr, pool.FUNDER_ROLE(), bootstrapAdmin);
                }
                _revokeRole(inflationPoolAddr, pool.DISTRIBUTOR_ROLE(), bootstrapAdmin);
            }
        }

        if (serviceFeeDistributorAddr != address(0)) {
            ServiceFeeDistributor distributor = ServiceFeeDistributor(payable(serviceFeeDistributorAddr));
            _grantRole(serviceFeeDistributorAddr, bytes32(0), timelock);
            _grantRole(serviceFeeDistributorAddr, distributor.ADMIN_ROLE(), timelock);
            _grantRole(serviceFeeDistributorAddr, distributor.UPGRADER_ROLE(), timelock);

            if (roles.revokeBootstrap && _shouldRevokeBootstrap(bootstrapAdmin, timelock, multisig)) {
                _revokeRole(serviceFeeDistributorAddr, bytes32(0), bootstrapAdmin);
                _revokeRole(serviceFeeDistributorAddr, distributor.ADMIN_ROLE(), bootstrapAdmin);
                _revokeRole(serviceFeeDistributorAddr, distributor.UPGRADER_ROLE(), bootstrapAdmin);
            }
        }

        if (streamingPaymentManagerAddr != address(0)) {
            StreamingPaymentManager streaming = StreamingPaymentManager(payable(streamingPaymentManagerAddr));
            _grantRole(streamingPaymentManagerAddr, bytes32(0), timelock);
            _grantRole(streamingPaymentManagerAddr, streaming.ADMIN_ROLE(), timelock);
            _grantRole(streamingPaymentManagerAddr, streaming.UPGRADER_ROLE(), timelock);

            if (roles.revokeBootstrap && _shouldRevokeBootstrap(bootstrapAdmin, timelock, multisig)) {
                _revokeRole(streamingPaymentManagerAddr, bytes32(0), bootstrapAdmin);
                _revokeRole(streamingPaymentManagerAddr, streaming.ADMIN_ROLE(), bootstrapAdmin);
                _revokeRole(streamingPaymentManagerAddr, streaming.UPGRADER_ROLE(), bootstrapAdmin);
            }
        }
    }

    function _shouldRevokeBootstrap(
        address bootstrapAdmin,
        address timelock,
        address multisig
    )
        internal
        pure
        returns (bool)
    {
        if (bootstrapAdmin == address(0)) return false;
        return bootstrapAdmin != timelock && bootstrapAdmin != multisig;
    }

    function _grantRole(address target, bytes32 role, address account) internal {
        if (target == address(0) || account == address(0)) return;
        IAccessControl(target).grantRole(role, account);
    }

    function _revokeRole(address target, bytes32 role, address account) internal {
        if (target == address(0) || account == address(0)) return;
        if (IAccessControl(target).hasRole(role, account)) {
            IAccessControl(target).revokeRole(role, account);
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // MIGRATION DEPLOY
    // ═══════════════════════════════════════════════════════════════════════════

    function _resolveMigrationConfig(MigrationConfig memory migration) internal view returns (MigrationConfig memory) {
        if (migration.merkleRoot == bytes32(0) || migration.substrateAllocation == 0) {
            if (bytes(migration.merklePath).length == 0) revert("Missing migration merklePath");
            string memory merkleJson = vm.readFile(migration.merklePath);
            bytes32 root = merkleJson.readBytes32(".root");
            uint256 totalValue = _readUintFlexible(merkleJson, ".totalValue");
            if (migration.merkleRoot == bytes32(0)) {
                migration.merkleRoot = root;
            } else if (migration.merkleRoot != root) {
                revert("Merkle root mismatch");
            }
            if (migration.substrateAllocation == 0) {
                migration.substrateAllocation = totalValue;
            } else if (migration.substrateAllocation != totalValue) {
                revert("Substrate allocation mismatch");
            }
        }

        if (migration.evmAllocation == 0 && bytes(migration.evmClaimsPath).length != 0) {
            string memory evmJson = vm.readFile(migration.evmClaimsPath);
            migration.evmAllocation = _readUintFlexible(evmJson, ".totalAmount");
        }

        if (migration.treasuryAmount == 0 && bytes(migration.treasuryCarveoutPath).length != 0) {
            string memory treasuryJson = vm.readFile(migration.treasuryCarveoutPath);
            migration.treasuryAmount = _readUintFlexible(treasuryJson, ".amount");
        }

        if (migration.foundationAmount == 0 && bytes(migration.foundationCarveoutPath).length != 0) {
            string memory foundationJson = vm.readFile(migration.foundationCarveoutPath);
            migration.foundationAmount = _readUintFlexible(foundationJson, ".amount");
        }

        if (migration.sp1VerifierGateway == address(0)) {
            migration.sp1VerifierGateway = SP1_VERIFIER_BASE;
        }

        return migration;
    }

    function _deployMigration(
        MigrationConfig memory migration,
        address tntToken,
        address deployer,
        address timelock,
        address treasury
    )
        internal
        returns (MigrationConfig memory)
    {
        if (tntToken == address(0)) revert("Missing TNT token for migration");
        if (migration.merkleRoot == bytes32(0)) revert("Missing migration merkle root");
        if (migration.programVKey == bytes32(0)) revert("Missing migration program vkey");
        if (migration.sp1VerifierGateway == address(0)) revert("Missing SP1 verifier gateway");
        if (migration.substrateAllocation == 0) revert("Missing substrate allocation");

        uint256 requiredBalance = migration.substrateAllocation + migration.treasuryAmount + migration.foundationAmount;
        IERC20 tnt = IERC20(tntToken);
        require(tnt.balanceOf(deployer) >= requiredBalance, "Insufficient TNT balance for migration");

        SP1ZKVerifier verifier = new SP1ZKVerifier(migration.sp1VerifierGateway, migration.programVKey, deployer);
        TangleMigration claim = new TangleMigration(tntToken, migration.merkleRoot, address(verifier), deployer);

        uint256 claimDeadline = migration.claimDeadline;
        if (claimDeadline == 0) {
            claimDeadline = block.timestamp + 365 days;
        }
        claim.setClaimDeadline(claimDeadline);

        if (migration.unlockedBps != 0 || migration.unlockTimestamp != 0) {
            uint16 unlockedBps = migration.unlockedBps == 0 ? claim.unlockedBps() : migration.unlockedBps;
            uint64 unlockTimestamp = migration.unlockTimestamp == 0 ? claim.unlockTimestamp() : migration.unlockTimestamp;
            claim.setLockConfig(address(claim.lockFactory()), unlockTimestamp, unlockedBps);
        }

        tnt.safeTransfer(address(claim), migration.substrateAllocation);

        if (migration.treasuryAmount > 0) {
            address treasuryRecipient = migration.treasuryRecipient == address(0) ? treasury : migration.treasuryRecipient;
            require(treasuryRecipient != address(0), "Missing treasury recipient");
            tnt.safeTransfer(treasuryRecipient, migration.treasuryAmount);
            migration.treasuryRecipient = treasuryRecipient;
        }

        if (migration.foundationAmount > 0) {
            address foundationRecipient = migration.foundationRecipient;
            require(foundationRecipient != address(0), "Missing foundation recipient");
            tnt.safeTransfer(foundationRecipient, migration.foundationAmount);
        }

        address finalOwner = migration.migrationOwner;
        if (finalOwner == address(0)) {
            finalOwner = timelock == address(0) ? deployer : timelock;
        }
        if (finalOwner != deployer) {
            claim.transferOwnership(finalOwner);
        }

        migration.migrationOwner = finalOwner;
        migration.tangleMigration = address(claim);
        migration.zkVerifier = address(verifier);
        migration.claimDeadline = claimDeadline;

        console2.log("Deployed TangleMigration:", address(claim));
        console2.log("Deployed SP1ZKVerifier:", address(verifier));
        console2.log("Migration merkle root:", _bytes32ToString(migration.merkleRoot));
        console2.log("Substrate allocation (TNT):", migration.substrateAllocation / 1e18);
        if (migration.evmAllocation > 0) {
            console2.log("EVM allocation held by deployer (TNT):", migration.evmAllocation / 1e18);
        }
        if (migration.treasuryAmount > 0) {
            console2.log("Treasury carveout (TNT):", migration.treasuryAmount / 1e18);
        }
        if (migration.foundationAmount > 0) {
            console2.log("Foundation carveout (TNT):", migration.foundationAmount / 1e18);
        }

        return migration;
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
            IMultiAssetDelegation restaking = IMultiAssetDelegation(payable(restakingAddr));
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
                "\"timelock\":\"",
                _addrToString(artifacts.timelock),
                "\",",
                "\"multisig\":\"",
                _addrToString(artifacts.multisig),
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
                "\"credits\":\"",
                _addrToString(artifacts.credits),
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
                "\"tangleMigration\":\"",
                _addrToString(migration.tangleMigration),
                "\",",
                "\"zkVerifier\":\"",
                _addrToString(migration.zkVerifier),
                "\",",
                "\"sp1VerifierGateway\":\"",
                _addrToString(migration.sp1VerifierGateway),
                "\",",
                "\"programVKey\":\"",
                _bytes32ToString(migration.programVKey),
                "\",",
                "\"merkleRoot\":\"",
                _bytes32ToString(migration.merkleRoot),
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
                ",",
                '"restakersBps":',
                uint256(weights.restakersBps).toString(),
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
                '"deploy":',
                _boolToString(migration.deploy),
                ",",
                '"emitArtifacts":',
                _boolToString(migration.emitArtifacts),
                ",",
                '"useMockVerifier":',
                _boolToString(migration.useMockVerifier),
                ",",
                '"artifactsPath":"',
                migration.artifactsPath,
                '",',
                '"merklePath":"',
                migration.merklePath,
                '",',
                '"evmClaimsPath":"',
                migration.evmClaimsPath,
                '",',
                '"treasuryCarveoutPath":"',
                migration.treasuryCarveoutPath,
                '",',
                '"foundationCarveoutPath":"',
                migration.foundationCarveoutPath,
                '",',
                '"notes":"',
                migration.notes,
                '",',
                '"migrationOwner":"',
                _addrToString(migration.migrationOwner),
                '",',
                '"sp1VerifierGateway":"',
                _addrToString(migration.sp1VerifierGateway),
                '",',
                '"programVKey":"',
                _bytes32ToString(migration.programVKey),
                '",',
                '"merkleRoot":"',
                _bytes32ToString(migration.merkleRoot),
                '",',
                '"substrateAllocation":"',
                migration.substrateAllocation.toString(),
                '",',
                '"evmAllocation":"',
                migration.evmAllocation.toString(),
                '",',
                '"treasuryRecipient":"',
                _addrToString(migration.treasuryRecipient),
                '",',
                '"treasuryAmount":"',
                migration.treasuryAmount.toString(),
                '",',
                '"foundationRecipient":"',
                _addrToString(migration.foundationRecipient),
                '",',
                '"foundationAmount":"',
                migration.foundationAmount.toString(),
                '",',
                '"claimDeadline":"',
                migration.claimDeadline.toString(),
                '",',
                '"unlockedBps":',
                uint256(migration.unlockedBps).toString(),
                ",",
                '"unlockTimestamp":"',
                uint256(migration.unlockTimestamp).toString(),
                '",',
                '"tangleMigration":"',
                _addrToString(migration.tangleMigration),
                '",',
                '"zkVerifier":"',
                _addrToString(migration.zkVerifier),
                '"',
                "}"
            )
        );
    }

    function _addrToString(address value) internal pure returns (string memory) {
        return Strings.toHexString(uint256(uint160(value)), 20);
    }

    function _bytes32ToString(bytes32 value) internal pure returns (string memory) {
        return Strings.toHexString(uint256(value), 32);
    }

    function _readUintFlexible(string memory json, string memory key) internal view returns (uint256) {
        try vm.parseJsonUint(json, key) returns (uint256 value) {
            return value;
        } catch {
            string memory raw = vm.parseJsonString(json, key);
            return vm.parseUint(raw);
        }
    }

    function _readBytes32Flexible(string memory json, string memory key) internal view returns (bytes32) {
        try vm.parseJsonBytes32(json, key) returns (bytes32 value) {
            return value;
        } catch {
            string memory raw = vm.parseJsonString(json, key);
            return _parseBytes32Flexible(raw);
        }
    }

    function _parseBytes32Flexible(string memory raw) internal pure returns (bytes32) {
        bytes memory rawBytes = bytes(raw);
        bytes memory decoded = _hexToBytes(rawBytes);
        if (decoded.length == 32) {
            return bytes32(decoded);
        }
        if (decoded.length == 66) {
            string memory inner = string(decoded);
            bytes memory innerBytes = bytes(inner);
            bytes memory innerDecoded = _hexToBytes(innerBytes);
            if (innerDecoded.length != 32) revert("Invalid vkey length");
            return bytes32(innerDecoded);
        }
        revert("Invalid vkey length");
    }

    function _hexToBytes(bytes memory data) internal pure returns (bytes memory) {
        if (
            data.length < 2
                || data[0] != bytes1(uint8(48))
                || (data[1] != bytes1(uint8(120)) && data[1] != bytes1(uint8(88)))
        ) {
            revert("Invalid hex prefix");
        }
        uint256 len = data.length - 2;
        if (len % 2 != 0) revert("Invalid hex length");
        bytes memory out = new bytes(len / 2);
        for (uint256 i = 0; i < len / 2; i++) {
            uint8 high = _fromHexChar(uint8(data[2 + i * 2]));
            uint8 low = _fromHexChar(uint8(data[3 + i * 2]));
            out[i] = bytes1((high << 4) | low);
        }
        return out;
    }

    function _fromHexChar(uint8 c) internal pure returns (uint8) {
        if (c >= 48 && c <= 57) return c - 48;
        if (c >= 65 && c <= 70) return c - 55;
        if (c >= 97 && c <= 102) return c - 87;
        revert("Invalid hex char");
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
