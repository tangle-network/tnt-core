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
