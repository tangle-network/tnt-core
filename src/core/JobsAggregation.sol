// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import { Base } from "./Base.sol";
import { Types } from "../libraries/Types.sol";
import { Errors } from "../libraries/Errors.sol";
import { BN254 } from "../libraries/BN254.sol";
import { IBlueprintServiceManager } from "../interfaces/IBlueprintServiceManager.sol";
import { SchemaLib } from "../libraries/SchemaLib.sol";

/// @title JobsAggregation
/// @notice Aggregated BLS job results
abstract contract JobsAggregation is Base {
    using EnumerableSet for EnumerableSet.AddressSet;

    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    event JobCompleted(uint64 indexed serviceId, uint64 indexed callId);
    event AggregatedResultSubmitted(
        uint64 indexed serviceId, uint64 indexed callId, uint256 signerBitmap, bytes output
    );

    // ═══════════════════════════════════════════════════════════════════════════
    // AGGREGATED RESULT SUBMISSION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Submit an aggregated BLS result for a job
    /// @dev Only valid for jobs where requiresAggregation returns true
    /// @param serviceId The service ID
    /// @param callId The job call ID
    /// @param output The aggregated output data
    /// @param signerBitmap Bitmap indicating which operators signed (bit i = operator i in service)
    /// @param aggregatedSignature The aggregated BLS signature [x, y]
    /// @param aggregatedPubkey The aggregated public key [x0, x1, y0, y1]
    function submitAggregatedResult(
        uint64 serviceId,
        uint64 callId,
        bytes calldata output,
        uint256 signerBitmap,
        uint256[2] calldata aggregatedSignature,
        uint256[4] calldata aggregatedPubkey
    )
        external
        whenNotPaused
        nonReentrant
    {
        Types.Service storage svc = _getService(serviceId);
        Types.JobCall storage job = _getJobCall(serviceId, callId);
        Types.Blueprint storage bp = _blueprints[svc.blueprintId];

        _validateServiceForAggregatedResult(svc, serviceId);

        if (job.completed) {
            revert Errors.JobAlreadyCompleted(serviceId, callId);
        }

        bool aggregationRequired;
        uint16 thresholdBps = DEFAULT_AGGREGATION_THRESHOLD_BPS;
        uint8 thresholdType = 0;
        if (bp.manager != address(0)) {
            (bool okReq, bytes memory retReq) = _tryStaticcallManager(
                bp.manager,
                abi.encodeWithSelector(IBlueprintServiceManager.requiresAggregation.selector, serviceId, job.jobIndex),
                32
            );
            if (okReq) aggregationRequired = abi.decode(retReq, (bool));

            (bool okThr, bytes memory retThr) = _tryStaticcallManager(
                bp.manager,
                abi.encodeWithSelector(
                    IBlueprintServiceManager.getAggregationThreshold.selector, serviceId, job.jobIndex
                ),
                64
            );
            if (okThr) {
                (thresholdBps, thresholdType) = abi.decode(retThr, (uint16, uint8));
            }
        }
        if (!aggregationRequired) {
            revert Errors.AggregationNotRequired(serviceId, job.jobIndex);
        }

        Types.StoredJobSchema storage schema = _jobSchema(svc.blueprintId, job.jobIndex);
        SchemaLib.validateJobResult(schema, output, svc.blueprintId, job.jobIndex);

        (uint256 achieved, uint256 required) =
            _validateSignersAndThreshold(serviceId, signerBitmap, thresholdBps, thresholdType);
        if (achieved < required) {
            revert Errors.AggregationThresholdNotMet(serviceId, callId, achieved, required);
        }

        _verifyAggregatedSignature(serviceId, callId, output, signerBitmap, aggregatedSignature, aggregatedPubkey);

        _finalizeAggregatedResult(
            svc, job, bp, serviceId, callId, signerBitmap, output, aggregatedSignature, aggregatedPubkey
        );
    }

    function _finalizeAggregatedResult(
        Types.Service storage svc,
        Types.JobCall storage job,
        Types.Blueprint storage bp,
        uint64 serviceId,
        uint64 callId,
        uint256 signerBitmap,
        bytes calldata output,
        uint256[2] calldata aggregatedSignature,
        uint256[4] calldata aggregatedPubkey
    )
        private
    {
        job.completed = true;

        emit AggregatedResultSubmitted(serviceId, callId, signerBitmap, output);
        emit JobCompleted(serviceId, callId);

        _recordAggregatedJobCompletion(serviceId, callId, signerBitmap);

        if (svc.pricing == Types.PricingModel.EventDriven && job.payment > 0) {
            if (job.isRFQ) {
                _distributeRFQJobPayment(serviceId, callId, job.payment);
            } else {
                _distributeJobPayment(serviceId, job.payment);
            }
        }

        if (bp.manager != address(0)) {
            _tryCallManager(
                bp.manager,
                abi.encodeWithSelector(
                    IBlueprintServiceManager.onAggregatedResult.selector,
                    serviceId,
                    job.jobIndex,
                    callId,
                    output,
                    signerBitmap,
                    aggregatedSignature,
                    aggregatedPubkey
                )
            );
        }
    }

    /// @notice Record job completion metrics for all signers in an aggregated result
    /// @param serviceId The service ID
    /// @param callId The job call ID
    /// @param signerBitmap Bitmap of operators who signed
    function _recordAggregatedJobCompletion(uint64 serviceId, uint64 callId, uint256 signerBitmap) internal {
        if (_metricsRecorder == address(0)) return;

        address[] memory operators = _getServiceOperatorList(serviceId);

        for (uint256 i = 0; i < operators.length; i++) {
            if ((signerBitmap & (uint256(1) << i)) != 0) {
                // This operator signed - record job completion
                _recordJobCompletion(operators[i], serviceId, callId, true);
            }
        }
    }

    /// @notice Validate signers in bitmap and compute achieved vs required threshold
    /// @param serviceId The service ID
    /// @param signerBitmap Bitmap of signers
    /// @param thresholdBps Threshold in basis points
    /// @param thresholdType 0 = CountBased, 1 = StakeWeighted
    /// @return achieved The achieved value (count or stake)
    /// @return required The required value (count or stake)
    function _validateSignersAndThreshold(
        uint64 serviceId,
        uint256 signerBitmap,
        uint16 thresholdBps,
        uint8 thresholdType
    )
        internal
        view
        returns (uint256 achieved, uint256 required)
    {
        SignerStats memory stats = _computeSignerStats(serviceId, signerBitmap, thresholdType);

        if (thresholdType == 0) {
            // CountBased: achieved = signerCount, required = threshold% of operatorCount
            achieved = stats.signerCount;
            required = _ceilDiv(uint256(stats.operatorCount) * thresholdBps, BPS_DENOMINATOR);
            if (required == 0 && stats.operatorCount > 0) required = 1; // At least 1 signer required
        } else {
            // StakeWeighted: achieved = signerWeight, required = threshold% of totalWeight
            achieved = stats.signerWeight;
            required = _ceilDiv(stats.totalWeight * thresholdBps, BPS_DENOMINATOR);
            if (required == 0 && stats.totalWeight > 0) required = 1;
        }
    }

    struct SignerStats {
        uint32 operatorCount;
        uint256 signerCount;
        uint256 totalWeight;
        uint256 signerWeight;
    }

    function _computeSignerStats(
        uint64 serviceId,
        uint256 signerBitmap,
        uint8 thresholdType
    )
        private
        view
        returns (SignerStats memory stats)
    {
        address[] memory operators = _getServiceOperatorList(serviceId);

        for (uint256 i = 0; i < operators.length; i++) {
            Types.ServiceOperator storage svcOp = _serviceOperators[serviceId][operators[i]];
            if (!svcOp.active) continue;
            if (!_staking.isOperatorActive(operators[i])) continue;

            stats.operatorCount++;
            uint256 weight = thresholdType == 1 ? uint256(svcOp.exposureBps) : 1;
            stats.totalWeight += weight;

            if ((signerBitmap >> i) & 1 == 1) {
                stats.signerCount++;
                stats.signerWeight += weight;
            }
        }
    }

    function _verifyAggregatedSignature(
        uint64 serviceId,
        uint64 callId,
        bytes calldata output,
        uint256 signerBitmap,
        uint256[2] calldata aggregatedSignature,
        uint256[4] calldata aggregatedPubkey
    )
        private
        view
    {
        Types.BN254G1Point memory sig = Types.BN254G1Point(aggregatedSignature[0], aggregatedSignature[1]);
        Types.BN254G2Point memory providedPubkey = Types.BN254G2Point(
            [aggregatedPubkey[0], aggregatedPubkey[1]], [aggregatedPubkey[2], aggregatedPubkey[3]]
        );

        // CRITICAL: Verify that the provided aggregated pubkey matches the expected pubkey
        // computed from the registered BLS keys of the operators indicated in signerBitmap.
        // The operator set is also hashed and bound into the BLS message below so that a
        // swap-and-pop reorder (operator leaves / forceRemove) invalidates any in-flight
        // signed result instead of mis-crediting a different operator at the same bitmap
        // index (Round 2 operator-collusion #2c).
        address[] memory operators = _getServiceOperatorList(serviceId);
        Types.BN254G2Point memory expectedPubkey =
            _computeExpectedAggregatedPubkeyFromList(serviceId, signerBitmap, operators);
        if (!BN254.g2Eq(providedPubkey, expectedPubkey)) {
            revert Errors.AggregatedPubkeyMismatch();
        }

        // Domain-separated message:
        //   "TANGLE_BLS_AGG_v1" || chainId || address(this) || serviceId || callId
        //   || keccak256(operators) || keccak256(output)
        // The chainId+address binds the signature to a specific deployment (Round 1
        // jobs J-2). The operator-set hash binds it to a specific membership snapshot.
        bytes memory message = abi.encode(
            "TANGLE_BLS_AGG_v1",
            block.chainid,
            address(this),
            serviceId,
            callId,
            keccak256(abi.encode(operators)),
            keccak256(output)
        );
        if (!BN254.verifyAggregatedBls(message, sig, providedPubkey)) {
            revert Errors.InvalidBLSSignature();
        }
    }

    /// @notice Compute the aggregated pubkey from a pre-fetched operator list.
    /// @dev Used by `_verifyAggregatedSignature` so the operator-set snapshot
    ///      that goes into the BLS message is the same one used to derive the
    ///      expected pubkey. Avoids a second `_getServiceOperatorList` call
    ///      and any chance of mismatch under concurrent state changes.
    function _computeExpectedAggregatedPubkeyFromList(
        uint64 serviceId,
        uint256 signerBitmap,
        address[] memory operators
    )
        private
        view
        returns (Types.BN254G2Point memory aggregatedPubkey)
    {
        bool firstKey = true;
        for (uint256 i = 0; i < operators.length; i++) {
            if ((signerBitmap >> i) & 1 == 1) {
                Types.BLSPubkey storage storedKey = _serviceOperatorBlsPubkeys[serviceId][operators[i]];
                if (storedKey.key[0] == 0 && storedKey.key[1] == 0 && storedKey.key[2] == 0 && storedKey.key[3] == 0) {
                    revert Errors.OperatorBlsPubkeyNotRegistered(serviceId, operators[i]);
                }
                Types.BN254G2Point memory operatorPubkey =
                    Types.BN254G2Point([storedKey.key[0], storedKey.key[1]], [storedKey.key[2], storedKey.key[3]]);
                if (firstKey) {
                    aggregatedPubkey = operatorPubkey;
                    firstKey = false;
                } else {
                    aggregatedPubkey = BN254.addG2(aggregatedPubkey, operatorPubkey);
                }
            }
        }
    }

    /// @notice Compute the expected aggregated public key from registered operator BLS keys
    /// @dev Iterates through the signerBitmap and aggregates (adds) the BLS pubkeys of signers
    /// @param serviceId The service ID
    /// @param signerBitmap Bitmap indicating which operators signed
    /// @return aggregatedPubkey The aggregated G2 public key
    function _computeExpectedAggregatedPubkey(
        uint64 serviceId,
        uint256 signerBitmap
    )
        private
        view
        returns (Types.BN254G2Point memory aggregatedPubkey)
    {
        address[] memory operators = _getServiceOperatorList(serviceId);
        bool firstKey = true;

        for (uint256 i = 0; i < operators.length; i++) {
            if ((signerBitmap >> i) & 1 == 1) {
                // This operator is marked as a signer in the bitmap
                Types.BLSPubkey storage storedKey = _serviceOperatorBlsPubkeys[serviceId][operators[i]];

                // Verify the operator has a BLS key registered for this service
                // A key is considered "not registered" if all components are zero
                if (storedKey.key[0] == 0 && storedKey.key[1] == 0 && storedKey.key[2] == 0 && storedKey.key[3] == 0) {
                    revert Errors.OperatorBlsPubkeyNotRegistered(serviceId, operators[i]);
                }

                Types.BN254G2Point memory operatorPubkey =
                    Types.BN254G2Point([storedKey.key[0], storedKey.key[1]], [storedKey.key[2], storedKey.key[3]]);

                if (firstKey) {
                    aggregatedPubkey = operatorPubkey;
                    firstKey = false;
                } else {
                    // Add this operator's pubkey to the aggregated pubkey
                    aggregatedPubkey = BN254.addG2(aggregatedPubkey, operatorPubkey);
                }
            }
        }

        // If no signers were found (empty bitmap with all inactive operators),
        // the aggregatedPubkey will be all zeros (point at infinity)
    }

    function _validateServiceForAggregatedResult(Types.Service storage svc, uint64 serviceId) private view {
        if (svc.status != Types.ServiceStatus.Active) {
            revert Errors.ServiceNotActive(serviceId);
        }
        if (svc.ttl > 0 && block.timestamp > svc.createdAt + svc.ttl) {
            revert Errors.ServiceExpired(serviceId);
        }
    }

    function _ceilDiv(uint256 numerator, uint256 denominator) private pure returns (uint256) {
        if (numerator == 0) return 0;
        return ((numerator - 1) / denominator) + 1;
    }

    function _jobSchema(
        uint64 blueprintId,
        uint8 jobIndex
    )
        internal
        view
        returns (Types.StoredJobSchema storage schema)
    {
        Types.StoredJobSchema[] storage schemas = _blueprintJobSchemas[blueprintId];
        if (jobIndex >= schemas.length) {
            revert Errors.InvalidJobIndex(jobIndex);
        }
        return schemas[jobIndex];
    }

    /// @notice Get the list of operators for a service (to be implemented by child contract)
    function _getServiceOperatorList(uint64 serviceId) internal view virtual returns (address[] memory);

    /// @notice Distribute payment for completed job - to be implemented in Payments mixin
    function _distributeJobPayment(uint64 serviceId, uint256 payment) internal virtual;

    /// @notice Distribute payment for RFQ job to quoted operators at their individual prices
    function _distributeRFQJobPayment(uint64 serviceId, uint64 callId, uint256 totalPayment) internal virtual;
}
