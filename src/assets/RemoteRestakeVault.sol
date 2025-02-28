// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { ICrossChainDelegatorMessage } from "../interfaces/ICrossChainDelegatorMessage.sol";
import { CrossChainDelegatorMessage } from "../libs/CrossChainDelegatorMessage.sol";
import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import { XCBridge } from "../cross_chain/XCBridge.sol";

contract RemoteRestakeVault is XCBridge {
    using SafeERC20 for IERC20;
    using CrossChainDelegatorMessage for *;
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.Bytes32Set;

    // Core state tracking
    mapping(address => mapping(address => uint256)) public userDeposits;
    mapping(address => mapping(address => mapping(bytes32 => uint256))) public userDelegations;
    mapping(address => mapping(address => mapping(bytes32 => uint256))) public userUnstaking;
    mapping(address => mapping(address => uint256)) public userWithdrawals;

    // Blueprint selection tracking
    mapping(address staker => mapping(bytes32 operator => mapping(uint64 blueprintId => uint256 amount))) public boundToBlueprint;

    // Enumerable sets for efficient iteration
    EnumerableSet.AddressSet private knownTokens;
    EnumerableSet.AddressSet private knownDelegators;
    EnumerableSet.Bytes32Set private knownOperators;

    // Operator tracking for efficient slashing
    mapping(bytes32 => mapping(address => bool)) public operatorTokens;
    mapping(bytes32 => mapping(address => mapping(address => bool))) public operatorDelegators;

    error InvalidBridgeManager();
    error InvalidAmount();
    error InvalidToken();
    error InsufficientBalance();
    error InsufficientDelegation();
    error InsufficientUnstaking();
    error InsufficientWithdrawal();
    error BridgeDispatchFailed();
    error InvalidRecipient();
    error InvalidOperator();
    error UnauthorizedReceiver();

    event AssetDeposited(address indexed token, address indexed sender, uint256 amount);
    event DelegationUpdated(address indexed token, address indexed sender, uint256 amount, bytes32 indexed operator);
    event UnstakeScheduled(address indexed token, address indexed sender, uint256 amount, bytes32 indexed operator);
    event UnstakeCancelled(address indexed token, address indexed sender, uint256 amount, bytes32 indexed operator);
    event UnstakeExecuted(address indexed token, address indexed sender, uint256 amount, bytes32 indexed operator);
    event WithdrawalScheduled(address indexed token, address indexed sender, uint256 amount);
    event WithdrawalCancelled(address indexed token, address indexed sender, uint256 amount);
    event WithdrawalExecuted(address indexed token, address indexed sender, address indexed recipient, uint256 amount);
    event TokensSlashed(address indexed token, bytes32 indexed operator, address indexed delegator, uint256 amount);

    modifier validToken(address token) {
        if (token == address(0)) revert InvalidToken();
        _;
    }

    modifier validAmount(uint256 amount) {
        if (amount == 0) revert InvalidAmount();
        _;
    }

    modifier validOperator(bytes32 operator) {
        if (operator == bytes32(0)) revert InvalidOperator();
        _;
    }

    modifier validRecipient(address recipient) {
        if (recipient == address(0)) revert InvalidRecipient();
        _;
    }

    modifier sufficientBalance(address token, uint256 amount) {
        if (userDeposits[msg.sender][token] < amount) revert InsufficientBalance();
        _;
    }

    modifier sufficientDelegation(address token, bytes32 operator, uint256 amount) {
        if (userDelegations[msg.sender][token][operator] < amount) revert InsufficientDelegation();
        _;
    }

    modifier sufficientUnstaking(address token, bytes32 operator, uint256 amount) {
        if (userUnstaking[msg.sender][token][operator] < amount) revert InsufficientUnstaking();
        _;
    }

    function deposit(
        address token,
        uint256 amount,
        uint256 bridgeId,
        uint8 lockMultiplier
    )
        external
        payable
        validToken(token)
        validAmount(amount)
    {
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        userDeposits[msg.sender][token] += amount;

        // Track known tokens and delegators
        knownTokens.add(token);
        knownDelegators.add(msg.sender);

        ICrossChainDelegatorMessage.DepositMessage memory message = ICrossChainDelegatorMessage.DepositMessage({
            bridgeId: bridgeId,
            originAsset: uint256(uint160(token)),
            amount: amount,
            sender: bytes32(uint256(uint160(msg.sender))),
            lockMultiplier: lockMultiplier
        });

        _sendMessage(message.encode(), bridgeId);
        emit AssetDeposited(token, msg.sender, amount);
    }

    function delegate(
        address token,
        uint256 amount,
        uint256 bridgeId,
        bytes32 operator,
        uint64[] memory blueprintSelection
    )
        external
        payable
        validToken(token)
        validAmount(amount)
        validOperator(operator)
        sufficientBalance(token, amount)
    {
        userDeposits[msg.sender][token] -= amount;
        userDelegations[msg.sender][token][operator] += amount;

        // Update tracking sets
        knownOperators.add(operator);
        operatorTokens[operator][token] = true;
        operatorDelegators[operator][token][msg.sender] = true;

        // Update blueprint selection tracking
        for (uint256 i = 0; i < blueprintSelection.length;) {
            uint64 blueprintId = blueprintSelection[i];
            boundToBlueprint[msg.sender][operator][blueprintId] += amount;
            unchecked {
                ++i;
            }
        }

        ICrossChainDelegatorMessage.DelegationMessage memory message = ICrossChainDelegatorMessage.DelegationMessage({
            bridgeId: bridgeId,
            originAsset: uint256(uint160(token)),
            amount: amount,
            sender: bytes32(uint256(uint160(msg.sender))),
            operator: operator,
            blueprintSelection: blueprintSelection
        });

        _sendMessage(message.encode(), bridgeId);
        emit DelegationUpdated(token, msg.sender, amount, operator);
    }

    function scheduleUnstake(
        address token,
        uint256 amount,
        uint256 bridgeId,
        bytes32 operator
    )
        external
        payable
        validToken(token)
        validAmount(amount)
        validOperator(operator)
        sufficientDelegation(token, operator, amount)
    {
        userDelegations[msg.sender][token][operator] -= amount;
        userUnstaking[msg.sender][token][operator] += amount;

        ICrossChainDelegatorMessage.ScheduleUnstakeMessage memory message = ICrossChainDelegatorMessage.ScheduleUnstakeMessage({
            bridgeId: bridgeId,
            originAsset: uint256(uint160(token)),
            amount: amount,
            sender: bytes32(uint256(uint160(msg.sender))),
            operator: operator
        });

        _sendMessage(message.encode(), bridgeId);
        emit UnstakeScheduled(token, msg.sender, amount, operator);
    }

    function cancelUnstake(
        address token,
        uint256 amount,
        uint256 bridgeId,
        bytes32 operator
    )
        external
        payable
        validToken(token)
        validAmount(amount)
        validOperator(operator)
        sufficientUnstaking(token, operator, amount)
    {
        userUnstaking[msg.sender][token][operator] -= amount;
        userDelegations[msg.sender][token][operator] += amount;

        ICrossChainDelegatorMessage.CancelUnstakeMessage memory message = ICrossChainDelegatorMessage.CancelUnstakeMessage({
            bridgeId: bridgeId,
            originAsset: uint256(uint160(token)),
            amount: amount,
            sender: bytes32(uint256(uint160(msg.sender))),
            operator: operator
        });

        _sendMessage(message.encode(), bridgeId);
        emit UnstakeCancelled(token, msg.sender, amount, operator);
    }

    function executeUnstake(
        address token,
        uint256 amount,
        uint256 bridgeId,
        bytes32 operator
    )
        external
        payable
        validToken(token)
        validAmount(amount)
        validOperator(operator)
        sufficientUnstaking(token, operator, amount)
    {
        ICrossChainDelegatorMessage.ExecuteUnstakeMessage memory message = ICrossChainDelegatorMessage.ExecuteUnstakeMessage({
            bridgeId: bridgeId,
            originAsset: uint256(uint160(token)),
            amount: amount,
            sender: bytes32(uint256(uint160(msg.sender))),
            operator: operator
        });

        _sendMessage(message.encode(), bridgeId);
    }

    function scheduleWithdrawal(
        address token,
        uint256 amount,
        uint256 bridgeId
    )
        external
        payable
        validToken(token)
        validAmount(amount)
    {
        userWithdrawals[msg.sender][token] += amount;
        userDeposits[msg.sender][token] -= amount;

        ICrossChainDelegatorMessage.ScheduleWithdrawalMessage memory message = ICrossChainDelegatorMessage.ScheduleWithdrawalMessage({
            bridgeId: bridgeId,
            originAsset: uint256(uint160(token)),
            amount: amount,
            sender: bytes32(uint256(uint160(msg.sender)))
        });

        _sendMessage(message.encode(), bridgeId);
        emit WithdrawalScheduled(token, msg.sender, amount);
    }

    function cancelWithdrawal(
        address token,
        uint256 amount,
        uint256 bridgeId
    )
        external
        payable
        validToken(token)
        validAmount(amount)
    {
        userWithdrawals[msg.sender][token] -= amount;
        userDeposits[msg.sender][token] += amount;

        ICrossChainDelegatorMessage.CancelWithdrawalMessage memory message = ICrossChainDelegatorMessage.CancelWithdrawalMessage({
            bridgeId: bridgeId,
            originAsset: uint256(uint160(token)),
            amount: amount,
            sender: bytes32(uint256(uint160(msg.sender)))
        });

        _sendMessage(message.encode(), bridgeId);
        emit WithdrawalCancelled(token, msg.sender, amount);
    }

    function executeWithdrawal(
        address token,
        uint256 amount,
        uint256 bridgeId,
        address recipient
    )
        external
        payable
        validToken(token)
        validAmount(amount)
    {
        ICrossChainDelegatorMessage.ExecuteWithdrawalMessage memory message = ICrossChainDelegatorMessage.ExecuteWithdrawalMessage({
            bridgeId: bridgeId,
            originAsset: uint256(uint160(token)),
            amount: amount,
            sender: bytes32(uint256(uint160(msg.sender))),
            recipient: bytes32(uint256(uint160(recipient)))
        });

        _sendMessage(message.encode(), bridgeId);
    }

    fallback() external {
        _receiveMessage(msg.sender, msg.data, _processMessage);
    }

    function _processMessage(uint256, bytes calldata _message) internal {
        uint8 messageType = CrossChainDelegatorMessage.getMessageType(_message);
        bytes calldata payload = _message[1:];

        if (messageType == CrossChainDelegatorMessage.WITHDRAWAL_EXECUTED_MESSAGE) {
            _handleExecutedWithdrawalMessage(payload);
        } else if (messageType == CrossChainDelegatorMessage.UNSTAKE_EXECUTED_MESSAGE) {
            _handleExecutedUnstakeMessage(payload);
        }
    }

    function _handleExecutedWithdrawalMessage(bytes calldata _payload) internal {
        ICrossChainDelegatorMessage.WithdrawalExecutedMessage memory message =
            CrossChainDelegatorMessage.decodeWithdrawalExecutedMessage(_payload);
        address token = address(uint160(message.originAsset));
        address sender = address(bytes20(message.sender));
        address recipient = address(bytes20(message.recipient));

        userWithdrawals[sender][token] -= message.amount;

        IERC20(token).safeTransfer(recipient, message.amount);

        emit WithdrawalExecuted(token, sender, recipient, message.amount);
    }

    function _handleExecutedUnstakeMessage(bytes calldata _payload) internal {
        ICrossChainDelegatorMessage.UnstakeExecutedMessage memory message =
            CrossChainDelegatorMessage.decodeUnstakeExecutedMessage(_payload);
        address token = address(uint160(message.originAsset));
        address sender = address(bytes20(message.sender));

        userUnstaking[sender][token][message.operator] -= message.amount;
        userDeposits[sender][token] += message.amount;

        // Clean up operator tracking if no more delegations
        if (userDelegations[sender][token][message.operator] == 0 && userUnstaking[sender][token][message.operator] == 0) {
            operatorDelegators[message.operator][token][sender] = false;
            _cleanupOperatorIfEmpty(message.operator, token);
        }

        for (uint256 i = 0; i < message.slashes.length;) {
            _handleSlash(message.operator, message.slashes[i].slashAmount, message.slashes[i].blueprintId);
            unchecked {
                ++i;
            }
        }

        emit UnstakeExecuted(token, sender, message.amount, message.operator);
    }

    function _handleSlash(bytes32 operator, uint256 slashAmount, uint64 blueprintId) internal {
        uint256 length = knownTokens.length();
        for (uint256 i = 0; i < length;) {
            address token = knownTokens.at(i);
            if (operatorTokens[operator][token]) {
                _handleSlashForToken(operator, token, slashAmount, blueprintId);
            }
            unchecked {
                ++i;
            }
        }
    }

    function _handleSlashForToken(bytes32 operator, address token, uint256 slashAmount, uint64 blueprintId) internal {
        if (slashAmount == 0) return;

        uint256 length = knownDelegators.length();
        for (uint256 i = 0; i < length;) {
            address delegator = knownDelegators.at(i);

            if (!operatorDelegators[operator][token][delegator]) return;

            uint256 delegatedAmount = userDelegations[delegator][token][operator];
            if (delegatedAmount == 0) return;

            uint256 blueprintAmount = boundToBlueprint[delegator][operator][blueprintId];
            if (blueprintAmount == 0) return;

            userDelegations[delegator][token][operator] -= slashAmount;
            boundToBlueprint[delegator][operator][blueprintId] -= slashAmount;
            IERC20(token).safeTransfer(address(0), slashAmount);
            emit TokensSlashed(token, operator, delegator, slashAmount);

            unchecked {
                ++i;
            }
        }
    }

    function _cleanupOperatorIfEmpty(bytes32 operator, address token) internal {
        uint256 length = knownDelegators.length();
        bool hasActiveDelegators = false;

        for (uint256 i = 0; i < length && !hasActiveDelegators;) {
            address delegator = knownDelegators.at(i);
            if (operatorDelegators[operator][token][delegator]) {
                hasActiveDelegators = true;
            }
            unchecked {
                ++i;
            }
        }

        if (!hasActiveDelegators) {
            operatorTokens[operator][token] = false;
            _cleanupOperatorIfNoTokens(operator);
        }
    }

    function _cleanupOperatorIfNoTokens(bytes32 operator) internal {
        uint256 length = knownTokens.length();
        bool hasActiveTokens = false;

        for (uint256 i = 0; i < length && !hasActiveTokens;) {
            address token = knownTokens.at(i);
            if (operatorTokens[operator][token]) {
                hasActiveTokens = true;
            }
            unchecked {
                ++i;
            }
        }

        if (!hasActiveTokens) {
            knownOperators.remove(operator);
        }
    }

    // View functions
    function getOperatorTokens(bytes32 operator) external view returns (address[] memory) {
        uint256 length = knownTokens.length();
        uint256 count;
        address[] memory tokens = new address[](length);

        for (uint256 i = 0; i < length;) {
            address token = knownTokens.at(i);
            if (operatorTokens[operator][token]) {
                tokens[count] = token;
                unchecked {
                    ++count;
                }
            }
            unchecked {
                ++i;
            }
        }

        assembly {
            mstore(tokens, count)
        }

        return tokens;
    }

    function getOperatorDelegators(bytes32 operator, address token) external view returns (address[] memory) {
        uint256 length = knownDelegators.length();
        uint256 count;
        address[] memory delegators = new address[](length);

        for (uint256 i = 0; i < length;) {
            address delegator = knownDelegators.at(i);
            if (operatorDelegators[operator][token][delegator]) {
                delegators[count] = delegator;
                unchecked {
                    ++count;
                }
            }
            unchecked {
                ++i;
            }
        }

        assembly {
            mstore(delegators, count)
        }

        return delegators;
    }
}
