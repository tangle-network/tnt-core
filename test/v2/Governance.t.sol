// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test } from "forge-std/Test.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { TimelockControllerUpgradeable } from "@openzeppelin/contracts-upgradeable/governance/TimelockControllerUpgradeable.sol";
import { IVotes } from "@openzeppelin/contracts/governance/utils/IVotes.sol";
import { IGovernor } from "@openzeppelin/contracts/governance/IGovernor.sol";

import { TangleToken } from "../../src/v2/governance/TangleToken.sol";
import { TangleGovernor } from "../../src/v2/governance/TangleGovernor.sol";
import { TangleTimelock } from "../../src/v2/governance/TangleTimelock.sol";
import { GovernanceDeployer } from "../../src/v2/governance/GovernanceDeployer.sol";

/// @title GovernanceTest
/// @notice Tests for the Tangle governance system
contract GovernanceTest is Test {
    TangleToken public token;
    TangleTimelock public timelock;
    TangleGovernor public governor;
    GovernanceDeployer public deployer;

    address public admin = address(0x1);
    address public voter1 = address(0x2);
    address public voter2 = address(0x3);
    address public voter3 = address(0x4);
    address public proposer = address(0x5);

    uint256 constant INITIAL_SUPPLY = 50_000_000 * 1e18;
    uint256 constant TIMELOCK_DELAY = 1 days;
    uint48 constant VOTING_DELAY = 100;
    uint32 constant VOTING_PERIOD = 1000;
    uint256 constant PROPOSAL_THRESHOLD = 1000 * 1e18;
    uint256 constant QUORUM_PERCENT = 4;

    function setUp() public {
        vm.startPrank(admin);

        // Deploy using the deployer
        deployer = new GovernanceDeployer();

        GovernanceDeployer.DeployParams memory params = GovernanceDeployer.DeployParams({
            tokenAdmin: admin,
            initialTokenSupply: INITIAL_SUPPLY,
            timelockDelay: TIMELOCK_DELAY,
            votingDelay: VOTING_DELAY,
            votingPeriod: VOTING_PERIOD,
            proposalThreshold: PROPOSAL_THRESHOLD,
            quorumPercent: QUORUM_PERCENT
        });

        GovernanceDeployer.DeployedContracts memory contracts = deployer.deployGovernance(params);
        token = contracts.token;
        timelock = contracts.timelock;
        governor = contracts.governor;

        // Distribute tokens for testing
        token.transfer(voter1, 1_000_000 * 1e18);
        token.transfer(voter2, 2_000_000 * 1e18);
        token.transfer(voter3, 3_000_000 * 1e18);
        token.transfer(proposer, 100_000 * 1e18); // Just above threshold

        vm.stopPrank();

        // Voters delegate to themselves
        vm.prank(voter1);
        token.delegate(voter1);
        vm.prank(voter2);
        token.delegate(voter2);
        vm.prank(voter3);
        token.delegate(voter3);
        vm.prank(proposer);
        token.delegate(proposer);

        // Mine a block to activate voting power
        vm.roll(block.number + 1);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // TOKEN TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_TokenBasics() public view {
        assertEq(token.name(), "Tangle Network Token");
        assertEq(token.symbol(), "TNT");
        assertEq(token.decimals(), 18);
        assertEq(token.totalSupply(), INITIAL_SUPPLY);
    }

    function test_TokenMaxSupply() public {
        uint256 maxSupply = token.MAX_SUPPLY();
        uint256 remaining = maxSupply - token.totalSupply();

        // Should be able to mint up to max
        vm.prank(admin);
        token.mint(admin, remaining);
        assertEq(token.totalSupply(), maxSupply);

        // Should not be able to exceed max
        vm.prank(admin);
        vm.expectRevert("Exceeds max supply");
        token.mint(admin, 1);
    }

    function test_TokenDelegation() public view {
        // Voters delegated to themselves in setUp
        assertEq(token.delegates(voter1), voter1);
        assertEq(token.getVotes(voter1), 1_000_000 * 1e18);
        assertEq(token.getVotes(voter2), 2_000_000 * 1e18);
        assertEq(token.getVotes(voter3), 3_000_000 * 1e18);
    }

    function test_TokenDelegateToOther() public {
        // voter1 delegates to voter2
        vm.prank(voter1);
        token.delegate(voter2);

        vm.roll(block.number + 1);

        assertEq(token.delegates(voter1), voter2);
        assertEq(token.getVotes(voter1), 0); // voter1 has no votes now
        assertEq(token.getVotes(voter2), 3_000_000 * 1e18); // voter2 has both
    }

    function test_TokenHistoricalVotes() public {
        // Store checkpoint before transfer (we're at block 2 after setUp's vm.roll)
        uint256 checkpointBlock = block.number - 1;

        // Transfer some tokens
        vm.prank(voter1);
        token.transfer(voter2, 500_000 * 1e18);

        // Mine blocks to create checkpoints and allow historical lookup
        vm.roll(block.number + 2);

        // Current votes should reflect transfer
        assertEq(token.getVotes(voter1), 500_000 * 1e18);
        assertEq(token.getVotes(voter2), 2_500_000 * 1e18);

        // Historical votes at checkpoint should be unchanged
        assertEq(token.getPastVotes(voter1, checkpointBlock), 1_000_000 * 1e18);
        assertEq(token.getPastVotes(voter2, checkpointBlock), 2_000_000 * 1e18);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // GOVERNOR TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_GovernorSettings() public view {
        assertEq(governor.votingDelay(), VOTING_DELAY);
        assertEq(governor.votingPeriod(), VOTING_PERIOD);
        assertEq(governor.proposalThreshold(), PROPOSAL_THRESHOLD);
    }

    function test_GovernorQuorum() public view {
        // Quorum should be 4% of total supply
        uint256 expectedQuorum = (INITIAL_SUPPLY * QUORUM_PERCENT) / 100;
        assertEq(governor.quorum(block.number - 1), expectedQuorum);
    }

    function test_CreateProposal() public {
        // Create a simple proposal
        address[] memory targets = new address[](1);
        uint256[] memory values = new uint256[](1);
        bytes[] memory calldatas = new bytes[](1);

        targets[0] = address(token);
        values[0] = 0;
        calldatas[0] = abi.encodeCall(TangleToken.mint, (voter1, 1000 * 1e18));

        vm.prank(proposer);
        uint256 proposalId = governor.propose(targets, values, calldatas, "Mint tokens to voter1");

        assertTrue(proposalId != 0);
        assertEq(uint8(governor.state(proposalId)), uint8(IGovernor.ProposalState.Pending));
    }

    function test_CreateProposal_RevertBelowThreshold() public {
        // voter1 doesn't have enough tokens to propose
        address lowVoter = address(0x999);
        vm.prank(admin);
        token.transfer(lowVoter, 100 * 1e18); // Well below threshold

        vm.prank(lowVoter);
        token.delegate(lowVoter);
        vm.roll(block.number + 1);

        address[] memory targets = new address[](1);
        uint256[] memory values = new uint256[](1);
        bytes[] memory calldatas = new bytes[](1);
        targets[0] = address(token);

        vm.prank(lowVoter);
        vm.expectRevert();
        governor.propose(targets, values, calldatas, "Should fail");
    }

    function test_VoteOnProposal() public {
        // Create proposal
        address[] memory targets = new address[](1);
        uint256[] memory values = new uint256[](1);
        bytes[] memory calldatas = new bytes[](1);
        targets[0] = address(token);
        values[0] = 0;
        calldatas[0] = abi.encodeCall(TangleToken.mint, (voter1, 1000 * 1e18));

        vm.prank(proposer);
        uint256 proposalId = governor.propose(targets, values, calldatas, "Mint tokens");

        // Move past voting delay
        vm.roll(block.number + VOTING_DELAY + 1);

        assertEq(uint8(governor.state(proposalId)), uint8(IGovernor.ProposalState.Active));

        // Cast votes
        vm.prank(voter1);
        governor.castVote(proposalId, 1); // For

        vm.prank(voter2);
        governor.castVote(proposalId, 1); // For

        vm.prank(voter3);
        governor.castVote(proposalId, 0); // Against

        assertTrue(governor.hasVoted(proposalId, voter1));
        assertTrue(governor.hasVoted(proposalId, voter2));
        assertTrue(governor.hasVoted(proposalId, voter3));
    }

    function test_VoteWithReason() public {
        address[] memory targets = new address[](1);
        uint256[] memory values = new uint256[](1);
        bytes[] memory calldatas = new bytes[](1);
        targets[0] = address(token);

        vm.prank(proposer);
        uint256 proposalId = governor.propose(targets, values, calldatas, "Test proposal");

        vm.roll(block.number + VOTING_DELAY + 1);

        vm.prank(voter1);
        governor.castVoteWithReason(proposalId, 1, "I support this because...");

        assertTrue(governor.hasVoted(proposalId, voter1));
    }

    function test_ProposalSucceeds() public {
        // Create proposal to grant MINTER_ROLE to timelock
        address[] memory targets = new address[](1);
        uint256[] memory values = new uint256[](1);
        bytes[] memory calldatas = new bytes[](1);
        targets[0] = address(token);
        values[0] = 0;
        calldatas[0] = abi.encodeCall(
            token.grantRole,
            (token.MINTER_ROLE(), address(timelock))
        );

        vm.prank(proposer);
        uint256 proposalId = governor.propose(targets, values, calldatas, "Grant minter to timelock");

        // Move to active
        vm.roll(block.number + VOTING_DELAY + 1);

        // Vote in favor (need quorum: 4% of 50M = 2M tokens)
        vm.prank(voter2); // 2M votes
        governor.castVote(proposalId, 1);

        vm.prank(voter3); // 3M votes
        governor.castVote(proposalId, 1);

        // Move past voting period
        vm.roll(block.number + VOTING_PERIOD + 1);

        assertEq(uint8(governor.state(proposalId)), uint8(IGovernor.ProposalState.Succeeded));
    }

    function test_ProposalDefeated_InsufficientQuorum() public {
        address[] memory targets = new address[](1);
        uint256[] memory values = new uint256[](1);
        bytes[] memory calldatas = new bytes[](1);
        targets[0] = address(token);

        vm.prank(proposer);
        uint256 proposalId = governor.propose(targets, values, calldatas, "Low turnout proposal");

        vm.roll(block.number + VOTING_DELAY + 1);

        // Only voter1 votes (1M, below 2M quorum)
        vm.prank(voter1);
        governor.castVote(proposalId, 1);

        vm.roll(block.number + VOTING_PERIOD + 1);

        assertEq(uint8(governor.state(proposalId)), uint8(IGovernor.ProposalState.Defeated));
    }

    function test_ProposalDefeated_MoreAgainst() public {
        address[] memory targets = new address[](1);
        uint256[] memory values = new uint256[](1);
        bytes[] memory calldatas = new bytes[](1);
        targets[0] = address(token);

        vm.prank(proposer);
        uint256 proposalId = governor.propose(targets, values, calldatas, "Unpopular proposal");

        vm.roll(block.number + VOTING_DELAY + 1);

        // voter3 (3M) votes against, voter2 (2M) votes for
        vm.prank(voter2);
        governor.castVote(proposalId, 1); // For

        vm.prank(voter3);
        governor.castVote(proposalId, 0); // Against

        vm.roll(block.number + VOTING_PERIOD + 1);

        assertEq(uint8(governor.state(proposalId)), uint8(IGovernor.ProposalState.Defeated));
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // TIMELOCK TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_TimelockRoles() public view {
        // Governor should have proposer, executor, and canceller roles
        assertTrue(timelock.isProposer(address(governor)));
        assertTrue(timelock.isExecutor(address(governor)));
        assertTrue(timelock.isCanceller(address(governor)));
    }

    function test_TimelockDelay() public view {
        assertEq(timelock.getMinDelay(), TIMELOCK_DELAY);
    }

    function test_FullGovernanceFlow() public {
        // 1. Verify admin has the required role and grant MINTER_ROLE to timelock
        assertTrue(token.hasRole(token.DEFAULT_ADMIN_ROLE(), admin), "Admin should have DEFAULT_ADMIN_ROLE");

        // Cache role to avoid prank being consumed by view call
        bytes32 minterRole = token.MINTER_ROLE();
        vm.prank(admin);
        token.grantRole(minterRole, address(timelock));

        // 2. Create proposal to mint tokens
        address[] memory targets = new address[](1);
        uint256[] memory values = new uint256[](1);
        bytes[] memory calldatas = new bytes[](1);
        targets[0] = address(token);
        values[0] = 0;
        calldatas[0] = abi.encodeCall(TangleToken.mint, (voter1, 1_000_000 * 1e18));
        string memory description = "Mint 1M tokens to voter1";

        vm.prank(proposer);
        uint256 proposalId = governor.propose(targets, values, calldatas, description);

        // 3. Move to active and vote
        vm.roll(block.number + VOTING_DELAY + 1);

        vm.prank(voter2);
        governor.castVote(proposalId, 1);
        vm.prank(voter3);
        governor.castVote(proposalId, 1);

        // 4. Move past voting period
        vm.roll(block.number + VOTING_PERIOD + 1);
        assertEq(uint8(governor.state(proposalId)), uint8(IGovernor.ProposalState.Succeeded));

        // 5. Queue the proposal
        bytes32 descriptionHash = keccak256(bytes(description));
        governor.queue(targets, values, calldatas, descriptionHash);
        assertEq(uint8(governor.state(proposalId)), uint8(IGovernor.ProposalState.Queued));

        // 6. Wait for timelock delay
        vm.warp(block.timestamp + TIMELOCK_DELAY + 1);

        // 7. Execute
        uint256 voter1BalanceBefore = token.balanceOf(voter1);
        governor.execute(targets, values, calldatas, descriptionHash);

        assertEq(uint8(governor.state(proposalId)), uint8(IGovernor.ProposalState.Executed));
        assertEq(token.balanceOf(voter1), voter1BalanceBefore + 1_000_000 * 1e18);
    }

    function test_ProposalLifecycle_QueueAndExecuteGuards() public {
        bytes32 minterRole = token.MINTER_ROLE();
        vm.prank(admin);
        token.grantRole(minterRole, address(timelock));

        address[] memory targets = new address[](1);
        uint256[] memory values = new uint256[](1);
        bytes[] memory calldatas = new bytes[](1);
        targets[0] = address(token);
        values[0] = 0;
        uint256 mintAmount = 500 * 1e18;
        calldatas[0] = abi.encodeCall(TangleToken.mint, (voter1, mintAmount));
        string memory description = "Queue lifecycle regression";
        bytes32 succeededBitmap = _stateBitmap(IGovernor.ProposalState.Succeeded);

        vm.prank(proposer);
        uint256 proposalId = governor.propose(targets, values, calldatas, description);
        bytes32 descriptionHash = keccak256(bytes(description));

        vm.expectRevert(
            abi.encodeWithSelector(
                IGovernor.GovernorUnexpectedProposalState.selector,
                proposalId,
                IGovernor.ProposalState.Pending,
                succeededBitmap
            )
        );
        governor.queue(targets, values, calldatas, descriptionHash);

        vm.roll(block.number + VOTING_DELAY + 1);
        vm.prank(voter2);
        governor.castVote(proposalId, 1);
        vm.prank(voter3);
        governor.castVote(proposalId, 1);

        vm.roll(block.number + VOTING_PERIOD + 1);
        assertEq(uint8(governor.state(proposalId)), uint8(IGovernor.ProposalState.Succeeded));
        assertTrue(governor.proposalNeedsQueuing(proposalId));

        governor.queue(targets, values, calldatas, descriptionHash);
        assertEq(uint8(governor.state(proposalId)), uint8(IGovernor.ProposalState.Queued));

        vm.expectRevert(
            abi.encodeWithSelector(
                IGovernor.GovernorUnexpectedProposalState.selector,
                proposalId,
                IGovernor.ProposalState.Queued,
                succeededBitmap
            )
        );
        governor.queue(targets, values, calldatas, descriptionHash);

        bytes32 salt = _timelockSalt(descriptionHash);
        bytes32 opId = timelock.hashOperationBatch(targets, values, calldatas, 0, salt);
        bytes32 readyState = bytes32(uint256(1) << uint8(TimelockControllerUpgradeable.OperationState.Ready));
        vm.expectRevert(
            abi.encodeWithSelector(
                TimelockControllerUpgradeable.TimelockUnexpectedOperationState.selector,
                opId,
                readyState
            )
        );
        governor.execute(targets, values, calldatas, descriptionHash);

        vm.warp(block.timestamp + TIMELOCK_DELAY + 1);
        uint256 voter1BalanceBefore = token.balanceOf(voter1);
        governor.execute(targets, values, calldatas, descriptionHash);

        assertEq(token.balanceOf(voter1), voter1BalanceBefore + mintAmount);
        assertEq(uint8(governor.state(proposalId)), uint8(IGovernor.ProposalState.Executed));
    }

    function test_ProposalLifecycle_CancelPreventsProgression() public {
        address[] memory targets = new address[](1);
        uint256[] memory values = new uint256[](1);
        bytes[] memory calldatas = new bytes[](1);
        targets[0] = address(token);
        values[0] = 0;
        calldatas[0] = abi.encodeCall(TangleToken.mint, (voter1, 1));
        string memory description = "Cancel lifecycle regression";
        bytes32 succeeded = _stateBitmap(IGovernor.ProposalState.Succeeded);
        bytes32 executableStates = succeeded | _stateBitmap(IGovernor.ProposalState.Queued);

        vm.prank(proposer);
        uint256 proposalId = governor.propose(targets, values, calldatas, description);
        bytes32 descriptionHash = keccak256(bytes(description));

        vm.prank(proposer);
        governor.cancel(targets, values, calldatas, descriptionHash);

        assertEq(uint8(governor.state(proposalId)), uint8(IGovernor.ProposalState.Canceled));

        vm.expectRevert(
            abi.encodeWithSelector(
                IGovernor.GovernorUnexpectedProposalState.selector,
                proposalId,
                IGovernor.ProposalState.Canceled,
                succeeded
            )
        );
        governor.queue(targets, values, calldatas, descriptionHash);

        vm.expectRevert(
            abi.encodeWithSelector(
                IGovernor.GovernorUnexpectedProposalState.selector,
                proposalId,
                IGovernor.ProposalState.Canceled,
                executableStates
            )
        );
        governor.execute(targets, values, calldatas, descriptionHash);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // DEPLOYER TESTS
    // ═══════════════════════════════════════════════════════════════════════════

    function test_DeployerDefaultParams() public view {
        GovernanceDeployer.DeployParams memory mainnetParams = deployer.getDefaultMainnetParams(admin);
        assertEq(mainnetParams.timelockDelay, 2 days);
        assertEq(mainnetParams.votingDelay, 7200);
        assertEq(mainnetParams.votingPeriod, 50400);
        assertEq(mainnetParams.quorumPercent, 4);

        GovernanceDeployer.DeployParams memory testnetParams = deployer.getDefaultTestnetParams(admin);
        assertEq(testnetParams.timelockDelay, 1 days);
        assertEq(testnetParams.votingDelay, 100);
        assertEq(testnetParams.votingPeriod, 1000);
        assertEq(testnetParams.quorumPercent, 1);
    }

    function test_DeployerGetTangleRoles() public view {
        bytes32[] memory roles = deployer.getTangleRoles();
        assertEq(roles.length, 5);
        assertEq(roles[0], bytes32(0)); // DEFAULT_ADMIN_ROLE
        assertEq(roles[1], keccak256("ADMIN_ROLE"));
        assertEq(roles[2], keccak256("PAUSER_ROLE"));
        assertEq(roles[3], keccak256("UPGRADER_ROLE"));
        assertEq(roles[4], keccak256("SLASH_ADMIN_ROLE"));
    }

    function test_DeployerGetMultiAssetDelegationRoles() public view {
        bytes32[] memory roles = deployer.getMultiAssetDelegationRoles();
        assertEq(roles.length, 4);
        assertEq(roles[0], bytes32(0)); // DEFAULT_ADMIN_ROLE
        assertEq(roles[1], keccak256("ADMIN_ROLE"));
        assertEq(roles[2], keccak256("ASSET_MANAGER_ROLE"));
        assertEq(roles[3], keccak256("SLASHER_ROLE"));
    }

    function test_DeployerGetTokenRoles() public view {
        bytes32[] memory roles = deployer.getTokenRoles();
        assertEq(roles.length, 3);
        assertEq(roles[0], bytes32(0)); // DEFAULT_ADMIN_ROLE
        assertEq(roles[1], keccak256("MINTER_ROLE"));
        assertEq(roles[2], keccak256("UPGRADER_ROLE"));
    }

    function test_DeployerOperationalRoles() public view {
        // Tangle operational roles (excludes DEFAULT_ADMIN_ROLE)
        bytes32[] memory tangleOps = deployer.getTangleOperationalRoles();
        assertEq(tangleOps.length, 4);
        assertEq(tangleOps[0], keccak256("ADMIN_ROLE"));

        // MultiAssetDelegation operational roles
        bytes32[] memory madOps = deployer.getMultiAssetDelegationOperationalRoles();
        assertEq(madOps.length, 3);
        assertEq(madOps[0], keccak256("ADMIN_ROLE"));
        assertEq(madOps[1], keccak256("ASSET_MANAGER_ROLE"));

        // Token operational roles
        bytes32[] memory tokenOps = deployer.getTokenOperationalRoles();
        assertEq(tokenOps.length, 2);
        assertEq(tokenOps[0], keccak256("MINTER_ROLE"));
    }

    function test_RenounceTimelockAdmin() public {
        // Deployer still has admin role
        assertTrue(timelock.hasRole(timelock.DEFAULT_ADMIN_ROLE(), address(deployer)));

        // Renounce admin
        deployer.renounceTimelockAdmin(timelock);

        // Deployer no longer has admin role
        assertFalse(timelock.hasRole(timelock.DEFAULT_ADMIN_ROLE(), address(deployer)));
    }

    function _stateBitmap(IGovernor.ProposalState proposalState) internal pure returns (bytes32) {
        return bytes32(uint256(1) << uint8(proposalState));
    }

    function _timelockSalt(bytes32 descriptionHash) internal view returns (bytes32) {
        return bytes32(bytes20(address(governor))) ^ descriptionHash;
    }
}

/// @title GovernanceUpgradeTest
/// @notice Tests for governance-controlled upgrades
contract GovernanceUpgradeTest is Test {
    TangleToken public token;
    TangleTimelock public timelock;
    TangleGovernor public governor;

    address public admin = address(0x1);
    address public voter = address(0x2);

    function setUp() public {
        vm.startPrank(admin);

        GovernanceDeployer deployer = new GovernanceDeployer();
        GovernanceDeployer.DeployParams memory params = GovernanceDeployer.DeployParams({
            tokenAdmin: admin,
            initialTokenSupply: 10_000_000 * 1e18,
            timelockDelay: 1 days,
            votingDelay: 10,
            votingPeriod: 100,
            proposalThreshold: 100 * 1e18,
            quorumPercent: 1
        });

        GovernanceDeployer.DeployedContracts memory contracts = deployer.deployGovernance(params);
        token = contracts.token;
        timelock = contracts.timelock;
        governor = contracts.governor;

        // Give voter enough tokens
        token.transfer(voter, 5_000_000 * 1e18);

        vm.stopPrank();

        vm.prank(voter);
        token.delegate(voter);
        vm.roll(block.number + 1);
    }

    function test_GovernorSelfUpgrade() public {
        // Deploy new implementation
        TangleGovernor newImpl = new TangleGovernor();

        // Create upgrade proposal
        address[] memory targets = new address[](1);
        uint256[] memory values = new uint256[](1);
        bytes[] memory calldatas = new bytes[](1);
        targets[0] = address(governor);
        values[0] = 0;
        calldatas[0] = abi.encodeCall(governor.upgradeToAndCall, (address(newImpl), ""));
        string memory description = "Upgrade governor implementation";

        vm.prank(voter);
        uint256 proposalId = governor.propose(targets, values, calldatas, description);

        // Vote and pass
        vm.roll(block.number + 11);
        vm.prank(voter);
        governor.castVote(proposalId, 1);

        vm.roll(block.number + 101);

        // Queue and execute
        bytes32 descHash = keccak256(bytes(description));
        governor.queue(targets, values, calldatas, descHash);
        vm.warp(block.timestamp + 1 days + 1);

        governor.execute(targets, values, calldatas, descHash);

        // Governor should still work after upgrade
        assertEq(governor.votingDelay(), 10);
    }

    function test_TokenUpgradeViaGovernance() public {
        // Grant UPGRADER_ROLE to timelock (cache role to avoid prank consumption)
        bytes32 upgraderRole = token.UPGRADER_ROLE();
        vm.prank(admin);
        token.grantRole(upgraderRole, address(timelock));

        // Deploy new implementation
        TangleToken newImpl = new TangleToken();

        // Create upgrade proposal
        address[] memory targets = new address[](1);
        uint256[] memory values = new uint256[](1);
        bytes[] memory calldatas = new bytes[](1);
        targets[0] = address(token);
        values[0] = 0;
        calldatas[0] = abi.encodeCall(token.upgradeToAndCall, (address(newImpl), ""));
        string memory description = "Upgrade token implementation";

        vm.prank(voter);
        uint256 proposalId = governor.propose(targets, values, calldatas, description);

        vm.roll(block.number + 11);
        vm.prank(voter);
        governor.castVote(proposalId, 1);

        vm.roll(block.number + 101);

        bytes32 descHash = keccak256(bytes(description));
        governor.queue(targets, values, calldatas, descHash);
        vm.warp(block.timestamp + 1 days + 1);

        governor.execute(targets, values, calldatas, descHash);

        // Token should still work
        assertEq(token.symbol(), "TNT");
        assertEq(token.totalSupply(), 10_000_000 * 1e18);
    }
}
