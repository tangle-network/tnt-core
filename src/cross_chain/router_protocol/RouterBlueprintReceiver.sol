// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { IDapp } from "../../vendored/router_protocol/IDapp.sol";
import { BaseBlueprintReceiver } from "../receivers/BaseBlueprintReceiver.sol";

/// @title RouterBlueprintReceiver
/// @notice Blueprint receiver contract for Router Protocol
/// This contract is used to receive and process messages from Router Protocol on the
/// remote chain that accepts restaking assets for Tangle Blueprints. Every blueprint
/// sends messages to this contract to process job results and slash events.
contract RouterBlueprintReceiver is BaseBlueprintReceiver, IDapp {
    // Mapping to track pending requests
    mapping(uint256 => bool) public pendingRequests;

    event AckReceived(uint256 indexed requestIdentifier, bool execFlag, bytes execData);

    function iReceive(
        string memory requestSender,
        bytes memory packet,
        string memory srcChainId
    )
        external
        override
        returns (bytes memory)
    {
        return this.handleCrossChainMessage(_stringToUint32(srcChainId), _stringToBytes32(requestSender), packet);
    }

    function iAck(uint256 requestIdentifier, bool execFlag, bytes memory execData) external override {
        require(pendingRequests[requestIdentifier], "Unknown request");
        delete pendingRequests[requestIdentifier];

        emit AckReceived(requestIdentifier, execFlag, execData);
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
        // Implement Router-specific slash processing
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
        // Implement Router-specific job result processing
        return abi.encode(true);
    }

    // Helper functions
    function _stringToUint32(string memory str) internal pure returns (uint32) {
        bytes memory b = bytes(str);
        uint32 result = 0;
        for (uint256 i = 0; i < b.length; i++) {
            uint8 c = uint8(b[i]);
            if (c >= 48 && c <= 57) {
                result = result * 10 + (c - 48);
            }
        }
        return result;
    }

    function _stringToBytes32(string memory str) internal pure returns (bytes32) {
        bytes memory b = bytes(str);
        bytes32 result;
        assembly {
            result := mload(add(b, 32))
        }
        return result;
    }
}
