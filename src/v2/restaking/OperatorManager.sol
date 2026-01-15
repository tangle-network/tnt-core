// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import { DelegationStorage } from "./DelegationStorage.sol";
import { DelegationErrors } from "./DelegationErrors.sol";
import { Types } from "../libraries/Types.sol";

/// @title OperatorManager
/// @notice Manages operator registration, stake, and lifecycle
/// @dev Inherits storage layout from DelegationStorage
abstract contract OperatorManager is DelegationStorage {
    using SafeERC20 for IERC20;
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;

    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    event OperatorRegistered(address indexed operator, uint256 stake);
    event OperatorStakeIncreased(address indexed operator, uint256 amount);
    event OperatorUnstakeScheduled(address indexed operator, uint256 amount, uint64 readyRound);
    event OperatorUnstakeExecuted(address indexed operator, uint256 amount);
    event OperatorLeavingScheduled(address indexed operator, uint64 readyRound);
    event OperatorLeft(address indexed operator);
    event OperatorBlueprintAdded(address indexed operator, uint64 indexed blueprintId);
    event OperatorBlueprintRemoved(address indexed operator, uint64 indexed blueprintId);

    // ═══════════════════════════════════════════════════════════════════════════
    // REGISTRATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Register as an operator with native stake
    /// @dev Caller must send ETH >= minOperatorStake
    function _registerOperatorNative() internal {
        if (_operatorBondToken != address(0)) {
            revert DelegationErrors.OperatorBondTokenOnly(_operatorBondToken);
        }
        if (_operators.contains(msg.sender)) {
            revert DelegationErrors.OperatorAlreadyRegistered(msg.sender);
        }

        bytes32 nativeHash = _assetHash(Types.Asset(Types.AssetKind.Native, address(0)));
        Types.AssetConfig storage config = _assetConfigs[nativeHash];

        if (!config.enabled) revert DelegationErrors.AssetNotEnabled(address(0));
        if (msg.value < config.minOperatorStake) {
            revert DelegationErrors.InsufficientStake(config.minOperatorStake, msg.value);
        }

        _operators.add(msg.sender);
        _operatorMetadata[msg.sender] = Types.OperatorMetadata({
            stake: msg.value,
            delegationCount: 0,
            status: Types.OperatorStatus.Active,
            leavingRound: 0
        });

        emit OperatorRegistered(msg.sender, msg.value);
    }

    /// @notice Register as operator with ERC20 stake
    /// @param token The ERC20 token to stake
    /// @param amount Amount to stake
    function _registerOperatorWithAsset(address token, uint256 amount) internal {
        if (_operators.contains(msg.sender)) {
            revert DelegationErrors.OperatorAlreadyRegistered(msg.sender);
        }
        if (_operatorBondToken == address(0) || token != _operatorBondToken) {
            revert DelegationErrors.OperatorBondTokenOnly(_operatorBondToken);
        }
        if (token == address(0)) revert DelegationErrors.AssetNotEnabled(address(0));

        bytes32 assetHash = _assetHash(Types.Asset(Types.AssetKind.ERC20, token));
        Types.AssetConfig storage config = _assetConfigs[assetHash];

        if (!config.enabled) revert DelegationErrors.AssetNotEnabled(token);
        if (amount < config.minOperatorStake) {
            revert DelegationErrors.InsufficientStake(config.minOperatorStake, amount);
        }

        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);

        _operators.add(msg.sender);
        _operatorMetadata[msg.sender] = Types.OperatorMetadata({
            stake: amount,
            delegationCount: 0,
            status: Types.OperatorStatus.Active,
            leavingRound: 0
        });

        emit OperatorRegistered(msg.sender, amount);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // STAKE MANAGEMENT
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Increase operator stake with native token
    function _increaseStakeNative() internal {
        if (_operatorBondToken != address(0)) {
            revert DelegationErrors.OperatorBondTokenOnly(_operatorBondToken);
        }
        Types.OperatorMetadata storage meta = _operatorMetadata[msg.sender];
        if (meta.status != Types.OperatorStatus.Active) {
            revert DelegationErrors.OperatorNotActive(msg.sender);
        }
        if (msg.value == 0) revert DelegationErrors.ZeroAmount();

        meta.stake += msg.value;
        emit OperatorStakeIncreased(msg.sender, msg.value);
    }

    /// @notice Increase operator stake with ERC20 bond token
    function _increaseStakeWithAsset(address token, uint256 amount) internal {
        if (_operatorBondToken == address(0) || token != _operatorBondToken) {
            revert DelegationErrors.OperatorBondTokenOnly(_operatorBondToken);
        }
        Types.OperatorMetadata storage meta = _operatorMetadata[msg.sender];
        if (meta.status != Types.OperatorStatus.Active) {
            revert DelegationErrors.OperatorNotActive(msg.sender);
        }
        if (amount == 0) revert DelegationErrors.ZeroAmount();

        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        meta.stake += amount;
        emit OperatorStakeIncreased(msg.sender, amount);
    }

    /// @notice Schedule operator stake reduction
    /// @param amount Amount to unstake
    function _scheduleOperatorUnstake(uint256 amount) internal {
        Types.OperatorMetadata storage meta = _operatorMetadata[msg.sender];
        if (meta.status != Types.OperatorStatus.Active) {
            revert DelegationErrors.OperatorNotActive(msg.sender);
        }
        if (amount == 0) revert DelegationErrors.ZeroAmount();

        // Check minimum stake requirement after unstake
        bytes32 bondHash = _operatorBondToken == address(0)
            ? _assetHash(Types.Asset(Types.AssetKind.Native, address(0)))
            : _assetHash(Types.Asset(Types.AssetKind.ERC20, _operatorBondToken));
        uint256 minStake = _assetConfigs[bondHash].minOperatorStake;

        // Include pending unstakes
        uint256 pendingUnstake = _operatorBondLessRequests[msg.sender].amount;
        uint256 availableStake = meta.stake - pendingUnstake;

        if (availableStake - amount < minStake) {
            revert DelegationErrors.InsufficientStake(minStake, availableStake - amount);
        }

        _operatorBondLessRequests[msg.sender] = Types.OperatorBondLessRequest({
            amount: pendingUnstake + amount,
            requestedRound: currentRound
        });

        emit OperatorUnstakeScheduled(msg.sender, amount, currentRound + delegationBondLessDelay);
    }

    /// @notice Execute pending operator unstake
    function _executeOperatorUnstake() internal returns (uint256 unstaked) {
        Types.OperatorBondLessRequest storage request = _operatorBondLessRequests[msg.sender];

        if (request.amount == 0) return 0;
        if (currentRound < request.requestedRound + delegationBondLessDelay) {
            revert DelegationErrors.LeavingTooEarly(currentRound, request.requestedRound + delegationBondLessDelay);
        }

        unstaked = request.amount;
        _operatorMetadata[msg.sender].stake -= unstaked;

        delete _operatorBondLessRequests[msg.sender];

        if (_operatorBondToken == address(0)) {
            // Transfer native tokens back
            (bool success,) = msg.sender.call{ value: unstaked }("");
            require(success, "Transfer failed");
        } else {
            IERC20(_operatorBondToken).safeTransfer(msg.sender, unstaked);
        }

        emit OperatorUnstakeExecuted(msg.sender, unstaked);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // OPERATOR LEAVING
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Schedule leaving as operator
    function _startLeaving() internal {
        Types.OperatorMetadata storage meta = _operatorMetadata[msg.sender];
        if (meta.status != Types.OperatorStatus.Active) {
            revert DelegationErrors.OperatorNotActive(msg.sender);
        }

        meta.status = Types.OperatorStatus.Leaving;
        meta.leavingRound = currentRound;

        emit OperatorLeavingScheduled(msg.sender, currentRound + leaveOperatorsDelay);
    }

    /// @notice Complete leaving and withdraw all stake
    function _completeLeaving() internal returns (uint256 stake) {
        Types.OperatorMetadata storage meta = _operatorMetadata[msg.sender];
        if (meta.status != Types.OperatorStatus.Leaving) {
            revert DelegationErrors.OperatorNotLeaving(msg.sender);
        }
        if (currentRound < meta.leavingRound + leaveOperatorsDelay) {
            revert DelegationErrors.LeavingTooEarly(currentRound, meta.leavingRound + leaveOperatorsDelay);
        }

        stake = meta.stake;
        meta.stake = 0;
        meta.status = Types.OperatorStatus.Inactive;
        _operators.remove(msg.sender);

        if (_operatorBondToken == address(0)) {
            // Return stake
            (bool success,) = msg.sender.call{ value: stake }("");
            require(success, "Transfer failed");
        } else {
            IERC20(_operatorBondToken).safeTransfer(msg.sender, stake);
        }

        emit OperatorLeft(msg.sender);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // BLUEPRINT MANAGEMENT (called by Tangle on operator registration)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Add blueprint support for an operator
    /// @dev Called by Tangle when operator registers for a blueprint
    /// @param operator The operator address
    /// @param blueprintId Blueprint to add
    function _addBlueprintForOperator(address operator, uint64 blueprintId) internal {
        if (_operatorMetadata[operator].status != Types.OperatorStatus.Active) {
            revert DelegationErrors.OperatorNotActive(operator);
        }
        _operatorBlueprints[operator].add(blueprintId);
        emit OperatorBlueprintAdded(operator, blueprintId);
    }

    /// @notice Remove blueprint support for an operator
    /// @dev Called by Tangle when operator unregisters from a blueprint
    /// @param operator The operator address
    /// @param blueprintId Blueprint to remove
    function _removeBlueprintForOperator(address operator, uint64 blueprintId) internal {
        _operatorBlueprints[operator].remove(blueprintId);
        emit OperatorBlueprintRemoved(operator, blueprintId);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // VIEW FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Check if address is a registered operator
    function _isOperator(address operator) internal view returns (bool) {
        return _operators.contains(operator);
    }

    /// @notice Check if operator is active (registered and not leaving)
    function _isOperatorActive(address operator) internal view returns (bool) {
        return _operators.contains(operator) &&
               _operatorMetadata[operator].status == Types.OperatorStatus.Active;
    }

    /// @notice Get operator self-stake
    function _getOperatorSelfStake(address operator) internal view returns (uint256) {
        return _operatorMetadata[operator].stake;
    }

    /// @notice Get operator metadata
    function _getOperatorMetadata(address operator) internal view returns (Types.OperatorMetadata memory) {
        return _operatorMetadata[operator];
    }

    /// @notice Get operator blueprints
    function _getOperatorBlueprints(address operator) internal view returns (uint256[] memory) {
        return _operatorBlueprints[operator].values();
    }

    /// @notice Get total operator count
    function _operatorCount() internal view returns (uint256) {
        return _operators.length();
    }

    /// @notice Get operator at index
    function _operatorAt(uint256 index) internal view returns (address) {
        return _operators.at(index);
    }
}
