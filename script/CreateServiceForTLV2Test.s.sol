// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Script, console2 } from "forge-std/Script.sol";
import { ITangleFull } from "../src/interfaces/ITangle.sol";

/// @title CreateServiceForTLV2Test
/// @notice Create a service for the TLV v2 test blueprint
contract CreateServiceForTLV2Test is Script {
    uint256 constant DEPLOYER_KEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
    uint256 constant OPERATOR1_KEY = 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d;
    address constant TANGLE = 0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9;
    address constant OPERATOR1 = 0x70997970C51812dc3A010C7d01b50e0d17dc79C8;

    function run() external {
        ITangleFull tangle = ITangleFull(payable(TANGLE));

        // 1. Register operator1 for blueprint 1
        console2.log("Registering operator for blueprint 1...");
        vm.startBroadcast(OPERATOR1_KEY);
        bytes memory operator1Key =
            hex"040102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f40";
        tangle.registerOperator(1, operator1Key, "http://operator1.local:8545");
        vm.stopBroadcast();
        console2.log("Operator registered");

        // 2. Request service for blueprint 1 with operator1
        console2.log("Requesting service for blueprint 1...");
        vm.startBroadcast(DEPLOYER_KEY);

        address[] memory operators = new address[](1);
        operators[0] = OPERATOR1;
        address[] memory permittedCallers = new address[](0); // Anyone can call

        uint64 serviceId = tangle.requestService(
            1, // blueprintId
            operators, // operators
            "", // config
            permittedCallers, // permittedCallers
            uint64(7 days), // ttl
            address(0), // paymentToken (native)
            0 // paymentAmount
        );
        console2.log("Service requested with ID:", serviceId);
        vm.stopBroadcast();

        // 3. Approve service as operator1
        console2.log("Approving service as operator1...");
        vm.startBroadcast(OPERATOR1_KEY);
        tangle.approveService(serviceId, 100); // 100% restaking
        vm.stopBroadcast();
        console2.log("Service approved and active");

        console2.log("Done! Service ID:", serviceId);
    }
}
