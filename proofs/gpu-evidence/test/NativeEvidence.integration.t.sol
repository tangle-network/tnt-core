// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BaseTest } from "tnt-core/test/BaseTest.sol";
import { Test } from "forge-std/Test.sol";
import { Errors } from "tnt-core/src/libraries/Errors.sol";
import { ITangleFull } from "tnt-core/src/interfaces/ITangle.sol";
import { BlueprintServiceManagerBase } from "tnt-core/src/BlueprintServiceManagerBase.sol";
import { GpuLeaseEvidenceVerifier } from "slashing-proof/contracts/src/GpuLeaseEvidenceVerifier.sol";
import { ComputeProviderSlashing } from "slashing-proof/contracts/src/ComputeProviderSlashing.sol";
import { SlashingTypes } from "slashing-proof/contracts/src/SlashingTypes.sol";

contract NativeEvidenceManager is BlueprintServiceManagerBase, ComputeProviderSlashing {
    bytes private callbackEvidence;
    bool private revertCallback;
    uint256 public callbacks;
    bool public reentryAccepted;

    constructor(address core, address owner, address verifier) ComputeProviderSlashing(verifier) {
        _initializeBlueprintManager(core, owner);
    }

    function querySlashingOrigin(uint64 id) external view override returns (address) {
        return _slashingOrigin(id);
    }

    function onSlash(uint64 id, bytes calldata offender, uint8 percent) external override onlyFromTangle {
        _recordSlashExecuted(id, offender, percent);
    }

    function configureCallback(bytes calldata evidence, bool fail) external onlyBlueprintOwner {
        callbackEvidence = evidence;
        revertCallback = fail;
    }

    function onUnappliedSlash(uint64 id, bytes calldata offender, uint8) external override onlyFromTangle {
        ++callbacks;
        (reentryAccepted,) = address(this)
            .call(
                abi.encodeCall(
                    this.submitEvidence,
                    (
                        id,
                        address(bytes20(offender)),
                        SlashingTypes.ViolationType.SERVICE_NOT_DELIVERED,
                        callbackEvidence
                    )
                )
            );
        require(!revertCallback, "callback rollback");
    }
}

contract NativeEvidenceFixture is BaseTest {
    function open(address verifier) external returns (NativeEvidenceManager manager, uint64 service) {
        _setUpNativeProtocol();
        manager = new NativeEvidenceManager(address(tangle), developer, verifier);
        uint64 blueprint = _createBlueprint(developer, address(manager));
        _registerOperator(operator1, 10 ether);
        _registerForBlueprint(operator1, blueprint);
        service = nextService(manager);
    }

    function nextService(NativeEvidenceManager manager) public returns (uint64) {
        uint64 request = _requestService(user1, manager.blueprintId(), operator1);
        _approveService(operator1, request);
        return tangle.serviceCount() - 1;
    }
}

contract NativeEvidenceIntegrationTest is Test {
    SlashingTypes.ViolationType private constant DELIVERY_FAILURE = SlashingTypes.ViolationType.SERVICE_NOT_DELIVERED;
    uint256 private constant KEY = 0xa11ce;
    GpuLeaseEvidenceVerifier private verifier;

    function testVerifiedNativeProposalReplayRotationAndAtomicCallbacks() public {
        verifier = new GpuLeaseEvidenceVerifier(vm.addr(KEY));
        NativeEvidenceFixture first = new NativeEvidenceFixture();
        (NativeEvidenceManager manager, uint64 service) = first.open(address(verifier));
        address operator = first.operator1();
        bytes memory good = _receipt(manager, service, operator, KEY, KEY);
        bytes memory wrongSigner = _receipt(manager, service, operator, KEY, 0xbad);
        vm.expectRevert("EVIDENCE_REJECTED");
        _admit(manager, service, operator, wrongSigner);
        SlashingTypes.EvidenceEnvelope memory unsigned = abi.decode(good, (SlashingTypes.EvidenceEnvelope));
        unsigned.payload = abi.encode(bytes("receipt"), bytes(""));
        vm.expectRevert("EVIDENCE_REJECTED");
        _admit(manager, service, operator, abi.encode(unsigned));
        vm.prank(first.developer());
        manager.configureCallback(good, false);
        bytes32 hash = _admit(manager, service, operator, good);
        assertEq(manager.pendingEvidence(service, operator), hash);
        assertEq(first.tangle().getSlashProposal(0).evidence, hash);
        assertEq(first.tangle().getSlashProposal(0).slashBps, SlashingTypes.defaultSeverityCap(DELIVERY_FAILURE));
        assertEq(first.tangle().getSlashProposal(0).proposer, address(manager));
        assertEq(manager.callbacks(), 1);
        assertFalse(manager.reentryAccepted());
        vm.warp(block.timestamp + 1);
        bytes memory replacement = _receipt(manager, service, operator, KEY, KEY);
        assertNotEq(keccak256(replacement), hash);
        vm.expectRevert("EVIDENCE_PENDING");
        _admit(manager, service, operator, replacement);
        assertEq(manager.pendingEvidence(service, operator), hash);
        vm.warp(first.tangle().getSlashProposal(0).executeAfter + 16);
        first.tangle().executeSlash(0);
        assertEq(manager.pendingEvidence(service, operator), bytes32(0));
        // Past TNT's dispute window, evidence age or replay may refuse first; both must.
        vm.expectRevert();
        _admit(manager, service, operator, good);
        vm.expectRevert();
        _admit(manager, service, operator, bytes.concat(good, bytes32(0)));
        NativeEvidenceManager other =
            new NativeEvidenceManager(address(first.tangle()), first.developer(), address(verifier));
        vm.expectRevert("EVIDENCE_REJECTED");
        _admit(other, service, operator, good);
        NativeEvidenceFixture second = new NativeEvidenceFixture();
        (NativeEvidenceManager foreign, uint64 foreignService) = second.open(address(verifier));
        assertEq(foreignService, service);
        vm.expectRevert("EVIDENCE_REJECTED");
        _admit(foreign, foreignService, operator, good);
        bytes memory absent = _receipt(manager, 99, operator, KEY, KEY);
        vm.expectRevert(abi.encodeWithSelector(Errors.ServiceNotFound.selector, uint64(99)));
        _admit(manager, 99, operator, absent);
        assertEq(manager.pendingEvidence(99, operator), bytes32(0));
        assertFalse(manager.submittedEvidence(keccak256(absent)));
        verifier.setCollector(vm.addr(KEY), false);
        bytes memory revoked = _receipt(foreign, foreignService, operator, KEY, KEY);
        vm.expectRevert("EVIDENCE_REJECTED");
        _admit(foreign, foreignService, operator, revoked);
        verifier.setCollector(vm.addr(0xbad), true);
        bytes memory rotated = _receipt(foreign, foreignService, operator, 0xbad, 0xbad);
        _admit(foreign, foreignService, operator, rotated);
        uint64 next = first.nextService(manager);
        bytes memory callback = _receipt(manager, next, operator, 0xbad, 0xbad);
        vm.prank(first.developer());
        manager.configureCallback(callback, true);
        bytes32 callbackHash = _admit(manager, next, operator, callback);
        assertEq(manager.callbacks(), 1, "reverted callback wrote state");
        assertEq(manager.pendingEvidence(next, operator), callbackHash);
        assertEq(first.tangle().getSlashProposal(1).evidence, callbackHash);
    }

    function testCancelledProposalFreesThePendingSlot() public {
        verifier = new GpuLeaseEvidenceVerifier(vm.addr(KEY));
        NativeEvidenceFixture fixture = new NativeEvidenceFixture();
        (NativeEvidenceManager manager, uint64 service) = fixture.open(address(verifier));
        address operator = fixture.operator1();
        bytes memory first = _receipt(manager, service, operator, KEY, KEY);
        _admit(manager, service, operator, first);
        ITangleFull core = fixture.tangle();
        vm.prank(fixture.admin());
        core.cancelSlash(0, "dispute upheld");
        vm.expectRevert("EVIDENCE_REPLAY");
        _admit(manager, service, operator, bytes.concat(first, bytes32(0)));
        vm.warp(block.timestamp + 1);
        bytes32 later = _admit(manager, service, operator, _receipt(manager, service, operator, KEY, KEY));
        assertEq(manager.pendingEvidence(service, operator), later);
        assertEq(fixture.tangle().getSlashProposal(1).evidence, later);
    }

    function _admit(
        NativeEvidenceManager manager,
        uint64 service,
        address operator,
        bytes memory evidence
    )
        internal
        returns (bytes32)
    {
        return manager.submitEvidence(service, operator, DELIVERY_FAILURE, evidence);
    }

    function _receipt(
        NativeEvidenceManager manager,
        uint64 service,
        address operator,
        uint256 collector,
        uint256 signer
    )
        internal
        returns (bytes memory)
    {
        SlashingTypes.EvidenceEnvelope memory envelope = SlashingTypes.EvidenceEnvelope(
            SlashingTypes.EvidenceKind.DEVICE_ATTESTATION, uint64(block.timestamp), vm.addr(collector), bytes("receipt")
        );
        bytes32 digest = verifier.evidenceDigest(DELIVERY_FAILURE, envelope, manager.evidenceContext(service), operator);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(signer, digest);
        envelope.payload = abi.encode(envelope.payload, abi.encodePacked(r, s, v));
        return abi.encode(envelope);
    }
}
