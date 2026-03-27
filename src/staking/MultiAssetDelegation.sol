// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { AccessControlUpgradeable } from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import { PausableUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import { ReentrancyGuardUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";

import { FacetRouterBase } from "../facets/FacetRouterBase.sol";
import { ProtocolConfig } from "../config/ProtocolConfig.sol";
import { SlashingManager } from "./SlashingManager.sol";
import { DepositManager } from "./DepositManager.sol";
import { Types } from "../libraries/Types.sol";
import { DelegationErrors } from "./DelegationErrors.sol";

/// @title MultiAssetDelegation
/// @notice Router contract for multi-asset staking
contract MultiAssetDelegation is
    Initializable,
    UUPSUpgradeable,
    AccessControlUpgradeable,
    PausableUpgradeable,
    ReentrancyGuardUpgradeable,
    SlashingManager,
    DepositManager,
    FacetRouterBase
{
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /// @notice Initialize the contract
    /// @param admin Admin address
    /// @param nativeMinOperatorStake Minimum stake for operators
    /// @param nativeMinDelegation Minimum delegation amount
    /// @param _operatorCommissionBps Operator commission in basis points
    function initialize(
        address admin,
        uint256 nativeMinOperatorStake,
        uint256 nativeMinDelegation,
        uint16 _operatorCommissionBps
    )
        external
        initializer
    {
        __UUPSUpgradeable_init();
        __AccessControl_init();
        __Pausable_init();
        __ReentrancyGuard_init();

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(ADMIN_ROLE, admin);
        _grantRole(ASSET_MANAGER_ROLE, admin);

        // Configure native asset
        bytes32 nativeHash = _assetHash(Types.Asset(Types.AssetKind.Native, address(0)));
        _assetConfigs[nativeHash] = Types.AssetConfig({
            enabled: true,
            minOperatorStake: nativeMinOperatorStake,
            minDelegation: nativeMinDelegation,
            depositCap: 0,
            currentDeposits: 0,
            // forge-lint: disable-next-line(unsafe-typecast)
            rewardMultiplierBps: uint16(BPS_DENOMINATOR)
        });
        nativeEnabled = true;

        operatorCommissionBps = _operatorCommissionBps;
        currentRound = 1;
        roundDuration = ProtocolConfig.ROUND_DURATION_SECONDS;
        // Note: lastRoundAdvance left at 0 to allow first advanceRound() call immediately

        delegationBondLessDelay = ProtocolConfig.DELEGATOR_DELAY_ROUNDS;
        leaveDelegatorsDelay = ProtocolConfig.DELEGATOR_DELAY_ROUNDS;
        leaveOperatorsDelay = ProtocolConfig.OPERATOR_DELAY_ROUNDS;
    }

    function _authorizeFacetRegistryChange() internal view override onlyRole(ADMIN_ROLE) { }

    function _getFacetForSelector(bytes4 selector) internal view override returns (address) {
        return _facetForSelector[selector];
    }

    function _setFacetForSelector(bytes4 selector, address facet) internal override {
        _facetForSelector[selector] = facet;
    }

    function _clearFacetForSelector(bytes4 selector) internal override {
        delete _facetForSelector[selector];
    }

    function _revertZeroAddress() internal pure override {
        revert DelegationErrors.ZeroAddress();
    }

    function _revertNotAContract(address facet) internal pure override {
        revert DelegationErrors.NotAContract(facet);
    }

    function _revertSelectorAlreadyRegistered(bytes4 selector, address existingFacet) internal pure override {
        revert DelegationErrors.SelectorAlreadyRegistered(selector, existingFacet);
    }

    fallback() external payable {
        _fallbackToFacet();
    }

    receive() external payable { }

    function _revertUnknownSelector(bytes4 selector) internal pure override {
        revert DelegationErrors.UnknownSelector(selector);
    }

    function _authorizeUpgrade(address) internal override onlyRole(ADMIN_ROLE) { }

    /// @notice H-1 FIX: Reset pending slash count when it drifts from actual pending slashes
    /// @dev Admin-only recovery function for when count becomes inconsistent
    /// @param operator The operator to reset
    /// @param count The correct pending slash count
    function resetPendingSlashCount(address operator, uint64 count) external override onlyRole(ADMIN_ROLE) {
        _operatorPendingSlashCount[operator] = count;
        emit PendingSlashCountReset(operator, count);
    }
}
