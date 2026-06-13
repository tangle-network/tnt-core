// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Script, console2 } from "forge-std/Script.sol";

import { LiquidDelegationFactory } from "../src/staking/LiquidDelegationFactory.sol";
import { IMultiAssetDelegation } from "../src/interfaces/IMultiAssetDelegation.sol";

/// @title DeployLiquidDelegation
/// @notice Deploys the `LiquidDelegationFactory` as a standalone, post-FullDeploy launch step.
/// @dev The factory is the single deploy unit; liquid-staking vaults are created per
///      `(operator, asset, blueprintIds)` on demand via `createVault` (permissionless, gated on
///      `staking.isOperatorActive`). Must run AFTER FullDeploy — the factory binds the staking
///      (MultiAssetDelegation) proxy immutably.
///
///      Usage:
///        PRIVATE_KEY=<pk> STAKING=<multiAssetDelegation> TIMELOCK=<timelock-or-multisig> \
///        forge script script/DeployLiquidDelegation.s.sol:DeployLiquidDelegation --rpc-url <rpc> --broadcast
///
///      On a production chain (mainnet/Base/Tangle/Arbitrum/Optimism) TIMELOCK must be set to a
///      real timelock/multisig distinct from the deployer; the factory ownership is handed off to
///      it. Bypass the guard on local/anvil with TANGLE_DEPLOY_LOCAL=1.
contract DeployLiquidDelegation is Script {
    function run() external {
        uint256 deployerKey = _requireUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerKey);
        address payable staking = payable(_requireAddress("STAKING"));
        // On production chains TIMELOCK is mandatory; on local it defaults to the deployer.
        address owner = _envAddress("TIMELOCK", _isProductionChain() ? address(0) : deployer);

        _requireProductionOwner(deployer, owner);

        console2.log("=== Deploy LiquidDelegationFactory ===");
        console2.log("ChainId:", block.chainid);
        console2.log("Deployer:", deployer);
        console2.log("Staking (MultiAssetDelegation):", staking);
        console2.log("Factory owner (timelock/multisig):", owner);

        vm.startBroadcast(deployerKey);
        LiquidDelegationFactory factory = new LiquidDelegationFactory(IMultiAssetDelegation(staking));
        // Hand factory ownership to the timelock/multisig (the factory is Ownable; this keeps
        // any future admin surface off the deployer hot key).
        if (owner != deployer) {
            factory.transferOwnership(owner);
        }
        vm.stopBroadcast();

        require(factory.owner() == owner, "ownership handoff failed");
        console2.log("LiquidDelegationFactory:", address(factory));
        console2.log("Vaults are created on demand via createVault(operator, asset, blueprintIds, name, symbol).");
        console2.log("Restrict prod vault creation to real ERC20 assets (native-ETH vault path is not live).");
    }

    function _isProductionChain() internal view returns (bool) {
        if (vm.envOr("TANGLE_DEPLOY_LOCAL", uint256(0)) != 0) return false;
        uint256 id = block.chainid;
        // Ethereum, Base, Tangle, Arbitrum, Optimism mainnets.
        return id == 1 || id == 8453 || id == 5845 || id == 42_161 || id == 10;
    }

    /// @notice On production chains the factory owner must be a distinct, non-zero timelock/multisig.
    function _requireProductionOwner(address deployer, address owner) internal view {
        if (!_isProductionChain()) return;
        require(owner != address(0), "config: TIMELOCK must be set on production");
        require(owner != deployer, "config: factory owner must not equal deployer on production");
    }

    function _requireUint(string memory key) internal returns (uint256) {
        try vm.envUint(key) returns (uint256 raw) {
            return raw;
        } catch {
            revert(string.concat("Missing env ", key));
        }
    }

    function _requireAddress(string memory key) internal returns (address) {
        try vm.envAddress(key) returns (address raw) {
            if (raw == address(0)) revert(string.concat("Missing env ", key));
            return raw;
        } catch {
            revert(string.concat("Missing env ", key));
        }
    }

    function _envAddress(string memory key, address defaultValue) internal returns (address) {
        try vm.envAddress(key) returns (address raw) {
            return raw == address(0) ? defaultValue : raw;
        } catch {
            return defaultValue;
        }
    }
}
