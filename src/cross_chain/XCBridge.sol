// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import { IMessageHelper } from "./helpers/IMessageHelper.sol";
import { RootChainEnabledOwnable } from "../Permissions.sol";

abstract contract XCBridge is RootChainEnabledOwnable {
    error RouterNotAuthorized();

    mapping(address => bool) public authorizedRouters;
    mapping(address => address) public routerHandlers;
    mapping(uint256 => address) public dispatchers;
    mapping(address => bool) public initialized;

    receive() external payable { }

    /// @notice Function to allow owner to withdraw any excess ETH
    function withdrawETH() external onlyOwnerOrRootChain {
        uint256 balance = address(this).balance;
        require(balance > 0, "No ETH to withdraw");

        (bool success,) = msg.sender.call{ value: balance }("");
        require(success, "ETH transfer failed");
    }

    function _initialize(address _helper) internal {
        if (!initialized[_helper]) {
            (bool success, bytes memory data) = _helper.delegatecall(abi.encodeWithSelector(IMessageHelper.initialize.selector));
            if (!success) {
                assembly {
                    revert(add(data, 32), mload(data))
                }
            }
            initialized[_helper] = true;
        }
    }

    function addDispatchers(address[] calldata _dispatchers, uint256[] calldata _bridgeIds) external onlyOwner {
        for (uint256 i = 0; i < _dispatchers.length;) {
            dispatchers[_bridgeIds[i]] = _dispatchers[i];
            _initialize(_dispatchers[i]);
            unchecked {
                ++i;
            }
        }
    }

    function removeDispatchers(uint256[] calldata _bridgeIds) external onlyOwner {
        for (uint256 i = 0; i < _bridgeIds.length;) {
            delete dispatchers[_bridgeIds[i]];
            unchecked {
                ++i;
            }
        }
    }

    function addRouters(address[] calldata _routers, address[] calldata _implementations) external onlyOwner {
        for (uint256 i = 0; i < _routers.length;) {
            _initialize(_implementations[i]);
            authorizedRouters[_routers[i]] = true;
            routerHandlers[_routers[i]] = _implementations[i];
            unchecked {
                ++i;
            }
        }
    }

    function removeRouters(address[] calldata _routers) external onlyOwner {
        for (uint256 i = 0; i < _routers.length;) {
            authorizedRouters[_routers[i]] = false;
            routerHandlers[_routers[i]] = address(0);
            unchecked {
                ++i;
            }
        }
    }

    function _sendMessage(bytes memory message, uint256 _bridgeId) internal {
        (bool success, bytes memory data) =
            dispatchers[_bridgeId].delegatecall(abi.encodeWithSelector(IMessageHelper.sendMessage.selector, message, _bridgeId));
        if (!success) {
            assembly {
                revert(add(data, 32), mload(data))
            }
        }
    }

    function _receiveMessage(
        address _sender,
        bytes calldata _message,
        function(bytes32,uint8) internal callback
    )
        internal
    {
        if (!authorizedRouters[_sender]) {
            revert RouterNotAuthorized();
        }

        (bool success, bytes memory data) =
            routerHandlers[_sender].delegatecall(abi.encodeWithSelector(IMessageHelper.parseMessage.selector, _message));

        if (!success) {
            assembly {
                revert(add(data, 32), mload(data))
            }
        }

        (bytes32[] memory operators, uint8[] memory slashPercents) =
            abi.decode(data, (bytes32[], uint8[]));

        for (uint256 i = 0; i < operators.length;) {
            callback(operators[i], slashPercents[i]);
            unchecked {
                ++i;
            }
        }
    }

    function _receiveMessage(
        address _sender,
        bytes calldata _message,
        function(uint256,bytes32,bytes calldata) internal callback
    )
        internal
    {
        if (!authorizedRouters[_sender]) {
            revert RouterNotAuthorized();
        }

        (bool success, bytes memory data) =
            routerHandlers[_sender].delegatecall(abi.encodeWithSelector(IMessageHelper.parseMessage.selector, _message));

        if (!success) {
            assembly {
                revert(add(data, 32), mload(data))
            }
        }

        (uint256 fromChainId, bytes32 fromAddress, uint256 start, uint256 end) =
            abi.decode(data, (uint256, bytes32, uint256, uint256));

        callback(fromChainId, fromAddress, _message[start:end]);
    }
}
