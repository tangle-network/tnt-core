// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import { Base } from "./Base.sol";
import { Types } from "../libraries/Types.sol";
import { Errors } from "../libraries/Errors.sol";
import { IBlueprintServiceManager } from "../interfaces/IBlueprintServiceManager.sol";
import { IServiceFeeDistributor } from "../interfaces/IServiceFeeDistributor.sol";

/// @title ServicesLifecycle
/// @notice Service lifecycle (join/exit) flows and views
abstract contract ServicesLifecycle is Base {
    using EnumerableSet for EnumerableSet.AddressSet;

    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    event ServiceTerminated(uint64 indexed serviceId);
    event OperatorJoinedService(uint64 indexed serviceId, address indexed operator, uint16 exposureBps);
    event OperatorSecurityCommitmentsStored(uint64 indexed serviceId, address indexed operator, uint256 count);
    event OperatorSecurityCommitment(uint64 indexed serviceId, address indexed operator, uint8 assetKind, address asset, uint16 exposureBps);
    event OperatorLeftService(uint64 indexed serviceId, address indexed operator);
    event ExitScheduled(uint64 indexed serviceId, address indexed operator, uint64 executeAfter);
    event ExitCanceled(uint64 indexed serviceId, address indexed operator);
    event ExitForced(uint64 indexed serviceId, address indexed operator, address indexed forcer);
    // M-15 FIX: Event for tracking service fee distributor call failures
    event ServiceFeeDistributorCallFailed(uint64 indexed serviceId, string operation, bytes reason);

    // ═══════════════════════════════════════════════════════════════════════════
    // SERVICE LIFECYCLE
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Terminate a service
    function terminateService(uint64 serviceId) external {
        Types.Service storage svc = _getService(serviceId);
        if (svc.owner != msg.sender) {
            revert Errors.NotServiceOwner(serviceId, msg.sender);
        }

        svc.status = Types.ServiceStatus.Terminated;
        svc.terminatedAt = uint64(block.timestamp);

        // Decrement active service count for all operators in this service
        uint64 blueprintId = svc.blueprintId;
        uint256 operatorSetLength = _serviceOperatorSet[serviceId].length();
        for (uint256 i = 0; i < operatorSetLength; i++) {
            address operator = _serviceOperatorSet[serviceId].at(i);
            if (_operatorActiveServiceCount[blueprintId][operator] > 0) {
                _operatorActiveServiceCount[blueprintId][operator]--;
            }
        }

        emit ServiceTerminated(serviceId);

        // Refund remaining streamed payments to the service owner
        // M-15 FIX: Emit event on external call failure
        if (_serviceFeeDistributor != address(0)) {
            try IServiceFeeDistributor(_serviceFeeDistributor).onServiceTerminated(serviceId, svc.owner) {}
            catch (bytes memory reason) {
                emit ServiceFeeDistributorCallFailed(serviceId, "onServiceTerminated", reason);
            }
        }

        Types.Blueprint storage bp = _blueprints[svc.blueprintId];
        if (bp.manager != address(0)) {
            _tryCallManager(
                bp.manager,
                abi.encodeCall(IBlueprintServiceManager.onServiceTermination, (serviceId, msg.sender))
            );
        }
    }

    /// @notice Add permitted caller
    function addPermittedCaller(uint64 serviceId, address caller) external {
        Types.Service storage svc = _getService(serviceId);
        if (svc.owner != msg.sender) {
            revert Errors.NotServiceOwner(serviceId, msg.sender);
        }
        _permittedCallers[serviceId].add(caller);
    }

    /// @notice Remove permitted caller
    function removePermittedCaller(uint64 serviceId, address caller) external {
        Types.Service storage svc = _getService(serviceId);
        if (svc.owner != msg.sender) {
            revert Errors.NotServiceOwner(serviceId, msg.sender);
        }
        _permittedCallers[serviceId].remove(caller);
    }

    /// @notice Join a dynamic service
    function joinService(uint64 serviceId, uint16 exposureBps) external whenNotPaused nonReentrant {
        Types.Service storage svc = _getService(serviceId);
        if (svc.status != Types.ServiceStatus.Active) {
            revert Errors.ServiceNotActive(serviceId);
        }
        if (svc.membership != Types.MembershipModel.Dynamic) {
            revert Errors.InvalidState();
        }
        if (_serviceSecurityRequirements[serviceId].length > 0) {
            // Enforce explicit per-asset security commitments when the service requires them.
            revert Errors.SecurityCommitmentsRequired(serviceId);
        }
        if (svc.maxOperators > 0 && svc.operatorCount >= svc.maxOperators) {
            revert Errors.InvalidState();
        }
        if (_operatorRegistrations[svc.blueprintId][msg.sender].registeredAt == 0) {
            revert Errors.OperatorNotRegistered(svc.blueprintId, msg.sender);
        }
        if (_serviceOperators[serviceId][msg.sender].active) {
            revert Errors.InvalidState();
        }

        // Validate minimum stake requirement (re-check in case operator withdrew after registration)
        Types.Blueprint storage bp = _blueprints[svc.blueprintId];
        uint256 minStake = _restaking.minOperatorStake();
        if (bp.manager != address(0)) {
            try IBlueprintServiceManager(bp.manager).getMinOperatorStake() returns (bool useDefault, uint256 customMin) {
                if (!useDefault && customMin > 0) {
                    minStake = customMin;
                }
            } catch {}
        }
        if (!_restaking.meetsStakeRequirement(msg.sender, minStake)) {
            revert Errors.InsufficientStake(msg.sender, minStake, _restaking.getOperatorStake(msg.sender));
        }

        // Check if manager allows this operator to join
        if (bp.manager != address(0)) {
            try IBlueprintServiceManager(bp.manager).canJoin(serviceId, msg.sender) returns (bool allowed) {
                if (!allowed) {
                    revert Errors.Unauthorized();
                }
            } catch {}
        }

        _serviceOperators[serviceId][msg.sender] = Types.ServiceOperator({
            exposureBps: exposureBps,
            joinedAt: uint64(block.timestamp),
            leftAt: 0,
            active: true
        });
        _serviceOperatorSet[serviceId].add(msg.sender);
        svc.operatorCount++;

        // Track active service count per blueprint for operator unregistration checks
        _operatorActiveServiceCount[svc.blueprintId][msg.sender]++;

        emit OperatorJoinedService(serviceId, msg.sender, exposureBps);

        // Notify manager of successful join
        if (bp.manager != address(0)) {
            _tryCallManager(
                bp.manager,
                abi.encodeCall(IBlueprintServiceManager.onOperatorJoined, (serviceId, msg.sender, exposureBps))
            );
        }
    }

    /// @notice Join a dynamic service with per-asset security commitments
    function joinServiceWithCommitments(
        uint64 serviceId,
        uint16 exposureBps,
        Types.AssetSecurityCommitment[] calldata commitments
    ) external whenNotPaused nonReentrant {
        Types.Service storage svc = _getService(serviceId);
        if (svc.status != Types.ServiceStatus.Active) {
            revert Errors.ServiceNotActive(serviceId);
        }
        if (svc.membership != Types.MembershipModel.Dynamic) {
            revert Errors.InvalidState();
        }
        if (svc.maxOperators > 0 && svc.operatorCount >= svc.maxOperators) {
            revert Errors.InvalidState();
        }
        if (_operatorRegistrations[svc.blueprintId][msg.sender].registeredAt == 0) {
            revert Errors.OperatorNotRegistered(svc.blueprintId, msg.sender);
        }
        if (_serviceOperators[serviceId][msg.sender].active) {
            revert Errors.InvalidState();
        }

        Types.AssetSecurityRequirement[] storage requirements = _serviceSecurityRequirements[serviceId];
        if (requirements.length > 0) {
            _validateSecurityCommitments(requirements, commitments);
        }

        for (uint256 i = 0; i < commitments.length; i++) {
            _serviceSecurityCommitments[serviceId][msg.sender].push(commitments[i]);
            // forge-lint: disable-next-line(asm-keccak256)
            bytes32 assetHash = keccak256(abi.encode(commitments[i].asset.kind, commitments[i].asset.token));
            _serviceSecurityCommitmentBps[serviceId][msg.sender][assetHash] = commitments[i].exposureBps;
            emit OperatorSecurityCommitment(
                serviceId,
                msg.sender,
                uint8(commitments[i].asset.kind),
                commitments[i].asset.token,
                commitments[i].exposureBps
            );
        }
        emit OperatorSecurityCommitmentsStored(serviceId, msg.sender, commitments.length);

        // Validate minimum stake requirement (re-check in case operator withdrew after registration)
        Types.Blueprint storage bp = _blueprints[svc.blueprintId];
        uint256 minStake = _restaking.minOperatorStake();
        if (bp.manager != address(0)) {
            try IBlueprintServiceManager(bp.manager).getMinOperatorStake() returns (bool useDefault, uint256 customMin) {
                if (!useDefault && customMin > 0) {
                    minStake = customMin;
                }
            } catch {}
        }
        if (!_restaking.meetsStakeRequirement(msg.sender, minStake)) {
            revert Errors.InsufficientStake(msg.sender, minStake, _restaking.getOperatorStake(msg.sender));
        }

        // Check if manager allows this operator to join
        if (bp.manager != address(0)) {
            try IBlueprintServiceManager(bp.manager).canJoin(serviceId, msg.sender) returns (bool allowed) {
                if (!allowed) {
                    revert Errors.Unauthorized();
                }
            } catch {}
        }

        _serviceOperators[serviceId][msg.sender] = Types.ServiceOperator({
            exposureBps: exposureBps,
            joinedAt: uint64(block.timestamp),
            leftAt: 0,
            active: true
        });
        _serviceOperatorSet[serviceId].add(msg.sender);
        svc.operatorCount++;

        // Track active service count per blueprint for operator unregistration checks
        _operatorActiveServiceCount[svc.blueprintId][msg.sender]++;

        emit OperatorJoinedService(serviceId, msg.sender, exposureBps);

        // Notify manager of successful join
        if (bp.manager != address(0)) {
            _tryCallManager(
                bp.manager,
                abi.encodeCall(IBlueprintServiceManager.onOperatorJoined, (serviceId, msg.sender, exposureBps))
            );
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // EXIT QUEUE
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Schedule exit from a dynamic service
    /// @dev Operator must wait for exit queue duration before executing
    function scheduleExit(uint64 serviceId) external nonReentrant {
        Types.Service storage svc = _getService(serviceId);
        if (svc.membership != Types.MembershipModel.Dynamic) {
            revert Errors.InvalidState();
        }

        Types.ServiceOperator storage opData = _serviceOperators[serviceId][msg.sender];
        if (!opData.active) {
            revert Errors.OperatorNotInService(serviceId, msg.sender);
        }

        // Check if already scheduled
        Types.ExitRequest storage exitReq = _exitRequests[serviceId][msg.sender];
        if (exitReq.pending) {
            revert Errors.ExitAlreadyScheduled(serviceId, msg.sender);
        }

        // Get exit config
        Types.ExitConfig memory exitConfig = _getExitConfig(svc.blueprintId, serviceId);

        // Check minimum commitment duration
        uint64 minCommitmentEnd = opData.joinedAt + exitConfig.minCommitmentDuration;
        if (block.timestamp < minCommitmentEnd) {
            revert Errors.ExitTooEarly(serviceId, msg.sender, minCommitmentEnd, uint64(block.timestamp));
        }

        // Calculate when exit can be executed
        uint64 executeAfter = uint64(block.timestamp) + exitConfig.exitQueueDuration;

        // Store exit request
        _exitRequests[serviceId][msg.sender] = Types.ExitRequest({
            serviceId: serviceId,
            scheduledAt: uint64(block.timestamp),
            executeAfter: executeAfter,
            pending: true
        });

        emit ExitScheduled(serviceId, msg.sender, executeAfter);

        // Notify manager
        Types.Blueprint storage bp = _blueprints[svc.blueprintId];
        if (bp.manager != address(0)) {
            _tryCallManager(
                bp.manager,
                abi.encodeCall(IBlueprintServiceManager.onExitScheduled, (serviceId, msg.sender, executeAfter))
            );
        }
    }

    /// @notice Execute a scheduled exit
    /// @dev Can only be called after exit queue duration has passed
    function executeExit(uint64 serviceId) external nonReentrant {
        Types.ExitRequest storage exitReq = _exitRequests[serviceId][msg.sender];
        if (!exitReq.pending) {
            revert Errors.ExitNotScheduled(serviceId, msg.sender);
        }

        if (block.timestamp < exitReq.executeAfter) {
            revert Errors.ExitNotExecutable(serviceId, msg.sender, exitReq.executeAfter, uint64(block.timestamp));
        }

        _executeLeave(serviceId, msg.sender);

        // Clear exit request
        delete _exitRequests[serviceId][msg.sender];
    }

    /// @notice Cancel a scheduled exit
    function cancelExit(uint64 serviceId) external nonReentrant {
        Types.ExitRequest storage exitReq = _exitRequests[serviceId][msg.sender];
        if (!exitReq.pending) {
            revert Errors.ExitNotScheduled(serviceId, msg.sender);
        }

        // Clear exit request
        delete _exitRequests[serviceId][msg.sender];

        emit ExitCanceled(serviceId, msg.sender);

        // Notify manager
        Types.Service storage svc = _getService(serviceId);
        Types.Blueprint storage bp = _blueprints[svc.blueprintId];
        if (bp.manager != address(0)) {
            _tryCallManager(
                bp.manager,
                abi.encodeCall(IBlueprintServiceManager.onExitCanceled, (serviceId, msg.sender))
            );
        }
    }

    /// @notice Force an operator to exit (service owner only, if allowed)
    /// @dev Requires forceExitAllowed in exit config
    function forceExit(uint64 serviceId, address operator) external nonReentrant {
        Types.Service storage svc = _getService(serviceId);
        if (svc.owner != msg.sender) {
            revert Errors.NotServiceOwner(serviceId, msg.sender);
        }

        Types.ExitConfig memory exitConfig = _getExitConfig(svc.blueprintId, serviceId);
        if (!exitConfig.forceExitAllowed) {
            revert Errors.ForceExitNotAllowed(serviceId);
        }

        Types.ServiceOperator storage opData = _serviceOperators[serviceId][operator];
        if (!opData.active) {
            revert Errors.OperatorNotInService(serviceId, operator);
        }

        _executeLeave(serviceId, operator);

        // Clear any pending exit request
        delete _exitRequests[serviceId][operator];

        emit ExitForced(serviceId, operator, msg.sender);
    }

    /// @notice Convenience leave function - schedules and immediately executes if allowed
    /// @dev For backwards compatibility. Will fail if exit queue duration > 0
    function leaveService(uint64 serviceId) external nonReentrant {
        Types.Service storage svc = _getService(serviceId);
        if (svc.membership != Types.MembershipModel.Dynamic) {
            revert Errors.InvalidState();
        }

        Types.ServiceOperator storage opData = _serviceOperators[serviceId][msg.sender];
        if (!opData.active) {
            revert Errors.OperatorNotInService(serviceId, msg.sender);
        }

        Types.ExitConfig memory exitConfig = _getExitConfig(svc.blueprintId, serviceId);

        // Check minimum commitment duration
        uint64 minCommitmentEnd = opData.joinedAt + exitConfig.minCommitmentDuration;
        if (block.timestamp < minCommitmentEnd) {
            revert Errors.ExitTooEarly(serviceId, msg.sender, minCommitmentEnd, uint64(block.timestamp));
        }

        // If exit queue is required, must use scheduleExit/executeExit
        if (exitConfig.exitQueueDuration > 0) {
            revert Errors.ExitNotExecutable(
                serviceId,
                msg.sender,
                uint64(block.timestamp) + exitConfig.exitQueueDuration,
                uint64(block.timestamp)
            );
        }

        _executeLeave(serviceId, msg.sender);
    }

    /// @notice Internal function to execute operator leave
    function _executeLeave(uint64 serviceId, address operator) internal {
        Types.Service storage svc = _getService(serviceId);

        if (svc.operatorCount <= svc.minOperators) {
            revert Errors.InvalidState();
        }

        Types.ServiceOperator storage opData = _serviceOperators[serviceId][operator];
        if (!opData.active) {
            revert Errors.OperatorNotInService(serviceId, operator);
        }

        // Check if manager allows this operator to leave
        Types.Blueprint storage bp = _blueprints[svc.blueprintId];
        if (bp.manager != address(0)) {
            try IBlueprintServiceManager(bp.manager).canLeave(serviceId, operator) returns (bool allowed) {
                if (!allowed) {
                    revert Errors.Unauthorized();
                }
            } catch {}
        }

        // Drip streaming payments BEFORE removing operator (ensures fair distribution)
        // M-15 FIX: Emit event on external call failure
        if (_serviceFeeDistributor != address(0)) {
            try IServiceFeeDistributor(_serviceFeeDistributor).onOperatorLeaving(serviceId, operator) {}
            catch (bytes memory reason) {
                emit ServiceFeeDistributorCallFailed(serviceId, "onOperatorLeaving", reason);
            }
        }

        opData.active = false;
        opData.leftAt = uint64(block.timestamp);
        _serviceOperatorSet[serviceId].remove(operator);
        svc.operatorCount--;

        // Decrement active service count for operator unregistration checks
        if (_operatorActiveServiceCount[svc.blueprintId][operator] > 0) {
            _operatorActiveServiceCount[svc.blueprintId][operator]--;
        }

        emit OperatorLeftService(serviceId, operator);

        // Notify manager of successful leave
        if (bp.manager != address(0)) {
            _tryCallManager(
                bp.manager,
                abi.encodeCall(IBlueprintServiceManager.onOperatorLeft, (serviceId, operator))
            );
        }
    }

    /// @notice Force remove operator from service - EMERGENCY USE ONLY
    /// @dev WARNING: Bypasses exit queue and minimum operator checks.
    /// Blueprint managers should use this sparingly as it can degrade service.
    /// Only callable by the blueprint manager.
    /// @param serviceId The service ID
    /// @param operator The operator to remove
    function forceRemoveOperator(uint64 serviceId, address operator) external nonReentrant {
        Types.Service storage svc = _getService(serviceId);
        Types.Blueprint storage bp = _blueprints[svc.blueprintId];

        // Only blueprint manager can force remove
        if (msg.sender != bp.manager) {
            revert Errors.Unauthorized();
        }

        Types.ServiceOperator storage opData = _serviceOperators[serviceId][operator];
        if (!opData.active) {
            revert Errors.OperatorNotInService(serviceId, operator);
        }

        // Don't check min operators - force removal is an emergency action
        // Don't check exit queue - this bypasses normal exit process

        // Drip streaming payments before removal
        // M-15 FIX: Emit event on external call failure
        if (_serviceFeeDistributor != address(0)) {
            try IServiceFeeDistributor(_serviceFeeDistributor).onOperatorLeaving(serviceId, operator) {}
            catch (bytes memory reason) {
                emit ServiceFeeDistributorCallFailed(serviceId, "onOperatorLeaving", reason);
            }
        }

        opData.active = false;
        opData.leftAt = uint64(block.timestamp);
        _serviceOperatorSet[serviceId].remove(operator);
        svc.operatorCount--;

        // Decrement active service count for operator unregistration checks
        if (_operatorActiveServiceCount[svc.blueprintId][operator] > 0) {
            _operatorActiveServiceCount[svc.blueprintId][operator]--;
        }

        // Clear any pending exit request
        delete _exitRequests[serviceId][operator];

        emit OperatorLeftService(serviceId, operator);

        // Notify manager (it called us, but we still notify for consistency)
        _tryCallManager(
            bp.manager,
            abi.encodeCall(IBlueprintServiceManager.onOperatorLeft, (serviceId, operator))
        );
    }

    /// @notice Get exit configuration for a service
    /// @dev Checks manager hook first, falls back to protocol defaults
    function _getExitConfig(uint64 blueprintId, uint64 serviceId) internal view returns (Types.ExitConfig memory config) {
        Types.Blueprint storage bp = _blueprints[blueprintId];

        // Check if manager provides custom exit config
        if (bp.manager != address(0)) {
            try IBlueprintServiceManager(bp.manager).getExitConfig(serviceId) returns (
                bool useDefault,
                uint64 minCommitmentDuration,
                uint64 exitQueueDuration,
                bool forceExitAllowed
            ) {
                if (!useDefault) {
                    return Types.ExitConfig({
                        minCommitmentDuration: minCommitmentDuration,
                        exitQueueDuration: exitQueueDuration,
                        forceExitAllowed: forceExitAllowed
                    });
                }
            } catch {}
        }

        // Use protocol defaults
        return Types.ExitConfig({
            minCommitmentDuration: DEFAULT_MIN_COMMITMENT_DURATION,
            exitQueueDuration: DEFAULT_EXIT_QUEUE_DURATION,
            forceExitAllowed: false
        });
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // EXIT QUEUE VIEW FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Get exit request for an operator
    function getExitRequest(uint64 serviceId, address operator) external view returns (Types.ExitRequest memory) {
        return _exitRequests[serviceId][operator];
    }

    /// @notice Get exit status for an operator
    function getExitStatus(uint64 serviceId, address operator) external view returns (Types.ExitStatus) {
        Types.ExitRequest storage exitReq = _exitRequests[serviceId][operator];

        if (!exitReq.pending) {
            Types.ServiceOperator storage opData = _serviceOperators[serviceId][operator];
            if (opData.leftAt > 0) {
                return Types.ExitStatus.Completed;
            }
            return Types.ExitStatus.None;
        }

        if (block.timestamp >= exitReq.executeAfter) {
            return Types.ExitStatus.Executable;
        }

        return Types.ExitStatus.Scheduled;
    }

    /// @notice Get exit config for a service
    function getExitConfig(uint64 serviceId) external view returns (Types.ExitConfig memory) {
        Types.Service storage svc = _services[serviceId];
        return _getExitConfig(svc.blueprintId, serviceId);
    }

    /// @notice Check if operator can schedule exit now
    function canScheduleExit(uint64 serviceId, address operator) external view returns (bool canExit, string memory reason) {
        Types.Service storage svc = _services[serviceId];
        if (svc.membership != Types.MembershipModel.Dynamic) {
            return (false, "Not dynamic membership");
        }

        Types.ServiceOperator storage opData = _serviceOperators[serviceId][operator];
        if (!opData.active) {
            return (false, "Not in service");
        }

        Types.ExitRequest storage exitReq = _exitRequests[serviceId][operator];
        if (exitReq.pending) {
            return (false, "Exit already scheduled");
        }

        Types.ExitConfig memory exitConfig = _getExitConfig(svc.blueprintId, serviceId);
        uint64 minCommitmentEnd = opData.joinedAt + exitConfig.minCommitmentDuration;
        if (block.timestamp < minCommitmentEnd) {
            return (false, "Minimum commitment not met");
        }

        return (true, "");
    }

    /// @notice Validate security commitments
    function _validateSecurityCommitments(
        Types.AssetSecurityRequirement[] storage requirements,
        Types.AssetSecurityCommitment[] calldata commitments
    ) internal view {
        for (uint256 i = 0; i < commitments.length; i++) {
            for (uint256 j = i + 1; j < commitments.length; j++) {
                if (commitments[i].asset.token == commitments[j].asset.token &&
                    commitments[i].asset.kind == commitments[j].asset.kind) {
                    revert Errors.DuplicateAssetCommitment(uint8(commitments[i].asset.kind), commitments[i].asset.token);
                }
            }
        }

        for (uint256 i = 0; i < requirements.length; i++) {
            Types.AssetSecurityRequirement storage req = requirements[i];
            bool found = false;

            for (uint256 j = 0; j < commitments.length; j++) {
                if (commitments[j].asset.token == req.asset.token &&
                    commitments[j].asset.kind == req.asset.kind) {
                    if (commitments[j].exposureBps < req.minExposureBps) {
                        revert Errors.CommitmentBelowMinimum(req.asset.token, commitments[j].exposureBps, req.minExposureBps);
                    }
                    if (commitments[j].exposureBps > req.maxExposureBps) {
                        revert Errors.CommitmentAboveMaximum(req.asset.token, commitments[j].exposureBps, req.maxExposureBps);
                    }
                    found = true;
                    break;
                }
            }

            if (!found) {
                revert Errors.MissingAssetCommitment(req.asset.token);
            }
        }
    }
}
