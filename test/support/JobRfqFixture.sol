// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BaseTest } from "../BaseTest.sol";
import { Tangle } from "../../src/Tangle.sol";
import { Types } from "../../src/libraries/Types.sol";
import { TangleJobsRFQFacet } from "../../src/facets/tangle/TangleJobsRFQFacet.sol";

interface TypedDataEncoder {
    function eip712HashTypedData(string calldata jsonData) external pure returns (bytes32);
}

/// Shared real Tangle registration fixture for legacy and GPU RFQ wire proofs.
abstract contract JobRfqFixture is BaseTest {
    uint256 constant OPERATOR1_PK = 0x1;
    uint256 constant OPERATOR2_PK = 0x2;
    uint256 constant OPERATOR3_PK = 0x3;

    uint64 internal blueprintId;
    uint64 internal serviceId;
    uint64 internal quoteNonce;

    function setUp() public override {
        super.setUp();

        // Override operator addresses with deterministic keys (for EIP-712 signing)
        operator1 = vm.addr(OPERATOR1_PK);
        operator2 = vm.addr(OPERATOR2_PK);
        operator3 = vm.addr(OPERATOR3_PK);

        vm.deal(operator1, 100 ether);
        vm.deal(operator2, 100 ether);
        vm.deal(operator3, 100 ether);

        // Register RFQ facet
        vm.startPrank(admin);
        Tangle(payable(address(tangleProxy))).registerFacet(address(new TangleJobsRFQFacet()));
        vm.stopPrank();

        // Create an EventDriven blueprint with a default eventRate
        Types.BlueprintConfig memory config = Types.BlueprintConfig({
            membership: Types.MembershipModel.Fixed,
            pricing: Types.PricingModel.EventDriven,
            minOperators: 0,
            maxOperators: 0,
            subscriptionRate: 0,
            subscriptionInterval: 0,
            eventRate: 0.5 ether
        });

        blueprintId = _createBlueprintWithConfig(developer, address(0), config);

        // Register operators
        _registerOperator(operator1, 5 ether);
        _registerOperator(operator2, 5 ether);
        _registerOperator(operator3, 5 ether);
        _registerForBlueprint(operator1, blueprintId);
        _registerForBlueprint(operator2, blueprintId);
        _registerForBlueprint(operator3, blueprintId);

        // Create service with operator1 and operator2
        address[] memory ops = new address[](2);
        ops[0] = operator1;
        ops[1] = operator2;
        address[] memory callers = new address[](0);

        vm.prank(user1);
        uint64 requestId =
            tangle.requestService(blueprintId, ops, "", callers, 0, address(0), 0, Types.ConfidentialityPolicy.Any);

        vm.prank(operator1);
        tangle.approveService(_approve(requestId));
        vm.prank(operator2);
        tangle.approveService(_approve(requestId));

        serviceId = tangle.serviceCount() - 1;
    }

    function _createJobQuote(
        address operator,
        uint256 privateKey,
        uint64 _serviceId,
        uint8 jobIndex,
        uint256 price
    )
        internal
        returns (Types.SignedJobQuote memory)
    {
        uint64 baseTimestamp = uint64(block.timestamp) + quoteNonce;
        quoteNonce++;

        Types.JobQuoteDetails memory details = Types.JobQuoteDetails({
            requester: user1,
            serviceId: _serviceId,
            jobIndex: jobIndex,
            price: price,
            timestamp: baseTimestamp,
            expiry: baseTimestamp + 1 hours,
            confidentiality: 0,
            inputsHash: keccak256("")
        });

        bytes memory signature = _signJobQuote(details, privateKey);

        return Types.SignedJobQuote({ details: details, signature: signature, operator: operator });
    }

    function _signJobQuote(Types.JobQuoteDetails memory d, uint256 key) internal view returns (bytes memory) {
        return _signTypedQuote(d, key, "", Types.GpuResourceCommitment(0, 0, bytes32(0), 0));
    }

    // Foundry delegates this JSON to Alloy's off-chain EIP-712 encoder. No production hash helper is called.
    function _signTypedQuote(
        Types.JobQuoteDetails memory d,
        uint256 key,
        string memory resourceName,
        Types.GpuResourceCommitment memory gpu
    )
        internal
        view
        returns (bytes memory)
    {
        bool hasGpu = bytes(resourceName).length != 0;
        string memory primary = hasGpu ? "GpuJobQuoteDetails" : "JobQuoteDetails";
        string memory fields = string.concat(
            '[{"name":"requester","type":"address"},{"name":"serviceId","type":"uint64"},',
            '{"name":"jobIndex","type":"uint8"},{"name":"price","type":"uint256"},',
            '{"name":"timestamp","type":"uint64"},{"name":"expiry","type":"uint64"},',
            '{"name":"confidentiality","type":"uint8"},{"name":"inputsHash","type":"bytes32"}',
            hasGpu ? string.concat(',{"name":"resourceCommitment","type":"', resourceName, '"}') : "",
            "]"
        );
        string memory types = string.concat(
            '{"EIP712Domain":[{"name":"name","type":"string"},{"name":"version","type":"string"},',
            '{"name":"chainId","type":"uint256"},{"name":"verifyingContract","type":"address"}],"',
            primary,
            '":',
            fields,
            hasGpu
                ? string.concat(
                    ',"',
                    resourceName,
                    '":[{"name":"kind","type":"uint8"},{"name":"count","type":"uint64"},',
                    '{"name":"gpuClass","type":"bytes32"},{"name":"durationSecs","type":"uint64"}]'
                )
                : "",
            "}"
        );
        string memory message = string.concat(
            '{"requester":"',
            vm.toString(d.requester),
            '","serviceId":"',
            vm.toString(d.serviceId),
            '","jobIndex":"',
            vm.toString(d.jobIndex),
            '","price":"',
            vm.toString(d.price),
            '","timestamp":"',
            vm.toString(d.timestamp),
            '","expiry":"',
            vm.toString(d.expiry),
            '","confidentiality":"',
            vm.toString(d.confidentiality),
            '","inputsHash":"',
            vm.toString(d.inputsHash),
            '"',
            hasGpu
                ? string.concat(
                    ',"resourceCommitment":{"kind":"',
                    vm.toString(gpu.kind),
                    '","count":"',
                    vm.toString(gpu.count),
                    '","gpuClass":"',
                    vm.toString(gpu.gpuClass),
                    '","durationSecs":"',
                    vm.toString(gpu.durationSecs),
                    '"}'
                )
                : "",
            "}"
        );
        string memory data = string.concat(
            '{"types":',
            types,
            ',"primaryType":"',
            primary,
            '","domain":{"name":"TangleQuote","version":"1","chainId":"',
            vm.toString(block.chainid),
            '","verifyingContract":"',
            vm.toString(address(tangle)),
            '"},"message":',
            message,
            "}"
        );
        (uint8 v, bytes32 r, bytes32 sigS) = vm.sign(key, TypedDataEncoder(address(vm)).eip712HashTypedData(data));
        return abi.encodePacked(r, sigS, v);
    }
}
