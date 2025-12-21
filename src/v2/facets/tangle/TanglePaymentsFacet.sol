// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Payments } from "../../core/Payments.sol";
import { Errors } from "../../libraries/Errors.sol";
import { IFacetSelectors } from "../../interfaces/IFacetSelectors.sol";

/// @title TanglePaymentsFacet
/// @notice Facet for escrow and rewards
contract TanglePaymentsFacet is Payments, IFacetSelectors {
    function selectors() external pure returns (bytes4[] memory selectorList) {
        selectorList = new bytes4[](15);
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
        selectorList[13] = this.distributePayment.selector;
        selectorList[14] = this.depositToEscrow.selector;
    }

    function distributePayment(
        uint64 serviceId,
        uint64 blueprintId,
        address token,
        uint256 amount,
        address[] calldata operators,
        uint16[] calldata exposures,
        uint256 totalExposure
    ) external {
        if (msg.sender != address(this)) revert Errors.Unauthorized();
        _distributePayment(serviceId, blueprintId, token, amount, operators, exposures, totalExposure);
    }

    function depositToEscrow(uint64 serviceId, address token, uint256 amount) external {
        if (msg.sender != address(this)) revert Errors.Unauthorized();
        _depositToEscrow(serviceId, token, amount);
    }
}
