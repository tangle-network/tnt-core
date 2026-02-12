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

    /// @notice Streaming payment for a service
    struct StreamingPayment {
        uint64 serviceId;
        uint64 blueprintId;
        address operator;
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
            serviceId: serviceId,
            blueprintId: blueprintId,
            operator: operator,
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
    /// @return dripped The amount dripped, durationSeconds The time period covered
    function _drip(uint64 serviceId, address operator) internal returns (uint256 dripped, uint256 durationSeconds) {
        StreamingPayment storage p = streamingPayments[serviceId][operator];

        if (p.totalAmount == 0) return (0, 0);
        if (p.distributed >= p.totalAmount) return (0, 0);
        if (block.timestamp <= p.startTime) return (0, 0);

        uint64 currentTime = uint64(block.timestamp);
        if (currentTime > p.endTime) {
            currentTime = p.endTime;
        }

        if (currentTime <= p.lastDripTime) return (0, 0);

        durationSeconds = currentTime - p.lastDripTime;
        uint256 duration = p.endTime - p.startTime;
        uint256 remaining = p.totalAmount - p.distributed;

        uint256 chunk = (p.totalAmount * durationSeconds) / duration;
        if (chunk > remaining) {
            chunk = remaining;
        }
        if (chunk == 0) return (0, 0);

        p.distributed += chunk;
        p.lastDripTime = currentTime;

        emit StreamingDrip(serviceId, operator, chunk, p.distributed);

        if (p.distributed >= p.totalAmount) {
            _removeActiveStream(operator, serviceId);
            emit StreamingPaymentCompleted(serviceId, operator, p.totalAmount);
        }

        return (chunk, durationSeconds);
    }

    /// @notice Drip a specific stream and return chunk info for distribution
    /// @dev Called by ServiceFeeDistributor to get the drip amount. Transfers dripped tokens to caller.
    function dripAndGetChunk(
        uint64 serviceId,
        address operator
    )
        external
        override
        onlyRole(DISTRIBUTOR_ROLE)
        returns (uint256 amount, uint256 durationSeconds, uint64 blueprintId, address paymentToken)
    {
        StreamingPayment storage p = streamingPayments[serviceId][operator];
        blueprintId = p.blueprintId;
        paymentToken = p.paymentToken;
        (amount, durationSeconds) = _drip(serviceId, operator);

        // Transfer dripped tokens to distributor for score-based distribution
        if (amount > 0) {
            _transferPayment(payable(msg.sender), paymentToken, amount);
        }
    }

    /// @notice Drip all active streams for an operator
    /// @dev Called by ServiceFeeDistributor before score changes. Transfers dripped tokens to caller.
    function dripOperatorStreams(address operator)
        external
        override
        onlyRole(DISTRIBUTOR_ROLE)
        returns (
            uint64[] memory serviceIds,
            uint64[] memory blueprintIds,
            address[] memory paymentTokens,
            uint256[] memory amounts,
            uint256[] memory durations
        )
    {
        uint64[] storage streams = _operatorActiveStreams[operator];
        uint256 len = streams.length;

        serviceIds = new uint64[](len);
        blueprintIds = new uint64[](len);
        paymentTokens = new address[](len);
        amounts = new uint256[](len);
        durations = new uint256[](len);

        // Iterate backwards to handle removals safely
        for (uint256 i = len; i > 0; i--) {
            uint256 idx = i - 1;
            uint64 svcId = streams[idx];
            StreamingPayment storage p = streamingPayments[svcId][operator];

            serviceIds[idx] = svcId;
            blueprintIds[idx] = p.blueprintId;
            paymentTokens[idx] = p.paymentToken;
            (amounts[idx], durations[idx]) = _drip(svcId, operator);

            // Transfer dripped tokens to distributor
            if (amounts[idx] > 0) {
                _transferPayment(payable(msg.sender), p.paymentToken, amounts[idx]);
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

            // Drip any pending amount up to now
            _drip(serviceId, operator);

            uint256 remaining = p.totalAmount - p.distributed;
            if (remaining == 0) continue;

            p.distributed = p.totalAmount;
            _removeActiveStream(operator, serviceId);

            _transferPayment(payable(refundRecipient), p.paymentToken, remaining);

            emit StreamingPaymentCancelled(serviceId, operator, remaining, refundRecipient);
        }
    }

    /// @notice Called when an operator is leaving a service
    function onOperatorLeaving(uint64 serviceId, address operator) external override {
        if (msg.sender != tangle && msg.sender != distributor) revert NotAuthorized();
        _drip(serviceId, operator);
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
        return (
            p.serviceId,
            p.blueprintId,
            p.operator,
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
}
