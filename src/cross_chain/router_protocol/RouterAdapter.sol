// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { IDapp } from "../../vendored/router_protocol/IDapp.sol";
import { ICrossChainReceiver } from "../../interfaces/ICrossChainReceiver.sol";
import { ICrossChainDepositMessage } from "../../interfaces/ICrossChainDepositMessage.sol";
import { CrossChainDepositMessage } from "../libs/CrossChainDepositMessage.sol";

/// @title RouterAdapter
/// @notice Adapts Router Protocol messages to standard cross-chain message format
contract RouterAdapter is IDapp {
    using CrossChainDepositMessage for ICrossChainDepositMessage.AssetMessage;

    ICrossChainReceiver public immutable receiver;

    uint256 public constant BRIDGE_ID = 2;

    constructor(address _receiver) {
        require(_receiver != address(0), "Invalid receiver");
        receiver = ICrossChainReceiver(_receiver);
    }

    function iReceive(string memory requestSender, bytes memory packet, string memory srcChainId) external returns (bytes memory) {
        // Decode Router Protocol packet
        (uint256 originAsset, uint256 amount, bytes memory delegateData) = abi.decode(packet, (uint256, uint256, bytes));

        // Create structured message
        ICrossChainDepositMessage.AssetMessage memory assetMessage = ICrossChainDepositMessage.AssetMessage({
            bridgeId: BRIDGE_ID,
            originAsset: originAsset,
            amount: amount,
            sender: _convertSender(requestSender),
            delegateData: delegateData
        });

        return receiver.handleCrossChainMessage(_parseChainId(srcChainId), _convertSender(requestSender), assetMessage.encode());
    }

    function iAck(uint256 requestIdentifier, bool execFlag, bytes memory execData) external { }

    function _parseChainId(string memory chainId) internal pure returns (uint32) {
        return uint32(_parseInt(chainId));
    }

    function _convertSender(string memory sender) internal pure returns (bytes32) {
        return bytes32(bytes(sender));
    }

    function _parseInt(string memory value) internal pure returns (uint256) {
        bytes memory b = bytes(value);
        uint256 result = 0;
        for (uint256 i = 0; i < b.length; i++) {
            uint8 c = uint8(b[i]);
            if (c >= 48 && c <= 57) {
                result = result * 10 + (c - 48);
            }
        }
        return result;
    }
}
