// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title ITangleGovernance
/// @notice Interface for Tangle governance components
interface ITangleGovernance {
    // ═══════════════════════════════════════════════════════════════════════════
    // PROPOSAL LIFECYCLE
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Proposal states
    enum ProposalState {
        Pending,
        Active,
        Canceled,
        Defeated,
        Succeeded,
        Queued,
        Expired,
        Executed
    }

    /// @notice Create a new proposal
    /// @param targets Contract addresses to call
    /// @param values ETH values to send
    /// @param calldatas Encoded function calls
    /// @param description Human-readable description
    /// @return proposalId The unique proposal identifier
    function propose(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        string memory description
    )
        external
        returns (uint256 proposalId);

    /// @notice Queue a successful proposal for execution
    /// @param targets Contract addresses to call
    /// @param values ETH values to send
    /// @param calldatas Encoded function calls
    /// @param descriptionHash Hash of the proposal description
    /// @return proposalId The proposal identifier
    function queue(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    )
        external
        returns (uint256 proposalId);

    /// @notice Execute a queued proposal
    /// @param targets Contract addresses to call
    /// @param values ETH values to send
    /// @param calldatas Encoded function calls
    /// @param descriptionHash Hash of the proposal description
    /// @return proposalId The proposal identifier
    function execute(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    )
        external
        payable
        returns (uint256 proposalId);

    /// @notice Cancel a proposal
    /// @param targets Contract addresses to call
    /// @param values ETH values to send
    /// @param calldatas Encoded function calls
    /// @param descriptionHash Hash of the proposal description
    /// @return proposalId The proposal identifier
    function cancel(
        address[] memory targets,
        uint256[] memory values,
        bytes[] memory calldatas,
        bytes32 descriptionHash
    )
        external
        returns (uint256 proposalId);

    // ═══════════════════════════════════════════════════════════════════════════
    // VOTING
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Cast a vote on a proposal
    /// @param proposalId The proposal to vote on
    /// @param support 0=Against, 1=For, 2=Abstain
    /// @return weight The voting weight used
    function castVote(uint256 proposalId, uint8 support) external returns (uint256 weight);

    /// @notice Cast a vote with reason
    /// @param proposalId The proposal to vote on
    /// @param support 0=Against, 1=For, 2=Abstain
    /// @param reason Explanation for the vote
    /// @return weight The voting weight used
    function castVoteWithReason(
        uint256 proposalId,
        uint8 support,
        string calldata reason
    )
        external
        returns (uint256 weight);

    /// @notice Cast a vote using EIP-712 signature
    /// @param proposalId The proposal to vote on
    /// @param support 0=Against, 1=For, 2=Abstain
    /// @param voter The voter address
    /// @param signature The EIP-712 signature
    /// @return weight The voting weight used
    function castVoteBySig(
        uint256 proposalId,
        uint8 support,
        address voter,
        bytes memory signature
    )
        external
        returns (uint256 weight);

    // ═══════════════════════════════════════════════════════════════════════════
    // VIEW FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Get the current state of a proposal
    function state(uint256 proposalId) external view returns (ProposalState);

    /// @notice Get the block number when voting starts
    function proposalSnapshot(uint256 proposalId) external view returns (uint256);

    /// @notice Get the block number when voting ends
    function proposalDeadline(uint256 proposalId) external view returns (uint256);

    /// @notice Get the proposer of a proposal
    function proposalProposer(uint256 proposalId) external view returns (address);

    /// @notice Check if an account has voted on a proposal
    function hasVoted(uint256 proposalId, address account) external view returns (bool);

    /// @notice Get voting power of an account at a specific block
    function getVotes(address account, uint256 blockNumber) external view returns (uint256);

    /// @notice Get the required quorum at a specific block
    function quorum(uint256 blockNumber) external view returns (uint256);

    /// @notice Get the voting delay (blocks before voting starts)
    function votingDelay() external view returns (uint256);

    /// @notice Get the voting period (blocks for voting)
    function votingPeriod() external view returns (uint256);

    /// @notice Get the proposal threshold (tokens needed to propose)
    function proposalThreshold() external view returns (uint256);
}

/// @title ITangleToken
/// @notice Interface for the TNT governance token
interface ITangleToken {
    /// @notice Get the current voting power of an account
    function getVotes(address account) external view returns (uint256);

    /// @notice Get historical voting power at a past block
    function getPastVotes(address account, uint256 blockNumber) external view returns (uint256);

    /// @notice Get the total supply at a past block
    function getPastTotalSupply(uint256 blockNumber) external view returns (uint256);

    /// @notice Get the delegate of an account
    function delegates(address account) external view returns (address);

    /// @notice Delegate voting power to another address
    function delegate(address delegatee) external;

    /// @notice Delegate using EIP-712 signature
    function delegateBySig(address delegatee, uint256 nonce, uint256 expiry, uint8 v, bytes32 r, bytes32 s) external;

    /// @notice Standard ERC20 functions
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}
