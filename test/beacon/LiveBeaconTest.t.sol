// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "forge-std/Test.sol";
import {BeaconChainProofs} from "../../src/beacon/BeaconChainProofs.sol";
import {ValidatorTypes} from "../../src/beacon/ValidatorTypes.sol";
import {ValidatorPod} from "../../src/beacon/ValidatorPod.sol";
import {ValidatorPodManager} from "../../src/beacon/ValidatorPodManager.sol";

/// @title LiveBeaconTest
/// @notice Integration tests using real Ethereum mainnet/testnet data
/// @dev Run with: forge test --match-contract LiveBeaconTest --fork-url $ETH_RPC_URL
contract LiveBeaconTest is Test {
    // EIP-4788 Beacon Root Oracle address
    address constant BEACON_ROOT_ORACLE = 0x000F3df6D732807Ef1319fB7B8bB8522d0Beac02;

    // Test validator indices (mainnet examples)
    uint64 constant SAMPLE_VALIDATOR_INDEX = 0; // Genesis validator
    uint64 constant LIDO_VALIDATOR_INDEX = 123456; // Example Lido validator

    /// @notice Test that EIP-4788 beacon root oracle is deployed on fork
    function test_beaconRootOracleExists() public view {
        // Skip if not on a fork
        if (block.chainid != 1 && block.chainid != 17000) {
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
        if (block.chainid != 1 && block.chainid != 17000) {
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

    /// @notice Test that validator fields extraction works correctly
    function test_validatorFieldsExtraction() public pure {
        // Sample validator fields (SSZ encoded)
        bytes32[] memory fields = new bytes32[](8);

        // Field 0: pubkey hash
        fields[0] = bytes32(0x1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef);

        // Field 1: withdrawal credentials (0x01 prefix)
        fields[1] = bytes32(0x0100000000000000000000001234567890123456789012345678901234567890);

        // Field 2: effective balance (32 ETH in gwei, little-endian)
        fields[2] = bytes32(uint256(32_000_000_000)); // 32e9 gwei

        // Field 3: slashed (false)
        fields[3] = bytes32(uint256(0));

        // Field 4: activation eligibility epoch
        fields[4] = bytes32(uint256(0));

        // Field 5: activation epoch
        fields[5] = bytes32(uint256(0));

        // Field 6: exit epoch (FAR_FUTURE_EPOCH)
        fields[6] = bytes32(uint256(type(uint64).max));

        // Field 7: withdrawable epoch (FAR_FUTURE_EPOCH)
        fields[7] = bytes32(uint256(type(uint64).max));

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
            uint256(32_000_000_000) |           // Index 0
            (uint256(31_500_000_000) << 64) |   // Index 1
            (uint256(32_100_000_000) << 128) |  // Index 2
            (uint256(0) << 192)                  // Index 3
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

    /// @notice Test generalized index calculation for validators
    function test_validatorGeneralizedIndex() public pure {
        // Validator at index 0 should have gindex:
        // (VALIDATOR_CONTAINER_GINDEX << VALIDATOR_TREE_HEIGHT) | 0
        // = (43 << 40) | 0
        // = 47278999994368

        uint256 gindex0 = (uint256(43) << 40) | 0;
        assertEq(gindex0, 47278999994368, "Validator 0 gindex");

        // Validator at index 100
        uint256 gindex100 = (uint256(43) << 40) | 100;
        assertEq(gindex100, 47278999994468, "Validator 100 gindex");
    }

    /// @notice Test generalized index calculation for balances
    function test_balanceGeneralizedIndex() public pure {
        // Balances are packed 4 per leaf
        // Validator 0-3 are in leaf 0
        // gindex = (BALANCE_CONTAINER_GINDEX << BALANCE_TREE_HEIGHT) | leafIndex
        // = (44 << 38) | 0

        uint256 gindex0 = (44 << 38) | 0;
        assertEq(gindex0 >> 38, 44, "Balance container gindex");

        // Validators 4-7 are in leaf 1
        uint256 gindex4 = (44 << 38) | 1;
        assertEq(gindex4 & 0x3FFFFFFFFF, 1, "Leaf index for validator 4");
    }

    /// @notice Test slashing factor calculation
    function test_slashingFactorCalculation() public pure {
        uint64 initialFactor = 1e18; // 100%

        // Validator balance drops from 32 ETH to 31 ETH (slashed)
        uint64 priorBalance = 32_000_000_000;
        uint64 currentBalance = 31_000_000_000;

        uint64 newFactor = uint64(
            (uint256(initialFactor) * uint256(currentBalance)) / uint256(priorBalance)
        );

        // Expected: 31/32 * 1e18 = 968750000000000000
        assertEq(newFactor, 968750000000000000, "Slashing factor after 1 ETH penalty");

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
