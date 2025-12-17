// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Types } from "../libraries/Types.sol";

/// @title ITangleSecurityView
/// @notice Minimal view interface for reading service security requirements + operator commitments.
interface ITangleSecurityView {
    function getServiceSecurityRequirements(uint64 serviceId)
        external
        view
        returns (Types.AssetSecurityRequirement[] memory);

    function getServiceSecurityCommitmentBps(
        uint64 serviceId,
        address operator,
        Types.AssetKind kind,
        address token
    ) external view returns (uint16);

    function treasury() external view returns (address payable);

    function getService(uint64 serviceId) external view returns (Types.Service memory);

    function getServiceOperators(uint64 serviceId) external view returns (address[] memory);
}

