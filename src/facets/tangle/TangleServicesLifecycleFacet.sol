// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import { ServicesLifecycle } from "../../core/ServicesLifecycle.sol";
import { IFacetSelectors } from "../../interfaces/IFacetSelectors.sol";

/// @title TangleServicesLifecycleFacet
/// @notice Facet for service lifecycle management
contract TangleServicesLifecycleFacet is ServicesLifecycle, IFacetSelectors {
    using EnumerableSet for EnumerableSet.AddressSet;

    function selectors() external pure returns (bytes4[] memory selectorList) {
        selectorList = new bytes4[](16);
        selectorList[0] = this.terminateService.selector;
        selectorList[1] = this.terminateServiceForNonPayment.selector;
        selectorList[2] = this.addPermittedCaller.selector;
        selectorList[3] = this.removePermittedCaller.selector;
        selectorList[4] = this.joinService.selector;
        selectorList[5] = bytes4(keccak256("joinServiceWithCommitments(uint64,uint16,((uint8,address),uint16)[])"));
        selectorList[6] = this.scheduleExit.selector;
        selectorList[7] = this.executeExit.selector;
        selectorList[8] = this.cancelExit.selector;
        selectorList[9] = this.forceExit.selector;
        selectorList[10] = this.leaveService.selector;
        selectorList[11] = this.forceRemoveOperator.selector;
        selectorList[12] = this.getExitRequest.selector;
        selectorList[13] = this.getExitStatus.selector;
        selectorList[14] = this.getExitConfig.selector;
        selectorList[15] = this.canScheduleExit.selector;
    }
}
