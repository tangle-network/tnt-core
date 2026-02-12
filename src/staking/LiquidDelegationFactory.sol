// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import { LiquidDelegationVault } from "./LiquidDelegationVault.sol";
import { IMultiAssetDelegation } from "../interfaces/IMultiAssetDelegation.sol";

/// @title LiquidDelegationFactory
/// @notice Factory for deploying ERC7540 liquid delegation vaults
/// @dev Creates one vault per (operator, asset, blueprintSelection) tuple
contract LiquidDelegationFactory is Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;

    // ═══════════════════════════════════════════════════════════════════════════
    // STATE
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice The underlying staking contract
    // forge-lint: disable-next-line(screaming-snake-case-immutable)
    IMultiAssetDelegation public immutable staking;

    /// @notice Mapping: vaultKey => vault address
    /// @dev vaultKey = keccak256(operator, asset, blueprintIds)
    mapping(bytes32 => address) public vaults;

    /// @notice All deployed vaults
    EnumerableSet.AddressSet private _allVaults;

    /// @notice Vaults by operator
    mapping(address => EnumerableSet.AddressSet) private _operatorVaults;

    /// @notice Vaults by asset
    mapping(address => EnumerableSet.AddressSet) private _assetVaults;

    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    event VaultCreated(
        address indexed vault,
        address indexed operator,
        address indexed asset,
        uint64[] blueprintIds,
        string name,
        string symbol
    );

    // ═══════════════════════════════════════════════════════════════════════════
    // ERRORS
    // ═══════════════════════════════════════════════════════════════════════════

    error VaultAlreadyExists();
    error OperatorNotActive();
    error AssetNotEnabled();

    // ═══════════════════════════════════════════════════════════════════════════
    // CONSTRUCTOR
    // ═══════════════════════════════════════════════════════════════════════════

    constructor(IMultiAssetDelegation _staking) Ownable(msg.sender) {
        staking = _staking;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // VAULT CREATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Create a new liquid delegation vault
    /// @param operator The operator to delegate to
    /// @param asset The underlying asset (address(0) for native via WETH)
    /// @param blueprintIds Blueprint IDs (empty for All mode)
    /// @return vault The newly created vault address
    function createVault(
        address operator,
        address asset,
        uint64[] calldata blueprintIds
    )
        external
        returns (address vault)
    {
        // Verify operator is active
        if (!staking.isOperatorActive(operator)) {
            revert OperatorNotActive();
        }

        // Compute vault key
        bytes32 vaultKey = computeVaultKey(operator, asset, blueprintIds);

        // Check vault doesn't exist
        if (vaults[vaultKey] != address(0)) {
            revert VaultAlreadyExists();
        }

        // Generate name and symbol
        (string memory name, string memory symbol) = _generateTokenMetadata(operator, asset, blueprintIds);

        // Deploy vault
        vault = address(new LiquidDelegationVault(staking, operator, IERC20(asset), blueprintIds, name, symbol));

        // Register vault
        vaults[vaultKey] = vault;
        _allVaults.add(vault);
        _operatorVaults[operator].add(vault);
        _assetVaults[asset].add(vault);

        emit VaultCreated(vault, operator, asset, blueprintIds, name, symbol);
    }

    /// @notice Create a vault for all blueprints (convenience function)
    function createAllBlueprintsVault(address operator, address asset) external returns (address vault) {
        return this.createVault(operator, asset, new uint64[](0));
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // VIEW FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Compute the vault key for a given configuration
    function computeVaultKey(
        address operator,
        address asset,
        uint64[] calldata blueprintIds
    )
        public
        pure
        returns (bytes32)
    {
        // forge-lint: disable-next-line(asm-keccak256)
        return keccak256(abi.encode(operator, asset, blueprintIds));
    }

    /// @notice Get vault for a specific configuration
    function getVault(address operator, address asset, uint64[] calldata blueprintIds) external view returns (address) {
        return vaults[computeVaultKey(operator, asset, blueprintIds)];
    }

    /// @notice Get all vaults for an operator
    function getOperatorVaults(address operator) external view returns (address[] memory) {
        uint256 length = _operatorVaults[operator].length();
        address[] memory result = new address[](length);
        for (uint256 i = 0; i < length; i++) {
            result[i] = _operatorVaults[operator].at(i);
        }
        return result;
    }

    /// @notice Get all vaults for an asset
    function getAssetVaults(address asset) external view returns (address[] memory) {
        uint256 length = _assetVaults[asset].length();
        address[] memory result = new address[](length);
        for (uint256 i = 0; i < length; i++) {
            result[i] = _assetVaults[asset].at(i);
        }
        return result;
    }

    /// @notice Get all deployed vaults
    function getAllVaults() external view returns (address[] memory) {
        uint256 length = _allVaults.length();
        address[] memory result = new address[](length);
        for (uint256 i = 0; i < length; i++) {
            result[i] = _allVaults.at(i);
        }
        return result;
    }

    /// @notice Get total number of vaults
    function vaultCount() external view returns (uint256) {
        return _allVaults.length();
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // INTERNAL HELPERS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Generate token name and symbol for a vault
    function _generateTokenMetadata(
        address operator,
        address asset,
        uint64[] calldata blueprintIds
    )
        internal
        view
        returns (string memory name, string memory symbol)
    {
        // Get operator short address (last 4 bytes)
        bytes memory opBytes = abi.encodePacked(operator);
        string memory opShort = _toHexString(opBytes, 18, 20); // Last 2 bytes = 4 hex chars

        // Get asset symbol
        string memory assetSymbol;
        if (asset == address(0)) {
            assetSymbol = "ETH";
        } else {
            // Try to get symbol from ERC20
            try IERC20Metadata(asset).symbol() returns (string memory s) {
                assetSymbol = s;
            } catch {
                assetSymbol = "TKN";
            }
        }

        // Build blueprint suffix
        string memory bpSuffix;
        if (blueprintIds.length == 0) {
            bpSuffix = "All";
        } else if (blueprintIds.length == 1) {
            bpSuffix = string(abi.encodePacked("BP", _uint64ToString(blueprintIds[0])));
        } else {
            bpSuffix = string(abi.encodePacked("BP", _uint64ToString(blueprintIds[0]), "+"));
        }

        // Generate name: "Liquid Delegation ETH Op-0x1234 All"
        name = string(abi.encodePacked("Liquid Delegation ", assetSymbol, " Op-0x", opShort, " ", bpSuffix));

        // Generate symbol: "ldETH-0x1234-All"
        symbol = string(abi.encodePacked("ld", assetSymbol, "-0x", opShort, "-", bpSuffix));
    }

    /// @notice Convert bytes to hex string (partial)
    function _toHexString(bytes memory data, uint256 start, uint256 end) internal pure returns (string memory) {
        bytes memory alphabet = "0123456789abcdef";
        bytes memory str = new bytes((end - start) * 2);

        for (uint256 i = start; i < end; i++) {
            str[(i - start) * 2] = alphabet[uint8(data[i] >> 4)];
            str[(i - start) * 2 + 1] = alphabet[uint8(data[i] & 0x0f)];
        }

        return string(str);
    }

    /// @notice Convert uint64 to string
    function _uint64ToString(uint64 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }

        uint64 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }

        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits--;
            // forge-lint: disable-next-line(unsafe-typecast)
            buffer[digits] = bytes1(uint8(48 + value % 10));
            value /= 10;
        }

        return string(buffer);
    }
}

/// @notice Interface for ERC20 metadata
interface IERC20Metadata {
    function symbol() external view returns (string memory);
}
