// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { JobRfqFixture } from "../support/JobRfqFixture.sol";
import { Types } from "../../src/libraries/Types.sol";
import { Errors } from "../../src/libraries/Errors.sol";

interface IndependentGpuRfq {
    function submitJobFromQuote(
        uint64 serviceId,
        uint8 jobIndex,
        bytes calldata inputs,
        Types.SignedJobQuote[] calldata quotes,
        Types.GpuResourceCommitment calldata gpu
    )
        external
        payable
        returns (uint64);
}

contract GpuQuoteAdversarialIntegrationTest is JobRfqFixture {
    function test_IndependentGpuSignatureCannotCrossIntoLegacyRedemption() public {
        Types.GpuResourceCommitment memory gpu = Types.GpuResourceCommitment(5, 8, keccak256("nvidia-b200"), 3600);
        Types.SignedJobQuote[] memory quotes = _quote(gpu, 1 ether);
        vm.expectRevert(abi.encodeWithSelector(Errors.InvalidQuoteSignature.selector, operator1));
        vm.prank(user1);
        tangle.submitJobFromQuote{ value: 1 ether }(serviceId, 0, "", quotes);
        uint64 callId = _redeem(quotes, gpu);
        assertEq(tangle.getJobQuotedPrice(serviceId, callId, operator1), 1 ether);
    }

    function test_IndependentWrongChainDomainCannotConsumeCanonicalGpuQuote() public {
        Types.GpuResourceCommitment memory gpu = Types.GpuResourceCommitment(5, 4, keccak256("nvidia-gb300"), 7200);
        uint256 realChain = block.chainid;
        vm.chainId(realChain + 1);
        Types.SignedJobQuote[] memory quotes = _quote(gpu, 1 ether);
        vm.chainId(realChain);
        vm.expectRevert(abi.encodeWithSelector(Errors.InvalidQuoteSignature.selector, operator1));
        _redeem(quotes, gpu);
        quotes[0].signature = _signTypedQuote(quotes[0].details, OPERATOR1_PK, "GpuResourceCommitment", gpu);
        assertEq(tangle.getJobQuotedPrice(serviceId, _redeem(quotes, gpu), operator1), 1 ether);
    }

    function test_IndependentOneBitPriceMutationAboveJsIntegerRangeIsRejected() public {
        uint256 price = 9_007_199_254_740_993;
        Types.GpuResourceCommitment memory gpu = Types.GpuResourceCommitment(5, 1, keccak256("nvidia-h200"), 60);
        Types.SignedJobQuote[] memory quotes = _quote(gpu, price);
        quotes[0].details.price = price - 1;
        vm.expectRevert(abi.encodeWithSelector(Errors.InvalidQuoteSignature.selector, operator1));
        _redeem(quotes, gpu);
        quotes[0].details.price = price;
        assertEq(tangle.getJobQuotedPrice(serviceId, _redeem(quotes, gpu), operator1), price);
    }

    function _quote(
        Types.GpuResourceCommitment memory gpu,
        uint256 price
    )
        private
        view
        returns (Types.SignedJobQuote[] memory quotes)
    {
        quotes = new Types.SignedJobQuote[](1);
        Types.JobQuoteDetails memory details = Types.JobQuoteDetails({
            requester: user1,
            serviceId: serviceId,
            jobIndex: 0,
            price: price,
            timestamp: uint64(block.timestamp),
            expiry: uint64(block.timestamp) + 1 hours,
            confidentiality: 0,
            inputsHash: keccak256("")
        });
        quotes[0] = Types.SignedJobQuote({
            details: details,
            signature: _signTypedQuote(details, OPERATOR1_PK, "GpuResourceCommitment", gpu),
            operator: operator1
        });
    }

    function _redeem(
        Types.SignedJobQuote[] memory quotes,
        Types.GpuResourceCommitment memory gpu
    )
        private
        returns (uint64)
    {
        vm.prank(user1);
        return IndependentGpuRfq(address(tangle)).submitJobFromQuote{ value: quotes[0].details.price }(
            serviceId, 0, "", quotes, gpu
        );
    }
}
