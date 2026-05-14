// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { ServicesApprovalsViews } from "../../core/ServicesApprovalsViews.sol";
import { IFacetSelectors } from "../../interfaces/IFacetSelectors.sol";

/// @title TangleServicesViewsFacet
/// @notice Hosts public read-only helpers and the permissionless request-expiry path.
/// @dev Carved off `TangleServicesFacet` so the approve/activate machinery does not have to
///      live alongside these selectors. Inherits only `ServicesApprovalsViews` to keep the
///      compiled facet small.
contract TangleServicesViewsFacet is ServicesApprovalsViews, IFacetSelectors {
    function selectors() external pure returns (bytes4[] memory selectorList) {
        selectorList = new bytes4[](5);
        selectorList[0] = this.getOperatorBlsPubkey.selector;
        selectorList[1] = this.blsPopMessage.selector;
        selectorList[2] = this.getTeeCommitmentRoot.selector;
        selectorList[3] = this.teeNonceFor.selector;
        selectorList[4] = this.expireServiceRequest.selector;
    }
}
