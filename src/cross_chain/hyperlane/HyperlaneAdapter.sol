// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { IMessageRecipient } from "../../vendored/hyperlane/IMessageRecipient.sol";
import { ICrossChainReceiver } from "../../interfaces/ICrossChainReceiver.sol";
import { ICrossChainDelegatorMessage } from "../../interfaces/ICrossChainDelegatorMessage.sol";
import { CrossChainDelegatorMessage } from "../../libs/CrossChainDelegatorMessage.sol";

/// @title HyperlaneAdapter
/// @notice Adapts Hyperlane messages to standard cross-chain message format
contract HyperlaneAdapter is IMessageRecipient {
    using CrossChainDelegatorMessage for ICrossChainDelegatorMessage.DepositMessage;

    ICrossChainReceiver public immutable receiver;

    uint256 public constant BRIDGE_ID = 1;

    constructor(address _receiver) {
        require(_receiver != address(0), "Invalid receiver");
        receiver = ICrossChainReceiver(_receiver);
    }

    /// @inheritdoc IMessageRecipient
    function handle(uint32 _origin, bytes32 _sender, bytes calldata _message) external payable returns (bytes memory) {
        return receiver.handleCrossChainMessage(_origin, _sender, _message);
    }
}
