// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import { GlacisAccessControlClient, IGlacisClient } from "glacis-contracts/client/GlacisClient.sol";

contract GlacisClientCalldata is GlacisAccessControlClient, IGlacisClient {

    error GlacisClient__CanOnlyBeCalledByRouter();
    error GlacisClient__InvalidRouterAddress();

    event GlacisClient__MessageRouted(
        bytes32 indexed messageId,
        uint256 toChainId,
        bytes32 to
    );
    
    event GlacisClient__MessageArrived(
        address[] fromAdapters,
        uint256 fromChainId,
        bytes32 fromAddress
    );

    address public immutable GLACIS_ROUTER;

    constructor(
        address _glacisRouter,
        uint256 _quorum
    ) GlacisAccessControlClient() IGlacisClient(_quorum) {
        if (_glacisRouter == address(0))
            revert GlacisClient__InvalidRouterAddress();
        GLACIS_ROUTER = _glacisRouter;
    }

    /// @notice Receives message from GMP(s) through GlacisRouter
    /// @param fromAdapters addresses of the adapters sent this message (that reached quorum requirements)
    /// @param fromChainId Source chain (Glacis chain ID)
    /// @param fromAddress Source address on source chain
    /// @param payload Routed payload
    function receiveMessage(
        address[] memory fromAdapters,
        uint256 fromChainId,
        bytes32 fromAddress,
        bytes calldata payload
    ) external override {
        if (msg.sender != GLACIS_ROUTER)
            revert GlacisClient__CanOnlyBeCalledByRouter();
        _receiveMessage(fromAdapters, fromChainId, fromAddress, payload);
        emit GlacisClient__MessageArrived(fromAdapters, fromChainId, fromAddress);
    }

    function _receiveMessage(
        address[] memory fromAdapters,
        uint256 fromChainId,
        bytes32 fromAddress,
        bytes calldata payload
    ) internal virtual {}
}
