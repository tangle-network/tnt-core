// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

interface ISlashAccumulator {
    function slash(uint64 blueprintId, uint64 serviceId, bytes32 operator, uint256 slashAmount) external;
}
