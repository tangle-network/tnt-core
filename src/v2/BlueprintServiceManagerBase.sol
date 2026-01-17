// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import { IBlueprintServiceManager } from "./interfaces/IBlueprintServiceManager.sol";

/// @title BlueprintServiceManagerBase
/// @notice Base implementation of IBlueprintServiceManager with sensible defaults
/// @dev Blueprint developers inherit from this and override only the hooks they need.
///      All hooks have safe default implementations that allow the operation to proceed.
///
/// Example usage:
/// ```solidity
/// contract MyAVSManager is BlueprintServiceManagerBase {
///     // Only override what you need
///     function onRegister(address operator, bytes calldata inputs)
///         external payable override onlyFromTangle
///     {
///         // Custom registration logic
///         require(customValidation(operator), "Invalid operator");
///     }
/// }
/// ```
contract BlueprintServiceManagerBase is IBlueprintServiceManager {
    using EnumerableSet for EnumerableSet.AddressSet;

    // ═══════════════════════════════════════════════════════════════════════════
    // ERRORS
    // ═══════════════════════════════════════════════════════════════════════════

    error OnlyTangleAllowed(address caller, address tangle);
    error OnlyBlueprintOwnerAllowed(address caller, address owner);
    error AlreadyInitialized();

    // ═══════════════════════════════════════════════════════════════════════════
    // STATE
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice The Tangle core contract address
    address public tangleCore;

    /// @notice The blueprint ID this manager handles
    uint64 public blueprintId;

    /// @notice The blueprint owner
    address public blueprintOwner;

    /// @notice Permitted payment assets per service
    /// @dev serviceId => set of permitted asset addresses
    mapping(uint64 => EnumerableSet.AddressSet) private _permittedPaymentAssets;

    // ═══════════════════════════════════════════════════════════════════════════
    // MODIFIERS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Restricts function to calls from Tangle core
    modifier onlyFromTangle() {
        _onlyFromTangle();
        _;
    }

    function _onlyFromTangle() internal view {
        if (msg.sender != tangleCore) {
            revert OnlyTangleAllowed(msg.sender, tangleCore);
        }
    }

    /// @notice Restricts function to blueprint owner
    modifier onlyBlueprintOwner() {
        if (msg.sender != blueprintOwner) {
            revert OnlyBlueprintOwnerAllowed(msg.sender, blueprintOwner);
        }
        _;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // BLUEPRINT LIFECYCLE
    // ═══════════════════════════════════════════════════════════════════════════

    /// @inheritdoc IBlueprintServiceManager
    function onBlueprintCreated(uint64 _blueprintId, address owner, address _tangleCore) external virtual {
        // Can only be set once
        if (tangleCore != address(0)) revert AlreadyInitialized();

        blueprintId = _blueprintId;
        blueprintOwner = owner;
        tangleCore = _tangleCore;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // OPERATOR LIFECYCLE
    // ═══════════════════════════════════════════════════════════════════════════

    /// @inheritdoc IBlueprintServiceManager
    function onRegister(address, bytes calldata) external payable virtual onlyFromTangle {
        // Accept all registrations by default
    }

    /// @inheritdoc IBlueprintServiceManager
    function onUnregister(address) external virtual onlyFromTangle {
        // No action by default
    }

    /// @inheritdoc IBlueprintServiceManager
    function onUpdatePreferences(address, bytes calldata) external payable virtual onlyFromTangle {
        // No action by default
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SERVICE CONFIGURATION QUERIES
    // ═══════════════════════════════════════════════════════════════════════════

    /// @inheritdoc IBlueprintServiceManager
    function getHeartbeatInterval(uint64) external view virtual returns (bool useDefault, uint64 interval) {
        return (true, 0); // Use protocol default
    }

    /// @inheritdoc IBlueprintServiceManager
    function getHeartbeatThreshold(uint64) external view virtual returns (bool useDefault, uint8 threshold) {
        return (true, 0); // Use protocol default
    }

    /// @inheritdoc IBlueprintServiceManager
    function getSlashingWindow(uint64) external view virtual returns (bool useDefault, uint64 window) {
        return (true, 0); // Use protocol default
    }

    /// @inheritdoc IBlueprintServiceManager
    function getExitConfig(uint64) external view virtual returns (
        bool useDefault,
        uint64 minCommitmentDuration,
        uint64 exitQueueDuration,
        bool forceExitAllowed
    ) {
        // Use protocol defaults:
        // - minCommitmentDuration: 1 day
        // - exitQueueDuration: 7 days
        // - forceExitAllowed: false
        return (true, 0, 0, false);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SERVICE LIFECYCLE
    // ═══════════════════════════════════════════════════════════════════════════

    /// @inheritdoc IBlueprintServiceManager
    function onRequest(uint64, address, address[] calldata, bytes calldata, uint64, address, uint256)
        external
        payable
        virtual
        onlyFromTangle
    {
        // Accept all requests by default
    }

    /// @inheritdoc IBlueprintServiceManager
    function onApprove(address, uint64, uint8) external payable virtual onlyFromTangle {
        // No action by default
    }

    /// @inheritdoc IBlueprintServiceManager
    function onReject(address, uint64) external virtual onlyFromTangle {
        // No action by default
    }

    /// @inheritdoc IBlueprintServiceManager
    function onServiceInitialized(uint64, uint64, uint64, address, address[] calldata, uint64)
        external
        virtual
        onlyFromTangle
    {
        // No action by default
    }

    /// @inheritdoc IBlueprintServiceManager
    function onServiceTermination(uint64, address) external virtual onlyFromTangle {
        // No action by default
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // DYNAMIC MEMBERSHIP
    // ═══════════════════════════════════════════════════════════════════════════

    /// @inheritdoc IBlueprintServiceManager
    function canJoin(uint64, address) external view virtual returns (bool) {
        return true; // Allow all joins by default
    }

    /// @inheritdoc IBlueprintServiceManager
    function onOperatorJoined(uint64, address, uint16) external virtual onlyFromTangle {
        // No action by default
    }

    /// @inheritdoc IBlueprintServiceManager
    function canLeave(uint64, address) external view virtual returns (bool) {
        return true; // Allow all leaves by default
    }

    /// @inheritdoc IBlueprintServiceManager
    function onOperatorLeft(uint64, address) external virtual onlyFromTangle {
        // No action by default
    }

    /// @inheritdoc IBlueprintServiceManager
    function onExitScheduled(uint64, address, uint64) external virtual onlyFromTangle {
        // No action by default
    }

    /// @inheritdoc IBlueprintServiceManager
    function onExitCanceled(uint64, address) external virtual onlyFromTangle {
        // No action by default
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // JOB LIFECYCLE
    // ═══════════════════════════════════════════════════════════════════════════

    /// @inheritdoc IBlueprintServiceManager
    function onJobCall(uint64, uint8, uint64, bytes calldata) external payable virtual onlyFromTangle {
        // Accept all jobs by default
    }

    /// @inheritdoc IBlueprintServiceManager
    function onJobResult(uint64, uint8, uint64, address, bytes calldata, bytes calldata)
        external
        payable
        virtual
        onlyFromTangle
    {
        // Accept all results by default
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SLASHING
    // ═══════════════════════════════════════════════════════════════════════════

    /// @inheritdoc IBlueprintServiceManager
    function onUnappliedSlash(uint64, bytes calldata, uint8) external virtual onlyFromTangle {
        // No action by default - slash proceeds after window
    }

    /// @inheritdoc IBlueprintServiceManager
    function onSlash(uint64, bytes calldata, uint8) external virtual onlyFromTangle {
        // No action by default
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // AUTHORIZATION QUERIES
    // ═══════════════════════════════════════════════════════════════════════════

    /// @inheritdoc IBlueprintServiceManager
    function querySlashingOrigin(uint64) external view virtual returns (address) {
        return address(this); // This contract is the slashing authority by default
    }

    /// @inheritdoc IBlueprintServiceManager
    function queryDisputeOrigin(uint64) external view virtual returns (address) {
        return address(this); // This contract handles disputes by default
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // PAYMENT QUERIES
    // ═══════════════════════════════════════════════════════════════════════════

    /// @inheritdoc IBlueprintServiceManager
    function queryDeveloperPaymentAddress(uint64) external view virtual returns (address payable) {
        return payable(blueprintOwner); // Blueprint owner receives developer share by default
    }

    /// @inheritdoc IBlueprintServiceManager
    function queryIsPaymentAssetAllowed(uint64 serviceId, address asset) external view virtual returns (bool) {
        // Native asset (address(0)) is always allowed
        if (asset == address(0)) {
            return true;
        }

        // If no specific assets configured, allow all
        if (_permittedPaymentAssets[serviceId].length() == 0) {
            return true;
        }

        // Check if asset is in permitted set
        return _permittedPaymentAssets[serviceId].contains(asset);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // JOB CONFIGURATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @inheritdoc IBlueprintServiceManager
    function getRequiredResultCount(uint64, uint8) external view virtual returns (uint32) {
        return 1; // Single result sufficient by default
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // BLS AGGREGATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @inheritdoc IBlueprintServiceManager
    function requiresAggregation(uint64, uint8) external view virtual returns (bool) {
        return false; // No aggregation required by default
    }

    /// @inheritdoc IBlueprintServiceManager
    function getAggregationThreshold(uint64, uint8) external view virtual returns (uint16, uint8) {
        // Default: 67% count-based threshold (only used if requiresAggregation returns true)
        return (6700, 0); // 67% threshold, CountBased
    }

    /// @inheritdoc IBlueprintServiceManager
    function onAggregatedResult(uint64, uint8, uint64, bytes calldata, uint256, uint256[2] calldata, uint256[4] calldata)
        external
        virtual
        onlyFromTangle
    {
        // Accept all aggregated results by default
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // STAKE REQUIREMENTS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @inheritdoc IBlueprintServiceManager
    function getMinOperatorStake() external view virtual returns (bool useDefault, uint256 minStake) {
        return (true, 0); // Use protocol default from restaking module
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // INTERNAL HELPERS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Permit a payment asset for a service
    /// @param serviceId The service ID
    /// @param asset The asset address to permit
    function _permitAsset(uint64 serviceId, address asset) internal virtual returns (bool) {
        return _permittedPaymentAssets[serviceId].add(asset);
    }

    /// @notice Revoke a payment asset for a service
    /// @param serviceId The service ID
    /// @param asset The asset address to revoke
    function _revokeAsset(uint64 serviceId, address asset) internal virtual returns (bool) {
        return _permittedPaymentAssets[serviceId].remove(asset);
    }

    /// @notice Clear all permitted assets for a service
    /// @param serviceId The service ID
    function _clearPermittedAssets(uint64 serviceId) internal virtual {
        EnumerableSet.AddressSet storage assets = _permittedPaymentAssets[serviceId];
        while (assets.length() > 0) {
            assets.remove(assets.at(0));
        }
    }

    /// @notice Get all permitted assets for a service
    /// @param serviceId The service ID
    /// @return Array of permitted asset addresses
    function _getPermittedAssets(uint64 serviceId) internal view virtual returns (address[] memory) {
        return _permittedPaymentAssets[serviceId].values();
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // PAYMENT RECEIVER
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Accept native token payments (e.g., developer revenue)
    /// @dev Override _onPaymentReceived to handle incoming payments
    receive() external payable virtual {
        _onPaymentReceived(address(0), msg.value);
    }

    /// @notice Hook called when native payments are received
    /// @dev Override this in child contracts to handle revenue
    /// @param token The token address (address(0) for native)
    /// @param amount The amount received
    function _onPaymentReceived(address token, uint256 amount) internal virtual {
        // Default: do nothing, just accumulate
        // Child contracts can override to distribute, buyback, etc.
    }
}
