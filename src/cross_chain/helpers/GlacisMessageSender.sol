// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import { GlacisClient } from "glacis-contracts/client/GlacisClient.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

/// @title GlacisMessageSender
/// @notice Manages message dispatch to Tangle through multiple bridges
contract GlacisMessageSender is GlacisClient, Ownable {
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
    )
        GlacisClient(_glacisRouter, _quorum)
        Ownable()
    {
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

    function _dispatchMessage(bytes calldata message) internal {
        _route(TANGLE_CHAIN_ID, RECEIVER, message, gmps, fees, REFUND_ADDRESS, false, msg.value);
    }

    function _calculateMessageFee(bytes calldata message) internal view virtual returns (uint256 fee) { }

    receive() external payable { }
}
