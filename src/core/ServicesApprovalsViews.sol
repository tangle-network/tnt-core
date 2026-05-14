// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Base } from "./Base.sol";
import { AttestationLib } from "../libraries/AttestationLib.sol";
import { Types } from "../libraries/Types.sol";
import { Errors } from "../libraries/Errors.sol";
import { PaymentLib } from "../libraries/PaymentLib.sol";
import { ProtocolConfig } from "../config/ProtocolConfig.sol";

/// @title ServicesApprovalsViews
/// @notice Read-only helpers + permissionless request-expiry cleanup.
/// @dev Hosts the view selectors on a dedicated facet so the approvals contract does not
///      drag this bytecode into the activation facet. Shared pure compute lives in
///      `AttestationLib` so the approvals flow and the views facet stay byte-identical.
abstract contract ServicesApprovalsViews is Base {
    event ServiceRequestExpired(uint64 indexed requestId, address indexed expiredBy);

    /// @notice Canonical TEE attestation nonce for `requestId` on this contract on this chain.
    function teeNonceFor(uint64 requestId) external view returns (bytes32) {
        return AttestationLib.teeNonce(requestId, address(this), block.chainid);
    }

    /// @notice Domain-separated message every operator must sign with their BLS secret key
    ///         to register a public key. Bound to chainId + verifying contract + operator
    ///         address so a PoP from one chain or operator cannot be replayed.
    function blsPopMessage(address operator, uint256[4] memory blsPubkey) external view returns (bytes memory) {
        return AttestationLib.blsPopMessage(operator, blsPubkey, address(this), block.chainid);
    }

    /// @notice keccak256 root over an operator's `TeeAttestationCommitment[]` for a service.
    /// @dev Slashing / provisioning oracles supply the original array as a witness and verify
    ///      `keccak256(abi.encode(witness)) == getTeeCommitmentRoot(serviceId, operator)` before
    ///      treating the witness as authoritative. Returns `bytes32(0)` if the operator
    ///      approved without TEE commitments.
    function getTeeCommitmentRoot(uint64 serviceId, address operator) external view returns (bytes32) {
        return _serviceTeeCommitmentRoot[serviceId][operator];
    }

    /// @notice Get operator's BLS public key for a service
    /// @param serviceId The service ID
    /// @param operator The operator address
    /// @return blsPubkey The BLS G2 public key [x0, x1, y0, y1], all zeros if not registered
    function getOperatorBlsPubkey(
        uint64 serviceId,
        address operator
    )
        external
        view
        returns (uint256[4] memory blsPubkey)
    {
        Types.BLSPubkey storage stored = _serviceOperatorBlsPubkeys[serviceId][operator];
        blsPubkey[0] = stored.key[0];
        blsPubkey[1] = stored.key[1];
        blsPubkey[2] = stored.key[2];
        blsPubkey[3] = stored.key[3];
    }

    /// @notice Permissionlessly expire a stale service request and refund the requester.
    /// @dev Anyone can call this once `block.timestamp > req.createdAt + grace`. The grace
    ///      period is `_requestExpiryGracePeriod` (or `ProtocolConfig.REQUEST_EXPIRY_GRACE_PERIOD`
    ///      when unset). Without this path stale unapproved requests would linger indefinitely
    ///      with their payment locked; cleanup is now permissionless and incentive-aligned
    ///      (the requester gets refunded, the caller pays the gas).
    ///      Refund is bounded to requests that were never activated AND never rejected.
    ///      `req.activated` is set inside `_activateService` so an activated request — whose
    ///      `paymentAmount` has already been routed to operators — cannot be drained again.
    function expireServiceRequest(uint64 requestId) external nonReentrant {
        Types.ServiceRequest storage req = _getServiceRequest(requestId);
        if (req.rejected || req.activated) revert Errors.ServiceRequestAlreadyProcessed(requestId);

        uint64 grace = _requestExpiryGracePeriod;
        if (grace == 0) grace = ProtocolConfig.REQUEST_EXPIRY_GRACE_PERIOD;
        if (block.timestamp <= uint256(req.createdAt) + grace) {
            revert Errors.ServiceRequestNotExpired(requestId);
        }

        req.rejected = true;
        PaymentLib.refundPayment(req.requester, req.paymentToken, req.paymentAmount);

        emit ServiceRequestExpired(requestId, msg.sender);
    }
}
