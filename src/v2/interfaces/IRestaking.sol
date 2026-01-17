// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Types } from "../libraries/Types.sol";

/// @title IRestaking
/// @notice Abstract interface for restaking/shared security protocols
/// @dev Implement this to integrate with native staking, EigenLayer, Symbiotic, etc.
///
/// Design principles:
/// - Minimal interface - only what Tangle core needs
/// - Read-heavy - most operations are queries
/// - Write-light - only slash() modifies state
/// - No assumptions about underlying implementation
interface IRestaking {
    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Emitted when an operator is slashed
    event OperatorSlashed(
        address indexed operator,
        uint64 indexed serviceId,
        uint16 slashBps,
        bytes32 evidence
    );

    // ═══════════════════════════════════════════════════════════════════════════
    // OPERATOR QUERIES
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Check if an address is a registered operator
    /// @param operator The address to check
    /// @return True if registered as operator
    function isOperator(address operator) external view returns (bool);

    /// @notice Check if an operator is currently active (not leaving, not slashed out)
    /// @param operator The address to check
    /// @return True if active
    function isOperatorActive(address operator) external view returns (bool);

    /// @notice Get an operator's total stake (self-stake + delegations)
    /// @param operator The operator address
    /// @return Total stake amount in native units
    function getOperatorStake(address operator) external view returns (uint256);

    /// @notice Get an operator's self-stake only
    /// @param operator The operator address
    /// @return Self-stake amount
    function getOperatorSelfStake(address operator) external view returns (uint256);

    /// @notice Get total amount delegated to an operator
    /// @param operator The operator address
    /// @return Total delegated amount
    function getOperatorDelegatedStake(address operator) external view returns (uint256);

    /// @notice Get total delegated amount for a specific asset
    /// @param operator The operator address
    /// @param asset The asset to query
    /// @return Total delegated amount for the asset
    function getOperatorDelegatedStakeForAsset(
        address operator,
        Types.Asset calldata asset
    ) external view returns (uint256);

    /// @notice Get total stake (self + delegated) for a specific asset
    /// @param operator The operator address
    /// @param asset The asset to query
    /// @return Total stake for the asset
    function getOperatorStakeForAsset(
        address operator,
        Types.Asset calldata asset
    ) external view returns (uint256);

    // ═══════════════════════════════════════════════════════════════════════════
    // DELEGATOR QUERIES
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Get a delegator's delegation to a specific operator
    /// @param delegator The delegator address
    /// @param operator The operator address
    /// @return Delegation amount
    function getDelegation(address delegator, address operator) external view returns (uint256);

    /// @notice Get a delegator's total delegations across all operators
    /// @param delegator The delegator address
    /// @return Total delegated amount
    function getTotalDelegation(address delegator) external view returns (uint256);

    // ═══════════════════════════════════════════════════════════════════════════
    // STAKE REQUIREMENTS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Get minimum stake required to be an operator
    /// @return Minimum stake amount
    function minOperatorStake() external view returns (uint256);

    /// @notice Check if operator meets a specific stake requirement
    /// @param operator The operator address
    /// @param required The required stake amount
    /// @return True if operator has sufficient stake
    function meetsStakeRequirement(address operator, uint256 required) external view returns (bool);

    // ═══════════════════════════════════════════════════════════════════════════
    // SLASHING
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Slash an operator's stake for a specific blueprint
    /// @dev Only affects delegators exposed to this blueprint (All mode + Fixed mode who selected it)
    /// @param operator The operator to slash
    /// @param blueprintId The blueprint where violation occurred
    /// @param serviceId The service where violation occurred
    /// @param slashBps Slash percentage in basis points
    /// @param evidence Evidence hash (IPFS or other reference)
    /// @return actualSlashed The actual amount slashed (may be less if insufficient stake)
    function slashForBlueprint(
        address operator,
        uint64 blueprintId,
        uint64 serviceId,
        uint16 slashBps,
        bytes32 evidence
    ) external returns (uint256 actualSlashed);

    /// @notice Slash an operator for a specific service, only slashing committed assets
    /// @dev Only slashes assets the operator committed to this service, proportionally
    /// @param operator The operator to slash
    /// @param blueprintId The blueprint where violation occurred
    /// @param serviceId The service where violation occurred
    /// @param commitments The operator's asset security commitments for this service
    /// @param slashBps Slash percentage in basis points
    /// @param evidence Evidence hash (IPFS or other reference)
    /// @return actualSlashed The actual amount slashed (may be less if insufficient committed stake)
    function slashForService(
        address operator,
        uint64 blueprintId,
        uint64 serviceId,
        Types.AssetSecurityCommitment[] calldata commitments,
        uint16 slashBps,
        bytes32 evidence
    ) external returns (uint256 actualSlashed);

    /// @notice Slash an operator's native stake for consensus violations (affects all native delegators)
    /// @dev Only callable by authorized slashers (e.g., Tangle core contract)
    /// @param operator The operator to slash
    /// @param serviceId The service where violation occurred
    /// @param slashBps Slash percentage in basis points
    /// @param evidence Evidence hash (IPFS or other reference)
    /// @return actualSlashed The actual amount slashed (may be less if insufficient stake)
    function slash(
        address operator,
        uint64 serviceId,
        uint16 slashBps,
        bytes32 evidence
    ) external returns (uint256 actualSlashed);

    /// @notice Check if an address is authorized to call slash()
    /// @param account The address to check
    /// @return True if authorized
    function isSlasher(address account) external view returns (bool);

    // ═══════════════════════════════════════════════════════════════════════════
    // BLUEPRINT MANAGEMENT (called by Tangle on operator registration)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Add a blueprint to an operator's supported list
    /// @dev Called by Tangle when operator registers for a blueprint
    /// @param operator The operator address
    /// @param blueprintId The blueprint to add
    function addBlueprintForOperator(address operator, uint64 blueprintId) external;

    /// @notice Remove a blueprint from an operator's supported list
    /// @dev Called by Tangle when operator unregisters from a blueprint
    /// @param operator The operator address
    /// @param blueprintId The blueprint to remove
    function removeBlueprintForOperator(address operator, uint64 blueprintId) external;

    // ═══════════════════════════════════════════════════════════════════════════
    // M-9 FIX: PENDING SLASH TRACKING
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Increment pending slash count for an operator
    /// @dev Called by Tangle when a slash is proposed
    /// @param operator The operator with a new pending slash
    function incrementPendingSlash(address operator) external;

    /// @notice Decrement pending slash count for an operator
    /// @dev Called by Tangle when a slash is executed or cancelled
    /// @param operator The operator whose pending slash was resolved
    function decrementPendingSlash(address operator) external;

    /// @notice Get pending slash count for an operator
    /// @param operator The operator to query
    /// @return count Number of pending slashes
    function getPendingSlashCount(address operator) external view returns (uint64);

}

/// @title IRestakingAdmin
/// @notice Admin functions for restaking implementations
/// @dev Separated to keep main interface clean
interface IRestakingAdmin {
    /// @notice Add an authorized slasher
    /// @param slasher Address to authorize
    function addSlasher(address slasher) external;

    /// @notice Remove an authorized slasher
    /// @param slasher Address to remove
    function removeSlasher(address slasher) external;

    /// @notice Set the Tangle contract for blueprint management
    /// @param tangle Address of the Tangle contract
    function setTangle(address tangle) external;

    /// @notice Update minimum operator stake
    /// @param amount New minimum
    function setMinOperatorStake(uint256 amount) external;
}
