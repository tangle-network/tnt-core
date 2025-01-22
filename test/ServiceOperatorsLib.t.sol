// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import { Test } from "forge-std/Test.sol";
import { ServiceOperators } from "../src/ServiceOperatorsLib.sol";
import { Assets } from "../src/AssetsLib.sol";

contract ServiceOperatorsLibTest is Test {
    // Test constants
    bytes constant TEST_PUBLIC_KEY =
        hex"04d2688b6bc2ce7676a3a9d2f85e178d1964e0fdc1cc8d8ed3d196b5ca6d7932d18f1a48789057ed03d100147b365627427b1918c405c932c2ca81625fd8a23975";
    address constant EXPECTED_OPERATOR = address(0x9C7483fb4D62C4f48E5d1049BB87B3E54b013E6b);

    function setUp() public {
        // No setup required as we're testing a library
    }

    function testStructInitialization() public {
        // Test PriceTargets initialization
        ServiceOperators.PriceTargets memory prices =
            ServiceOperators.PriceTargets({ cpu: 100, mem: 200, storage_hdd: 300, storage_ssd: 400, storage_nvme: 500 });

        assertEq(prices.cpu, 100, "CPU price not set correctly");
        assertEq(prices.mem, 200, "Memory price not set correctly");
        assertEq(prices.storage_hdd, 300, "HDD storage price not set correctly");
        assertEq(prices.storage_ssd, 400, "SSD storage price not set correctly");
        assertEq(prices.storage_nvme, 500, "NVMe storage price not set correctly");

        // Test OperatorPreferences initialization
        ServiceOperators.OperatorPreferences memory prefs =
            ServiceOperators.OperatorPreferences({ ecdsaPublicKey: TEST_PUBLIC_KEY, priceTargets: prices });

        assertEq(prefs.ecdsaPublicKey, TEST_PUBLIC_KEY, "ECDSA public key not set correctly");
        assertEq(prefs.priceTargets.cpu, prices.cpu, "Price targets not set correctly");
    }

    function testRequestParamsInitialization() public {
        // Create operator preferences array
        ServiceOperators.OperatorPreferences[] memory operators = new ServiceOperators.OperatorPreferences[](2);

        // Set up price targets for operators
        ServiceOperators.PriceTargets memory prices1 =
            ServiceOperators.PriceTargets({ cpu: 100, mem: 200, storage_hdd: 300, storage_ssd: 400, storage_nvme: 500 });

        ServiceOperators.PriceTargets memory prices2 =
            ServiceOperators.PriceTargets({ cpu: 150, mem: 250, storage_hdd: 350, storage_ssd: 450, storage_nvme: 550 });

        // Set up operator preferences
        operators[0] = ServiceOperators.OperatorPreferences({ ecdsaPublicKey: TEST_PUBLIC_KEY, priceTargets: prices1 });

        operators[1] = ServiceOperators.OperatorPreferences({
            ecdsaPublicKey: hex"04e2688b6bc2ce7676a3a9d2f85e178d1964e0fdc1cc8d8ed3d196b5ca6d7932d18f1a48789057ed03d100147b365627427b1918c405c932c2ca81625fd8a23976",
            priceTargets: prices2
        });

        // Set up permitted callers
        address[] memory permittedCallers = new address[](2);
        permittedCallers[0] = address(0x1234);
        permittedCallers[1] = address(0x5678);

        // Create request params
        ServiceOperators.RequestParams memory params = ServiceOperators.RequestParams({
            requestId: 12_345,
            requester: address(this),
            operators: operators,
            requestInputs: hex"1234567890",
            permittedCallers: permittedCallers,
            ttl: 3600,
            paymentAsset: Assets.Asset({ kind: Assets.Kind.Erc20, data: bytes32(uint256(uint160(address(0x1)))) }),
            amount: 1000
        });

        // Verify request params
        assertEq(params.requestId, 12_345, "Request ID not set correctly");
        assertEq(params.requester, address(this), "Requester not set correctly");
        assertEq(params.operators.length, 2, "Operators array length incorrect");
        assertEq(params.requestInputs, hex"1234567890", "Request inputs not set correctly");
        assertEq(params.permittedCallers.length, 2, "Permitted callers array length incorrect");
        assertEq(params.ttl, 3600, "TTL not set correctly");
        assertEq(params.amount, 1000, "Amount not set correctly");

        // Verify first operator
        assertEq(params.operators[0].ecdsaPublicKey, TEST_PUBLIC_KEY, "First operator public key not set correctly");
        assertEq(params.operators[0].priceTargets.cpu, 100, "First operator CPU price not set correctly");

        // Verify permitted callers
        assertEq(params.permittedCallers[0], address(0x1234), "First permitted caller not set correctly");
        assertEq(params.permittedCallers[1], address(0x5678), "Second permitted caller not set correctly");
    }

    function testDifferentPublicKeysProduceDifferentAddresses(bytes calldata key1, bytes calldata key2) public {
        vm.assume(keccak256(key1) != keccak256(key2));

        address operator1 = ServiceOperators.asOperatorAddress(key1);
        address operator2 = ServiceOperators.asOperatorAddress(key2);

        assertTrue(operator1 != operator2, "Different public keys should produce different addresses");
    }
}
