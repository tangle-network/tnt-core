// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { GovernorUpgradeable } from "@openzeppelin/contracts-upgradeable/governance/GovernorUpgradeable.sol";
import {
    GovernorSettingsUpgradeable
} from "@openzeppelin/contracts-upgradeable/governance/extensions/GovernorSettingsUpgradeable.sol";
import {
    GovernorCountingSimpleUpgradeable
} from "@openzeppelin/contracts-upgradeable/governance/extensions/GovernorCountingSimpleUpgradeable.sol";
import {
    GovernorVotesUpgradeable
} from "@openzeppelin/contracts-upgradeable/governance/extensions/GovernorVotesUpgradeable.sol";
import {
    GovernorVotesQuorumFractionUpgradeable
} from "@openzeppelin/contracts-upgradeable/governance/extensions/GovernorVotesQuorumFractionUpgradeable.sol";
import {
    GovernorTimelockControlUpgradeable
} from "@openzeppelin/contracts-upgradeable/governance/extensions/GovernorTimelockControlUpgradeable.sol";
import {
    TimelockControllerUpgradeable
} from "@openzeppelin/contracts-upgradeable/governance/TimelockControllerUpgradeable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { IVotes } from "@openzeppelin/contracts/governance/utils/IVotes.sol";
import { Errors } from "../libraries/Errors.sol";

/// @title TangleGovernor
/// @notice On-chain governance for the Tangle Protocol
/// @dev Modular governor using OpenZeppelin's Governor framework
///
/// Components:
/// - GovernorSettings: Configurable voting delay, period, and proposal threshold
/// - GovernorCountingSimple: For/Against/Abstain voting
/// - GovernorVotes: TNT token as voting power source
/// - GovernorVotesQuorumFraction: Percentage-based quorum
/// - GovernorTimelockControl: Timelock integration for execution delay
///
/// Governance Parameters (configurable):
/// - Voting Delay: Time before voting starts after proposal
/// - Voting Period: Duration of the voting window
/// - Proposal Threshold: Minimum tokens needed to create proposal
/// - Quorum: Minimum participation (% of total supply)
/// - Timelock Delay: Execution delay after proposal passes
contract TangleGovernor is
    Initializable,
    GovernorUpgradeable,
    GovernorSettingsUpgradeable,
    GovernorCountingSimpleUpgradeable,
    GovernorVotesUpgradeable,
    GovernorVotesQuorumFractionUpgradeable,
    GovernorTimelockControlUpgradeable,
    UUPSUpgradeable
{
    // ═══════════════════════════════════════════════════════════════════════════
    // PROPOSAL VALIDATION CONSTANTS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Maximum number of actions per proposal
    /// @dev Audit Round 2 governance #8: 50 actions is enough surface area for a
    ///      proposer to bury a privileged call (e.g. `grantRole(DEFAULT_ADMIN, attacker)`)
    ///      in action #50 of 50 where UI tooling may truncate or skim. Lowered to 10
    ///      to keep the typical multi-step queue legitimate (most real proposals touch
    ///      ≤ 5 targets) while making "haystack" obfuscation impractical. Multi-action
    ///      legitimate flows that genuinely need >10 actions can chain proposals.
    uint256 public constant MAX_PROPOSAL_ACTIONS = 10;

    /// @notice Maximum NATIVE value (msg.value) per single action.
    /// @dev This caps the native-coin (ETH) value attached to a single proposal action
    ///      only. It does NOT bound ERC20/TNT transfers — those move via token `transfer`
    ///      calldata (value 0) and are governed solely by the vote + timelock, not this
    ///      limit. Lowered from 100k to 10k ETH (audit Round 2 governance #8): 100k × 10
    ///      actions = 1M ETH outflow per proposal was an over-broad safety bound; 10k keeps
    ///      any single proposal well below mainnet-scale treasury holdings while remaining
    ///      permissive for routine native grants / refunds.
    uint256 public constant MAX_ACTION_VALUE = 10_000 ether;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // INITIALIZATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Initialize the governor
    /// @param token The TNT governance token (must implement IVotes)
    /// @param timelock The timelock controller for execution
    /// @param initialVotingDelay Seconds before voting starts (ERC-6372 timestamp clock; e.g., 1 days = 86400)
    /// @param initialVotingPeriod Seconds for voting duration (ERC-6372 timestamp clock; e.g., 7 days = 604800)
    /// @param initialProposalThreshold Tokens needed to propose (e.g., 100000e18 = 100k TNT)
    /// @param quorumPercent Quorum as percentage of total supply (e.g., 4 = 4%)
    function initialize(
        IVotes token,
        TimelockControllerUpgradeable timelock,
        uint48 initialVotingDelay,
        uint32 initialVotingPeriod,
        uint256 initialProposalThreshold,
        uint256 quorumPercent
    )
        public
        initializer
    {
        __Governor_init("TangleGovernor");
        __GovernorSettings_init(initialVotingDelay, initialVotingPeriod, initialProposalThreshold);
        __GovernorCountingSimple_init();
        __GovernorVotes_init(token);
        __GovernorVotesQuorumFraction_init(quorumPercent);
        __GovernorTimelockControl_init(timelock);
        __UUPSUpgradeable_init();
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // REQUIRED OVERRIDES
    // ═══════════════════════════════════════════════════════════════════════════

    function votingDelay() public view override(GovernorUpgradeable, GovernorSettingsUpgradeable) returns (uint256) {
        return super.votingDelay();
    }

    function votingPeriod() public view override(GovernorUpgradeable, GovernorSettingsUpgradeable) returns (uint256) {
        return super.votingPeriod();
    }

    function quorum(uint256 blockNumber)
        public
        view
        override(GovernorUpgradeable, GovernorVotesQuorumFractionUpgradeable)
        returns (uint256)
    {
        return super.quorum(blockNumber);
    }

    function state(uint256 proposalId)
        public
        view
        override(GovernorUpgradeable, GovernorTimelockControlUpgradeable)
        returns (ProposalState)
    {
        return super.state(proposalId);
    }

    function proposalNeedsQueuing(uint256 proposalId)
        public
        view
        override(GovernorUpgradeable, GovernorTimelockControlUpgradeable)
        returns (bool)
    {
        return super.proposalNeedsQueuing(proposalId);
    }

    function proposalThreshold()
        public
        view
        override(GovernorUpgradeable, GovernorSettingsUpgradeable)
        returns (uint256)
    {
        return super.proposalThreshold();
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // PROPOSAL VALIDATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Override propose to add validation for targets and values
    /// @dev Validates that:
    ///      - No zero address targets
    ///      - Values are within bounds
    ///      - Number of actions is reasonable
    function propose(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        string memory description
    )
        public
        override
        returns (uint256)
    {
        // Validate proposal action count
        if (targets.length == 0) revert Errors.InvalidState();
        if (targets.length > MAX_PROPOSAL_ACTIONS) revert Errors.InvalidState();
        if (targets.length != values.length || targets.length != calldatas.length) {
            revert Errors.LengthMismatch();
        }

        // Validate each action
        for (uint256 i = 0; i < targets.length; i++) {
            // No zero address targets
            if (targets[i] == address(0)) revert Errors.ZeroAddress();

            // Value bounds check
            if (values[i] > MAX_ACTION_VALUE) revert Errors.InvalidState();
        }

        return super.propose(targets, values, calldatas, description);
    }

    function _queueOperations(
        uint256 proposalId,
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    )
        internal
        override(GovernorUpgradeable, GovernorTimelockControlUpgradeable)
        returns (uint48)
    {
        return super._queueOperations(proposalId, targets, values, calldatas, descriptionHash);
    }

    function _executeOperations(
        uint256 proposalId,
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    )
        internal
        override(GovernorUpgradeable, GovernorTimelockControlUpgradeable)
    {
        // OpenZeppelin's GovernorTimelockControlUpgradeable already validates:
        // - Proposal must be in executable state
        // - Timelock operation must exist and be ready
        // - Arrays must match the original proposal
        // The parent implementation provides sufficient protection against execution bypasses.
        super._executeOperations(proposalId, targets, values, calldatas, descriptionHash);
    }

    function _cancel(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    )
        internal
        override(GovernorUpgradeable, GovernorTimelockControlUpgradeable)
        returns (uint256)
    {
        return super._cancel(targets, values, calldatas, descriptionHash);
    }

    function _executor()
        internal
        view
        override(GovernorUpgradeable, GovernorTimelockControlUpgradeable)
        returns (address)
    {
        return super._executor();
    }

    /// @notice Only governance can upgrade this contract
    function _authorizeUpgrade(address) internal override onlyGovernance { }
}
