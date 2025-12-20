// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Script, console2 } from "forge-std/Script.sol";

import { IMultiAssetDelegation } from "../../src/v2/interfaces/IMultiAssetDelegation.sol";

interface EnvReader {
    function vm_envUint(string calldata) external returns (uint256);
    function vm_envAddress(string calldata) external returns (address);
    function vm_envOr(string calldata, uint256) external returns (uint256);
    function vm_envOr(string calldata, address) external returns (address);
}

abstract contract BasicEnv is Script {
    function _requireUint(string memory key) internal returns (uint256 value) {
        try vm.envUint(key) returns (uint256 raw) {
            return raw;
        } catch {
            revert(string.concat("Missing env ", key));
        }
    }

    function _requireAddress(string memory key) internal returns (address value) {
        try vm.envAddress(key) returns (address raw) {
            if (raw == address(0)) revert(string.concat("Missing env ", key));
            return raw;
        } catch {
            revert(string.concat("Missing env ", key));
        }
    }

    function _envUint(string memory key, uint256 defaultValue) internal returns (uint256) {
        try vm.envUint(key) returns (uint256 raw) {
            return raw;
        } catch {
            return defaultValue;
        }
    }

    function _envAddress(string memory key, address defaultValue) internal returns (address) {
        try vm.envAddress(key) returns (address raw) {
            if (raw == address(0)) revert(string.concat("Missing env ", key));
            return raw;
        } catch {
            if (defaultValue == address(0)) revert(string.concat("Missing env ", key));
            return defaultValue;
        }
    }
}

/// @title AddRestakingAsset
/// @notice Helper forge script to register new ERC20 assets with MultiAssetDelegation.enableAsset
/// @dev Usage:
///      PRIVATE_KEY=<pk> RESTAKING=<delegation> ASSET_TOKEN=<token>
///      MIN_OPERATOR_STAKE=1e18 MIN_DELEGATION=1e17 DEPOSIT_CAP=0 REWARD_MULTIPLIER_BPS=10000
///      forge script script/v2/AddRestakingAsset.s.sol:AddRestakingAsset --rpc-url <rpc> --broadcast
contract AddRestakingAsset is BasicEnv {
    function run() external {
        uint256 deployerPk = _requireUint("PRIVATE_KEY");
        address payable restaking = payable(_requireAddress("RESTAKING"));
        address asset = _requireAddress("ASSET_TOKEN");
        uint256 minOperatorStake = _envUint("MIN_OPERATOR_STAKE", 0);
        uint256 minDelegation = _envUint("MIN_DELEGATION", 0);
        uint256 depositCap = _envUint("DEPOSIT_CAP", 0);
        uint16 rewardMultiplierBps = uint16(_envUint("REWARD_MULTIPLIER_BPS", 10_000));

        console2.log("=== Adding Restaking Asset ===");
        console2.log("Restaking:", restaking);
        console2.log("Token:", asset);
        console2.log("Min Operator Stake:", minOperatorStake);
        console2.log("Min Delegation:", minDelegation);
        console2.log("Deposit Cap:", depositCap);
        console2.log("Reward Multiplier (bps):", rewardMultiplierBps);

        vm.startBroadcast(deployerPk);
        IMultiAssetDelegation(restaking)
            .enableAsset(asset, minOperatorStake, minDelegation, depositCap, rewardMultiplierBps);
        vm.stopBroadcast();

        console2.log("Asset registered successfully.");
    }
}
