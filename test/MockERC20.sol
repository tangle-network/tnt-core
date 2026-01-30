// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { MockERC20 as ForgeStdMockERC20 } from "forge-std/mocks/MockERC20.sol";

/// @title MockERC20
/// @notice Extended MockERC20 for testing with constructor and public mint
contract MockERC20 is ForgeStdMockERC20 {
    constructor() {
        initialize("MockToken", "MTK", 18);
    }

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external {
        _burn(from, amount);
    }
}
