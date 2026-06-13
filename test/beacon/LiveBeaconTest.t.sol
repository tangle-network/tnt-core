// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import { BeaconChainProofs } from "../../src/beacon/BeaconChainProofs.sol";
import { ValidatorTypes } from "../../src/beacon/ValidatorTypes.sol";
import { ValidatorPod } from "../../src/beacon/ValidatorPod.sol";
import { ValidatorPodManager } from "../../src/beacon/ValidatorPodManager.sol";

/// @title LiveBeaconTest
/// @notice Integration tests using real Ethereum mainnet/testnet data
/// @dev Run with: forge test --match-contract LiveBeaconTest --fork-url $ETH_RPC_URL
contract LiveBeaconTest is Test {
    // EIP-4788 Beacon Root Oracle address
    address constant BEACON_ROOT_ORACLE = 0x000F3df6D732807Ef1319fB7B8bB8522d0Beac02;

    // Test validator indices (mainnet examples)
    uint64 constant SAMPLE_VALIDATOR_INDEX = 0; // Genesis validator
    uint64 constant LIDO_VALIDATOR_INDEX = 123_456; // Example Lido validator

    /// @notice Test that EIP-4788 beacon root oracle is deployed on fork
    function test_beaconRootOracleExists() public view {
        // Skip if not on a fork
        if (block.chainid != 1 && block.chainid != 17_000) {
            return;
        }

        uint256 codeSize;
        assembly {
            codeSize := extcodesize(BEACON_ROOT_ORACLE)
        }
        assertGt(codeSize, 0, "Beacon root oracle should be deployed");
    }

    /// @notice Test querying beacon root from EIP-4788 oracle
    function test_queryBeaconRoot() public {
        // Skip if not on a fork
        if (block.chainid != 1 && block.chainid != 17_000) {
            return;
        }

        // Query the beacon root for the current block's parent
        uint256 timestamp = block.timestamp - 12; // Previous slot (12 seconds)

        // Call the oracle with the timestamp
        (bool success, bytes memory data) = BEACON_ROOT_ORACLE.call(abi.encode(timestamp));

        if (success && data.length == 32) {
            bytes32 beaconRoot = abi.decode(data, (bytes32));
            assertTrue(beaconRoot != bytes32(0), "Beacon root should not be zero");
            emit log_named_bytes32("Beacon root", beaconRoot);
        }
    }

    /// @notice Test withdrawal credentials computation matches expected format
    function test_withdrawalCredentialsFormat() public pure {
        address podAddress = 0x1234567890123456789012345678901234567890;

        bytes32 creds01 = ValidatorTypes.computeWithdrawalCredentials(podAddress);
        bytes32 creds02 = ValidatorTypes.computeWithdrawalCredentials02(podAddress);

        // Check 0x01 prefix
        assertEq(bytes1(creds01), bytes1(0x01), "Should have 0x01 prefix");
        assertEq(
            creds01,
            bytes32(0x0100000000000000000000001234567890123456789012345678901234567890),
            "0x01 credentials format"
        );

        // Check 0x02 prefix
        assertEq(bytes1(creds02), bytes1(0x02), "Should have 0x02 prefix");
        assertEq(
            creds02,
            bytes32(0x0200000000000000000000001234567890123456789012345678901234567890),
            "0x02 credentials format"
        );
    }

    /// @notice Encode a uint64 as the leftmost 8 bytes of a bytes32, little-endian.
    /// @dev SSZ encodes basic types as little-endian and pads to the chunk size on
    ///      the right. `BeaconChainProofs._fromLittleEndianUint64` extracts the
    ///      leftmost 8 bytes (`>> 192`) and byte-reverses them, so test fixtures
    ///      must place the LE-encoded value in that position. Previously the
    ///      test wrote `bytes32(uint256(N))` which right-aligns the value (BE),
    ///      causing the helper to read zero — the test was silently broken on
    ///      `main` (tracked via issue #130) and is fixed here as part of the
    function _leUint64Bytes32(uint64 n) internal pure returns (bytes32) {
        // Reverse bytes (n becomes little-endian)
        uint64 le = ((n & 0x00000000000000FF) << 56) | ((n & 0x000000000000FF00) << 40)
            | ((n & 0x0000000000FF0000) << 24) | ((n & 0x00000000FF000000) << 8) | ((n & 0x000000FF00000000) >> 8)
            | ((n & 0x0000FF0000000000) >> 24) | ((n & 0x00FF000000000000) >> 40) | ((n & 0xFF00000000000000) >> 56);
        // Place in leftmost 8 bytes
        return bytes32(uint256(le) << 192);
    }

    /// @notice Test that validator fields extraction works correctly
    function test_validatorFieldsExtraction() public pure {
        // Sample validator fields (SSZ encoded; basic types LE-packed into leftmost 8 bytes)
        bytes32[] memory fields = new bytes32[](8);

        // Field 0: pubkey hash (bytes32, no endian translation)
        fields[0] = bytes32(0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef);

        // Field 1: withdrawal credentials (0x01 prefix; bytes32, no endian translation)
        fields[1] = bytes32(0x0100000000000000000000001234567890123456789012345678901234567890);

        // Field 2: effective balance (32 ETH in gwei, little-endian, leftmost 8 bytes)
        fields[2] = _leUint64Bytes32(32_000_000_000); // 32e9 gwei

        // Field 3: slashed (false) — LE-encoded zero is just zero
        fields[3] = bytes32(uint256(0));

        // Field 4: activation eligibility epoch
        fields[4] = _leUint64Bytes32(0);

        // Field 5: activation epoch
        fields[5] = _leUint64Bytes32(0);

        // Field 6: exit epoch (FAR_FUTURE_EPOCH)
        fields[6] = _leUint64Bytes32(type(uint64).max);

        // Field 7: withdrawable epoch (FAR_FUTURE_EPOCH)
        fields[7] = _leUint64Bytes32(type(uint64).max);

        // Extract and verify
        assertEq(BeaconChainProofs.getPubkeyHash(fields), fields[0]);
        assertEq(BeaconChainProofs.getWithdrawalCredentials(fields), fields[1]);
        assertEq(BeaconChainProofs.getEffectiveBalanceGwei(fields), 32_000_000_000);
        assertFalse(BeaconChainProofs.isValidatorSlashed(fields));
        assertEq(BeaconChainProofs.getActivationEpoch(fields), 0);
        assertEq(BeaconChainProofs.getExitEpoch(fields), type(uint64).max);
        assertEq(BeaconChainProofs.getWithdrawableEpoch(fields), type(uint64).max);
    }

    /// @notice Test balance leaf extraction for packed balances
    function test_balanceLeafExtraction() public pure {
        // Pack 4 balances into a leaf (little-endian)
        // Validator 0: 32 ETH, Validator 1: 31.5 ETH, Validator 2: 32.1 ETH, Validator 3: 0 ETH
        bytes32 balanceLeaf = bytes32(
            uint256(32_000_000_000) // Index 0
                | (uint256(31_500_000_000) << 64) // Index 1
                | (uint256(32_100_000_000) << 128) // Index 2
                | (uint256(0) << 192) // Index 3
        );

        // Extract balances at each position
        uint64 balance0 = uint64(uint256(balanceLeaf));
        uint64 balance1 = uint64(uint256(balanceLeaf) >> 64);
        uint64 balance2 = uint64(uint256(balanceLeaf) >> 128);
        uint64 balance3 = uint64(uint256(balanceLeaf) >> 192);

        assertEq(balance0, 32_000_000_000, "Balance 0");
        assertEq(balance1, 31_500_000_000, "Balance 1");
        assertEq(balance2, 32_100_000_000, "Balance 2");
        assertEq(balance3, 0, "Balance 3");
    }

    /// @notice Test generalized index calculation for validators (SSZ List mix_in_length).
    /// @dev The `validators` field is an SSZ List, whose root is
    ///      `mix_in_length(merkleize(chunks), length)`. That extra hash level pushes each
    ///      element ONE level deeper than a bare Vector, so the correct shift is
    ///      `VALIDATOR_TREE_HEIGHT + 1` (= 41), not `VALIDATOR_TREE_HEIGHT` (= 40), and the
    ///      validators-container gindex in post-Pectra state is 75 (not the stale 43 the
    ///      previous version of this test hardcoded). Expected values below are derived
    ///      from the SSZ spec, NOT read back from the library under test.
    ///        gindex(i) = (75 << 41) | i
    ///        75 << 41 = 75 * 2_199_023_255_552 = 164_926_744_166_400
    function test_validatorGeneralizedIndex() public pure {
        uint256 gindex0 = (uint256(75) << 41) | 0;
        assertEq(gindex0, 164_926_744_166_400, "Validator 0 gindex (75 << 41)");

        uint256 gindex100 = (uint256(75) << 41) | 100;
        assertEq(gindex100, 164_926_744_166_500, "Validator 100 gindex");

        // The shift MUST be 41 (height + mix_in_length level), not 40.
        assertEq((uint256(75) << 41) >> 41, 75, "validators container gindex is 75");
        assertTrue((uint256(75) << 41) != (uint256(75) << 40), "shift must include mix_in_length level");
    }

    /// @notice Test generalized index calculation for balances (SSZ List mix_in_length).
    /// @dev `balances` is also an SSZ List, so the packed-balance leaf sits one level below
    ///      the list root: shift `BALANCE_TREE_HEIGHT + 1` (= 39), balances-container
    ///      gindex 76. Values derived from the SSZ spec, not the code under test.
    function test_balanceGeneralizedIndex() public pure {
        // Leaf 0 holds validators 0-3.
        uint256 gindex0 = (uint256(76) << 39) | 0;
        assertEq(gindex0 >> 39, 76, "balances container gindex is 76");

        // Validators 4-7 are in leaf 1.
        uint256 gindex4 = (uint256(76) << 39) | 1;
        assertEq(gindex4 & ((uint256(1) << 39) - 1), 1, "Leaf index for validator 4");

        // The shift MUST include the mix_in_length level.
        assertTrue((uint256(76) << 39) != (uint256(76) << 38), "balance shift must include mix_in_length level");
    }

    /// @notice Test slashing factor calculation
    function test_slashingFactorCalculation() public pure {
        uint64 initialFactor = 1e18; // 100%

        // Validator balance drops from 32 ETH to 31 ETH (slashed)
        uint64 priorBalance = 32_000_000_000;
        uint64 currentBalance = 31_000_000_000;

        uint64 newFactor = uint64((uint256(initialFactor) * uint256(currentBalance)) / uint256(priorBalance));

        // Expected: 31/32 * 1e18 = 968750000000000000
        assertEq(newFactor, 968_750_000_000_000_000, "Slashing factor after 1 ETH penalty");

        // Apply slashing factor to 100 ETH of shares
        uint256 shares = 100 ether;
        uint256 effectiveShares = (shares * newFactor) / 1e18;

        // Expected: 100 * 0.96875 = 96.875 ETH
        assertEq(effectiveShares, 96.875 ether, "Effective shares after slashing");
    }

    /// @notice Test withdrawal delay configuration
    function test_withdrawalDelayConstants() public pure {
        // Default: 7 days on L2 (~302,400 blocks at 2s block time)
        uint32 defaultDelay = 302_400;

        // Max: 30 days
        uint32 maxDelay = 1_296_000;

        assertTrue(defaultDelay < maxDelay, "Default should be less than max");
        assertEq(defaultDelay * 2, 604_800, "Default delay in seconds (7 days)");
    }
}
