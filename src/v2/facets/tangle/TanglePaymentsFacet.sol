// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Payments } from "../../core/Payments.sol";
import { IFacetSelectors } from "../../interfaces/IFacetSelectors.sol";

/// @title TanglePaymentsFacet
/// @notice Facet for escrow and rewards
contract TanglePaymentsFacet is Payments, IFacetSelectors {
    function selectors() external pure returns (bytes4[] memory selectorList) {
        selectorList = new bytes4[](13);
        selectorList[0] = this.fundService.selector;
        selectorList[1] = this.billSubscription.selector;
        selectorList[2] = this.billSubscriptionBatch.selector;
        selectorList[3] = this.getBillableServices.selector;
        selectorList[4] = bytes4(keccak256("claimRewards()"));
        selectorList[5] = bytes4(keccak256("claimRewards(address)"));
        selectorList[6] = bytes4(keccak256("pendingRewards(address)"));
        selectorList[7] = bytes4(keccak256("pendingRewards(address,address)"));
        selectorList[8] = this.setPaymentSplit.selector;
        selectorList[9] = this.setTreasury.selector;
        selectorList[10] = this.paymentSplit.selector;
        selectorList[11] = this.treasury.selector;
        selectorList[12] = this.getServiceEscrow.selector;
    }
}
