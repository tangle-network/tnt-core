// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Script, console2 } from "forge-std/Script.sol";
import { stdJson } from "forge-std/StdJson.sol";

import { ShieldedGateway } from "../src/shielded/ShieldedGateway.sol";
import { ShieldedCredits } from "../src/shielded/ShieldedCredits.sol";

// protocol-solidity contracts (audited, unmodified)
import { PoseidonHasher } from "protocol-solidity/hashers/PoseidonHasher.sol";
import { VAnchorVerifier } from "protocol-solidity/verifiers/VAnchorVerifier.sol";
import { VAnchorTree } from "protocol-solidity/vanchors/instances/VAnchorTree.sol";
import { FungibleTokenWrapper } from "protocol-solidity/tokens/FungibleTokenWrapper.sol";
import { TokenWrapperHandler } from "protocol-solidity/handlers/TokenWrapperHandler.sol";
import { AnchorHandler } from "protocol-solidity/handlers/AnchorHandler.sol";

import { IAnchorVerifier } from "protocol-solidity/interfaces/verifiers/IAnchorVerifier.sol";
import { IHasher } from "protocol-solidity/hashers/IHasher.sol";
import {
    IVAnchorVerifier2_2,
    IVAnchorVerifier2_16,
    IVAnchorVerifier8_2,
    IVAnchorVerifier8_16
} from "protocol-solidity/interfaces/verifiers/IVAnchorVerifier.sol";

/// @title DeployShieldedPool
/// @notice Deploys the complete VAnchor shielded pool stack for Base Sepolia or Base mainnet.
///
/// @dev Deployment order:
///      1. Poseidon libraries (T2-T6) — pre-deployed, addresses passed via env vars
///      2. PoseidonHasher — links to pre-deployed Poseidon libraries
///      3. Sub-verifiers (Verifier2_2, Verifier2_16, Verifier8_2, Verifier8_16) — pre-deployed
///      4. VAnchorVerifier — routes to sub-verifiers
///      5. TokenWrapperHandler — bridge=deployer initially for setup
///      6. FungibleTokenWrapper — handler=tokenWrapperHandler
///      7. AnchorHandler — bridge=deployer initially for setup
///      8. VAnchorTree — the shielded pool
///      9. Register stablecoins in wrapper via handler
///     10. ShieldedCredits + ShieldedGateway
///     11. Register pool in gateway
///
/// @dev Poseidon libraries require bytecode injection from circomlibjs.
///      Deploy them first using the TypeScript tooling, then pass addresses as env vars.
///      See: scripts/trusted-setup/ceremony.sh for circuit compilation.
///
/// Usage (config file):
///   PRIVATE_KEY=0x... SHIELDED_CONFIG=script/deploy-config/base-sepolia-shielded.json \
///   forge script script/DeployShieldedPool.s.sol:DeployShieldedPool --rpc-url $RPC --broadcast --slow
///
/// Usage (env vars only):
///   PRIVATE_KEY=0x... TANGLE=0x... POSEIDON_T2=0x... POSEIDON_T3=0x... POSEIDON_T4=0x... \
///   POSEIDON_T5=0x... POSEIDON_T6=0x... VERIFIER_2_2=0x... VERIFIER_2_16=0x... \
///   VERIFIER_8_2=0x... VERIFIER_8_16=0x... MERKLE_TREE_LEVELS=30 MAX_EDGES=1 \
///   STABLECOINS="0x...,0x..." WRAPPING_LIMIT=1000000000000 \
///   forge script script/DeployShieldedPool.s.sol:DeployShieldedPool --rpc-url $RPC --broadcast --slow
contract DeployShieldedPool is Script {
    using stdJson for string;

    // Deployment results
    address public poseidonHasher;
    address public vanchorVerifier;
    address public tokenWrapperHandler;
    address public fungibleTokenWrapper;
    address public anchorHandler;
    address public vanchorTree;
    address public shieldedCredits;
    address public shieldedGateway;

    function run() external {
        uint256 deployerPk = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPk);

        // Load config from JSON file if provided, otherwise use env vars
        string memory configPath = vm.envOr("SHIELDED_CONFIG", string(""));
        bool hasConfig = bytes(configPath).length > 0;
        string memory json;
        if (hasConfig) {
            json = vm.readFile(configPath);
        }

        // --- Required external addresses ---
        address tangle = hasConfig
            ? json.readAddress(".tangle")
            : vm.envAddress("TANGLE");
        address gatewayOwner = hasConfig
            ? _jsonAddressOr(json, ".gatewayOwner", deployer)
            : vm.envOr("GATEWAY_OWNER", deployer);
        address feeRecipient = hasConfig
            ? _jsonAddressOr(json, ".feeRecipient", deployer)
            : vm.envOr("FEE_RECIPIENT", deployer);

        // --- Pre-deployed Poseidon library addresses (from circomlibjs) ---
        address poseidonT2 = hasConfig
            ? json.readAddress(".poseidon.T2")
            : vm.envAddress("POSEIDON_T2");
        address poseidonT3 = hasConfig
            ? json.readAddress(".poseidon.T3")
            : vm.envAddress("POSEIDON_T3");
        address poseidonT4 = hasConfig
            ? json.readAddress(".poseidon.T4")
            : vm.envAddress("POSEIDON_T4");
        address poseidonT5 = hasConfig
            ? json.readAddress(".poseidon.T5")
            : vm.envAddress("POSEIDON_T5");
        address poseidonT6 = hasConfig
            ? json.readAddress(".poseidon.T6")
            : vm.envAddress("POSEIDON_T6");

        // --- Pre-deployed verifier addresses (from trusted setup ceremony) ---
        address verifier2_2 = hasConfig
            ? json.readAddress(".verifiers.v2_2")
            : vm.envAddress("VERIFIER_2_2");
        address verifier2_16 = hasConfig
            ? json.readAddress(".verifiers.v2_16")
            : vm.envAddress("VERIFIER_2_16");
        address verifier8_2 = hasConfig
            ? json.readAddress(".verifiers.v8_2")
            : vm.envAddress("VERIFIER_8_2");
        address verifier8_16 = hasConfig
            ? json.readAddress(".verifiers.v8_16")
            : vm.envAddress("VERIFIER_8_16");

        // --- Pool parameters ---
        uint32 merkleTreeLevels = uint32(hasConfig
            ? json.readUint(".merkleTreeLevels")
            : vm.envOr("MERKLE_TREE_LEVELS", uint256(30)));
        uint8 maxEdges = uint8(hasConfig
            ? json.readUint(".maxEdges")
            : vm.envOr("MAX_EDGES", uint256(1)));
        uint256 wrappingLimit = hasConfig
            ? json.readUint(".wrappingLimit")
            : vm.envOr("WRAPPING_LIMIT", uint256(1_000_000_000e6));
        uint16 feePercentage = uint16(hasConfig
            ? json.readUint(".feePercentage")
            : vm.envOr("FEE_PERCENTAGE", uint256(0)));
        bool isNativeAllowed = hasConfig
            ? json.readBool(".isNativeAllowed")
            : vm.envOr("IS_NATIVE_ALLOWED", false);

        // --- Stablecoins to register ---
        address[] memory stablecoins;
        if (hasConfig) {
            stablecoins = json.readAddressArray(".stablecoins");
        } else {
            string memory stablecoinsStr = vm.envOr("STABLECOINS", string(""));
            if (bytes(stablecoinsStr).length > 0) {
                stablecoins = _parseAddressList(stablecoinsStr);
            }
        }

        // --- Validate ---
        require(tangle != address(0), "DeployShieldedPool: TANGLE required");
        require(poseidonT2 != address(0), "DeployShieldedPool: POSEIDON_T2 required");
        require(poseidonT3 != address(0), "DeployShieldedPool: POSEIDON_T3 required");
        require(verifier2_2 != address(0), "DeployShieldedPool: VERIFIER_2_2 required");

        console2.log("=== DeployShieldedPool ===");
        console2.log("Deployer:", deployer);
        console2.log("Tangle:", tangle);
        console2.log("Chain ID:", block.chainid);

        vm.startBroadcast(deployerPk);

        // Step 1: Deploy PoseidonHasher
        // The PoseidonHasher contract references PoseidonT2-T6 libraries.
        // These libraries must be pre-deployed and linked via forge's --libraries flag
        // or deployed as part of the circomlibjs setup.
        // For this script, we assume the PoseidonHasher is deployed with linked libraries.
        poseidonHasher = _deployPoseidonHasher(poseidonT2, poseidonT3, poseidonT4, poseidonT5, poseidonT6);
        console2.log("PoseidonHasher:", poseidonHasher);

        // Step 2: Deploy VAnchorVerifier (routes proofs to correct sub-verifier)
        vanchorVerifier = address(new VAnchorVerifier(
            IVAnchorVerifier2_2(verifier2_2),
            IVAnchorVerifier2_16(verifier2_16),
            IVAnchorVerifier8_2(verifier8_2),
            IVAnchorVerifier8_16(verifier8_16)
        ));
        console2.log("VAnchorVerifier:", vanchorVerifier);

        // Step 3: Deploy TokenWrapperHandler with deployer as bridge (for initial setup)
        bytes32[] memory emptyResourceIds = new bytes32[](0);
        address[] memory emptyAddresses = new address[](0);
        tokenWrapperHandler = address(new TokenWrapperHandler(
            deployer, // deployer acts as bridge during setup
            emptyResourceIds,
            emptyAddresses
        ));
        console2.log("TokenWrapperHandler:", tokenWrapperHandler);

        // Step 4: Deploy FungibleTokenWrapper
        FungibleTokenWrapper wrapper = new FungibleTokenWrapper("Tangle Shielded USD", "tsUSD");
        wrapper.initialize(
            feePercentage,
            payable(feeRecipient),
            tokenWrapperHandler,
            wrappingLimit,
            isNativeAllowed,
            deployer // admin for minting rights
        );
        fungibleTokenWrapper = address(wrapper);
        console2.log("FungibleTokenWrapper:", fungibleTokenWrapper);

        // Step 5: Register FungibleTokenWrapper as a resource in TokenWrapperHandler
        bytes32 wrapperResourceId = _computeResourceId(fungibleTokenWrapper);
        TokenWrapperHandler(tokenWrapperHandler).setResource(wrapperResourceId, fungibleTokenWrapper);

        // Step 6: Register stablecoins via TokenWrapperHandler
        for (uint256 i = 0; i < stablecoins.length; i++) {
            // Build the proposal data for add(address,uint32)
            uint32 nonce = uint32(i + 1);
            bytes memory proposalData = abi.encodePacked(
                wrapperResourceId,
                bytes4(keccak256("add(address,uint32)")),
                bytes4(nonce),
                bytes20(stablecoins[i])
            );
            TokenWrapperHandler(tokenWrapperHandler).executeProposal(wrapperResourceId, proposalData);
            console2.log("  Registered stablecoin:", stablecoins[i]);
        }

        // Step 7: Deploy AnchorHandler with deployer as bridge
        anchorHandler = address(new AnchorHandler(
            deployer,
            emptyResourceIds,
            emptyAddresses
        ));
        console2.log("AnchorHandler:", anchorHandler);

        // Step 8: Deploy VAnchorTree
        vanchorTree = address(new VAnchorTree(
            IAnchorVerifier(vanchorVerifier),
            merkleTreeLevels,
            IHasher(poseidonHasher),
            anchorHandler,
            fungibleTokenWrapper,
            maxEdges
        ));
        console2.log("VAnchorTree:", vanchorTree);

        // Step 9: Register VAnchorTree in AnchorHandler
        bytes32 anchorResourceId = _computeResourceId(vanchorTree);
        AnchorHandler(anchorHandler).setResource(anchorResourceId, vanchorTree);

        // Step 10: Deploy ShieldedCredits
        ShieldedCredits credits = new ShieldedCredits();
        shieldedCredits = address(credits);
        console2.log("ShieldedCredits:", shieldedCredits);

        // Step 11: Deploy ShieldedGateway and register the pool
        ShieldedGateway gateway = new ShieldedGateway(tangle, shieldedCredits, gatewayOwner);
        shieldedGateway = address(gateway);
        console2.log("ShieldedGateway:", shieldedGateway);

        gateway.registerPool(fungibleTokenWrapper, vanchorTree);
        console2.log("  Registered pool: wrapper", fungibleTokenWrapper, "=> anchor", vanchorTree);

        vm.stopBroadcast();

        // --- Summary ---
        console2.log("\n=== Deployment Summary ===");
        console2.log("PoseidonHasher:         ", poseidonHasher);
        console2.log("VAnchorVerifier:        ", vanchorVerifier);
        console2.log("TokenWrapperHandler:    ", tokenWrapperHandler);
        console2.log("FungibleTokenWrapper:   ", fungibleTokenWrapper);
        console2.log("AnchorHandler:          ", anchorHandler);
        console2.log("VAnchorTree:            ", vanchorTree);
        console2.log("ShieldedCredits:        ", shieldedCredits);
        console2.log("ShieldedGateway:        ", shieldedGateway);
        console2.log("Stablecoins registered: ", stablecoins.length);
    }

    /// @notice Deploy PoseidonHasher with pre-deployed Poseidon library bytecode.
    /// @dev Poseidon libraries (T2-T6) have no constructor args — their bytecode is
    ///      generated by circomlibjs and deployed as standalone contracts. The PoseidonHasher
    ///      contract links to these libraries at compile time via forge's --libraries flag.
    ///      Pass the pre-deployed addresses when running:
    ///        forge script ... --libraries \
    ///          "protocol-solidity/hashers/Poseidon.sol:PoseidonT2:$POSEIDON_T2" \
    ///          "protocol-solidity/hashers/Poseidon.sol:PoseidonT3:$POSEIDON_T3" \
    ///          "protocol-solidity/hashers/Poseidon.sol:PoseidonT4:$POSEIDON_T4" \
    ///          "protocol-solidity/hashers/Poseidon.sol:PoseidonT5:$POSEIDON_T5" \
    ///          "protocol-solidity/hashers/Poseidon.sol:PoseidonT6:$POSEIDON_T6"
    function _deployPoseidonHasher(
        address, /* poseidonT2 */
        address, /* poseidonT3 */
        address, /* poseidonT4 */
        address, /* poseidonT5 */
        address  /* poseidonT6 */
    ) internal returns (address) {
        // The PoseidonHasher deployment relies on forge library linking.
        // The Poseidon library addresses are passed via --libraries flag at the CLI level.
        PoseidonHasher hasher = new PoseidonHasher();
        return address(hasher);
    }

    /// @notice Compute a resourceID from a contract address (protocol-solidity convention).
    /// @dev ResourceID = bytes32(chainId << 160 | address) — used by handler contracts.
    function _computeResourceId(address contractAddr) internal view returns (bytes32) {
        return bytes32(uint256(uint160(contractAddr)) | (uint256(block.chainid) << 160));
    }

    /// @notice Parse a comma-separated list of addresses.
    function _parseAddressList(string memory csv) internal pure returns (address[] memory) {
        bytes memory csvBytes = bytes(csv);

        // Count commas to determine array size
        uint256 count = 1;
        for (uint256 i = 0; i < csvBytes.length; i++) {
            if (csvBytes[i] == ",") count++;
        }

        address[] memory result = new address[](count);
        uint256 start = 0;
        uint256 idx = 0;

        for (uint256 i = 0; i <= csvBytes.length; i++) {
            if (i == csvBytes.length || csvBytes[i] == ",") {
                bytes memory addrBytes = new bytes(i - start);
                for (uint256 j = start; j < i; j++) {
                    addrBytes[j - start] = csvBytes[j];
                }
                result[idx] = vm.parseAddress(string(addrBytes));
                idx++;
                start = i + 1;
            }
        }

        return result;
    }

    /// @notice Read an address from JSON, falling back to a default.
    function _jsonAddressOr(string memory json, string memory key, address fallback_) internal view returns (address) {
        try this._tryReadAddress(json, key) returns (address val) {
            return val;
        } catch {
            return fallback_;
        }
    }

    /// @notice External wrapper for json.readAddress to use in try/catch.
    function _tryReadAddress(string calldata json, string calldata key) external view returns (address) {
        return json.readAddress(key);
    }
}
