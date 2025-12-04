// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import { Base } from "./Base.sol";
import { Types } from "../libraries/Types.sol";
import { Errors } from "../libraries/Errors.sol";
import { PaymentLib } from "../libraries/PaymentLib.sol";
import { BN254 } from "../libraries/BN254.sol";
import { IBlueprintServiceManager } from "../interfaces/IBlueprintServiceManager.sol";

/// @title Jobs
/// @notice Job submission and result handling
abstract contract Jobs is Base {
    using EnumerableSet for EnumerableSet.AddressSet;

    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    event JobSubmitted(uint64 indexed serviceId, uint64 indexed callId, uint8 jobIndex, address caller, bytes inputs);
    event JobResultSubmitted(uint64 indexed serviceId, uint64 indexed callId, address indexed operator, bytes output);
    event JobCompleted(uint64 indexed serviceId, uint64 indexed callId);
    event AggregatedResultSubmitted(
        uint64 indexed serviceId,
        uint64 indexed callId,
        uint256 signerBitmap,
        bytes output
    );

    // ═══════════════════════════════════════════════════════════════════════════
    // JOB SUBMISSION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Submit a job to a service
    function submitJob(
        uint64 serviceId,
        uint8 jobIndex,
        bytes calldata inputs
    ) external payable whenNotPaused nonReentrant returns (uint64 callId) {
        Types.Service storage svc = _getService(serviceId);
        if (svc.status != Types.ServiceStatus.Active) {
            revert Errors.ServiceNotActive(serviceId);
        }
        if (svc.ttl > 0 && block.timestamp > svc.createdAt + svc.ttl) {
            revert Errors.ServiceExpired(serviceId);
        }
        if (!_permittedCallers[serviceId].contains(msg.sender)) {
            revert Errors.NotPermittedCaller(serviceId, msg.sender);
        }

        uint256 payment = 0;
        if (svc.pricing == Types.PricingModel.EventDriven) {
            payment = _blueprintConfigs[svc.blueprintId].eventRate;
            PaymentLib.collectPayment(address(0), payment, msg.value);
            _recordPayment(msg.sender, serviceId, address(0), payment);
        }

        callId = _serviceCallCount[serviceId]++;
        _jobCalls[serviceId][callId] = Types.JobCall({
            jobIndex: jobIndex,
            caller: msg.sender,
            createdAt: uint64(block.timestamp),
            resultCount: 0,
            payment: payment,
            completed: false
        });

        // Store inputs for onJobResult hook
        _jobInputs[serviceId][callId] = inputs;

        // Call BSM hook - allows manager to validate/reject job
        Types.Blueprint storage bp = _blueprints[svc.blueprintId];
        if (bp.manager != address(0)) {
            _callManager(
                bp.manager,
                abi.encodeCall(IBlueprintServiceManager.onJobCall, (serviceId, jobIndex, callId, inputs))
            );
        }

        emit JobSubmitted(serviceId, callId, jobIndex, msg.sender, inputs);
        _recordJobCall(serviceId, msg.sender, callId);
    }

    /// @notice Submit job result
    /// @dev Reverts if this job requires BLS aggregation (use submitAggregatedResult instead)
    function submitResult(
        uint64 serviceId,
        uint64 callId,
        bytes calldata output
    ) external whenNotPaused nonReentrant {
        Types.Service storage svc = _getService(serviceId);
        Types.JobCall storage job = _getJobCall(serviceId, callId);
        Types.Blueprint storage bp = _blueprints[svc.blueprintId];

        // Check if aggregation is required for this job
        if (bp.manager != address(0)) {
            try IBlueprintServiceManager(bp.manager).requiresAggregation(serviceId, job.jobIndex) returns (bool aggRequired) {
                if (aggRequired) {
                    revert Errors.AggregationRequired(serviceId, job.jobIndex);
                }
            } catch {}
        }

        if (!_serviceOperators[serviceId][msg.sender].active) {
            revert Errors.OperatorNotInService(serviceId, msg.sender);
        }
        if (job.completed) {
            revert Errors.JobAlreadyCompleted(serviceId, callId);
        }
        if (_jobResultSubmitted[serviceId][callId][msg.sender]) {
            revert Errors.ResultAlreadySubmitted(serviceId, callId, msg.sender);
        }

        _jobResultSubmitted[serviceId][callId][msg.sender] = true;
        job.resultCount++;

        // Call BSM hook - notify manager of result
        if (bp.manager != address(0)) {
            _tryCallManager(
                bp.manager,
                abi.encodeCall(
                    IBlueprintServiceManager.onJobResult,
                    (serviceId, job.jobIndex, callId, msg.sender, _jobInputs[serviceId][callId], output)
                )
            );
        }

        emit JobResultSubmitted(serviceId, callId, msg.sender, output);

        uint32 required = 1;
        if (bp.manager != address(0)) {
            try IBlueprintServiceManager(bp.manager).getRequiredResultCount(serviceId, job.jobIndex) returns (uint32 r) {
                required = r;
            } catch {}
        }

        if (job.resultCount >= required) {
            job.completed = true;
            emit JobCompleted(serviceId, callId);

            // Record metrics for rewards distribution
            _recordJobCompletion(msg.sender, serviceId, callId, true);

            if (svc.pricing == Types.PricingModel.EventDriven && job.payment > 0) {
                _distributeJobPayment(serviceId, job.payment);
            }
        }
    }

    /// @notice Batch submit results
    function submitResults(
        uint64 serviceId,
        uint64[] calldata callIds,
        bytes[] calldata outputs
    ) external whenNotPaused nonReentrant {
        if (callIds.length != outputs.length) revert Errors.LengthMismatch();

        Types.Service storage svc = _services[serviceId];
        Types.Blueprint storage bp = _blueprints[svc.blueprintId];

        for (uint256 i = 0; i < callIds.length; i++) {
            Types.JobCall storage job = _jobCalls[serviceId][callIds[i]];

            if (!_serviceOperators[serviceId][msg.sender].active) {
                revert Errors.OperatorNotInService(serviceId, msg.sender);
            }
            if (job.completed) {
                revert Errors.JobAlreadyCompleted(serviceId, callIds[i]);
            }
            if (_jobResultSubmitted[serviceId][callIds[i]][msg.sender]) {
                revert Errors.ResultAlreadySubmitted(serviceId, callIds[i], msg.sender);
            }

            _jobResultSubmitted[serviceId][callIds[i]][msg.sender] = true;
            job.resultCount++;

            // Call BSM hook - notify manager of result
            if (bp.manager != address(0)) {
                _tryCallManager(
                    bp.manager,
                    abi.encodeCall(
                        IBlueprintServiceManager.onJobResult,
                        (serviceId, job.jobIndex, callIds[i], msg.sender, _jobInputs[serviceId][callIds[i]], outputs[i])
                    )
                );
            }

            emit JobResultSubmitted(serviceId, callIds[i], msg.sender, outputs[i]);

            // Query required result count from manager (same as submitResult)
            uint32 required = 1;
            if (bp.manager != address(0)) {
                try IBlueprintServiceManager(bp.manager).getRequiredResultCount(serviceId, job.jobIndex) returns (uint32 r) {
                    required = r;
                } catch {}
            }

            if (job.resultCount >= required && !job.completed) {
                job.completed = true;
                emit JobCompleted(serviceId, callIds[i]);

                // Record metrics for rewards distribution
                _recordJobCompletion(msg.sender, serviceId, callIds[i], true);

                if (svc.pricing == Types.PricingModel.EventDriven && job.payment > 0) {
                    _distributeJobPayment(serviceId, job.payment);
                }
            }
        }
    }

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
        Types.Service storage svc = _getService(serviceId);
        Types.JobCall storage job = _getJobCall(serviceId, callId);
        Types.Blueprint storage bp = _blueprints[svc.blueprintId];

        if (job.completed) {
            revert Errors.JobAlreadyCompleted(serviceId, callId);
        }

        // Verify aggregation is required for this job
        bool aggregationRequired = false;
        if (bp.manager != address(0)) {
            try IBlueprintServiceManager(bp.manager).requiresAggregation(serviceId, job.jobIndex) returns (bool aggReq) {
                aggregationRequired = aggReq;
            } catch {}
        }
        if (!aggregationRequired) {
            revert Errors.AggregationNotRequired(serviceId, job.jobIndex);
        }

        // Get threshold configuration
        uint16 thresholdBps = 6700; // Default 67%
        uint8 thresholdType = 0; // Default CountBased
        if (bp.manager != address(0)) {
            try IBlueprintServiceManager(bp.manager).getAggregationThreshold(serviceId, job.jobIndex) returns (
                uint16 _thresholdBps,
                uint8 _thresholdType
            ) {
                thresholdBps = _thresholdBps;
                thresholdType = _thresholdType;
            } catch {}
        }

        // Validate signers and compute threshold
        (uint256 achieved, uint256 required) = _validateSignersAndThreshold(
            serviceId,
            signerBitmap,
            thresholdBps,
            thresholdType
        );

        if (achieved < required) {
            revert Errors.AggregationThresholdNotMet(serviceId, callId, achieved, required);
        }

        // Verify the BLS signature
        Types.BN254G1Point memory sig = Types.BN254G1Point(aggregatedSignature[0], aggregatedSignature[1]);
        Types.BN254G2Point memory pubkey = Types.BN254G2Point(
            [aggregatedPubkey[0], aggregatedPubkey[1]],
            [aggregatedPubkey[2], aggregatedPubkey[3]]
        );

        // Construct message to verify: hash of (serviceId, callId, outputHash)
        bytes memory message = abi.encodePacked(serviceId, callId, keccak256(output));
        if (!BN254.verifyAggregatedBLS(message, sig, pubkey)) {
            revert Errors.InvalidBLSSignature();
        }

        // Mark job complete
        job.completed = true;

        // Call BSM hook
        if (bp.manager != address(0)) {
            _tryCallManager(
                bp.manager,
                abi.encodeCall(
                    IBlueprintServiceManager.onAggregatedResult,
                    (serviceId, job.jobIndex, callId, output, signerBitmap, aggregatedSignature, aggregatedPubkey)
                )
            );
        }

        emit AggregatedResultSubmitted(serviceId, callId, signerBitmap, output);
        emit JobCompleted(serviceId, callId);

        // Record metrics for ALL signers in the bitmap for rewards distribution
        _recordAggregatedJobCompletion(serviceId, callId, signerBitmap);

        if (svc.pricing == Types.PricingModel.EventDriven && job.payment > 0) {
            _distributeJobPayment(serviceId, job.payment);
        }
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
            if ((signerBitmap & (1 << i)) != 0) {
                // This operator signed - record job completion
                _recordJobCompletion(operators[i], serviceId, callId, true);
            }
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
        Types.Service storage svc = _services[serviceId];
        uint32 operatorCount = svc.operatorCount;

        // Get operator list for this service
        address[] memory operators = _getServiceOperatorList(serviceId);

        uint256 signerCount = 0;
        uint256 totalWeight = 0;
        uint256 signerWeight = 0;

        for (uint256 i = 0; i < operators.length; i++) {
            address op = operators[i];
            Types.ServiceOperator storage svcOp = _serviceOperators[serviceId][op];

            if (!svcOp.active) continue;

            uint256 weight = thresholdType == 1 ? uint256(svcOp.exposureBps) : 1;
            totalWeight += weight;

            // Check if operator signed (bit i is set)
            if ((signerBitmap >> i) & 1 == 1) {
                signerCount++;
                signerWeight += weight;
            }
        }

        if (thresholdType == 0) {
            // CountBased: achieved = signerCount, required = threshold% of operatorCount
            achieved = signerCount;
            required = (uint256(operatorCount) * thresholdBps) / 10000;
            if (required == 0 && operatorCount > 0) required = 1; // At least 1 signer required
        } else {
            // StakeWeighted: achieved = signerWeight, required = threshold% of totalWeight
            achieved = signerWeight;
            required = (totalWeight * thresholdBps) / 10000;
            if (required == 0 && totalWeight > 0) required = 1;
        }
    }

    /// @notice Get the list of operators for a service (to be implemented by child contract)
    function _getServiceOperatorList(uint64 serviceId) internal view virtual returns (address[] memory);

    /// @notice Distribute payment for completed job - to be implemented in Payments mixin
    function _distributeJobPayment(uint64 serviceId, uint256 payment) internal virtual;
}
