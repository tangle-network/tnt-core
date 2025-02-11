// // SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.18;

// import { GlacisClientCalldata } from "./GlacisClientCalldata.sol";

// /// @title BaseBlueprintReceiver
// /// @notice Base contract for receiving cross-chain messages from Tangle Blueprints
// /// This contract lives on the remote chain and accepts messages from Tangle Blueprints.
// abstract contract BaseBlueprintReceiver is GlacisClientCalldata {
//     /// Event types
//     uint8 constant SLASH_EVENT = 1;
//     uint8 constant JOB_RESULT_EVENT = 2;

//     /// Events for specific message types
//     event SlashEventReceived(uint64 serviceId, bytes offender, uint8 slashPercent, uint256 totalPayout);
//     event JobResultReceived(uint64 serviceId, uint8 job, uint64 jobCallId, bytes participant, bytes inputs, bytes outputs);

//     constructor(address _glacisRouter, uint256 _quorum) GlacisClientCalldata(_glacisRouter, _quorum) { }

//     /// @dev Implementation of ICrossChainReceiver.handleCrossChainMessage
//     function _receiveMessage(address[] memory, uint256, bytes32, bytes calldata payload) internal override {
//         /// First byte indicates message type
//         require(payload.length > 0, "Empty message");
//         uint8 messageType = uint8(payload[0]);
//         bytes memory messageData = payload[1:];

//         if (messageType == SLASH_EVENT) {
//             _handleSlashEvent(messageData);
//             return;
//         } else if (messageType == JOB_RESULT_EVENT) {
//             _handleJobResultEvent(messageData);
//             return;
//         }

//         revert("Unknown message type");
//     }

//     function _handleSlashEvent(bytes memory eventData) internal virtual {
//         (uint64 serviceId, bytes memory offender, uint8 slashPercent, uint256 totalPayout) =
//             abi.decode(eventData, (uint64, bytes, uint8, uint256));

//         emit SlashEventReceived(serviceId, offender, slashPercent, totalPayout);

//         _processSlashEvent(serviceId, offender, slashPercent, totalPayout);
//     }

//     function _handleJobResultEvent(bytes memory eventData) internal virtual returns (bytes memory) {
//         (uint64 serviceId, uint8 job, uint64 jobCallId, bytes memory participant, bytes memory inputs, bytes memory outputs) =
//             abi.decode(eventData, (uint64, uint8, uint64, bytes, bytes, bytes));

//         emit JobResultReceived(serviceId, job, jobCallId, participant, inputs, outputs);

//         return _processJobResultEvent(serviceId, job, jobCallId, participant, inputs, outputs);
//     }

//     function _processSlashEvent(
//         uint64 serviceId,
//         bytes memory offender,
//         uint8 slashPercent,
//         uint256 totalPayout
//     )
//         internal
//         virtual
//         returns (bytes memory);

//     function _processJobResultEvent(
//         uint64 serviceId,
//         uint8 job,
//         uint64 jobCallId,
//         bytes memory participant,
//         bytes memory inputs,
//         bytes memory outputs
//     )
//         internal
//         virtual
//         returns (bytes memory);
// }
