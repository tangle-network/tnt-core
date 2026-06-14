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

    /// REGRESSION (was PoC #1): the genesis distribution script
    /// (DistributeTNTWithLockup) calls getOrCreateLock as the DEPLOYER on behalf of
    /// each recipient. `getOrCreateLock` is now permissionless, so the batch distributor
    /// can create a lock for a recipient even though it is NOT the beneficiary — the
    /// `msg.sender == beneficiary` DoS guard is gone. Guards against reintroducing that
    /// guard (which would make the entire genesis distribution revert).
    function test_distributionFlow_succeedsForNonBeneficiaryDistributor() public {
        token.mint(deployer, 1_000 ether);

        vm.startPrank(deployer); // == vm.startBroadcast(deployerKey) in the script
        // Reproduces DistributeTNTWithLockup.s.sol:121 exactly:
        //   factory.getOrCreateLock(token, t.to, unlockTimestamp, t.to)
        address lock = factory.getOrCreateLock(address(token), beneficiary, unlockTs, beneficiary);
        vm.stopPrank();

        // Distributor (deployer != beneficiary) successfully provisioned the lock.
        assertTrue(lock.code.length > 0, "lock not deployed by distributor");
        assertEq(TNTCliffLock(lock).beneficiary(), beneficiary, "wrong beneficiary on distributed lock");
    }

    /// REGRESSION (was PoC #2): creation no longer auto-delegates to a caller-supplied
    /// delegatee. A front-runner could call getOrCreateLock first, but the caller-chosen
    /// `delegatee` is recorded only in the event and is NEVER applied at init — so the
    /// lock's voting power stays unassigned (delegates == address(0)) until the
    /// beneficiary themselves delegates. Guards the delegation-hijack closure.
    function test_creationDoesNotAutoDelegate_onlyBeneficiaryCanDelegate() public {
        // Front-runner deploys the lock but passes its OWN address as the delegatee.
        address frontRunner = address(0xF00D);
        vm.prank(frontRunner);
        address lock = factory.getOrCreateLock(address(token), beneficiary, unlockTs, frontRunner);
        assertTrue(lock.code.length > 0, "lock not deployed");
        assertEq(TNTCliffLock(lock).beneficiary(), beneficiary);

        // No auto-delegation: the caller-supplied delegatee was NOT acted upon, so the
        // lock's voting power is still unassigned. This is the hijack-safety invariant.
        assertEq(token.delegates(lock), address(0), "creation must not auto-delegate");

        // Only the beneficiary can subsequently direct the lock's voting power.
        vm.prank(beneficiary);
        TNTCliffLock(lock).delegate(beneficiary);
        assertEq(token.delegates(lock), beneficiary, "beneficiary delegation not applied");
    }

    /// REGRESSION (was PoC #3): the implementation behind the clones is now sealed in its
    /// constructor (`initialized = true`), the _disableInitializers equivalent. Anyone
    /// trying to seize the template by calling `initialize` on it now reverts
    /// AlreadyInitialized. Clones still initialize fine (covered by the other tests) since
    /// they carry their own zeroed storage. Guards against dropping the constructor seal.
    function test_implementationIsSealedAgainstInitialization() public {
        address impl = factory.implementation();
        assertTrue(TNTCliffLock(impl).initialized(), "impl must be sealed at construction");
        vm.prank(address(0x1234));
        vm.expectRevert(TNTCliffLock.AlreadyInitialized.selector);
        TNTCliffLock(impl).initialize(address(token), address(0x1234), unlockTs, address(0x1234));
    }
}
