// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { AccessControlUpgradeable } from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import { ReentrancyGuardUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import { Types } from "../libraries/Types.sol";
import { ITangleSecurityView } from "../interfaces/ITangleSecurityView.sol";
import { IStreamingPaymentManager } from "../interfaces/IStreamingPaymentManager.sol";

/// @title StreamingPaymentManager
/// @notice Manages streaming payments that distribute over service TTL
/// @dev Extracted from ServiceFeeDistributor to reduce contract size
contract StreamingPaymentManager is
    Initializable,
    UUPSUpgradeable,
    AccessControlUpgradeable,
    ReentrancyGuardUpgradeable,
    IStreamingPaymentManager
{
    using SafeERC20 for IERC20;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    bytes32 public constant DISTRIBUTOR_ROLE = keccak256("DISTRIBUTOR_ROLE");

    /// @notice Tangle contract for service queries
    address public tangle;

    /// @notice ServiceFeeDistributor that receives dripped chunks
    address public distributor;

    /// @notice Streaming payment for a service.
    /// @dev `serviceId`/`operator` are the mapping keys (see `streamingPayments`), so they are
    ///      not duplicated in the struct; callers pass them explicitly and the getter echoes them.
    struct StreamingPayment {
        uint64 blueprintId;
        address paymentToken;
        uint256 totalAmount;
        uint256 distributed;
        uint64 startTime;
        uint64 endTime;
        uint64 lastDripTime;
    }

    /// @notice serviceId => operator => StreamingPayment
    mapping(uint64 => mapping(address => StreamingPayment)) public streamingPayments;

    /// @notice Track active streams per operator for drip iteration
    mapping(address => uint64[]) private _operatorActiveStreams;
    mapping(address => mapping(uint64 => uint256)) private _operatorStreamIndex;

    event StreamingPaymentCreated(
        uint64 indexed serviceId,
        address indexed operator,
        address paymentToken,
        uint256 amount,
        uint64 startTime,
        uint64 endTime
    );

    event StreamingDrip(uint64 indexed serviceId, address indexed operator, uint256 amount, uint256 totalDistributed);

    event StreamingPaymentCompleted(uint64 indexed serviceId, address indexed operator, uint256 totalAmount);

    event StreamingPaymentCancelled(
        uint64 indexed serviceId, address indexed operator, uint256 refundedAmount, address refundRecipient
    );

    event TangleConfigured(address indexed tangle);
    event DistributorConfigured(address indexed distributor);

    /// @notice Emitted when a stream has drippable funds available
    /// @dev Blueprint managers should listen for this to trigger drip operations
    /// @param operator The operator with pending drips
    /// @param pendingAmount Approximate amount available to drip
    /// @param streamCount Number of active streams for this operator
    event StreamDripAvailable(address indexed operator, uint256 pendingAmount, uint256 streamCount);

    error NotTangle();
    error NotDistributor();
    error NotAuthorized();

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address admin, address tangle_, address distributor_) external initializer {
        __UUPSUpgradeable_init();
        __AccessControl_init();
        __ReentrancyGuard_init();

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ADMIN_ROLE, admin);
        _grantRole(UPGRADER_ROLE, admin);
        _grantRole(DISTRIBUTOR_ROLE, distributor_);

        tangle = tangle_;
        distributor = distributor_;

        emit TangleConfigured(tangle_);
        emit DistributorConfigured(distributor_);
    }

    function setTangle(address tangle_) external onlyRole(ADMIN_ROLE) {
        tangle = tangle_;
        emit TangleConfigured(tangle_);
    }

    function setDistributor(address distributor_) external onlyRole(ADMIN_ROLE) {
        distributor = distributor_;
        emit DistributorConfigured(distributor_);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // STREAM CREATION (called by ServiceFeeDistributor)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Create a streaming payment for a service
    /// @dev Only callable by the ServiceFeeDistributor
    function createStream(
        uint64 serviceId,
        uint64 blueprintId,
        address operator,
        address paymentToken,
        uint256 amount,
        uint64 startTime,
        uint64 endTime
    )
        external
        payable
        override
        onlyRole(DISTRIBUTOR_ROLE)
    {
        if (amount == 0) return;
        if (endTime <= startTime) return;

        StreamingPayment storage existing = streamingPayments[serviceId][operator];

        // If there's an existing stream for this service/operator, drip it first
        if (existing.totalAmount > 0 && existing.distributed < existing.totalAmount) {
            _drip(serviceId, operator);
        }

        // If extending an existing stream, add to it
        if (existing.totalAmount > 0 && existing.endTime == startTime) {
            existing.totalAmount += amount;
            existing.endTime = endTime;
            emit StreamingPaymentCreated(serviceId, operator, paymentToken, amount, startTime, endTime);
            return;
        }

        // Create new stream
        streamingPayments[serviceId][operator] = StreamingPayment({
            blueprintId: blueprintId,
            paymentToken: paymentToken,
            totalAmount: amount,
            distributed: 0,
            startTime: startTime,
            endTime: endTime,
            lastDripTime: startTime
        });

        // Track active stream for operator
        if (_operatorStreamIndex[operator][serviceId] == 0) {
            _operatorActiveStreams[operator].push(serviceId);
            _operatorStreamIndex[operator][serviceId] = _operatorActiveStreams[operator].length;
        }

        emit StreamingPaymentCreated(serviceId, operator, paymentToken, amount, startTime, endTime);

        // Signal to keepers that this operator will have drippable funds
        emit StreamDripAvailable(operator, amount, _operatorActiveStreams[operator].length);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // DRIP FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Drip pending payment chunk from a streaming payment
    /// @return dripped The amount dripped
    function _drip(uint64 serviceId, address operator) internal returns (uint256 dripped) {
        StreamingPayment storage p = streamingPayments[serviceId][operator];

        // Cache the struct fields read multiple times into memory locals (each is a warm/cold
        // SLOAD otherwise). Semantics are preserved: none of these fields is mutated between the
        // reads below, and the only writes (`distributed`, `lastDripTime`) happen after all reads.
        uint256 totalAmount = p.totalAmount;
        uint256 distributed = p.distributed;
        uint64 startTime = p.startTime;
        uint64 endTime = p.endTime;
        uint64 lastDripTime = p.lastDripTime;

        if (totalAmount == 0) return 0;
        if (distributed >= totalAmount) return 0;
        if (block.timestamp <= startTime) return 0;

        uint64 currentTime = uint64(block.timestamp);
        if (currentTime > endTime) {
            currentTime = endTime;
        }

        if (currentTime <= lastDripTime) return 0;

        uint256 elapsed = currentTime - lastDripTime;
        uint256 duration = endTime - startTime;
        uint256 remaining = totalAmount - distributed;

        uint256 chunk = (totalAmount * elapsed) / duration;
        if (chunk > remaining) {
            chunk = remaining;
        }
        if (chunk == 0) return 0;

        uint256 newDistributed = distributed + chunk;
        p.distributed = newDistributed;
        p.lastDripTime = currentTime;

        emit StreamingDrip(serviceId, operator, chunk, newDistributed);

        if (newDistributed >= totalAmount) {
            _removeActiveStream(operator, serviceId);
            emit StreamingPaymentCompleted(serviceId, operator, totalAmount);
        }

        return chunk;
    }

    /// @notice Drip a specific stream and return chunk info for distribution.
    /// @dev `nonReentrant` is load-bearing: without it, a re-entrant call from the
    ///      transfer hook (or a same-tx call to `dripOperatorStreams`) would observe
    ///      `lastDripTime == block.timestamp` only after the first call mutated it,
    ///      but the second call could otherwise re-enter and process additional state
    ///      before the first frame finishes. Combined with timestamp-granular dripping
    ///      this also closes the same-block double-drip race.
    function dripAndGetChunk(
        uint64 serviceId,
        address operator
    )
        external
        override
        onlyRole(DISTRIBUTOR_ROLE)
        nonReentrant
        returns (uint256 amount, uint64 blueprintId, address paymentToken)
    {
        StreamingPayment storage p = streamingPayments[serviceId][operator];
        blueprintId = p.blueprintId;
        paymentToken = p.paymentToken;
        amount = _drip(serviceId, operator);

        // Transfer dripped tokens to distributor for score-based distribution
        if (amount > 0) {
            _transferPayment(payable(msg.sender), paymentToken, amount);
        }
    }

    /// @notice Drip all active streams for an operator.
    /// @dev `nonReentrant` mutex prevents `dripOperatorStreams` and `dripAndGetChunk`
    ///      from executing in the same transaction. Without it, two distributor calls
    ///      in the same block would each compute the same elapsed-time window and pay
    ///      the chunk twice.
    function dripOperatorStreams(address operator)
        external
        override
        onlyRole(DISTRIBUTOR_ROLE)
        nonReentrant
        returns (
            uint64[] memory serviceIds,
            uint64[] memory blueprintIds,
            address[] memory paymentTokens,
            uint256[] memory amounts
        )
    {
        uint64[] storage streams = _operatorActiveStreams[operator];
        uint256 len = streams.length;

        serviceIds = new uint64[](len);
        blueprintIds = new uint64[](len);
        paymentTokens = new address[](len);
        amounts = new uint256[](len);

        // Iterate backwards to handle removals safely
        for (uint256 i = len; i > 0;) {
            uint256 idx = i - 1;
            uint64 svcId = streams[idx];
            StreamingPayment storage p = streamingPayments[svcId][operator];

            // Cache `paymentToken` once: `_drip` never writes this field, so the value read here
            // is identical to a re-read after the drip (removes the second SLOAD at the transfer).
            address token = p.paymentToken;
            serviceIds[idx] = svcId;
            blueprintIds[idx] = p.blueprintId;
            paymentTokens[idx] = token;
            uint256 amt = _drip(svcId, operator);
            amounts[idx] = amt;

            // Transfer dripped tokens to distributor
            if (amt > 0) {
                _transferPayment(payable(msg.sender), token, amt);
            }

            // `i` decrements from `len` to 1; the loop guard (`i > 0`) proves no underflow.
            unchecked {
                --i;
            }
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SERVICE TERMINATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Called when a service is terminated - refunds remaining payments
    /// @dev Can be called by either Tangle directly or via ServiceFeeDistributor
    function onServiceTerminated(uint64 serviceId, address refundRecipient) external override nonReentrant {
        if (msg.sender != tangle && msg.sender != distributor) revert NotAuthorized();
        if (refundRecipient == address(0)) return;

        address[] memory operators = ITangleSecurityView(tangle).getServiceOperators(serviceId);

        for (uint256 i = 0; i < operators.length; i++) {
            address operator = operators[i];
            StreamingPayment storage p = streamingPayments[serviceId][operator];

            if (p.totalAmount == 0) continue;

            // Drip any pending amount up to now. The freshly-dripped chunk is earned
            // payment that must be forwarded to the distributor for score-based payout —
            // otherwise `_drip()` would mark it `distributed` while the tokens stay locked
            // here, and it would also be excluded from the `remaining` refund below.
            uint256 dripped = _drip(serviceId, operator);
            if (dripped > 0) {
                _transferPayment(payable(distributor), p.paymentToken, dripped);
            }

            uint256 remaining = p.totalAmount - p.distributed;
            if (remaining == 0) continue;

            p.distributed = p.totalAmount;
            _removeActiveStream(operator, serviceId);

            _transferPayment(payable(refundRecipient), p.paymentToken, remaining);

            emit StreamingPaymentCancelled(serviceId, operator, remaining, refundRecipient);
        }
    }

    /// @notice Called when an operator is leaving a service
    /// @dev Drips earned payment up to the leave moment and forwards the freshly-dripped
    ///      chunk to the distributor. Without the transfer, `_drip()` marks the chunk
    ///      `distributed` while the tokens stay stranded in this contract. `nonReentrant`
    ///      matches the other transfer-performing entrypoints.
    function onOperatorLeaving(uint64 serviceId, address operator) external override nonReentrant {
        if (msg.sender != tangle && msg.sender != distributor) revert NotAuthorized();
        StreamingPayment storage p = streamingPayments[serviceId][operator];
        address paymentToken = p.paymentToken;
        uint256 dripped = _drip(serviceId, operator);
        if (dripped > 0) {
            _transferPayment(payable(distributor), paymentToken, dripped);
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // VIEWS
    // ═══════════════════════════════════════════════════════════════════════════

    function getOperatorActiveStreams(address operator) external view override returns (uint64[] memory) {
        return _operatorActiveStreams[operator];
    }

    function getStreamingPayment(
        uint64 serviceId,
        address operator
    )
        external
        view
        override
        returns (
            uint64 _serviceId,
            uint64 blueprintId,
            address _operator,
            address paymentToken,
            uint256 totalAmount,
            uint256 distributed,
            uint64 startTime,
            uint64 endTime,
            uint64 lastDripTime
        )
    {
        StreamingPayment storage p = streamingPayments[serviceId][operator];
        // `serviceId`/`operator` are the mapping keys, echoed back so the ABI is unchanged.
        return (
            serviceId,
            p.blueprintId,
            operator,
            p.paymentToken,
            p.totalAmount,
            p.distributed,
            p.startTime,
            p.endTime,
            p.lastDripTime
        );
    }

    function pendingDrip(uint64 serviceId, address operator) external view override returns (uint256) {
        StreamingPayment storage p = streamingPayments[serviceId][operator];

        if (p.totalAmount == 0) return 0;
        if (p.distributed >= p.totalAmount) return 0;
        if (block.timestamp <= p.startTime) return 0;

        uint64 currentTime = uint64(block.timestamp);
        if (currentTime > p.endTime) {
            currentTime = p.endTime;
        }

        if (currentTime <= p.lastDripTime) return 0;

        uint256 elapsed = currentTime - p.lastDripTime;
        uint256 duration = p.endTime - p.startTime;
        uint256 remaining = p.totalAmount - p.distributed;

        uint256 chunk = (p.totalAmount * elapsed) / duration;
        if (chunk > remaining) {
            chunk = remaining;
        }

        return chunk;
    }

    /// @notice Get total pending drip amount across all streams for an operator
    /// @dev Useful for keepers to check if drip operations are worthwhile
    /// @param operator The operator to check
    /// @return totalPending Total drippable amount, streamCount Number of active streams
    function pendingDripForOperator(address operator)
        external
        view
        returns (uint256 totalPending, uint256 streamCount)
    {
        uint64[] storage streams = _operatorActiveStreams[operator];
        streamCount = streams.length;

        for (uint256 i = 0; i < streamCount; i++) {
            StreamingPayment storage p = streamingPayments[streams[i]][operator];

            if (p.totalAmount == 0) continue;
            if (p.distributed >= p.totalAmount) continue;
            if (block.timestamp <= p.startTime) continue;

            uint64 currentTime = uint64(block.timestamp);
            if (currentTime > p.endTime) {
                currentTime = p.endTime;
            }

            if (currentTime <= p.lastDripTime) continue;

            uint256 elapsed = currentTime - p.lastDripTime;
            uint256 duration = p.endTime - p.startTime;
            uint256 remaining = p.totalAmount - p.distributed;

            uint256 chunk = (p.totalAmount * elapsed) / duration;
            if (chunk > remaining) {
                chunk = remaining;
            }

            totalPending += chunk;
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // INTERNAL
    // ═══════════════════════════════════════════════════════════════════════════

    function _removeActiveStream(address operator, uint64 serviceId) internal {
        uint256 indexPlusOne = _operatorStreamIndex[operator][serviceId];
        if (indexPlusOne == 0) return;

        uint64[] storage arr = _operatorActiveStreams[operator];
        uint256 index = indexPlusOne - 1;
        uint256 lastIndex = arr.length - 1;

        if (index != lastIndex) {
            uint64 lastServiceId = arr[lastIndex];
            arr[index] = lastServiceId;
            _operatorStreamIndex[operator][lastServiceId] = index + 1;
        }

        arr.pop();
        _operatorStreamIndex[operator][serviceId] = 0;
    }

    function _transferPayment(address payable to, address token, uint256 amount) internal {
        if (amount == 0) return;
        if (token == address(0)) {
            (bool ok,) = to.call{ value: amount }("");
            require(ok, "eth transfer failed");
        } else {
            IERC20(token).safeTransfer(to, amount);
        }
    }

    function _authorizeUpgrade(address) internal override onlyRole(UPGRADER_ROLE) { }

    /// @notice Receive ETH for native token streams
    receive() external payable { }

    /// @dev Reserved storage slots for future upgrades (Round 2 storage F-3).
    uint256[50] private __gap;
}
