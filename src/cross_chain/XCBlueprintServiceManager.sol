// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { BlueprintServiceManagerBase } from "../BlueprintServiceManagerBase.sol";
import { ICrossChainBridgeManager } from "../interfaces/ICrossChainBridgeManager.sol";

/**
 * @title XCBlueprintServiceManager
 * @dev Cross-chain enabled BlueprintServiceManager that dispatches messages through a bridge manager
 */
contract XCBlueprintServiceManager is BlueprintServiceManagerBase {
    ICrossChainBridgeManager public immutable bridgeManager;

    // Events for tracking message dispatches
    event CrossChainMessageDispatched(bytes message);
    event CrossChainDispatchFailed(string reason);

    constructor(address _bridgeManager) {
        require(_bridgeManager != address(0), "Invalid bridge manager");
        bridgeManager = ICrossChainBridgeManager(_bridgeManager);
    }

    /**
     * @dev Internal function to safely dispatch a cross-chain message
     * @param message The message to dispatch
     */
    function _dispatchCrossChainMessage(bytes memory message) internal {
        // Get the total fee required for all destinations
        uint256 totalFee = msg.value;

        try bridgeManager.dispatchMessage{ value: totalFee }(message) {
            emit CrossChainMessageDispatched(message);
        } catch Error(string memory reason) {
            emit CrossChainDispatchFailed(reason);
        } catch (bytes memory) {
            emit CrossChainDispatchFailed("Unknown error");
        }
    }

    /**
     * @dev Override of onSlash to dispatch slash events cross-chain
     */
    function onSlash(uint64 serviceId, bytes calldata offender, uint8 slashPercent, uint256 totalPayout) public virtual override {
        // Call parent implementation
        super.onSlash(serviceId, offender, slashPercent, totalPayout);

        // Encode the slash event
        bytes memory message = abi.encodePacked(
            uint8(1), // SLASH_EVENT type
            abi.encode(serviceId, offender, slashPercent, totalPayout)
        );

        // Dispatch via bridge manager
        _dispatchCrossChainMessage(message);
    }

    /**
     * @dev Override of onJobResult to dispatch job result events cross-chain
     */
    function onJobResult(
        uint64 serviceId,
        uint8 job,
        uint64 jobCallId,
        bytes calldata participant,
        bytes calldata inputs,
        bytes calldata outputs
    )
        public
        payable
        virtual
        override
    {
        // Call parent implementation
        super.onJobResult(serviceId, job, jobCallId, participant, inputs, outputs);

        // Encode the job result event
        bytes memory message = abi.encodePacked(
            uint8(2), // JOB_RESULT_EVENT type
            abi.encode(serviceId, job, jobCallId, participant, inputs, outputs)
        );

        // Dispatch via bridge manager
        _dispatchCrossChainMessage(message);
    }

    /**
     * @dev Function to receive ETH for bridge fees
     */
    receive() external payable { }

    /**
     * @dev Function to allow owner to withdraw any excess ETH
     */
    function withdrawTNT() external onlyOwnerOrRootChain {
        uint256 balance = address(this).balance;
        require(balance > 0, "No ETH to withdraw");

        (bool success,) = msg.sender.call{ value: balance }("");
        require(success, "ETH transfer failed");
    }
}
