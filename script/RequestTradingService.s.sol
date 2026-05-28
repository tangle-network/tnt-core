// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Script, console2 } from "forge-std/Script.sol";
import { ITangleFull } from "../src/interfaces/ITangle.sol";
import { Types } from "../src/libraries/Types.sol";

/// @title RequestTradingService
/// @notice Onboard an operator to a trading blueprint and stand up a live
/// service in one shot: registerOperator -> requestService -> approveService.
/// Reliable path when cargo-tangle's bindings are version-skewed vs the
/// deployed Tangle (this script compiles against tnt-core's own interfaces, so
/// the selectors always match the deployment).
///
/// Env:
///   TANGLE_CORE       deployed Tangle (e.g. 0x8299d60f… on Base Sepolia)
///   BLUEPRINT_ID      uint64 (13 = trading/cloud)
///   OPERATOR_KEY      operator private key (must already be a staked/active
///                     MAD operator; this only registers it on the blueprint)
///   OPERATOR_ADDR     operator address
///   OPERATOR_PUBKEY   65-byte uncompressed secp256k1 pubkey (0x04‖X‖Y)
///   OPERATOR_RPC      operator RPC advertised on-chain (string)
///   SERVICE_TTL_SECS  optional, default 604800 (7 days)
contract RequestTradingService is Script {
    function run() external {
        ITangleFull tangle = ITangleFull(payable(vm.envAddress("TANGLE_CORE")));
        uint64 blueprintId = uint64(vm.envUint("BLUEPRINT_ID"));
        uint256 operatorKey = vm.envUint("OPERATOR_KEY");
        address operator = vm.envAddress("OPERATOR_ADDR");
        bytes memory pubkey = vm.envBytes("OPERATOR_PUBKEY");
        string memory rpc = vm.envString("OPERATOR_RPC");
        uint64 ttl = uint64(vm.envOr("SERVICE_TTL_SECS", uint256(7 days)));

        // 1. Register the (already-staked) operator on the blueprint.
        vm.startBroadcast(operatorKey);
        tangle.registerOperator(blueprintId, pubkey, rpc);
        vm.stopBroadcast();
        console2.log("registerOperator OK; blueprint", blueprintId);

        // 2. Request a service with this single operator, empty config, native
        //    (free) payment, Any confidentiality — mirrors the canonical flow.
        address[] memory operators = new address[](1);
        operators[0] = operator;
        address[] memory permittedCallers = new address[](0);

        vm.startBroadcast(operatorKey);
        uint64 serviceId = tangle.requestService(
            blueprintId,
            operators,
            "", // empty config (trading blueprint accepts it; matches CreateServiceForTLV2Test)
            permittedCallers,
            ttl,
            address(0), // native payment token
            0, // payment amount
            Types.ConfidentialityPolicy.Any
        );
        console2.log("requestService OK; serviceId", serviceId);
        vm.stopBroadcast();

        // 3. Operator approves -> service becomes active (single-operator).
        vm.startBroadcast(operatorKey);
        tangle.approveService(
            Types.ApprovalParams({
                requestId: serviceId,
                securityCommitments: new Types.AssetSecurityCommitment[](0),
                blsPubkey: [uint256(0), 0, 0, 0],
                blsPopSignature: [uint256(0), 0],
                teeCommitments: new Types.TeeAttestationCommitment[](0)
            })
        );
        vm.stopBroadcast();
        console2.log("approveService OK; service ACTIVE serviceId", serviceId);
    }
}
