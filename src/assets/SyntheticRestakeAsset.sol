// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { ERC20 } from "node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { ISyntheticRestakeAsset } from "../interfaces/ISyntheticRestakeAsset.sol";

/// @title SyntheticRestakeAsset
/// @notice ERC20 token representing a cross-chain restaking position
contract SyntheticRestakeAsset is ERC20, ISyntheticRestakeAsset {
    /// @notice Origin chain information
    uint32 public immutable originChainId;
    /// @notice Original asset address on origin chain
    uint256 public immutable originAsset;
    /// @notice Bridge used for cross-chain transfer
    uint256 public immutable bridgeId;
    /// @notice Vault that manages this synthetic asset
    address public immutable vault;

    /// @notice Creates a new synthetic asset
    /// @param _name Token name
    /// @param _symbol Token symbol
    /// @param _originChainId Chain ID where the original asset exists
    /// @param _originAsset Address of the original asset
    /// @param _bridgeId ID of the bridge used
    constructor(
        string memory _name,
        string memory _symbol,
        uint32 _originChainId,
        uint256 _originAsset,
        uint256 _bridgeId
    )
        ERC20(_name, _symbol)
    {
        originChainId = _originChainId;
        originAsset = _originAsset;
        bridgeId = _bridgeId;
        vault = msg.sender;
    }

    /// @notice Mints new tokens (only callable by vault)
    /// @param to Recipient of the minted tokens
    /// @param amount Amount to mint
    function mint(address to, uint256 amount) external {
        require(msg.sender == vault, "Only vault can mint");
        _mint(to, amount);
    }

    /// @notice Burns tokens (only callable by vault)
    /// @param from Address to burn from
    /// @param amount Amount to burn
    function burn(address from, uint256 amount) external {
        require(msg.sender == vault, "Only vault can burn");
        _burn(from, amount);
    }
}
