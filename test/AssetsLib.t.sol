// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {Assets} from "../src/AssetsLib.sol";

contract AssetsLibTest is Test {
    // Test constants
    address constant TEST_ERC20_ADDRESS = address(0x1234567890123456789012345678901234567890);
    bytes32 constant TEST_ASSET_ID = bytes32(uint256(123));
    
    function setUp() public {
        // No setup required as we're testing a library
    }

    function testErc20AssetConversion() public {
        Assets.Asset memory asset = Assets.Asset({
            kind: Assets.Kind.Erc20,
            data: bytes32(uint256(uint160(TEST_ERC20_ADDRESS)))
        });

        address result = Assets.toAddress(asset);
        assertEq(result, TEST_ERC20_ADDRESS, "ERC20 address conversion failed");
    }

    function testCustomAssetConversion() public {
        Assets.Asset memory asset = Assets.Asset({
            kind: Assets.Kind.Custom,
            data: TEST_ASSET_ID
        });

        address result = Assets.toAddress(asset);
        assertTrue(Assets.isAssetIdCompatible(result), "Custom asset address should be compatible");
        assertEq(Assets.toAssetId(result), TEST_ASSET_ID, "Asset ID conversion failed");
    }

    function testAssetIdToAddressConversion() public {
        address result = Assets.toAddress(bytes32(uint256(0xAB))); // Using 0xAB as test value
        assertTrue(Assets.isAssetIdCompatible(result), "Result should be asset ID compatible");
        assertEq(result, 0xffffFfFF000000000000000000000000000000AB, "Asset ID to address conversion failed");
    }

    function testInvalidAssetIdReversion() public {
        address invalidAddress = address(0x1234567890123456789012345678901234567890);
        vm.expectRevert(abi.encodeWithSelector(Assets.InvalidAssetId.selector, invalidAddress));
        Assets.toAssetId(invalidAddress);
    }

    function testAssetTypeChecks() public {
        Assets.Asset memory erc20Asset = Assets.Asset({
            kind: Assets.Kind.Erc20,
            data: bytes32(uint256(uint160(TEST_ERC20_ADDRESS)))
        });

        Assets.Asset memory customAsset = Assets.Asset({
            kind: Assets.Kind.Custom,
            data: TEST_ASSET_ID
        });

        assertTrue(Assets.isErc20(erc20Asset), "Should be identified as ERC20");
        assertFalse(Assets.isErc20(customAsset), "Should not be identified as ERC20");
        assertTrue(Assets.isCustom(customAsset), "Should be identified as Custom");
        assertFalse(Assets.isCustom(erc20Asset), "Should not be identified as Custom");
    }

    function testToAssetConversion() public {
        // Test ERC20 address conversion
        Assets.Asset memory erc20Result = Assets.toAsset(TEST_ERC20_ADDRESS);
        assertTrue(Assets.isErc20(erc20Result), "Should convert to ERC20 asset");
        assertEq(address(uint160(uint256(erc20Result.data))), TEST_ERC20_ADDRESS, "ERC20 address mismatch");

        // Test Custom asset address conversion
        Assets.Asset memory customResult = Assets.toAsset(0xffffFfFF000000000000000000000000000000AB);
        assertTrue(Assets.isCustom(customResult), "Should convert to Custom asset");
        assertEq(customResult.data, bytes32(uint256(0xAB)), "Custom asset ID mismatch");
    }

    function testNativeAssetChecks() public {
        // Test native ERC20 (address(0))
        Assets.Asset memory nativeErc20 = Assets.Asset({
            kind: Assets.Kind.Erc20,
            data: bytes32(0)
        });
        assertTrue(Assets.isNative(nativeErc20), "Should identify native ERC20");

        // Test native Custom asset (id = 0)
        Assets.Asset memory nativeCustom = Assets.Asset({
            kind: Assets.Kind.Custom,
            data: bytes32(0)
        });
        assertTrue(Assets.isNative(nativeCustom), "Should identify native Custom asset");

        // Test non-native assets
        Assets.Asset memory nonNativeErc20 = Assets.Asset({
            kind: Assets.Kind.Erc20,
            data: bytes32(uint256(uint160(TEST_ERC20_ADDRESS)))
        });
        assertFalse(Assets.isNative(nonNativeErc20), "Should not identify as native ERC20");

        Assets.Asset memory nonNativeCustom = Assets.Asset({
            kind: Assets.Kind.Custom,
            data: TEST_ASSET_ID
        });
        assertFalse(Assets.isNative(nonNativeCustom), "Should not identify as native Custom asset");
    }
}
