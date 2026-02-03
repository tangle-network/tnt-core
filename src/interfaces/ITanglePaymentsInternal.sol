// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface ITanglePaymentsInternal {
    /// @notice Legacy distribute payment using simple exposure bps
    /// @dev DEPRECATED: Use distributePaymentWithEffectiveExposure for accurate security-weighted payments
    function distributePayment(
        uint64 serviceId,
        uint64 blueprintId,
        address token,
        uint256 amount,
        address[] calldata operators,
        uint16[] calldata exposures,
        uint256 totalExposure
    ) external;

    /// @notice Distribute payment using effective exposures (delegation × exposureBps)
    /// @dev This ensures operators are paid proportionally to actual security capital at risk
    /// @param serviceId The service ID
    /// @param blueprintId The blueprint ID
    /// @param token Payment token address
    /// @param amount Total payment amount
    /// @param operators Array of operator addresses
    /// @param effectiveExposures Array of effective exposure values (pre-calculated as delegation × exposureBps)
    /// @param totalEffectiveExposure Sum of all effective exposures
    function distributePaymentWithEffectiveExposure(
        uint64 serviceId,
        uint64 blueprintId,
        address token,
        uint256 amount,
        address[] calldata operators,
        uint256[] calldata effectiveExposures,
        uint256 totalEffectiveExposure
    ) external;

    function depositToEscrow(uint64 serviceId, address token, uint256 amount) external;
}
