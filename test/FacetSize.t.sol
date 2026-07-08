// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test } from "forge-std/Test.sol";

import { TangleBlueprintsFacet } from "../src/facets/tangle/TangleBlueprintsFacet.sol";
import { TangleBlueprintsManagementFacet } from "../src/facets/tangle/TangleBlueprintsManagementFacet.sol";
import { TangleJobsAggregationFacet } from "../src/facets/tangle/TangleJobsAggregationFacet.sol";
import { TangleJobsFacet } from "../src/facets/tangle/TangleJobsFacet.sol";
import { TangleJobsRFQFacet } from "../src/facets/tangle/TangleJobsRFQFacet.sol";
import { TangleOperatorsFacet } from "../src/facets/tangle/TangleOperatorsFacet.sol";
import { TanglePaymentsDistributionFacet } from "../src/facets/tangle/TanglePaymentsDistributionFacet.sol";
import { TanglePaymentsFacet } from "../src/facets/tangle/TanglePaymentsFacet.sol";
import { TanglePaymentsRewardsFacet } from "../src/facets/tangle/TanglePaymentsRewardsFacet.sol";
import { TangleQuotesExtensionFacet } from "../src/facets/tangle/TangleQuotesExtensionFacet.sol";
import { TangleQuotesFacet } from "../src/facets/tangle/TangleQuotesFacet.sol";
import { TangleServicesFacet } from "../src/facets/tangle/TangleServicesFacet.sol";
import { TangleServicesLifecycleFacet } from "../src/facets/tangle/TangleServicesLifecycleFacet.sol";
import { TangleServicesRequestsFacet } from "../src/facets/tangle/TangleServicesRequestsFacet.sol";
import { TangleServicesViewsFacet } from "../src/facets/tangle/TangleServicesViewsFacet.sol";
import { TangleSlashingFacet } from "../src/facets/tangle/TangleSlashingFacet.sol";

import { StakingAdminFacet } from "../src/facets/staking/StakingAdminFacet.sol";
import { StakingAssetsFacet } from "../src/facets/staking/StakingAssetsFacet.sol";
import { StakingDelegationsFacet } from "../src/facets/staking/StakingDelegationsFacet.sol";
import { StakingUnstakeWithdrawFacet } from "../src/facets/staking/StakingUnstakeWithdrawFacet.sol";
import { StakingDepositsFacet } from "../src/facets/staking/StakingDepositsFacet.sol";
import { StakingOperatorsFacet } from "../src/facets/staking/StakingOperatorsFacet.sol";
import { StakingSlashingFacet } from "../src/facets/staking/StakingSlashingFacet.sol";
import { StakingViewsFacet } from "../src/facets/staking/StakingViewsFacet.sol";

// Standalone (non-facet) deployable impls that sit near the size ceiling — gated for Tempo too.
import { ServiceFeeDistributor } from "../src/rewards/ServiceFeeDistributor.sol";
import { InflationPool } from "../src/rewards/InflationPool.sol";
import { RewardVaults } from "../src/rewards/RewardVaults.sol";
import { StreamingPaymentManager } from "../src/rewards/StreamingPaymentManager.sol";
import { ValidatorPodManager } from "../src/beacon/ValidatorPodManager.sol";

/// @notice EIP-170 gate: every deployable facet's runtime bytecode must fit under the
///         24576-byte limit enforced by mainnet, Base, Arbitrum, Optimism, and every
///         other EIP-170 chain. Anvil runs with `--disable-code-size-limit` and will
///         silently let an oversized facet pass the local build (this exact trap was
///         what PR #149 cleaned up after — a 24874-byte TanglePaymentsFacet that
///         shipped through CI because the test suite never deployed it on a chain
///         that enforces the limit).
///
///         The test compares `address(new Facet()).code.length` to the limit, so it
///         exercises the *actual* deployed runtime bytecode (post-constructor) under
///         the default profile that production builds use.
contract FacetSizeTest is Test {
    /// @dev EIP-170 contract size limit (24576 bytes).
    uint256 internal constant CODE_SIZE_LIMIT = 24_576;

    /// @dev Tempo (chain 42431) per-transaction gas cap is 30M and it meters code deposit ~1,372
    ///      gas/runtime-byte, so a contract's CREATE cost is ~1,372*bytes + init overhead. The
    ///      deploy ceiling is therefore ~21,870 B (30M/1,372) — STRICTER than EIP-170's 24,576.
    ///      We gate at 21,500 to keep ~370 B (~500k gas) of margin for constructor/init overhead and
    ///      forge's gas-estimate variance, so a contract can never silently grow past the point where
    ///      `forge script ... --broadcast` to Tempo would fail with "tx gas limit > cap". This is the
    ///      fence that caught the 0.19 deploy (StakingDelegationsFacet + ServiceFeeDistributor both
    ///      exceeded it and were split / library-extracted).
    uint256 internal constant TEMPO_DEPLOY_CAP = 21_500;

    function _assertUnderLimit(address facet, string memory name) internal view {
        uint256 size = facet.code.length;
        if (size > CODE_SIZE_LIMIT) {
            revert(
                string.concat(
                    name,
                    ": ",
                    vm.toString(size),
                    " bytes exceeds EIP-170 limit of ",
                    vm.toString(CODE_SIZE_LIMIT),
                    " bytes (overage: ",
                    vm.toString(size - CODE_SIZE_LIMIT),
                    ")"
                )
            );
        }
    }

    function _assertUnderTempoCap(address c, string memory name) internal view {
        uint256 size = c.code.length;
        if (size > TEMPO_DEPLOY_CAP) {
            revert(
                string.concat(
                    name,
                    ": ",
                    vm.toString(size),
                    " bytes exceeds the Tempo deploy ceiling of ",
                    vm.toString(TEMPO_DEPLOY_CAP),
                    " bytes (overage: ",
                    vm.toString(size - TEMPO_DEPLOY_CAP),
                    ") - its CREATE would exceed Tempo's 30M per-tx gas cap; split it or extract a library"
                )
            );
        }
    }

    /// @notice Tempo deploy-cap gate: every deployable contract (facets + near-ceiling standalone
    ///         impls) must fit under the ~21,870 B Tempo CREATE ceiling. Runs under the optimized
    ///         (default) profile that production builds use.
    function test_DeployablesUnderTempoDeployCap() public {
        // Tangle facets
        _assertUnderTempoCap(address(new TangleBlueprintsFacet()), "TangleBlueprintsFacet");
        _assertUnderTempoCap(address(new TangleBlueprintsManagementFacet()), "TangleBlueprintsManagementFacet");
        _assertUnderTempoCap(address(new TangleJobsAggregationFacet()), "TangleJobsAggregationFacet");
        _assertUnderTempoCap(address(new TangleJobsFacet()), "TangleJobsFacet");
        _assertUnderTempoCap(address(new TangleJobsRFQFacet()), "TangleJobsRFQFacet");
        _assertUnderTempoCap(address(new TangleOperatorsFacet()), "TangleOperatorsFacet");
        _assertUnderTempoCap(address(new TanglePaymentsDistributionFacet()), "TanglePaymentsDistributionFacet");
        _assertUnderTempoCap(address(new TanglePaymentsFacet()), "TanglePaymentsFacet");
        _assertUnderTempoCap(address(new TanglePaymentsRewardsFacet()), "TanglePaymentsRewardsFacet");
        _assertUnderTempoCap(address(new TangleQuotesExtensionFacet()), "TangleQuotesExtensionFacet");
        _assertUnderTempoCap(address(new TangleQuotesFacet()), "TangleQuotesFacet");
        _assertUnderTempoCap(address(new TangleServicesFacet()), "TangleServicesFacet");
        _assertUnderTempoCap(address(new TangleServicesLifecycleFacet()), "TangleServicesLifecycleFacet");
        _assertUnderTempoCap(address(new TangleServicesRequestsFacet()), "TangleServicesRequestsFacet");
        _assertUnderTempoCap(address(new TangleServicesViewsFacet()), "TangleServicesViewsFacet");
        _assertUnderTempoCap(address(new TangleSlashingFacet()), "TangleSlashingFacet");
        // Staking facets
        _assertUnderTempoCap(address(new StakingAdminFacet()), "StakingAdminFacet");
        _assertUnderTempoCap(address(new StakingAssetsFacet()), "StakingAssetsFacet");
        _assertUnderTempoCap(address(new StakingDelegationsFacet()), "StakingDelegationsFacet");
        _assertUnderTempoCap(address(new StakingUnstakeWithdrawFacet()), "StakingUnstakeWithdrawFacet");
        _assertUnderTempoCap(address(new StakingDepositsFacet()), "StakingDepositsFacet");
        _assertUnderTempoCap(address(new StakingOperatorsFacet()), "StakingOperatorsFacet");
        _assertUnderTempoCap(address(new StakingSlashingFacet()), "StakingSlashingFacet");
        _assertUnderTempoCap(address(new StakingViewsFacet()), "StakingViewsFacet");
        // Standalone impls that sit near the ceiling
        _assertUnderTempoCap(address(new ServiceFeeDistributor()), "ServiceFeeDistributor");
        _assertUnderTempoCap(address(new InflationPool()), "InflationPool");
        _assertUnderTempoCap(address(new RewardVaults()), "RewardVaults");
        _assertUnderTempoCap(address(new StreamingPaymentManager()), "StreamingPaymentManager");
        _assertUnderTempoCap(address(new ValidatorPodManager(address(0x1), 0)), "ValidatorPodManager");
    }

    function test_TangleFacetsUnderEip170() public {
        _assertUnderLimit(address(new TangleBlueprintsFacet()), "TangleBlueprintsFacet");
        _assertUnderLimit(address(new TangleBlueprintsManagementFacet()), "TangleBlueprintsManagementFacet");
        _assertUnderLimit(address(new TangleJobsAggregationFacet()), "TangleJobsAggregationFacet");
        _assertUnderLimit(address(new TangleJobsFacet()), "TangleJobsFacet");
        _assertUnderLimit(address(new TangleJobsRFQFacet()), "TangleJobsRFQFacet");
        _assertUnderLimit(address(new TangleOperatorsFacet()), "TangleOperatorsFacet");
        _assertUnderLimit(address(new TanglePaymentsDistributionFacet()), "TanglePaymentsDistributionFacet");
        _assertUnderLimit(address(new TanglePaymentsFacet()), "TanglePaymentsFacet");
        _assertUnderLimit(address(new TanglePaymentsRewardsFacet()), "TanglePaymentsRewardsFacet");
        _assertUnderLimit(address(new TangleQuotesExtensionFacet()), "TangleQuotesExtensionFacet");
        _assertUnderLimit(address(new TangleQuotesFacet()), "TangleQuotesFacet");
        _assertUnderLimit(address(new TangleServicesFacet()), "TangleServicesFacet");
        _assertUnderLimit(address(new TangleServicesLifecycleFacet()), "TangleServicesLifecycleFacet");
        _assertUnderLimit(address(new TangleServicesRequestsFacet()), "TangleServicesRequestsFacet");
        _assertUnderLimit(address(new TangleServicesViewsFacet()), "TangleServicesViewsFacet");
        _assertUnderLimit(address(new TangleSlashingFacet()), "TangleSlashingFacet");
    }

    function test_StakingFacetsUnderEip170() public {
        _assertUnderLimit(address(new StakingAdminFacet()), "StakingAdminFacet");
        _assertUnderLimit(address(new StakingAssetsFacet()), "StakingAssetsFacet");
        _assertUnderLimit(address(new StakingDelegationsFacet()), "StakingDelegationsFacet");
        _assertUnderLimit(address(new StakingUnstakeWithdrawFacet()), "StakingUnstakeWithdrawFacet");
        _assertUnderLimit(address(new StakingDepositsFacet()), "StakingDepositsFacet");
        _assertUnderLimit(address(new StakingOperatorsFacet()), "StakingOperatorsFacet");
        _assertUnderLimit(address(new StakingSlashingFacet()), "StakingSlashingFacet");
        _assertUnderLimit(address(new StakingViewsFacet()), "StakingViewsFacet");
    }
}
