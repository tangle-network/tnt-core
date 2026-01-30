// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;
import {Script} from "forge-std/Script.sol";

import "../src/MasterBlueprintServiceManager.sol";

// Here is how you can run this script:
// forge script scripts/MBSMDeployer.s.sol -vvvv --broadcast --evm-version london --legacy --private-key $(subkey inspect //Alice --scheme Ecdsa --output-type json | jq -r .secretSeed)

contract MBSMDeployerScript is Script {
    function run() public {
        vm.createSelectFork("tangle_local");
        vm.startBroadcast();
        // TODO: Change this to the actual protocol fees receiver address
        address payable protocolFeesReceiver = payable(address(0x0));
        new MasterBlueprintServiceManager(protocolFeesReceiver);
        vm.stopBroadcast();

        // vm.createSelectFork("base-sepolia");
        // vm.startBroadcast();
        // new Counter();
        // vm.stopBroadcast();
    }
}
