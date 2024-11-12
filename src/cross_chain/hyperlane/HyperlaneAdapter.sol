// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { IMessageRecipient } from "../../vendored/hyperlane/IMessageRecipient.sol";
import { ICrossChainReceiver } from "../../interfaces/ICrossChainReceiver.sol";
import { ICrossChainDepositMessage } from "../../interfaces/ICrossChainDepositMessage.sol";
import { CrossChainDepositMessage } from "../../libs/CrossChainDepositMessage.sol";

/// @title HyperlaneAdapter
/// @notice Adapts Hyperlane messages to standard cross-chain message format
contract HyperlaneAdapter is IMessageRecipient {
    using CrossChainDepositMessage for ICrossChainDepositMessage.AssetMessage;

    ICrossChainReceiver public immutable receiver;

    uint256 public constant BRIDGE_ID = 1;

    constructor(address _receiver) {
        require(_receiver != address(0), "Invalid receiver");
        receiver = ICrossChainReceiver(_receiver);
    }

    /// @inheritdoc IMessageRecipient
    function handle(uint32 _origin, bytes32 _sender, bytes calldata _message) external payable returns (bytes memory) {
        // Decode the incoming Hyperlane message format
        (uint256 originAsset, uint256 amount, bytes memory delegateData) = abi.decode(_message, (uint256, uint256, bytes));

        // Create structured message
        ICrossChainDepositMessage.AssetMessage memory assetMessage = ICrossChainDepositMessage.AssetMessage({
            bridgeId: BRIDGE_ID,
            originAsset: originAsset,
            amount: amount,
            sender: _sender,
            delegateData: delegateData
        });

        return receiver.handleCrossChainMessage(_origin, _sender, assetMessage.encode());
    }
}
