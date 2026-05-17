// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface ITanglePaymentsInternal {
    /// @notice Pre-computed bill distribution parameters passed across the diamond
    ///         self-call boundary from the subscription billing facet to the
    ///         distribution facet. Mirrors the in-memory struct in `PaymentsDistribution`.
    struct BillDistribution {
        uint64 serviceId;
        uint64 blueprintId;
        address token;
        uint256 amount;
        address[] operators;
        uint256[] weights;
        uint256 totalWeight;
        bool hasSecurityCommitments;
        address keeper;
    }

    /// @notice Distribute payment using effective exposures (delegation × exposureBps)
    /// @dev Computes effective exposures internally from operator security commitments.
    function distributePayment(
        uint64 serviceId,
        uint64 blueprintId,
        address token,
        uint256 amount,
        address[] calldata operators
    )
        external;

    function depositToEscrow(uint64 serviceId, address token, uint256 amount) external;

    /// @notice Seed per-operator TWAP cursors and pin the subscription baseline at activation.
    function initSubscriptionBaseline(uint64 serviceId, address[] calldata operators) external;

    /// @notice Distribute a pre-weighted subscription bill (with optional keeper rebate).
    /// @dev Self-call only. The caller is responsible for releasing `amount` from escrow
    ///      BEFORE invoking — this entry point is pure distribution.
    function distributeBillWithKeeper(BillDistribution calldata d) external;

    /// @notice Atomic ERC20 transfer + distributeServiceFee in a single call frame.
    /// @dev Self-call only. Bundles the safeTransfer and the distributor call so a
    ///      revert in either rolls back both — no ERC20 stranding at the distributor.
    function forwardStakerShareAtomic(
        address distributor,
        uint64 serviceId,
        uint64 blueprintId,
        address operator,
        address token,
        uint256 amount
    )
        external;
}
