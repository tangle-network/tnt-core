// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test } from "forge-std/Test.sol";
import { ValidatorTypes } from "../../src/beacon/ValidatorTypes.sol";

/// @title PectraValidatorCapTest
/// @notice PoC for B4: ValidatorPod silently caps Pectra (0x02 / EIP-7251)
///         compounding-validator effective balance at 32 ETH on restake, even
///         though the spec allows up to 2048 ETH. Up to 2016 ETH per validator
///         vanishes from protocol accounting.
/// @dev Senior staff harden run, 2026-05-04.
///      This is a unit-level proof of the cap arithmetic. The fix is in
///      ValidatorPod._verifyAndProcessRestake (lines 269-273). We prove the
///      cap behavior here; once the fix prefix-discriminates, tests should
///      assert the larger cap for `has02Prefix` credentials.
contract PectraValidatorCapTest is Test {
    /// @notice The cap that the pod currently applies to ALL validators.
    uint64 internal constant POD_CURRENT_CAP_GWEI = ValidatorTypes.MAX_EFFECTIVE_BALANCE_GWEI; // 32 ETH

    /// @notice The Pectra max effective balance for 0x02 compounding validators (EIP-7251).
    uint64 internal constant PECTRA_MAX_EFFECTIVE_BALANCE_GWEI = 2_048_000_000_000; // 2048 ETH

    function test_PoC_PectraValidatorBalanceLostAtRestake() public pure {
        // A 0x02 (compounding) validator with 64 ETH effective balance.
        uint64 actualEffective = 64_000_000_000; // 64 ETH

        // Reproduce the exact ValidatorPod logic at src/beacon/ValidatorPod.sol:269-273
        uint64 restakedGwei = actualEffective > POD_CURRENT_CAP_GWEI
            ? POD_CURRENT_CAP_GWEI
            : actualEffective;

        assertEq(
            restakedGwei,
            POD_CURRENT_CAP_GWEI,
            "cap applied - 32 ETH credited"
        );

        uint64 lostGwei = actualEffective - restakedGwei;
        assertEq(lostGwei, 32_000_000_000, "BUG: 32 ETH silently lost on a 64 ETH compounding validator");

        // Worst case: max compounding balance = 2048 ETH
        uint64 worstCaseEffective = PECTRA_MAX_EFFECTIVE_BALANCE_GWEI;
        uint64 worstCaseRestaked = worstCaseEffective > POD_CURRENT_CAP_GWEI
            ? POD_CURRENT_CAP_GWEI
            : worstCaseEffective;
        uint64 worstCaseLost = worstCaseEffective - worstCaseRestaked;

        assertEq(
            worstCaseLost,
            2_016_000_000_000,
            "BUG: 2016 ETH unaccounted per maxed-out Pectra validator"
        );
    }

    /// @notice Document the intended post-fix behavior. Run after the fix lands
    ///         to verify both prefixes credit the correct max.
    function test_PostFix_PrefixDiscriminatedCap_DOCUMENTATION() public pure {
        // After fix:
        //   uint64 maxEffective = ValidatorTypes.has02Prefix(creds)
        //       ? PECTRA_MAX_EFFECTIVE_BALANCE_GWEI
        //       : ValidatorTypes.MAX_EFFECTIVE_BALANCE_GWEI;
        //   restakedGwei = effective > maxEffective ? maxEffective : effective;

        bytes32 creds01 = bytes32(abi.encodePacked(ValidatorTypes.WITHDRAWAL_CREDENTIALS_PREFIX_01, bytes11(0), address(0xdead)));
        bytes32 creds02 = bytes32(abi.encodePacked(ValidatorTypes.WITHDRAWAL_CREDENTIALS_PREFIX_02, bytes11(0), address(0xdead)));

        assertTrue(ValidatorTypes.has01Prefix(creds01), "0x01 detected");
        assertTrue(ValidatorTypes.has02Prefix(creds02), "0x02 detected");

        // After fix: a 0x02 validator with 1024 ETH should restake all 1024 ETH;
        // a 0x01 validator with 1024 ETH should still cap at 32 ETH.
        // (No assertion here today since the fix has not landed.)
    }
}
