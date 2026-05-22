// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Script, console2 } from "forge-std/Script.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import { TangleBlueprintsBinaryVersionsFacet } from
    "../src/facets/tangle/TangleBlueprintsBinaryVersionsFacet.sol";
import { TangleBlueprintsBinaryAttestationsFacet } from
    "../src/facets/tangle/TangleBlueprintsBinaryAttestationsFacet.sol";
import { BlueprintAuditors } from "../src/governance/BlueprintAuditors.sol";

/// @title UpgradeFlowAddon
/// @notice Deploys the new upgrade-flow surfaces (binary versions, attestations,
///         auditor registry) onto an EXISTING Tangle deployment without going
///         through the full `FullDeploy` path. Two separate broadcasts because
///         the facet registration step needs UPGRADER_ROLE on the Tangle proxy
///         (the admin/timelock) while the rest only needs the deployer EOA.
///
/// Usage:
///   # As the deployer EOA — deploys facet impls + BlueprintAuditors proxy,
///   # prints the registerFacet calldata for the admin to broadcast.
///   PRIVATE_KEY=$DEPLOYER_KEY \
///   TANGLE_PROXY=0xC9b0716a187072be0f38A5D972392C6479b9Cfe3 \
///   ADMIN_BOOTSTRAP=$DEPLOYER_ADDRESS \
///   GOVERNOR=$DEPLOYER_ADDRESS \
///   FIRST_PARTY_ADMIN=$DEPLOYER_ADDRESS \
///   forge script script/UpgradeFlowAddon.s.sol:UpgradeFlowAddon \
///     --rpc-url https://sepolia.base.org --broadcast --slow
contract UpgradeFlowAddon is Script {
    function run() external {
        uint256 deployerKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerKey);
        address tangleProxy = vm.envAddress("TANGLE_PROXY");

        // BlueprintAuditors role layout. Defaults to all-deployer for the
        // testnet bootstrap path so the deployer can admit the first auditors
        // before handing off to the multisig + timelock via `grantRole` /
        // `revokeRole`. Override per env for production.
        address admin = _envAddrOr("ADMIN_BOOTSTRAP", deployer);
        address governor = _envAddrOr("GOVERNOR", deployer);
        address firstPartyAdmin = _envAddrOr("FIRST_PARTY_ADMIN", deployer);

        console2.log("=== Upgrade Flow Addon ===");
        console2.log("Deployer:       ", deployer);
        console2.log("Tangle proxy:   ", tangleProxy);
        console2.log("Auditors admin: ", admin);
        console2.log("Auditors gov:   ", governor);
        console2.log("Auditors FPA:   ", firstPartyAdmin);

        vm.startBroadcast(deployerKey);

        TangleBlueprintsBinaryVersionsFacet versionsFacet =
            new TangleBlueprintsBinaryVersionsFacet();
        console2.log("VersionsFacet:    ", address(versionsFacet));

        TangleBlueprintsBinaryAttestationsFacet attestationsFacet =
            new TangleBlueprintsBinaryAttestationsFacet();
        console2.log("AttestationsFacet:", address(attestationsFacet));

        BlueprintAuditors auditorsImpl = new BlueprintAuditors();
        ERC1967Proxy auditorsProxy = new ERC1967Proxy(
            address(auditorsImpl),
            abi.encodeCall(BlueprintAuditors.initialize, (admin, governor, firstPartyAdmin))
        );
        console2.log("AuditorsImpl:     ", address(auditorsImpl));
        console2.log("AuditorsProxy:    ", address(auditorsProxy));

        vm.stopBroadcast();

        console2.log("");
        console2.log("=== HANDOFF TO ADMIN ===");
        console2.log("The following two calls require UPGRADER_ROLE on the Tangle proxy.");
        console2.log("Run as the admin / timelock signer:");
        console2.log("");
        console2.log("cast send", tangleProxy);
        console2.log('  "registerFacet(address)"', address(versionsFacet));
        console2.log("");
        console2.log("cast send", tangleProxy);
        console2.log('  "registerFacet(address)"', address(attestationsFacet));
    }

    function _envAddrOr(string memory key, address fallbackAddr) internal view returns (address) {
        try vm.envAddress(key) returns (address v) {
            return v;
        } catch {
            return fallbackAddr;
        }
    }
}
