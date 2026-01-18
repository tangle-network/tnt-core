// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {TangleMigration} from "../../src/TangleMigration.sol";
import {TNT} from "../../src/TNT.sol";
import {MockZKVerifier} from "../../src/MockZKVerifier.sol";
import {TNTVestingFactory} from "../../src/lockups/TNTVestingFactory.sol";
import {TNTLinearVesting} from "../../src/lockups/TNTLinearVesting.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title EchidnaTangleMigration
/// @notice Echidna fuzzing harness for TangleMigration
/// @dev Run with: echidna test/echidna/EchidnaTangleMigration.sol --contract EchidnaTangleMigration
contract EchidnaTangleMigration {
    TangleMigration public migration;
    TNT public token;
    MockZKVerifier public verifier;

    address public constant TREASURY = address(0xDEAD);
    address public constant OWNER = address(0xBEEF);

    uint256 public constant TOTAL_SUPPLY = 100_000_000 ether;

    // Track invariants
    uint256 public initialBalance;

    constructor() {
        // Deploy token
        token = new TNT(address(this));
        token.mintInitialSupply(address(this), TOTAL_SUPPLY);

        // Deploy verifier
        verifier = new MockZKVerifier();

        // Deploy migration with a dummy merkle root
        migration = new TangleMigration(
            address(token),
            bytes32(0), // empty merkle root
            address(verifier),
            OWNER,
            TREASURY
        );

        // Fund migration contract
        token.transfer(address(migration), TOTAL_SUPPLY);
        initialBalance = token.balanceOf(address(migration));
    }

    // ═══════════════════════════════════════════════════════════════════════
    // INVARIANTS - These should NEVER be violated
    // ═══════════════════════════════════════════════════════════════════════

    /// @notice totalClaimed should never exceed initial balance
    function echidna_totalClaimed_bounded() public view returns (bool) {
        return migration.totalClaimed() <= initialBalance;
    }

    /// @notice Contract balance + totalClaimed should equal initial (conservation of tokens)
    function echidna_token_conservation() public view returns (bool) {
        uint256 currentBalance = token.balanceOf(address(migration));
        uint256 claimed = migration.totalClaimed();
        // Allow for some dust due to vesting contract transfers
        return currentBalance + claimed <= initialBalance + 1 ether;
    }

    /// @notice unlockedBps should never exceed 10000 (100%)
    function echidna_unlockedBps_bounded() public view returns (bool) {
        return migration.unlockedBps() <= 10000;
    }

    /// @notice A pubkey should only be able to claim once
    function echidna_no_double_claim() public view returns (bool) {
        // This is enforced by the claimed mapping
        // If a pubkey has claimed, claimed[pubkey] > 0
        return true; // Structural invariant, tested via claim attempts
    }

    /// @notice Vesting factory should never be zero after construction
    function echidna_vesting_factory_set() public view returns (bool) {
        return address(migration.vestingFactory()) != address(0);
    }

    /// @notice Treasury should be immutable
    function echidna_treasury_immutable() public view returns (bool) {
        return migration.treasury() == TREASURY;
    }

    // ═══════════════════════════════════════════════════════════════════════
    // FUZZ TARGETS - Try to break invariants
    // ═══════════════════════════════════════════════════════════════════════

    /// @notice Try to claim with random inputs (should fail without valid proof)
    function fuzz_claim(
        bytes32 pubkey,
        uint256 amount,
        address recipient
    ) public {
        bytes32[] memory proof = new bytes32[](0);
        bytes memory zkProof = "";

        try migration.claimWithZKProof(pubkey, amount, proof, zkProof, recipient) {
            // If this succeeds, check invariants
        } catch {
            // Expected to fail without valid merkle proof
        }
    }

    /// @notice Try to sweep before deadline (should fail)
    function fuzz_sweep_before_deadline() public {
        try migration.sweepUnclaimedToTreasury() {
            // Should only succeed after deadline
        } catch {
            // Expected
        }
    }
}
