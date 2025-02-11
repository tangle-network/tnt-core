// // SPDX-License-Identifier: UNLICENSED
// pragma solidity ^0.8.18;

// import {
//     GlacisMockSetup,
//     GlacisCommons,
//     GlacisRouter,
//     GlacisLayerZeroV2Adapter,
//     GlacisHyperlaneAdapter
// } from "glacis-test/GlacisMockSetup.sol";
// import { MasterVault } from "../../assets/MasterVault.sol";
// import { RemoteRestakeVault } from "../../assets/RemoteRestakeVault.sol";
// import { SyntheticRestakeAsset } from "../../assets/SyntheticRestakeAsset.sol";
// import { RemoteChainBridgeManager } from "../../cross_chain/RemoteChainBridgeManager.sol";
// import { XCBlueprintServiceManager } from "../../cross_chain/XCBlueprintServiceManager.sol";

// contract LocalTestSetup {
//     address public constant TANGLE_SIDE = address(0x1337);
//     address public constant XC_EVM_SIDE = address(0x9999);

//     struct GlacisConfig {
//         GlacisRouter glacisRouter;
//         GlacisLayerZeroV2Adapter LZAdapter;
//         address LAYERZERO_GMP_ID;
//         GlacisHyperlaneAdapter hyperlaneAdapter;
//         address HYPERLANE_GMP_ID;
//     }

//     struct XCConfig {
//         MasterVault masterVault;
//         RemoteRestakeVault remoteRestakeVault;
//         SyntheticRestakeAsset syntheticRestakeAsset;
//         RemoteChainBridgeManager remoteChainBridgeManagerTangle;
//         RemoteChainBridgeManager remoteChainBridgeManagerXC;
//         XCBlueprintServiceManager xcBlueprintServiceManager;
//     }

//     struct Config {
//         GlacisConfig glacisConfig;
//         XCConfig xcConfig;
//     }

//     function setup() internal returns (Config memory config) {
//         GlacisMockSetup mock = new GlacisMockSetup();
//         config.glacisConfig.glacisRouter = mock.glacisRouter();
//         config.glacisConfig.LZAdapter = mock.setupLayerZero();
//         config.glacisConfig.hyperlaneAdapter = mock.setupHyperlane();
//         config.glacisConfig.LAYERZERO_GMP_ID = mock.LAYERZERO_GMP_ID();
//         config.glacisConfig.HYPERLANE_GMP_ID = mock.HYPERLANE_GMP_ID();
//         config.xcConfig.remoteChainBridgeManagerTangle = setupRemoteChainBridgeManager(
//             address(config.glacisConfig.glacisRouter), 0, bytes32(uint256(uint160(XC_EVM_SIDE))), address(this), block.chainid
//         );
//         config.xcConfig.remoteChainBridgeManagerXC = setupRemoteChainBridgeManager(
//             address(config.glacisConfig.glacisRouter), 0, bytes32(uint256(uint160(TANGLE_SIDE))), address(this), block.chainid
//         );
//         config.xcConfig.masterVault =
//             setupMasterVault(address(config.xcConfig.remoteChainBridgeManagerTangle), address(config.glacisConfig.glacisRouter), 1);
//         config.xcConfig.xcBlueprintServiceManager = setupXCBlueprintServiceManager(address(this));

//         config.xcConfig.remoteRestakeVault = setupRemoteRestakeVault(address(config.xcConfig.remoteChainBridgeManagerXC));
//     }

//     function createFees(GlacisCommons.CrossChainGas[] storage fees, uint256 amount, uint256 size) internal {
//         for (uint256 i; i < size; ++i) {
//             fees.push(GlacisCommons.CrossChainGas({ gasLimit: 0, nativeCurrencyValue: uint128(amount) }));
//         }
//     }

//     function setupMasterVault(address _bridgeManager, address _glacisRouter, uint256 _quorum) internal returns (MasterVault) {
//         return new MasterVault(_bridgeManager, _glacisRouter, _quorum);
//     }

//     function setupRemoteRestakeVault(address _bridgeManager) internal returns (RemoteRestakeVault) {
//         return new RemoteRestakeVault(_bridgeManager);
//     }

//     function setupRemoteChainBridgeManager(
//         address _glacisRouter,
//         uint256 _quorum,
//         bytes32 _receiver,
//         address _refundAddress,
//         uint256 _tangleChainId
//     )
//         internal
//         returns (RemoteChainBridgeManager)
//     {
//         return new RemoteChainBridgeManager(_glacisRouter, _quorum, _receiver, _refundAddress, _tangleChainId);
//     }

//     function setupXCBlueprintServiceManager(address _bridgeManager) internal returns (XCBlueprintServiceManager) {
//         return new XCBlueprintServiceManager(_bridgeManager);
//     }
// }
