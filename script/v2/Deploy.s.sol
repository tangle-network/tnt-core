// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Script, console2 } from "forge-std/Script.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import { Tangle } from "../../src/v2/Tangle.sol";
import { IMultiAssetDelegation } from "../../src/v2/interfaces/IMultiAssetDelegation.sol";
import { MultiAssetDelegation } from "../../src/v2/staking/MultiAssetDelegation.sol";
import { OperatorStatusRegistry } from "../../src/v2/staking/OperatorStatusRegistry.sol";
import { TangleToken } from "../../src/v2/governance/TangleToken.sol";
import { MasterBlueprintServiceManager } from "../../src/v2/MasterBlueprintServiceManager.sol";
import { MBSMRegistry } from "../../src/v2/MBSMRegistry.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { AccessControlUpgradeable } from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
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
import { StakingOperatorsFacet } from "../../src/v2/facets/staking/StakingOperatorsFacet.sol";
import { StakingDepositsFacet } from "../../src/v2/facets/staking/StakingDepositsFacet.sol";
import { StakingDelegationsFacet } from "../../src/v2/facets/staking/StakingDelegationsFacet.sol";
import { StakingSlashingFacet } from "../../src/v2/facets/staking/StakingSlashingFacet.sol";
import { StakingAssetsFacet } from "../../src/v2/facets/staking/StakingAssetsFacet.sol";
import { StakingViewsFacet } from "../../src/v2/facets/staking/StakingViewsFacet.sol";
import { StakingAdminFacet } from "../../src/v2/facets/staking/StakingAdminFacet.sol";
import { ServiceFeeDistributor } from "../../src/v2/rewards/ServiceFeeDistributor.sol";
import { Types } from "../../src/v2/libraries/Types.sol";

error InvalidAddress(string field);
error ProxyVerificationFailed(string reason);
error AddressNotAllowlisted(string field, address provided, address expected);
error MissingEnv(string key);

abstract contract DeployScriptBase is Script {
    function _requireEnvUint(string memory key) internal view returns (uint256 value) {
        try vm.envUint(key) returns (uint256 raw) {
            return raw;
        } catch {
            revert MissingEnv(key);
        }
    }

    function _envUintOrDefault(string memory key, uint256 defaultValue) internal view returns (uint256 value) {
        try vm.envUint(key) returns (uint256 raw) {
            return raw;
        } catch {
            return defaultValue;
        }
    }

    function _requireEnvAddress(string memory key) internal view returns (address value) {
        try vm.envAddress(key) returns (address raw) {
            return _requireNonZero(raw, key);
        } catch {
            revert MissingEnv(key);
        }
    }

    function _envAddressOrDefault(string memory key, address fallbackValue) internal view returns (address) {
        try vm.envAddress(key) returns (address raw) {
            return _requireNonZero(raw, key);
        } catch {
            return _requireNonZero(fallbackValue, key);
        }
    }

    function _envAddressIfSet(string memory key) internal view returns (address) {
        try vm.envAddress(key) returns (address raw) {
            return raw;
        } catch {
            return address(0);
        }
    }

    function _requireNonZero(address value, string memory field) internal pure returns (address) {
        if (value == address(0)) {
            revert InvalidAddress(field);
        }
        return value;
    }

    function _enforceAllowlist(string memory envKey, string memory field, address candidate) internal view {
        try vm.envAddress(envKey) returns (address allowed) {
            if (allowed != address(0) && candidate != allowed) {
                revert AddressNotAllowlisted(field, candidate, allowed);
            }
        } catch { }
    }

    /// @notice Verify UUPS proxy deployment was successful
    /// @param proxy The proxy address
    /// @param expectedAdmin The expected admin address
    /// @param label Human-readable label for error messages
    function _verifyProxy(address proxy, address expectedAdmin, string memory label) internal view {
        // 1. Check proxy address is valid
        if (proxy == address(0)) {
            revert ProxyVerificationFailed(string.concat(label, ": proxy is zero address"));
        }

        // 2. Check proxy has code (is a contract)
        if (proxy.code.length == 0) {
            revert ProxyVerificationFailed(string.concat(label, ": proxy has no code"));
        }

        // 3. Verify admin role is properly set
        bytes32 adminRole = AccessControlUpgradeable(proxy).DEFAULT_ADMIN_ROLE();
        if (!AccessControlUpgradeable(proxy).hasRole(adminRole, expectedAdmin)) {
            revert ProxyVerificationFailed(string.concat(label, ": admin role not set"));
        }

        console2.log(string.concat("[VERIFIED] ", label, " proxy at"), proxy);
    }
}

/// @title DeployV2
/// @notice Deploy script for Tangle v2 contracts
/// @dev Deploys with UUPS proxies for upgradeability
contract DeployV2 is DeployScriptBase {
    // Configuration
    uint256 public minOperatorStake = 1 ether;
    uint256 public minDelegation = 0.1 ether;
    uint16 public operatorCommissionBps = 1000; // 10%
    address public tntToken;
    uint256 public tntInitialSupply;

    function run() external virtual {
        uint256 deployerPrivateKey = _requireEnvUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        address admin = _envAddressOrDefault("ADMIN", deployer);
        address treasury = _envAddressOrDefault("TREASURY", deployer);
        _enforceAllowlist("ADMIN_ALLOWLIST", "ADMIN", admin);
        _enforceAllowlist("TREASURY_ALLOWLIST", "TREASURY", treasury);

        console2.log("Deployer:", deployer);
        console2.log("Admin:", admin);
        console2.log("Treasury:", treasury);

        (
            address stakingProxy,
            address stakingImpl,
            address tangleProxy,
            address tangleImpl,
            address statusRegistry
        ) = _deployCore(deployerPrivateKey, deployer, admin, treasury, true);

        // Log summary
        console2.log("\n=== Deployment Summary ===");
        console2.log("Chain ID:", block.chainid);
        console2.log("Tangle:", tangleProxy);
        console2.log("MultiAssetDelegation:", stakingProxy);
        console2.log("OperatorStatusRegistry:", statusRegistry);
    }

    /// @notice Dry-run deployment for testing/CI without env or broadcast
    function dryRun(
        address deployer,
        address admin,
        address treasury
    )
        external
        returns (address stakingProxy, address tangleProxy, address statusRegistry)
    {
        address deployerAddr = deployer == address(0) ? msg.sender : deployer;
        admin = _requireNonZero(admin == address(0) ? deployerAddr : admin, "ADMIN");
        treasury = _requireNonZero(treasury == address(0) ? deployerAddr : treasury, "TREASURY");
        _enforceAllowlist("ADMIN_ALLOWLIST", "ADMIN", admin);
        _enforceAllowlist("TREASURY_ALLOWLIST", "TREASURY", treasury);
        (stakingProxy,, tangleProxy,, statusRegistry) = _deployCore(0, deployerAddr, admin, treasury, false);
    }

    function _deployCore(
        uint256 deployerPrivateKey,
        address deployer,
        address admin,
        address treasury,
        bool broadcast
    )
        internal
        returns (
            address stakingProxy,
            address stakingImpl,
            address tangleProxy,
            address tangleImpl,
            address statusRegistry
        )
    {
        if (broadcast) {
            vm.startBroadcast(deployerPrivateKey);
        } else if (deployer != address(0)) {
            vm.startPrank(deployer);
        }

        (stakingProxy, stakingImpl) = deployMultiAssetDelegation(admin);
        console2.log("MultiAssetDelegation implementation:", stakingImpl);
        console2.log("MultiAssetDelegation proxy:", stakingProxy);

        (tangleProxy, tangleImpl) = deployTangle(admin, stakingProxy, treasury);
        console2.log("Tangle implementation:", tangleImpl);
        console2.log("Tangle proxy:", tangleProxy);

        _registerStakingFacets(stakingProxy);
        _registerTangleFacets(tangleProxy);

        statusRegistry = deployOperatorStatusRegistry(tangleProxy, admin);
        console2.log("OperatorStatusRegistry:", statusRegistry);

        // Verify proxy deployments
        _verifyProxy(stakingProxy, admin, "MultiAssetDelegation");
        _verifyProxy(tangleProxy, admin, "Tangle");

        IMultiAssetDelegation(payable(stakingProxy)).addSlasher(tangleProxy);
        IMultiAssetDelegation(payable(stakingProxy)).setTangle(tangleProxy);

        MasterBlueprintServiceManager masterManager = new MasterBlueprintServiceManager(admin, tangleProxy);
        MBSMRegistry registryImpl = new MBSMRegistry();
        ERC1967Proxy registryProxy =
            new ERC1967Proxy(address(registryImpl), abi.encodeCall(MBSMRegistry.initialize, (admin)));
        MBSMRegistry mbsmRegistry = MBSMRegistry(address(registryProxy));
        mbsmRegistry.grantRole(mbsmRegistry.MANAGER_ROLE(), tangleProxy);
        mbsmRegistry.addVersion(address(masterManager));
        Tangle(payable(tangleProxy)).setMBSMRegistry(address(mbsmRegistry));

        console2.log("Granted SLASHER_ROLE and TANGLE_ROLE to Tangle");
        Tangle(payable(tangleProxy)).setOperatorStatusRegistry(statusRegistry);
        console2.log("Set OperatorStatusRegistry on Tangle");

        _ensureTntToken(admin);
        _configureTntDefaults(tangleProxy, stakingProxy);
        _configureServiceFeeDistributor(admin, stakingProxy, tangleProxy);

        if (broadcast) {
            vm.stopBroadcast();
        } else if (deployer != address(0)) {
            vm.stopPrank();
        }
    }

    function _configureTntDefaults(address tangleProxy, address stakingProxy) internal {
        Tangle tangle = Tangle(payable(tangleProxy));
        IMultiAssetDelegation staking = IMultiAssetDelegation(payable(stakingProxy));

        address tnt = _envAddressIfSet("TNT_TOKEN");
        if (tnt == address(0)) {
            tnt = tntToken;
        }

        tangle.setTntToken(tnt);
        console2.log("Configured TNT token:", tnt);
        if (tnt != address(0)) {
            Types.AssetConfig memory cfg = staking.getAssetConfig(tnt);
            if (!cfg.enabled) {
                staking.enableAsset(tnt, minOperatorStake, minDelegation, 0, 10_000);
                console2.log("Enabled TNT as staking asset");
            }
            staking.setOperatorBondToken(tnt);
            console2.log("Configured operator bond token:", tnt);
        }

        address vaults = _envAddressIfSet("REWARD_VAULTS");
        if (vaults != address(0)) {
            tangle.setRewardVaults(vaults);
            console2.log("Configured RewardVaults:", vaults);
        }

        uint256 minExposure = _envUintOrDefault("DEFAULT_TNT_MIN_EXPOSURE_BPS", 0);
        if (minExposure > 0) {
            require(minExposure <= 10_000, "DEFAULT_TNT_MIN_EXPOSURE_BPS too high");
            tangle.setDefaultTntMinExposureBps(uint16(minExposure));
            console2.log("Configured default TNT min exposure bps:", minExposure);
        }

        uint256 discountBps = _envUintOrDefault("TNT_PAYMENT_DISCOUNT_BPS", 0);
        if (discountBps > 0) {
            require(discountBps <= 10_000, "TNT_PAYMENT_DISCOUNT_BPS too high");
            tangle.setTntPaymentDiscountBps(uint16(discountBps));
            console2.log("Configured TNT payment discount bps:", discountBps);
        }
    }

    function _configureServiceFeeDistributor(address admin, address stakingProxy, address tangleProxy) internal {
        Tangle tangle = Tangle(payable(tangleProxy));
        IMultiAssetDelegation staking = IMultiAssetDelegation(payable(stakingProxy));

        address distributor = _envAddressIfSet("SERVICE_FEE_DISTRIBUTOR");
        address oracle = _envAddressIfSet("PRICE_ORACLE");

        if (distributor == address(0)) {
            ServiceFeeDistributor impl = new ServiceFeeDistributor();
            ERC1967Proxy proxy = new ERC1967Proxy(
                address(impl),
                abi.encodeCall(ServiceFeeDistributor.initialize, (admin, stakingProxy, tangleProxy, oracle))
            );
            distributor = address(proxy);
            console2.log("Deployed ServiceFeeDistributor proxy:", distributor);
        } else {
            console2.log("Using existing ServiceFeeDistributor:", distributor);
        }

        tangle.setServiceFeeDistributor(distributor);
        staking.setServiceFeeDistributor(distributor);

        if (oracle != address(0)) {
            tangle.setPriceOracle(oracle);
        }
    }

    function _ensureTntToken(address admin) internal {
        if (tntToken != address(0)) {
            return;
        }

        address tokenFromEnv = _envAddressIfSet("TNT_TOKEN");
        if (tokenFromEnv != address(0)) {
            tntToken = _requireNonZero(tokenFromEnv, "TNT_TOKEN");
            console2.log("Using existing TNT token from env:", tntToken);
            return;
        }

        tntToken = _deployTNTToken(admin);
    }

    function _deployTNTToken(address admin) internal returns (address) {
        uint256 initialSupply = tntInitialSupply;
        if (initialSupply == 0) {
            initialSupply = _envUintOrDefault("TNT_INITIAL_SUPPLY", 1_000_000 ether);
        }
        TangleToken tokenImpl = new TangleToken();
        ERC1967Proxy tokenProxy =
            new ERC1967Proxy(address(tokenImpl), abi.encodeCall(TangleToken.initialize, (admin, initialSupply)));
        console2.log("Deployed TangleToken proxy:", address(tokenProxy));
        console2.log("Initial TNT supply minted to admin:", initialSupply);
        return address(tokenProxy);
    }

    function deployMultiAssetDelegation(address admin) internal returns (address proxy, address impl) {
        // Deploy implementation
        MultiAssetDelegation implementation = new MultiAssetDelegation();
        impl = address(implementation);

        // Deploy proxy
        bytes memory initData = abi.encodeCall(
            MultiAssetDelegation.initialize, (admin, minOperatorStake, minDelegation, operatorCommissionBps)
        );

        ERC1967Proxy proxyContract = new ERC1967Proxy(impl, initData);
        proxy = address(proxyContract);
    }

    function deployTangle(
        address admin,
        address staking,
        address treasury
    )
        internal
        returns (address proxy, address impl)
    {
        // Deploy implementation
        Tangle implementation = new Tangle();
        impl = address(implementation);

        // Deploy proxy
        bytes memory initData = abi.encodeCall(Tangle.initialize, (admin, staking, payable(treasury)));

        ERC1967Proxy proxyContract = new ERC1967Proxy(impl, initData);
        proxy = address(proxyContract);
    }

    function _registerTangleFacets(address tangleProxy) internal {
        Tangle router = Tangle(payable(tangleProxy));
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

    function _registerStakingFacets(address stakingProxy) internal {
        MultiAssetDelegation router = MultiAssetDelegation(payable(stakingProxy));
        router.registerFacet(address(new StakingOperatorsFacet()));
        router.registerFacet(address(new StakingDepositsFacet()));
        router.registerFacet(address(new StakingDelegationsFacet()));
        router.registerFacet(address(new StakingSlashingFacet()));
        router.registerFacet(address(new StakingAssetsFacet()));
        router.registerFacet(address(new StakingViewsFacet()));
        router.registerFacet(address(new StakingAdminFacet()));
    }

    function deployOperatorStatusRegistry(address tangleCore, address owner) internal returns (address) {
        // OperatorStatusRegistry is not upgradeable - uses immutable tangleCore
        OperatorStatusRegistry registry = new OperatorStatusRegistry(tangleCore, owner);
        return address(registry);
    }
}

/// @title UpgradeTangle
/// @notice Upgrade Tangle to new implementation
contract UpgradeTangle is DeployScriptBase {
    function run() external {
        uint256 deployerPrivateKey = _requireEnvUint("PRIVATE_KEY");
        address tangleProxy = vm.envAddress("TANGLE_PROXY");

        console2.log("Upgrading Tangle proxy:", tangleProxy);

        vm.startBroadcast(deployerPrivateKey);

        // Deploy new implementation
        Tangle newImplementation = new Tangle();
        console2.log("New implementation:", address(newImplementation));

        // Upgrade (caller must have UPGRADER_ROLE)
        Tangle(payable(tangleProxy)).upgradeToAndCall(address(newImplementation), "");
        console2.log("Upgrade complete");

        vm.stopBroadcast();
    }
}

/// @title UpgradeMultiAssetDelegation
/// @notice Upgrade MultiAssetDelegation to new implementation
contract UpgradeMultiAssetDelegation is DeployScriptBase {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address stakingProxy = vm.envAddress("RESTAKING_PROXY");

        console2.log("Upgrading MultiAssetDelegation proxy:", stakingProxy);

        vm.startBroadcast(deployerPrivateKey);

        // Deploy new implementation
        MultiAssetDelegation newImplementation = new MultiAssetDelegation();
        console2.log("New implementation:", address(newImplementation));

        // Upgrade
        MultiAssetDelegation(payable(stakingProxy)).upgradeToAndCall(address(newImplementation), "");
        console2.log("Upgrade complete");

        vm.stopBroadcast();
    }
}
