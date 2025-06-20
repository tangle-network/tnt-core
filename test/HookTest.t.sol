// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import { Test } from "forge-std/Test.sol";
import { HookTestBlueprintServiceManager } from "./HookTest.sol";
import { ServiceOperators } from "../src/ServiceOperatorsLib.sol";
import { Assets } from "../src/AssetsLib.sol";

/// @title HookTest Test Contract
/// @notice Tests the hooks functionality of the HookTestBlueprintServiceManager
contract HookTestContract is Test {
    HookTestBlueprintServiceManager hookTest;
    address constant ROOT_CHAIN = 0x09dF6A941ee03B1e632904E382e10862fA9cc0e3;
    address constant TEST_OWNER = address(0x1111);
    address constant TEST_MBSM = address(0x2222);
    uint64 constant TEST_BLUEPRINT_ID = 123;

    function setUp() public {
        hookTest = new HookTestBlueprintServiceManager();
        vm.startPrank(ROOT_CHAIN);
        hookTest.onBlueprintCreated(TEST_BLUEPRINT_ID, TEST_OWNER, TEST_MBSM);
        vm.stopPrank();
    }

    function testOnBlueprintCreated() public {
        assertEq(hookTest.currentBlueprintId(), TEST_BLUEPRINT_ID);
        assertEq(hookTest.blueprintOwner(), TEST_OWNER);
        assertEq(hookTest.masterBlueprintServiceManagerAddress(), TEST_MBSM);
    }

    function testOnRegister() public {
        ServiceOperators.OperatorPreferences memory prefs = ServiceOperators.OperatorPreferences({
            ecdsaPublicKey: bytes("test_key"),
            rpcAddress: "test_rpc"
        });
        
        vm.startPrank(TEST_MBSM);
        hookTest.onRegister(prefs, bytes(""));
        vm.stopPrank();
    }

    function testOnUnregister() public {
        ServiceOperators.OperatorPreferences memory prefs = ServiceOperators.OperatorPreferences({
            ecdsaPublicKey: bytes("test_key"),
            rpcAddress: "test_rpc"
        });
        
        vm.startPrank(TEST_MBSM);
        hookTest.onUnregister(prefs);
        vm.stopPrank();
    }

    function testOnUpdateRpcAddress() public {
        ServiceOperators.OperatorPreferences memory prefs = ServiceOperators.OperatorPreferences({
            ecdsaPublicKey: bytes("test_key"),
            rpcAddress: "test_rpc"
        });
        
        vm.startPrank(TEST_MBSM);
        hookTest.onUpdateRpcAddress(prefs);
        vm.stopPrank();
    }

    function testOnRequest() public {
        ServiceOperators.OperatorPreferences[] memory operators = new ServiceOperators.OperatorPreferences[](1);
        operators[0] = ServiceOperators.OperatorPreferences({
            ecdsaPublicKey: bytes("test_key"),
            rpcAddress: "test_rpc"
        });
        
        address[] memory permittedCallers = new address[](1);
        permittedCallers[0] = address(0x3333);
        
        ServiceOperators.RequestParams memory params = ServiceOperators.RequestParams({
            requestId: 1,
            requester: address(0x4444),
            operators: operators,
            requestInputs: bytes("test_inputs"),
            permittedCallers: permittedCallers,
            ttl: 3600,
            paymentAsset: Assets.Asset({
                kind: Assets.Kind.Erc20,
                data: bytes32(uint256(uint160(address(0x5555))))
            }),
            amount: 1000
        });
        
        vm.startPrank(TEST_MBSM);
        hookTest.onRequest(params);
        vm.stopPrank();
    }

    function testOnApprove() public {
        ServiceOperators.OperatorPreferences memory prefs = ServiceOperators.OperatorPreferences({
            ecdsaPublicKey: bytes("test_key"),
            rpcAddress: "test_rpc"
        });
        
        vm.startPrank(TEST_MBSM);
        hookTest.onApprove(prefs, 1, 1);
        vm.stopPrank();
    }

    function testOnReject() public {
        ServiceOperators.OperatorPreferences memory prefs = ServiceOperators.OperatorPreferences({
            ecdsaPublicKey: bytes("test_key"),
            rpcAddress: "test_rpc"
        });
        
        vm.startPrank(TEST_MBSM);
        hookTest.onReject(prefs, 1);
        vm.stopPrank();
    }

    function testOnServiceInitialized() public {
        address[] memory operators = new address[](1);
        operators[0] = address(0x6666);
        
        vm.startPrank(TEST_MBSM);
        hookTest.onServiceInitialized(1, 2, address(0x7777), operators, 3600);
        vm.stopPrank();
    }

    function testOnJobCall() public {
        vm.startPrank(TEST_MBSM);
        hookTest.onJobCall(1, 2, 3, bytes("test_data"));
        vm.stopPrank();
    }

    function testOnJobResult() public {
        ServiceOperators.OperatorPreferences memory prefs = ServiceOperators.OperatorPreferences({
            ecdsaPublicKey: bytes("test_key"),
            rpcAddress: "test_rpc"
        });
        
        vm.startPrank(TEST_MBSM);
        hookTest.onJobResult(1, 2, 3, prefs, bytes("inputs"), bytes("outputs"));
        vm.stopPrank();
    }

    function testOnServiceTermination() public {
        vm.startPrank(TEST_MBSM);
        hookTest.onServiceTermination(1, address(0x8888));
        vm.stopPrank();
    }

    function testOnUnappliedSlash() public {
        vm.startPrank(TEST_MBSM);
        hookTest.onUnappliedSlash(1, bytes("offence"), 2);
        vm.stopPrank();
    }

    function testOnSlash() public {
        vm.startPrank(TEST_MBSM);
        hookTest.onSlash(1, bytes("offence"), 2);
        vm.stopPrank();
    }

    function testOnlyFromRootChain() public {
        vm.expectRevert();
        hookTest.onBlueprintCreated(1, address(0x1), address(0x2));
    }

    function testOnlyFromMaster() public {
        ServiceOperators.OperatorPreferences memory prefs = ServiceOperators.OperatorPreferences({
            ecdsaPublicKey: bytes("test_key"),
            rpcAddress: "test_rpc"
        });
        
        vm.expectRevert();
        hookTest.onRegister(prefs, bytes(""));
    }
}
