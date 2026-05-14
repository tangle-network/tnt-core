// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { PaymentsDistribution } from "../../core/PaymentsDistribution.sol";
import { Errors } from "../../libraries/Errors.sol";
import { IFacetSelectors } from "../../interfaces/IFacetSelectors.sol";
import { ITanglePaymentsInternal } from "../../interfaces/ITanglePaymentsInternal.sol";

/// @title TanglePaymentsDistributionFacet
/// @notice Sole owner of the bill distribution path.
/// @dev These selectors are invoked exclusively via `address(this).call(...)` from other
///      facets in the diamond:
///        - `distributePayment` from event-driven job + RFQ + extension flows
///        - `depositToEscrow` from event-driven job flows
///        - `distributeBillWithKeeper` from the subscription billing facet
///      Hosting them on a dedicated facet keeps the billing facet under EIP-170.
contract TanglePaymentsDistributionFacet is PaymentsDistribution, IFacetSelectors {
    function selectors() external pure returns (bytes4[] memory selectorList) {
        selectorList = new bytes4[](4);
        selectorList[0] = this.distributePayment.selector;
        selectorList[1] = this.depositToEscrow.selector;
        selectorList[2] = this.distributeBillWithKeeper.selector;
        selectorList[3] = this.initSubscriptionBaseline.selector;
    }

    /// @notice Seed per-operator TWAP cursors and pin the subscription baseline at activation.
    /// @dev Self-call only — invoked from `_activateService` and from RFQ quote-create paths.
    function initSubscriptionBaseline(uint64 serviceId, address[] calldata operators) external {
        if (msg.sender != address(this)) revert Errors.Unauthorized();
        _initSubscriptionBaseline(serviceId, operators);
    }

    /// @notice Distribute payment using effective exposures (delegation × exposureBps).
    function distributePayment(
        uint64 serviceId,
        uint64 blueprintId,
        address token,
        uint256 amount,
        address[] calldata operators
    )
        external
    {
        if (msg.sender != address(this)) revert Errors.Unauthorized();

        (uint256[] memory effectiveExposures, uint256 totalEffectiveExposure, bool hasSecurityCommitments) =
            _calculateEffectiveExposuresWithFallback(serviceId, operators);

        _distributePaymentWithEffectiveExposure(
            serviceId,
            blueprintId,
            token,
            amount,
            operators,
            effectiveExposures,
            totalEffectiveExposure,
            hasSecurityCommitments
        );
    }

    function depositToEscrow(uint64 serviceId, address token, uint256 amount) external {
        if (msg.sender != address(this)) revert Errors.Unauthorized();
        _depositToEscrow(serviceId, token, amount);
    }

    /// @notice Distribute a pre-weighted subscription bill (with optional keeper rebate).
    /// @dev Self-call only. The caller (subscription billing facet) is responsible for
    ///      releasing `d.amount` from escrow BEFORE invoking — this entry point is pure
    ///      distribution. Weights, operators, and `hasSecurityCommitments` are computed
    ///      by the caller from TWAP-projected per-(op, asset) cum-stake-seconds.
    function distributeBillWithKeeper(ITanglePaymentsInternal.BillDistribution calldata d) external {
        if (msg.sender != address(this)) revert Errors.Unauthorized();
        // Re-pack into memory for the internal entry point. The calldata struct already
        // matches the in-memory layout used by `_distributeBill`.
        ITanglePaymentsInternal.BillDistribution memory m = ITanglePaymentsInternal.BillDistribution({
            serviceId: d.serviceId,
            blueprintId: d.blueprintId,
            token: d.token,
            amount: d.amount,
            operators: d.operators,
            weights: d.weights,
            totalWeight: d.totalWeight,
            hasSecurityCommitments: d.hasSecurityCommitments,
            keeper: d.keeper
        });
        _distributeBill(m);
    }
}
