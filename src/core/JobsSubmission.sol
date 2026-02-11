// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import { Base } from "./Base.sol";
import { Types } from "../libraries/Types.sol";
import { Errors } from "../libraries/Errors.sol";
import { PaymentLib } from "../libraries/PaymentLib.sol";
import { IBlueprintServiceManager } from "../interfaces/IBlueprintServiceManager.sol";
import { SchemaLib } from "../libraries/SchemaLib.sol";

/// @title JobsSubmission
/// @notice Job submission and result handling
abstract contract JobsSubmission is Base {
    using EnumerableSet for EnumerableSet.AddressSet;

    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    event JobSubmitted(uint64 indexed serviceId, uint64 indexed callId, uint8 jobIndex, address caller, bytes inputs);
    event JobResultSubmitted(uint64 indexed serviceId, uint64 indexed callId, address indexed operator, bytes output);
    event JobCompleted(uint64 indexed serviceId, uint64 indexed callId);

    // ═══════════════════════════════════════════════════════════════════════════
    // JOB SUBMISSION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Submit a job to a service
    function submitJob(
        uint64 serviceId,
        uint8 jobIndex,
        bytes calldata inputs
    )
        external
        payable
        whenNotPaused
        nonReentrant
        returns (uint64 callId)
    {
        (Types.Service storage svc, Types.Blueprint storage bp) = _loadServiceAndBlueprint(serviceId);

        _validateServiceForSubmission(svc, serviceId);
        _requirePermittedCaller(serviceId, msg.sender);

        uint256 payment = _collectJobPaymentIfNeeded(svc, serviceId, jobIndex, msg.value, msg.sender);
        _validateJobInputs(svc.blueprintId, jobIndex, inputs);

        callId = _createJobCall(serviceId, jobIndex, msg.sender, payment, false);
        bytes memory managerInputs = inputs;
        _jobInputs[serviceId][callId] = managerInputs;

        _finalizeJobSubmission(bp.manager, serviceId, jobIndex, callId, msg.sender, managerInputs);
    }

    /// @notice Submit job result
    /// @dev Reverts if this job requires BLS aggregation (use submitAggregatedResult instead)
    function submitResult(uint64 serviceId, uint64 callId, bytes calldata output) external whenNotPaused nonReentrant {
        (Types.Service storage svc, Types.JobCall storage job, Types.Blueprint storage bp) =
            _loadServiceJobAndBlueprint(serviceId, callId);

        _processResultSubmission(serviceId, callId, output, svc, job, bp);
    }

    /// @notice Batch submit results
    function submitResults(
        uint64 serviceId,
        uint64[] calldata callIds,
        bytes[] calldata outputs
    )
        external
        whenNotPaused
        nonReentrant
    {
        if (callIds.length != outputs.length) revert Errors.LengthMismatch();

        (Types.Service storage svc, Types.Blueprint storage bp) = _loadServiceAndBlueprint(serviceId);

        for (uint256 i = 0; i < callIds.length; i++) {
            Types.JobCall storage job = _getJobCall(serviceId, callIds[i]);
            _processResultSubmission(serviceId, callIds[i], outputs[i], svc, job, bp);
        }
    }

    function _processResultSubmission(
        uint64 serviceId,
        uint64 callId,
        bytes calldata output,
        Types.Service storage svc,
        Types.JobCall storage job,
        Types.Blueprint storage bp
    )
        private
    {
        _ensureAggregationBypass(bp.manager, serviceId, job.jobIndex);
        _validateResultSubmissionState(serviceId, callId, job);

        _validateJobResultOutput(svc.blueprintId, job.jobIndex, output);
        _recordOperatorResult(serviceId, callId, job);

        _notifyManagerOnJobResult(bp.manager, serviceId, job.jobIndex, callId, output);

        emit JobResultSubmitted(serviceId, callId, msg.sender, output);

        _maybeFinalizeJob(serviceId, callId, svc, job, bp.manager);
    }

    function _loadServiceAndBlueprint(uint64 serviceId)
        private
        view
        returns (Types.Service storage svc, Types.Blueprint storage bp)
    {
        svc = _getService(serviceId);
        bp = _blueprints[svc.blueprintId];
    }

    function _loadServiceJobAndBlueprint(
        uint64 serviceId,
        uint64 callId
    )
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
        uint8 jobIndex,
        uint256 msgValue,
        address payer
    )
        private
        returns (uint256 payment)
    {
        if (svc.pricing == Types.PricingModel.EventDriven) {
            uint256 perJob = _jobEventRates[svc.blueprintId][jobIndex];
            payment = perJob > 0 ? perJob : _blueprintConfigs[svc.blueprintId].eventRate;
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
        uint256 payment,
        bool isRFQ
    )
        internal
        returns (uint64 callId)
    {
        callId = _serviceCallCount[serviceId]++;
        _jobCalls[serviceId][callId] = Types.JobCall({
            jobIndex: jobIndex,
            caller: caller,
            createdAt: uint64(block.timestamp),
            resultCount: 0,
            payment: payment,
            completed: false,
            isRFQ: isRFQ
        });
    }

    function _finalizeJobSubmission(
        address manager,
        uint64 serviceId,
        uint8 jobIndex,
        uint64 callId,
        address caller,
        bytes memory inputs
    )
        private
    {
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
    )
        private
    {
        if (manager == address(0)) {
            return;
        }

        bytes memory payload = abi.encodeCall(IBlueprintServiceManager.onJobCall, (serviceId, jobIndex, callId, inputs));
        _callManager(manager, payload);
    }

    function _ensureAggregationBypass(address manager, uint64 serviceId, uint8 jobIndex) private view {
        if (manager == address(0)) return;

        try IBlueprintServiceManager(manager).requiresAggregation(serviceId, jobIndex) returns (bool aggRequired) {
            if (aggRequired) {
                revert Errors.AggregationRequired(serviceId, jobIndex);
            }
        } catch { }
    }

    function _validateResultSubmissionState(uint64 serviceId, uint64 callId, Types.JobCall storage job) private view {
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
        if (job.isRFQ && !_jobQuotedOperators[serviceId][callId].contains(msg.sender)) {
            revert Errors.NotQuotedOperator(serviceId, callId);
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
    )
        private
    {
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
    )
        private
    {
        uint32 required = _getRequiredResultCount(manager, serviceId, job.jobIndex);
        if (job.resultCount < required || job.completed) {
            return;
        }

        job.completed = true;
        emit JobCompleted(serviceId, callId);

        _recordJobCompletion(msg.sender, serviceId, callId, true);

        if (svc.pricing == Types.PricingModel.EventDriven && job.payment > 0) {
            if (job.isRFQ) {
                _distributeRFQJobPayment(serviceId, callId, job.payment);
            } else {
                _distributeJobPayment(serviceId, job.payment);
            }
        }
    }

    function _getRequiredResultCount(
        address manager,
        uint64 serviceId,
        uint8 jobIndex
    )
        private
        view
        returns (uint32 required)
    {
        required = 1;
        if (manager == address(0)) {
            return required;
        }

        try IBlueprintServiceManager(manager).getRequiredResultCount(serviceId, jobIndex) returns (uint32 r) {
            required = r;
        } catch { }
    }

    function _jobSchema(
        uint64 blueprintId,
        uint8 jobIndex
    )
        internal
        view
        returns (Types.StoredJobSchema storage schema)
    {
        Types.StoredJobSchema[] storage schemas = _blueprintJobSchemas[blueprintId];
        if (jobIndex >= schemas.length) {
            revert Errors.InvalidJobIndex(jobIndex);
        }
        return schemas[jobIndex];
    }

    /// @notice Distribute payment for completed job - to be implemented in Payments mixin
    function _distributeJobPayment(uint64 serviceId, uint256 payment) internal virtual;

    /// @notice Distribute payment for RFQ job to quoted operators at their individual prices
    function _distributeRFQJobPayment(uint64 serviceId, uint64 callId, uint256 totalPayment) internal virtual;
}
