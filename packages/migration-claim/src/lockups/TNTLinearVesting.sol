// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {IVotes} from "@openzeppelin/contracts/governance/utils/IVotes.sol";

/// @title TNTLinearVesting
/// @notice Per-beneficiary vesting contract with cliff period followed by linear unlock.
/// @dev Intended to be deployed as EIP-1167 clones via TNTVestingFactory.
///
/// Vesting Schedule:
/// - Before cliff (t < start + cliffDuration): 0% vested
/// - During vesting (start + cliffDuration <= t < start + cliffDuration + vestingDuration):
///     vestedAmount = totalLocked * (t - start - cliffDuration) / vestingDuration
/// - After vesting complete (t >= start + cliffDuration + vestingDuration): 100% vested
///
/// Example with 12-month cliff + 24-month linear vesting (36 months total):
/// - Month 0-12: 0% vested (cliff period)
/// - Month 12-36: Linear unlock (~4.17% per month)
/// - Month 36+: 100% vested
contract TNTLinearVesting {
    using SafeERC20 for IERC20;

    error AlreadyInitialized();
    error NotBeneficiary();
    error NothingToRelease();
    error ZeroAddress();
    error InvalidDuration();

    event Initialized(
        address indexed token,
        address indexed beneficiary,
        uint64 startTimestamp,
        uint64 cliffDuration,
        uint64 vestingDuration,
        address indexed delegatee
    );
    event Released(address indexed token, address indexed beneficiary, address indexed to, uint256 amount);
    event Delegated(address indexed token, address indexed beneficiary, address indexed delegatee);

    // ═══════════════════════════════════════════════════════════════════════
    // IMMUTABLE STATE (set at initialization, never changes)
    // ═══════════════════════════════════════════════════════════════════════

    address public token;
    address public beneficiary;
    uint64 public startTimestamp;
    uint64 public cliffDuration;
    uint64 public vestingDuration;
    bool public initialized;

    // ═══════════════════════════════════════════════════════════════════════
    // MUTABLE STATE
    // ═══════════════════════════════════════════════════════════════════════

    /// @notice Total amount already released to beneficiary
    uint256 public released;

    // ═══════════════════════════════════════════════════════════════════════
    // MODIFIERS
    // ═══════════════════════════════════════════════════════════════════════

    modifier onlyBeneficiary() {
        if (msg.sender != beneficiary) revert NotBeneficiary();
        _;
    }

    // ═══════════════════════════════════════════════════════════════════════
    // INITIALIZATION
    // ═══════════════════════════════════════════════════════════════════════

    /// @notice Initialize the vesting contract (called by factory)
    /// @param token_ The ERC20 token being vested
    /// @param beneficiary_ The address that can withdraw vested tokens
    /// @param startTimestamp_ When the vesting schedule begins
    /// @param cliffDuration_ Duration of cliff period in seconds (no vesting during this time)
    /// @param vestingDuration_ Duration of linear vesting period in seconds (after cliff)
    /// @param delegatee Initial voting power delegatee (can be beneficiary)
    function initialize(
        address token_,
        address beneficiary_,
        uint64 startTimestamp_,
        uint64 cliffDuration_,
        uint64 vestingDuration_,
        address delegatee
    ) external {
        if (initialized) revert AlreadyInitialized();
        if (token_ == address(0) || beneficiary_ == address(0)) revert ZeroAddress();
        if (vestingDuration_ == 0) revert InvalidDuration();

        token = token_;
        beneficiary = beneficiary_;
        startTimestamp = startTimestamp_;
        cliffDuration = cliffDuration_;
        vestingDuration = vestingDuration_;
        initialized = true;

        // Delegate voting power if requested
        if (delegatee != address(0)) {
            try IVotes(token_).delegate(delegatee) {
                emit Delegated(token_, beneficiary_, delegatee);
            } catch {}
        }

        emit Initialized(token_, beneficiary_, startTimestamp_, cliffDuration_, vestingDuration_, delegatee);
    }

    // ═══════════════════════════════════════════════════════════════════════
    // VIEW FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════

    /// @notice Returns the total amount of tokens held by this contract (locked + releasable)
    function totalLocked() public view returns (uint256) {
        return IERC20(token).balanceOf(address(this)) + released;
    }

    /// @notice Returns the amount of tokens that have vested up to the current timestamp
    /// @dev Uses linear interpolation after cliff period
    function vestedAmount() public view returns (uint256) {
        return _vestedAmount(uint64(block.timestamp));
    }

    /// @notice Returns the amount of tokens that have vested at a specific timestamp
    /// @param timestamp The timestamp to check vesting for
    function vestedAmountAt(uint64 timestamp) external view returns (uint256) {
        return _vestedAmount(timestamp);
    }

    /// @notice Returns the amount of tokens currently available for release
    function releasable() public view returns (uint256) {
        return vestedAmount() - released;
    }

    /// @notice Returns the timestamp when the cliff ends and vesting begins
    function cliffEnd() public view returns (uint64) {
        return startTimestamp + cliffDuration;
    }

    /// @notice Returns the timestamp when vesting is complete
    function vestingEnd() public view returns (uint64) {
        return startTimestamp + cliffDuration + vestingDuration;
    }

    // ═══════════════════════════════════════════════════════════════════════
    // RELEASE FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════

    /// @notice Release all currently vested tokens to the beneficiary
    /// @return amount The amount of tokens released
    function release() external onlyBeneficiary returns (uint256 amount) {
        return _release(beneficiary);
    }

    /// @notice Release all currently vested tokens to a specified address
    /// @param to The address to send vested tokens to
    /// @return amount The amount of tokens released
    function release(address to) external onlyBeneficiary returns (uint256 amount) {
        if (to == address(0)) revert ZeroAddress();
        return _release(to);
    }

    // ═══════════════════════════════════════════════════════════════════════
    // DELEGATION
    // ═══════════════════════════════════════════════════════════════════════

    /// @notice Delegate voting power for tokens held by this vesting contract
    /// @param delegatee The address to delegate voting power to
    function delegate(address delegatee) external onlyBeneficiary {
        if (delegatee == address(0)) revert ZeroAddress();
        IVotes(token).delegate(delegatee);
        emit Delegated(token, beneficiary, delegatee);
    }

    // ═══════════════════════════════════════════════════════════════════════
    // INTERNAL FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════

    /// @dev Calculate vested amount at a given timestamp using linear interpolation
    function _vestedAmount(uint64 timestamp) internal view returns (uint256) {
        uint256 total = totalLocked();

        uint64 cliff = startTimestamp + cliffDuration;
        uint64 end = cliff + vestingDuration;

        if (timestamp < cliff) {
            // Before cliff: nothing vested
            return 0;
        } else if (timestamp >= end) {
            // After vesting complete: everything vested
            return total;
        } else {
            // During linear vesting: interpolate
            // vestedAmount = total * (timestamp - cliff) / vestingDuration
            return (total * (timestamp - cliff)) / vestingDuration;
        }
    }

    /// @dev Internal release implementation
    function _release(address to) internal returns (uint256 amount) {
        amount = releasable();
        if (amount == 0) revert NothingToRelease();

        released += amount;
        IERC20(token).safeTransfer(to, amount);

        emit Released(token, beneficiary, to, amount);
    }
}
