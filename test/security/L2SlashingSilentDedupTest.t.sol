// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test } from "forge-std/Test.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { L2SlashingReceiver, IL2Slasher } from "../../src/beacon/L2SlashingReceiver.sol";

/// @title L2SlashingSilentDedupTest
/// @notice Regression: a duplicate (sourceChainId, sender, nonce) must revert so the
///         relayer can distinguish "already processed" from "still pending" during
///         retries / partition recovery. The previous implementation silently `return`ed.
contract L2SlashingSilentDedupTest is Test {
    MockSlasher slasher;
    L2SlashingReceiver receiver;
    address messenger = makeAddr("messenger");

    uint256 constant SOURCE_CHAIN_ID = 1;
    address authorizedSender;

    bytes4 constant SLASH_MESSAGE_TYPE = bytes4(keccak256("BEACON_SLASH"));

    function setUp() public {
        slasher = new MockSlasher();
        L2SlashingReceiver impl = new L2SlashingReceiver();
        ERC1967Proxy proxy = new ERC1967Proxy(
            address(impl), abi.encodeCall(L2SlashingReceiver.initialize, (address(slasher), messenger, address(this)))
        );
        receiver = L2SlashingReceiver(address(proxy));
        authorizedSender = makeAddr("connector");

        receiver.setAuthorizedSender(SOURCE_CHAIN_ID, authorizedSender, true);
        vm.warp(block.timestamp + 2 days + 1);
        receiver.activateAuthorizedSender(SOURCE_CHAIN_ID, authorizedSender);
    }

    function test_DuplicateNonceReverts() public {
        bytes memory payload = _buildSlashPayload({
            operator: makeAddr("op1"),
            slashBps: 1000,
            slashingFactor: 9e17,
            nonce: 42,
            pod: makeAddr("pod1")
        });

        vm.prank(messenger);
        receiver.receiveMessage(SOURCE_CHAIN_ID, authorizedSender, payload);
        assertEq(slasher.callCount(), 1, "first delivery slashed");

        vm.prank(messenger);
        vm.expectRevert(
            abi.encodeWithSelector(
                L2SlashingReceiver.NonceAlreadyProcessed.selector, SOURCE_CHAIN_ID, authorizedSender, uint256(42)
            )
        );
        receiver.receiveMessage(SOURCE_CHAIN_ID, authorizedSender, payload);

        assertEq(slasher.callCount(), 1, "no double-slash");
        assertTrue(receiver.isNonceProcessed(SOURCE_CHAIN_ID, authorizedSender, 42));
    }

    function test_NewNoncesStillAccepted() public {
        for (uint256 i = 0; i < 3; i++) {
            bytes memory payload = _buildSlashPayload({
                operator: makeAddr("op1"),
                slashBps: 1000,
                slashingFactor: uint64(9e17 - i),
                nonce: i,
                pod: makeAddr("pod1")
            });
            vm.prank(messenger);
            receiver.receiveMessage(SOURCE_CHAIN_ID, authorizedSender, payload);
        }
        assertEq(slasher.callCount(), 3, "every distinct nonce slashed once");
    }

    function _buildSlashPayload(
        address operator,
        uint16 slashBps,
        uint64 slashingFactor,
        uint256 nonce,
        address pod
    ) internal pure returns (bytes memory) {
        return abi.encodePacked(
            SLASH_MESSAGE_TYPE,
            abi.encode(operator, slashBps, slashingFactor, nonce, pod)
        );
    }
}

contract MockSlasher is IL2Slasher {
    uint256 public callCount;
    function slashOperator(address, uint16, bytes calldata) external override {
        callCount++;
    }
    function canSlash(address) external pure override returns (bool) {
        return true;
    }
    function getSlashableStake(address) external pure override returns (uint256) {
        return type(uint256).max;
    }
}
