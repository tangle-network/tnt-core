// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { IBlueprintServiceManager } from "./IBlueprintServiceManager.sol";
import { BlueprintServiceManagerBase } from "../BlueprintServiceManagerBase.sol";

/// @title IBlueprintHook
/// @notice Simplified hook interface for basic blueprint customization
/// @dev For full control, implement IBlueprintServiceManager directly.
///      This interface provides a simpler subset for common use cases.
///
/// Migration path:
/// - Simple blueprints: Use IBlueprintHook / BlueprintHookBase
/// - Full-featured blueprints: Use IBlueprintServiceManager / BlueprintServiceManagerBase
interface IBlueprintHook {
    // ═══════════════════════════════════════════════════════════════════════════
    // BLUEPRINT LIFECYCLE
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Called when blueprint is created
    function onBlueprintCreated(uint64 blueprintId, address owner) external;

    // ═══════════════════════════════════════════════════════════════════════════
    // OPERATOR LIFECYCLE
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Called when an operator registers
    /// @return accept True to accept registration
    function onOperatorRegister(
        uint64 blueprintId,
        address operator,
        bytes calldata data
    ) external returns (bool accept);

    /// @notice Called when an operator unregisters
    function onOperatorUnregister(uint64 blueprintId, address operator) external;

    // ═══════════════════════════════════════════════════════════════════════════
    // SERVICE LIFECYCLE
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Called when a service is requested
    /// @return accept True to accept request
    function onServiceRequest(
        uint64 requestId,
        uint64 blueprintId,
        address requester,
        address[] calldata operators,
        bytes calldata config
    ) external payable returns (bool accept);

    /// @notice Called when an operator approves a service request
    function onServiceApprove(uint64 requestId, address operator, uint8 restakingPercent) external;

    /// @notice Called when an operator rejects a service request
    function onServiceReject(uint64 requestId, address operator) external;

    /// @notice Called when service becomes active
    function onServiceActivated(
        uint64 serviceId,
        uint64 requestId,
        address owner,
        address[] calldata operators
    ) external;

    /// @notice Called when service is terminated
    function onServiceTerminated(uint64 serviceId, address owner) external;

    /// @notice Check if operator can join a dynamic service
    function canJoin(uint64 serviceId, address operator, uint16 exposureBps) external view returns (bool);

    /// @notice Check if operator can leave a dynamic service
    function canLeave(uint64 serviceId, address operator) external view returns (bool);

    // ═══════════════════════════════════════════════════════════════════════════
    // JOB LIFECYCLE
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Called when a job is submitted
    /// @return accept True to accept job
    function onJobSubmitted(
        uint64 serviceId,
        uint64 callId,
        uint8 jobIndex,
        address caller,
        bytes calldata inputs
    ) external payable returns (bool accept);

    /// @notice Called when an operator submits a result
    /// @return accept True to accept result
    function onJobResult(
        uint64 serviceId,
        uint64 callId,
        address operator,
        bytes calldata result
    ) external returns (bool accept);

    /// @notice Called when a job is marked complete
    function onJobCompleted(uint64 serviceId, uint64 callId, uint32 resultCount) external;

    // ═══════════════════════════════════════════════════════════════════════════
    // SLASHING
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Called before a slash is applied
    /// @return approve True to approve slash
    function onSlashProposed(
        uint64 serviceId,
        address operator,
        uint256 amount,
        bytes32 evidence
    ) external returns (bool approve);

    /// @notice Called after a slash is applied
    function onSlashApplied(uint64 serviceId, address operator, uint256 amount) external;

    // ═══════════════════════════════════════════════════════════════════════════
    // QUERIES
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Get the developer payment address
    function getDeveloperPaymentAddress(uint64 serviceId) external view returns (address payable);

    /// @notice Check if a payment token is allowed
    function isPaymentTokenAllowed(address token) external view returns (bool);

    /// @notice Get the number of results required for job completion
    function getRequiredResultCount(uint64 serviceId, uint8 jobIndex) external view returns (uint32);

    // ═══════════════════════════════════════════════════════════════════════════
    // BLS AGGREGATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Check if a job requires BLS aggregated results
    function requiresAggregation(uint64 serviceId, uint8 jobIndex) external view returns (bool);

    /// @notice Get the aggregation threshold configuration for a job
    /// @return thresholdBps Threshold in basis points (6700 = 67%)
    /// @return thresholdType 0 = CountBased (% of operators), 1 = StakeWeighted (% of total stake)
    function getAggregationThreshold(uint64 serviceId, uint8 jobIndex)
        external
        view
        returns (uint16 thresholdBps, uint8 thresholdType);

    /// @notice Called when an aggregated result is submitted
    function onAggregatedResult(
        uint64 serviceId,
        uint64 callId,
        uint256 signerBitmap,
        bytes calldata output
    ) external;
}

/// @title BlueprintHookBase
/// @notice Base implementation with sensible defaults
/// @dev For full features, extend BlueprintServiceManagerBase instead
abstract contract BlueprintHookBase is IBlueprintHook {
    function onBlueprintCreated(uint64, address) external virtual {}

    function onOperatorRegister(uint64, address, bytes calldata) external virtual returns (bool) {
        return true;
    }

    function onOperatorUnregister(uint64, address) external virtual {}

    function onServiceRequest(uint64, uint64, address, address[] calldata, bytes calldata)
        external
        payable
        virtual
        returns (bool)
    {
        return true;
    }

    function onServiceApprove(uint64, address, uint8) external virtual {}

    function onServiceReject(uint64, address) external virtual {}

    function onServiceActivated(uint64, uint64, address, address[] calldata) external virtual {}

    function onServiceTerminated(uint64, address) external virtual {}

    function canJoin(uint64, address, uint16) external view virtual returns (bool) {
        return true;
    }

    function canLeave(uint64, address) external view virtual returns (bool) {
        return true;
    }

    function onJobSubmitted(uint64, uint64, uint8, address, bytes calldata)
        external
        payable
        virtual
        returns (bool)
    {
        return true;
    }

    function onJobResult(uint64, uint64, address, bytes calldata) external virtual returns (bool) {
        return true;
    }

    function onJobCompleted(uint64, uint64, uint32) external virtual {}

    function onSlashProposed(uint64, address, uint256, bytes32) external virtual returns (bool) {
        return true;
    }

    function onSlashApplied(uint64, address, uint256) external virtual {}

    function getDeveloperPaymentAddress(uint64) external view virtual returns (address payable) {
        return payable(address(0));
    }

    function isPaymentTokenAllowed(address) external view virtual returns (bool) {
        return true;
    }

    function getRequiredResultCount(uint64, uint8) external view virtual returns (uint32) {
        return 1;
    }

    // BLS Aggregation defaults
    function requiresAggregation(uint64, uint8) external view virtual returns (bool) {
        return false; // No aggregation by default
    }

    function getAggregationThreshold(uint64, uint8) external view virtual returns (uint16, uint8) {
        return (6700, 0); // 67% count-based by default
    }

    function onAggregatedResult(uint64, uint64, uint256, bytes calldata) external virtual {}
}
