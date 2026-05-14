// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { AttestationLib } from "./AttestationLib.sol";
import { BN254 } from "./BN254.sol";
import { Errors } from "./Errors.sol";
import { Types } from "./Types.sol";

library ServiceValidationLib {
    uint256 internal constant MAX_TEE_COMMITMENTS_PER_OPERATOR = 8;
    uint64 internal constant MAX_TEE_COMMITMENT_TTL = 90 days;

    function validateTeeCommitments(
        uint64,
        Types.TeeAttestationCommitment[] calldata teeCommitments,
        bytes32 expectedNonce
    )
        external
        view
    {
        if (teeCommitments.length > MAX_TEE_COMMITMENTS_PER_OPERATOR) {
            revert Errors.TooManyTeeCommitments(teeCommitments.length, MAX_TEE_COMMITMENTS_PER_OPERATOR);
        }
        uint64 nowTs = uint64(block.timestamp);
        uint64 maxExpiresAt = nowTs + MAX_TEE_COMMITMENT_TTL;
        for (uint256 i = 0; i < teeCommitments.length; i++) {
            Types.TeeBackend backend = teeCommitments[i].backend;
            if (backend == Types.TeeBackend.Unset) revert Errors.UnsetTeeBackend();
            if (backend == Types.TeeBackend.DirectTdx) revert Errors.DirectTdxNotPermitted();
            if (teeCommitments[i].nonceBinding != expectedNonce) revert Errors.InvalidNonceBinding();
            if (teeCommitments[i].expectedMeasurement == bytes32(0)) revert Errors.InvalidExpectedMeasurement();
            uint64 expiresAt = teeCommitments[i].expiresAt;
            if (expiresAt != 0) {
                if (expiresAt <= nowTs) revert Errors.TeeCommitmentExpired(expiresAt, nowTs);
                if (expiresAt > maxExpiresAt) revert Errors.TeeCommitmentExpiryTooFar(expiresAt, maxExpiresAt);
            }
        }
    }

    function validateSecurityCommitments(
        Types.AssetSecurityRequirement[] storage requirements,
        Types.AssetSecurityCommitment[] calldata commitments
    )
        external
        view
    {
        for (uint256 i = 0; i < commitments.length; i++) {
            for (uint256 j = i + 1; j < commitments.length; j++) {
                if (
                    commitments[i].asset.token == commitments[j].asset.token
                        && commitments[i].asset.kind == commitments[j].asset.kind
                ) {
                    revert Errors.DuplicateAssetCommitment(uint8(commitments[i].asset.kind), commitments[i].asset.token);
                }
            }
        }

        for (uint256 i = 0; i < requirements.length; i++) {
            Types.AssetSecurityRequirement storage req = requirements[i];
            bool found = false;

            for (uint256 j = 0; j < commitments.length; j++) {
                if (commitments[j].asset.token == req.asset.token && commitments[j].asset.kind == req.asset.kind) {
                    if (commitments[j].exposureBps < req.minExposureBps) {
                        revert Errors.CommitmentBelowMinimum(
                            req.asset.token, commitments[j].exposureBps, req.minExposureBps
                        );
                    }
                    if (commitments[j].exposureBps > req.maxExposureBps) {
                        revert Errors.CommitmentAboveMaximum(
                            req.asset.token, commitments[j].exposureBps, req.maxExposureBps
                        );
                    }
                    found = true;
                    break;
                }
            }

            if (!found) revert Errors.MissingAssetCommitment(req.asset.token);
        }
    }

    function requireBlsProofOfPossession(
        address operator,
        uint256[4] memory blsPubkey,
        uint256[2] memory popSignature,
        address verifyingContract,
        uint256 chainId
    )
        external
        view
    {
        bool ok = BN254.verifyBls(
            AttestationLib.blsPopMessage(operator, blsPubkey, verifyingContract, chainId),
            Types.BN254G1Point({ x: popSignature[0], y: popSignature[1] }),
            Types.BN254G2Point({ x: [blsPubkey[0], blsPubkey[1]], y: [blsPubkey[2], blsPubkey[3]] })
        );
        if (!ok) revert Errors.InvalidBLSSignature();
    }
}
