// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { IDapp } from "../../vendored/router_protocol/IDapp.sol";
import { ICrossChainReceiver } from "../../interfaces/ICrossChainReceiver.sol";
import { ICrossChainDelegatorMessage } from "../../interfaces/ICrossChainDelegatorMessage.sol";
import { CrossChainDelegatorMessage } from "../../libs/CrossChainDelegatorMessage.sol";

/// @title RouterAdapter
/// @notice Adapts Router Protocol messages to standard cross-chain message format
contract RouterAdapter is IDapp {
    using CrossChainDelegatorMessage for ICrossChainDelegatorMessage.DepositMessage;

    ICrossChainReceiver public immutable receiver;

    uint256 public constant BRIDGE_ID = 2;

    constructor(address _receiver) {
        require(_receiver != address(0), "Invalid receiver");
        receiver = ICrossChainReceiver(_receiver);
    }

    function iReceive(string memory requestSender, bytes memory packet, string memory srcChainId) external returns (bytes memory) {
        return receiver.handleCrossChainMessage(_parseChainId(srcChainId), _convertSender(requestSender), packet);
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
