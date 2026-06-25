// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {TNTLinearVesting} from "./TNTLinearVesting.sol";

/// @title TNTVestingFactory
/// @notice Factory for deploying deterministic TNTLinearVesting clones.
/// @dev Uses EIP-1167 minimal proxy pattern for gas-efficient deployments.
///
/// The factory stores global vesting parameters (cliffDuration, vestingDuration)
/// that apply to all vesting contracts created through it. This allows:
/// - Consistent vesting schedules across all beneficiaries
/// - Easy configuration changes before deployment (just deploy new factory)
/// - Configurable durations (e.g., 18 months or 24 months total)
contract TNTVestingFactory {
    using Clones for address;

    /// @notice The implementation contract used for all clones
    address public immutable implementation;

    /// @notice Duration of cliff period in seconds (time before vesting starts)
    uint64 public immutable cliffDuration;

    /// @notice Duration of linear vesting period in seconds (after cliff ends)
    uint64 public immutable vestingDuration;

    event VestingCreated(
        address indexed vesting,
        address indexed token,
        address indexed beneficiary,
        uint64 startTimestamp,
        uint64 cliffDuration,
        uint64 vestingDuration
    );

    error InvalidVestingDuration();

    /// @notice Deploy a new factory with specified vesting parameters
    /// @param cliffDuration_ Duration of cliff period (e.g., 365 days for 12 months)
    /// @param vestingDuration_ Duration of linear vesting after cliff (e.g., 730 days for 24 months)
    constructor(uint64 cliffDuration_, uint64 vestingDuration_) {
        if (vestingDuration_ == 0) revert InvalidVestingDuration();
        implementation = address(new TNTLinearVesting());
        cliffDuration = cliffDuration_;
        vestingDuration = vestingDuration_;
    }

    /// @notice Get or create a vesting contract for a beneficiary
    /// @dev Uses CREATE2 for deterministic addresses. If contract exists, returns existing address.
    /// @param token The ERC20 token to vest
    /// @param beneficiary The address that can withdraw vested tokens
    /// @param startTimestamp When the vesting schedule begins
    /// @return vesting The address of the vesting contract
    /// @dev The clone's voting-power delegatee is forced to `beneficiary`. The delegatee is NOT part
    ///      of the CREATE2 salt, so accepting a caller-supplied delegatee let a front-runner pre-create
    ///      the victim's clone at the predicted address with an attacker delegatee; the get-or-create
    ///      path then skips initialization and merely funds the hijacked clone, redirecting the
    ///      beneficiary's vested voting power. Binding the delegatee to `beneficiary` removes that
    ///      degree of freedom: any pre-created clone is byte-identical to the one this call would
    ///      create, so front-running is a harmless no-op. The beneficiary may re-delegate afterward.
    function getOrCreateVesting(
        address token,
        address beneficiary,
        uint64 startTimestamp
    ) external returns (address vesting) {
        bytes32 salt = _computeSalt(token, beneficiary, startTimestamp);
        vesting = implementation.predictDeterministicAddress(salt, address(this));

        if (vesting.code.length == 0) {
            vesting = implementation.cloneDeterministic(salt);
            TNTLinearVesting(vesting).initialize(
                token,
                beneficiary,
                startTimestamp,
                cliffDuration,
                vestingDuration,
                beneficiary
            );
            emit VestingCreated(vesting, token, beneficiary, startTimestamp, cliffDuration, vestingDuration);
        }
    }

    /// @notice Predict the address of a vesting contract before deployment
    /// @param token The ERC20 token
    /// @param beneficiary The beneficiary address
    /// @param startTimestamp When the vesting schedule begins
    /// @return The deterministic address of the vesting contract
    function predictVestingAddress(
        address token,
        address beneficiary,
        uint64 startTimestamp
    ) external view returns (address) {
        bytes32 salt = _computeSalt(token, beneficiary, startTimestamp);
        return implementation.predictDeterministicAddress(salt, address(this));
    }

    /// @notice Check if a vesting contract has been deployed
    /// @param token The ERC20 token
    /// @param beneficiary The beneficiary address
    /// @param startTimestamp When the vesting schedule begins
    /// @return True if the vesting contract exists
    function vestingExists(
        address token,
        address beneficiary,
        uint64 startTimestamp
    ) external view returns (bool) {
        bytes32 salt = _computeSalt(token, beneficiary, startTimestamp);
        address vesting = implementation.predictDeterministicAddress(salt, address(this));
        return vesting.code.length > 0;
    }

    /// @notice Calculate the total vesting period (cliff + linear vesting)
    /// @return Total duration in seconds
    function totalVestingDuration() external view returns (uint64) {
        return cliffDuration + vestingDuration;
    }

    /// @dev Compute deterministic salt from parameters
    function _computeSalt(
        address token,
        address beneficiary,
        uint64 startTimestamp
    ) internal pure returns (bytes32) {
        return keccak256(abi.encode(token, beneficiary, startTimestamp));
    }
}
