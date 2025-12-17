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
        uint256 amount,
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
    /// @param amount Amount to slash
    /// @param evidence Evidence hash (IPFS or other reference)
    /// @return actualSlashed The actual amount slashed (may be less if insufficient stake)
    function slashForBlueprint(
        address operator,
        uint64 blueprintId,
        uint64 serviceId,
        uint256 amount,
        bytes32 evidence
    ) external returns (uint256 actualSlashed);

    /// @notice Slash an operator for a specific service, only slashing committed assets
    /// @dev Only slashes assets the operator committed to this service, proportionally
    /// @param operator The operator to slash
    /// @param blueprintId The blueprint where violation occurred
    /// @param serviceId The service where violation occurred
    /// @param commitments The operator's asset security commitments for this service
    /// @param amount Amount to slash
    /// @param evidence Evidence hash (IPFS or other reference)
    /// @return actualSlashed The actual amount slashed (may be less if insufficient committed stake)
    function slashForService(
        address operator,
        uint64 blueprintId,
        uint64 serviceId,
        Types.AssetSecurityCommitment[] calldata commitments,
        uint256 amount,
        bytes32 evidence
    ) external returns (uint256 actualSlashed);

    /// @notice Slash an operator's stake (legacy - slashes all delegators)
    /// @dev Only callable by authorized slashers (e.g., Tangle core contract)
    /// @param operator The operator to slash
    /// @param serviceId The service where violation occurred
    /// @param amount Amount to slash
    /// @param evidence Evidence hash (IPFS or other reference)
    /// @return actualSlashed The actual amount slashed (may be less if insufficient stake)
    function slash(
        address operator,
        uint64 serviceId,
        uint256 amount,
        bytes32 evidence
    ) external returns (uint256 actualSlashed);

    /// @notice Check if an address is authorized to call slash()
    /// @param account The address to check
    /// @return True if authorized
    function isSlasher(address account) external view returns (bool);

    // ═══════════════════════════════════════════════════════════════════════════
    // REWARD COORDINATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Notify the restaking module of rewards from a specific blueprint
    /// @dev Routes rewards to appropriate pools based on delegator blueprint exposure
    /// @param operator The operator receiving rewards
    /// @param blueprintId The blueprint generating rewards
    /// @param serviceId The service generating rewards
    /// @param amount Reward amount
    function notifyRewardForBlueprint(
        address operator,
        uint64 blueprintId,
        uint64 serviceId,
        uint256 amount
    ) external;

    /// @notice Notify the restaking module of rewards to distribute (legacy)
    /// @dev Called by Tangle core after service payments
    /// @param operator The operator receiving rewards
    /// @param serviceId The service generating rewards
    /// @param amount Reward amount
    function notifyReward(
        address operator,
        uint64 serviceId,
        uint256 amount
    ) external;
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

    /// @notice Update minimum operator stake
    /// @param amount New minimum
    function setMinOperatorStake(uint256 amount) external;
}
