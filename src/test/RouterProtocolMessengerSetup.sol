// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { RouterProtocolMessenger } from "../cross_chain/router_protocol/RouterProtocolMessenger.sol";

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
