# Shared Security Interface

The core abstraction enabling protocol-agnostic restaking.

## Interface Design

### ISecurityManager

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title ISecurityManager
/// @notice Abstract interface for any shared security protocol
/// @dev Implement this to integrate with EigenLayer, Symbiotic, or native staking
interface ISecurityManager {
    // ═══════════════════════════════════════════════════════════════════════
    // STRUCTS
    // ═══════════════════════════════════════════════════════════════════════

    struct OperatorInfo {
        bool isRegistered;
        bool isActive;
        uint256 totalStake;           // Across all assets
        uint64 registeredAt;
        uint64 lastActiveAt;
    }

    struct Stake {
        address asset;                 // ERC20 or address(0) for native
        uint256 amount;
        uint256 shares;                // For rebasing assets
    }

    struct Delegation {
        address operator;
        address asset;
        uint256 amount;
        uint64 delegatedAt;
    }

    struct SlashParams {
        address operator;
        uint64 serviceId;
        uint256 amount;                // Amount to slash
        address asset;                 // Asset to slash (or address(0) for any)
        bytes32 evidence;              // IPFS hash or commitment to evidence
    }

    // ═══════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════

    event OperatorRegistered(address indexed operator, uint256 initialStake);
    event OperatorDeregistered(address indexed operator);
    event StakeDeposited(address indexed operator, address indexed asset, uint256 amount);
    event StakeWithdrawn(address indexed operator, address indexed asset, uint256 amount);
    event Delegated(address indexed delegator, address indexed operator, address asset, uint256 amount);
    event Undelegated(address indexed delegator, address indexed operator, address asset, uint256 amount);
    event Slashed(address indexed operator, uint64 indexed serviceId, uint256 amount);

    // ═══════════════════════════════════════════════════════════════════════
    // OPERATOR QUERIES
    // ═══════════════════════════════════════════════════════════════════════

    /// @notice Check if an operator is registered
    function isOperatorRegistered(address operator) external view returns (bool);

    /// @notice Check if an operator is active (online and not leaving)
    function isOperatorActive(address operator) external view returns (bool);

    /// @notice Get full operator info
    function getOperatorInfo(address operator) external view returns (OperatorInfo memory);

    /// @notice Get operator's total stake across all assets
    function getOperatorTotalStake(address operator) external view returns (uint256);

    /// @notice Get operator's stake for a specific asset
    function getOperatorStake(address operator, address asset) external view returns (uint256);

    /// @notice Get all stakes for an operator
    function getOperatorStakes(address operator) external view returns (Stake[] memory);

    /// @notice Get operators registered for a specific blueprint
    function getOperatorsForBlueprint(uint64 blueprintId) external view returns (address[] memory);

    // ═══════════════════════════════════════════════════════════════════════
    // DELEGATION QUERIES
    // ═══════════════════════════════════════════════════════════════════════

    /// @notice Get total delegation to an operator
    function getTotalDelegation(address operator) external view returns (uint256);

    /// @notice Get delegation from a specific delegator to operator
    function getDelegation(address delegator, address operator) external view returns (uint256);

    /// @notice Get all delegations for a delegator
    function getDelegatorDelegations(address delegator) external view returns (Delegation[] memory);

    /// @notice Get all delegators for an operator
    function getOperatorDelegators(address operator) external view returns (address[] memory);

    // ═══════════════════════════════════════════════════════════════════════
    // STAKE REQUIREMENTS
    // ═══════════════════════════════════════════════════════════════════════

    /// @notice Minimum stake required to be an operator
    function minOperatorStake() external view returns (uint256);

    /// @notice Check if operator meets stake requirements for a blueprint
    function meetsStakeRequirement(
        address operator,
        uint64 blueprintId,
        uint256 requiredStake
    ) external view returns (bool);

    /// @notice Get the stake-weighted score for an operator (for selection)
    function getOperatorScore(address operator, uint64 blueprintId) external view returns (uint256);

    // ═══════════════════════════════════════════════════════════════════════
    // SLASHING
    // ═══════════════════════════════════════════════════════════════════════

    /// @notice Execute a slash against an operator
    /// @dev Only callable by authorized slasher (TangleCore or designated contract)
    function slash(SlashParams calldata params) external returns (uint256 slashedAmount);

    /// @notice Get the slashing percentage for a violation type
    function getSlashingRate(bytes32 violationType) external view returns (uint256);

    /// @notice Check if an address is authorized to initiate slashing
    function isSlasher(address account) external view returns (bool);

    // ═══════════════════════════════════════════════════════════════════════
    // REWARDS COORDINATION
    // ═══════════════════════════════════════════════════════════════════════

    /// @notice Notify the security manager of rewards for distribution
    /// @dev Called by TangleCore when service payments are processed
    function notifyReward(
        address operator,
        uint64 serviceId,
        uint256 amount,
        address asset
    ) external;

    /// @notice Get the rewards distributor address
    function rewardsDistributor() external view returns (address);
}
```

### ISecurityManagerAdmin

```solidity
/// @title ISecurityManagerAdmin
/// @notice Admin functions for security manager configuration
interface ISecurityManagerAdmin {
    /// @notice Register an operator (native) or sync from external protocol
    function registerOperator(address operator, bytes calldata data) external;

    /// @notice Deregister an operator
    function deregisterOperator(address operator) external;

    /// @notice Update minimum stake requirement
    function setMinOperatorStake(uint256 amount) external;

    /// @notice Add a supported asset for staking
    function addSupportedAsset(address asset, uint256 minAmount) external;

    /// @notice Remove a supported asset
    function removeSupportedAsset(address asset) external;

    /// @notice Set slashing rate for a violation type
    function setSlashingRate(bytes32 violationType, uint256 rate) external;

    /// @notice Authorize a slasher
    function addSlasher(address slasher) external;

    /// @notice Remove slasher authorization
    function removeSlasher(address slasher) external;
}
```

## Native Implementation

Our own multi-asset delegation system:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ISecurityManager, ISecurityManagerAdmin} from "./ISecurityManager.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {SafeERC20, IERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

contract NativeSecurityManager is
    ISecurityManager,
    ISecurityManagerAdmin,
    AccessControlUpgradeable,
    ReentrancyGuard
{
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeERC20 for IERC20;

    // ═══════════════════════════════════════════════════════════════════════
    // STORAGE
    // ═══════════════════════════════════════════════════════════════════════

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant SLASHER_ROLE = keccak256("SLASHER_ROLE");

    struct OperatorData {
        bool isRegistered;
        bool isActive;
        uint64 registeredAt;
        uint64 lastActiveAt;
        uint64 deactivationTime;        // 0 if not leaving
        EnumerableSet.AddressSet stakedAssets;
        mapping(address => uint256) stakes;  // asset => amount
        EnumerableSet.AddressSet delegators;
    }

    struct DelegatorData {
        EnumerableSet.AddressSet operators;
        mapping(address => mapping(address => uint256)) delegations; // operator => asset => amount
        mapping(address => uint256) deposits;  // asset => deposited amount
    }

    // Operators
    mapping(address => OperatorData) internal _operators;
    EnumerableSet.AddressSet internal _allOperators;

    // Delegators
    mapping(address => DelegatorData) internal _delegators;

    // Blueprint registrations
    mapping(uint64 => EnumerableSet.AddressSet) internal _blueprintOperators;
    mapping(address => EnumerableSet.UintSet) internal _operatorBlueprints;

    // Configuration
    uint256 public override minOperatorStake;
    EnumerableSet.AddressSet internal _supportedAssets;
    mapping(address => uint256) public minAssetAmount;
    mapping(bytes32 => uint256) public slashingRates;

    // Timing
    uint256 public constant UNSTAKE_DELAY = 7 days;
    uint256 public constant DEACTIVATION_DELAY = 3 days;

    address public override rewardsDistributor;

    // ═══════════════════════════════════════════════════════════════════════
    // OPERATOR FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════

    function registerOperator(address operator, bytes calldata /* data */) external override {
        require(!_operators[operator].isRegistered, "Already registered");

        _operators[operator].isRegistered = true;
        _operators[operator].isActive = false;  // Must stake to activate
        _operators[operator].registeredAt = uint64(block.timestamp);
        _allOperators.add(operator);

        emit OperatorRegistered(operator, 0);
    }

    function stakeNative() external payable nonReentrant {
        require(_operators[msg.sender].isRegistered, "Not registered");
        require(msg.value > 0, "Zero stake");

        _operators[msg.sender].stakes[address(0)] += msg.value;
        _operators[msg.sender].stakedAssets.add(address(0));

        _tryActivateOperator(msg.sender);

        emit StakeDeposited(msg.sender, address(0), msg.value);
    }

    function stakeERC20(address asset, uint256 amount) external nonReentrant {
        require(_operators[msg.sender].isRegistered, "Not registered");
        require(_supportedAssets.contains(asset), "Asset not supported");
        require(amount >= minAssetAmount[asset], "Below minimum");

        IERC20(asset).safeTransferFrom(msg.sender, address(this), amount);

        _operators[msg.sender].stakes[asset] += amount;
        _operators[msg.sender].stakedAssets.add(asset);

        _tryActivateOperator(msg.sender);

        emit StakeDeposited(msg.sender, asset, amount);
    }

    function registerToBlueprint(uint64 blueprintId) external {
        require(_operators[msg.sender].isActive, "Not active");

        _blueprintOperators[blueprintId].add(msg.sender);
        _operatorBlueprints[msg.sender].add(blueprintId);
    }

    function _tryActivateOperator(address operator) internal {
        if (!_operators[operator].isActive) {
            uint256 totalStake = getOperatorTotalStake(operator);
            if (totalStake >= minOperatorStake) {
                _operators[operator].isActive = true;
                _operators[operator].lastActiveAt = uint64(block.timestamp);
            }
        }
    }

    // ═══════════════════════════════════════════════════════════════════════
    // DELEGATION FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════

    function depositNative() external payable nonReentrant {
        require(msg.value > 0, "Zero deposit");
        _delegators[msg.sender].deposits[address(0)] += msg.value;
    }

    function depositERC20(address asset, uint256 amount) external nonReentrant {
        require(_supportedAssets.contains(asset), "Asset not supported");
        IERC20(asset).safeTransferFrom(msg.sender, address(this), amount);
        _delegators[msg.sender].deposits[asset] += amount;
    }

    function delegate(address operator, address asset, uint256 amount) external nonReentrant {
        require(_operators[operator].isActive, "Operator not active");
        require(_delegators[msg.sender].deposits[asset] >= amount, "Insufficient deposit");

        _delegators[msg.sender].deposits[asset] -= amount;
        _delegators[msg.sender].delegations[operator][asset] += amount;
        _delegators[msg.sender].operators.add(operator);
        _operators[operator].delegators.add(msg.sender);

        emit Delegated(msg.sender, operator, asset, amount);
    }

    // ═══════════════════════════════════════════════════════════════════════
    // QUERY IMPLEMENTATIONS
    // ═══════════════════════════════════════════════════════════════════════

    function isOperatorRegistered(address operator) external view override returns (bool) {
        return _operators[operator].isRegistered;
    }

    function isOperatorActive(address operator) external view override returns (bool) {
        return _operators[operator].isActive;
    }

    function getOperatorInfo(address operator) external view override returns (OperatorInfo memory) {
        OperatorData storage op = _operators[operator];
        return OperatorInfo({
            isRegistered: op.isRegistered,
            isActive: op.isActive,
            totalStake: _calculateTotalStake(operator),
            registeredAt: op.registeredAt,
            lastActiveAt: op.lastActiveAt
        });
    }

    function getOperatorTotalStake(address operator) public view override returns (uint256) {
        return _calculateTotalStake(operator) + _calculateTotalDelegation(operator);
    }

    function getOperatorStake(address operator, address asset) external view override returns (uint256) {
        return _operators[operator].stakes[asset];
    }

    function getOperatorStakes(address operator) external view override returns (Stake[] memory) {
        OperatorData storage op = _operators[operator];
        uint256 len = op.stakedAssets.length();
        Stake[] memory stakes = new Stake[](len);

        for (uint256 i = 0; i < len; i++) {
            address asset = op.stakedAssets.at(i);
            stakes[i] = Stake({
                asset: asset,
                amount: op.stakes[asset],
                shares: op.stakes[asset]  // 1:1 for non-rebasing
            });
        }
        return stakes;
    }

    function getOperatorsForBlueprint(uint64 blueprintId) external view override returns (address[] memory) {
        return _blueprintOperators[blueprintId].values();
    }

    function getTotalDelegation(address operator) external view override returns (uint256) {
        return _calculateTotalDelegation(operator);
    }

    function getDelegation(address delegator, address operator) external view override returns (uint256) {
        uint256 total = 0;
        address[] memory assets = _supportedAssets.values();
        for (uint256 i = 0; i < assets.length; i++) {
            total += _delegators[delegator].delegations[operator][assets[i]];
        }
        // Add native
        total += _delegators[delegator].delegations[operator][address(0)];
        return total;
    }

    function getDelegatorDelegations(address delegator) external view override returns (Delegation[] memory) {
        // Simplified - return all delegations
        DelegatorData storage del = _delegators[delegator];
        uint256 opCount = del.operators.length();

        // Count total delegations
        uint256 count = 0;
        for (uint256 i = 0; i < opCount; i++) {
            address op = del.operators.at(i);
            if (del.delegations[op][address(0)] > 0) count++;
            for (uint256 j = 0; j < _supportedAssets.length(); j++) {
                if (del.delegations[op][_supportedAssets.at(j)] > 0) count++;
            }
        }

        Delegation[] memory delegations = new Delegation[](count);
        uint256 idx = 0;

        for (uint256 i = 0; i < opCount; i++) {
            address op = del.operators.at(i);

            if (del.delegations[op][address(0)] > 0) {
                delegations[idx++] = Delegation({
                    operator: op,
                    asset: address(0),
                    amount: del.delegations[op][address(0)],
                    delegatedAt: 0  // Not tracked in simplified version
                });
            }

            for (uint256 j = 0; j < _supportedAssets.length(); j++) {
                address asset = _supportedAssets.at(j);
                if (del.delegations[op][asset] > 0) {
                    delegations[idx++] = Delegation({
                        operator: op,
                        asset: asset,
                        amount: del.delegations[op][asset],
                        delegatedAt: 0
                    });
                }
            }
        }

        return delegations;
    }

    function getOperatorDelegators(address operator) external view override returns (address[] memory) {
        return _operators[operator].delegators.values();
    }

    function meetsStakeRequirement(
        address operator,
        uint64 /* blueprintId */,
        uint256 requiredStake
    ) external view override returns (bool) {
        return getOperatorTotalStake(operator) >= requiredStake;
    }

    function getOperatorScore(address operator, uint64 /* blueprintId */) external view override returns (uint256) {
        // Simple: score = total stake
        return getOperatorTotalStake(operator);
    }

    // ═══════════════════════════════════════════════════════════════════════
    // SLASHING
    // ═══════════════════════════════════════════════════════════════════════

    function slash(SlashParams calldata params) external override onlyRole(SLASHER_ROLE) returns (uint256) {
        OperatorData storage op = _operators[params.operator];
        require(op.isRegistered, "Not registered");

        uint256 slashed = 0;
        uint256 remaining = params.amount;

        // Slash operator stake first
        if (params.asset == address(0) || op.stakes[params.asset] > 0) {
            address asset = params.asset == address(0) ? address(0) : params.asset;
            uint256 toSlash = remaining > op.stakes[asset] ? op.stakes[asset] : remaining;
            op.stakes[asset] -= toSlash;
            slashed += toSlash;
            remaining -= toSlash;
        }

        // Slash delegators proportionally if needed
        if (remaining > 0) {
            slashed += _slashDelegators(params.operator, remaining);
        }

        // Deactivate if below minimum
        if (_calculateTotalStake(params.operator) < minOperatorStake) {
            op.isActive = false;
        }

        emit Slashed(params.operator, params.serviceId, slashed);
        return slashed;
    }

    function _slashDelegators(address operator, uint256 amount) internal returns (uint256) {
        uint256 totalDelegated = _calculateTotalDelegation(operator);
        if (totalDelegated == 0) return 0;

        uint256 slashed = 0;
        address[] memory delegators = _operators[operator].delegators.values();

        for (uint256 i = 0; i < delegators.length && slashed < amount; i++) {
            DelegatorData storage del = _delegators[delegators[i]];

            // Slash native
            uint256 delNative = del.delegations[operator][address(0)];
            if (delNative > 0) {
                uint256 toSlash = (delNative * amount) / totalDelegated;
                del.delegations[operator][address(0)] -= toSlash;
                slashed += toSlash;
            }

            // Slash ERC20s
            for (uint256 j = 0; j < _supportedAssets.length(); j++) {
                address asset = _supportedAssets.at(j);
                uint256 delAmount = del.delegations[operator][asset];
                if (delAmount > 0) {
                    uint256 toSlash = (delAmount * amount) / totalDelegated;
                    del.delegations[operator][asset] -= toSlash;
                    slashed += toSlash;
                }
            }
        }

        return slashed;
    }

    function getSlashingRate(bytes32 violationType) external view override returns (uint256) {
        return slashingRates[violationType];
    }

    function isSlasher(address account) external view override returns (bool) {
        return hasRole(SLASHER_ROLE, account);
    }

    // ═══════════════════════════════════════════════════════════════════════
    // REWARDS
    // ═══════════════════════════════════════════════════════════════════════

    function notifyReward(
        address operator,
        uint64 serviceId,
        uint256 amount,
        address asset
    ) external override {
        // Forward to rewards distributor
        // This is called by TangleCore after payment processing
        emit RewardNotified(operator, serviceId, amount, asset);
    }

    event RewardNotified(address indexed operator, uint64 indexed serviceId, uint256 amount, address asset);

    // ═══════════════════════════════════════════════════════════════════════
    // INTERNAL HELPERS
    // ═══════════════════════════════════════════════════════════════════════

    function _calculateTotalStake(address operator) internal view returns (uint256) {
        OperatorData storage op = _operators[operator];
        uint256 total = op.stakes[address(0)];  // Native

        for (uint256 i = 0; i < op.stakedAssets.length(); i++) {
            address asset = op.stakedAssets.at(i);
            if (asset != address(0)) {
                total += op.stakes[asset];  // Simplified: assume 1:1 value
            }
        }
        return total;
    }

    function _calculateTotalDelegation(address operator) internal view returns (uint256) {
        uint256 total = 0;
        address[] memory delegators = _operators[operator].delegators.values();

        for (uint256 i = 0; i < delegators.length; i++) {
            DelegatorData storage del = _delegators[delegators[i]];
            total += del.delegations[operator][address(0)];

            for (uint256 j = 0; j < _supportedAssets.length(); j++) {
                total += del.delegations[operator][_supportedAssets.at(j)];
            }
        }
        return total;
    }

    // ═══════════════════════════════════════════════════════════════════════
    // ADMIN (ISecurityManagerAdmin)
    // ═══════════════════════════════════════════════════════════════════════

    function deregisterOperator(address operator) external override onlyRole(ADMIN_ROLE) {
        // Implementation
    }

    function setMinOperatorStake(uint256 amount) external override onlyRole(ADMIN_ROLE) {
        minOperatorStake = amount;
    }

    function addSupportedAsset(address asset, uint256 minAmount) external override onlyRole(ADMIN_ROLE) {
        _supportedAssets.add(asset);
        minAssetAmount[asset] = minAmount;
    }

    function removeSupportedAsset(address asset) external override onlyRole(ADMIN_ROLE) {
        _supportedAssets.remove(asset);
    }

    function setSlashingRate(bytes32 violationType, uint256 rate) external override onlyRole(ADMIN_ROLE) {
        require(rate <= 10000, "Rate too high");  // Max 100%
        slashingRates[violationType] = rate;
    }

    function addSlasher(address slasher) external override onlyRole(ADMIN_ROLE) {
        _grantRole(SLASHER_ROLE, slasher);
    }

    function removeSlasher(address slasher) external override onlyRole(ADMIN_ROLE) {
        _revokeRole(SLASHER_ROLE, slasher);
    }
}
```

## EigenLayer Adapter

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ISecurityManager} from "./ISecurityManager.sol";
import {IDelegationManager} from "@eigenlayer/interfaces/IDelegationManager.sol";
import {IStrategy} from "@eigenlayer/interfaces/IStrategy.sol";
import {IAVSDirectory} from "@eigenlayer/interfaces/IAVSDirectory.sol";

/// @title EigenLayerSecurityManager
/// @notice Adapter that implements ISecurityManager using EigenLayer's restaking
contract EigenLayerSecurityManager is ISecurityManager {
    // EigenLayer core contracts
    IDelegationManager public immutable delegationManager;
    IAVSDirectory public immutable avsDirectory;
    IStrategy[] public strategies;

    // Tangle-specific mappings
    mapping(address => bool) internal _registeredOperators;
    mapping(uint64 => address[]) internal _blueprintOperators;
    mapping(address => uint64[]) internal _operatorBlueprints;

    address public override rewardsDistributor;

    constructor(
        address _delegationManager,
        address _avsDirectory,
        address[] memory _strategies
    ) {
        delegationManager = IDelegationManager(_delegationManager);
        avsDirectory = IAVSDirectory(_avsDirectory);

        for (uint256 i = 0; i < _strategies.length; i++) {
            strategies.push(IStrategy(_strategies[i]));
        }
    }

    // ═══════════════════════════════════════════════════════════════════════
    // OPERATOR REGISTRATION (EigenLayer AVS)
    // ═══════════════════════════════════════════════════════════════════════

    function registerOperatorToAVS(
        address operator,
        ISignatureUtils.SignatureWithSaltAndExpiry memory signature
    ) external {
        // Register operator to Tangle AVS in EigenLayer
        avsDirectory.registerOperatorToAVS(operator, signature);
        _registeredOperators[operator] = true;

        emit OperatorRegistered(operator, getOperatorTotalStake(operator));
    }

    // ═══════════════════════════════════════════════════════════════════════
    // QUERY IMPLEMENTATIONS (Read from EigenLayer)
    // ═══════════════════════════════════════════════════════════════════════

    function isOperatorRegistered(address operator) external view override returns (bool) {
        return _registeredOperators[operator] &&
               avsDirectory.avsOperatorStatus(address(this), operator) == IAVSDirectory.OperatorAVSRegistrationStatus.REGISTERED;
    }

    function isOperatorActive(address operator) external view override returns (bool) {
        return this.isOperatorRegistered(operator) &&
               delegationManager.isOperator(operator);
    }

    function getOperatorInfo(address operator) external view override returns (OperatorInfo memory) {
        return OperatorInfo({
            isRegistered: this.isOperatorRegistered(operator),
            isActive: this.isOperatorActive(operator),
            totalStake: getOperatorTotalStake(operator),
            registeredAt: 0,  // Not tracked by EigenLayer directly
            lastActiveAt: uint64(block.timestamp)
        });
    }

    function getOperatorTotalStake(address operator) public view override returns (uint256) {
        uint256 total = 0;

        // Sum across all registered strategies
        for (uint256 i = 0; i < strategies.length; i++) {
            uint256 shares = delegationManager.operatorShares(operator, strategies[i]);
            // Convert shares to underlying - simplified, real impl would use strategy
            total += shares;
        }

        return total;
    }

    function getOperatorStake(address operator, address asset) external view override returns (uint256) {
        // Find strategy for asset
        for (uint256 i = 0; i < strategies.length; i++) {
            if (address(strategies[i].underlyingToken()) == asset) {
                return delegationManager.operatorShares(operator, strategies[i]);
            }
        }
        return 0;
    }

    function getOperatorStakes(address operator) external view override returns (Stake[] memory) {
        Stake[] memory stakes = new Stake[](strategies.length);

        for (uint256 i = 0; i < strategies.length; i++) {
            uint256 shares = delegationManager.operatorShares(operator, strategies[i]);
            stakes[i] = Stake({
                asset: address(strategies[i].underlyingToken()),
                amount: strategies[i].sharesToUnderlying(shares),
                shares: shares
            });
        }

        return stakes;
    }

    function getOperatorsForBlueprint(uint64 blueprintId) external view override returns (address[] memory) {
        return _blueprintOperators[blueprintId];
    }

    // ═══════════════════════════════════════════════════════════════════════
    // DELEGATION (Read from EigenLayer)
    // ═══════════════════════════════════════════════════════════════════════

    function getTotalDelegation(address operator) external view override returns (uint256) {
        // In EigenLayer, operator stake IS delegated stake
        return getOperatorTotalStake(operator);
    }

    function getDelegation(address delegator, address operator) external view override returns (uint256) {
        // Check if delegator has delegated to this operator
        if (delegationManager.delegatedTo(delegator) != operator) {
            return 0;
        }

        // Sum delegator's shares across strategies
        uint256 total = 0;
        for (uint256 i = 0; i < strategies.length; i++) {
            (uint256 shares,) = delegationManager.stakerStrategyShares(delegator, strategies[i]);
            total += shares;
        }
        return total;
    }

    function getDelegatorDelegations(address delegator) external view override returns (Delegation[] memory) {
        address operator = delegationManager.delegatedTo(delegator);
        if (operator == address(0)) {
            return new Delegation[](0);
        }

        Delegation[] memory delegations = new Delegation[](strategies.length);
        for (uint256 i = 0; i < strategies.length; i++) {
            (uint256 shares,) = delegationManager.stakerStrategyShares(delegator, strategies[i]);
            delegations[i] = Delegation({
                operator: operator,
                asset: address(strategies[i].underlyingToken()),
                amount: strategies[i].sharesToUnderlying(shares),
                delegatedAt: 0
            });
        }
        return delegations;
    }

    function getOperatorDelegators(address /* operator */) external pure override returns (address[] memory) {
        // EigenLayer doesn't expose this directly - would need indexer
        revert("Use indexer");
    }

    // ═══════════════════════════════════════════════════════════════════════
    // STAKE REQUIREMENTS
    // ═══════════════════════════════════════════════════════════════════════

    function minOperatorStake() external pure override returns (uint256) {
        return 32 ether;  // Standard EigenLayer minimum
    }

    function meetsStakeRequirement(
        address operator,
        uint64 /* blueprintId */,
        uint256 requiredStake
    ) external view override returns (bool) {
        return getOperatorTotalStake(operator) >= requiredStake;
    }

    function getOperatorScore(address operator, uint64 /* blueprintId */) external view override returns (uint256) {
        return getOperatorTotalStake(operator);
    }

    // ═══════════════════════════════════════════════════════════════════════
    // SLASHING (Via EigenLayer Slasher)
    // ═══════════════════════════════════════════════════════════════════════

    function slash(SlashParams calldata params) external override returns (uint256) {
        // EigenLayer slashing is handled through their slasher contract
        // This would call into EigenLayer's slashing mechanism
        // For now, emit event and let off-chain handle

        emit Slashed(params.operator, params.serviceId, params.amount);
        return params.amount;
    }

    function getSlashingRate(bytes32 /* violationType */) external pure override returns (uint256) {
        return 1000;  // 10% default
    }

    function isSlasher(address /* account */) external pure override returns (bool) {
        return false;  // EigenLayer handles this
    }

    // ═══════════════════════════════════════════════════════════════════════
    // REWARDS
    // ═══════════════════════════════════════════════════════════════════════

    function notifyReward(
        address operator,
        uint64 serviceId,
        uint256 amount,
        address asset
    ) external override {
        // Route to EigenLayer rewards or our own distributor
        emit RewardNotified(operator, serviceId, amount, asset);
    }

    event RewardNotified(address indexed operator, uint64 indexed serviceId, uint256 amount, address asset);
}
```

## Symbiotic Adapter (Skeleton)

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ISecurityManager} from "./ISecurityManager.sol";

/// @title SymbioticSecurityManager
/// @notice Adapter that implements ISecurityManager using Symbiotic
contract SymbioticSecurityManager is ISecurityManager {
    // Symbiotic interfaces would go here

    // Similar pattern to EigenLayer adapter:
    // - Read stake from Symbiotic vaults
    // - Map Symbiotic operators to Tangle blueprints
    // - Route slashing through Symbiotic
}
```

## Usage in TangleCore

```solidity
contract TangleCore {
    ISecurityManager public securityManager;

    function setSecurityManager(address _manager) external onlyAdmin {
        securityManager = ISecurityManager(_manager);
    }

    function requestService(
        uint64 blueprintId,
        address[] calldata operators,
        // ...
    ) external payable {
        // Verify operators meet requirements
        for (uint256 i = 0; i < operators.length; i++) {
            require(
                securityManager.isOperatorActive(operators[i]),
                "Operator not active"
            );
            require(
                securityManager.meetsStakeRequirement(operators[i], blueprintId, minStake),
                "Insufficient stake"
            );
        }
        // Continue with service creation...
    }

    function slash(address operator, uint64 serviceId, uint256 amount) external {
        // Delegate to security manager
        securityManager.slash(ISecurityManager.SlashParams({
            operator: operator,
            serviceId: serviceId,
            amount: amount,
            asset: address(0),
            evidence: bytes32(0)
        }));
    }
}
```

## Switching Security Backends

```solidity
// Deploy with native staking
NativeSecurityManager nativeSM = new NativeSecurityManager();
tangleCore.setSecurityManager(address(nativeSM));

// Later, migrate to EigenLayer
EigenLayerSecurityManager eigenSM = new EigenLayerSecurityManager(
    DELEGATION_MANAGER,
    AVS_DIRECTORY,
    strategies
);
tangleCore.setSecurityManager(address(eigenSM));

// Or use Symbiotic
SymbioticSecurityManager symbioticSM = new SymbioticSecurityManager();
tangleCore.setSecurityManager(address(symbioticSM));
```

## Key Design Decisions

1. **Unified Interface** - All backends implement `ISecurityManager`
2. **Minimal State Duplication** - Adapters read from underlying protocol
3. **Flexible Slashing** - Each backend handles slashing per its own mechanism
4. **Blueprint Registration** - Tangle-specific, not in underlying protocol
5. **Rewards Coordination** - Notify pattern allows flexible distribution
