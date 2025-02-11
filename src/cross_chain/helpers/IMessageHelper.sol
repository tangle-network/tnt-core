// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

interface IMessageHelper {
    function initialize() external;
    function update(bytes calldata) external;
    function sendMessage(bytes calldata) external;
    function parseMessage(bytes calldata) external;
}
