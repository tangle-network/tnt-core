// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { ICrossChainDepositMessage } from "../../interfaces/ICrossChainDepositMessage.sol";

/// @title CrossChainDepositMessage
/// @notice Library for handling cross-chain message encoding/decoding
library CrossChainDepositMessage {
    function encode(ICrossChainDepositMessage.AssetMessage memory message) internal pure returns (bytes memory) {
        return abi.encode(message);
    }

    function decode(bytes memory data) internal pure returns (ICrossChainDepositMessage.AssetMessage memory) {
        return abi.decode(data, (ICrossChainDepositMessage.AssetMessage));
    }

    function bytes32ToAddress(bytes32 _buf) internal pure returns (address) {
        return address(uint160(uint256(_buf)));
    }
}
