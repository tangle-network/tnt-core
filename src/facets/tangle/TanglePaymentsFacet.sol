// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { PaymentsEscrow } from "../../core/PaymentsEscrow.sol";
import { PaymentsBilling } from "../../core/PaymentsBilling.sol";
import { IFacetSelectors } from "../../interfaces/IFacetSelectors.sol";

/// @title TanglePaymentsFacet
/// @notice Customer-facing escrow funding/withdrawal + subscription billing entry points.
/// @dev Distribution self-call selectors (`distributePayment`, `depositToEscrow`,
///      `initSubscriptionBaseline`, `distributeBillWithKeeper`) live on
///      `TanglePaymentsDistributionFacet`. Rewards claims + admin/views live on
///      `TanglePaymentsRewardsFacet`. Subscription billing reaches the distribution
///      path via a diamond self-call so the heavy distribution machinery does not
///      contribute bytecode to this facet.
contract TanglePaymentsFacet is PaymentsEscrow, PaymentsBilling, IFacetSelectors {
    function selectors() external pure returns (bytes4[] memory selectorList) {
        selectorList = new bytes4[](5);
        selectorList[0] = this.fundService.selector;
        selectorList[1] = this.withdrawRemainingEscrow.selector;
        selectorList[2] = this.withdrawRemainingEscrowTo.selector;
        selectorList[3] = this.billSubscription.selector;
        selectorList[4] = this.billSubscriptionBatch.selector;
    }
}
