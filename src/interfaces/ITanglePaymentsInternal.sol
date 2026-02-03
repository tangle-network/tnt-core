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
    ) external;

    function depositToEscrow(uint64 serviceId, address token, uint256 amount) external;
}
