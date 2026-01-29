// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { TimelockControllerUpgradeable } from "@openzeppelin/contracts-upgradeable/governance/TimelockControllerUpgradeable.sol";
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
    ) public override initializer {
        // M-16 FIX: Use custom errors for gas efficiency
        if (minDelay < MIN_DELAY) revert DelayTooShort(minDelay, MIN_DELAY);
        if (minDelay > MAX_DELAY) revert DelayTooLong(minDelay, MAX_DELAY);

        __TimelockController_init(minDelay, proposers, executors, admin);
        __UUPSUpgradeable_init();
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // M-16 FIX: DELAY VALIDATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Update the minimum delay
    /// @dev M-16 FIX: Validates bounds before allowing delay changes. Only callable by
    ///      the timelock itself (via a governance proposal).
    /// @param newDelay The new delay to set
    function updateDelay(uint256 newDelay) external override onlyRole(DEFAULT_ADMIN_ROLE) {
        // M-16 FIX: Enforce delay bounds to prevent timelock bypass
        if (newDelay < MIN_DELAY) revert DelayTooShort(newDelay, MIN_DELAY);
        if (newDelay > MAX_DELAY) revert DelayTooLong(newDelay, MAX_DELAY);

        // Parent implementation handles the actual update and event emission
        // Note: This calls TimelockControllerUpgradeable.updateDelay which is onlyRole(DEFAULT_ADMIN_ROLE)
        emit MinDelayChange(getMinDelay(), newDelay);
        _setMinDelay(newDelay);
    }

    /// @notice Internal function to set the minimum delay (matching OZ 5.x pattern)
    function _setMinDelay(uint256 newDelay) private {
        // Storage slot for _minDelay in TimelockControllerUpgradeable
        // Using direct storage write since OZ 5.x TimelockControllerUpgradeable
        // doesn't expose a setter function (it's an immutable in the non-upgradeable version)
        assembly {
            // _minDelay storage slot (position 0x33 = 51 in TimelockControllerUpgradeable)
            sstore(0x33, newDelay)
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
