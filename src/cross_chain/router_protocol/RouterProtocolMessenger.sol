// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { ICrossChainMessenger } from "../../interfaces/ICrossChainMessenger.sol";
import { IGateway } from "../../vendored/router_protocol/IGateway.sol";

/// @title RouterProtocolMessenger
/// @notice Blueprint messenger contract for Router Protocol
/// This contract is used to send messages from Tangle Blueprints to Router Protocol
/// for cross-chain communication. Every blueprint uses this contract to send job results
/// and slash events to the remote chain.
contract RouterProtocolMessenger is ICrossChainMessenger {
    IGateway public immutable gateway;

    struct RouterConfig {
        uint64 destGasLimit;
        uint64 destGasPrice;
        uint64 ackGasLimit;
        uint64 ackGasPrice;
        uint128 relayerFees;
        uint8 ackType;
        bool isReadCall;
        string asmAddress;
    }

    // Default configuration per destination chain
    mapping(uint32 => RouterConfig) public chainConfigs;

    event ConfigUpdated(uint32 chainId, RouterConfig config);

    constructor(address _gateway) {
        require(_gateway != address(0), "Invalid router address");
        gateway = IGateway(_gateway);
    }

    function setChainConfig(uint32 chainId, RouterConfig calldata config) external {
        chainConfigs[chainId] = config;
        emit ConfigUpdated(chainId, config);
    }

    function getRequestMetadata(RouterConfig memory config) public pure returns (bytes memory) {
        return abi.encodePacked(
            config.destGasLimit,
            config.destGasPrice,
            config.ackGasLimit,
            config.ackGasPrice,
            config.relayerFees,
            config.ackType,
            config.isReadCall,
            config.asmAddress
        );
    }

    function getRequestPacket(string memory destAddress, bytes memory payload) public pure returns (bytes memory) {
        return abi.encode(destAddress, payload);
    }

    /// @inheritdoc ICrossChainMessenger
    function quoteMessageFee(
        uint32 destinationChainId,
        bytes32 recipient,
        bytes calldata message
    )
        external
        view
        override
        returns (uint256)
    {
        // TODO: Implement fee estimation
        return 0;
    }

    /// @inheritdoc ICrossChainMessenger
    function sendMessage(
        uint32 destinationChainId,
        bytes32 recipient,
        bytes calldata message
    )
        external
        payable
        override
        returns (bytes32)
    {
        RouterConfig memory config = chainConfigs[destinationChainId];
        require(config.destGasLimit != 0, "Chain config not set");

        bytes memory metadata = getRequestMetadata(config);
        bytes memory packet = getRequestPacket(_bytes32ToAddress(recipient), message);

        uint256 requestId = gateway.iSend{ value: msg.value }(
            gateway.currentVersion(),
            0, // No ROUTE tokens
            "", // No ROUTE recipient
            _uint32ToString(destinationChainId),
            metadata,
            packet
        );

        // Convert requestId to bytes32 for compatibility with our interface
        return bytes32(requestId);
    }

    // Helper functions
    function _uint32ToString(uint32 value) internal pure returns (string memory) {
        if (value == 0) return "0";

        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }

        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }

        return string(buffer);
    }

    function _bytes32ToAddress(bytes32 _input) internal pure returns (string memory) {
        bytes memory alphabet = "0123456789abcdef";
        bytes memory str = new bytes(42);
        str[0] = "0";
        str[1] = "x";
        for (uint256 i = 0; i < 20; i++) {
            str[2 + i * 2] = alphabet[uint8(_input[i + 12] >> 4)];
            str[3 + i * 2] = alphabet[uint8(_input[i + 12] & 0x0f)];
        }
        return string(str);
    }
}
