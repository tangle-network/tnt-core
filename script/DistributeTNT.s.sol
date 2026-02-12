// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Script, console2 } from "forge-std/Script.sol";
import { stdJson } from "forge-std/StdJson.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title DistributeTNT
/// @notice Batch transfer TNT (or any ERC20) from the deployer to a recipient list.
/// @dev Intended for testnet launches and controlled distributions; for large sets prefer a Merkle distributor.
contract DistributeTNT is Script {
    using stdJson for string;

    error EmptyDistributionFile();
    error MissingToken();

    struct Transfer {
        address to;
        uint256 amount;
    }

    function run() external {
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");
        address token = vm.envOr("TNT_TOKEN", address(0));
        string memory path = vm.envString("DISTRIBUTION_FILE");

        string memory json = vm.readFile(path);
        if (bytes(json).length == 0) revert EmptyDistributionFile();

        if (token == address(0) && json.keyExists(".token")) {
            token = json.readAddress(".token");
        }
        if (token == address(0)) revert MissingToken();

        Transfer[] memory transfers = abi.decode(json.parseRaw(".transfers"), (Transfer[]));
        require(transfers.length > 0, "No transfers");

        address deployer = vm.addr(deployerKey);
        uint256 total;
        for (uint256 i = 0; i < transfers.length; i++) {
            total += transfers[i].amount;
        }

        IERC20 erc20 = IERC20(token);
        uint256 balance = erc20.balanceOf(deployer);
        require(balance >= total, "Insufficient balance for distribution");

        console2.log("=== TNT Distribution ===");
        console2.log("Token:", token);
        console2.log("Sender:", deployer);
        console2.log("Recipients:", transfers.length);
        console2.log("Total:", total);

        vm.startBroadcast(deployerKey);
        for (uint256 i = 0; i < transfers.length; i++) {
            Transfer memory t = transfers[i];
            require(t.to != address(0), "Zero recipient");
            require(t.amount > 0, "Zero amount");
            require(erc20.transfer(t.to, t.amount), "Transfer failed");
        }
        vm.stopBroadcast();

        console2.log("Distribution complete.");
    }
}

