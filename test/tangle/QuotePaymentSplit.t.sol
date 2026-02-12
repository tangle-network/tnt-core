// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BaseTest } from "../BaseTest.sol";
import { Types } from "../../src/libraries/Types.sol";
import { SignatureLib } from "../../src/libraries/SignatureLib.sol";
import { IMetricsRecorder } from "../../src/interfaces/IMetricsRecorder.sol";
import { MockServiceFeeDistributor } from "../mocks/MockServiceFeeDistributor.sol";

contract RecordingMetrics is IMetricsRecorder {
    uint256 public serviceCreatedCount;
    uint64 public lastServiceId;
    uint64 public lastBlueprintId;
    uint256 public lastOperatorCount;

    uint256 public paymentCount;
    address public lastPayer;
    uint64 public lastPaymentServiceId;
    address public lastPaymentToken;
    uint256 public lastPaymentAmount;

    function recordServiceCreated(uint64 serviceId, uint64 blueprintId, address, uint256 operatorCount) external {
        serviceCreatedCount++;
        lastServiceId = serviceId;
        lastBlueprintId = blueprintId;
        lastOperatorCount = operatorCount;
    }

    function recordPayment(address payer, uint64 serviceId, address token, uint256 amount) external {
        paymentCount++;
        lastPayer = payer;
        lastPaymentServiceId = serviceId;
        lastPaymentToken = token;
        lastPaymentAmount = amount;
    }

    // Stub all other methods
    function recordStake(address, address, address, uint256) external { }
    function recordUnstake(address, address, address, uint256) external { }
    function recordOperatorRegistered(address, address, uint256) external { }
    function recordHeartbeat(address, uint64, uint64) external { }
    function recordJobCompletion(address, uint64, uint64, bool) external { }
    function recordSlash(address, uint64, uint256) external { }
    function recordServiceTerminated(uint64, uint256) external { }
    function recordJobCall(uint64, address, uint64) external { }
    function recordBlueprintCreated(uint64, address) external { }
    function recordBlueprintRegistration(uint64, address) external { }
}

contract RevertingMetricsRecorder is IMetricsRecorder {
    function recordServiceCreated(uint64, uint64, address, uint256) external pure {
        revert("boom");
    }

    // Stub remaining methods
    function recordStake(address, address, address, uint256) external { }
    function recordUnstake(address, address, address, uint256) external { }
    function recordOperatorRegistered(address, address, uint256) external { }
    function recordHeartbeat(address, uint64, uint64) external { }
    function recordJobCompletion(address, uint64, uint64, bool) external { }
    function recordSlash(address, uint64, uint256) external { }
    function recordServiceTerminated(uint64, uint256) external { }
    function recordJobCall(uint64, address, uint64) external { }
    function recordPayment(address, uint64, address, uint256) external { }
    function recordBlueprintCreated(uint64, address) external { }
    function recordBlueprintRegistration(uint64, address) external { }
}

contract QuotePaymentSplitTest is BaseTest {
    uint256 internal constant OPERATOR_PK = 0xA11CE;
    bytes32 private constant QUOTE_TYPEHASH = keccak256(
        "QuoteDetails(uint64 blueprintId,uint64 ttlBlocks,uint256 totalCost,uint64 timestamp,uint64 expiry,AssetSecurityCommitment[] securityCommitments,ResourceCommitment[] resourceCommitments)AssetSecurityCommitment(Asset asset,uint16 exposureBps)Asset(uint8 kind,address token)ResourceCommitment(uint8 kind,uint64 count)"
    );

    RecordingMetrics internal metrics;
    MockServiceFeeDistributor internal serviceFeeDistributor;

    function setUp() public override {
        super.setUp();
        metrics = new RecordingMetrics();
        vm.prank(admin);
        tangle.setMetricsRecorder(address(metrics));

        serviceFeeDistributor = new MockServiceFeeDistributor();
        vm.startPrank(admin);
        tangle.setServiceFeeDistributor(address(serviceFeeDistributor));
        staking.setServiceFeeDistributor(address(serviceFeeDistributor));
        vm.stopPrank();

        operator1 = vm.addr(OPERATOR_PK);
        vm.deal(operator1, 100 ether);
        _registerOperator(operator1);
        vm.deal(user1, 100 ether);
    }

    function test_CreateServiceFromQuotes_DistributesPayment() public {
        vm.prank(developer);
        uint64 blueprintId = _createBlueprintAsSender("ipfs://payment-split", address(0));
        _registerForBlueprint(operator1, blueprintId);

        Types.SignedQuote[] memory quotes = _createSignedQuote(blueprintId, 1 ether, 120);

        uint256 devStart = developer.balance;
        uint256 treasuryStart = treasury.balance;
        uint256 distributorStart = address(serviceFeeDistributor).balance;

        vm.prank(user1);
        tangle.createServiceFromQuotes{ value: 1 ether }(blueprintId, quotes, "", new address[](0), 120);

        assertEq(developer.balance, devStart + 0.2 ether, "developer split");
        assertEq(treasury.balance, treasuryStart + 0.2 ether, "treasury split");
        // No security commitments: restaker share merges into operator pool
        assertEq(address(serviceFeeDistributor).balance, distributorStart, "restaker split");
        assertEq(tangle.pendingRewards(operator1), 0.6 ether, "operator pending reward");

        assertEq(metrics.serviceCreatedCount(), 1, "metrics service created");
        assertEq(metrics.lastBlueprintId(), blueprintId, "metrics blueprint id");
    }

    function test_CreateServiceFromQuotes_MetricsRevertIgnored() public {
        vm.startPrank(admin);
        tangle.setMetricsRecorder(address(new RevertingMetricsRecorder()));
        vm.stopPrank();

        vm.prank(developer);
        uint64 blueprintId = _createBlueprintAsSender("ipfs://metrics-test", address(0));
        _registerForBlueprint(operator1, blueprintId);

        Types.SignedQuote[] memory quotes = _createSignedQuote(blueprintId, 1 ether, 120);

        vm.prank(user1);
        tangle.createServiceFromQuotes{ value: 1 ether }(blueprintId, quotes, "", new address[](0), 120);
        // Should succeed without reverting even though metrics recorder throws.
        assertGt(tangle.serviceCount(), 0, "service created");
    }

    function _createSignedQuote(
        uint64 blueprintId,
        uint256 totalCost,
        uint64 ttl
    )
        internal
        view
        returns (Types.SignedQuote[] memory quotes)
    {
        Types.QuoteDetails memory details = Types.QuoteDetails({
            blueprintId: blueprintId,
            ttlBlocks: ttl,
            totalCost: totalCost,
            timestamp: uint64(block.timestamp),
            expiry: uint64(block.timestamp + 1 hours),
            securityCommitments: new Types.AssetSecurityCommitment[](0),
            resourceCommitments: new Types.ResourceCommitment[](0)
        });

        bytes memory signature = _signQuote(details, OPERATOR_PK);
        quotes = new Types.SignedQuote[](1);
        quotes[0] = Types.SignedQuote({ details: details, signature: signature, operator: operator1 });
    }

    function _signQuote(Types.QuoteDetails memory details, uint256 pk) internal view returns (bytes memory) {
        bytes32 commitmentsHash = _hashSecurityCommitments(details.securityCommitments);
        bytes32 resourcesHash = _hashResourceCommitments(details.resourceCommitments);
        bytes32 domainSeparator = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes("TangleQuote")),
                keccak256(bytes("1")),
                block.chainid,
                address(tangle)
            )
        );
        bytes32 structHash = keccak256(
            abi.encode(
                QUOTE_TYPEHASH,
                details.blueprintId,
                details.ttlBlocks,
                details.totalCost,
                details.timestamp,
                details.expiry,
                commitmentsHash,
                resourcesHash
            )
        );
        bytes32 digest = keccak256(abi.encodePacked("\x19\x01", domainSeparator, structHash));
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(pk, digest);
        return abi.encodePacked(r, s, v);
    }

    function _hashSecurityCommitments(Types.AssetSecurityCommitment[] memory commitments)
        internal
        pure
        returns (bytes32)
    {
        bytes32[] memory hashes = new bytes32[](commitments.length);
        for (uint256 i = 0; i < commitments.length; i++) {
            hashes[i] = _hashSecurityCommitment(commitments[i]);
        }
        bytes32 out;
        assembly ("memory-safe") {
            out := keccak256(add(hashes, 0x20), mul(mload(hashes), 0x20))
        }
        return out;
    }

    function _hashSecurityCommitment(Types.AssetSecurityCommitment memory commitment) internal pure returns (bytes32) {
        bytes32 ASSET_TYPEHASH = keccak256("Asset(uint8 kind,address token)");
        bytes32 COMMITMENT_TYPEHASH =
            keccak256("AssetSecurityCommitment(Asset asset,uint16 exposureBps)Asset(uint8 kind,address token)");
        bytes32 assetHash = keccak256(abi.encode(ASSET_TYPEHASH, uint8(commitment.asset.kind), commitment.asset.token));
        return keccak256(abi.encode(COMMITMENT_TYPEHASH, assetHash, commitment.exposureBps));
    }

    function _hashResourceCommitments(Types.ResourceCommitment[] memory commitments) internal pure returns (bytes32) {
        bytes32 RC_TYPEHASH = keccak256("ResourceCommitment(uint8 kind,uint64 count)");
        bytes32[] memory hashes = new bytes32[](commitments.length);
        for (uint256 i = 0; i < commitments.length; i++) {
            hashes[i] = keccak256(abi.encode(RC_TYPEHASH, commitments[i].kind, commitments[i].count));
        }
        bytes32 out;
        assembly ("memory-safe") {
            out := keccak256(add(hashes, 0x20), mul(mload(hashes), 0x20))
        }
        return out;
    }
}
