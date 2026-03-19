// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test } from "forge-std/Test.sol";
import { MockERC20 } from "../MockERC20.sol";
import { ShieldedCredits } from "../../src/shielded/ShieldedCredits.sol";
import { IShieldedCredits } from "../../src/shielded/IShieldedCredits.sol";
import { MessageHashUtils } from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

/// @title ShieldedCreditsTest
/// @notice Tests the anonymous prepaid credit system.
contract ShieldedCreditsTest is Test {
    ShieldedCredits public credits;
    MockERC20 public token;

    // Ephemeral spending key (simulates what a user would generate)
    uint256 internal spendingPrivKey = 0xdead;
    address internal spendingPubKey;
    bytes32 internal salt = keccak256("test-salt");
    bytes32 internal commitment;

    address public funder = makeAddr("funder"); // ShieldedGateway in production
    address public operator1 = makeAddr("operator1");

    uint256 public constant CREDIT_AMOUNT = 100 ether;

    function setUp() public {
        credits = new ShieldedCredits();
        token = new MockERC20();

        spendingPubKey = vm.addr(spendingPrivKey);
        commitment = keccak256(abi.encodePacked(spendingPubKey, salt));

        // Fund the "gateway" with tokens
        token.mint(funder, CREDIT_AMOUNT * 10);
        vm.prank(funder);
        token.approve(address(credits), type(uint256).max);
    }

    // ═══════════════════════════════════════════════════════════════════════
    // FUNDING
    // ═══════════════════════════════════════════════════════════════════════

    function test_fundCredits() public {
        vm.prank(funder);
        credits.fundCredits(address(token), CREDIT_AMOUNT, commitment, spendingPubKey);

        IShieldedCredits.CreditAccountView memory acct = credits.getAccount(commitment);
        assertEq(acct.spendingKey, spendingPubKey);
        assertEq(acct.token, address(token));
        assertEq(acct.balance, CREDIT_AMOUNT);
        assertEq(acct.totalFunded, CREDIT_AMOUNT);
        assertEq(acct.nonce, 0);
    }

    function test_fundCredits_topUp() public {
        vm.prank(funder);
        credits.fundCredits(address(token), CREDIT_AMOUNT, commitment, spendingPubKey);

        vm.prank(funder);
        credits.fundCredits(address(token), 50 ether, commitment, spendingPubKey);

        IShieldedCredits.CreditAccountView memory acct = credits.getAccount(commitment);
        assertEq(acct.balance, CREDIT_AMOUNT + 50 ether);
        assertEq(acct.totalFunded, CREDIT_AMOUNT + 50 ether);
    }

    function test_fundCredits_wrongKey_reverts() public {
        vm.prank(funder);
        credits.fundCredits(address(token), CREDIT_AMOUNT, commitment, spendingPubKey);

        address wrongKey = makeAddr("wrong");
        vm.prank(funder);
        vm.expectRevert(abi.encodeWithSelector(IShieldedCredits.SpendingKeyMismatch.selector, spendingPubKey, wrongKey));
        credits.fundCredits(address(token), 10 ether, commitment, wrongKey);
    }

    function test_fundCredits_wrongToken_reverts() public {
        vm.prank(funder);
        credits.fundCredits(address(token), CREDIT_AMOUNT, commitment, spendingPubKey);

        MockERC20 otherToken = new MockERC20();
        otherToken.mint(funder, 10 ether);
        vm.prank(funder);
        otherToken.approve(address(credits), 10 ether);

        vm.prank(funder);
        vm.expectRevert(
            abi.encodeWithSelector(IShieldedCredits.TokenMismatch.selector, address(token), address(otherToken))
        );
        credits.fundCredits(address(otherToken), 10 ether, commitment, spendingPubKey);
    }

    // ═══════════════════════════════════════════════════════════════════════
    // SPENDING
    // ═══════════════════════════════════════════════════════════════════════

    function test_authorizeSpend() public {
        _fundAccount();

        uint256 spendAmount = 5 ether;
        IShieldedCredits.SpendAuth memory auth = _signSpend(0, 64, 0, spendAmount, 0);

        bytes32 authHash = credits.authorizeSpend(auth);
        assertTrue(authHash != bytes32(0));

        // Check balance deducted
        IShieldedCredits.CreditAccountView memory acct = credits.getAccount(commitment);
        assertEq(acct.balance, CREDIT_AMOUNT - spendAmount);
        assertEq(acct.totalSpent, spendAmount);
        assertEq(acct.nonce, 1);

        // Check spend recorded
        (uint256 amount,, address op, uint64 exp, bool claimed) = credits.getSpendAuth(authHash);
        assertEq(amount, spendAmount);
        assertEq(op, operator1);
        assertTrue(exp > 0);
        assertFalse(claimed);
    }

    function test_authorizeSpend_badSignature_reverts() public {
        _fundAccount();

        IShieldedCredits.SpendAuth memory auth = _signSpend(0, 64, 0, 5 ether, 0);
        // Corrupt the signature — OZ 5.x ECDSA.recover reverts on invalid sigs
        auth.signature[0] = bytes1(uint8(auth.signature[0]) + 1);

        vm.expectRevert(); // ECDSAInvalidSignature or InvalidSignature
        credits.authorizeSpend(auth);
    }

    function test_authorizeSpend_replayNonce_reverts() public {
        _fundAccount();

        IShieldedCredits.SpendAuth memory auth0 = _signSpend(0, 64, 0, 1 ether, 0);
        credits.authorizeSpend(auth0);

        // Try same nonce again
        IShieldedCredits.SpendAuth memory auth0again = _signSpend(0, 64, 0, 1 ether, 0);
        vm.expectRevert(abi.encodeWithSelector(IShieldedCredits.InvalidNonce.selector, 1, 0));
        credits.authorizeSpend(auth0again);
    }

    function test_authorizeSpend_insufficientBalance_reverts() public {
        _fundAccount();

        IShieldedCredits.SpendAuth memory auth = _signSpend(0, 64, 0, CREDIT_AMOUNT + 1, 0);
        vm.expectRevert(
            abi.encodeWithSelector(IShieldedCredits.InsufficientCredits.selector, CREDIT_AMOUNT, CREDIT_AMOUNT + 1)
        );
        credits.authorizeSpend(auth);
    }

    function test_authorizeSpend_expired_reverts() public {
        _fundAccount();

        // Expiry in the past
        IShieldedCredits.SpendAuth memory auth = _signSpendWithExpiry(0, 64, 0, 1 ether, 0, uint64(block.timestamp - 1));
        vm.expectRevert();
        credits.authorizeSpend(auth);
    }

    function test_multipleSpends_sequential() public {
        _fundAccount();

        for (uint256 i = 0; i < 5; i++) {
            IShieldedCredits.SpendAuth memory auth = _signSpend(0, 64, 0, 1 ether, i);
            credits.authorizeSpend(auth);
        }

        IShieldedCredits.CreditAccountView memory acct = credits.getAccount(commitment);
        assertEq(acct.balance, CREDIT_AMOUNT - 5 ether);
        assertEq(acct.nonce, 5);
    }

    // ═══════════════════════════════════════════════════════════════════════
    // CLAIMING
    // ═══════════════════════════════════════════════════════════════════════

    function test_claimPayment() public {
        _fundAccount();

        uint256 spendAmount = 5 ether;
        IShieldedCredits.SpendAuth memory auth = _signSpend(0, 64, 0, spendAmount, 0);
        bytes32 authHash = credits.authorizeSpend(auth);

        uint256 opBalBefore = token.balanceOf(operator1);
        vm.prank(operator1); // Must be the designated operator
        credits.claimPayment(authHash, operator1);
        uint256 opBalAfter = token.balanceOf(operator1);

        assertEq(opBalAfter - opBalBefore, spendAmount);

        // Verify claimed
        (,,,, bool claimed) = credits.getSpendAuth(authHash);
        assertTrue(claimed);
    }

    function test_claimPayment_wrongOperator_reverts() public {
        _fundAccount();

        IShieldedCredits.SpendAuth memory auth = _signSpend(0, 64, 0, 5 ether, 0);
        bytes32 authHash = credits.authorizeSpend(auth);

        address attacker = makeAddr("attacker");
        vm.prank(attacker);
        vm.expectRevert(abi.encodeWithSelector(IShieldedCredits.NotDesignatedOperator.selector, operator1, attacker));
        credits.claimPayment(authHash, attacker);
    }

    function test_claimPayment_doubleClaim_reverts() public {
        _fundAccount();

        IShieldedCredits.SpendAuth memory auth = _signSpend(0, 64, 0, 5 ether, 0);
        bytes32 authHash = credits.authorizeSpend(auth);

        vm.prank(operator1);
        credits.claimPayment(authHash, operator1);

        vm.prank(operator1);
        vm.expectRevert(abi.encodeWithSelector(IShieldedCredits.AlreadyClaimed.selector, authHash));
        credits.claimPayment(authHash, operator1);
    }

    function test_claimPayment_notFound_reverts() public {
        bytes32 fakeHash = keccak256("fake");
        vm.expectRevert(abi.encodeWithSelector(IShieldedCredits.AuthNotFound.selector, fakeHash));
        credits.claimPayment(fakeHash, operator1);
    }

    // ═══════════════════════════════════════════════════════════════════════
    // WITHDRAWAL
    // ═══════════════════════════════════════════════════════════════════════

    function test_withdrawCredits() public {
        _fundAccount();

        address recipient = makeAddr("withdrawRecipient");
        uint256 withdrawAmount = 30 ether;

        bytes memory sig = _signWithdraw(commitment, recipient, withdrawAmount, 0);
        credits.withdrawCredits(commitment, recipient, withdrawAmount, 0, sig);

        assertEq(token.balanceOf(recipient), withdrawAmount);

        IShieldedCredits.CreditAccountView memory acct = credits.getAccount(commitment);
        assertEq(acct.balance, CREDIT_AMOUNT - withdrawAmount);
        assertEq(acct.nonce, 1);
    }

    function test_withdrawCredits_badSignature_reverts() public {
        _fundAccount();

        address recipient = makeAddr("withdrawRecipient");
        bytes memory sig = _signWithdraw(commitment, recipient, 10 ether, 0);
        sig[0] = bytes1(uint8(sig[0]) + 1); // corrupt

        vm.expectRevert(); // ECDSAInvalidSignature or InvalidSignature
        credits.withdrawCredits(commitment, recipient, 10 ether, 0, sig);
    }

    // ═══════════════════════════════════════════════════════════════════════
    // EXPIRY & RECLAIM
    // ═══════════════════════════════════════════════════════════════════════

    function test_claimPayment_afterExpiry_reverts() public {
        _fundAccount();

        uint256 spendAmount = 5 ether;
        IShieldedCredits.SpendAuth memory auth = _signSpend(0, 64, 0, spendAmount, 0);
        bytes32 authHash = credits.authorizeSpend(auth);

        // Warp past expiry
        vm.warp(block.timestamp + 3601);

        vm.prank(operator1);
        vm.expectRevert();
        credits.claimPayment(authHash, operator1);
    }

    function test_reclaimExpiredAuth() public {
        _fundAccount();

        uint256 spendAmount = 5 ether;
        IShieldedCredits.SpendAuth memory auth = _signSpend(0, 64, 0, spendAmount, 0);
        bytes32 authHash = credits.authorizeSpend(auth);

        // Balance should be deducted
        IShieldedCredits.CreditAccountView memory acctBefore = credits.getAccount(commitment);
        assertEq(acctBefore.balance, CREDIT_AMOUNT - spendAmount);

        // Warp past expiry
        vm.warp(block.timestamp + 3601);

        // Reclaim
        credits.reclaimExpiredAuth(authHash, commitment);

        // Balance should be restored
        IShieldedCredits.CreditAccountView memory acctAfter = credits.getAccount(commitment);
        assertEq(acctAfter.balance, CREDIT_AMOUNT);

        // Spend should be marked as claimed (preventing double-reclaim)
        (,,,, bool claimed) = credits.getSpendAuth(authHash);
        assertTrue(claimed);
    }

    function test_reclaimExpiredAuth_notExpired_reverts() public {
        _fundAccount();

        IShieldedCredits.SpendAuth memory auth = _signSpend(0, 64, 0, 1 ether, 0);
        bytes32 authHash = credits.authorizeSpend(auth);

        vm.expectRevert();
        credits.reclaimExpiredAuth(authHash, commitment);
    }

    function test_reclaimExpiredAuth_alreadyClaimed_reverts() public {
        _fundAccount();

        IShieldedCredits.SpendAuth memory auth = _signSpend(0, 64, 0, 1 ether, 0);
        bytes32 authHash = credits.authorizeSpend(auth);

        // Operator claims before expiry
        vm.prank(operator1);
        credits.claimPayment(authHash, operator1);

        // Warp past expiry
        vm.warp(block.timestamp + 3601);

        // Reclaim should fail — already claimed
        vm.expectRevert(abi.encodeWithSelector(IShieldedCredits.AlreadyClaimed.selector, authHash));
        credits.reclaimExpiredAuth(authHash, commitment);
    }

    // ═══════════════════════════════════════════════════════════════════════
    // END-TO-END
    // ═══════════════════════════════════════════════════════════════════════

    function test_endToEnd_fundSpendClaim() public {
        // 1. Fund credits (simulates ShieldedGateway forwarding VAnchor withdrawal)
        _fundAccount();
        assertEq(credits.getAccount(commitment).balance, CREDIT_AMOUNT);

        // 2. User authorizes 3 job payments
        bytes32[] memory authHashes = new bytes32[](3);
        uint256 perJobCost = 2 ether;
        for (uint256 i = 0; i < 3; i++) {
            IShieldedCredits.SpendAuth memory auth = _signSpend(42, 0, 0, perJobCost, i);
            authHashes[i] = credits.authorizeSpend(auth);
        }

        // Balance should reflect 3 deductions
        assertEq(credits.getAccount(commitment).balance, CREDIT_AMOUNT - (perJobCost * 3));

        // 3. Operator claims after completing jobs
        for (uint256 i = 0; i < 3; i++) {
            vm.prank(operator1);
            credits.claimPayment(authHashes[i], operator1);
        }
        assertEq(token.balanceOf(operator1), perJobCost * 3);

        // 4. User withdraws remaining credits
        uint256 remaining = credits.getAccount(commitment).balance;
        address exitAddr = makeAddr("exit");
        bytes memory sig = _signWithdraw(commitment, exitAddr, remaining, 3); // nonce=3 after 3 spends
        credits.withdrawCredits(commitment, exitAddr, remaining, 3, sig);

        assertEq(token.balanceOf(exitAddr), remaining);
        assertEq(credits.getAccount(commitment).balance, 0);
    }

    // ═══════════════════════════════════════════════════════════════════════
    // FUZZ TESTS
    // ═══════════════════════════════════════════════════════════════════════

    function testFuzz_fundAndSpend(uint256 fundAmount, uint256 spendAmount) public {
        fundAmount = bound(fundAmount, 1 ether, 1000 ether);
        spendAmount = bound(spendAmount, 1, fundAmount);

        // Mint enough tokens
        token.mint(funder, fundAmount);
        vm.prank(funder);
        credits.fundCredits(address(token), fundAmount, commitment, spendingPubKey);

        IShieldedCredits.SpendAuth memory auth = _signSpend(0, 0, 0, spendAmount, 0);
        credits.authorizeSpend(auth);

        IShieldedCredits.CreditAccountView memory acct = credits.getAccount(commitment);
        assertEq(acct.balance + acct.totalSpent, acct.totalFunded, "balance + totalSpent == totalFunded");
    }

    function testFuzz_multipleSpends(uint256 seed) public {
        uint256 fundAmount = 500 ether;
        token.mint(funder, fundAmount);
        vm.prank(funder);
        credits.fundCredits(address(token), fundAmount, commitment, spendingPubKey);

        uint256 numSpends = (seed % 10) + 1; // 1..10 spends
        uint256 remaining = fundAmount;

        for (uint256 i = 0; i < numSpends; i++) {
            if (remaining == 0) break;
            // Derive a pseudo-random spend amount from seed + i
            uint256 spendAmt = (uint256(keccak256(abi.encode(seed, i))) % remaining) + 1;
            spendAmt = spendAmt > remaining ? remaining : spendAmt;

            IShieldedCredits.SpendAuth memory auth = _signSpend(0, 0, 0, spendAmt, i);
            credits.authorizeSpend(auth);

            remaining -= spendAmt;

            IShieldedCredits.CreditAccountView memory acct = credits.getAccount(commitment);
            assertEq(acct.balance + acct.totalSpent, acct.totalFunded, "invariant after each spend");
        }
    }

    function testFuzz_fundSpendClaimWithdraw(uint256 fundAmt, uint256 spendAmt) public {
        fundAmt = bound(fundAmt, 1 ether, 1000 ether);
        spendAmt = bound(spendAmt, 1, fundAmt);

        // Mint and fund
        token.mint(funder, fundAmt);
        vm.prank(funder);
        credits.fundCredits(address(token), fundAmt, commitment, spendingPubKey);

        uint256 contractBalBefore = token.balanceOf(address(credits));

        // Spend
        IShieldedCredits.SpendAuth memory auth = _signSpend(0, 0, 0, spendAmt, 0);
        bytes32 authHash = credits.authorizeSpend(auth);

        // Claim
        vm.prank(operator1);
        credits.claimPayment(authHash, operator1);
        assertEq(token.balanceOf(operator1), spendAmt, "operator got spendAmt");

        // Withdraw remainder
        uint256 remainder = fundAmt - spendAmt;
        if (remainder > 0) {
            address withdrawRecipient = makeAddr("fuzzWithdrawRecipient");
            bytes memory sig = _signWithdraw(commitment, withdrawRecipient, remainder, 1);
            credits.withdrawCredits(commitment, withdrawRecipient, remainder, 1, sig);
            assertEq(token.balanceOf(withdrawRecipient), remainder, "recipient got remainder");
        }

        IShieldedCredits.CreditAccountView memory acct = credits.getAccount(commitment);
        assertEq(acct.balance, 0, "credit balance is 0");
        assertEq(
            token.balanceOf(address(credits)), contractBalBefore - fundAmt, "contract balance decreased by fundAmt"
        );
    }

    function testFuzz_reclaimAfterExpiry(uint256 amount, uint256 expiryOffset) public {
        amount = bound(amount, 1 ether, 1000 ether);
        expiryOffset = bound(expiryOffset, 1, 365 days);

        token.mint(funder, amount);
        vm.prank(funder);
        credits.fundCredits(address(token), amount, commitment, spendingPubKey);

        uint64 expiry = uint64(block.timestamp + expiryOffset);
        IShieldedCredits.SpendAuth memory auth = _signSpendWithExpiry(0, 0, 0, amount, 0, expiry);
        bytes32 authHash = credits.authorizeSpend(auth);

        IShieldedCredits.CreditAccountView memory acctBefore = credits.getAccount(commitment);
        assertEq(acctBefore.balance, 0, "balance is 0 after full spend");

        // Warp past expiry
        vm.warp(block.timestamp + expiryOffset + 1);

        credits.reclaimExpiredAuth(authHash, commitment);

        IShieldedCredits.CreditAccountView memory acctAfter = credits.getAccount(commitment);
        assertEq(acctAfter.balance, amount, "balance restored exactly");
        assertEq(acctAfter.totalSpent, 0, "totalSpent back to 0");
    }

    // ═══════════════════════════════════════════════════════════════════════
    // HELPERS
    // ═══════════════════════════════════════════════════════════════════════

    function _fundAccount() internal {
        vm.prank(funder);
        credits.fundCredits(address(token), CREDIT_AMOUNT, commitment, spendingPubKey);
    }

    function _signSpend(
        uint64 serviceId,
        uint8 jobIndex,
        uint8, /* unused */
        uint256 amount,
        uint256 nonce
    )
        internal
        view
        returns (IShieldedCredits.SpendAuth memory)
    {
        return _signSpendWithExpiry(serviceId, jobIndex, 0, amount, nonce, uint64(block.timestamp) + 3600);
    }

    function _signSpendWithExpiry(
        uint64 serviceId,
        uint8 jobIndex,
        uint8, /* unused */
        uint256 amount,
        uint256 nonce,
        uint64 expiry
    )
        internal
        view
        returns (IShieldedCredits.SpendAuth memory)
    {
        bytes32 structHash = keccak256(
            abi.encode(credits.SPEND_TYPEHASH(), commitment, serviceId, jobIndex, amount, operator1, nonce, expiry)
        );
        bytes32 digest = MessageHashUtils.toTypedDataHash(credits.DOMAIN_SEPARATOR(), structHash);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(spendingPrivKey, digest);

        return IShieldedCredits.SpendAuth({
            commitment: commitment,
            serviceId: serviceId,
            jobIndex: jobIndex,
            amount: amount,
            operator: operator1,
            nonce: nonce,
            expiry: expiry,
            signature: abi.encodePacked(r, s, v)
        });
    }

    function _signWithdraw(
        bytes32 _commitment,
        address recipient,
        uint256 amount,
        uint256 nonce
    )
        internal
        view
        returns (bytes memory)
    {
        bytes32 structHash = keccak256(abi.encode(credits.WITHDRAW_TYPEHASH(), _commitment, recipient, amount, nonce));
        bytes32 digest = MessageHashUtils.toTypedDataHash(credits.DOMAIN_SEPARATOR(), structHash);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(spendingPrivKey, digest);
        return abi.encodePacked(r, s, v);
    }
}
