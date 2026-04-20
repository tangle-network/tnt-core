// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BaseTest } from "../BaseTest.sol";
import { Types } from "../../src/libraries/Types.sol";

/// @title ConfidentialityProtocolTest
/// @notice Focused coverage for non-default confidentiality modes across request, activation, and RFQ flows.
contract ConfidentialityProtocolTest is BaseTest {
    uint256 internal constant OPERATOR1_PK = 0xA11CE;
    uint256 internal constant OPERATOR2_PK = 0xB0B;

    uint64 internal blueprintId;

    function setUp() public override {
        operator1 = vm.addr(OPERATOR1_PK);
        operator2 = vm.addr(OPERATOR2_PK);

        super.setUp();

        _registerOperator(operator1, 5 ether);
        _registerOperator(operator2, 5 ether);

        vm.prank(developer);
        blueprintId = _createBlueprintAsSender("ipfs://confidentiality", address(0));

        _registerForBlueprint(operator1, blueprintId);
        _registerForBlueprint(operator2, blueprintId);
    }

    function test_RequestService_PersistsTeeRequiredThroughActivation() public {
        address[] memory operators = new address[](2);
        operators[0] = operator1;
        operators[1] = operator2;

        vm.prank(user1);
        uint64 requestId = tangle.requestService(
            blueprintId, operators, "", new address[](0), 0, address(0), 0, Types.ConfidentialityPolicy.TeeRequired
        );

        Types.ServiceRequest memory req = tangle.getServiceRequest(requestId);
        assertEq(uint8(req.confidentiality), uint8(Types.ConfidentialityPolicy.TeeRequired), "request confidentiality");

        vm.prank(operator1);
        tangle.approveService(requestId, 0);
        vm.prank(operator2);
        tangle.approveService(requestId, 0);

        Types.Service memory svc = tangle.getService(0);
        assertEq(uint8(svc.confidentiality), uint8(Types.ConfidentialityPolicy.TeeRequired), "service confidentiality");
    }

    function test_CreateServiceFromQuotes_PersistsTeePreferred() public {
        Types.SignedQuote[] memory quotes = new Types.SignedQuote[](2);
        quotes[0] = _createQuote(operator1, OPERATOR1_PK, 1 ether, 30 days, Types.ConfidentialityPolicy.TeePreferred);
        quotes[1] = _createQuote(operator2, OPERATOR2_PK, 1.1 ether, 30 days, Types.ConfidentialityPolicy.TeePreferred);

        vm.prank(user1);
        uint64 serviceId =
            tangle.createServiceFromQuotes{ value: 2.1 ether }(blueprintId, quotes, "", new address[](0), 30 days);

        Types.Service memory svc = tangle.getService(serviceId);
        assertEq(uint8(svc.confidentiality), uint8(Types.ConfidentialityPolicy.TeePreferred), "rfq confidentiality");
    }

    function test_ExtendServiceFromQuotes_PreservesStandardRequired() public {
        Types.SignedQuote[] memory quotes = new Types.SignedQuote[](2);
        quotes[0] = _createQuote(
            operator1, OPERATOR1_PK, 1 ether, 30 days, Types.ConfidentialityPolicy.StandardRequired
        );
        quotes[1] = _createQuote(
            operator2, OPERATOR2_PK, 1.1 ether, 30 days, Types.ConfidentialityPolicy.StandardRequired
        );

        vm.prank(user1);
        uint64 serviceId =
            tangle.createServiceFromQuotes{ value: 2.1 ether }(blueprintId, quotes, "", new address[](0), 30 days);

        Types.Service memory beforeExtension = tangle.getService(serviceId);
        assertEq(
            uint8(beforeExtension.confidentiality),
            uint8(Types.ConfidentialityPolicy.StandardRequired),
            "initial service confidentiality"
        );

        Types.SignedQuote[] memory extensionQuotes = new Types.SignedQuote[](2);
        extensionQuotes[0] = _createQuote(
            operator1, OPERATOR1_PK, 0.5 ether, 15 days, Types.ConfidentialityPolicy.StandardRequired
        );
        extensionQuotes[1] = _createQuote(
            operator2, OPERATOR2_PK, 0.6 ether, 15 days, Types.ConfidentialityPolicy.StandardRequired
        );

        vm.prank(user1);
        tangle.extendServiceFromQuotes{ value: 1.1 ether }(serviceId, extensionQuotes, 15 days);

        Types.Service memory afterExtension = tangle.getService(serviceId);
        assertEq(
            uint8(afterExtension.confidentiality),
            uint8(Types.ConfidentialityPolicy.StandardRequired),
            "extended service confidentiality"
        );
        assertGt(afterExtension.ttl, beforeExtension.ttl, "ttl should increase");
    }

    function _createQuote(
        address operator,
        uint256 privateKey,
        uint256 totalCost,
        uint64 ttl,
        Types.ConfidentialityPolicy confidentiality
    )
        internal
        view
        returns (Types.SignedQuote memory)
    {
        Types.QuoteDetails memory details = Types.QuoteDetails({
            blueprintId: blueprintId,
            ttlBlocks: ttl,
            totalCost: totalCost,
            timestamp: uint64(block.timestamp),
            expiry: uint64(block.timestamp + 1 hours),
            confidentiality: confidentiality,
            securityCommitments: new Types.AssetSecurityCommitment[](0),
            resourceCommitments: new Types.ResourceCommitment[](0)
        });

        return Types.SignedQuote({ details: details, signature: _signQuote(details, privateKey), operator: operator });
    }

    function _signQuote(Types.QuoteDetails memory details, uint256 privateKey) internal view returns (bytes memory) {
        bytes32 quoteTypehash = keccak256(
            "QuoteDetails(uint64 blueprintId,uint64 ttlBlocks,uint256 totalCost,uint64 timestamp,uint64 expiry,uint8 confidentiality,AssetSecurityCommitment[] securityCommitments,ResourceCommitment[] resourceCommitments)AssetSecurityCommitment(Asset asset,uint16 exposureBps)Asset(uint8 kind,address token)ResourceCommitment(uint8 kind,uint64 count)"
        );
        bytes32 domainSeparator = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256("TangleQuote"),
                keccak256("1"),
                block.chainid,
                address(tangle)
            )
        );
        bytes32 structHash = keccak256(
            abi.encode(
                quoteTypehash,
                details.blueprintId,
                details.ttlBlocks,
                details.totalCost,
                details.timestamp,
                details.expiry,
                details.confidentiality,
                keccak256(""),
                keccak256("")
            )
        );

        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, digest);
        return abi.encodePacked(r, s, v);
    }
}
