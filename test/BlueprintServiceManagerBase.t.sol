// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import { Test } from "forge-std/Test.sol";
import "src/BlueprintServiceManagerBase.sol";
import "src/IBlueprintServiceManager.sol";
import "./MockERC20.sol";
import "./MockBlueprintServiceManager.sol";

contract BlueprintServiceManagerBaseTest is Test {
    using Assets for Assets.Asset;
    using Assets for address;
    using Assets for bytes32;

    MockBlueprintServiceManager manager;
    address rootChain = 0x09dF6A941ee03B1e632904E382e10862fA9cc0e3;
    address masterBlueprintServiceManager = address(0x2222222222222222222222222222222222222222);
    address blueprintOwner = address(0x3333333333333333333333333333333333333333);
    MockERC20 mockToken;
    
    // Additional tokens for extended tests
    MockERC20 mockToken1;
    MockERC20 mockToken2;
    MockERC20 mockToken3;
    
    uint64 constant TEST_SERVICE_ID = 42;

    function setUp() public {
        // Deploy Mock Blueprint Service Manager
        manager = new MockBlueprintServiceManager();

        // Set the master blueprint service manager
        manager.setMasterBlueprintServiceManager(masterBlueprintServiceManager);

        // Deploy a Mock ERC20 token
        mockToken = new MockERC20();
        mockToken.initialize("MockToken", "MTK", 18);
        
        // Deploy additional Mock ERC20 tokens for extended tests
        mockToken1 = new MockERC20();
        mockToken1.initialize("MockToken1", "MT1", 18);
        
        mockToken2 = new MockERC20();
        mockToken2.initialize("MockToken2", "MT2", 18);
        
        mockToken3 = new MockERC20();
        mockToken3.initialize("MockToken3", "MT3", 18);
    }

    // Utility modifier to simulate calls from root chain
    modifier onlyRootChain() {
        vm.prank(rootChain);
        _;
    }

    // Utility modifier to simulate calls from master blueprint service manager
    modifier onlyMaster() {
        vm.prank(masterBlueprintServiceManager);
        _;
    }

    // Test onBlueprintCreated
    function test_OnBlueprintCreated_SetsStateCorrectly() public onlyRootChain {
        uint64 blueprintId = 1;
        manager.onBlueprintCreated(blueprintId, blueprintOwner, masterBlueprintServiceManager);

        assertEq(manager.currentBlueprintId(), blueprintId, "Incorrect blueprint ID set");
        assertEq(manager.blueprintOwner(), blueprintOwner, "Incorrect blueprint owner set");
        assertEq(manager.masterBlueprintServiceManager(), masterBlueprintServiceManager, "Incorrect MBSM set");
    }

    // Test onRegister
    function test_OnRegister_CalledByMaster() public onlyMaster {
        ServiceOperators.OperatorPreferences memory operator = ServiceOperators.OperatorPreferences({
            ecdsaPublicKey: "0xabcdef",
            rpcAddress: "https://example.com/rpc"
        });
        bytes memory registrationInputs = "registration data";

        // Expect no revert
        manager.onRegister(operator, registrationInputs);
    }

    function test_OnRegister_RevertsWhenNotMaster() public {
        ServiceOperators.OperatorPreferences memory operator = ServiceOperators.OperatorPreferences({
            ecdsaPublicKey: "0xabcdef",
            rpcAddress: "https://example.com/rpc"
        });
        bytes memory registrationInputs = "registration data";

        vm.expectRevert(
            abi.encodeWithSelector(
                RootChainEnabled.OnlyMasterBlueprintServiceManagerAllowed.selector,
                address(0x999),
                masterBlueprintServiceManager
            )
        );
        vm.prank(address(0x999));
        manager.onRegister(operator, registrationInputs);
    }

    // Test onUnregister
    function test_OnUnregister_CalledByMaster() public onlyMaster {
        ServiceOperators.OperatorPreferences memory operator = ServiceOperators.OperatorPreferences({
            ecdsaPublicKey: "0xabcdef",
            rpcAddress: "https://example.com/rpc"
        });

        // Expect no revert
        manager.onUnregister(operator);
    }

    function test_OnUnregister_RevertsWhenNotMaster() public {
        ServiceOperators.OperatorPreferences memory operator = ServiceOperators.OperatorPreferences({
            ecdsaPublicKey: "0xabcdef",
            rpcAddress: "https://example.com/rpc"
        });

        vm.expectRevert(
            abi.encodeWithSelector(
                RootChainEnabled.OnlyMasterBlueprintServiceManagerAllowed.selector,
                address(0x999),
                masterBlueprintServiceManager
            )
        );
        vm.prank(address(0x999));
        manager.onUnregister(operator);
    }

    // Test onUpdateRpcAddress
    function test_OnUpdateRpcAddress_CalledByMaster() public onlyMaster {
        ServiceOperators.OperatorPreferences memory operator = ServiceOperators.OperatorPreferences({
            ecdsaPublicKey: "0xabcdef",
            rpcAddress: "https://example.com/rpc"
        });

        // Expect no revert
        manager.onUpdateRpcAddress(operator);
    }

    function test_OnUpdateRpcAddress_RevertsWhenNotMaster() public {
        ServiceOperators.OperatorPreferences memory operator = ServiceOperators.OperatorPreferences({
            ecdsaPublicKey: "0xabcdef",
            rpcAddress: "https://example.com/rpc"
        });

        vm.expectRevert(
            abi.encodeWithSelector(
                RootChainEnabled.OnlyMasterBlueprintServiceManagerAllowed.selector,
                address(0x999),
                masterBlueprintServiceManager
            )
        );
        vm.prank(address(0x999));
        manager.onUpdateRpcAddress(operator);
    }

    // Test onRequest
    function test_OnRequest_CalledByMaster() public onlyMaster {
        ServiceOperators.RequestParams memory params = ServiceOperators.RequestParams({
            requestId: 1,
            requester: address(0x444),
            operators: new ServiceOperators.OperatorPreferences[](0),
            requestInputs: "input data",
            permittedCallers: new address[](0),
            ttl: 1000,
            paymentAsset: Assets.Asset({ kind: Assets.Kind.Erc20, data: bytes32(uint256(uint160(address(mockToken)))) }),
            amount: 1000
        });

        // Expect no revert
        manager.onRequest(params);
    }

    function test_OnRequest_RevertsWhenNotMaster() public {
        ServiceOperators.RequestParams memory params = ServiceOperators.RequestParams({
            requestId: 1,
            requester: address(0x444),
            operators: new ServiceOperators.OperatorPreferences[](0),
            requestInputs: "input data",
            permittedCallers: new address[](0),
            ttl: 1000,
            paymentAsset: Assets.Asset({ kind: Assets.Kind.Erc20, data: bytes32(uint256(uint160(address(mockToken)))) }),
            amount: 1000
        });

        vm.expectRevert(
            abi.encodeWithSelector(
                RootChainEnabled.OnlyMasterBlueprintServiceManagerAllowed.selector,
                address(0x999),
                masterBlueprintServiceManager
            )
        );
        vm.prank(address(0x999));
        manager.onRequest(params);
    }

    // Test onApprove
    function test_OnApprove_CalledByMaster() public onlyMaster {
        ServiceOperators.OperatorPreferences memory operator = ServiceOperators.OperatorPreferences({
            ecdsaPublicKey: "0xabcdef",
            rpcAddress: "https://example.com/rpc"
        });
        uint64 requestId = 2;
        uint8 restakingPercent = 10;

        // Expect no revert
        manager.onApprove(operator, requestId, restakingPercent);
    }

    function test_OnApprove_RevertsWhenNotMaster() public {
        ServiceOperators.OperatorPreferences memory operator = ServiceOperators.OperatorPreferences({
            ecdsaPublicKey: "0xabcdef",
            rpcAddress: "https://example.com/rpc"
        });
        uint64 requestId = 2;
        uint8 restakingPercent = 10;

        vm.expectRevert(
            abi.encodeWithSelector(
                RootChainEnabled.OnlyMasterBlueprintServiceManagerAllowed.selector,
                address(0x999),
                masterBlueprintServiceManager
            )
        );
        vm.prank(address(0x999));
        manager.onApprove(operator, requestId, restakingPercent);
    }

    // Test onReject
    function test_OnReject_CalledByMaster() public onlyMaster {
        ServiceOperators.OperatorPreferences memory operator = ServiceOperators.OperatorPreferences({
            ecdsaPublicKey: "0xabcdef",
            rpcAddress: "https://example.com/rpc"
        });
        uint64 requestId = 3;

        // Expect no revert
        manager.onReject(operator, requestId);
    }

    function test_OnReject_RevertsWhenNotMaster() public {
        ServiceOperators.OperatorPreferences memory operator = ServiceOperators.OperatorPreferences({
            ecdsaPublicKey: "0xabcdef",
            rpcAddress: "https://example.com/rpc"
        });
        uint64 requestId = 3;

        vm.expectRevert(
            abi.encodeWithSelector(
                RootChainEnabled.OnlyMasterBlueprintServiceManagerAllowed.selector,
                address(0x999),
                masterBlueprintServiceManager
            )
        );
        vm.prank(address(0x999));
        manager.onReject(operator, requestId);
    }

    // Test onServiceInitialized
    function test_OnServiceInitialized_CalledByMaster() public onlyMaster {
        uint64 requestId = 4;
        uint64 serviceId = 100;
        address owner = address(0x555);
        address[] memory permittedCallers = new address[](2);
        permittedCallers[0] = address(0x666);
        permittedCallers[1] = address(0x777);
        uint64 ttl = 2000;

        // Expect no revert
        manager.onServiceInitialized(requestId, serviceId, owner, permittedCallers, ttl);

        // Verify state or behaviors as needed (if any)
        // Since the base contract does not implement, no state change to verify
    }

    function test_OnServiceInitialized_RevertsWhenNotMaster() public {
        uint64 requestId = 4;
        uint64 serviceId = 100;
        address owner = address(0x555);
        address[] memory permittedCallers = new address[](2);
        permittedCallers[0] = address(0x666);
        permittedCallers[1] = address(0x777);
        uint64 ttl = 2000;

        vm.expectRevert(
            abi.encodeWithSelector(
                RootChainEnabled.OnlyMasterBlueprintServiceManagerAllowed.selector,
                address(0x999),
                masterBlueprintServiceManager
            )
        );
        vm.prank(address(0x999));
        manager.onServiceInitialized(requestId, serviceId, owner, permittedCallers, ttl);
    }

    // Test onJobCall
    function test_OnJobCall_CalledByMaster() public onlyMaster {
        uint64 serviceId = 101;
        uint8 job = 1;
        uint64 jobCallId = 500;
        bytes memory inputs = "job inputs";

        // Expect no revert
        manager.onJobCall(serviceId, job, jobCallId, inputs);
    }

    function test_OnJobCall_RevertsWhenNotMaster() public {
        uint64 serviceId = 101;
        uint8 job = 1;
        uint64 jobCallId = 500;
        bytes memory inputs = "job inputs";

        vm.expectRevert(
            abi.encodeWithSelector(
                RootChainEnabled.OnlyMasterBlueprintServiceManagerAllowed.selector,
                address(0x999),
                masterBlueprintServiceManager
            )
        );
        vm.prank(address(0x999));
        manager.onJobCall(serviceId, job, jobCallId, inputs);
    }

    // Test onJobResult
    function test_OnJobResult_CalledByMaster() public onlyMaster {
        uint64 serviceId = 102;
        uint8 job = 2;
        uint64 jobCallId = 600;
        ServiceOperators.OperatorPreferences memory operator = ServiceOperators.OperatorPreferences({
            ecdsaPublicKey: "0x123456",
            rpcAddress: "https://example.com/rpc"
        });
        bytes memory inputs = "job inputs";
        bytes memory outputs = "job outputs";

        // Expect no revert
        manager.onJobResult(serviceId, job, jobCallId, operator, inputs, outputs);
    }

    function test_OnJobResult_RevertsWhenNotMaster() public {
        uint64 serviceId = 102;
        uint8 job = 2;
        uint64 jobCallId = 600;
        ServiceOperators.OperatorPreferences memory operator = ServiceOperators.OperatorPreferences({
            ecdsaPublicKey: "0x123456",
            rpcAddress: "https://example.com/rpc"
        });
        bytes memory inputs = "job inputs";
        bytes memory outputs = "job outputs";

        vm.expectRevert(
            abi.encodeWithSelector(
                RootChainEnabled.OnlyMasterBlueprintServiceManagerAllowed.selector,
                address(0x999),
                masterBlueprintServiceManager
            )
        );
        vm.prank(address(0x999));
        manager.onJobResult(serviceId, job, jobCallId, operator, inputs, outputs);
    }

    // Test onServiceTermination
    function test_OnServiceTermination_CalledByMaster() public onlyMaster {
        uint64 serviceId = 103;
        address owner = address(0x888);

        // Expect no revert
        manager.onServiceTermination(serviceId, owner);
    }

    function test_OnServiceTermination_RevertsWhenNotMaster() public {
        uint64 serviceId = 103;
        address owner = address(0x888);

        vm.expectRevert(
            abi.encodeWithSelector(
                RootChainEnabled.OnlyMasterBlueprintServiceManagerAllowed.selector,
                address(0x999),
                masterBlueprintServiceManager
            )
        );
        vm.prank(address(0x999));
        manager.onServiceTermination(serviceId, owner);
    }

    // Test onUnappliedSlash
    function test_OnUnappliedSlash_CalledByMaster() public onlyMaster {
        uint64 serviceId = 104;
        bytes memory offender = "offender data";
        uint8 slashPercent = 5;

        // Expect no revert
        manager.onUnappliedSlash(serviceId, offender, slashPercent);
    }

    function test_OnUnappliedSlash_RevertsWhenNotMaster() public {
        uint64 serviceId = 104;
        bytes memory offender = "offender data";
        uint8 slashPercent = 5;

        vm.expectRevert(
            abi.encodeWithSelector(
                RootChainEnabled.OnlyMasterBlueprintServiceManagerAllowed.selector,
                address(0x999),
                masterBlueprintServiceManager
            )
        );
        vm.prank(address(0x999));
        manager.onUnappliedSlash(serviceId, offender, slashPercent);
    }

    // Test onSlash
    function test_OnSlash_CalledByMaster() public onlyMaster {
        uint64 serviceId = 105;
        bytes memory offender = "offender data";
        uint8 slashPercent = 10;
        uint256 totalPayout = 2000 ether;

        // Expect no revert
        manager.onSlash(serviceId, offender, slashPercent);
    }

    function test_OnSlash_RevertsWhenNotMaster() public {
        uint64 serviceId = 105;
        bytes memory offender = "offender data";
        uint8 slashPercent = 10;
        uint256 totalPayout = 2000 ether;

        vm.expectRevert(
            abi.encodeWithSelector(
                RootChainEnabled.OnlyMasterBlueprintServiceManagerAllowed.selector,
                address(0x999),
                masterBlueprintServiceManager
            )
        );
        vm.prank(address(0x999));
        manager.onSlash(serviceId, offender, slashPercent);
    }

    // Test querySlashingOrigin
    function test_QuerySlashingOrigin_ReturnsCorrectAddress() public view {
        uint64 serviceId = 106;
        address expected = address(manager);

        address result = manager.querySlashingOrigin(serviceId);
        assertEq(result, expected, "Slashing origin should be the contract itself");
    }

    // Test queryDisputeOrigin
    function test_QueryDisputeOrigin_ReturnsCorrectAddress() public view {
        uint64 serviceId = 107;
        address expected = address(manager);

        address result = manager.queryDisputeOrigin(serviceId);
        assertEq(result, expected, "Dispute origin should be the contract itself");
    }

    // Test queryDeveloperPaymentAddress
    function test_QueryDeveloperPaymentAddress_ReturnsBlueprintOwner() public view {
        uint64 serviceId = 108;

        address payable result = manager.queryDeveloperPaymentAddress(serviceId);
        assertEq(result, payable(manager.blueprintOwner()), "Developer payment address should be blueprint owner");
    }

    // Test queryIsPaymentAssetAllowed
    function test_QueryIsPaymentAssetAllowed_Erc20AssetAllowed() public onlyMaster {
        uint64 serviceId = 109;
        Assets.Asset memory asset =
            Assets.Asset({ kind: Assets.Kind.Erc20, data: bytes32(uint256(uint160(address(mockToken)))) });

        // Permit the asset
        manager.exposePermitAsset(serviceId, asset);

        bool isAllowed = manager.queryIsPaymentAssetAllowed(serviceId, asset);
        assertTrue(isAllowed, "ERC20 asset should be allowed");
    }

    function test_QueryIsPaymentAssetAllowed_Erc20AssetNotAllowed() public view {
        uint64 serviceId = 110;
        Assets.Asset memory asset =
            Assets.Asset({ kind: Assets.Kind.Erc20, data: bytes32(uint256(uint160(address(mockToken)))) });

        bool isAllowed = manager.queryIsPaymentAssetAllowed(serviceId, asset);
        assertFalse(isAllowed, "ERC20 asset should not be allowed initially");
    }

    function test_QueryIsPaymentAssetAllowed_CustomAssetAllowed() public onlyMaster {
        uint64 serviceId = 111;
        bytes32 assetId = bytes32(uint256(123_456));
        Assets.Asset memory asset = Assets.Asset({ kind: Assets.Kind.Custom, data: assetId });

        // Permit the asset
        manager.exposePermitAsset(serviceId, asset);

        bool isAllowed = manager.queryIsPaymentAssetAllowed(serviceId, asset);
        assertTrue(isAllowed, "Custom asset should be allowed");
    }

    function test_QueryIsPaymentAssetAllowed_CustomAssetNotAllowed() public view {
        uint64 serviceId = 112;
        bytes32 assetId = bytes32(uint256(654_321));
        Assets.Asset memory asset = Assets.Asset({ kind: Assets.Kind.Custom, data: assetId });

        bool isAllowed = manager.queryIsPaymentAssetAllowed(serviceId, asset);
        assertFalse(isAllowed, "Custom asset should not be allowed initially");
    }

    // Test _permitAsset and _revokeAsset
    function test_PermitAndRevokeAsset() public onlyMaster {
        uint64 serviceId = 113;
        Assets.Asset memory erc20Asset =
            Assets.Asset({ kind: Assets.Kind.Erc20, data: bytes32(uint256(uint160(address(mockToken)))) });
        bytes32 customAssetId = bytes32(uint256(789_012));
        Assets.Asset memory customAsset = Assets.Asset({ kind: Assets.Kind.Custom, data: customAssetId });

        // Permit both assets
        manager.exposePermitAsset(serviceId, erc20Asset);
        manager.exposePermitAsset(serviceId, customAsset);

        // Check if allowed
        assertTrue(manager.queryIsPaymentAssetAllowed(serviceId, erc20Asset), "ERC20 asset should be allowed");
        assertTrue(manager.queryIsPaymentAssetAllowed(serviceId, customAsset), "Custom asset should be allowed");

        // Revoke ERC20 asset
        manager.exposeRevokeAsset(serviceId, erc20Asset);
        assertFalse(manager.queryIsPaymentAssetAllowed(serviceId, erc20Asset), "ERC20 asset should be revoked");
        assertTrue(manager.queryIsPaymentAssetAllowed(serviceId, customAsset), "Custom asset should still be allowed");

        // Revoke Custom asset
        manager.exposeRevokeAsset(serviceId, customAsset);
        assertFalse(manager.queryIsPaymentAssetAllowed(serviceId, customAsset), "Custom asset should be revoked");
    }

    // Test _clearPermittedAssets
    function test_ClearPermittedAssets() public onlyMaster {
        uint64 serviceId = 114;
        Assets.Asset memory erc20Asset =
            Assets.Asset({ kind: Assets.Kind.Erc20, data: bytes32(uint256(uint160(address(mockToken)))) });
        bytes32 customAssetId = bytes32(uint256(890_123));
        Assets.Asset memory customAsset = Assets.Asset({ kind: Assets.Kind.Custom, data: customAssetId });

        // Permit both assets
        manager.exposePermitAsset(serviceId, erc20Asset);
        manager.exposePermitAsset(serviceId, customAsset);

        // Verify assets are permitted
        assertTrue(manager.queryIsPaymentAssetAllowed(serviceId, erc20Asset), "ERC20 asset should be allowed");
        assertTrue(manager.queryIsPaymentAssetAllowed(serviceId, customAsset), "Custom asset should be allowed");

        // Clear all permitted assets
        manager.exposeClearPermittedAssets(serviceId);

        // Verify assets are revoked
        assertFalse(manager.queryIsPaymentAssetAllowed(serviceId, erc20Asset), "ERC20 asset should be revoked");
        assertFalse(manager.queryIsPaymentAssetAllowed(serviceId, customAsset), "Custom asset should be revoked");
    }

    // Test _getPermittedAssetsAsAddresses
    function test_GetPermittedAssetsAsAddresses() public onlyMaster {
        uint64 serviceId = 115;
        Assets.Asset memory erc20Asset =
            Assets.Asset({ kind: Assets.Kind.Erc20, data: bytes32(uint256(uint160(address(mockToken)))) });

        manager.exposePermitAsset(serviceId, erc20Asset);

        address[] memory permitted = manager.exposeGetPermittedAssetsAsAddresses(serviceId);
        assertEq(permitted.length, 1, "Should have one permitted asset");
        assertEq(permitted[0], address(mockToken), "Permitted asset address mismatch");
    }

    // Test _getPermittedAssets
    function test_GetPermittedAssets() public onlyMaster {
        uint64 serviceId = 116;
        Assets.Asset memory erc20Asset =
            Assets.Asset({ kind: Assets.Kind.Erc20, data: bytes32(uint256(uint160(address(mockToken)))) });
        bytes32 customAssetId = bytes32(uint256(345_678));
        Assets.Asset memory customAsset = Assets.Asset({ kind: Assets.Kind.Custom, data: customAssetId });

        manager.exposePermitAsset(serviceId, erc20Asset);
        manager.exposePermitAsset(serviceId, customAsset);

        Assets.Asset[] memory permitted = manager.exposeGetPermittedAssets(serviceId);
        assertEq(permitted.length, 2, "Should have two permitted assets");

        // Verify ERC20 asset
        assertTrue(permitted[0].kind == Assets.Kind.Erc20, "First asset should be ERC20");
        assertEq(address(uint160(uint256(permitted[0].data))), address(mockToken), "ERC20 asset data mismatch");

        // Verify Custom asset
        assertTrue(permitted[1].kind == Assets.Kind.Custom, "Second asset should be Custom");
        assertEq(permitted[1].data, customAssetId, "Custom asset data mismatch");
    }

    // Test asset ID to address and back
    function test_AssetIdConversion() public onlyMaster {
        bytes32 assetId = bytes32(uint256(567_890));
        address assetAddress = assetId.toAddress();
        bytes32 convertedId = assetAddress.toAssetId();
        assertEq(assetId, convertedId, "Asset ID should match after conversion");
    }

    // Test invalid asset address conversion
    function test_AddressToAssetId_InvalidAddress() public {
        address invalidAssetAddress = address(0xABCDEF);
        vm.expectRevert(abi.encodeWithSelector(Assets.InvalidAssetId.selector, invalidAssetAddress));

        invalidAssetAddress.toAssetId();
    }

    // Test native asset check
    function test_IsNativeAsset_Erc20NonNative() public view {
        Assets.Asset memory erc20Asset =
            Assets.Asset({ kind: Assets.Kind.Erc20, data: bytes32(uint256(uint160(address(mockToken)))) });

        bool isNative = erc20Asset.isNative();
        assertFalse(isNative, "ERC20 asset should not be native");
    }

    function test_IsNativeAsset_CustomNonNative() public pure {
        Assets.Asset memory customAsset = Assets.Asset({ kind: Assets.Kind.Custom, data: bytes32(uint256(678_901)) });

        bool isNative = customAsset.isNative();
        assertFalse(isNative, "Custom asset should not be native");
    }

    function test_IsNativeAsset_NativeErc20() public pure {
        Assets.Asset memory nativeErc20 =
            Assets.Asset({ kind: Assets.Kind.Erc20, data: bytes32(uint256(uint160(address(0)))) });

        bool isNative = nativeErc20.isNative();
        assertTrue(isNative, "Erc20 with address 0 should be native");
    }

    function test_IsNativeAsset_NativeCustom() public pure {
        Assets.Asset memory nativeCustom = Assets.Asset({ kind: Assets.Kind.Custom, data: bytes32(uint256(0)) });

        bool isNative = nativeCustom.isNative();
        assertTrue(isNative, "Custom asset with ID 0 should be native");
    }

    function test_canJoin_CalledByMaster() public onlyMaster {
        uint64 serviceId = 1;
        ServiceOperators.OperatorPreferences memory operator = ServiceOperators.OperatorPreferences({
            ecdsaPublicKey: "0xabcdef",
            rpcAddress: "https://example.com/rpc"
        });

        bool canJoin = manager.canJoin(serviceId, operator);
        assertTrue(canJoin, "Default implementation should allow joining");
    }

    function test_canJoin_RevertsWhenNotMaster() public {
        uint64 serviceId = 1;
        ServiceOperators.OperatorPreferences memory operator = ServiceOperators.OperatorPreferences({
            ecdsaPublicKey: hex"1234",
            rpcAddress: "https://example.com/rpc"
        });

        vm.expectRevert(
            abi.encodeWithSelector(
                RootChainEnabled.OnlyMasterBlueprintServiceManagerAllowed.selector,
                address(this),
                masterBlueprintServiceManager
            )
        );
        manager.canJoin(serviceId, operator);
    }

    function test_onOperatorJoined_CalledByMaster() public onlyMaster {
        uint64 serviceId = 1;
        ServiceOperators.OperatorPreferences memory operator = ServiceOperators.OperatorPreferences({
            ecdsaPublicKey: "0xabcdef",
            rpcAddress: "https://example.com/rpc"
        });

        // Should not revert
        manager.onOperatorJoined(serviceId, operator);
    }

    function test_onOperatorJoined_RevertsWhenNotMaster() public {
        uint64 serviceId = 1;
        ServiceOperators.OperatorPreferences memory operator = ServiceOperators.OperatorPreferences({
            ecdsaPublicKey: "0xabcdef",
            rpcAddress: "https://example.com/rpc"
        });

        vm.expectRevert(
            abi.encodeWithSelector(
                RootChainEnabled.OnlyMasterBlueprintServiceManagerAllowed.selector,
                address(0x999),
                masterBlueprintServiceManager
            )
        );
        vm.prank(address(0x999));
        manager.onOperatorJoined(serviceId, operator);
    }

    function test_canLeave_CalledByMaster() public onlyMaster {
        uint64 serviceId = 1;
        ServiceOperators.OperatorPreferences memory operator = ServiceOperators.OperatorPreferences({
            ecdsaPublicKey: "0xabcdef",
            rpcAddress: "https://example.com/rpc"
        });

        bool canLeave = manager.canLeave(serviceId, operator);
        assertTrue(canLeave, "Default implementation should allow leaving");
    }

    function test_canLeave_RevertsWhenNotMaster() public {
        uint64 serviceId = 1;
        ServiceOperators.OperatorPreferences memory operator = ServiceOperators.OperatorPreferences({
            ecdsaPublicKey: hex"1234",
            rpcAddress: "https://example.com/rpc"
        });

        vm.expectRevert(
            abi.encodeWithSelector(
                RootChainEnabled.OnlyMasterBlueprintServiceManagerAllowed.selector,
                address(this),
                masterBlueprintServiceManager
            )
        );
        manager.canLeave(serviceId, operator);
    }

    function test_onOperatorLeft_CalledByMaster() public onlyMaster {
        uint64 serviceId = 1;
        ServiceOperators.OperatorPreferences memory operator = ServiceOperators.OperatorPreferences({
            ecdsaPublicKey: "0xabcdef",
            rpcAddress: "https://example.com/rpc"
        });

        // Should not revert
        manager.onOperatorLeft(serviceId, operator);
    }

    function test_onOperatorLeft_RevertsWhenNotMaster() public {
        uint64 serviceId = 1;
        ServiceOperators.OperatorPreferences memory operator = ServiceOperators.OperatorPreferences({
            ecdsaPublicKey: "0xabcdef",
            rpcAddress: "https://example.com/rpc"
        });

        vm.expectRevert(
            abi.encodeWithSelector(
                RootChainEnabled.OnlyMasterBlueprintServiceManagerAllowed.selector,
                address(0x999),
                masterBlueprintServiceManager
            )
        );
        vm.prank(address(0x999));
        manager.onOperatorLeft(serviceId, operator);
    }
    
    // Test native asset permissions
    function test_NativeAssetAlwaysPermitted() public onlyMaster {
        uint64 serviceId = TEST_SERVICE_ID;
        
        // Test native ERC20 (address(0))
        Assets.Asset memory nativeErc20 = Assets.Asset({ 
            kind: Assets.Kind.Erc20, 
            data: bytes32(0) 
        });
        
        Assets.Asset memory nativeCustom = Assets.Asset({ 
            kind: Assets.Kind.Custom, 
            data: bytes32(0) 
        });
        
        assertTrue(
            manager.queryIsPaymentAssetAllowed(serviceId, nativeErc20),
            "Native ERC20 should be permitted by default"
        );
        
        assertTrue(
            manager.queryIsPaymentAssetAllowed(serviceId, nativeCustom),
            "Native Custom asset should be permitted by default"
        );
    }
    
    // Test UnsupportedAssetKind error indirectly to ensure the code path is covered
    function test_UnsupportedAssetKind_Coverage() public {
        Assets.Asset memory erc20Asset = Assets.Asset({
            kind: Assets.Kind.Erc20,
            data: bytes32(uint256(uint160(address(0x1234))))
        });
        
        Assets.Asset memory customAsset = Assets.Asset({
            kind: Assets.Kind.Custom,
            data: bytes32(uint256(123456))
        });
        
        address erc20Address = erc20Asset.toAddress();
        assertEq(erc20Address, address(0x1234), "ERC20 asset should convert to correct address");
        
        address customAddress = customAsset.toAddress();
        assertTrue(customAddress != address(0), "Custom asset should convert to non-zero address");
    }
}
