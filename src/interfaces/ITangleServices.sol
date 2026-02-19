// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Types } from "../libraries/Types.sol";
import { PaymentLib } from "../libraries/PaymentLib.sol";

/// @title ITangleServices
/// @notice Service lifecycle management interface
interface ITangleServices {
    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    event ServiceRequested(uint64 indexed requestId, uint64 indexed blueprintId, address indexed requester);

    event ServiceRequestedWithSecurity(uint64 indexed requestId, uint64 indexed blueprintId, address indexed requester);

    event ServiceApproved(uint64 indexed requestId, address indexed operator);

    event ServiceRejected(uint64 indexed requestId, address indexed operator);

    event ServiceActivated(uint64 indexed serviceId, uint64 indexed requestId, uint64 indexed blueprintId);

    event ServiceTerminated(uint64 indexed serviceId);

    event OperatorJoinedService(uint64 indexed serviceId, address indexed operator, uint16 exposureBps);

    event OperatorLeftService(uint64 indexed serviceId, address indexed operator);

    event SubscriptionBilled(uint64 indexed serviceId, uint256 amount, uint64 period);

    // ═══════════════════════════════════════════════════════════════════════════
    // SERVICE REQUEST FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Request a new service
    function requestService(
        uint64 blueprintId,
        address[] calldata operators,
        bytes calldata config,
        address[] calldata permittedCallers,
        uint64 ttl,
        address paymentToken,
        uint256 paymentAmount
    )
        external
        payable
        returns (uint64 requestId);

    /// @notice Request a service with explicit exposure commitments
    function requestServiceWithExposure(
        uint64 blueprintId,
        address[] calldata operators,
        uint16[] calldata exposureBps,
        bytes calldata config,
        address[] calldata permittedCallers,
        uint64 ttl,
        address paymentToken,
        uint256 paymentAmount
    )
        external
        payable
        returns (uint64 requestId);

    /// @notice Request a service with multi-asset security requirements
    /// @dev Each operator must provide security commitments matching these requirements when approving
    function requestServiceWithSecurity(
        uint64 blueprintId,
        address[] calldata operators,
        Types.AssetSecurityRequirement[] calldata securityRequirements,
        bytes calldata config,
        address[] calldata permittedCallers,
        uint64 ttl,
        address paymentToken,
        uint256 paymentAmount
    )
        external
        payable
        returns (uint64 requestId);

    /// @notice Get resource requirements for a service request
    function getServiceRequestResourceRequirements(uint64 requestId)
        external
        view
        returns (Types.ResourceCommitment[] memory);

    /// @notice Approve a service request (as operator) - simple version
    function approveService(uint64 requestId, uint8 stakingPercent) external;

    /// @notice Approve a service request with multi-asset security commitments
    /// @dev Commitments must match the security requirements specified in the request
    function approveServiceWithCommitments(
        uint64 requestId,
        Types.AssetSecurityCommitment[] calldata commitments
    )
        external;

    /// @notice Approve a service request with BLS public key for aggregated signature verification
    /// @param requestId The service request ID
    /// @param stakingPercent The staking percentage (0-100)
    /// @param blsPubkey The operator's BLS G2 public key [x0, x1, y0, y1]
    function approveServiceWithBls(uint64 requestId, uint8 stakingPercent, uint256[4] calldata blsPubkey) external;

    /// @notice Approve a service request with both security commitments and BLS public key
    /// @param requestId The service request ID
    /// @param commitments Security commitments matching the request requirements
    /// @param blsPubkey The operator's BLS G2 public key [x0, x1, y0, y1]
    function approveServiceWithCommitmentsAndBls(
        uint64 requestId,
        Types.AssetSecurityCommitment[] calldata commitments,
        uint256[4] calldata blsPubkey
    )
        external;

    /// @notice Reject a service request (as operator)
    function rejectService(uint64 requestId) external;

    // ═══════════════════════════════════════════════════════════════════════════
    // RFQ (Request For Quote) - INSTANT SERVICE CREATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Create a service instantly using pre-signed operator quotes
    /// @dev No approval flow needed - operators have pre-committed via signatures
    /// @param blueprintId The blueprint to use
    /// @param quotes Array of signed quotes from operators
    /// @param config Service configuration
    /// @param permittedCallers Addresses allowed to call jobs
    /// @param ttl Service time-to-live (must match quotes)
    function createServiceFromQuotes(
        uint64 blueprintId,
        Types.SignedQuote[] calldata quotes,
        bytes calldata config,
        address[] calldata permittedCallers,
        uint64 ttl
    )
        external
        payable
        returns (uint64 serviceId);

    /// @notice Extend a service using pre-signed operator quotes
    function extendServiceFromQuotes(
        uint64 serviceId,
        Types.SignedQuote[] calldata quotes,
        uint64 extensionDuration
    )
        external
        payable;

    // ═══════════════════════════════════════════════════════════════════════════
    // SERVICE MANAGEMENT FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Terminate a service (as owner)
    function terminateService(uint64 serviceId) external;

    /// @notice Add a permitted caller to a service
    function addPermittedCaller(uint64 serviceId, address caller) external;

    /// @notice Remove a permitted caller from a service
    function removePermittedCaller(uint64 serviceId, address caller) external;

    // ═══════════════════════════════════════════════════════════════════════════
    // DYNAMIC MEMBERSHIP FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Join an active service (Dynamic membership only)
    function joinService(uint64 serviceId, uint16 exposureBps) external;

    /// @notice Join an active service with per-asset security commitments (Dynamic membership only)
    function joinServiceWithCommitments(
        uint64 serviceId,
        uint16 exposureBps,
        Types.AssetSecurityCommitment[] calldata commitments
    )
        external;

    /// @notice Leave an active service (Dynamic membership only)
    function leaveService(uint64 serviceId) external;

    /// @notice Schedule exit from an active service when exit queues are enabled
    function scheduleExit(uint64 serviceId) external;

    /// @notice Execute a scheduled exit after the queue delay
    function executeExit(uint64 serviceId) external;

    /// @notice Cancel a scheduled exit before execution
    function cancelExit(uint64 serviceId) external;

    /// @notice Force exit an operator from a service (if permitted by config)
    function forceExit(uint64 serviceId, address operator) external;

    /// @notice Force remove an operator from a service (blueprint manager only)
    /// @param serviceId The service ID
    /// @param operator The operator to remove
    function forceRemoveOperator(uint64 serviceId, address operator) external;

    // ═══════════════════════════════════════════════════════════════════════════
    // BILLING FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Bill a subscription service for the current period
    function billSubscription(uint64 serviceId) external;

    /// @notice Bill multiple subscription services in one call
    function billSubscriptionBatch(uint64[] calldata serviceIds)
        external
        returns (uint256 totalBilled, uint256 billedCount);

    /// @notice Get billable services from a list of candidates
    function getBillableServices(uint64[] calldata serviceIds) external view returns (uint64[] memory billable);

    /// @notice Fund a service escrow balance
    function fundService(uint64 serviceId, uint256 amount) external payable;

    /// @notice Withdraw remaining escrow after termination
    function withdrawRemainingEscrow(uint64 serviceId) external;

    // ═══════════════════════════════════════════════════════════════════════════
    // VIEW FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Get service request
    function getServiceRequest(uint64 requestId) external view returns (Types.ServiceRequest memory);

    /// @notice Get security requirements for a service request
    function getServiceRequestSecurityRequirements(uint64 requestId)
        external
        view
        returns (Types.AssetSecurityRequirement[] memory);

    /// @notice Get security commitments for a service request by operator
    function getServiceRequestSecurityCommitments(
        uint64 requestId,
        address operator
    )
        external
        view
        returns (Types.AssetSecurityCommitment[] memory);

    /// @notice Get service info
    function getService(uint64 serviceId) external view returns (Types.Service memory);

    /// @notice Check if service is active
    function isServiceActive(uint64 serviceId) external view returns (bool);

    /// @notice Check if address is operator in service
    function isServiceOperator(uint64 serviceId, address operator) external view returns (bool);

    /// @notice Get operator info for a service
    function getServiceOperator(uint64 serviceId, address operator) external view returns (Types.ServiceOperator memory);

    /// @notice Get the list of operators for a service
    function getServiceOperators(uint64 serviceId) external view returns (address[] memory);

    /// @notice Get persisted security requirements for an active service
    function getServiceSecurityRequirements(uint64 serviceId)
        external
        view
        returns (Types.AssetSecurityRequirement[] memory);

    /// @notice Get service escrow details
    function getServiceEscrow(uint64 serviceId) external view returns (PaymentLib.ServiceEscrow memory);

    /// @notice Get exit request for an operator
    function getExitRequest(uint64 serviceId, address operator) external view returns (Types.ExitRequest memory);

    /// @notice Get exit status for an operator
    function getExitStatus(uint64 serviceId, address operator) external view returns (Types.ExitStatus);

    /// @notice Get exit configuration for a service
    function getExitConfig(uint64 serviceId) external view returns (Types.ExitConfig memory);

    /// @notice Check if operator can schedule exit now
    function canScheduleExit(
        uint64 serviceId,
        address operator
    )
        external
        view
        returns (bool canExit, string memory reason);

    /// @notice Get persisted security commitments for an active service by operator
    function getServiceSecurityCommitments(
        uint64 serviceId,
        address operator
    )
        external
        view
        returns (Types.AssetSecurityCommitment[] memory);

    /// @notice Get total exposure for a service

    /// @notice Check if address can call jobs on service
    function isPermittedCaller(uint64 serviceId, address caller) external view returns (bool);

    /// @notice Get current service count
    function serviceCount() external view returns (uint64);

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
        returns (uint256[4] memory blsPubkey);

    /// @notice Get the resource commitment hash for an operator in a service
    /// @param serviceId The service ID
    /// @param operator The operator address
    /// @return The keccak256 of EIP-712-hashed ResourceCommitment[] (bytes32(0) if none)
    function getServiceResourceCommitmentHash(uint64 serviceId, address operator) external view returns (bytes32);
}
