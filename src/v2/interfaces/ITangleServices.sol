// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Types } from "../libraries/Types.sol";

/// @title ITangleServices
/// @notice Service lifecycle management interface
interface ITangleServices {
    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    event ServiceRequested(
        uint64 indexed requestId,
        uint64 indexed blueprintId,
        address indexed requester,
        address[] operators,
        bytes config,
        uint64 ttl,
        address paymentToken,
        uint256 paymentAmount
    );

    event ServiceRequestedWithSecurity(
        uint64 indexed requestId,
        uint64 indexed blueprintId,
        address indexed requester,
        address[] operators,
        Types.AssetSecurityRequirement[] securityRequirements
    );

    event ServiceCreatedFromQuotes(
        uint64 indexed serviceId,
        uint64 indexed blueprintId,
        address indexed owner,
        address[] operators
    );

    event ServiceApproved(uint64 indexed requestId, address indexed operator);

    event ServiceRejected(uint64 indexed requestId, address indexed operator);

    event ServiceActivated(
        uint64 indexed serviceId,
        uint64 indexed requestId,
        uint64 indexed blueprintId,
        address owner,
        address[] operators
    );

    event ServiceTerminated(uint64 indexed serviceId, address indexed owner);

    event OperatorJoinedService(uint64 indexed serviceId, address indexed operator, uint16 exposureBps);

    event OperatorLeftService(uint64 indexed serviceId, address indexed operator);

    event SubscriptionBilled(uint64 indexed serviceId, uint256 amount, uint64 billedAt);

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
    ) external payable returns (uint64 requestId);

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
    ) external payable returns (uint64 requestId);

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
    ) external payable returns (uint64 requestId);

    /// @notice Approve a service request (as operator) - simple version
    function approveService(uint64 requestId, uint8 restakingPercent) external;

    /// @notice Approve a service request with multi-asset security commitments
    /// @dev Commitments must match the security requirements specified in the request
    function approveServiceWithCommitments(
        uint64 requestId,
        Types.AssetSecurityCommitment[] calldata commitments
    ) external;

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
    ) external payable returns (uint64 serviceId);

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

    /// @notice Leave an active service (Dynamic membership only)
    function leaveService(uint64 serviceId) external;

    // ═══════════════════════════════════════════════════════════════════════════
    // BILLING FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Bill a subscription service for the current period
    function billSubscription(uint64 serviceId) external;

    // ═══════════════════════════════════════════════════════════════════════════
    // VIEW FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Get service request
    function getServiceRequest(uint64 requestId) external view returns (Types.ServiceRequest memory);

    /// @notice Get service info
    function getService(uint64 serviceId) external view returns (Types.Service memory);

    /// @notice Check if service is active
    function isServiceActive(uint64 serviceId) external view returns (bool);

    /// @notice Check if address is operator in service
    function isServiceOperator(uint64 serviceId, address operator) external view returns (bool);

    /// @notice Get operator info for a service
    function getServiceOperator(uint64 serviceId, address operator)
        external
        view
        returns (Types.ServiceOperator memory);

    /// @notice Get the list of operators for a service
    function getServiceOperators(uint64 serviceId) external view returns (address[] memory);

    /// @notice Get total exposure for a service
    function getServiceTotalExposure(uint64 serviceId) external view returns (uint256);

    /// @notice Check if address can call jobs on service
    function isPermittedCaller(uint64 serviceId, address caller) external view returns (bool);

    /// @notice Get current service count
    function serviceCount() external view returns (uint64);
}
