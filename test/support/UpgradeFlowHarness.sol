// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BaseTest } from "../BaseTest.sol";
import { Tangle } from "../../src/Tangle.sol";
import { TangleBlueprintsBinaryVersionsFacet } from "../../src/facets/tangle/TangleBlueprintsBinaryVersionsFacet.sol";
import {
    TangleBlueprintsBinaryAttestationsFacet
} from "../../src/facets/tangle/TangleBlueprintsBinaryAttestationsFacet.sol";
import { BlueprintsBinaryVersions } from "../../src/core/BlueprintsBinaryVersions.sol";
import { BlueprintsBinaryAttestations } from "../../src/core/BlueprintsBinaryAttestations.sol";

/// @title UpgradeFlowHarness
/// @notice BaseTest extension that wires the upgrade-flow facets (binary versions,
///         attestations) into the Tangle router and exposes typed handles so each
///         test contract avoids casting to the proxy explicitly.
/// @dev BaseTest does not register the new facets because they are an additive
///      surface introduced on `feat/blueprint-binary-versions`. The unified
///      deploy script does register them; this harness mirrors that registration
///      for unit tests so behaviour matches production routing exactly.
abstract contract UpgradeFlowHarness is BaseTest {
    BlueprintsBinaryVersions internal versions;
    BlueprintsBinaryAttestations internal attestations;

    function setUp() public virtual override {
        super.setUp();

        Tangle router = Tangle(payable(address(tangleProxy)));
        vm.startPrank(admin);
        router.registerFacet(address(new TangleBlueprintsBinaryVersionsFacet()));
        router.registerFacet(address(new TangleBlueprintsBinaryAttestationsFacet()));
        vm.stopPrank();

        // The proxy dispatches via fallback; cast it to the binary-flow facets so
        // tests can call publishBinaryVersion / attestBinaryVersion directly.
        versions = BlueprintsBinaryVersions(payable(address(tangleProxy)));
        attestations = BlueprintsBinaryAttestations(payable(address(tangleProxy)));
    }

    /// @notice Register an operator with staking and create a fixed service with
    ///         a single approved operator, returning the blueprintId and serviceId.
    function _createServiceWithSingleOperator(
        address owner,
        address operator,
        address manager
    )
        internal
        returns (uint64 blueprintId, uint64 serviceId)
    {
        _registerOperator(operator);
        blueprintId = _createBlueprint(owner, manager);

        _registerForBlueprint(operator, blueprintId);
        uint64 requestId = _requestService(user1, blueprintId, operator);
        _approveService(operator, requestId);
        serviceId = tangle.serviceCount() - 1;
    }
}
