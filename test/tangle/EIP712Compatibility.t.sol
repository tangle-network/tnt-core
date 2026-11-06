// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { JobRfqFixture } from "../support/JobRfqFixture.sol";
import { Types } from "../../src/libraries/Types.sol";

/// Cross-language typed data is redeemed through the public Tangle RFQ overloads.
contract EIP712CompatibilityTest is JobRfqFixture {
    function test_GpuQuote_EightB200AndLegacyQuoteBothRedeem() public {
        Types.GpuResourceCommitment memory gpu = Types.GpuResourceCommitment(5, 8, keccak256("nvidia-b200"), 3600);
        Types.SignedJobQuote[] memory quotes = _gpuQuotes(gpu);
        (bool ok, bytes memory result) = _submitGpu(quotes, gpu);
        assertTrue(ok, "GPU-aware public RFQ entrypoint must accept a signed 8xB200 quote");
        uint64 callId = abi.decode(result, (uint64));
        assertEq(tangle.getJobQuotedPrice(serviceId, callId, operator1), 1 ether);
        quotes[0] = _createJobQuote(operator1, OPERATOR1_PK, serviceId, 0, 1 ether);
        vm.prank(user1);
        tangle.submitJobFromQuote{ value: 1 ether }(serviceId, 0, "", quotes);
    }

    function test_GpuQuote_RejectsClassCountDurationTamperingWithoutBurningQuote() public {
        Types.GpuResourceCommitment memory gpu = Types.GpuResourceCommitment(5, 8, keccak256("nvidia-b200"), 3600);
        Types.SignedJobQuote[] memory quotes = _gpuQuotes(gpu);
        gpu.gpuClass = keccak256("nvidia-b300");
        (bool ok,) = _submitGpu(quotes, gpu);
        assertFalse(ok, "different GPU class must invalidate the signature");
        gpu.gpuClass = keccak256("nvidia-b200");
        gpu.count = 1;
        (ok,) = _submitGpu(quotes, gpu);
        assertFalse(ok, "different count must invalidate the signature");
        gpu.count = 8;
        gpu.durationSecs = 7200;
        (ok,) = _submitGpu(quotes, gpu);
        assertFalse(ok, "different duration must invalidate the signature");
        gpu.durationSecs = 3600;
        (ok,) = _submitGpu(quotes, gpu);
        assertTrue(ok, "rejected mutations must not consume the real quote");
        (ok,) = _submitGpu(quotes, gpu);
        assertFalse(ok, "accepted GPU quote must be single-use");
    }

    function test_GpuQuote_RejectsInvalidResourceAndLegacySignature() public {
        Types.GpuResourceCommitment memory gpu = Types.GpuResourceCommitment(5, 8, keccak256("nvidia-b200"), 3600);
        Types.SignedJobQuote[] memory quotes = new Types.SignedJobQuote[](1);
        quotes[0] = _createJobQuote(operator1, OPERATOR1_PK, serviceId, 0, 1 ether);
        (bool ok,) = _submitGpu(quotes, gpu);
        assertFalse(ok, "legacy signature cannot authorize a GPU commitment");
        gpu.count = 0;
        quotes = _gpuQuotes(gpu);
        (ok,) = _submitGpu(quotes, gpu);
        assertFalse(ok, "zero count must be refused even when signed");
        gpu.count = 8;
        gpu.durationSecs = 0;
        quotes = _gpuQuotes(gpu);
        (ok,) = _submitGpu(quotes, gpu);
        assertFalse(ok, "zero duration must be refused even when signed");
    }

    function test_GpuQuote_RejectsTheObsoleteNestedTypeNameWithoutConsumingCanonicalQuote() public {
        Types.GpuResourceCommitment memory gpu = Types.GpuResourceCommitment(5, 8, keccak256("nvidia-b200"), 3600);
        Types.SignedJobQuote[] memory quotes = _gpuQuotes(gpu);
        quotes[0].signature = _signTypedQuote(quotes[0].details, OPERATOR1_PK, "ResourceCommitment", gpu);
        (bool ok,) = _submitGpu(quotes, gpu);
        assertFalse(ok, "obsolete GPU-only schema must not authorize an allocation");
        quotes[0].signature = _signTypedQuote(quotes[0].details, OPERATOR1_PK, "GpuResourceCommitment", gpu);
        (ok,) = _submitGpu(quotes, gpu);
        assertTrue(ok, "the canonical quote remains usable after a rejected schema");
    }

    function test_GpuQuote_OffchainIntegerVectorsPreserveEveryPriceBit() public {
        uint256[3] memory prices = [uint256(0), uint256(9_007_199_254_740_993), uint256(type(uint128).max)];
        Types.GpuResourceCommitment memory gpu = Types.GpuResourceCommitment(5, 4, keccak256("nvidia-gb300"), 7200);
        for (uint256 i; i < prices.length; i++) {
            Types.SignedJobQuote[] memory quotes = _gpuQuotes(gpu);
            quotes[0].details.price = prices[i];
            quotes[0].signature = _signTypedQuote(quotes[0].details, OPERATOR1_PK, "GpuResourceCommitment", gpu);
            vm.deal(user1, prices[i]);
            (bool ok, bytes memory result) = _submitGpu(quotes, gpu);
            assertTrue(ok, "the independently encoded integer quote must redeem");
            assertEq(tangle.getJobQuotedPrice(serviceId, abi.decode(result, (uint64)), operator1), prices[i]);
        }
    }

    function _gpuQuotes(Types.GpuResourceCommitment memory gpu)
        internal
        returns (Types.SignedJobQuote[] memory quotes)
    {
        quotes = new Types.SignedJobQuote[](1);
        quotes[0] = _createJobQuote(operator1, OPERATOR1_PK, serviceId, 0, 1 ether);
        quotes[0].signature = _signTypedQuote(quotes[0].details, OPERATOR1_PK, "GpuResourceCommitment", gpu);
    }

    function _submitGpu(
        Types.SignedJobQuote[] memory quotes,
        Types.GpuResourceCommitment memory gpu
    )
        internal
        returns (bool, bytes memory)
    {
        vm.prank(user1);
        return address(tangle).call{ value: quotes[0].details.price }(
            abi.encodeWithSignature(
                "submitJobFromQuote(uint64,uint8,bytes,((address,uint64,uint8,uint256,uint64,uint64,uint8,bytes32),bytes,address)[],(uint8,uint64,bytes32,uint64))",
                serviceId,
                uint8(0),
                bytes(""),
                quotes,
                gpu
            )
        );
    }
}
