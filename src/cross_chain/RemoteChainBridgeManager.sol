// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import "../Permissions.sol";
import { ICrossChainMessenger } from "../interfaces/ICrossChainMessenger.sol";
import { IRemoteChainBridgeManager } from "../interfaces/IRemoteChainBridgeManager.sol";
import { GlacisClient } from "glacis-contracts/client/GlacisClient.sol";

/// @title RemoteChainBridgeManager
/// @notice Manages message dispatch to Tangle through multiple bridges
contract RemoteChainBridgeManager is IRemoteChainBridgeManager, RootChainEnabledOwnable, GlacisClient {

    bytes32 immutable RECEIVER;
    address immutable REFUND_ADDRESS;
    uint256 immutable TANGLE_CHAIN_ID;
    address[] gmps;
    CrossChainGas[] fees;

    error InvalidMessenger();
    error InvalidRecipient();
    error BridgeNotFound();
    error InactiveBridge();
    error InsufficientFee();

    constructor(
        address _glacisRouter,
        uint256 _quorum,
        bytes32 _receiver,
        address _refundAddress,
        uint256 _tangleChainId
    ) GlacisClient(_glacisRouter, _quorum) {
        RECEIVER = _receiver;
        REFUND_ADDRESS = _refundAddress;
        TANGLE_CHAIN_ID = _tangleChainId;
    }

    function configureGMPs(address[] memory _gmps, CrossChainGas[] memory _fees) external onlyOwner {
        gmps = _gmps;
        delete fees;
        for (uint256 i = 0; i < _fees.length;) {
            fees.push(_fees[i]);
            unchecked {
                i++;
            }
        }
    }

    function dispatchMessage(bytes calldata message) external payable {
        _route(TANGLE_CHAIN_ID, RECEIVER, message, gmps, fees, REFUND_ADDRESS, false, msg.value);
    }

    function getMessageFee(bytes calldata message) external view returns (uint256 fee) {
        _calculateFeeForMessage(message);
    }

    function _calculateFeeForMessage(bytes calldata message) internal view virtual returns (uint256 fee) {}

    receive() external payable { }
}
