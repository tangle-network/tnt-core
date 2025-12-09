// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IPriceOracle} from "../../../src/v2/oracles/interfaces/IPriceOracle.sol";

/// @notice Minimal mock implementing the price oracle interface for testing.
contract MockPriceOracle is IPriceOracle {
    mapping(address => uint256) public prices;

    function setPrice(address token, uint256 price) external {
        prices[token] = price;
    }

    function getPrice(address token) external view override returns (uint256 price) {
        price = prices[token];
        if (price == 0) revert PriceNotAvailable(token);
    }

    function getPriceData(address token) external view override returns (PriceData memory data) {
        uint256 price = prices[token];
        return PriceData({price: price, updatedAt: block.timestamp, decimals: 18, isValid: price > 0});
    }

    function isTokenSupported(address token) external view override returns (bool supported) {
        return prices[token] != 0;
    }

    function toUSD(address token, uint256 amount) external view override returns (uint256) {
        uint256 price = prices[token];
        if (price == 0) revert PriceNotAvailable(token);
        return (price * amount) / 1e18;
    }

    function fromUSD(address token, uint256 usdValue) external view override returns (uint256 amount) {
        uint256 price = prices[token];
        if (price == 0) revert PriceNotAvailable(token);
        return (usdValue * 1e18) / price;
    }

    function batchToUSD(address[] calldata tokens, uint256[] calldata amounts)
        external
        view
        override
        returns (uint256 totalUsd)
    {
        require(tokens.length == amounts.length, "len");
        for (uint256 i = 0; i < tokens.length; i++) {
            if (amounts[i] == 0) continue;
            uint256 price = prices[tokens[i]];
            if (price == 0) revert PriceNotAvailable(tokens[i]);
            totalUsd += (price * amounts[i]) / 1e18;
        }
    }

    function maxPriceAge() external pure override returns (uint256) {
        return type(uint256).max;
    }

    function oracleName() external pure override returns (string memory) {
        return "MockPriceOracle";
    }
}
