// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { IVotes } from "@openzeppelin/contracts/governance/utils/IVotes.sol";

/// @title TNTCliffLock
/// @notice Minimal per-beneficiary cliff lock for TNT (or any ERC20).
/// @dev Intended to be deployed as EIP-1167 clones via TNTLockFactory.
contract TNTCliffLock {
    using SafeERC20 for IERC20;

    error AlreadyInitialized();
    error NotBeneficiary();
    error NotUnlocked(uint64 unlockTimestamp, uint64 nowTimestamp);
    error ZeroAddress();

    event Initialized(
        address indexed token, address indexed beneficiary, uint64 unlockTimestamp, address indexed delegatee
    );
    event Withdrawn(address indexed token, address indexed beneficiary, address indexed to, uint256 amount);
    event Delegated(address indexed token, address indexed beneficiary, address indexed delegatee);

    address public token;
    address public beneficiary;
    uint64 public unlockTimestamp;
    bool public initialized;

    modifier onlyBeneficiary() {
        if (msg.sender != beneficiary) revert NotBeneficiary();
        _;
    }

    function initialize(address token_, address beneficiary_, uint64 unlockTimestamp_, address delegatee) external {
        if (initialized) revert AlreadyInitialized();
        if (token_ == address(0) || beneficiary_ == address(0)) revert ZeroAddress();

        token = token_;
        beneficiary = beneficiary_;
        unlockTimestamp = unlockTimestamp_;
        initialized = true;

        if (delegatee != address(0)) {
            try IVotes(token_).delegate(delegatee) {
                emit Delegated(token_, beneficiary_, delegatee);
            } catch { }
        }

        emit Initialized(token_, beneficiary_, unlockTimestamp_, delegatee);
    }

    /// @notice Withdraw all tokens after the cliff.
    function withdraw(address to) external onlyBeneficiary returns (uint256 amount) {
        if (block.timestamp < unlockTimestamp) {
            // forge-lint: disable-next-line(unsafe-typecast)
            revert NotUnlocked(unlockTimestamp, uint64(block.timestamp));
        }
        if (to == address(0)) revert ZeroAddress();

        IERC20 erc20 = IERC20(token);
        amount = erc20.balanceOf(address(this));
        erc20.safeTransfer(to, amount);
        emit Withdrawn(token, beneficiary, to, amount);
    }

    /// @notice Delegate voting power for tokens held by this lock (if token supports IVotes).
    function delegate(address delegatee) external onlyBeneficiary {
        if (delegatee == address(0)) revert ZeroAddress();
        IVotes(token).delegate(delegatee);
        emit Delegated(token, beneficiary, delegatee);
    }
}

