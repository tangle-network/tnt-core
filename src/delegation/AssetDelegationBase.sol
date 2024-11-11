// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { MultiAssetDelegation } from "../precompiles/MultiAssetDelegation.sol";
import { IAssetDelegator } from "../interfaces/IAssetDelegator.sol";

/// @title AssetDelegationBase
/// @notice Base contract implementing delegation logic for all assets
abstract contract AssetDelegationBase is IAssetDelegator {
    /// @dev The MultiAssetDelegation contract's address.
    address constant MULTI_ASSET_DELEGATION = 0x0000000000000000000000000000000000000822;

    /// @dev The MultiAssetDelegation contract's instance.
    MultiAssetDelegation constant DELEGATION = MultiAssetDelegation(MULTI_ASSET_DELEGATION);

    /// @inheritdoc IAssetDelegator
    function delegate(bytes32 operator, address asset, uint256 amount, DelegationOp op) public virtual returns (bool) {
        uint8 result;
        if (op == DelegationOp.Delegate) {
            result = DELEGATION.delegate(operator, uint256(uint160(asset)), amount);
        } else if (op == DelegationOp.ScheduleUnstake) {
            result = DELEGATION.scheduleDelegatorUnstake(operator, uint256(uint160(asset)), amount);
        } else if (op == DelegationOp.CancelUnstake) {
            result = DELEGATION.cancelDelegatorUnstake(operator, uint256(uint160(asset)), amount);
        }

        require(result == 0, "Delegation operation failed");

        emit DelegationExecuted(asset, msg.sender, op, operator, amount);
        return true;
    }

    /// @inheritdoc IAssetDelegator
    function handleDelegation(address asset, uint256 amount, bytes memory delegateData) public virtual returns (bool) {
        (bytes32 operator, DelegationOp op) = abi.decode(delegateData, (bytes32, DelegationOp));
        return delegate(operator, asset, amount, op);
    }
}
