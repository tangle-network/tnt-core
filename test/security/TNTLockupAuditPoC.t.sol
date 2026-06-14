// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test } from "forge-std/Test.sol";
import { TNTLockFactory } from "../../src/governance/lockups/TNTLockFactory.sol";
import { TNTCliffLock } from "../../src/governance/lockups/TNTCliffLock.sol";

/// @dev Minimal ERC20 + IVotes-like token to exercise the lock's delegate path.
contract MockVotesToken {
    mapping(address => uint256) public balanceOf;
    mapping(address => address) public delegates; // account => delegatee

    function mint(address to, uint256 amount) external {
        balanceOf[to] += amount;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        return true;
    }

    // IVotes.delegate — NO auth (mirrors OZ Votes._delegate semantics: sets _delegatee[msg.sender])
    function delegate(address delegatee) external {
        delegates[msg.sender] = delegatee;
    }
}

contract TNTLockupAuditPoC is Test {
    TNTLockFactory factory;
    MockVotesToken token;

    address deployer = address(0xDEAD); // the distribution broadcaster
    address beneficiary = address(0xBEEF); // airdrop recipient
    uint64 unlockTs = uint64(1_760_000_000);

    function setUp() public {
        factory = new TNTLockFactory();
        token = new MockVotesToken();
    }

    /// PoC #1: The genesis distribution script (DistributeTNTWithLockup) calls
    /// getOrCreateLock as the DEPLOYER on behalf of each recipient. The factory's
    /// `msg.sender == beneficiary` guard rejects this, so EVERY locked transfer reverts.
    function test_distributionFlow_alwaysReverts() public {
        token.mint(deployer, 1_000 ether);

        vm.startPrank(deployer); // == vm.startBroadcast(deployerKey) in the script
        // Reproduces DistributeTNTWithLockup.s.sol:121 exactly:
        //   factory.getOrCreateLock(token, t.to, unlockTimestamp, t.to)
        vm.expectRevert(
            abi.encodeWithSelector(TNTLockFactory.NotBeneficiary.selector, deployer, beneficiary)
        );
        factory.getOrCreateLock(address(token), beneficiary, unlockTs, beneficiary);
        vm.stopPrank();
    }

    /// PoC #2: The ONLY caller that succeeds is the beneficiary itself — proving the
    /// factory is unusable by a batch distributor and only supports self-service creation.
    function test_onlyBeneficiaryCanCreate() public {
        vm.prank(beneficiary);
        address lock = factory.getOrCreateLock(address(token), beneficiary, unlockTs, beneficiary);
        assertTrue(lock.code.length > 0, "lock not deployed");
        assertEq(TNTCliffLock(lock).beneficiary(), beneficiary);
        // self-delegation wired through at init
        assertEq(token.delegates(lock), beneficiary, "delegatee not set to beneficiary");
    }

    /// PoC #3 (latent): the implementation behind the clones is never initialized
    /// and `initialize` has no access control beyond the one-shot flag — anyone can
    /// seize it. Demonstrates the missing _disableInitializers equivalent.
    function test_implementationIsInitializableByAnyone() public {
        address impl = factory.implementation();
        assertFalse(TNTCliffLock(impl).initialized(), "impl pre-initialized");
        vm.prank(address(0x1234));
        TNTCliffLock(impl).initialize(address(token), address(0x1234), unlockTs, address(0x1234));
        assertEq(TNTCliffLock(impl).beneficiary(), address(0x1234));
    }
}
