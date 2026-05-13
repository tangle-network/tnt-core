// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface ITanglePaymentsInternal {
    /// @notice Distribute payment using effective exposures (delegation × exposureBps)
    /// @dev Computes effective exposures internally from operator security commitments.
    ///      Operators are paid proportionally to actual security capital at risk.
    /// @param serviceId The service ID
    /// @param blueprintId The blueprint ID
    /// @param token Payment token address
    /// @param amount Total payment amount
    /// @param operators Array of operator addresses
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
    /// @dev Called for Subscription-pricing services from the activation paths so the first
    ///      bill measures against the activation snapshot (not against state captured at
    ///      first bill, which would let post-activation stake changes shift the baseline).
    function initSubscriptionBaseline(uint64 serviceId, address[] calldata operators) external;
}
