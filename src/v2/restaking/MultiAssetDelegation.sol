// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { AccessControlUpgradeable } from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import { PausableUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import { ReentrancyGuardUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";

import { ProtocolConfig } from "../config/ProtocolConfig.sol";
import { SlashingManager } from "./SlashingManager.sol";
import { DepositManager } from "./DepositManager.sol";
import { Types } from "../libraries/Types.sol";
import { DelegationErrors } from "./DelegationErrors.sol";
import { IFacetSelectors } from "../interfaces/IFacetSelectors.sol";

/// @title MultiAssetDelegation
/// @notice Router contract for multi-asset restaking
contract MultiAssetDelegation is
    Initializable,
    UUPSUpgradeable,
    AccessControlUpgradeable,
    PausableUpgradeable,
    ReentrancyGuardUpgradeable,
    SlashingManager,
    DepositManager
{
    event FacetRegistered(address indexed facet);
    event FacetSelectorSet(bytes4 indexed selector, address indexed facet);
    event FacetSelectorCleared(bytes4 indexed selector);

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

    /// @notice Register selectors exposed by a facet
    function registerFacet(address facet) external onlyRole(ADMIN_ROLE) {
        bytes4[] memory selectors = IFacetSelectors(facet).selectors();
        _setFacetSelectors(facet, selectors);
        emit FacetRegistered(facet);
    }

    /// @notice Register specific selectors for a facet
    function registerFacetSelectors(address facet, bytes4[] calldata selectors) external onlyRole(ADMIN_ROLE) {
        _setFacetSelectors(facet, selectors);
    }

    /// @notice Remove selectors from the router
    function clearFacetSelectors(bytes4[] calldata selectors) external onlyRole(ADMIN_ROLE) {
        for (uint256 i = 0; i < selectors.length; i++) {
            delete _facetForSelector[selectors[i]];
            emit FacetSelectorCleared(selectors[i]);
        }
    }

    /// @notice Resolve the facet for a selector
    function facetForSelector(bytes4 selector) external view returns (address) {
        return _facetForSelector[selector];
    }

    function _setFacetSelectors(address facet, bytes4[] memory selectors) internal {
        if (facet == address(0)) revert DelegationErrors.ZeroAddress();
        if (facet.code.length == 0) revert DelegationErrors.NotAContract(facet);
        for (uint256 i = 0; i < selectors.length; i++) {
            _facetForSelector[selectors[i]] = facet;
            emit FacetSelectorSet(selectors[i], facet);
        }
    }

    fallback() external payable {
        address facet = _facetForSelector[msg.sig];
        if (facet == address(0)) revert DelegationErrors.UnknownSelector(msg.sig);
        _delegateTo(facet);
    }

    receive() external payable {}

    function _delegateTo(address target) private {
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), target, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }

    function _authorizeUpgrade(address) internal override onlyRole(ADMIN_ROLE) { }
}
