// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test } from "forge-std/Test.sol";

import { BlueprintServiceManagerBase } from "../../src/BlueprintServiceManagerBase.sol";

/// @notice Concrete test double that exposes internal helpers
contract BlueprintServiceManagerBaseHarness is BlueprintServiceManagerBase {
    uint256 public totalReceived;
    address public lastToken;

    event PaymentLogged(address indexed token, uint256 amount);

    function exposePermit(uint64 serviceId, address asset) external {
        _permitAsset(serviceId, asset);
    }

    function exposeRevoke(uint64 serviceId, address asset) external returns (bool) {
        return _revokeAsset(serviceId, asset);
    }

    function exposeClear(uint64 serviceId) external {
        _clearPermittedAssets(serviceId);
    }

    function exposePermitted(uint64 serviceId) external view returns (address[] memory) {
        return _getPermittedAssets(serviceId);
    }

    function _onPaymentReceived(address token, uint256 amount) internal override {
        totalReceived += amount;
        lastToken = token;
        emit PaymentLogged(token, amount);
    }
}

contract BlueprintServiceManagerBaseTest is Test {
    BlueprintServiceManagerBaseHarness internal bsm;
    address internal blueprintOwner = makeAddr("owner");
    address internal tangle = makeAddr("tangle");

    function setUp() public {
        bsm = new BlueprintServiceManagerBaseHarness();
        bsm.onBlueprintCreated(42, blueprintOwner, tangle);
    }

    function test_OnBlueprintCreated_SetsImmutableState() public {
        assertEq(bsm.blueprintId(), 42);
        assertEq(bsm.blueprintOwner(), blueprintOwner);
        assertEq(bsm.tangleCore(), tangle);
    }

    function test_OnBlueprintCreated_CannotBeCalledTwice() public {
        vm.expectRevert(BlueprintServiceManagerBase.AlreadyInitialized.selector);
        bsm.onBlueprintCreated(1, blueprintOwner, tangle);
    }

    function test_OnlyFromTangle_EnforcedForHooks() public {
        vm.expectRevert(
            abi.encodeWithSelector(BlueprintServiceManagerBase.OnlyTangleAllowed.selector, address(this), tangle)
        );
        bsm.onRegister(address(0xBEEF), "");

        vm.prank(tangle);
        bsm.onRegister(address(0xBEEF), ""); // should succeed
    }

    function test_DefaultQueryImplementations() public {
        (bool useDefaultHeartbeat,) = bsm.getHeartbeatInterval(1);
        assertTrue(useDefaultHeartbeat);

        (bool useDefaultThreshold,) = bsm.getHeartbeatThreshold(1);
        assertTrue(useDefaultThreshold);

        (bool useDefaultWindow,) = bsm.getSlashingWindow(1);
        assertTrue(useDefaultWindow);

        (bool useDefaultExit,, uint64 exitQueue, bool forceExitAllowed) = bsm.getExitConfig(1);
        assertTrue(useDefaultExit);
        assertEq(exitQueue, 0);
        assertFalse(forceExitAllowed);

        assertEq(bsm.queryDeveloperPaymentAddress(1), blueprintOwner);
        assertEq(bsm.querySlashingOrigin(1), address(bsm));
        assertEq(bsm.queryDisputeOrigin(1), address(bsm));

        assertFalse(bsm.requiresAggregation(1, 0));
        (uint16 thresholdBps, uint8 thresholdType) = bsm.getAggregationThreshold(1, 0);
        assertEq(thresholdBps, 6700);
        assertEq(thresholdType, 0);

        (bool useDefaultStake,) = bsm.getMinOperatorStake();
        assertTrue(useDefaultStake);
    }

    function test_PaymentAssetAllowList_Workflow() public {
        address tokenA = makeAddr("tokenA");
        address tokenB = makeAddr("tokenB");

        // All assets allowed before an allowlist is configured
        assertTrue(bsm.queryIsPaymentAssetAllowed(7, tokenA));
        assertTrue(bsm.queryIsPaymentAssetAllowed(7, address(0)));

        bsm.exposePermit(7, tokenA);
        address[] memory permitted = bsm.exposePermitted(7);
        assertEq(permitted.length, 1);
        assertEq(permitted[0], tokenA);

        assertTrue(bsm.queryIsPaymentAssetAllowed(7, tokenA));
        assertFalse(bsm.queryIsPaymentAssetAllowed(7, tokenB));

        bool removed = bsm.exposeRevoke(7, tokenA);
        assertTrue(removed);
        assertEq(bsm.exposePermitted(7).length, 0, "allowlist should be empty now");
        assertTrue(bsm.queryIsPaymentAssetAllowed(7, tokenA));

        bsm.exposePermit(7, tokenA);
        bsm.exposePermit(7, tokenB);
        bsm.exposeClear(7);
        assertEq(bsm.exposePermitted(7).length, 0);
        // With cleared allowlist, everything is accepted again
        assertTrue(bsm.queryIsPaymentAssetAllowed(7, tokenB));
    }

    function test_ReceiveHook_TracksPayments() public {
        vm.deal(address(this), 1 ether);
        (bool ok,) = address(bsm).call{ value: 0.75 ether }("");
        require(ok, "send failed");

        assertEq(bsm.totalReceived(), 0.75 ether);
        assertEq(bsm.lastToken(), address(0));
    }
}
