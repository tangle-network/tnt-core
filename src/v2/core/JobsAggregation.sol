// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import { Base } from "./Base.sol";
import { Types } from "../libraries/Types.sol";
import { Errors } from "../libraries/Errors.sol";
import { BN254 } from "../libraries/BN254.sol";
import { IBlueprintServiceManager } from "../interfaces/IBlueprintServiceManager.sol";
import { SchemaLib } from "../libraries/SchemaLib.sol";

/// @title JobsAggregation
/// @notice Aggregated BLS job results
abstract contract JobsAggregation is Base {
    using EnumerableSet for EnumerableSet.AddressSet;

    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    event JobCompleted(uint64 indexed serviceId, uint64 indexed callId);
    event AggregatedResultSubmitted(
        uint64 indexed serviceId,
        uint64 indexed callId,
        uint256 signerBitmap,
        bytes output
    );

    // ═══════════════════════════════════════════════════════════════════════════
    // AGGREGATED RESULT SUBMISSION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Submit an aggregated BLS result for a job
    /// @dev Only valid for jobs where requiresAggregation returns true
    /// @param serviceId The service ID
    /// @param callId The job call ID
    /// @param output The aggregated output data
    /// @param signerBitmap Bitmap indicating which operators signed (bit i = operator i in service)
    /// @param aggregatedSignature The aggregated BLS signature [x, y]
    /// @param aggregatedPubkey The aggregated public key [x0, x1, y0, y1]
    function submitAggregatedResult(
        uint64 serviceId,
        uint64 callId,
        bytes calldata output,
        uint256 signerBitmap,
        uint256[2] calldata aggregatedSignature,
        uint256[4] calldata aggregatedPubkey
    ) external whenNotPaused nonReentrant {
        (Types.Service storage svc, Types.JobCall storage job, Types.Blueprint storage bp) =
            _loadServiceJobAndBlueprint(serviceId, callId);

        _validateAggregatedSubmissionPreconditions(serviceId, callId, output, svc, job, bp.manager);

        AggregationConfig memory config = _getAggregationConfig(bp.manager, serviceId, job.jobIndex);
        _enforceAggregationThreshold(serviceId, callId, signerBitmap, config);

        _verifyAggregatedSignature(serviceId, callId, output, aggregatedSignature, aggregatedPubkey);

        _finalizeAggregatedResult(
            svc,
            job,
            bp,
            serviceId,
            callId,
            signerBitmap,
            output,
            aggregatedSignature,
            aggregatedPubkey
        );
    }

    function _finalizeAggregatedResult(
        Types.Service storage svc,
        Types.JobCall storage job,
        Types.Blueprint storage bp,
        uint64 serviceId,
        uint64 callId,
        uint256 signerBitmap,
        bytes calldata output,
        uint256[2] calldata aggregatedSignature,
        uint256[4] calldata aggregatedPubkey
    ) private {
        job.completed = true;

        emit AggregatedResultSubmitted(serviceId, callId, signerBitmap, output);
        emit JobCompleted(serviceId, callId);

        _recordAggregatedJobCompletion(serviceId, callId, signerBitmap);

        if (svc.pricing == Types.PricingModel.EventDriven && job.payment > 0) {
            _distributeJobPayment(serviceId, job.payment);
        }

        if (bp.manager != address(0)) {
            _notifyManagerAggregatedResult(
                bp.manager,
                job.jobIndex,
                serviceId,
                callId,
                output,
                signerBitmap,
                aggregatedSignature,
                aggregatedPubkey
            );
        }
    }

    function _notifyManagerAggregatedResult(
        address manager,
        uint8 jobIndex,
        uint64 serviceId,
        uint64 callId,
        bytes calldata output,
        uint256 signerBitmap,
        uint256[2] calldata aggregatedSignature,
        uint256[4] calldata aggregatedPubkey
    ) private {
        try IBlueprintServiceManager(manager).onAggregatedResult(
            serviceId,
            jobIndex,
            callId,
            output,
            signerBitmap,
            aggregatedSignature,
            aggregatedPubkey
        ) {} catch {}
    }

    /// @notice Record job completion metrics for all signers in an aggregated result
    /// @param serviceId The service ID
    /// @param callId The job call ID
    /// @param signerBitmap Bitmap of operators who signed
    function _recordAggregatedJobCompletion(
        uint64 serviceId,
        uint64 callId,
        uint256 signerBitmap
    ) internal {
        if (_metricsRecorder == address(0)) return;

        address[] memory operators = _getServiceOperatorList(serviceId);

        for (uint256 i = 0; i < operators.length; i++) {
            if ((signerBitmap & (uint256(1) << i)) != 0) {
                // This operator signed - record job completion
                _recordJobCompletion(operators[i], serviceId, callId, true);
            }
        }
    }

    function _loadServiceJobAndBlueprint(uint64 serviceId, uint64 callId)
        private
        view
        returns (Types.Service storage svc, Types.JobCall storage job, Types.Blueprint storage bp)
    {
        svc = _getService(serviceId);
        job = _getJobCall(serviceId, callId);
        bp = _blueprints[svc.blueprintId];
    }

    function _validateAggregatedSubmissionPreconditions(
        uint64 serviceId,
        uint64 callId,
        bytes calldata output,
        Types.Service storage svc,
        Types.JobCall storage job,
        address manager
    ) private view {
        if (job.completed) {
            revert Errors.JobAlreadyCompleted(serviceId, callId);
        }

        _ensureAggregationRequired(manager, serviceId, job.jobIndex);

        Types.StoredJobSchema storage schema = _jobSchema(svc.blueprintId, job.jobIndex);
        SchemaLib.validateJobResult(schema, output, svc.blueprintId, job.jobIndex);
    }

    function _enforceAggregationThreshold(
        uint64 serviceId,
        uint64 callId,
        uint256 signerBitmap,
        AggregationConfig memory config
    ) private view {
        (uint256 achieved, uint256 required) = _validateSignersAndThreshold(
            serviceId,
            signerBitmap,
            config.thresholdBps,
            config.thresholdType
        );

        if (achieved < required) {
            revert Errors.AggregationThresholdNotMet(serviceId, callId, achieved, required);
        }
    }

    /// @notice Validate signers in bitmap and compute achieved vs required threshold
    /// @param serviceId The service ID
    /// @param signerBitmap Bitmap of signers
    /// @param thresholdBps Threshold in basis points
    /// @param thresholdType 0 = CountBased, 1 = StakeWeighted
    /// @return achieved The achieved value (count or stake)
    /// @return required The required value (count or stake)
    function _validateSignersAndThreshold(
        uint64 serviceId,
        uint256 signerBitmap,
        uint16 thresholdBps,
        uint8 thresholdType
    ) internal view returns (uint256 achieved, uint256 required) {
        SignerStats memory stats = _computeSignerStats(serviceId, signerBitmap, thresholdType);

        if (thresholdType == 0) {
            // CountBased: achieved = signerCount, required = threshold% of operatorCount
            achieved = stats.signerCount;
            required = (uint256(stats.operatorCount) * thresholdBps) / 10000;
            if (required == 0 && stats.operatorCount > 0) required = 1; // At least 1 signer required
        } else {
            // StakeWeighted: achieved = signerWeight, required = threshold% of totalWeight
            achieved = stats.signerWeight;
            required = (stats.totalWeight * thresholdBps) / 10000;
            if (required == 0 && stats.totalWeight > 0) required = 1;
        }
    }

    struct SignerStats {
        uint32 operatorCount;
        uint256 signerCount;
        uint256 totalWeight;
        uint256 signerWeight;
    }

    function _computeSignerStats(uint64 serviceId, uint256 signerBitmap, uint8 thresholdType)
        private
        view
        returns (SignerStats memory stats)
    {
        address[] memory operators = _getServiceOperatorList(serviceId);

        for (uint256 i = 0; i < operators.length; i++) {
            Types.ServiceOperator storage svcOp = _serviceOperators[serviceId][operators[i]];
            if (!svcOp.active) continue;
            if (!_restaking.isOperatorActive(operators[i])) continue;

            stats.operatorCount++;
            uint256 weight = thresholdType == 1 ? uint256(svcOp.exposureBps) : 1;
            stats.totalWeight += weight;

            if ((signerBitmap >> i) & 1 == 1) {
                stats.signerCount++;
                stats.signerWeight += weight;
            }
        }
    }

    struct AggregationConfig {
        uint16 thresholdBps;
        uint8 thresholdType;
    }

    function _getAggregationConfig(
        address manager,
        uint64 serviceId,
        uint8 jobIndex
    ) private view returns (AggregationConfig memory config) {
        config.thresholdBps = 6700; // Default 67%
        config.thresholdType = 0;   // Default CountBased

        if (manager != address(0)) {
            try IBlueprintServiceManager(manager).getAggregationThreshold(serviceId, jobIndex) returns (
                uint16 thresholdBps,
                uint8 thresholdType
            ) {
                config.thresholdBps = thresholdBps;
                config.thresholdType = thresholdType;
            } catch {}
        }
    }

    function _ensureAggregationRequired(
        address manager,
        uint64 serviceId,
        uint8 jobIndex
    ) private view {
        bool required;
        if (manager != address(0)) {
            try IBlueprintServiceManager(manager).requiresAggregation(serviceId, jobIndex) returns (bool aggReq) {
                required = aggReq;
            } catch {}
        }
        if (!required) {
            revert Errors.AggregationNotRequired(serviceId, jobIndex);
        }
    }

    function _verifyAggregatedSignature(
        uint64 serviceId,
        uint64 callId,
        bytes calldata output,
        uint256[2] calldata aggregatedSignature,
        uint256[4] calldata aggregatedPubkey
    ) private view {
        Types.BN254G1Point memory sig = Types.BN254G1Point(aggregatedSignature[0], aggregatedSignature[1]);
        Types.BN254G2Point memory pubkey = Types.BN254G2Point(
            [aggregatedPubkey[0], aggregatedPubkey[1]],
            [aggregatedPubkey[2], aggregatedPubkey[3]]
        );

        bytes memory message = abi.encodePacked(serviceId, callId, keccak256(output));
        if (!BN254.verifyAggregatedBls(message, sig, pubkey)) {
            revert Errors.InvalidBLSSignature();
        }
    }

    function _jobSchema(
        uint64 blueprintId,
        uint8 jobIndex
    ) internal view returns (Types.StoredJobSchema storage schema) {
        Types.StoredJobSchema[] storage schemas = _blueprintJobSchemas[blueprintId];
        if (jobIndex >= schemas.length) {
            revert Errors.InvalidJobIndex(jobIndex);
        }
        return schemas[jobIndex];
    }

    /// @notice Get the list of operators for a service (to be implemented by child contract)
    function _getServiceOperatorList(uint64 serviceId) internal view virtual returns (address[] memory);

    /// @notice Distribute payment for completed job - to be implemented in Payments mixin
    function _distributeJobPayment(uint64 serviceId, uint256 payment) internal virtual;
}
