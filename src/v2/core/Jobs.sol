// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import { Base } from "./Base.sol";
import { Types } from "../libraries/Types.sol";
import { Errors } from "../libraries/Errors.sol";
import { PaymentLib } from "../libraries/PaymentLib.sol";
import { BN254 } from "../libraries/BN254.sol";
import { IBlueprintServiceManager } from "../interfaces/IBlueprintServiceManager.sol";
import { SchemaLib } from "../libraries/SchemaLib.sol";

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
        (Types.Service storage svc, Types.Blueprint storage bp) = _loadServiceAndBlueprint(serviceId);

        _validateServiceForSubmission(svc, serviceId);
        _requirePermittedCaller(serviceId, msg.sender);

        uint256 payment = _collectJobPaymentIfNeeded(svc, serviceId, msg.value, msg.sender);
        _validateJobInputs(svc.blueprintId, jobIndex, inputs);

        callId = _createJobCall(serviceId, jobIndex, msg.sender, payment);
        bytes memory managerInputs = inputs;
        _jobInputs[serviceId][callId] = managerInputs;

        _finalizeJobSubmission(bp.manager, serviceId, jobIndex, callId, msg.sender, managerInputs);
    }

    /// @notice Submit job result
    /// @dev Reverts if this job requires BLS aggregation (use submitAggregatedResult instead)
    function submitResult(
        uint64 serviceId,
        uint64 callId,
        bytes calldata output
    ) external whenNotPaused nonReentrant {
        (Types.Service storage svc, Types.JobCall storage job, Types.Blueprint storage bp) =
            _loadServiceJobAndBlueprint(serviceId, callId);

        _processResultSubmission(serviceId, callId, output, svc, job, bp);
    }

    /// @notice Batch submit results
    function submitResults(
        uint64 serviceId,
        uint64[] calldata callIds,
        bytes[] calldata outputs
    ) external whenNotPaused nonReentrant {
        if (callIds.length != outputs.length) revert Errors.LengthMismatch();

        (Types.Service storage svc, Types.Blueprint storage bp) = _loadServiceAndBlueprint(serviceId);

        for (uint256 i = 0; i < callIds.length; i++) {
            Types.JobCall storage job = _getJobCall(serviceId, callIds[i]);
            _processResultSubmission(serviceId, callIds[i], outputs[i], svc, job, bp);
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

    function _processResultSubmission(
        uint64 serviceId,
        uint64 callId,
        bytes calldata output,
        Types.Service storage svc,
        Types.JobCall storage job,
        Types.Blueprint storage bp
    ) private {
        _ensureAggregationBypass(bp.manager, serviceId, job.jobIndex);
        _validateResultSubmissionState(serviceId, callId, job);

        _validateJobResultOutput(svc.blueprintId, job.jobIndex, output);
        _recordOperatorResult(serviceId, callId, job);

        _notifyManagerOnJobResult(bp.manager, serviceId, job.jobIndex, callId, output);

        emit JobResultSubmitted(serviceId, callId, msg.sender, output);

        _maybeFinalizeJob(serviceId, callId, svc, job, bp.manager);
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

    function _loadServiceAndBlueprint(uint64 serviceId)
        private
        view
        returns (Types.Service storage svc, Types.Blueprint storage bp)
    {
        svc = _getService(serviceId);
        bp = _blueprints[svc.blueprintId];
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

    function _validateServiceForSubmission(Types.Service storage svc, uint64 serviceId) private view {
        if (svc.status != Types.ServiceStatus.Active) {
            revert Errors.ServiceNotActive(serviceId);
        }
        if (svc.ttl > 0 && block.timestamp > svc.createdAt + svc.ttl) {
            revert Errors.ServiceExpired(serviceId);
        }
    }

    function _requirePermittedCaller(uint64 serviceId, address caller) private view {
        if (!_permittedCallers[serviceId].contains(caller)) {
            revert Errors.NotPermittedCaller(serviceId, caller);
        }
    }

    function _collectJobPaymentIfNeeded(
        Types.Service storage svc,
        uint64 serviceId,
        uint256 msgValue,
        address payer
    ) private returns (uint256 payment) {
        if (svc.pricing == Types.PricingModel.EventDriven) {
            payment = _blueprintConfigs[svc.blueprintId].eventRate;
            PaymentLib.collectPayment(address(0), payment, msgValue);
            _recordPayment(payer, serviceId, address(0), payment);
        }
    }

    function _validateJobInputs(uint64 blueprintId, uint8 jobIndex, bytes calldata inputs) private view {
        Types.StoredJobSchema storage schema = _jobSchema(blueprintId, jobIndex);
        SchemaLib.validateJobParams(schema, inputs, blueprintId, jobIndex);
    }

    function _createJobCall(
        uint64 serviceId,
        uint8 jobIndex,
        address caller,
        uint256 payment
    ) private returns (uint64 callId) {
        callId = _serviceCallCount[serviceId]++;
        _jobCalls[serviceId][callId] = Types.JobCall({
            jobIndex: jobIndex,
            caller: caller,
            createdAt: uint64(block.timestamp),
            resultCount: 0,
            payment: payment,
            completed: false
        });
    }

    function _finalizeJobSubmission(
        address manager,
        uint64 serviceId,
        uint8 jobIndex,
        uint64 callId,
        address caller,
        bytes memory inputs
    ) private {
        emit JobSubmitted(serviceId, callId, jobIndex, caller, inputs);
        _notifyManagerOnJobCall(manager, serviceId, jobIndex, callId, inputs);
        _recordJobCall(serviceId, caller, callId);
    }

    function _notifyManagerOnJobCall(
        address manager,
        uint64 serviceId,
        uint8 jobIndex,
        uint64 callId,
        bytes memory inputs
    ) private {
        if (manager == address(0)) {
            return;
        }

        bytes memory payload =
            abi.encodeCall(IBlueprintServiceManager.onJobCall, (serviceId, jobIndex, callId, inputs));
        _callManager(manager, payload);
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

    function _ensureAggregationBypass(address manager, uint64 serviceId, uint8 jobIndex) private view {
        if (manager == address(0)) return;

        try IBlueprintServiceManager(manager).requiresAggregation(serviceId, jobIndex) returns (bool aggRequired) {
            if (aggRequired) {
                revert Errors.AggregationRequired(serviceId, jobIndex);
            }
        } catch {}
    }

    function _validateResultSubmissionState(
        uint64 serviceId,
        uint64 callId,
        Types.JobCall storage job
    ) private view {
        if (!_serviceOperators[serviceId][msg.sender].active) {
            revert Errors.OperatorNotInService(serviceId, msg.sender);
        }
        if (!_staking.isOperatorActive(msg.sender)) {
            revert Errors.OperatorNotActive(msg.sender);
        }
        if (job.completed) {
            revert Errors.JobAlreadyCompleted(serviceId, callId);
        }
        if (_jobResultSubmitted[serviceId][callId][msg.sender]) {
            revert Errors.ResultAlreadySubmitted(serviceId, callId, msg.sender);
        }
    }

    function _validateJobResultOutput(uint64 blueprintId, uint8 jobIndex, bytes calldata output) private view {
        Types.StoredJobSchema storage schema = _jobSchema(blueprintId, jobIndex);
        SchemaLib.validateJobResult(schema, output, blueprintId, jobIndex);
    }

    function _recordOperatorResult(uint64 serviceId, uint64 callId, Types.JobCall storage job) private {
        _jobResultSubmitted[serviceId][callId][msg.sender] = true;
        job.resultCount++;
    }

    function _notifyManagerOnJobResult(
        address manager,
        uint64 serviceId,
        uint8 jobIndex,
        uint64 callId,
        bytes calldata output
    ) private {
        if (manager == address(0)) return;

        _tryCallManager(
            manager,
            abi.encodeCall(
                IBlueprintServiceManager.onJobResult,
                (serviceId, jobIndex, callId, msg.sender, _jobInputs[serviceId][callId], output)
            )
        );
    }

    function _maybeFinalizeJob(
        uint64 serviceId,
        uint64 callId,
        Types.Service storage svc,
        Types.JobCall storage job,
        address manager
    ) private {
        uint32 required = _getRequiredResultCount(manager, serviceId, job.jobIndex);
        if (job.resultCount < required || job.completed) {
            return;
        }

        job.completed = true;
        emit JobCompleted(serviceId, callId);

        _recordJobCompletion(msg.sender, serviceId, callId, true);

        if (svc.pricing == Types.PricingModel.EventDriven && job.payment > 0) {
            _distributeJobPayment(serviceId, job.payment);
        }
    }

    function _getRequiredResultCount(
        address manager,
        uint64 serviceId,
        uint8 jobIndex
    ) private view returns (uint32 required) {
        required = 1;
        if (manager == address(0)) {
            return required;
        }

        try IBlueprintServiceManager(manager).getRequiredResultCount(serviceId, jobIndex) returns (uint32 r) {
            required = r;
        } catch {}
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
            required = (uint256(stats.operatorCount) * thresholdBps) / BPS_DENOMINATOR;
            if (required == 0 && stats.operatorCount > 0) required = 1; // At least 1 signer required
        } else {
            // StakeWeighted: achieved = signerWeight, required = threshold% of totalWeight
            achieved = stats.signerWeight;
            required = (stats.totalWeight * thresholdBps) / BPS_DENOMINATOR;
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
            if (!_staking.isOperatorActive(operators[i])) continue;

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
        config.thresholdBps = DEFAULT_AGGREGATION_THRESHOLD_BPS;
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

    /// @notice Get the list of operators for a service (to be implemented by child contract)
    function _getServiceOperatorList(uint64 serviceId) internal view virtual returns (address[] memory);

    /// @notice Distribute payment for completed job - to be implemented in Payments mixin
    function _distributeJobPayment(uint64 serviceId, uint256 payment) internal virtual;
}
