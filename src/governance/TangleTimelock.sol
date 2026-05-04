// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {
    TimelockControllerUpgradeable
} from "@openzeppelin/contracts-upgradeable/governance/TimelockControllerUpgradeable.sol";
import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

/// @title TangleTimelock
/// @notice Timelock controller for Tangle governance execution
/// @dev Extends OpenZeppelin's TimelockControllerUpgradeable with UUPS upgradeability
///
/// The timelock enforces a delay between when a proposal passes and when it can be executed.
/// This gives users time to exit the system if they disagree with a passed proposal.
///
/// Roles:
/// - PROPOSER_ROLE: Can schedule operations (granted to TangleGovernor)
/// - EXECUTOR_ROLE: Can execute ready operations (granted to TangleGovernor or open)
/// - CANCELLER_ROLE: Can cancel pending operations (granted to TangleGovernor)
/// - DEFAULT_ADMIN_ROLE: Can manage roles (initially admin, then renounced)
///
/// This timelock will hold critical roles on protocol contracts:
/// - UPGRADER_ROLE on Tangle.sol
/// - ADMIN_ROLE on Tangle.sol (optional)
/// - UPGRADER_ROLE on MultiAssetDelegation.sol
contract TangleTimelock is Initializable, TimelockControllerUpgradeable, UUPSUpgradeable {
    /// @notice Minimum delay that can be set (1 day)
    uint256 public constant MIN_DELAY = 1 days;

    /// @notice Maximum delay that can be set (30 days)
    uint256 public constant MAX_DELAY = 30 days;

    // M-16 FIX: Custom errors for better gas efficiency
    error DelayTooShort(uint256 delay, uint256 minimum);
    error DelayTooLong(uint256 delay, uint256 maximum);
    error OnlySelfUpgrade();

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // INITIALIZATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Initialize the timelock
    /// @param minDelay The minimum delay before execution (e.g., 2 days)
    /// @param proposers Addresses that can schedule operations (typically just the Governor)
    /// @param executors Addresses that can execute operations (Governor or address(0) for anyone)
    /// @param admin Initial admin for role management (should renounce after setup)
    function initialize(
        uint256 minDelay,
        address[] memory proposers,
        address[] memory executors,
        address admin
    )
        public
        override
        initializer
    {
        // M-16 FIX: Use custom errors for gas efficiency
        if (minDelay < MIN_DELAY) revert DelayTooShort(minDelay, MIN_DELAY);
        if (minDelay > MAX_DELAY) revert DelayTooLong(minDelay, MAX_DELAY);

        __TimelockController_init(minDelay, proposers, executors, admin);
        __UUPSUpgradeable_init();
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // M-16 FIX: DELAY VALIDATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice ERC-7201 storage location for `TimelockControllerStorage`.
    ///         keccak256(abi.encode(uint256(keccak256("openzeppelin.storage.TimelockController")) - 1)) & ~bytes32(uint256(0xff))
    /// @dev Pinned to OpenZeppelin Contracts Upgradeable 5.1.0; verify before bumping.
    bytes32 private constant TIMELOCK_CONTROLLER_STORAGE_LOCATION =
        0x9a37c2aa9d186a0969ff8a8267bf4e07e864c2f2768f5040949e28a624fb3600;

    /// @notice Update the minimum delay. Only callable by the timelock itself via a
    ///         scheduled governance proposal (matches the parent's `onlySelf` policy).
    /// @param newDelay The new delay to set, bounded by [MIN_DELAY, MAX_DELAY].
    function updateDelay(uint256 newDelay) external override {
        if (msg.sender != address(this)) revert TimelockUnauthorizedCaller(msg.sender);
        if (newDelay < MIN_DELAY) revert DelayTooShort(newDelay, MIN_DELAY);
        if (newDelay > MAX_DELAY) revert DelayTooLong(newDelay, MAX_DELAY);

        emit MinDelayChange(getMinDelay(), newDelay);
        _setMinDelay(newDelay);
    }

    /// @dev Writes `newDelay` directly into the OZ ERC-7201 namespaced storage slot for
    ///      `TimelockControllerStorage._minDelay`. The struct layout is:
    ///         slot 0: _timestamps mapping
    ///         slot 1: _minDelay
    ///      so the absolute slot is `TIMELOCK_CONTROLLER_STORAGE_LOCATION + 1`.
    function _setMinDelay(uint256 newDelay) private {
        bytes32 slot = bytes32(uint256(TIMELOCK_CONTROLLER_STORAGE_LOCATION) + 1);
        assembly {
            sstore(slot, newDelay)
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // UPGRADE AUTHORIZATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Only the timelock itself (via governance) can upgrade
    function _authorizeUpgrade(address) internal view override {
        // M-16 FIX: Use custom error for gas efficiency
        if (msg.sender != address(this)) revert OnlySelfUpgrade();
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // VIEW FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Check if an address has the proposer role
    function isProposer(address account) external view returns (bool) {
        return hasRole(PROPOSER_ROLE, account);
    }

    /// @notice Check if an address has the executor role
    function isExecutor(address account) external view returns (bool) {
        return hasRole(EXECUTOR_ROLE, account);
    }

    /// @notice Check if an address has the canceller role
    function isCanceller(address account) external view returns (bool) {
        return hasRole(CANCELLER_ROLE, account);
    }
}
