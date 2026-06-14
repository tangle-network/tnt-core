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

/// @notice F-001 REGRESSION: top-up now settles reward debt before growing the
///         position's boostedScore, so freshly-added stake CANNOT retroactively
///         earn rewards accrued before it existed. Honest delegators stay whole
///         and the pool stays solvent. Fails if the harvest-before-resize
///         settlement in recordDelegate/_settle is removed.
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

    function test_F001_TopUpDoesNotStealPriorEpochRewards() public {
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
        // recordDelegate sees stakedAmount != 0 (not a new delegator). The fix makes
        // it _settle() FIRST — banking the (~0) rewards accrued to the old boostedScore
        // and advancing lastAccumulatedPerShare — before growing boostedScore, so the
        // added stake starts from the current per-share rate with zero retroactive credit.
        vault.recordDelegate(ATTACKER, OPERATOR, ASSET, LARGE, 0);

        uint256 attackerAfter = vault.pendingDelegatorRewards(ASSET, ATTACKER, OPERATOR);
        console2.log("--- after attacker top-up of LARGE ---");
        console2.log("attacker pending NOW:", attackerAfter);

        // ── OUTCOME (FIXED): recordDelegate settles the position before growing
        // boostedScore (harvest-before-resize). The added LARGE stake therefore
        // earns NOTHING from the already-distributed epoch — pending stays the
        // attacker's fair ~0 share (banked accruedRewards from the 1 wei stake +
        // zero new accrual). It does NOT jump to ~REWARD.
        assertApproxEqAbs(
            attackerAfter, 0, 1e6, "top-up must not retroactively earn the prior-epoch reward"
        );
        assertLe(attackerAfter, attackerFair + 1, "top-up did not inflate the attacker's pending");

        // The attacker has no claimable rewards: their fair share rounded to 0 and
        // the top-up earned nothing retroactively, so the claim reverts with
        // NoRewardsToClaim (owed == 0). The pool is NOT drained.
        vm.expectRevert(RewardVaults.NoRewardsToClaim.selector);
        vault.claimDelegatorRewardsFor(ASSET, OPERATOR, ATTACKER);
        console2.log("attacker claim REVERTED: NoRewardsToClaim (nothing stolen)");

        // The honest delegator, who staked LARGE for the whole epoch, is still owed
        // ~REWARD and the vault remains solvent enough to pay it.
        uint256 honestStillOwed = vault.pendingDelegatorRewards(ASSET, HONEST, OPERATOR);
        console2.log("honest STILL owed:", honestStillOwed);
        console2.log("vault can cover honest?", tnt.balanceOf(address(vault)) >= honestStillOwed);

        assertApproxEqAbs(honestStillOwed, REWARD, 1e6, "honest is still owed ~full reward");
        assertGe(
            tnt.balanceOf(address(vault)),
            honestStillOwed,
            "SOLVENT: vault can still pay the honest delegator after the top-up"
        );

        // The honest delegator can actually claim their ~full epoch reward.
        uint256 honestClaimed = vault.claimDelegatorRewardsFor(ASSET, OPERATOR, HONEST);
        console2.log("honest CLAIMED:", honestClaimed);
        console2.log("honest TNT balance:", tnt.balanceOf(HONEST));
        console2.log("vault TNT remaining:", tnt.balanceOf(address(vault)));
        assertApproxEqAbs(honestClaimed, REWARD, 1e6, "honest delegator received ~full reward");
    }
}
