// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { DelegationTestHarness } from "../restaking/DelegationTestHarness.sol";
import { Types } from "../../../src/v2/libraries/Types.sol";

/// @notice Full stack scenario that deterministically simulates deposits, delegations,
///         withdraw queues, and round advancement. This doubles as an
///         end-to-end trace for the indexer: run the test with `forge test -vvv` to emit
///         the event log, or replay the resulting transactions against `envio dev`.
contract FullStackScenarioTest is DelegationTestHarness {
    uint256 internal constant STEP_SECONDS = 5;
    uint256 internal constant ITERATIONS = 12;

    event ScenarioTick(
        uint256 indexed tick, address indexed delegator, address indexed operator, bytes32 action, uint256 amount
    );

    function setUp() public override {
        super.setUp();
        _registerOperator(operator2, 8 ether);
        _registerOperator(operator3, 6 ether);
    }

    function test_full_stack_simulation() public {
        address[3] memory delegators = [delegator1, delegator2, delegator3];
        address[3] memory operators = [operator1, operator2, operator3];
        address[2] memory tokens = [address(token), address(token2)];

        for (uint256 tick = 0; tick < ITERATIONS; tick++) {
            address delegator = delegators[tick % delegators.length];
            address operator = operators[tick % operators.length];
            uint256 amount = (tick + 1) * 0.2 ether;

            if (tick % 2 == 0) {
                _depositAndDelegate(delegator, operator, amount);
                emit ScenarioTick(tick, delegator, operator, keccak256("native-deposit"), amount);
            } else {
                address tokenAddr = tokens[tick % tokens.length];
                _depositAndDelegateErc20(delegator, operator, tokenAddr, amount);
                emit ScenarioTick(tick, delegator, operator, keccak256("erc20-deposit"), amount);
            }

            if (tick % 4 == 3) {
                uint256 unstakeAmount = amount / 2;
                address tokenAddr = tick % 2 == 1 ? tokens[tick % tokens.length] : address(0);
                _scheduleUnstake(delegator, operator, tokenAddr, unstakeAmount);
                emit ScenarioTick(tick, delegator, operator, keccak256("schedule-unstake"), unstakeAmount);
            }

            if (tick % 5 == 4) {
                uint256 liquidAmount = amount / 2;
                _depositNative(delegator, liquidAmount);
                emit ScenarioTick(tick, delegator, operator, keccak256("native-hodl"), liquidAmount);
                _scheduleWithdraw(delegator, address(0), liquidAmount / 2);
                emit ScenarioTick(tick, delegator, operator, keccak256("schedule-withdraw"), liquidAmount / 2);
            }

            skip(STEP_SECONDS);
            // Try to advance round - will silently fail if too soon (rate limited)
            try delegation.advanceRound() {} catch {}
        }

        // Make rounds ready for earlier withdrawals/unstakes.
        _advanceRounds(12);
        _executeUnstake(delegator1);
        _executeUnstake(delegator2);
        _executeWithdraw(delegator1);
        _executeWithdraw(delegator2);

        // Sanity assertions: every operator should retain active stake, delegators are non-zero.
        for (uint256 i = 0; i < operators.length; i++) {
            assertOperatorActive(operators[i]);
        }
        for (uint256 i = 0; i < delegators.length; i++) {
            uint256 totalDelegated = delegation.getTotalDelegation(delegators[i]);
            assertGt(totalDelegated, 0, "delegator lost all stake");
        }
    }
}
