// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Script, console2 } from "forge-std/Script.sol";
import { stdJson } from "forge-std/StdJson.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import { TNTLockFactory } from "../src/governance/lockups/TNTLockFactory.sol";

/// @title DistributeTNTWithLockup
/// @notice Batch distribute TNT with a configurable unlocked/locked split and cliff lock.
/// @dev Config format:
/// {
///   "token": "0x...",
///   "lockFactory": "0x... (optional, deploy if omitted)",
///   "unlockTimestamp": 1760000000,
///   "unlockedBps": 1000,
///   "transfers": [ { "to": "0x...", "amount": "100000..." } ]
/// }
contract DistributeTNTWithLockup is Script {
    using stdJson for string;
    using SafeERC20 for IERC20;

    error EmptyDistributionFile();
    error InvalidBps();
    error MissingToken();
    error MissingUnlockTimestamp();

    struct Transfer {
        address to;
        uint256 amount;
    }

    function run() external {
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerKey);

        string memory path = vm.envString("DISTRIBUTION_FILE");
        string memory json = vm.readFile(path);
        if (bytes(json).length == 0) revert EmptyDistributionFile();

        address token = vm.envOr("TNT_TOKEN", address(0));
        if (token == address(0) && json.keyExists(".token")) {
            token = json.readAddress(".token");
        }
        if (token == address(0)) revert MissingToken();

        uint16 unlockedBps;
        try vm.envUint("UNLOCKED_BPS") returns (uint256 fromEnv) {
            unlockedBps = uint16(fromEnv);
        } catch {
            if (json.keyExists(".unlockedBps")) {
                unlockedBps = uint16(json.readUint(".unlockedBps"));
            } else {
                unlockedBps = 1000; // default: 10% unlocked, 90% locked
            }
        }
        if (unlockedBps > 10_000) revert InvalidBps();

        uint64 unlockTimestamp;
        try vm.envUint("UNLOCK_TIMESTAMP") returns (uint256 tsFromEnv) {
            unlockTimestamp = uint64(tsFromEnv);
        } catch {
            if (json.keyExists(".unlockTimestamp")) {
                unlockTimestamp = uint64(json.readUint(".unlockTimestamp"));
            } else {
                // default: 6 month cliff from execution time
                unlockTimestamp = uint64(block.timestamp + 180 days);
            }
        }
        if (unlockedBps < 10_000 && unlockTimestamp == 0) revert MissingUnlockTimestamp();

        address factoryAddr = vm.envOr("LOCK_FACTORY", address(0));
        if (factoryAddr == address(0) && json.keyExists(".lockFactory")) {
            factoryAddr = json.readAddress(".lockFactory");
        }

        Transfer[] memory transfers = abi.decode(json.parseRaw(".transfers"), (Transfer[]));
        require(transfers.length > 0, "No transfers");

        IERC20 erc20 = IERC20(token);
        uint256 total;
        for (uint256 i = 0; i < transfers.length; i++) {
            total += transfers[i].amount;
        }
        require(erc20.balanceOf(deployer) >= total, "Insufficient balance");

        console2.log("=== TNT Distribution (with lockup) ===");
        console2.log("Token:", token);
        console2.log("Sender:", deployer);
        console2.log("Recipients:", transfers.length);
        console2.log("Total:", total);
        console2.log("Unlocked bps:", unlockedBps);
        console2.log("Unlock timestamp:", unlockTimestamp);

        vm.startBroadcast(deployerKey);

        TNTLockFactory factory;
        if (factoryAddr == address(0)) {
            factory = new TNTLockFactory();
            factoryAddr = address(factory);
            console2.log("Deployed TNTLockFactory:", factoryAddr);
        } else {
            factory = TNTLockFactory(factoryAddr);
        }

        for (uint256 i = 0; i < transfers.length; i++) {
            Transfer memory t = transfers[i];
            require(t.to != address(0), "Zero recipient");
            require(t.amount > 0, "Zero amount");

            uint256 unlockedAmount = (t.amount * unlockedBps) / 10_000;
            uint256 lockedAmount = t.amount - unlockedAmount;

            if (unlockedAmount > 0) {
                erc20.safeTransfer(t.to, unlockedAmount);
            }

            if (lockedAmount > 0) {
                address lock = factory.getOrCreateLock(token, t.to, unlockTimestamp, t.to);
                erc20.safeTransfer(lock, lockedAmount);
            }
        }

        vm.stopBroadcast();

        console2.log("Lock factory:", factoryAddr);
        console2.log("Distribution complete.");
    }
}
