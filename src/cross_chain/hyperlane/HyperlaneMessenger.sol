// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { ICrossChainMessenger } from "../../interfaces/ICrossChainMessenger.sol";
import { IMailbox } from "../../vendored/hyperlane/IMailbox.sol";

contract HyperlaneMessenger is ICrossChainMessenger {
    IMailbox public immutable mailbox;

    constructor(address _mailbox) {
        require(_mailbox != address(0), "Invalid mailbox address");
        mailbox = IMailbox(_mailbox);
    }

    function quoteMessageFee(
        uint32 destinationChainId,
        bytes32 recipient,
        bytes calldata message
    )
        external
        view
        override
        returns (uint256)
    {
        return mailbox.quoteDispatch(destinationChainId, recipient, message);
    }

    function sendMessage(
        uint32 destinationChainId,
        bytes32 recipient,
        bytes calldata message
    )
        external
        payable
        override
        returns (bytes32)
    {
        return mailbox.dispatch{ value: msg.value }(destinationChainId, recipient, message);
    }
}
