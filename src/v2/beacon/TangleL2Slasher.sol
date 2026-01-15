// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IL2Slasher} from "./L2SlashingReceiver.sol";
import {IRestaking} from "../interfaces/IRestaking.sol";
import {Types} from "../libraries/Types.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/// @title TangleL2Slasher
/// @notice Implementation of IL2Slasher that integrates with Tangle's restaking system
/// @dev Receives cross-chain slashing messages and executes them via MultiAssetDelegation
///
/// Architecture:
/// 1. L2SlashingReceiver receives cross-chain message from L1
/// 2. L2SlashingReceiver calls this contract's slashOperator()
/// 3. This contract validates and routes to IRestaking.slash()
/// 4. MultiAssetDelegation executes O(1) proportional slashing
contract TangleL2Slasher is IL2Slasher, Ownable {
    // ═══════════════════════════════════════════════════════════════════════════
    // ERRORS
    // ═══════════════════════════════════════════════════════════════════════════

    error UnauthorizedCaller();
    error ZeroAddress();
    error ZeroAmount();
    error SlashingPaused();
    error OperatorNotSlashable();

    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    event BeaconSlashExecuted(
        address indexed operator,
        uint16 slashBps,
        uint256 actualSlashed,
        bytes reason
    );

    event AuthorizedCallerUpdated(address indexed caller, bool authorized);
    event RestakingUpdated(address indexed oldRestaking, address indexed newRestaking);
    event SlashingPausedUpdated(bool paused);

    // ═══════════════════════════════════════════════════════════════════════════
    // CONSTANTS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Service ID used for beacon chain slashing events
    /// @dev This is a special service ID reserved for cross-chain beacon slashing
    uint64 public constant BEACON_SLASH_SERVICE_ID = type(uint64).max;

    // ═══════════════════════════════════════════════════════════════════════════
    // STATE
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice The Tangle restaking contract (MultiAssetDelegation)
    IRestaking public restaking;

    /// @notice Authorized callers (L2SlashingReceiver addresses)
    mapping(address => bool) public authorizedCallers;

    /// @notice Whether slashing is paused (emergency brake)
    bool public paused;

    /// @notice Cumulative slashed amount per operator from beacon chain
    mapping(address => uint256) public totalBeaconSlashed;

    /// @notice Nonce for slash tracking
    uint256 public slashNonce;

    // ═══════════════════════════════════════════════════════════════════════════
    // CONSTRUCTOR
    // ═══════════════════════════════════════════════════════════════════════════

    constructor(address _restaking, address _owner) Ownable(_owner) {
        if (_restaking == address(0)) revert ZeroAddress();
        restaking = IRestaking(_restaking);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // MODIFIERS
    // ═══════════════════════════════════════════════════════════════════════════

    modifier onlyAuthorized() {
        _onlyAuthorized();
        _;
    }

    function _onlyAuthorized() internal view {
        if (!authorizedCallers[msg.sender]) revert UnauthorizedCaller();
    }

    modifier whenNotPaused() {
        _ensureNotPaused();
        _;
    }

    function _ensureNotPaused() internal view {
        if (paused) revert SlashingPaused();
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // IL2Slasher IMPLEMENTATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @inheritdoc IL2Slasher
    function slashOperator(
        address operator,
        uint16 slashBps,
        bytes calldata reason
    ) external onlyAuthorized whenNotPaused {
        if (operator == address(0)) revert ZeroAddress();
        if (slashBps == 0) revert ZeroAmount();

        // Check if operator can be slashed
        if (!canSlash(operator)) revert OperatorNotSlashable();

        // Generate evidence hash from the reason
        // forge-lint: disable-next-line(asm-keccak256)
        bytes32 evidence = keccak256(abi.encodePacked(
            "BEACON_CHAIN_SLASH",
            operator,
            slashBps,
            slashNonce++,
            reason
        ));

        // Execute slash through restaking contract
        uint256 actualSlashed = restaking.slash(
            operator,
            BEACON_SLASH_SERVICE_ID,
            slashBps,
            evidence
        );

        // Track total slashed
        totalBeaconSlashed[operator] += actualSlashed;

        emit BeaconSlashExecuted(operator, slashBps, actualSlashed, reason);
    }

    /// @inheritdoc IL2Slasher
    function canSlash(address operator) public view returns (bool) {
        if (paused) return false;
        return getSlashableStake(operator) > 0;
    }

    /// @inheritdoc IL2Slasher
    function getSlashableStake(address operator) public view returns (uint256) {
        return restaking.getOperatorStakeForAsset(
            operator,
            Types.Asset({ kind: Types.AssetKind.Native, token: address(0) })
        );
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // ADMIN FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Authorize a caller (typically L2SlashingReceiver)
    function setAuthorizedCaller(address caller, bool authorized) external onlyOwner {
        if (caller == address(0)) revert ZeroAddress();
        authorizedCallers[caller] = authorized;
        emit AuthorizedCallerUpdated(caller, authorized);
    }

    /// @notice Update the restaking contract
    function setRestaking(address _restaking) external onlyOwner {
        if (_restaking == address(0)) revert ZeroAddress();
        address old = address(restaking);
        restaking = IRestaking(_restaking);
        emit RestakingUpdated(old, _restaking);
    }

    /// @notice Pause/unpause slashing (emergency brake)
    function setPaused(bool _paused) external onlyOwner {
        paused = _paused;
        emit SlashingPausedUpdated(_paused);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // VIEW FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Get operator's remaining slashable stake after beacon slashes
    function getRemainingSlashableStake(address operator) external view returns (uint256) {
        uint256 total = getSlashableStake(operator);
        uint256 alreadySlashed = totalBeaconSlashed[operator];
        return total > alreadySlashed ? total - alreadySlashed : 0;
    }

    /// @notice Check if an operator has been slashed from beacon chain
    function hasBeenSlashed(address operator) external view returns (bool) {
        return totalBeaconSlashed[operator] > 0;
    }
}
