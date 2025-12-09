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
        require(minDelay >= MIN_DELAY, "Delay too short");
        require(minDelay <= MAX_DELAY, "Delay too long");

        __TimelockController_init(minDelay, proposers, executors, admin);
        __UUPSUpgradeable_init();
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // UPGRADE AUTHORIZATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Only the timelock itself (via governance) can upgrade
    function _authorizeUpgrade(address) internal view override {
        // Only callable by the timelock itself (i.e., through a governance proposal)
        require(msg.sender == address(this), "Only self-upgrade via governance");
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
