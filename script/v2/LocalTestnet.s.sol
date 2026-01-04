// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Script, console2 } from "forge-std/Script.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import { Tangle } from "../../src/v2/Tangle.sol";
import { ITangleFull } from "../../src/v2/interfaces/ITangle.sol";
import { IMultiAssetDelegation } from "../../src/v2/interfaces/IMultiAssetDelegation.sol";
import { MultiAssetDelegation } from "../../src/v2/restaking/MultiAssetDelegation.sol";
import { OperatorStatusRegistry } from "../../src/v2/restaking/OperatorStatusRegistry.sol";
import { TangleToken } from "../../src/v2/governance/TangleToken.sol";
import { MasterBlueprintServiceManager } from "../../src/v2/MasterBlueprintServiceManager.sol";
import { MBSMRegistry } from "../../src/v2/MBSMRegistry.sol";
import { Types } from "../../src/v2/libraries/Types.sol";
import { BlueprintDefinitionHelper } from "../../test/support/BlueprintDefinitionHelper.sol";
import { MockToken } from "../../test/v2/mocks/MockToken.sol";
import { ValidatorPodManager } from "../../src/v2/beacon/ValidatorPodManager.sol";
import { MockBeaconOracle } from "../../src/v2/beacon/BeaconRootReceiver.sol";
import { LiquidDelegationFactory } from "../../src/v2/restaking/LiquidDelegationFactory.sol";
import { LiquidDelegationVault } from "../../src/v2/restaking/LiquidDelegationVault.sol";
import { TangleMetrics } from "../../src/v2/rewards/TangleMetrics.sol";
import { RewardVaults } from "../../src/v2/rewards/RewardVaults.sol";
import { InflationPool } from "../../src/v2/rewards/InflationPool.sol";
import { ServiceFeeDistributor } from "../../src/v2/rewards/ServiceFeeDistributor.sol";
import { StreamingPaymentManager } from "../../src/v2/rewards/StreamingPaymentManager.sol";
import { Credits } from "../../packages/credits/src/Credits.sol";
import { TangleBlueprintsFacet } from "../../src/v2/facets/tangle/TangleBlueprintsFacet.sol";
import { TangleBlueprintsManagementFacet } from "../../src/v2/facets/tangle/TangleBlueprintsManagementFacet.sol";
import { TangleOperatorsFacet } from "../../src/v2/facets/tangle/TangleOperatorsFacet.sol";
import { TangleServicesRequestsFacet } from "../../src/v2/facets/tangle/TangleServicesRequestsFacet.sol";
import { TangleServicesFacet } from "../../src/v2/facets/tangle/TangleServicesFacet.sol";
import { TangleServicesLifecycleFacet } from "../../src/v2/facets/tangle/TangleServicesLifecycleFacet.sol";
import { TangleJobsFacet } from "../../src/v2/facets/tangle/TangleJobsFacet.sol";
import { TangleJobsAggregationFacet } from "../../src/v2/facets/tangle/TangleJobsAggregationFacet.sol";
import { TangleQuotesFacet } from "../../src/v2/facets/tangle/TangleQuotesFacet.sol";
import { TangleQuotesExtensionFacet } from "../../src/v2/facets/tangle/TangleQuotesExtensionFacet.sol";
import { TanglePaymentsFacet } from "../../src/v2/facets/tangle/TanglePaymentsFacet.sol";
import { TangleSlashingFacet } from "../../src/v2/facets/tangle/TangleSlashingFacet.sol";
import { RestakingOperatorsFacet } from "../../src/v2/facets/restaking/RestakingOperatorsFacet.sol";
import { RestakingDepositsFacet } from "../../src/v2/facets/restaking/RestakingDepositsFacet.sol";
import { RestakingDelegationsFacet } from "../../src/v2/facets/restaking/RestakingDelegationsFacet.sol";
import { RestakingRewardsFacet } from "../../src/v2/facets/restaking/RestakingRewardsFacet.sol";
import { RestakingSlashingFacet } from "../../src/v2/facets/restaking/RestakingSlashingFacet.sol";
import { RestakingAssetsFacet } from "../../src/v2/facets/restaking/RestakingAssetsFacet.sol";
import { RestakingViewsFacet } from "../../src/v2/facets/restaking/RestakingViewsFacet.sol";
import { RestakingAdminFacet } from "../../src/v2/facets/restaking/RestakingAdminFacet.sol";

/// @title LocalTestnetSetup
/// @notice Deploy and setup a complete local testnet environment for integration testing
/// @dev Run with: forge script script/v2/LocalTestnet.s.sol:LocalTestnetSetup --rpc-url http://localhost:8545
/// --broadcast
contract LocalTestnetSetup is Script, BlueprintDefinitionHelper {
    // Anvil default accounts
    uint256 constant DEPLOYER_KEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
    uint256 constant OPERATOR1_KEY = 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d;
    uint256 constant OPERATOR2_KEY = 0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a;
    uint256 constant DELEGATOR_KEY = 0x7c852118294e51e653712a81e05800f419141751be58f605c371e15141b007a6;

    address deployer;
    address operator1;
    address operator2;
    address delegator;

    bool internal useBroadcastKeys;

    // Deployed contracts
    address public tangleProxy;
    address public restakingProxy;
    address public statusRegistry;
    TangleToken public tntToken;

    // Incentives
    address public metrics;
    address public rewardVaults;
    address public inflationPool;
    address public serviceFeeDistributor;
    address public streamingPaymentManager;
    address public credits;
    address public priceOracle;

    // Mock ERC20 tokens for restaking
    MockToken public usdc;
    MockToken public usdt;
    MockToken public dai;
    MockToken public weth;
    MockToken public stETH;
    MockToken public wstETH;
    MockToken public eigen;

    // Beacon chain / L1 pod manager contracts
    MockBeaconOracle public beaconOracle;
    ValidatorPodManager public podManager;

    // Liquid delegation
    LiquidDelegationFactory public liquidFactory;
    address payable public liquidVaultETH;
    address payable public liquidVaultUSDC;

    // Test blueprint/service
    uint64 public blueprintId;
    uint64 public requestId;
    uint64 public serviceId;

    function run() external {
        _executeSetup(true);
    }

    /// @notice Dry run setup for CI/tests (no broadcast cheatcodes)
    function dryRun() external returns (uint64) {
        return _executeSetup(false);
    }

    function _executeSetup(bool broadcast) internal returns (uint64) {
        useBroadcastKeys = broadcast;

        // Derive addresses
        deployer = vm.addr(DEPLOYER_KEY);
        operator1 = vm.addr(OPERATOR1_KEY);
        operator2 = vm.addr(OPERATOR2_KEY);
        delegator = vm.addr(DELEGATOR_KEY);

        // Dry runs don't have funded accounts by default.
        if (!useBroadcastKeys) {
            vm.deal(deployer, 10_000 ether);
            vm.deal(operator1, 10_000 ether);
            vm.deal(operator2, 10_000 ether);
            vm.deal(delegator, 10_000 ether);
        }

        console2.log("=== Accounts ===");
        console2.log("Deployer:", deployer);
        console2.log("Operator1:", operator1);
        console2.log("Operator2:", operator2);
        console2.log("Delegator:", delegator);

        _deployContracts();
        _deployIncentives();
        _deployMockTokens();
        _configureRewardVaults();
        _deployPodManager();
        _registerOperatorsRestaking();
        _deployLiquidDelegation();
        _registerPodManagerOperators();
        _createBlueprint();
        _operatorsRegisterForBlueprint();
        _delegatorStake();
        _delegatorStakeERC20();
        _seedRewardVaults();
        _createAndApproveService();

        console2.log("\n=== Local Testnet Ready ===");
        console2.log("Tangle:", tangleProxy);
        console2.log("MultiAssetDelegation:", restakingProxy);
        console2.log("OperatorStatusRegistry:", statusRegistry);
        console2.log("Blueprint ID:", blueprintId);
        console2.log("Service ID:", serviceId);
        console2.log("\n=== Mock Tokens ===");
        console2.log("USDC:", address(usdc));
        console2.log("USDT:", address(usdt));
        console2.log("DAI:", address(dai));
        console2.log("WETH:", address(weth));
        console2.log("stETH:", address(stETH));
        console2.log("wstETH:", address(wstETH));
        console2.log("EIGEN:", address(eigen));
        console2.log("\n=== Beacon / Pod Manager ===");
        console2.log("MockBeaconOracle:", address(beaconOracle));
        console2.log("ValidatorPodManager:", address(podManager));
        console2.log("\n=== Incentives ===");
        console2.log("TangleMetrics:", metrics);
        console2.log("RewardVaults:", rewardVaults);
        console2.log("InflationPool:", inflationPool);
        console2.log("\n=== Liquid Delegation ===");
        console2.log("LiquidDelegationFactory:", address(liquidFactory));
        console2.log("LiquidVault WETH (operator1):", liquidVaultETH);
        console2.log("LiquidVault USDC (operator2):", liquidVaultUSDC);
        console2.log("\nOperators registered and staked");
        console2.log("Delegator has delegated to both operators");
        console2.log("Service is active and ready for jobs");

        return serviceId;
    }

    function _deployContracts() internal {
        console2.log("\n=== Deploying Contracts ===");
        if (useBroadcastKeys) {
            vm.startBroadcast(DEPLOYER_KEY);
        } else {
            vm.startPrank(deployer);
        }

        // Deploy MultiAssetDelegation
        MultiAssetDelegation restakingImpl = new MultiAssetDelegation();
        bytes memory restakingInit = abi.encodeCall(
            MultiAssetDelegation.initialize,
            (deployer, 1 ether, 0.1 ether, 1000) // minOpStake, minDelegation, commissionBps
        );
        restakingProxy = address(new ERC1967Proxy(address(restakingImpl), restakingInit));
        console2.log("MultiAssetDelegation:", restakingProxy);

        // Deploy Tangle
        Tangle tangleImpl = new Tangle();
        bytes memory tangleInit = abi.encodeCall(Tangle.initialize, (deployer, restakingProxy, payable(deployer)));
        tangleProxy = address(new ERC1967Proxy(address(tangleImpl), tangleInit));
        console2.log("Tangle:", tangleProxy);

        _registerRestakingFacets(restakingProxy);
        _registerTangleFacets(tangleProxy);

        // Deploy OperatorStatusRegistry
        statusRegistry = address(new OperatorStatusRegistry(tangleProxy, deployer));
        console2.log("OperatorStatusRegistry:", statusRegistry);

        bool deployedNewTNT;
        address configuredTNT = _envAddressOrZero("TNT_TOKEN");
        if (configuredTNT == address(0)) {
            configuredTNT = _envAddressOrZero("LOCAL_TNT_TOKEN");
        }

        if (configuredTNT == address(0)) {
            TangleToken tokenImpl = new TangleToken();
            ERC1967Proxy tokenProxy = new ERC1967Proxy(
                address(tokenImpl), abi.encodeCall(TangleToken.initialize, (deployer, 1_000_000 ether))
            );
            tntToken = TangleToken(address(tokenProxy));
            deployedNewTNT = true;
            console2.log("TangleToken:", address(tntToken));
        } else {
            tntToken = TangleToken(configuredTNT);
            console2.log("Using existing TangleToken:", address(tntToken));
        }

        _distributeTntToken(deployer, deployedNewTNT);

        // Configure cross-references
        IMultiAssetDelegation restaking = IMultiAssetDelegation(payable(restakingProxy));
        restaking.addSlasher(tangleProxy);

        Tangle tangle = Tangle(payable(tangleProxy));
        tangle.setOperatorStatusRegistry(statusRegistry);
        tangle.setTntToken(address(tntToken));
        uint256 minExposure = _envUintOrZero("DEFAULT_TNT_MIN_EXPOSURE_BPS");
        if (minExposure > 0) {
            require(minExposure <= 10_000, "DEFAULT_TNT_MIN_EXPOSURE_BPS too high");
            tangle.setDefaultTntMinExposureBps(uint16(minExposure));
        }

        // Deploy master blueprint service manager + registry
        MasterBlueprintServiceManager masterManager = new MasterBlueprintServiceManager(deployer, tangleProxy);
        MBSMRegistry registryImpl = new MBSMRegistry();
        ERC1967Proxy registryProxy =
            new ERC1967Proxy(address(registryImpl), abi.encodeCall(MBSMRegistry.initialize, (deployer)));
        MBSMRegistry registry = MBSMRegistry(address(registryProxy));
        registry.grantRole(registry.MANAGER_ROLE(), tangleProxy);
        registry.addVersion(address(masterManager));
        tangle.setMBSMRegistry(address(registry));

        // Deploy Credits (standalone)
        credits = address(new Credits(deployer));
        console2.log("Credits:", credits);

        if (useBroadcastKeys) {
            vm.stopBroadcast();
        } else {
            vm.stopPrank();
        }
    }

    function _deployIncentives() internal {
        console2.log("\n=== Deploying Incentives (Metrics / RewardVaults / InflationPool) ===");
        if (useBroadcastKeys) {
            vm.startBroadcast(DEPLOYER_KEY);
        } else {
            vm.startPrank(deployer);
        }

        // Deploy TangleMetrics
        TangleMetrics metricsImpl = new TangleMetrics();
        metrics = address(new ERC1967Proxy(address(metricsImpl), abi.encodeCall(TangleMetrics.initialize, (deployer))));
        console2.log("TangleMetrics:", metrics);

        // Deploy RewardVaults
        RewardVaults vaultsImpl = new RewardVaults();
        rewardVaults = address(
            new ERC1967Proxy(
                address(vaultsImpl),
                abi.encodeCall(RewardVaults.initialize, (deployer, address(tntToken), uint16(1500)))
            )
        );
        console2.log("RewardVaults:", rewardVaults);

        // Deploy InflationPool (short epoch length for local testing)
        InflationPool poolImpl = new InflationPool();
        inflationPool = address(
            new ERC1967Proxy(
                address(poolImpl),
                abi.encodeCall(InflationPool.initialize, (deployer, address(tntToken), metrics, rewardVaults, 3600))
            )
        );
        console2.log("InflationPool:", inflationPool);

        // Optional price oracle for USD-normalized scoring (0 disables USD weighting)
        priceOracle = _envAddressOrZero("PRICE_ORACLE");
        console2.log("PriceOracle:", priceOracle);

        // Deploy ServiceFeeDistributor (for multi-token restaker fee payouts)
        ServiceFeeDistributor distImpl = new ServiceFeeDistributor();
        serviceFeeDistributor = address(
            new ERC1967Proxy(
                address(distImpl),
                abi.encodeCall(ServiceFeeDistributor.initialize, (deployer, restakingProxy, tangleProxy, priceOracle))
            )
        );
        console2.log("ServiceFeeDistributor:", serviceFeeDistributor);

        // Deploy StreamingPaymentManager (handles streaming payments over service TTL)
        StreamingPaymentManager streamingImpl = new StreamingPaymentManager();
        streamingPaymentManager = address(
            new ERC1967Proxy(
                address(streamingImpl),
                abi.encodeCall(StreamingPaymentManager.initialize, (deployer, tangleProxy, serviceFeeDistributor))
            )
        );
        console2.log("StreamingPaymentManager:", streamingPaymentManager);

        // Configure ServiceFeeDistributor to use StreamingPaymentManager
        ServiceFeeDistributor(payable(serviceFeeDistributor)).setStreamingManager(streamingPaymentManager);

        // Wire metrics recorder into core contracts
        Tangle(payable(tangleProxy)).setMetricsRecorder(metrics);
        OperatorStatusRegistry(statusRegistry).setMetricsRecorder(metrics);

        // Grant recorder role to protocol contracts
        TangleMetrics(metrics).grantRecorderRole(tangleProxy);
        TangleMetrics(metrics).grantRecorderRole(restakingProxy);
        TangleMetrics(metrics).grantRecorderRole(statusRegistry);

        // Wire RewardVaults into restaking + grant manager roles
        IMultiAssetDelegation restaking = IMultiAssetDelegation(payable(restakingProxy));
        restaking.setRewardsManager(rewardVaults);
        RewardVaults vaults = RewardVaults(rewardVaults);
        bytes32 rmRole = vaults.REWARDS_MANAGER_ROLE();
        if (!vaults.hasRole(rmRole, restakingProxy)) vaults.grantRole(rmRole, restakingProxy);
        if (!vaults.hasRole(rmRole, inflationPool)) vaults.grantRole(rmRole, inflationPool);

        // Wire fee distributor into Tangle + restaking
        Tangle(payable(tangleProxy)).setServiceFeeDistributor(serviceFeeDistributor);
        if (priceOracle != address(0)) {
            Tangle(payable(tangleProxy)).setPriceOracle(priceOracle);
        }
        restaking.setServiceFeeDistributor(serviceFeeDistributor);

        // Wire RewardVaults into Tangle for TNT-specific incentives
        Tangle(payable(tangleProxy)).setRewardVaults(rewardVaults);
        uint256 feeBps = _envUintOrZero("TNT_RESTAKER_FEE_BPS");
        if (feeBps > 0) {
            require(feeBps <= 10_000, "TNT_RESTAKER_FEE_BPS too high");
            Tangle(payable(tangleProxy)).setTntRestakerFeeBps(uint16(feeBps));
        }
        uint256 discountBps = _envUintOrZero("TNT_PAYMENT_DISCOUNT_BPS");
        if (discountBps > 0) {
            require(discountBps <= 10_000, "TNT_PAYMENT_DISCOUNT_BPS too high");
            Tangle(payable(tangleProxy)).setTntPaymentDiscountBps(uint16(discountBps));
        }

        if (useBroadcastKeys) {
            vm.stopBroadcast();
        } else {
            vm.stopPrank();
        }
    }

    function _configureRewardVaults() internal {
        console2.log("\n=== Configuring RewardVaults ===");
        if (useBroadcastKeys) {
            vm.startBroadcast(DEPLOYER_KEY);
        } else {
            vm.startPrank(deployer);
        }

        RewardVaults vaults = RewardVaults(rewardVaults);

        // Use conservative caps to avoid overflow in RewardVaults math.
        uint256 depositCap = 1_000_000 ether;
        uint256 incentiveCap = 1_000_000 ether;
        uint256 apyBps = 500; // 5% (unused for seeded epoch rewards, but kept sane)
        uint256 boostMultiplierBps = 0;

        // Native (address(0)) + all configured restaking assets
        vaults.createVault(address(0), apyBps, depositCap, incentiveCap, boostMultiplierBps);
        vaults.createVault(address(tntToken), apyBps, depositCap, incentiveCap, boostMultiplierBps);
        vaults.createVault(address(usdc), apyBps, depositCap, incentiveCap, boostMultiplierBps);
        vaults.createVault(address(usdt), apyBps, depositCap, incentiveCap, boostMultiplierBps);
        vaults.createVault(address(dai), apyBps, depositCap, incentiveCap, boostMultiplierBps);
        vaults.createVault(address(weth), apyBps, depositCap, incentiveCap, boostMultiplierBps);
        vaults.createVault(address(stETH), apyBps, depositCap, incentiveCap, boostMultiplierBps);
        vaults.createVault(address(wstETH), apyBps, depositCap, incentiveCap, boostMultiplierBps);
        vaults.createVault(address(eigen), apyBps, depositCap, incentiveCap, boostMultiplierBps);

        console2.log("RewardVaults configured for: native, TNT, USDC, USDT, DAI, WETH, stETH, wstETH, EIGEN");

        if (useBroadcastKeys) {
            vm.stopBroadcast();
        } else {
            vm.stopPrank();
        }
    }

    function _seedRewardVaults() internal {
        console2.log("\n=== Seeding RewardVaults (local-only rewards) ===");
        if (useBroadcastKeys) {
            vm.startBroadcast(DEPLOYER_KEY);
        } else {
            vm.startPrank(deployer);
        }

        RewardVaults vaults = RewardVaults(rewardVaults);

        // Ensure vault has TNT balance to cover claims.
        tntToken.transfer(rewardVaults, 100_000 ether);

        // Seed some rewards so the dApp can test pending/claim flows immediately.
        vaults.distributeRewards(address(0), operator1, 100 ether);
        vaults.distributeRewards(address(0), operator2, 100 ether);
        vaults.distributeRewards(address(usdc), operator1, 50 ether);
        vaults.distributeRewards(address(usdt), operator2, 50 ether);

        if (useBroadcastKeys) {
            vm.stopBroadcast();
        } else {
            vm.stopPrank();
        }
    }

    function _deployMockTokens() internal {
        console2.log("\n=== Deploying Mock Tokens ===");
        if (useBroadcastKeys) {
            vm.startBroadcast(DEPLOYER_KEY);
        } else {
            vm.startPrank(deployer);
        }

        IMultiAssetDelegation restaking = IMultiAssetDelegation(payable(restakingProxy));

        // Deploy stablecoins (6 decimals for USDC/USDT)
        usdc = new MockToken("USD Coin", "USDC", 6);
        usdt = new MockToken("Tether USD", "USDT", 6);
        dai = new MockToken("Dai Stablecoin", "DAI", 18);
        console2.log("USDC:", address(usdc));
        console2.log("USDT:", address(usdt));
        console2.log("DAI:", address(dai));

        // Deploy ETH-related tokens (18 decimals)
        weth = new MockToken("Wrapped Ether", "WETH", 18);
        stETH = new MockToken("Lido Staked ETH", "stETH", 18);
        wstETH = new MockToken("Wrapped stETH", "wstETH", 18);
        console2.log("WETH:", address(weth));
        console2.log("stETH:", address(stETH));
        console2.log("wstETH:", address(wstETH));

        // Deploy EIGEN token
        eigen = new MockToken("Eigenlayer", "EIGEN", 18);
        console2.log("EIGEN:", address(eigen));

        // Enable all tokens as restaking assets
        // Parameters: token, minOperatorStake, minDelegation, depositCap, rewardMultiplierBps
        restaking.enableAsset(address(usdc), 0, 0, 0, 10_000);
        restaking.enableAsset(address(usdt), 0, 0, 0, 10_000);
        restaking.enableAsset(address(dai), 0, 0, 0, 10_000);
        restaking.enableAsset(address(weth), 0, 0, 0, 12_000); // 1.2x multiplier for WETH
        restaking.enableAsset(address(stETH), 0, 0, 0, 15_000); // 1.5x multiplier for stETH
        restaking.enableAsset(address(wstETH), 0, 0, 0, 15_000); // 1.5x multiplier for wstETH
        restaking.enableAsset(address(eigen), 0, 0, 0, 20_000); // 2x multiplier for EIGEN
        restaking.enableAsset(address(tntToken), 0, 0, 0, 10_000); // TNT native token
        console2.log("All tokens enabled as restaking assets");

        // Mint tokens to test accounts (use large amounts for testing)
        address[] memory accounts = new address[](10);
        accounts[0] = deployer;
        accounts[1] = operator1;
        accounts[2] = operator2;
        accounts[3] = delegator;
        accounts[4] = vm.addr(0x47e179ec197488593b187f80a00eb0da91f1b9d0b13f8733639f19c30a34926a); // Account 5
        accounts[5] = vm.addr(0x8b3a350cf5c34c9194ca85829a2df0ec3153be0318b5e2d3348e872092edffba); // Account 6
        accounts[6] = vm.addr(0x92db14e403b83dfe3df233f83dfa3a0d7096f21ca9b0d6d6b8d88b2b4ec1564e); // Account 7
        accounts[7] = vm.addr(0x4bbbf85ce3377467afe5d46f804f221813b2bb87f24d81f60f1fcdbf7cbf4356); // Account 8
        accounts[8] = vm.addr(0xdbda1821b80551c9d65939329250298aa3472ba22feea921c0cf5d620ea67b97); // Account 9
        accounts[9] = vm.addr(0x2a871d0798f97d79848a013d4936a73bf4cc922c825d33c1cf7073dff6d409c6); // Account 10

        for (uint256 i = 0; i < accounts.length; i++) {
            usdc.mint(accounts[i], 1_000_000 * 10 ** 6); // 1M USDC
            usdt.mint(accounts[i], 1_000_000 * 10 ** 6); // 1M USDT
            dai.mint(accounts[i], 1_000_000 ether); // 1M DAI
            weth.mint(accounts[i], 1000 ether); // 1000 WETH
            stETH.mint(accounts[i], 1000 ether); // 1000 stETH
            wstETH.mint(accounts[i], 1000 ether); // 1000 wstETH
            eigen.mint(accounts[i], 10_000 ether); // 10000 EIGEN
        }
        console2.log("\n=== Funded Development Accounts ===");
        console2.log("All accounts have: 1M USDC, 1M USDT, 1M DAI, 1000 WETH/stETH/wstETH, 10000 EIGEN");
        for (uint256 i = 0; i < accounts.length; i++) {
            console2.log("Account", i, ":", accounts[i]);
        }
        console2.log("Tokens minted to all 10 test accounts");

        if (useBroadcastKeys) {
            vm.stopBroadcast();
        } else {
            vm.stopPrank();
        }
    }

    function _registerOperatorsRestaking() internal {
        console2.log("\n=== Registering Operators in Restaking ===");
        IMultiAssetDelegation restaking = IMultiAssetDelegation(payable(restakingProxy));

        // Operator 1 registers with 10 ETH stake
        if (useBroadcastKeys) {
            vm.startBroadcast(OPERATOR1_KEY);
        } else {
            vm.startPrank(operator1);
        }
        restaking.registerOperator{ value: 10 ether }();
        console2.log("Operator1 registered with 10 ETH stake");
        if (useBroadcastKeys) {
            vm.stopBroadcast();
        } else {
            vm.stopPrank();
        }

        // Operator 2 registers with 10 ETH stake
        if (useBroadcastKeys) {
            vm.startBroadcast(OPERATOR2_KEY);
        } else {
            vm.startPrank(operator2);
        }
        restaking.registerOperator{ value: 10 ether }();
        console2.log("Operator2 registered with 10 ETH stake");
        if (useBroadcastKeys) {
            vm.stopBroadcast();
        } else {
            vm.stopPrank();
        }
    }

    function _createBlueprint() internal {
        console2.log("\n=== Creating Blueprint ===");
        if (useBroadcastKeys) {
            vm.startBroadcast(DEPLOYER_KEY);
        } else {
            vm.startPrank(deployer);
        }

        ITangleFull tangle = ITangleFull(payable(tangleProxy));

        Types.BlueprintDefinition memory def = _blueprintDefinition("ipfs://QmTestBlueprint", address(0));
        def.config.membership = Types.MembershipModel.Dynamic;
        def.config.minOperators = 1;
        def.config.maxOperators = 0; // unlimited to allow future joins
        blueprintId = tangle.createBlueprint(def);
        console2.log("Blueprint created:", blueprintId);
        console2.log("Blueprint configured for dynamic membership (CLI join target)");

        if (useBroadcastKeys) {
            vm.stopBroadcast();
        } else {
            vm.stopPrank();
        }
    }

    function _operatorsRegisterForBlueprint() internal {
        console2.log("\n=== Operators Registering for Blueprint ===");
        ITangleFull tangle = ITangleFull(payable(tangleProxy));

        bytes memory operator1Key =
            hex"040102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f40";
        bytes memory operator2Key =
            hex"044142434445464748494a4b4c4d4e4f505152535455565758595a5b5c5d5e5f606162636465666768696a6b6c6d6e6f707172737475767778797a7b7c7d7e7f80";

        // Operator 1 registers for blueprint
        if (useBroadcastKeys) {
            vm.startBroadcast(OPERATOR1_KEY);
        } else {
            vm.startPrank(operator1);
        }
        tangle.registerOperator(blueprintId, operator1Key, "http://operator1.local:8545");
        console2.log("Operator1 registered for blueprint");
        if (useBroadcastKeys) {
            vm.stopBroadcast();
        } else {
            vm.stopPrank();
        }

        // Operator 2 registers for blueprint
        if (useBroadcastKeys) {
            vm.startBroadcast(OPERATOR2_KEY);
        } else {
            vm.startPrank(operator2);
        }
        tangle.registerOperator(blueprintId, operator2Key, "http://operator2.local:8545");
        console2.log("Operator2 registered for blueprint");
        if (useBroadcastKeys) {
            vm.stopBroadcast();
        } else {
            vm.stopPrank();
        }
    }

    function _delegatorStake() internal {
        console2.log("\n=== Delegator Staking ===");
        IMultiAssetDelegation restaking = IMultiAssetDelegation(payable(restakingProxy));

        if (useBroadcastKeys) {
            vm.startBroadcast(DELEGATOR_KEY);
        } else {
            vm.startPrank(delegator);
        }

        // Deposit and delegate 5 ETH to operator1
        restaking.depositAndDelegate{ value: 5 ether }(operator1);
        console2.log("Delegated 5 ETH to Operator1");

        // Deposit and delegate 5 ETH to operator2
        restaking.depositAndDelegate{ value: 5 ether }(operator2);
        console2.log("Delegated 5 ETH to Operator2");

        if (useBroadcastKeys) {
            vm.stopBroadcast();
        } else {
            vm.stopPrank();
        }
    }

    function _delegatorStakeERC20() internal {
        console2.log("\n=== Delegator ERC20 Staking ===");
        IMultiAssetDelegation restaking = IMultiAssetDelegation(payable(restakingProxy));
        uint64[] memory emptyBlueprints = new uint64[](0);

        if (useBroadcastKeys) {
            vm.startBroadcast(DELEGATOR_KEY);
        } else {
            vm.startPrank(delegator);
        }

        // Deposit and delegate USDC
        usdc.approve(restakingProxy, type(uint256).max);
        restaking.depositERC20(address(usdc), 10_000 * 10 ** 6); // 10k USDC
        restaking.delegateWithOptions(
            operator1, address(usdc), 5000 * 10 ** 6, Types.BlueprintSelectionMode.All, emptyBlueprints
        );
        console2.log("Deposited 10k USDC, delegated 5k to Operator1");

        // Deposit and delegate TNT to enable TNT restaker incentive testing.
        uint256 tntBalance = tntToken.balanceOf(delegator);
        if (tntBalance >= 2000 ether) {
            tntToken.approve(restakingProxy, type(uint256).max);
            restaking.depositERC20(address(tntToken), 2000 ether);
            restaking.delegateWithOptions(
                operator1, address(tntToken), 1000 ether, Types.BlueprintSelectionMode.All, emptyBlueprints
            );
            restaking.delegateWithOptions(
                operator2, address(tntToken), 1000 ether, Types.BlueprintSelectionMode.All, emptyBlueprints
            );
            console2.log("Deposited 2000 TNT, delegated 1000 to each operator");
        } else {
            console2.log("Skipping TNT delegation - insufficient TNT balance for delegator:", tntBalance);
        }

        // Deposit and delegate USDT
        usdt.approve(restakingProxy, type(uint256).max);
        restaking.depositERC20(address(usdt), 10_000 * 10 ** 6); // 10k USDT
        restaking.delegateWithOptions(
            operator2, address(usdt), 5000 * 10 ** 6, Types.BlueprintSelectionMode.All, emptyBlueprints
        );
        console2.log("Deposited 10k USDT, delegated 5k to Operator2");

        // Deposit and delegate DAI
        dai.approve(restakingProxy, type(uint256).max);
        restaking.depositERC20(address(dai), 10_000 ether); // 10k DAI
        restaking.delegateWithOptions(
            operator1, address(dai), 5000 ether, Types.BlueprintSelectionMode.All, emptyBlueprints
        );
        console2.log("Deposited 10k DAI, delegated 5k to Operator1");

        // Deposit and delegate WETH
        weth.approve(restakingProxy, type(uint256).max);
        restaking.depositERC20(address(weth), 10 ether); // 10 WETH
        restaking.delegateWithOptions(
            operator2, address(weth), 5 ether, Types.BlueprintSelectionMode.All, emptyBlueprints
        );
        console2.log("Deposited 10 WETH, delegated 5 to Operator2");

        // Deposit and delegate stETH
        stETH.approve(restakingProxy, type(uint256).max);
        restaking.depositERC20(address(stETH), 10 ether); // 10 stETH
        restaking.delegateWithOptions(
            operator1, address(stETH), 5 ether, Types.BlueprintSelectionMode.All, emptyBlueprints
        );
        console2.log("Deposited 10 stETH, delegated 5 to Operator1");

        // Deposit and delegate wstETH
        wstETH.approve(restakingProxy, type(uint256).max);
        restaking.depositERC20(address(wstETH), 10 ether); // 10 wstETH
        restaking.delegateWithOptions(
            operator2, address(wstETH), 5 ether, Types.BlueprintSelectionMode.All, emptyBlueprints
        );
        console2.log("Deposited 10 wstETH, delegated 5 to Operator2");

        // Deposit and delegate EIGEN
        eigen.approve(restakingProxy, type(uint256).max);
        restaking.depositERC20(address(eigen), 100 ether); // 100 EIGEN
        restaking.delegateWithOptions(
            operator1, address(eigen), 50 ether, Types.BlueprintSelectionMode.All, emptyBlueprints
        );
        console2.log("Deposited 100 EIGEN, delegated 50 to Operator1");

        if (useBroadcastKeys) {
            vm.stopBroadcast();
        } else {
            vm.stopPrank();
        }
    }

    function _createAndApproveService() internal {
        console2.log("\n=== Creating and Approving Service ===");

        ITangleFull tangle = ITangleFull(payable(tangleProxy));

        // Create service request
        address[] memory operators = new address[](2);
        operators[0] = operator1;
        operators[1] = operator2;

        address[] memory permittedCallers = new address[](0);

        if (useBroadcastKeys) {
            vm.startBroadcast(DEPLOYER_KEY);
        } else {
            vm.startPrank(deployer);
        }
        requestId = tangle.requestService(
            blueprintId,
            operators,
            "", // Empty config
            permittedCallers,
            0, // No TTL
            address(0), // Native ETH payment
            0 // No payment for one-time
        );
        console2.log("Service requested, ID:", requestId);
        if (useBroadcastKeys) {
            vm.stopBroadcast();
        } else {
            vm.stopPrank();
        }

        // Operators approve the service
        if (useBroadcastKeys) {
            vm.startBroadcast(OPERATOR1_KEY);
        } else {
            vm.startPrank(operator1);
        }
        tangle.approveService(requestId, 50); // 50% restaking exposure
        console2.log("Operator1 approved service");
        if (useBroadcastKeys) {
            vm.stopBroadcast();
        } else {
            vm.stopPrank();
        }

        if (useBroadcastKeys) {
            vm.startBroadcast(OPERATOR2_KEY);
        } else {
            vm.startPrank(operator2);
        }
        tangle.approveService(requestId, 50); // 50% restaking exposure
        console2.log("Operator2 approved service");
        if (useBroadcastKeys) {
            vm.stopBroadcast();
        } else {
            vm.stopPrank();
        }

        // After all approvals, service should be active with same ID as request
        serviceId = requestId;
        console2.log("Service activated:", serviceId);
    }

    function _deployPodManager() internal {
        console2.log("\n=== Deploying Beacon / Pod Manager ===");
        if (useBroadcastKeys) {
            vm.startBroadcast(DEPLOYER_KEY);
        } else {
            vm.startPrank(deployer);
        }

        // Deploy mock beacon oracle for local testing
        beaconOracle = new MockBeaconOracle();
        console2.log("MockBeaconOracle:", address(beaconOracle));

        // Set some mock beacon roots for testing
        uint64 currentTimestamp = uint64(block.timestamp);
        beaconOracle.setBeaconBlockRoot(currentTimestamp, keccak256(abi.encode("mock_root_1", currentTimestamp)));

        // Deploy ValidatorPodManager with 32 ETH minimum operator stake
        uint256 minOperatorStake = 32 ether;
        podManager = new ValidatorPodManager(address(beaconOracle), minOperatorStake);
        console2.log("ValidatorPodManager:", address(podManager));

        // Add Tangle as a slasher so it can slash validators for service violations
        podManager.addSlasher(tangleProxy);
        console2.log("Tangle added as pod manager slasher");

        if (useBroadcastKeys) {
            vm.stopBroadcast();
        } else {
            vm.stopPrank();
        }
    }

    function _registerPodManagerOperators() internal {
        console2.log("\n=== Registering Pod Manager Operators ===");

        // Operator 1 registers with 32 ETH stake
        if (useBroadcastKeys) {
            vm.startBroadcast(OPERATOR1_KEY);
        } else {
            vm.startPrank(operator1);
        }
        podManager.registerOperator{ value: 32 ether }();
        console2.log("Operator1 registered in PodManager with 32 ETH");
        if (useBroadcastKeys) {
            vm.stopBroadcast();
        } else {
            vm.stopPrank();
        }

        // Operator 2 registers with 32 ETH stake
        if (useBroadcastKeys) {
            vm.startBroadcast(OPERATOR2_KEY);
        } else {
            vm.startPrank(operator2);
        }
        podManager.registerOperator{ value: 32 ether }();
        console2.log("Operator2 registered in PodManager with 32 ETH");
        if (useBroadcastKeys) {
            vm.stopBroadcast();
        } else {
            vm.stopPrank();
        }

        // Delegator creates a pod
        // Note: To delegate in PodManager, delegator needs podOwnerShares
        // which come from beacon chain ETH via verifyWithdrawalCredentials.
        // For local testing we just deploy the contracts and create a pod.
        // Real beacon chain integration would be needed to test full delegation flow.
        if (useBroadcastKeys) {
            vm.startBroadcast(DELEGATOR_KEY);
        } else {
            vm.startPrank(delegator);
        }
        address pod = podManager.createPod();
        console2.log("Delegator created pod:", pod);
        console2.log("Note: PodManager delegation requires beacon chain shares (not simulated in local testnet)");

        if (useBroadcastKeys) {
            vm.stopBroadcast();
        } else {
            vm.stopPrank();
        }
    }

    function _deployLiquidDelegation() internal {
        console2.log("\n=== Deploying Liquid Delegation ===");
        if (useBroadcastKeys) {
            vm.startBroadcast(DEPLOYER_KEY);
        } else {
            vm.startPrank(deployer);
        }

        // Deploy liquid delegation factory
        IMultiAssetDelegation restaking = IMultiAssetDelegation(payable(restakingProxy));
        liquidFactory = new LiquidDelegationFactory(restaking);
        console2.log("LiquidDelegationFactory:", address(liquidFactory));

        // Create vaults (anyone can create vaults, keeping within deployer broadcast)
        // Note: LiquidDelegationVault uses ERC20 safeTransferFrom, so we use WETH instead of native ETH
        uint64[] memory emptyBlueprints = new uint64[](0);
        liquidVaultETH = payable(liquidFactory.createVault(operator1, address(weth), emptyBlueprints));
        console2.log("LiquidVault WETH (operator1):", liquidVaultETH);

        // Create USDC vault for operator2
        liquidVaultUSDC = payable(liquidFactory.createVault(operator2, address(usdc), emptyBlueprints));
        console2.log("LiquidVault USDC (operator2):", liquidVaultUSDC);

        if (useBroadcastKeys) {
            vm.stopBroadcast();
        } else {
            vm.stopPrank();
        }

        // Delegator deposits into liquid vaults
        if (useBroadcastKeys) {
            vm.startBroadcast(DELEGATOR_KEY);
        } else {
            vm.startPrank(delegator);
        }

        // Approve and deposit WETH into liquid vault
        weth.approve(liquidVaultETH, type(uint256).max);
        LiquidDelegationVault(liquidVaultETH).deposit(1 ether, delegator);
        console2.log("Delegator deposited 1 WETH to liquid vault");

        // Approve and deposit USDC into liquid USDC vault
        usdc.approve(liquidVaultUSDC, type(uint256).max);
        LiquidDelegationVault(liquidVaultUSDC).deposit(1000 * 10 ** 6, delegator);
        console2.log("Delegator deposited 1000 USDC to liquid vault");

        if (useBroadcastKeys) {
            vm.stopBroadcast();
        } else {
            vm.stopPrank();
        }
    }

    function _envAddressOrZero(string memory key) internal view returns (address) {
        try vm.envAddress(key) returns (address raw) {
            return raw;
        } catch {
            return address(0);
        }
    }

    function _envUintOrZero(string memory key) internal view returns (uint256) {
        try vm.envUint(key) returns (uint256 raw) {
            return raw;
        } catch {
            return 0;
        }
    }

    function _distributeTntToken(address source, bool deployedNewTNT) internal {
        address[9] memory recipients = [
            operator1,
            operator2,
            delegator,
            vm.addr(0x47e179ec197488593b187f80a00eb0da91f1b9d0b13f8733639f19c30a34926a),
            vm.addr(0x8b3a350cf5c34c9194ca85829a2df0ec3153be0318b5e2d3348e872092edffba),
            vm.addr(0x92db14e403b83dfe3df233f83dfa3a0d7096f21ca9b0d6d6b8d88b2b4ec1564e),
            vm.addr(0x4bbbf85ce3377467afe5d46f804f221813b2bb87f24d81f60f1fcdbf7cbf4356),
            vm.addr(0xdbda1821b80551c9d65939329250298aa3472ba22feea921c0cf5d620ea67b97),
            vm.addr(0x2a871d0798f97d79848a013d4936a73bf4cc922c825d33c1cf7073dff6d409c6)
        ];

        uint256 required = recipients.length * 10_000 ether;
        uint256 balance = tntToken.balanceOf(source);
        if (balance < required) {
            if (deployedNewTNT) {
                console2.log("Skipping TNT airdrop due to insufficient admin balance");
            } else {
                console2.log("Skipping TNT airdrop - provided TNT token lacks balance for distribution");
            }
            console2.log("Required balance:", required);
            console2.log("Current balance:", balance);
            return;
        }

        for (uint256 i = 0; i < recipients.length; i++) {
            tntToken.transfer(recipients[i], 10_000 ether);
        }
        console2.log("TNT tokens distributed to all dev accounts (10,000 TNT each)");
    }

    function _registerTangleFacets(address tangleProxy_) internal {
        Tangle router = Tangle(payable(tangleProxy_));
        router.registerFacet(address(new TangleBlueprintsFacet()));
        router.registerFacet(address(new TangleBlueprintsManagementFacet()));
        router.registerFacet(address(new TangleOperatorsFacet()));
        router.registerFacet(address(new TangleServicesRequestsFacet()));
        router.registerFacet(address(new TangleServicesFacet()));
        router.registerFacet(address(new TangleServicesLifecycleFacet()));
        router.registerFacet(address(new TangleJobsFacet()));
        router.registerFacet(address(new TangleJobsAggregationFacet()));
        router.registerFacet(address(new TangleQuotesFacet()));
        router.registerFacet(address(new TangleQuotesExtensionFacet()));
        router.registerFacet(address(new TanglePaymentsFacet()));
        router.registerFacet(address(new TangleSlashingFacet()));
    }

    function _registerRestakingFacets(address restakingProxy_) internal {
        MultiAssetDelegation router = MultiAssetDelegation(payable(restakingProxy_));
        router.registerFacet(address(new RestakingOperatorsFacet()));
        router.registerFacet(address(new RestakingDepositsFacet()));
        router.registerFacet(address(new RestakingDelegationsFacet()));
        router.registerFacet(address(new RestakingRewardsFacet()));
        router.registerFacet(address(new RestakingSlashingFacet()));
        router.registerFacet(address(new RestakingAssetsFacet()));
        router.registerFacet(address(new RestakingViewsFacet()));
        router.registerFacet(address(new RestakingAdminFacet()));
    }
}

/// @title TestServiceFlow
/// @notice Test the complete service flow after deployment
/// @dev Run after LocalTestnetSetup
contract TestServiceFlow is Script {
    uint256 constant DEPLOYER_KEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
    uint256 constant OPERATOR1_KEY = 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d;

    function run() external {
        address tangleProxy = vm.envAddress("TANGLE_PROXY");
        uint64 serviceId = uint64(vm.envUint("SERVICE_ID"));

        ITangleFull tangle = ITangleFull(payable(tangleProxy));

        console2.log("Testing service flow for service:", serviceId);

        // Submit a job (as service owner or permitted caller)
        vm.startBroadcast(DEPLOYER_KEY);
        uint64 callId = tangle.submitJob(
            serviceId,
            0, // job index
            abi.encode("test input")
        );
        console2.log("Job submitted, callId:", callId);
        vm.stopBroadcast();

        // Submit result (as operator)
        vm.startBroadcast(OPERATOR1_KEY);
        tangle.submitResult(serviceId, callId, abi.encode("test result"));
        console2.log("Job result submitted");
        vm.stopBroadcast();

        console2.log("Service flow test complete!");
    }
}

/// @title TestHeartbeat
/// @notice Test operator heartbeat submission
contract TestHeartbeat is Script {
    uint256 constant OPERATOR1_KEY = 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d;

    function run() external {
        address statusRegistry = vm.envAddress("STATUS_REGISTRY");
        uint64 serviceId = uint64(vm.envUint("SERVICE_ID"));
        uint64 blueprintId = uint64(vm.envUint("BLUEPRINT_ID"));

        OperatorStatusRegistry registry = OperatorStatusRegistry(statusRegistry);

        console2.log("Submitting heartbeat for service:", serviceId);

        vm.startBroadcast(OPERATOR1_KEY);

        // Create heartbeat signature using Foundry's vm.sign
        bytes memory metrics = "";
        bytes32 messageHash = keccak256(abi.encodePacked(serviceId, blueprintId, metrics));
        // Add Ethereum signed message prefix
        bytes32 ethSignedHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(OPERATOR1_KEY, ethSignedHash);
        bytes memory signature = abi.encodePacked(r, s, v);

        registry.submitHeartbeat(
            serviceId,
            blueprintId,
            0, // Healthy
            metrics,
            signature
        );
        console2.log("Heartbeat submitted");

        vm.stopBroadcast();
    }
}
