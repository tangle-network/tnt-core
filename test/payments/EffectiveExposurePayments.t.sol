// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import { PaymentLib } from "../../src/libraries/PaymentLib.sol";
import { Types } from "../../src/libraries/Types.sol";

/// @title EffectiveExposurePaymentsTest
/// @notice Tests for the effective exposure payment distribution fix
/// @dev Tests that operators are paid proportionally to (delegation x exposureBps) not just exposureBps
contract EffectiveExposurePaymentsTest is Test {
    uint16 constant BPS_DENOMINATOR = 10_000;

    // ═══════════════════════════════════════════════════════════════════════════
    // calculateOperatorPayments with uint256[] effectiveExposures
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Test that operators with higher effective exposure get more payment
    function test_calculateOperatorPayments_proportionalToEffectiveExposure() public pure {
        address[] memory operators = new address[](3);
        operators[0] = address(0x1); // Alice: 500 ETH x 10% = 50 ETH effective
        operators[1] = address(0x2); // Bob: 200 ETH x 10% = 20 ETH effective
        operators[2] = address(0x3); // Charlie: 0 ETH x 10% = 0 ETH effective

        uint256[] memory effectiveExposures = new uint256[](3);
        effectiveExposures[0] = 50 ether; // 50 ETH effective exposure
        effectiveExposures[1] = 20 ether; // 20 ETH effective exposure
        effectiveExposures[2] = 0;        // 0 ETH effective exposure

        uint256 totalEffectiveExposure = 70 ether;
        uint256 totalOperatorAmount = 700 ether; // 700 total to distribute
        uint256 totalRestakerAmount = 300 ether;

        PaymentLib.OperatorPayment[] memory payments = PaymentLib.calculateOperatorPayments(
            totalOperatorAmount,
            totalRestakerAmount,
            operators,
            effectiveExposures,
            totalEffectiveExposure
        );

        assertEq(payments.length, 3, "Should have 3 payment entries");
        
        // Alice: 50/70 ≈ 71.4%
        // Expected: 700 * 50 / 70 = 500 (operator), 300 * 50 / 70 ≈ 214 (restaker)
        assertEq(payments[0].operator, address(0x1), "First should be Alice");
        assertEq(payments[0].operatorShare, 500 ether, "Alice operator share should be 500 ETH");
        assertEq(payments[0].restakerShare, 214285714285714285714, "Alice restaker share ~214 ETH");

        // Bob: 20/70 ≈ 28.6%
        // Expected: 700 * 20 / 70 = 200 (operator), 300 * 20 / 70 ≈ 85.7 (restaker)
        assertEq(payments[1].operator, address(0x2), "Second should be Bob");
        assertEq(payments[1].operatorShare, 200 ether, "Bob operator share should be 200 ETH");
        assertEq(payments[1].restakerShare, 85714285714285714285, "Bob restaker share ~85.7 ETH");

        // Charlie: 0/70 = 0% (last operator gets remainder)
        // Since Charlie has 0 effective exposure, his share should be remainder after Alice and Bob
        assertEq(payments[2].operator, address(0x3), "Third should be Charlie");
        // Charlie gets remainder: 700 - 500 - 200 = 0 (operator), 300 - 214.28... - 85.71... = 0 (restaker)
        assertEq(payments[2].operatorShare, 0, "Charlie operator share should be 0");
    }

    /// @notice Test that zero total effective exposure returns empty payments
    function test_calculateOperatorPayments_zeroTotalExposure() public pure {
        address[] memory operators = new address[](2);
        operators[0] = address(0x1);
        operators[1] = address(0x2);

        uint256[] memory effectiveExposures = new uint256[](2);
        effectiveExposures[0] = 0;
        effectiveExposures[1] = 0;

        PaymentLib.OperatorPayment[] memory payments = PaymentLib.calculateOperatorPayments(
            1000 ether,
            500 ether,
            operators,
            effectiveExposures,
            0 // totalEffectiveExposure = 0
        );

        assertEq(payments.length, 0, "Should return empty array when total exposure is 0");
    }

    /// @notice Test single operator gets all payment
    function test_calculateOperatorPayments_singleOperator() public pure {
        address[] memory operators = new address[](1);
        operators[0] = address(0x1);

        uint256[] memory effectiveExposures = new uint256[](1);
        effectiveExposures[0] = 100 ether;

        PaymentLib.OperatorPayment[] memory payments = PaymentLib.calculateOperatorPayments(
            1000 ether,
            500 ether,
            operators,
            effectiveExposures,
            100 ether
        );

        assertEq(payments.length, 1, "Should have 1 payment entry");
        assertEq(payments[0].operatorShare, 1000 ether, "Single operator gets all operator share");
        assertEq(payments[0].restakerShare, 500 ether, "Single operator gets all restaker share");
    }

    /// @notice Test that dust is properly captured by last operator
    function test_calculateOperatorPayments_dustCapture() public pure {
        address[] memory operators = new address[](3);
        operators[0] = address(0x1);
        operators[1] = address(0x2);
        operators[2] = address(0x3);

        // Use values that create rounding
        uint256[] memory effectiveExposures = new uint256[](3);
        effectiveExposures[0] = 33 ether;
        effectiveExposures[1] = 33 ether;
        effectiveExposures[2] = 34 ether;

        uint256 totalAmount = 1000 ether;
        uint256 totalExposure = 100 ether;

        PaymentLib.OperatorPayment[] memory payments = PaymentLib.calculateOperatorPayments(
            totalAmount,
            0,
            operators,
            effectiveExposures,
            totalExposure
        );

        // Sum should equal total (dust captured by last operator)
        uint256 totalDistributed = payments[0].operatorShare + 
                                    payments[1].operatorShare + 
                                    payments[2].operatorShare;
        assertEq(totalDistributed, totalAmount, "Total distributed should equal input amount");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // Comparison: Old vs New payment distribution
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Demonstrate the bug fix: old method vs new method
    function test_comparison_oldVsNewPaymentDistribution() public pure {
        // Scenario:
        // - Operator A: 500 ETH delegated, 10% exposure → 50 ETH effective
        // - Operator B: 0 ETH delegated, 10% exposure → 0 ETH effective (no security!)
        //
        // OLD method (bug): Both get 50% because they both have 10% exposureBps
        // NEW method (fix): A gets 100%, B gets 0% because B provides no security

        address[] memory operators = new address[](2);
        operators[0] = address(0xA);
        operators[1] = address(0xB);

        uint256 totalPayment = 1000 ether;

        // --- OLD METHOD (using exposureBps directly) ---
        uint256[] memory oldExposures = new uint256[](2);
        oldExposures[0] = 1000; // 10% in bps
        oldExposures[1] = 1000; // 10% in bps (but NO delegation!)
        uint256 oldTotalExposure = 2000;

        PaymentLib.OperatorPayment[] memory oldPayments = PaymentLib.calculateOperatorPayments(
            totalPayment,
            0,
            operators,
            oldExposures,
            oldTotalExposure
        );

        // OLD: Both get 50% - THIS IS THE BUG
        assertEq(oldPayments[0].operatorShare, 500 ether, "OLD: A gets 500 (50%)");
        assertEq(oldPayments[1].operatorShare, 500 ether, "OLD: B gets 500 (50%) - BUG!");

        // --- NEW METHOD (using effective exposure = delegation x exposureBps) ---
        uint256[] memory newExposures = new uint256[](2);
        newExposures[0] = 50 ether;  // 500 ETH x 10% = 50 ETH effective
        newExposures[1] = 0;         // 0 ETH x 10% = 0 ETH effective
        uint256 newTotalExposure = 50 ether;

        PaymentLib.OperatorPayment[] memory newPayments = PaymentLib.calculateOperatorPayments(
            totalPayment,
            0,
            operators,
            newExposures,
            newTotalExposure
        );

        // NEW: A gets 100%, B gets 0% - CORRECT!
        assertEq(newPayments[0].operatorShare, 1000 ether, "NEW: A gets 1000 (100%) - CORRECT");
        assertEq(newPayments[1].operatorShare, 0, "NEW: B gets 0 (0%) - CORRECT");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // Edge cases
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Test with very small amounts (wei-level)
    function test_calculateOperatorPayments_smallAmounts() public pure {
        address[] memory operators = new address[](2);
        operators[0] = address(0x1);
        operators[1] = address(0x2);

        uint256[] memory effectiveExposures = new uint256[](2);
        effectiveExposures[0] = 60;
        effectiveExposures[1] = 40;

        PaymentLib.OperatorPayment[] memory payments = PaymentLib.calculateOperatorPayments(
            10, // 10 wei total
            0,
            operators,
            effectiveExposures,
            100
        );

        // 10 * 60 / 100 = 6, 10 - 6 = 4
        assertEq(payments[0].operatorShare, 6, "First operator gets 6 wei");
        assertEq(payments[1].operatorShare, 4, "Second operator gets remaining 4 wei");
    }

    /// @notice Test with unequal number of operators
    function test_calculateOperatorPayments_manyOperators() public pure {
        uint256 numOperators = 10;
        address[] memory operators = new address[](numOperators);
        uint256[] memory effectiveExposures = new uint256[](numOperators);
        uint256 totalExposure = 0;

        for (uint256 i = 0; i < numOperators; i++) {
            operators[i] = address(uint160(i + 1));
            effectiveExposures[i] = (i + 1) * 10 ether; // 10, 20, 30... ETH
            totalExposure += effectiveExposures[i];
        }

        uint256 totalAmount = 1000 ether;

        PaymentLib.OperatorPayment[] memory payments = PaymentLib.calculateOperatorPayments(
            totalAmount,
            0,
            operators,
            effectiveExposures,
            totalExposure
        );

        assertEq(payments.length, numOperators, "Should have correct number of payments");

        // Verify total distributed equals input
        uint256 totalDistributed = 0;
        for (uint256 i = 0; i < numOperators; i++) {
            totalDistributed += payments[i].operatorShare;
        }
        assertEq(totalDistributed, totalAmount, "Total should equal input");
    }

}
