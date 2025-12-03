// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import { Base } from "./Base.sol";
import { Types } from "../libraries/Types.sol";
import { Errors } from "../libraries/Errors.sol";
import { PaymentLib } from "../libraries/PaymentLib.sol";
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
    }

    /// @notice Submit job result
    function submitResult(
        uint64 serviceId,
        uint64 callId,
        bytes calldata output
    ) external whenNotPaused nonReentrant {
        Types.Service storage svc = _getService(serviceId);
        Types.JobCall storage job = _getJobCall(serviceId, callId);

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
        Types.Blueprint storage bp = _blueprints[svc.blueprintId];
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

                if (svc.pricing == Types.PricingModel.EventDriven && job.payment > 0) {
                    _distributeJobPayment(serviceId, job.payment);
                }
            }
        }
    }

    /// @notice Distribute payment for completed job - to be implemented in Payments mixin
    function _distributeJobPayment(uint64 serviceId, uint256 payment) internal virtual;
}
