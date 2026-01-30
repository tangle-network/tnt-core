// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Types } from "../../src/libraries/Types.sol";
import { IServiceFeeDistributor } from "../../src/interfaces/IServiceFeeDistributor.sol";

/// @notice Minimal test stub that accepts service-fee restaker shares without redistributing.
/// @dev Used by payment-split tests to ensure protocol/treasury accounting is stable even when no restakers exist.
contract MockServiceFeeDistributor is IServiceFeeDistributor {
    event ServiceFeeReceived(
        uint64 indexed serviceId,
        uint64 indexed blueprintId,
        address indexed operator,
        address paymentToken,
        uint256 amount
    );

    function distributeServiceFee(
        uint64 serviceId,
        uint64 blueprintId,
        address operator,
        address paymentToken,
        uint256 amount
    ) external payable override {
        if (paymentToken == address(0)) {
            require(msg.value == amount, "bad msg.value");
        } else {
            require(msg.value == 0, "unexpected msg.value");
        }
        emit ServiceFeeReceived(serviceId, blueprintId, operator, paymentToken, amount);
    }

    function distributeInflationReward(
        uint64 serviceId,
        uint64 blueprintId,
        address operator,
        address paymentToken,
        uint256 amount
    ) external payable override {
        if (paymentToken == address(0)) {
            require(msg.value == amount, "bad msg.value");
        } else {
            require(msg.value == 0, "unexpected msg.value");
        }
        emit ServiceFeeReceived(serviceId, blueprintId, operator, paymentToken, amount);
    }

    function claimFor(
        address,
        address,
        Types.Asset calldata
    ) external pure override returns (uint256 amount) {
        return amount;
    }

    function claimAll(address) external pure override returns (uint256 totalAmount) {
        return totalAmount;
    }

    function claimAllBatch(address[] calldata tokens) external pure override returns (uint256[] memory amounts) {
        amounts = new uint256[](tokens.length);
    }

    function pendingRewards(address, address) external pure override returns (uint256 pending) {
        return pending;
    }

    function delegatorOperators(address) external pure override returns (address[] memory operators) {
        return operators;
    }

    function delegatorAssets(address, address) external pure override returns (bytes32[] memory assetHashes) {
        return assetHashes;
    }

    function getPosition(
        address,
        address,
        bytes32
    ) external pure override returns (uint8 mode, uint256 principal, uint256 score) {
        return (mode, principal, score);
    }

    function operatorRewardTokens(address) external pure override returns (address[] memory tokens) {
        return tokens;
    }

    function onDelegationChanged(
        address,
        address,
        Types.Asset calldata,
        uint256,
        bool,
        Types.BlueprintSelectionMode,
        uint64[] calldata,
        uint256[] calldata,
        uint16
    ) external override {}

    function onBlueprintsRebalanced(address, address, Types.Asset calldata, uint64[] calldata, uint256[] calldata)
        external
        override
    {}
    function onAllModeSlashed(address, Types.Asset calldata, uint16) external override {}
    function onFixedModeSlashed(address, uint64, Types.Asset calldata, uint16) external override {}

    function getPoolScore(
        address,
        uint64,
        Types.Asset calldata
    ) external pure override returns (uint256 allScore, uint256 fixedScore) {
        return (0, 0);
    }

    function getOperatorServiceUsdExposure(
        uint64,
        uint64,
        address
    ) external pure override returns (uint256 totalUsdExposure) {
        return totalUsdExposure;
    }

    function onOperatorLeaving(uint64, address) external override {}
    function onServiceTerminated(uint64, address) external override {}

    receive() external payable {}
}
