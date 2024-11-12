// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { ICrossChainMessenger } from "../interfaces/ICrossChainMessenger.sol";
import { IRemoteChainBridgeManager } from "../interfaces/IRemoteChainBridgeManager.sol";

/// @title RemoteChainBridgeManager
/// @notice Manages message dispatch to Tangle through multiple bridges
contract RemoteChainBridgeManager is IRemoteChainBridgeManager {
    /// @dev Maps bridge IDs to their configurations
    mapping(uint256 => BridgeConfig) public bridges;

    error InvalidMessenger();
    error InvalidRecipient();
    error BridgeNotFound();
    error InactiveBridge();
    error InsufficientFee();

    function configureBridge(uint256 bridgeId, address messenger, uint32 tangleChainId, bytes32 tangleRecipient) external {
        if (messenger == address(0)) revert InvalidMessenger();
        if (tangleRecipient == bytes32(0)) revert InvalidRecipient();

        bridges[bridgeId] = BridgeConfig({
            messenger: ICrossChainMessenger(messenger),
            tangleChainId: tangleChainId,
            tangleRecipient: tangleRecipient,
            isActive: true
        });

        emit BridgeConfigured(bridgeId, messenger, tangleChainId, tangleRecipient);
    }

    function dispatchMessage(bytes calldata message) external payable {
        uint256 remainingValue = msg.value;

        // Try each configured bridge
        for (uint256 bridgeId = 0; bridgeId < type(uint256).max; bridgeId++) {
            BridgeConfig storage config = bridges[bridgeId];
            if (!config.isActive) continue;

            try config.messenger.quoteMessageFee(config.tangleChainId, config.tangleRecipient, message) returns (uint256 fee) {
                if (fee > remainingValue) continue;

                try config.messenger.sendMessage{ value: fee }(config.tangleChainId, config.tangleRecipient, message) returns (
                    bytes32 messageId
                ) {
                    remainingValue -= fee;
                    emit MessageDispatched(bridgeId, messageId, message);
                } catch Error(string memory reason) {
                    emit DispatchError(bridgeId, reason);
                }
            } catch Error(string memory reason) {
                emit DispatchError(bridgeId, reason);
            }
        }

        // Return any unused fees
        if (remainingValue > 0) {
            (bool success,) = msg.sender.call{ value: remainingValue }("");
            require(success, "Fee return failed");
        }
    }

    function getMessageFee(uint256 bridgeId, bytes calldata message) external view returns (uint256) {
        BridgeConfig storage config = bridges[bridgeId];
        if (!config.isActive) revert InactiveBridge();

        return config.messenger.quoteMessageFee(config.tangleChainId, config.tangleRecipient, message);
    }

    receive() external payable { }
}
