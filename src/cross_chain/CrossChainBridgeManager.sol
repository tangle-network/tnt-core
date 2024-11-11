// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { Ownable, RootChainEnabled } from "../Permissions.sol";
import { ICrossChainMessenger } from "../interfaces/ICrossChainMessenger.sol";
import { ICrossChainBridgeManager } from "../interfaces/ICrossChainBridgeManager.sol";

/**
 * @title CrossChainBridgeManager
 * @dev Central manager for cross-chain bridge configurations and message dispatch
 */
contract CrossChainBridgeManager is ICrossChainBridgeManager, Ownable, RootChainEnabled {
    // Mapping of bridge ID to bridge configuration
    mapping(uint256 => BridgeConfig) public bridges;

    // Mapping of bridge ID to chain configurations
    mapping(uint256 => ChainConfig[]) public bridgeChains;

    // Mapping of authorized blueprint contracts
    mapping(address => bool) public authorizedBlueprints;

    modifier onlyAuthorizedBlueprint() {
        require(authorizedBlueprints[msg.sender], "Unauthorized blueprint");
        _;
    }

    modifier onlyOwnerOrRootChain() {
        require(msg.sender == owner() || msg.sender == rootChainOrigin(), "Unauthorized");
        _;
    }

    /**
     * @dev Authorize a blueprint contract to use the bridge manager
     */
    function authorizeBlueprint(address blueprint) external onlyOwnerOrRootChain {
        require(blueprint != address(0), "Invalid blueprint address");
        authorizedBlueprints[blueprint] = true;
        emit BlueprintAuthorized(blueprint);
    }

    /**
     * @dev Deauthorize a blueprint contract
     */
    function deauthorizeBlueprint(address blueprint) external onlyOwnerOrRootChain {
        authorizedBlueprints[blueprint] = false;
        emit BlueprintDeauthorized(blueprint);
    }

    /**
     * @dev Add a new bridge configuration
     */
    function addBridge(uint256 bridgeId, address messenger, string calldata bridgeName) external onlyOwnerOrRootChain {
        require(messenger != address(0), "Invalid messenger address");
        require(!bridges[bridgeId].isActive, "Bridge already exists");
        require(bytes(bridgeName).length > 0, "Bridge name required");

        bridges[bridgeId] = BridgeConfig({ messenger: ICrossChainMessenger(messenger), isActive: true, bridgeName: bridgeName });

        emit BridgeAdded(bridgeId, messenger, bridgeName);
    }

    /**
     * @dev Remove a bridge configuration
     */
    function removeBridge(uint256 bridgeId) external onlyOwnerOrRootChain {
        require(bridges[bridgeId].isActive, "Bridge not found");

        delete bridges[bridgeId];
        delete bridgeChains[bridgeId];

        emit BridgeRemoved(bridgeId);
    }

    /**
     * @dev Add a new chain configuration for a bridge
     */
    function addChain(
        uint256 bridgeId,
        uint32 chainId,
        bytes32 recipient,
        string calldata chainName
    )
        external
        onlyOwnerOrRootChain
    {
        require(bridges[bridgeId].isActive, "Bridge not found");
        require(recipient != bytes32(0), "Invalid recipient");
        require(bytes(chainName).length > 0, "Chain name required");

        ChainConfig[] storage chains = bridgeChains[bridgeId];
        for (uint256 i = 0; i < chains.length; i++) {
            require(chains[i].chainId != chainId, "Chain already exists");
        }

        chains.push(ChainConfig({ chainId: chainId, recipient: recipient, isActive: true, chainName: chainName }));

        emit ChainAdded(bridgeId, chainId, recipient, chainName);
    }

    /**
     * @dev Remove a chain configuration from a bridge
     */
    function removeChain(uint256 bridgeId, uint32 chainId) external onlyOwnerOrRootChain {
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
     * @dev Get all active bridges
     */
    function getActiveBridges() external view returns (uint256[] memory bridgeIds, string[] memory bridgeNames) {
        uint256 count = 0;
        for (uint256 i = 0; i < type(uint256).max; i++) {
            if (bridges[i].isActive) count++;
        }

        bridgeIds = new uint256[](count);
        bridgeNames = new string[](count);

        uint256 index = 0;
        for (uint256 i = 0; i < type(uint256).max; i++) {
            if (bridges[i].isActive) {
                bridgeIds[index] = i;
                bridgeNames[index] = bridges[i].bridgeName;
                index++;
            }
        }
    }

    /**
     * @dev Get all active chains for a bridge
     */
    function getActiveChainsForBridge(uint256 bridgeId)
        external
        view
        returns (uint32[] memory chainIds, string[] memory chainNames, bytes32[] memory recipients)
    {
        require(bridges[bridgeId].isActive, "Bridge not found");

        ChainConfig[] storage chains = bridgeChains[bridgeId];
        uint256 count = 0;
        for (uint256 i = 0; i < chains.length; i++) {
            if (chains[i].isActive) count++;
        }

        chainIds = new uint32[](count);
        chainNames = new string[](count);
        recipients = new bytes32[](count);

        uint256 index = 0;
        for (uint256 i = 0; i < chains.length; i++) {
            if (chains[i].isActive) {
                chainIds[index] = chains[i].chainId;
                chainNames[index] = chains[i].chainName;
                recipients[index] = chains[i].recipient;
                index++;
            }
        }
    }

    /**
     * @dev Dispatch a message to all configured bridges and chains
     */
    function dispatchMessage(bytes memory message) external payable onlyAuthorizedBlueprint {
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
                        emit MessageDispatched(msg.sender, bridgeId, chains[i].chainId, chains[i].recipient, messageId);
                    } catch Error(string memory reason) {
                        emit DispatchError(msg.sender, bridgeId, chains[i].chainId, reason);
                    }
                } catch Error(string memory reason) {
                    emit DispatchError(msg.sender, bridgeId, chains[i].chainId, reason);
                }
            }
        }
    }

    function get_bridges(uint256 bridgeId) external view override returns (BridgeConfig memory) {
        return bridges[bridgeId];
    }

    /**
     * @dev Function to receive ETH for bridge fees
     */
    receive() external payable { }
}
