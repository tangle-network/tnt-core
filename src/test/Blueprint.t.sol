// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import {LocalTestSetup, GlacisCommons} from "./mock/LocalTestSetup.sol";
import {Test} from "forge-std/Test.sol";
contract BlueprintTest is LocalTestSetup, Test {

    address public constant USER = makeAddr("USER");

    LocalTestSetup.Config  config;
    GlacisCommons.CrossChainGas[] fees;

    function setUp() public {
        config = setup();
        createFees(fees, 100, 5);
    }

    function test_blueprint_send() public {
        config.xcConfig.remoteRestakeVault.deposit(100 ether);
    }

    function test_blueprint_receive() public {
}
