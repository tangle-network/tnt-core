// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BlueprintServiceManagerBase } from "../../src/BlueprintServiceManagerBase.sol";
import { Types } from "../../src/libraries/Types.sol";

/// @title MockBinaryHookBSM
/// @notice Test BSM that records every binary-version hook invocation so tests
///         can assert msg.sender identity and call ordering.
/// @dev Inherits `onlyFromTangle` enforcement from the base - this is the same
///      modifier production BSMs use. Tests pin their assertions to that.
contract MockBinaryHookBSM is BlueprintServiceManagerBase {
    struct PublishCall {
        uint64 blueprintId;
        uint64 versionId;
        bytes32 sha256Hash;
        string binaryUri;
        bytes32 attestationHash;
        address senderAtCall;
    }

    struct AckCall {
        uint64 serviceId;
        uint64 versionId;
        address operator;
        address senderAtCall;
    }

    PublishCall[] private _publishCalls;
    AckCall[] private _ackCalls;

    /// @notice When set, `onBinaryVersionPublished` reverts. Used to assert the
    ///         hook's revert does NOT roll back the on-chain version row.
    bool public revertOnPublish;
    /// @notice When set, `onBinaryVersionPublished` reverts only if attestationHash is zero.
    bool public requireAttestation;
    /// @notice When set, `onOperatorBinaryAcked` reverts.
    bool public revertOnAck;
    /// @notice Custom revert message for revert-tracking.
    string public revertReason = "MockBinaryHookBSM: forced revert";

    function setRevertOnPublish(bool v) external {
        revertOnPublish = v;
    }

    function setRequireAttestation(bool v) external {
        requireAttestation = v;
    }

    function setRevertOnAck(bool v) external {
        revertOnAck = v;
    }

    function publishCallCount() external view returns (uint256) {
        return _publishCalls.length;
    }

    function ackCallCount() external view returns (uint256) {
        return _ackCalls.length;
    }

    function publishCallAt(uint256 i) external view returns (PublishCall memory) {
        return _publishCalls[i];
    }

    function ackCallAt(uint256 i) external view returns (AckCall memory) {
        return _ackCalls[i];
    }

    function onBinaryVersionPublished(
        uint64 blueprintId,
        Types.BinaryVersion calldata version
    )
        external
        override
        onlyFromTangle
    {
        if (revertOnPublish || (requireAttestation && version.attestationHash == bytes32(0))) {
            revert(revertReason);
        }
        _publishCalls.push(
            PublishCall({
                blueprintId: blueprintId,
                versionId: version.versionId,
                sha256Hash: version.sha256Hash,
                binaryUri: version.binaryUri,
                attestationHash: version.attestationHash,
                senderAtCall: msg.sender
            })
        );
    }

    function onOperatorBinaryAcked(
        uint64 serviceId,
        uint64 versionId,
        address operator
    )
        external
        override
        onlyFromTangle
    {
        if (revertOnAck) {
            revert(revertReason);
        }
        _ackCalls.push(
            AckCall({ serviceId: serviceId, versionId: versionId, operator: operator, senderAtCall: msg.sender })
        );
    }
}
