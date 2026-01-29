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
        selectorList = new bytes4[](15);
        selectorList[0] = this.terminateService.selector;
        selectorList[1] = this.addPermittedCaller.selector;
        selectorList[2] = this.removePermittedCaller.selector;
        selectorList[3] = this.joinService.selector;
        selectorList[4] = bytes4(keccak256("joinServiceWithCommitments(uint64,uint16,((uint8,address),uint16)[])"));
        selectorList[5] = this.scheduleExit.selector;
        selectorList[6] = this.executeExit.selector;
        selectorList[7] = this.cancelExit.selector;
        selectorList[8] = this.forceExit.selector;
        selectorList[9] = this.leaveService.selector;
        selectorList[10] = this.forceRemoveOperator.selector;
        selectorList[11] = this.getExitRequest.selector;
        selectorList[12] = this.getExitStatus.selector;
        selectorList[13] = this.getExitConfig.selector;
        selectorList[14] = this.canScheduleExit.selector;
    }
}
