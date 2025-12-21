// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test } from "forge-std/Test.sol";
import { Credits } from "../src/Credits.sol";

contract CreditsTest is Test {
    Credits credits;

    address owner = address(0xA11CE);
    address alice = address(0xA71CE);
    address bob = address(0xB0B);

    uint256 epochId = 1;
    uint256 aliceAmount = 100 ether;
    uint256 bobAmount = 50 ether;

    function setUp() public {
        credits = new Credits(owner);
    }

    function _leaf(uint256 e, address account, uint256 amount) internal pure returns (bytes32) {
        return keccak256(bytes.concat(keccak256(abi.encode(e, account, amount))));
    }

    function _hashPair(bytes32 a, bytes32 b) internal pure returns (bytes32) {
        return a < b ? keccak256(bytes.concat(a, b)) : keccak256(bytes.concat(b, a));
    }

    function test_SetMerkleRoot_OnlyOwner() public {
        bytes32 root = bytes32(uint256(123));
        vm.prank(owner);
        credits.setMerkleRoot(epochId, root);
        assertEq(credits.merkleRoots(epochId), root);

        vm.expectRevert();
        credits.setMerkleRoot(epochId + 1, root);
    }

    function test_Claim_SingleLeaf() public {
        bytes32 leaf = _leaf(epochId, alice, aliceAmount);
        vm.prank(owner);
        credits.setMerkleRoot(epochId, leaf);

        bytes32[] memory proof = new bytes32[](0);
        vm.prank(alice);
        vm.expectEmit(true, false, false, true, address(credits));
        emit Credits.CreditsClaimed(alice, aliceAmount, bytes32("acct"));
        credits.claim(epochId, aliceAmount, bytes32("acct"), proof);

        assertTrue(credits.claimed(epochId, alice));
    }

    function test_Claim_TwoLeafTree() public {
        bytes32 leafAlice = _leaf(epochId, alice, aliceAmount);
        bytes32 leafBob = _leaf(epochId, bob, bobAmount);
        bytes32 root = _hashPair(leafAlice, leafBob);
        vm.prank(owner);
        credits.setMerkleRoot(epochId, root);

        // Alice proof is just Bob leaf
        bytes32[] memory proofAlice = new bytes32[](1);
        proofAlice[0] = leafBob;
        vm.prank(alice);
        credits.claim(epochId, aliceAmount, bytes32("alice"), proofAlice);

        // Bob proof is just Alice leaf
        bytes32[] memory proofBob = new bytes32[](1);
        proofBob[0] = leafAlice;
        vm.prank(bob);
        credits.claim(epochId, bobAmount, bytes32("bob"), proofBob);

        assertTrue(credits.claimed(epochId, alice));
        assertTrue(credits.claimed(epochId, bob));
    }

    function test_Claim_RevertIfAlreadyClaimed() public {
        bytes32 leaf = _leaf(epochId, alice, aliceAmount);
        vm.prank(owner);
        credits.setMerkleRoot(epochId, leaf);

        bytes32[] memory proof = new bytes32[](0);
        vm.prank(alice);
        credits.claim(epochId, aliceAmount, bytes32("acct"), proof);

        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(Credits.AlreadyClaimed.selector, epochId, alice));
        credits.claim(epochId, aliceAmount, bytes32("acct"), proof);
    }

    function test_Claim_RevertIfInvalidProof() public {
        bytes32 leaf = _leaf(epochId, alice, aliceAmount);
        vm.prank(owner);
        credits.setMerkleRoot(epochId, leaf);

        bytes32[] memory badProof = new bytes32[](1);
        badProof[0] = bytes32(uint256(456));
        vm.prank(alice);
        vm.expectRevert(Credits.InvalidMerkleProof.selector);
        credits.claim(epochId, aliceAmount, bytes32("acct"), badProof);
    }

    function test_Verify() public {
        bytes32 leaf = _leaf(epochId, alice, aliceAmount);
        vm.prank(owner);
        credits.setMerkleRoot(epochId, leaf);

        bytes32[] memory proof = new bytes32[](0);
        assertTrue(credits.verify(epochId, alice, aliceAmount, proof));
        assertFalse(credits.verify(epochId, alice, aliceAmount + 1, proof));
    }
}

