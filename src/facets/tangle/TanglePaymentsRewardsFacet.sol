// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { PaymentsRewards } from "../../core/PaymentsRewards.sol";
import { IFacetSelectors } from "../../interfaces/IFacetSelectors.sol";

/// @title TanglePaymentsRewardsFacet
/// @notice Rewards claim, payment-split / treasury admin, escrow view.
/// @dev Hosted on its own facet so the bytecode footprint stays small. The billing,
///      escrow funding, and distribution selectors live on `TanglePaymentsFacet`.
contract TanglePaymentsRewardsFacet is PaymentsRewards, IFacetSelectors {
    function selectors() external pure returns (bytes4[] memory selectorList) {
        selectorList = new bytes4[](13);
        selectorList[0] = bytes4(keccak256("claimRewards()"));
        selectorList[1] = bytes4(keccak256("claimRewards(address)"));
        selectorList[2] = bytes4(keccak256("claimRewardsBatch(address[])"));
        selectorList[3] = bytes4(keccak256("claimRewardsAll()"));
        selectorList[4] = bytes4(keccak256("pendingRewards(address)"));
        selectorList[5] = bytes4(keccak256("pendingRewards(address,address)"));
        selectorList[6] = bytes4(keccak256("rewardTokens(address)"));
        selectorList[7] = this.setPaymentSplit.selector;
        selectorList[8] = this.setTreasury.selector;
        selectorList[9] = this.paymentSplit.selector;
        selectorList[10] = this.treasury.selector;
        selectorList[11] = this.getServiceEscrow.selector;
        selectorList[12] = this.getBillableServices.selector;
    }
}
