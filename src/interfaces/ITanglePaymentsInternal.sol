// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

interface ITanglePaymentsInternal {
    function distributePayment(
        uint64 serviceId,
        uint64 blueprintId,
        address token,
        uint256 amount,
        address[] calldata operators,
        uint16[] calldata exposures,
        uint256 totalExposure
    ) external;

    function depositToEscrow(uint64 serviceId, address token, uint256 amount) external;
}
