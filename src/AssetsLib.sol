// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

/// @title Assets Library
/// @notice A library for handling asset types and conversions in a blockchain system
/// @dev Provides utilities for managing different asset types and converting between asset IDs and addresses
library Assets {
    /// @dev Represents different types of assets that can be used in the system
    enum Kind {
        /// @notice Custom Asset Id
        Custom,
        /// @notice Standard ERC20 token asset type
        Erc20
    }

    /// @dev Represents an asset with its type and associated data
    struct Asset {
        /// @notice The kind/type of the asset (Custom or ERC20)
        Kind kind;
        /// @notice The data associated with the asset, encoded as bytes32
        /// @dev The data is encoded as follows:
        /// - For Custom assets: The asset ID is stored as uint256
        /// - For ERC20 assets: The token address is stored as address
        bytes32 data;
    }

    /// @dev The asset kind is not supported by the library.
    error UnsupportedAssetKind(uint256 kind);

    /// @dev The supplied address is not a valid asset address, it does not start with 0xFFFFFFFF.
    error InvalidAssetId(address assetAddress);

    /// @notice Converts a given asset to its corresponding address representation.
    /// @dev The conversion follows the pattern: 0xFFFFFFFF followed by the 16-byte asset ID or if the asset is an ERC20
    /// token,
    /// the address of the token contract.
    ///
    /// @param asset The asset be converted.
    /// @return The address representation of the asset.
    function toAddress(Asset memory asset) internal pure returns (address) {
        if (isErc20(asset)) {
            return address(uint160(uint256(asset.data)));
        } else if (isCustom(asset)) {
            return toAddress(asset.data);
        } else {
            revert UnsupportedAssetKind(uint256(asset.kind));
        }
    }

    /// @notice Converts a given asset ID to its corresponding address representation.
    /// @dev The conversion follows the pattern: 0xFFFFFFFF followed by the 16-byte asset ID.
    ///
    /// @param assetId The bytes32 asset ID to be converted.
    /// @return The address representation of the asset ID.
    function toAddress(bytes32 assetId) internal pure returns (address) {
        // Construct the address by combining the prefix 0xFFFFFFFF00000000000000000000000000000000
        // with the lower 16 bytes of the assetId.
        // This ensures the address follows the designated asset address format.
        return address(uint160(uint256(0xFFFFFFFF << 128) | uint256(assetId)));
    }

    /// @notice Converts an asset address back to its original asset ID.
    /// @dev Validates that the address starts with the prefix 0xFFFFFFFF and extracts the 16-byte asset ID.
    ///
    /// @param assetAddress The address to be converted back to an asset ID.
    /// @return The bytes32 representation of the original asset ID.
    function toAssetId(address assetAddress) internal pure returns (bytes32) {
        // Convert the address to a uint256 for bit manipulation.
        uint256 addr = uint256(uint160(assetAddress));

        // Ensure the upper 128 bits match the expected prefix 0xFFFFFFFF.
        if (!isAssetIdCompatible(assetAddress)) {
            revert InvalidAssetId(assetAddress);
        }

        // Extract the lower 128 bits which represent the original asset ID.
        uint128 assetIdUint = uint128(addr);

        // Convert the uint128 asset ID back to bytes32 format.
        return bytes32(uint256(assetIdUint));
    }

    /// @notice Converts an asset address to an asset representation.
    /// @dev Converts the asset address to an asset ID and constructs an asset object.
    /// @param assetAddress The address of the asset to convert.
    /// @return Asset Returns the asset representation of the provided address.
    function toAsset(address assetAddress) internal pure returns (Asset memory) {
        if (isAssetIdCompatible(assetAddress)) {
            return Asset(Kind.Custom, toAssetId(assetAddress));
        } else {
            return Asset(Kind.Erc20, bytes32(uint256(uint160(assetAddress))));
        }
    }

    /// @notice Determines if the provided asset is an ERC20 token.
    /// @dev Checks if the asset kind matches the ERC20 enum value.
    /// @param asset The asset to check.
    /// @return bool Returns true if the asset is an ERC20 token, false otherwise.
    function isErc20(Asset memory asset) internal pure returns (bool) {
        return asset.kind == Kind.Erc20;
    }

    /// @notice Checks i the given asset is a Cstom type.
    /// @dev Verifies if the asset's kid property mathes he Custom type.
    /// @param asset The asset to check, defned by its kind and data.
    /// @return bool Returns true if the asset is Custom, false otherwise.
    function isCustom(Asset memory asset) internal pure returns (bool) {
        return asset.kind == Kind.Custom;
    }

    /// @notice Checks if the given asset address is compatible by verifying it starts with the prefix 0xFFFFFFFF.
    /// @dev This function converts the asset address to a uint256 and ensures the upper 128 bits match 0xFFFFFFFF.
    /// @param assetAddress The address of the asset to check for compatibility.
    /// @return bool Returns true if the asset address is compatible, false otherwise.
    function isAssetIdCompatible(address assetAddress) internal pure returns (bool) {
        // Convert the address to a uint256 for bit manipulation.
        uint256 addr = uint256(uint160(assetAddress));

        // Ensure the upper 128 bits match the expected prefix 0xFFFFFFFF.
        if ((addr >> 128) != 0xFFFFFFFF) {
            return false;
        }

        return true;
    }

    /// @notice Determines if the provided asset is a native asset.
    /// @dev This function checks the asset kind and verifies if the asset address or ID corresponds to a native asset.
    /// @param asset The asset to be checked, defined by its kind and data.
    /// @return bool Returns true if the asset is native, false otherwise.
    function isNative(Asset memory asset) internal pure returns (bool) {
        if (isErc20(asset)) {
            address assetAddress = address(uint160(uint256(asset.data)));
            return (assetAddress == address(0));
        } else if (isCustom(asset)) {
            uint256 assetId = uint256(asset.data);
            return (assetId == 0);
        } else {
            return false;
        }
    }
}
