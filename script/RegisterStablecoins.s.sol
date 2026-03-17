// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Script, console2 } from "forge-std/Script.sol";
import { TokenWrapperHandler } from "protocol-solidity/handlers/TokenWrapperHandler.sol";
import { FungibleTokenWrapper } from "protocol-solidity/tokens/FungibleTokenWrapper.sol";

/// @title RegisterStablecoins
/// @notice Registers stablecoins in an already-deployed FungibleTokenWrapper.
///
/// @dev The FungibleTokenWrapper.add() function has an `onlyHandler` modifier,
///      so token registration must go through the TokenWrapperHandler.executeProposal()
///      path. The caller (deployer) must be the bridge address that the handler
///      was initialized with.
///
/// Usage:
///   PRIVATE_KEY=0x... WRAPPER=0x... HANDLER=0x... TOKENS="0x...,0x...,0x..." \
///   forge script script/RegisterStablecoins.s.sol:RegisterStablecoins --rpc-url $RPC --broadcast
contract RegisterStablecoins is Script {
    function run() external {
        uint256 deployerPk = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPk);

        address wrapperAddr = vm.envAddress("WRAPPER");
        address handlerAddr = vm.envAddress("HANDLER");
        string memory tokensStr = vm.envString("TOKENS");

        address[] memory tokens = _parseAddressList(tokensStr);
        require(tokens.length > 0, "RegisterStablecoins: no tokens provided");

        FungibleTokenWrapper wrapper = FungibleTokenWrapper(payable(wrapperAddr));
        TokenWrapperHandler handler = TokenWrapperHandler(handlerAddr);

        // The resourceID for the wrapper must match what was registered in the handler
        bytes32 resourceId = _computeResourceId(wrapperAddr);

        console2.log("=== RegisterStablecoins ===");
        console2.log("Deployer (bridge):", deployer);
        console2.log("FungibleTokenWrapper:", wrapperAddr);
        console2.log("TokenWrapperHandler:", handlerAddr);
        console2.log("Tokens to register:", tokens.length);

        // Read current nonce from the wrapper to determine starting nonce
        // The ProposalNonceTracker in FungibleTokenWrapper tracks nonces
        // We need to query current state. The add() requires onlyIncrementingByOne.
        // Start from the wrapper's current proposalNonce + 1.

        vm.startBroadcast(deployerPk);

        for (uint256 i = 0; i < tokens.length; i++) {
            // Check if already registered
            if (wrapper.valid(tokens[i])) {
                console2.log("  SKIP (already valid):", tokens[i]);
                continue;
            }

            // The nonce must increment by one from the wrapper's current proposalNonce.
            // ProposalNonceTracker stores `proposalNonce` as a public uint32.
            uint32 currentNonce = uint32(wrapper.proposalNonce());
            uint32 nextNonce = currentNonce + 1;

            // Build the proposal data: resourceId + functionSig + nonce + tokenAddress
            bytes memory proposalData = abi.encodePacked(
                resourceId,
                bytes4(keccak256("add(address,uint32)")),
                bytes4(nextNonce),
                bytes20(tokens[i])
            );

            handler.executeProposal(resourceId, proposalData);
            console2.log("  Registered:", tokens[i], "nonce:", nextNonce);
        }

        vm.stopBroadcast();

        console2.log("Done. Registered stablecoins in wrapper.");
    }

    /// @notice Compute a resourceID from a contract address (protocol-solidity convention).
    function _computeResourceId(address contractAddr) internal view returns (bytes32) {
        return bytes32(uint256(uint160(contractAddr)) | (uint256(block.chainid) << 160));
    }

    /// @notice Parse a comma-separated list of addresses.
    function _parseAddressList(string memory csv) internal pure returns (address[] memory) {
        bytes memory csvBytes = bytes(csv);
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
}
