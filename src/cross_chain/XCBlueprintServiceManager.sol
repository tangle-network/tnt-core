// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { BlueprintServiceManagerBase } from "../BlueprintServiceManagerBase.sol";
import { ICrossChainMessenger } from "./ICrossChainMessenger.sol";

/**
 * @title XCBlueprintServiceManager
 * @dev Cross-chain enabled BlueprintServiceManager that can dispatch messages across multiple bridges
 */
contract XCBlueprintServiceManager is BlueprintServiceManagerBase {
    struct BridgeConfig {
        ICrossChainMessenger messenger;
        bool isActive;
    }

    struct ChainConfig {
        uint32 chainId;
        bytes32 recipient;
        bool isActive;
    }

    // Mapping of bridge ID to bridge configuration
    mapping(uint256 => BridgeConfig) public bridges;

    // Mapping of bridge ID to chain configurations
    mapping(uint256 => ChainConfig[]) public bridgeChains;

    // Events
    event BridgeAdded(uint256 indexed bridgeId, address messenger);
    event BridgeRemoved(uint256 indexed bridgeId);
    event ChainAdded(uint256 indexed bridgeId, uint32 chainId, bytes32 recipient);
    event ChainRemoved(uint256 indexed bridgeId, uint32 chainId);
    event MessageDispatched(uint256 indexed bridgeId, uint32 indexed chainId, bytes32 recipient, bytes32 messageId);
    event DispatchError(uint256 indexed bridgeId, uint32 indexed chainId, string reason);

    /**
     * @dev Add a new bridge configuration
     */
    function addBridge(uint256 bridgeId, address messenger) external onlyFromRootChain {
        require(messenger != address(0), "Invalid messenger address");
        require(!bridges[bridgeId].isActive, "Bridge already exists");

        bridges[bridgeId] = BridgeConfig({ messenger: ICrossChainMessenger(messenger), isActive: true });

        emit BridgeAdded(bridgeId, messenger);
    }

    /**
     * @dev Remove a bridge configuration
     */
    function removeBridge(uint256 bridgeId) external onlyFromRootChain {
        require(bridges[bridgeId].isActive, "Bridge not found");

        delete bridges[bridgeId];
        delete bridgeChains[bridgeId];

        emit BridgeRemoved(bridgeId);
    }

    /**
     * @dev Add a new chain configuration for a bridge
     */
    function addChain(uint256 bridgeId, uint32 chainId, bytes32 recipient) external onlyFromRootChain {
        require(bridges[bridgeId].isActive, "Bridge not found");
        require(recipient != bytes32(0), "Invalid recipient");

        // Check if chain already exists
        ChainConfig[] storage chains = bridgeChains[bridgeId];
        for (uint256 i = 0; i < chains.length; i++) {
            require(chains[i].chainId != chainId, "Chain already exists");
        }

        chains.push(ChainConfig({ chainId: chainId, recipient: recipient, isActive: true }));

        emit ChainAdded(bridgeId, chainId, recipient);
    }

    /**
     * @dev Remove a chain configuration from a bridge
     */
    function removeChain(uint256 bridgeId, uint32 chainId) external onlyFromRootChain {
        ChainConfig[] storage chains = bridgeChains[bridgeId];

        for (uint256 i = 0; i < chains.length; i++) {
            if (chains[i].chainId == chainId) {
                chains[i] = chains[chains.length - 1];
                chains.pop();
                emit ChainRemoved(bridgeId, chainId);
                return;
            }
        }

        revert("Chain not found");
    }

    /**
     * @dev Internal function to dispatch a message to all configured bridges and chains
     */
    function _dispatchCrossChainMessage(bytes memory message) internal {
        // Iterate through all bridges
        for (uint256 bridgeId = 0; bridgeId < type(uint256).max; bridgeId++) {
            BridgeConfig storage bridge = bridges[bridgeId];
            if (!bridge.isActive) continue;

            // Get chains for this bridge
            ChainConfig[] storage chains = bridgeChains[bridgeId];

            // Dispatch to all chains for this bridge
            for (uint256 i = 0; i < chains.length; i++) {
                if (!chains[i].isActive) continue;

                try bridge.messenger.quoteMessageFee(chains[i].chainId, chains[i].recipient, message) returns (uint256 fee) {
                    try bridge.messenger.sendMessage{ value: fee }(chains[i].chainId, chains[i].recipient, message) returns (
                        bytes32 messageId
                    ) {
                        emit MessageDispatched(bridgeId, chains[i].chainId, chains[i].recipient, messageId);
                    } catch Error(string memory reason) {
                        emit DispatchError(bridgeId, chains[i].chainId, reason);
                    }
                } catch Error(string memory reason) {
                    emit DispatchError(bridgeId, chains[i].chainId, reason);
                }
            }
        }
    }

    /**
     * @dev Override of onSlash to dispatch slash events cross-chain
     */
    function onSlash(uint64 serviceId, bytes calldata offender, uint8 slashPercent, uint256 totalPayout) public virtual override {
        // Call parent implementation if needed
        super.onSlash(serviceId, offender, slashPercent, totalPayout);

        // Encode the slash event
        bytes memory message = abi.encodePacked(
            uint8(1), // SLASH_EVENT type
            abi.encode(serviceId, offender, slashPercent, totalPayout)
        );

        // Dispatch to all configured bridges and chains
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
        override
    {
        // Call parent implementation if needed
        super.onJobResult(serviceId, job, jobCallId, participant, inputs, outputs);

        // Encode the job result event
        bytes memory message = abi.encodePacked(
            uint8(2), // JOB_RESULT_EVENT type
            abi.encode(serviceId, job, jobCallId, participant, inputs, outputs)
        );

        // Dispatch to all configured bridges and chains
        _dispatchCrossChainMessage(message);
    }

    /**
     * @dev Function to receive ETH for bridge fees
     */
    receive() external payable { }
}
