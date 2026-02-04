// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {SP1VerifierGateway} from "../src/sp1/SP1VerifierGateway.sol";
import {SP1Verifier} from "../src/sp1/SP1Verifier.sol";

/// @title Deploy SP1 Infrastructure
/// @notice Deploys SP1VerifierGateway and SP1Verifier v5.0.0 to any EVM chain
/// @dev Usage:
///   PRIVATE_KEY=0x... OWNER=0x... forge script script/DeploySP1Infrastructure.s.sol:DeploySP1Infrastructure \
///     --rpc-url $RPC_URL --broadcast -vvv
contract DeploySP1Infrastructure is Script {
    function run() external {
        // Get owner address from environment (defaults to deployer if not set)
        address deployer = vm.addr(vm.envUint("PRIVATE_KEY"));
        address owner = vm.envOr("OWNER", deployer);

        console.log("============================================");
        console.log("SP1 Infrastructure Deployment");
        console.log("============================================");
        console.log("Deployer:", deployer);
        console.log("Owner:", owner);
        console.log("");

        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));

        // 1. Deploy SP1VerifierGateway with owner
        SP1VerifierGateway gateway = new SP1VerifierGateway(owner);
        console.log("SP1VerifierGateway deployed at:", address(gateway));

        // 2. Deploy SP1Verifier v5.0.0
        SP1Verifier verifier = new SP1Verifier();
        console.log("SP1Verifier (v5.0.0) deployed at:", address(verifier));
        console.log("  VERIFIER_HASH:", vm.toString(verifier.VERIFIER_HASH()));

        // 3. Add verifier route to gateway
        // Note: This must be called by the owner
        if (deployer == owner) {
            gateway.addRoute(address(verifier));
            console.log("Route added to gateway for SP1Verifier v5.0.0");
        } else {
            console.log("");
            console.log("WARNING: Deployer is not the owner. You must manually add the route:");
            console.log("  gateway.addRoute(", vm.toString(address(verifier)), ")");
        }

        vm.stopBroadcast();

        console.log("");
        console.log("============================================");
        console.log("Deployment Complete!");
        console.log("============================================");
        console.log("");
        console.log("Use this address as SP1_VERIFIER for migration deployment:");
        console.log("  SP1_VERIFIER=", vm.toString(address(gateway)));
        console.log("");
        console.log("Export for shell:");
        console.log("  export SP1_VERIFIER=", vm.toString(address(gateway)));
    }
}
