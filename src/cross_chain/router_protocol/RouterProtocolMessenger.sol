// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { ICrossChainMessenger } from "../ICrossChainMessenger.sol";
import { IGateway } from "../../vendored/router_protocol/IGateway.sol";

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

/// @title RouterProtocolMessengerSetup
/// @dev Helper contract to setup the RouterProtocolMessenger with default configurations
contract RouterProtocolMessengerSetup {
    function setupArbitrumConfig(RouterProtocolMessenger messenger) external {
        RouterProtocolMessenger.RouterConfig memory config = RouterProtocolMessenger.RouterConfig({
            destGasLimit: 500_000, // Example gas limit
            destGasPrice: 0, // Let Router estimate
            ackGasLimit: 300_000, // Example ack gas limit
            ackGasPrice: 0, // Let Router estimate
            relayerFees: 25_000_000_000_000_000, // 0.025 ROUTE (minimum)
            ackType: 1, // Expect success acks
            isReadCall: false, // This is a write operation
            asmAddress: "" // No ASM module
         });

        messenger.setChainConfig(421_614, config); // Arbitrum Sepolia testnet
    }
}
