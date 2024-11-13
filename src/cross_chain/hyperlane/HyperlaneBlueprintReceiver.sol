// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { IMailbox } from "../../vendored/hyperlane/IMailbox.sol";
import { IMessageRecipient } from "../../vendored/hyperlane/IMessageRecipient.sol";
import { TypeCasts } from "../../vendored/hyperlane/TypeCasts.sol";
import { BaseBlueprintReceiver } from "../BaseBlueprintReceiver.sol";

/// @title HyperlaneBlueprintReceiver
/// @notice Blueprint receiver contract for Hyperlane
/// This contract is used to receive and process messages from Hyperlane on the
/// remote chain that accepts restaking assets for Tangle Blueprints. Every blueprint
/// sends messages to this contract to process job results and slash events.
contract HyperlaneBlueprintReceiver is BaseBlueprintReceiver, IMessageRecipient {
    using TypeCasts for bytes32;
    using TypeCasts for address;

    IMailbox public immutable mailbox;

    constructor(address _mailbox) {
        require(_mailbox != address(0), "Invalid mailbox");
        mailbox = IMailbox(_mailbox);
    }

    modifier onlyMailbox() {
        require(msg.sender == address(mailbox), "Only mailbox can call");
        _;
    }

    /**
     * @notice Handle an interchain message
     * @param _origin Domain ID of origin chain
     * @param _sender Address of sender on origin chain as bytes32
     * @param _message Raw bytes content of message
     */
    function handle(
        uint32 _origin,
        bytes32 _sender,
        bytes calldata _message
    )
        external
        payable
        override
        onlyMailbox
        returns (bytes memory)
    {
        return this.handleCrossChainMessage(_origin, _sender, _message);
    }

    function _processSlashEvent(
        uint64 serviceId,
        bytes memory offender,
        uint8 slashPercent,
        uint256 totalPayout
    )
        internal
        virtual
        override
        returns (bytes memory)
    {
        // Implement Hyperlane-specific slash processing
        return abi.encode(true);
    }

    function _processJobResultEvent(
        uint64 serviceId,
        uint8 job,
        uint64 jobCallId,
        bytes memory participant,
        bytes memory inputs,
        bytes memory outputs
    )
        internal
        virtual
        override
        returns (bytes memory)
    {
        // Implement Hyperlane-specific job result processing
        return abi.encode(true);
    }
}
