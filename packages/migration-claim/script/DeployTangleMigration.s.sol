// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {TNT} from "../src/TNT.sol";
import {TangleMigration} from "../src/TangleMigration.sol";
import {SP1ZKVerifier} from "../src/SP1ZKVerifier.sol";
import {MockZKVerifier} from "../src/MockZKVerifier.sol";
import {TNTVestingFactory} from "../src/lockups/TNTVestingFactory.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @title DeployTangleMigration
 * @notice Full deployment script for the TNT migration system
 *
 * Environment Variables (Required):
 *   MERKLE_ROOT          - Merkle root from migration snapshot
 *   TOTAL_SUBSTRATE      - Exact total for Substrate claims (from distribution.json)
 *   TOTAL_EVM            - Exact total for EVM airdrop (from distribution.json)
 *
 * Environment Variables (Optional):
 *   PRIVATE_KEY          - Deployer private key (default: Anvil account 0)
 *   TNT_TOKEN            - Existing TNT token address to reuse (recommended)
 *   ALLOW_STANDALONE_TOKEN - Set to "true" to deploy a test-only TNT token when TNT_TOKEN is not provided
 *   SP1_VERIFIER         - SP1 Verifier Gateway address (default: Base gateway)
 *   PROGRAM_VKEY         - SP1 program verification key
 *   USE_MOCK_VERIFIER    - Set to "true" for testing without real ZK proofs
 *
 * Usage:
 *   # Use the deploy-migration.sh wrapper script which reads from distribution.json:
 *   ./scripts/local-env/deploy-migration.sh
 *
 *   # Or manually with exact values:
 *   MERKLE_ROOT=0x824b... \
 *   TOTAL_SUBSTRATE=108138164691043996671207028 \
 *   TOTAL_EVM=1125776519168932493729792 \
 *   USE_MOCK_VERIFIER=true \
 *   forge script script/DeployTangleMigration.s.sol:DeployTangleMigration \
 *     --rpc-url http://localhost:8545 --broadcast
 */
contract DeployTangleMigration is Script {
    using SafeERC20 for IERC20;

    // SP1 Verifier Gateway on Base
    address constant SP1_VERIFIER_BASE = 0x397A5f7f3dBd538f23DE225B51f532c34448dA9B;

    function run() external {
        // Load configuration
        uint256 deployerPrivateKey = vm.envOr(
            "PRIVATE_KEY",
            uint256(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80)
        );
        address deployer = vm.addr(deployerPrivateKey);
        address migrationOwner = _envAddressOrZero("MIGRATION_OWNER");
        if (migrationOwner == address(0)) {
            migrationOwner = deployer;
        }

        // Required: Read from distribution.json via wrapper script
        bytes32 merkleRoot = vm.envBytes32("MERKLE_ROOT");
        require(merkleRoot != bytes32(0), "MERKLE_ROOT required - use deploy-migration.sh wrapper");

        uint256 substrateAllocation = vm.envUint("TOTAL_SUBSTRATE");
        require(substrateAllocation > 0, "TOTAL_SUBSTRATE required - use deploy-migration.sh wrapper");

        uint256 evmAllocation = vm.envUint("TOTAL_EVM");
        require(evmAllocation > 0, "TOTAL_EVM required - use deploy-migration.sh wrapper");

        address treasuryRecipient = _envAddressOrZero("TREASURY_RECIPIENT");
        uint256 treasuryAmount = vm.envOr("TREASURY_AMOUNT", uint256(0));
        address foundationRecipient = _envAddressOrZero("FOUNDATION_RECIPIENT");
        uint256 foundationAmount = vm.envOr("FOUNDATION_AMOUNT", uint256(0));

        uint256 totalSupply = substrateAllocation + evmAllocation + treasuryAmount + foundationAmount;

        bool useMockVerifier = vm.envOr("USE_MOCK_VERIFIER", false);
        address sp1VerifierAddr = vm.envOr("SP1_VERIFIER", SP1_VERIFIER_BASE);
        bytes32 programVKey = vm.envOr("PROGRAM_VKEY", bytes32(0));

        console.log("=== Tangle Migration Deployment ===");
        console.log("Deployer:", deployer);
        console.log("Migration Owner:", migrationOwner);
        console.log("Merkle Root:", vm.toString(merkleRoot));
        console.log("Substrate Allocation (wei):", substrateAllocation);
        console.log("Substrate Allocation (TNT):", substrateAllocation / 1e18);
        console.log("EVM Allocation (wei):", evmAllocation);
        console.log("EVM Allocation (TNT):", evmAllocation / 1e18);
        if (treasuryAmount > 0) {
            console.log("Treasury Allocation (wei):", treasuryAmount);
            console.log("Treasury Allocation (TNT):", treasuryAmount / 1e18);
            console.log("Treasury Recipient:", treasuryRecipient);
        }
        if (foundationAmount > 0) {
            console.log("Foundation Allocation (wei):", foundationAmount);
            console.log("Foundation Allocation (TNT):", foundationAmount / 1e18);
            console.log("Foundation Recipient:", foundationRecipient);
        }
        console.log("Total Supply (TNT):", totalSupply / 1e18);
        console.log("Use Mock Verifier:", useMockVerifier);

        vm.startBroadcast(deployerPrivateKey);

        bool allowStandaloneToken = vm.envOr("ALLOW_STANDALONE_TOKEN", false);
        address configuredTnt = _envAddressOrZero("TNT_TOKEN");
        if (configuredTnt == address(0)) {
            configuredTnt = _envAddressOrZero("TNT_TOKEN_ADDRESS");
        }

        IERC20 tntToken;
        if (configuredTnt == address(0)) {
            require(
                allowStandaloneToken,
                "Missing TNT token address. Set TNT_TOKEN (preferred) or set ALLOW_STANDALONE_TOKEN=true to deploy a test-only token."
            );
            TNT fresh = new TNT(deployer);
            configuredTnt = address(fresh);
            console.log("\n1. TNT Token deployed:", configuredTnt);
            fresh.mintInitialSupply(deployer, totalSupply);
            console.log("   Minted:", totalSupply / 1e18, "TNT to deployer");
            tntToken = IERC20(configuredTnt);
        } else {
            console.log("\n1. Using existing TNT token:", configuredTnt);
            tntToken = IERC20(configuredTnt);
            uint256 balance = tntToken.balanceOf(deployer);
            uint256 requiredBalance = totalSupply;
            require(balance >= requiredBalance, "Existing TNT balance insufficient for migration allocations");
            console.log("   Existing TNT balance (TNT):", balance / 1e18);
        }

        // 3. Deploy ZK Verifier
        address zkVerifier;
        if (useMockVerifier) {
            MockZKVerifier mock = new MockZKVerifier();
            zkVerifier = address(mock);
            console.log("\n2. MockZKVerifier deployed:", zkVerifier);
            console.log("   WARNING: Using mock verifier - NOT FOR PRODUCTION");
        } else {
            require(programVKey != bytes32(0), "PROGRAM_VKEY required for SP1 verifier");
            SP1ZKVerifier sp1 = new SP1ZKVerifier(sp1VerifierAddr, programVKey);
            zkVerifier = address(sp1);
            console.log("\n2. SP1ZKVerifier deployed:", zkVerifier);
            console.log("   SP1 Gateway:", sp1VerifierAddr);
            console.log("   Program VKey:", vm.toString(programVKey));
        }

        // 4. Deploy TangleMigration
        // Treasury for unclaimed token sweep - defaults to treasury recipient, falls back to owner
        address sweepTreasury = treasuryRecipient != address(0) ? treasuryRecipient : migrationOwner;
        TangleMigration migration = new TangleMigration(
            configuredTnt,
            merkleRoot,
            zkVerifier,
            migrationOwner,
            sweepTreasury
        );
        console.log("\n3. TangleMigration deployed:", address(migration));
        console.log("   Unclaimed sweep treasury:", sweepTreasury);

        // 5. Fund the migration contract with EXACT Substrate allocation
        require(tntToken.transfer(address(migration), substrateAllocation), "Funding transfer failed");
        console.log("   Funded with:", substrateAllocation / 1e18, "TNT for Substrate claims");

        // 6. Set claim deadline (1 year from now)
        uint256 deadline = block.timestamp + 365 days;
        migration.setClaimDeadline(deadline);
        console.log("   Claim deadline:", deadline);

        // 7. EVM allocation remains in deployer for transfer-based airdrop
        console.log("\n4. EVM Airdrop:");
        console.log("   Remaining in deployer:", evmAllocation / 1e18, "TNT");
        console.log("   Run ExecuteEVMAirdrop to distribute to", "EVM holders");

        // 8. Optional: Treasury allocation (0% unlocked, 100% vested with 12-month cliff + 24-month linear)
        if (treasuryAmount > 0) {
            require(treasuryRecipient != address(0), "TREASURY_RECIPIENT required when TREASURY_AMOUNT > 0");

            // Treasury: 0% unlocked, 100% goes to vesting contract
            // 12-month cliff + 24-month linear = 3 years total
            TNTVestingFactory treasuryVestingFactory = new TNTVestingFactory(365 days, 730 days);
            // forge-lint: disable-next-line(unsafe-typecast)
            address treasuryVesting = treasuryVestingFactory.getOrCreateVesting(
                configuredTnt,
                treasuryRecipient,
                uint64(block.timestamp),
                treasuryRecipient // delegatee
            );
            require(tntToken.transfer(treasuryVesting, treasuryAmount), "Treasury vesting transfer failed");

            console.log("\n5. Treasury Allocation (0% unlocked, 100% vested):");
            console.log("   Total:", treasuryAmount / 1e18, "TNT");
            console.log("   Vesting contract:", treasuryVesting);
            console.log("   Beneficiary:", treasuryRecipient);
            console.log("   Cliff: 12 months, Linear: 24 months (3 years total)");
        }

        // 9. Optional: Foundation allocation (1% unlocked, 99% vested with 12-month cliff + 24-month linear)
        if (foundationAmount > 0) {
            require(foundationRecipient != address(0), "FOUNDATION_RECIPIENT required when FOUNDATION_AMOUNT > 0");

            // Foundation: 1% unlocked immediately, 99% vested
            uint256 foundationUnlocked = (foundationAmount * 100) / 10_000; // 1%
            uint256 foundationVested = foundationAmount - foundationUnlocked;

            // Transfer unlocked portion directly
            require(tntToken.transfer(foundationRecipient, foundationUnlocked), "Foundation unlocked transfer failed");

            // Create vesting for the rest (12-month cliff + 24-month linear = 3 years)
            TNTVestingFactory foundationVestingFactory = new TNTVestingFactory(365 days, 730 days);
            // forge-lint: disable-next-line(unsafe-typecast)
            address foundationVesting = foundationVestingFactory.getOrCreateVesting(
                configuredTnt,
                foundationRecipient,
                uint64(block.timestamp),
                foundationRecipient // delegatee
            );
            require(tntToken.transfer(foundationVesting, foundationVested), "Foundation vesting transfer failed");

            console.log("\n6. Foundation Allocation (1% unlocked, 99% vested):");
            console.log("   Total:", foundationAmount / 1e18, "TNT");
            console.log("   Unlocked (1%):", foundationUnlocked / 1e18, "TNT to", foundationRecipient);
            console.log("   Vested (99%):", foundationVested / 1e18, "TNT");
            console.log("   Vesting contract:", foundationVesting);
            console.log("   Cliff: 12 months, Linear: 24 months (3 years total)");
        }

        vm.stopBroadcast();

        // Output summary
        console.log("\n=== Deployment Complete ===");
        console.log("TNT Token:", configuredTnt);
        console.log("TangleMigration:", address(migration));
        console.log("ZK Verifier:", zkVerifier);
        console.log("");
        console.log("Environment Variables for Frontend:");
        console.log("  VITE_TNT_TOKEN_ADDRESS=", configuredTnt);
        console.log("  VITE_TANGLE_MIGRATION_ADDRESS=", address(migration));
        console.log("  VITE_ZK_VERIFIER_ADDRESS=", zkVerifier);
        console.log("");
        console.log("Next: Run ExecuteEVMAirdrop to distribute EVM tokens");

        // Optional: write a machine-readable manifest for the dApp / ops tooling.
        // Controlled by env var to avoid writing files unexpectedly.
        string memory manifestPath = vm.envOr("MIGRATION_MANIFEST_PATH", string(""));
        if (bytes(manifestPath).length != 0) {
            string memory verifierType = useMockVerifier ? "mock" : "sp1";
            string memory json = string(
                abi.encodePacked(
                    "{",
                    "\"chainId\":",
                    vm.toString(block.chainid),
                    ",",
                    "\"deployer\":\"",
                    vm.toString(deployer),
                    "\",",
                    "\"tntToken\":\"",
                    vm.toString(configuredTnt),
                    "\",",
                    "\"tangleMigration\":\"",
                    vm.toString(address(migration)),
                    "\",",
                    "\"zkVerifier\":\"",
                    vm.toString(zkVerifier),
                    "\",",
                    "\"verifierType\":\"",
                    verifierType,
                    "\",",
                    "\"merkleRoot\":\"",
                    vm.toString(merkleRoot),
                    "\",",
                    "\"programVKey\":\"",
                    vm.toString(programVKey),
                    "\",",
                    "\"sp1VerifierGateway\":\"",
                    vm.toString(sp1VerifierAddr),
                    "\",",
                    "\"unlockedBps\":",
                    vm.toString(uint256(migration.unlockedBps())),
                    ",",
                    "\"cliffDuration\":",
                    vm.toString(uint256(migration.cliffDuration())),
                    ",",
                    "\"vestingDuration\":",
                    vm.toString(uint256(migration.vestingDuration())),
                    ",",
                    "\"vestingFactory\":\"",
                    vm.toString(address(migration.vestingFactory())),
                    "\",",
                    "\"adminClaimDeadline\":",
                    vm.toString(uint256(migration.adminClaimDeadline())),
                    ",",
                    "\"claimDeadline\":",
                    vm.toString(migration.claimDeadline()),
                    ",",
                    "\"treasury\":\"",
                    vm.toString(migration.treasury()),
                    "\"}"
                )
            );
            vm.writeJson(json, manifestPath);
            console.log("Wrote migration manifest:", manifestPath);
        }
    }

    function _envAddressOrZero(string memory key) internal view returns (address) {
        if (bytes(key).length == 0) {
            return address(0);
        }
        try vm.envAddress(key) returns (address value) {
            return value;
        } catch {
            return address(0);
        }
    }
}

/**
 * @title ExecuteEVMAirdrop
 * @notice Executes the EVM airdrop via direct ERC20 transfers
 *
 * This script reads arrays of addresses and amounts and calls ERC20.transfer().
 * The arrays should be generated from evm-airdrop.json by an external wrapper/tool.
 *
 * Environment Variables:
 *   TNT_ADDRESS          - TNT token address
 *   PRIVATE_KEY          - Deployer private key (must hold sufficient TNT balance)
 *
 * Usage:
 *   # Use an external wrapper which parses JSON and calls runBatch() in chunks.
 */
contract ExecuteEVMAirdrop is Script {
    using SafeERC20 for IERC20;

    function run() external {
        uint256 deployerPrivateKey = vm.envOr(
            "PRIVATE_KEY",
            uint256(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80)
        );
        address tntAddress = vm.envAddress("TNT_ADDRESS");

        console.log("=== EVM Airdrop Execution ===");
        console.log("TNT Token:", tntAddress);

        vm.startBroadcast(deployerPrivateKey);

        console.log("\nUse runBatch(tntAddress, recipients[], amounts[]) for a batched transfer-based airdrop.");
        console.log("NOTE: Deployer must already hold the TNT being distributed (no minting performed).");

        vm.stopBroadcast();
    }

    /// @notice Execute airdrop with pre-parsed arrays (called by wrapper)
    function runBatch(
        address tntAddress,
        address[] calldata recipients,
        uint256[] calldata amounts
    ) external {
        uint256 deployerPrivateKey = vm.envOr(
            "PRIVATE_KEY",
            uint256(0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80)
        );

        console.log("=== EVM Airdrop Batch ===");
        console.log("TNT Token:", tntAddress);
        console.log("Recipients:", recipients.length);

        IERC20 tnt = IERC20(tntAddress);

        vm.startBroadcast(deployerPrivateKey);
        require(recipients.length == amounts.length, "Length mismatch");
        for (uint256 i = 0; i < recipients.length; i++) {
            if (recipients[i] == address(0) || amounts[i] == 0) continue;
            tnt.safeTransfer(recipients[i], amounts[i]);
        }
        vm.stopBroadcast();

        console.log("Airdrop complete!");
    }
}
