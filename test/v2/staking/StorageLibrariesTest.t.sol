// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import {DelegationErrors} from "../../../src/v2/staking/DelegationErrors.sol";
import {DepositManager} from "../../../src/v2/staking/DepositManager.sol";
import {RewardVaults} from "../../../src/v2/rewards/RewardVaults.sol";
import {SlashingManager} from "../../../src/v2/staking/SlashingManager.sol";
import {MultiAssetDelegation} from "../../../src/v2/staking/MultiAssetDelegation.sol";
import {DelegationTestHarness} from "./DelegationTestHarness.sol";
import {Types} from "../../../src/v2/libraries/Types.sol";

contract DelegationStorageHarness is DepositManager {
    using EnumerableSet for EnumerableSet.AddressSet;

    function lockDuration(Types.LockMultiplier multiplier) external pure returns (uint64) {
        return _getLockDuration(multiplier);
    }

    function lockMultiplierBps(Types.LockMultiplier multiplier) external pure returns (uint16) {
        return _getLockMultiplierBps(multiplier);
    }

    function configureAsset(
        Types.AssetKind kind,
        address token,
        bool enabled,
        uint256 minDelegation,
        uint256 depositCap
    ) external {
        Types.Asset memory asset = Types.Asset(kind, token);
        bytes32 assetHash = _assetHash(asset);
        _assetConfigs[assetHash] = Types.AssetConfig({
            enabled: enabled,
            minOperatorStake: 0,
            minDelegation: minDelegation,
            depositCap: depositCap,
            currentDeposits: 0,
            rewardMultiplierBps: 10000
        });

        if (kind == Types.AssetKind.Native) {
            nativeEnabled = enabled;
        } else {
            if (enabled) {
                EnumerableSet.add(_enabledErc20s, token);
            } else {
                EnumerableSet.remove(_enabledErc20s, token);
            }
        }
    }

    function depositAsset(
        Types.AssetKind kind,
        address token,
        uint256 amount,
        Types.LockMultiplier multiplier
    ) external {
        _depositAsset(Types.Asset(kind, token), amount, multiplier);
    }

    function getDeposit(
        address delegator,
        Types.AssetKind kind,
        address token
    ) external view returns (Types.Deposit memory) {
        return _deposits[delegator][_assetHash(Types.Asset(kind, token))];
    }

    function getLockCount(
        address delegator,
        Types.AssetKind kind,
        address token
    ) external view returns (uint256) {
        return _depositLocks[delegator][_assetHash(Types.Asset(kind, token))].length;
    }
}

contract RewardVaultsHarness is RewardVaults {
    function lockMultiplierBpsPublic(LockDuration lock) external pure returns (uint256) {
        return _lockMultiplierBps(lock);
    }

    function lockDurationSecondsPublic(LockDuration lock) external view returns (uint256) {
        return _lockDurationSeconds(lock);
    }
}

contract DelegationStorageLibrariesTest is Test {
    DelegationStorageHarness internal harness;
    RewardVaultsHarness internal rewardsHarness;

    function setUp() public {
        harness = new DelegationStorageHarness();
        rewardsHarness = new RewardVaultsHarness();
    }

    function test_lockDurationCoversAllMultipliers() public {
        assertEq(harness.lockDuration(Types.LockMultiplier.None), 0);
        assertEq(harness.lockDuration(Types.LockMultiplier.OneMonth), harness.LOCK_ONE_MONTH());
        assertEq(harness.lockDuration(Types.LockMultiplier.TwoMonths), harness.LOCK_TWO_MONTHS());
        assertEq(harness.lockDuration(Types.LockMultiplier.ThreeMonths), harness.LOCK_THREE_MONTHS());
        assertEq(harness.lockDuration(Types.LockMultiplier.SixMonths), harness.LOCK_SIX_MONTHS());

    }

    function test_lockMultiplierBpsCoversAllMultipliers() public {
        assertEq(harness.lockMultiplierBps(Types.LockMultiplier.None), harness.MULTIPLIER_NONE());
        assertEq(harness.lockMultiplierBps(Types.LockMultiplier.OneMonth), harness.MULTIPLIER_ONE_MONTH());
        assertEq(harness.lockMultiplierBps(Types.LockMultiplier.TwoMonths), harness.MULTIPLIER_TWO_MONTHS());
        assertEq(harness.lockMultiplierBps(Types.LockMultiplier.ThreeMonths), harness.MULTIPLIER_THREE_MONTHS());
        assertEq(harness.lockMultiplierBps(Types.LockMultiplier.SixMonths), harness.MULTIPLIER_SIX_MONTHS());
    }

    function test_depositTracksNativeAndErc20Modes() public {
        // M-9 FIX: MIN_LOCK_AMOUNT = 1e16 for locked deposits
        harness.configureAsset(Types.AssetKind.Native, address(0), true, 1, 0);
        harness.depositAsset(Types.AssetKind.Native, address(0), 1e16, Types.LockMultiplier.OneMonth);

        Types.Deposit memory nativeDep =
            harness.getDeposit(address(this), Types.AssetKind.Native, address(0));
        assertEq(nativeDep.amount, 1e16);
        assertEq(nativeDep.delegatedAmount, 0);
        assertEq(harness.getLockCount(address(this), Types.AssetKind.Native, address(0)), 1);

        address token = address(0xBEEF);
        harness.configureAsset(Types.AssetKind.ERC20, token, true, 1, 0);
        harness.depositAsset(Types.AssetKind.ERC20, token, 7, Types.LockMultiplier.None);

        Types.Deposit memory ercDep =
            harness.getDeposit(address(this), Types.AssetKind.ERC20, token);
        assertEq(ercDep.amount, 7);
        assertEq(ercDep.delegatedAmount, 0);
        assertEq(harness.getLockCount(address(this), Types.AssetKind.ERC20, token), 0);
    }

    function test_depositRevertsWhenAssetDisabled() public {
        harness.configureAsset(Types.AssetKind.Native, address(0), false, 1, 0);
        vm.expectRevert(
            abi.encodeWithSelector(
                DelegationErrors.AssetNotEnabled.selector,
                address(0)
            )
        );
        harness.depositAsset(Types.AssetKind.Native, address(0), 1, Types.LockMultiplier.None);

        address token = address(0xCAFE);
        harness.configureAsset(Types.AssetKind.ERC20, token, false, 1, 0);
        vm.expectRevert(
            abi.encodeWithSelector(
                DelegationErrors.AssetNotEnabled.selector,
                token
            )
        );
        harness.depositAsset(Types.AssetKind.ERC20, token, 1, Types.LockMultiplier.None);
    }

    function test_depositRevertsWhenDepositCapExceeded() public {
        harness.configureAsset(Types.AssetKind.Native, address(0), true, 1, 10);
        harness.depositAsset(Types.AssetKind.Native, address(0), 6, Types.LockMultiplier.None);

        vm.expectRevert(
            abi.encodeWithSelector(
                DelegationErrors.DepositCapExceeded.selector,
                10,
                6,
                6
            )
        );
        harness.depositAsset(Types.AssetKind.Native, address(0), 6, Types.LockMultiplier.None);
    }

    function test_rewardVaultLockHelpersEnumerateAllDurations() public {
        assertEq(rewardsHarness.lockMultiplierBpsPublic(RewardVaults.LockDuration.None), 10000);
        assertEq(rewardsHarness.lockMultiplierBpsPublic(RewardVaults.LockDuration.OneMonth), 11000);
        assertEq(rewardsHarness.lockMultiplierBpsPublic(RewardVaults.LockDuration.TwoMonths), 12000);
        assertEq(rewardsHarness.lockMultiplierBpsPublic(RewardVaults.LockDuration.ThreeMonths), 13000);
        assertEq(rewardsHarness.lockMultiplierBpsPublic(RewardVaults.LockDuration.SixMonths), 16000);

        assertEq(rewardsHarness.lockDurationSecondsPublic(RewardVaults.LockDuration.None), 0);
        assertEq(rewardsHarness.lockDurationSecondsPublic(RewardVaults.LockDuration.OneMonth), 30 days);
        assertEq(rewardsHarness.lockDurationSecondsPublic(RewardVaults.LockDuration.TwoMonths), 60 days);
        assertEq(rewardsHarness.lockDurationSecondsPublic(RewardVaults.LockDuration.ThreeMonths), 90 days);
        assertEq(rewardsHarness.lockDurationSecondsPublic(RewardVaults.LockDuration.SixMonths), 180 days);
    }
}

contract SlashQueueStateTest is DelegationTestHarness {
    function test_slashQueueEmptyState() public {
        assertEq(delegation.getSlashCount(operator1), 0);
        SlashingManager.SlashRecord memory record = delegation.getSlashRecord(operator1, 0);
        assertEq(record.round, 0);
        assertEq(delegation.getSlashImpact(operator1, 0, delegator1), 0);
    }

    function test_slashQueueTracksRecords() public {
        _depositAndDelegate(delegator1, operator1, 5 ether);
        _slash(operator1, 1 ether);

        assertEq(delegation.getSlashCount(operator1), 1);
        SlashingManager.SlashRecord memory record = delegation.getSlashRecord(operator1, 0);
        assertTrue(record.round != 0);
        assertTrue(record.totalSlashed > 0);
        assertTrue(record.exchangeRateBefore >= record.exchangeRateAfter);

        uint256 loss = delegation.getSlashImpact(operator1, 0, delegator1);
        assertGt(loss, 0);

        assertEq(delegation.getSlashImpact(operator1, 5, delegator1), 0);
    }
}
