// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import { RestakingFacetBase } from "../../restaking/RestakingFacetBase.sol";
import { DelegationErrors } from "../../restaking/DelegationErrors.sol";
import { Types } from "../../libraries/Types.sol";
import { IFacetSelectors } from "../../interfaces/IFacetSelectors.sol";

/// @title RestakingDelegationsFacet
/// @notice Facet for delegation lifecycle
contract RestakingDelegationsFacet is RestakingFacetBase, IFacetSelectors {
    using EnumerableSet for EnumerableSet.AddressSet;

    function selectors() external pure returns (bytes4[] memory selectorList) {
        selectorList = new bytes4[](10);
        selectorList[0] = this.depositAndDelegate.selector;
        selectorList[1] = this.depositAndDelegateWithOptions.selector;
        selectorList[2] = this.delegate.selector;
        selectorList[3] = this.delegateWithOptions.selector;
        selectorList[4] = this.scheduleDelegatorUnstake.selector;
        selectorList[5] = this.undelegate.selector;
        selectorList[6] = this.executeDelegatorUnstake.selector;
        selectorList[7] = this.addBlueprintToDelegation.selector;
        selectorList[8] = this.removeBlueprintFromDelegation.selector;
        selectorList[9] = this.executeDelegatorUnstakeAndWithdraw.selector;
    }

    /// @notice Deposit and delegate native tokens in one transaction
    /// @param operator Operator to delegate to
    function depositAndDelegate(address operator) external payable whenNotPaused nonReentrant {
        _tryAdvanceRound();
        _depositNative();
        _delegateNative(operator, msg.value);
    }

    /// @notice Deposit and delegate with full options in one transaction
    /// @param operator Operator to delegate to
    /// @param token Token address (address(0) for native)
    /// @param amount Amount to deposit and delegate
    /// @param selectionMode Blueprint selection mode
    /// @param blueprintIds Blueprint IDs for Fixed mode
    function depositAndDelegateWithOptions(
        address operator,
        address token,
        uint256 amount,
        Types.BlueprintSelectionMode selectionMode,
        uint64[] calldata blueprintIds
    )
        external
        payable
        whenNotPaused
        nonReentrant
    {
        _tryAdvanceRound();
        if (token == address(0)) {
            _depositNative();
        } else {
            _depositErc20(token, amount);
        }
        _delegateWithOptions(operator, token, amount, selectionMode, blueprintIds);
    }

    /// @notice Delegate to an operator (from existing deposit)
    function delegate(address operator, uint256 amount) external whenNotPaused nonReentrant {
        _tryAdvanceRound();
        _delegateNative(operator, amount);
    }

    /// @notice Delegate with full options (from existing deposit)
    function delegateWithOptions(
        address operator,
        address token,
        uint256 amount,
        Types.BlueprintSelectionMode selectionMode,
        uint64[] calldata blueprintIds
    )
        external
        whenNotPaused
        nonReentrant
    {
        _tryAdvanceRound();
        _delegateWithOptions(operator, token, amount, selectionMode, blueprintIds);
    }

    /// @notice Schedule undelegation
    function scheduleDelegatorUnstake(address operator, address token, uint256 amount) external whenNotPaused {
        _scheduleDelegatorUnstake(operator, token, amount);
    }

    /// @notice Undelegate native tokens
    function undelegate(address operator, uint256 amount) external whenNotPaused nonReentrant {
        _undelegateNative(operator, amount);
    }

    /// @notice Execute pending unstakes
    function executeDelegatorUnstake() external nonReentrant {
        _tryAdvanceRound();
        _executeDelegatorUnstake();
    }

    /// @notice Execute a specific matured unstake request and immediately withdraw the resulting assets.
    /// @dev This is intended for integrations that need a single-step "redeem" once the bond-less delay has passed.
    function executeDelegatorUnstakeAndWithdraw(
        address operator,
        address token,
        uint256 shares,
        uint64 requestedRound,
        address receiver
    )
        external
        nonReentrant
        returns (uint256 amountReturned)
    {
        _tryAdvanceRound();
        return _executeDelegatorUnstakeAndWithdrawInner(operator, token, shares, requestedRound, receiver);
    }

    function _executeDelegatorUnstakeAndWithdrawInner(
        address operator,
        address token,
        uint256 shares,
        uint64 requestedRound,
        address receiver
    ) private returns (uint256 amountReturned) {
        if (receiver == address(0)) revert DelegationErrors.ZeroAddress();
        if (shares == 0) revert DelegationErrors.ZeroAmount();

        Types.Asset memory asset = token == address(0)
            ? Types.Asset(Types.AssetKind.Native, address(0))
            : Types.Asset(Types.AssetKind.ERC20, token);
        bytes32 assetHash = _assetHash(asset);

        // Find the exact bond-less request (operator, asset, shares, requestedRound).
        Types.BondLessRequest[] storage requests = _unstakeRequests[msg.sender];
        uint256 requestIndex = type(uint256).max;
        for (uint256 i = 0; i < requests.length; i++) {
            Types.BondLessRequest storage candidate = requests[i];
            if (
                candidate.operator == operator &&
                _assetHash(candidate.asset) == assetHash &&
                candidate.shares == shares &&
                candidate.requestedRound == requestedRound
            ) {
                requestIndex = i;
                break;
            }
        }
        if (requestIndex == type(uint256).max) {
            revert DelegationErrors.DelegationNotFound(msg.sender, operator);
        }

        Types.BondLessRequest storage req = requests[requestIndex];

        uint64 unstakeReadyRound = req.requestedRound + delegationBondLessDelay;
        if (currentRound < unstakeReadyRound) {
            revert DelegationErrors.UnstakeTooEarly(currentRound, unstakeReadyRound);
        }

        uint64 withdrawReadyRound = req.requestedRound + leaveDelegatorsDelay;
        if (currentRound < withdrawReadyRound) {
            revert DelegationErrors.WithdrawTooEarly(currentRound, withdrawReadyRound);
        }

        // Convert shares to amount at current exchange rate and apply lazy slashing.
        amountReturned = _sharesToAmount(req.operator, req.shares);
        amountReturned = _applyLazySlash(
            amountReturned,
            req.slashFactorSnapshot,
            getOperatorSlashFactor(req.operator)
        );

        _applyBondlessUnstakeToDelegatorState(msg.sender, operator, assetHash, req, amountReturned);

        emit DelegatorUnstakeExecuted(msg.sender, req.operator, req.asset.token, req.shares, amountReturned);

        // Remove processed request (swap and pop).
        requests[requestIndex] = requests[requests.length - 1];
        requests.pop();

        // Withdraw to receiver immediately (after both delays have elapsed).
        Types.Deposit storage dep2 = _deposits[msg.sender][assetHash];
        uint256 available = dep2.amount - dep2.delegatedAmount;
        uint256 locked = _getLockedAmount(msg.sender, assetHash);
        uint256 free = dep2.amount > locked ? dep2.amount - locked : 0;

        if (free < amountReturned) revert DelegationErrors.AmountLocked(locked, amountReturned);
        if (available < amountReturned) revert DelegationErrors.InsufficientAvailableBalance(available, amountReturned);

        dep2.amount -= amountReturned;
        // Update deposit cap accounting on actual transfer (TVL decreases here).
        Types.AssetConfig storage config = _assetConfigs[assetHash];
        if (config.currentDeposits >= amountReturned) {
            config.currentDeposits -= amountReturned;
        } else {
            // Clamp for upgrade safety (in case currentDeposits was previously incorrect).
            config.currentDeposits = 0;
        }
        _transferAssetAndEmitWithdraw(asset, receiver, amountReturned);
    }

    function _applyBondlessUnstakeToDelegatorState(
        address delegator,
        address operator,
        bytes32 assetHash,
        Types.BondLessRequest storage req,
        uint256 amountReturned
    ) private {
        bool updated = false;
        Types.BondInfoDelegator[] storage delegations = _delegations[delegator];
        for (uint256 j = 0; j < delegations.length; j++) {
            Types.BondInfoDelegator storage d = delegations[j];
            if (d.operator != req.operator || _assetHash(d.asset) != assetHash) continue;

            uint64[] memory blueprintIds = d.selectionMode == Types.BlueprintSelectionMode.Fixed
                ? _delegationBlueprints[delegator][j]
                : new uint64[](0);

            if (d.selectionMode == Types.BlueprintSelectionMode.Fixed && blueprintIds.length > 0) {
                uint256 sharesPerBlueprint = req.shares / blueprintIds.length;
                for (uint256 k = 0; k < blueprintIds.length; k++) {
                    uint256 currentBpShares = _delegatorBlueprintShares[delegator][req.operator][blueprintIds[k]];
                    _delegatorBlueprintShares[delegator][req.operator][blueprintIds[k]] =
                        sharesPerBlueprint > currentBpShares ? 0 : currentBpShares - sharesPerBlueprint;
                }
            }

            _notifyDelegationChangedForBondlessExecution(
                delegator,
                req.operator,
                req.asset,
                req.shares,
                amountReturned,
                d.selectionMode,
                blueprintIds
            );

            d.shares -= req.shares;

            Types.Deposit storage dep = _deposits[delegator][assetHash];
            uint256 depReduction = amountReturned > dep.delegatedAmount ? dep.delegatedAmount : amountReturned;
            dep.delegatedAmount -= depReduction;

            if (d.shares == 0) {
                _operatorMetadata[req.operator].delegationCount--;
                delegations[j] = delegations[delegations.length - 1];
                delegations.pop();
                if (_getDelegatorSharesForOperator(delegator, req.operator) == 0) {
                    _operatorDelegators[req.operator].remove(delegator);
                }
            }

            updated = true;
            break;
        }

        if (!updated) {
            revert DelegationErrors.DelegationNotFound(delegator, operator);
        }
    }

    function _notifyDelegationChangedForBondlessExecution(
        address delegator,
        address operator,
        Types.Asset memory asset,
        uint256 shares,
        uint256 amount,
        Types.BlueprintSelectionMode selectionMode,
        uint64[] memory blueprintIds
    ) private {
        _onDelegationChanged(
            delegator,
            operator,
            asset,
            shares,
            amount,
            false,
            selectionMode,
            blueprintIds,
            _getLockMultiplierBps(Types.LockMultiplier.None)
        );
    }

    function _transferAssetAndEmitWithdraw(Types.Asset memory asset, address receiver, uint256 amount) private {
        _transferAsset(asset, receiver, amount);
        emit Withdrawn(msg.sender, asset.token, amount);
    }

    /// @notice Add a blueprint to a Fixed mode delegation
    function addBlueprintToDelegation(uint256 delegationIndex, uint64 blueprintId) external whenNotPaused {
        _addBlueprintToDelegation(delegationIndex, blueprintId);
    }

    /// @notice Remove a blueprint from a Fixed mode delegation
    function removeBlueprintFromDelegation(uint256 delegationIndex, uint64 blueprintId) external whenNotPaused {
        _removeBlueprintFromDelegation(delegationIndex, blueprintId);
    }
}
