// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { IMailbox } from "../../vendored/hyperlane/IMailbox.sol";
import { IMessageRecipient } from "../../vendored/hyperlane/IMessageRecipient.sol";
import { ICrossChainReceiver } from "../../interfaces/ICrossChainReceiver.sol";
import { ICrossChainDelegatorMessage } from "../../interfaces/ICrossChainDelegatorMessage.sol";
import { CrossChainDelegatorMessage } from "../../libs/CrossChainDelegatorMessage.sol";

/// @title HyperlaneAdapter
/// @notice Adapts Hyperlane messages to standard cross-chain message format
contract HyperlaneAdapter is IMessageRecipient {
    using CrossChainDelegatorMessage for ICrossChainDelegatorMessage.DepositMessage;

    ICrossChainReceiver public immutable receiver;
    IMailbox public immutable mailbox;

    uint256 public constant BRIDGE_ID = 1;

    modifier onlyMailbox() {
        require(msg.sender == address(mailbox), "Only mailbox can call");
        _;
    }

    constructor(address _receiver, address _mailbox) {
        require(_receiver != address(0), "Invalid receiver");
        require(_mailbox != address(0), "Invalid mailbox");
        receiver = ICrossChainReceiver(_receiver);
        mailbox = IMailbox(_mailbox);
    }

    /// @inheritdoc IMessageRecipient
    function handle(uint32 _origin, bytes32 _sender, bytes calldata _message) external payable onlyMailbox returns (bytes memory) {
        return receiver.handleCrossChainMessage(_origin, _sender, _message);
    }
}
