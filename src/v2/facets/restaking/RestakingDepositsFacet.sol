// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { RestakingFacetBase } from "../../restaking/RestakingFacetBase.sol";
import { Types } from "../../libraries/Types.sol";
import { IFacetSelectors } from "../../interfaces/IFacetSelectors.sol";

/// @title RestakingDepositsFacet
/// @notice Facet for deposit and withdrawal flows
contract RestakingDepositsFacet is RestakingFacetBase, IFacetSelectors {
    function selectors() external pure returns (bytes4[] memory selectorList) {
        selectorList = new bytes4[](6);
        selectorList[0] = this.deposit.selector;
        selectorList[1] = this.depositWithLock.selector;
        selectorList[2] = this.depositERC20.selector;
        selectorList[3] = this.depositERC20WithLock.selector;
        selectorList[4] = this.scheduleWithdraw.selector;
        selectorList[5] = this.executeWithdraw.selector;
    }

    /// @notice Deposit native token
    function deposit() external payable whenNotPaused nonReentrant {
        _tryAdvanceRound();
        _depositNative();
    }

    /// @notice Deposit native token with lock
    function depositWithLock(Types.LockMultiplier lockMultiplier) external payable whenNotPaused nonReentrant {
        _tryAdvanceRound();
        _depositNativeWithLock(lockMultiplier);
    }

    /// @notice Deposit ERC20 token
    function depositERC20(address token, uint256 amount) external whenNotPaused nonReentrant {
        _tryAdvanceRound();
        _depositErc20(token, amount);
    }

    /// @notice Deposit ERC20 with lock
    function depositERC20WithLock(
        address token,
        uint256 amount,
        Types.LockMultiplier lockMultiplier
    )
        external
        whenNotPaused
        nonReentrant
    {
        _tryAdvanceRound();
        _depositErc20WithLock(token, amount, lockMultiplier);
    }

    /// @notice Schedule withdrawal
    function scheduleWithdraw(address token, uint256 amount) external whenNotPaused {
        _scheduleWithdraw(token, amount);
    }

    /// @notice Execute pending withdrawals
    function executeWithdraw() external nonReentrant {
        _tryAdvanceRound();
        _executeWithdraw();
    }
}
