// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { IRemoteChainBridgeManager } from "../interfaces/IRemoteChainBridgeManager.sol";
import { ICrossChainDelegatorMessage } from "../interfaces/ICrossChainDelegatorMessage.sol";
import { CrossChainDelegatorMessage } from "../libs/CrossChainDelegatorMessage.sol";
import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract RemoteRestakeVault {
    using SafeERC20 for IERC20;
    using CrossChainDelegatorMessage for *;
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.Bytes32Set;

    IRemoteChainBridgeManager public immutable bridgeManager;

    // Core state tracking
    mapping(address => mapping(address => uint256)) public userDeposits;
    mapping(address => mapping(address => mapping(bytes32 => uint256))) public userDelegations;
    mapping(address => mapping(address => mapping(bytes32 => uint256))) public userUnstaking;
    mapping(address => mapping(address => uint256)) public userWithdrawals;

    // Enumerable sets for efficient iteration
    EnumerableSet.AddressSet private knownTokens;
    EnumerableSet.AddressSet private knownDelegators;
    EnumerableSet.Bytes32Set private knownOperators;

    // Operator tracking for efficient slashing
    mapping(bytes32 => mapping(address => bool)) public operatorTokens;
    mapping(bytes32 => mapping(address => mapping(address => bool))) public operatorDelegators;

    // Trusted receivers for cross-chain messages
    mapping(address => bool) public trustedReceivers;

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
    event TrustedReceiverUpdated(address indexed receiver, bool trusted);

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

    modifier onlyTrustedReceiver() {
        if (!trustedReceivers[msg.sender]) revert UnauthorizedReceiver();
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

    constructor(address _bridgeManager) {
        if (_bridgeManager == address(0)) revert InvalidBridgeManager();
        bridgeManager = IRemoteChainBridgeManager(_bridgeManager);
    }

    function deposit(address token, uint256 amount, uint256 bridgeId) external payable validToken(token) validAmount(amount) {
        IERC20(token).safeTransferFrom(msg.sender, address(this), amount);
        userDeposits[msg.sender][token] += amount;

        // Track known tokens and delegators
        knownTokens.add(token);
        knownDelegators.add(msg.sender);

        ICrossChainDelegatorMessage.DepositMessage memory message = ICrossChainDelegatorMessage.DepositMessage({
            bridgeId: bridgeId,
            originAsset: uint256(uint160(token)),
            amount: amount,
            sender: bytes32(uint256(uint160(msg.sender)))
        });

        _dispatchMessage(bridgeId, message.encode());
        emit AssetDeposited(token, msg.sender, amount);
    }

    function delegate(
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
        sufficientBalance(token, amount)
    {
        userDeposits[msg.sender][token] -= amount;
        userDelegations[msg.sender][token][operator] += amount;

        // Update tracking sets
        knownOperators.add(operator);
        operatorTokens[operator][token] = true;
        operatorDelegators[operator][token][msg.sender] = true;

        ICrossChainDelegatorMessage.DelegationMessage memory message = ICrossChainDelegatorMessage.DelegationMessage({
            bridgeId: bridgeId,
            originAsset: uint256(uint160(token)),
            amount: amount,
            sender: bytes32(uint256(uint160(msg.sender))),
            operator: operator
        });

        _dispatchMessage(bridgeId, message.encode());
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

        _dispatchMessage(bridgeId, message.encode());
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

        _dispatchMessage(bridgeId, message.encode());
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
        userUnstaking[msg.sender][token][operator] -= amount;
        userDeposits[msg.sender][token] += amount;

        // Clean up operator tracking if no more delegations
        if (userDelegations[msg.sender][token][operator] == 0 && userUnstaking[msg.sender][token][operator] == 0) {
            operatorDelegators[operator][token][msg.sender] = false;
            _cleanupOperatorIfEmpty(operator, token);
        }

        ICrossChainDelegatorMessage.ExecuteUnstakeMessage memory message = ICrossChainDelegatorMessage.ExecuteUnstakeMessage({
            bridgeId: bridgeId,
            originAsset: uint256(uint160(token)),
            amount: amount,
            sender: bytes32(uint256(uint160(msg.sender))),
            operator: operator
        });

        _dispatchMessage(bridgeId, message.encode());
        emit UnstakeExecuted(token, msg.sender, amount, operator);
    }

    function handleSlashMessage(bytes32 operator, uint8 slashPercent) internal validOperator(operator) returns (bool) {
        uint256 length = knownTokens.length();
        for (uint256 i = 0; i < length;) {
            address token = knownTokens.at(i);
            if (operatorTokens[operator][token]) {
                _handleSlashForToken(operator, token, slashPercent);
            }
            unchecked {
                ++i;
            }
        }
        return true;
    }

    function _handleSlashForToken(bytes32 operator, address token, uint8 slashPercent) internal {
        uint256 length = knownDelegators.length();
        for (uint256 i = 0; i < length;) {
            address delegator = knownDelegators.at(i);
            if (operatorDelegators[operator][token][delegator]) {
                uint256 delegatedAmount = userDelegations[delegator][token][operator];
                if (delegatedAmount > 0) {
                    uint256 slashAmount = (delegatedAmount * slashPercent) / 100;
                    if (slashAmount > 0) {
                        userDelegations[delegator][token][operator] -= slashAmount;
                        IERC20(token).safeTransfer(address(0), slashAmount);
                        emit TokensSlashed(token, operator, delegator, slashAmount);
                    }
                }
            }
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

    function _dispatchMessage(uint256 bridgeId, bytes memory message) internal {
        uint256 requiredFee = bridgeId != 0 ? bridgeManager.getMessageFee(bridgeId, message) : msg.value;

        try bridgeManager.dispatchMessage{ value: requiredFee }(message) {
            // Success case handled by events
        } catch {
            revert BridgeDispatchFailed();
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

    // Admin functions
    function setTrustedReceiver(address receiver, bool trusted) external validRecipient(receiver) {
        trustedReceivers[receiver] = trusted;
        emit TrustedReceiverUpdated(receiver, trusted);
    }
}
