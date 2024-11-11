// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { ICrossChainReceiver } from "../../interfaces/ICrossChainReceiver.sol";

abstract contract BaseBlueprintReceiver is ICrossChainReceiver {
    // Event types
    uint8 constant SLASH_EVENT = 1;
    uint8 constant JOB_RESULT_EVENT = 2;

    // Events for specific message types
    event SlashEventReceived(uint64 serviceId, bytes offender, uint8 slashPercent, uint256 totalPayout);

    event JobResultReceived(uint64 serviceId, uint8 job, uint64 jobCallId, bytes participant, bytes inputs, bytes outputs);

    // Trusted senders mapping
    mapping(uint32 => mapping(bytes32 => bool)) public trustedSenders;

    /**
     * @dev Modifier to check if sender is trusted
     */
    modifier onlyTrustedSender(uint32 originChainId, bytes32 sender) {
        require(trustedSenders[originChainId][sender], "Untrusted sender");
        _;
    }

    /**
     * @dev Add a trusted sender
     */
    function addTrustedSender(uint32 chainId, bytes32 sender) external virtual {
        trustedSenders[chainId][sender] = true;
    }

    /**
     * @dev Implementation of ICrossChainReceiver.handleCrossChainMessage
     */
    function handleCrossChainMessage(
        uint32 originChainId,
        bytes32 sender,
        bytes calldata message
    )
        external
        payable
        override
        onlyTrustedSender(originChainId, sender)
        returns (bytes memory)
    {
        emit MessageReceived(originChainId, sender, message);

        // First byte indicates message type
        require(message.length > 0, "Empty message");
        uint8 messageType = uint8(message[0]);
        bytes memory messageData = message[1:];

        if (messageType == SLASH_EVENT) {
            return _handleSlashEvent(messageData);
        } else if (messageType == JOB_RESULT_EVENT) {
            return _handleJobResultEvent(messageData);
        }

        revert("Unknown message type");
    }

    function _handleSlashEvent(bytes memory eventData) internal virtual returns (bytes memory) {
        (uint64 serviceId, bytes memory offender, uint8 slashPercent, uint256 totalPayout) =
            abi.decode(eventData, (uint64, bytes, uint8, uint256));

        emit SlashEventReceived(serviceId, offender, slashPercent, totalPayout);

        return _processSlashEvent(serviceId, offender, slashPercent, totalPayout);
    }

    function _handleJobResultEvent(bytes memory eventData) internal virtual returns (bytes memory) {
        (uint64 serviceId, uint8 job, uint64 jobCallId, bytes memory participant, bytes memory inputs, bytes memory outputs) =
            abi.decode(eventData, (uint64, uint8, uint64, bytes, bytes, bytes));

        emit JobResultReceived(serviceId, job, jobCallId, participant, inputs, outputs);

        return _processJobResultEvent(serviceId, job, jobCallId, participant, inputs, outputs);
    }

    function _processSlashEvent(
        uint64 serviceId,
        bytes memory offender,
        uint8 slashPercent,
        uint256 totalPayout
    )
        internal
        virtual
        returns (bytes memory);

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
        returns (bytes memory);
}
