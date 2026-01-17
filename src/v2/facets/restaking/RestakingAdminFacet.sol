// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import { RestakingFacetBase } from "../../restaking/RestakingFacetBase.sol";
import { Types } from "../../libraries/Types.sol";
import { DelegationErrors } from "../../restaking/DelegationErrors.sol";
import { IFacetSelectors } from "../../interfaces/IFacetSelectors.sol";

/// @title RestakingAdminFacet
/// @notice Facet for restaking admin controls
contract RestakingAdminFacet is RestakingFacetBase, IFacetSelectors {
    using EnumerableSet for EnumerableSet.AddressSet;
    using SafeERC20 for IERC20;

    // M-10 FIX: Events for commission change timelock
    event CommissionChangeQueued(uint16 newBps, uint64 executeAfter);
    event CommissionChangeExecuted(uint16 oldBps, uint16 newBps);
    event CommissionChangeCancelled(uint16 cancelledBps);

    function selectors() external pure returns (bytes4[] memory selectorList) {
        selectorList = new bytes4[](15);
        selectorList[0] = this.addSlasher.selector;
        selectorList[1] = this.removeSlasher.selector;
        selectorList[2] = this.setOperatorCommission.selector;
        selectorList[3] = this.setDelays.selector;
        selectorList[4] = this.setRewardsManager.selector;
        selectorList[5] = this.setServiceFeeDistributor.selector;
        selectorList[6] = this.setOperatorBondToken.selector;
        selectorList[7] = this.pause.selector;
        selectorList[8] = this.unpause.selector;
        selectorList[9] = this.rescueTokens.selector;
        selectorList[10] = this.setTangle.selector;
        // M-10 FIX: New commission change timelock functions
        selectorList[11] = this.executeCommissionChange.selector;
        selectorList[12] = this.cancelCommissionChange.selector;
        selectorList[13] = this.getPendingCommissionChange.selector;
        // M-7 FIX: Dust sweep function
        selectorList[14] = this.sweepDust.selector;
    }

    /// @notice Add a slasher
    function addSlasher(address slasher) external onlyRole(ADMIN_ROLE) {
        _grantRole(SLASHER_ROLE, slasher);
    }

    /// @notice Remove a slasher
    function removeSlasher(address slasher) external onlyRole(ADMIN_ROLE) {
        _revokeRole(SLASHER_ROLE, slasher);
    }

    /// @notice Set the Tangle contract for blueprint management
    /// @dev M-10 FIX: Also stores reference for active service queries
    /// @param tangle Address of the Tangle contract
    function setTangle(address tangle) external onlyRole(ADMIN_ROLE) {
        _grantRole(TANGLE_ROLE, tangle);
        // M-10 FIX: Store Tangle reference for operator active service checks
        _tangleCore = tangle;
    }

    /// @notice Queue a commission rate change (M-10 FIX: uses timelock)
    /// @dev The change will take effect after COMMISSION_CHANGE_DELAY (7 days)
    /// @param bps New commission rate in basis points
    function setOperatorCommission(uint16 bps) external onlyRole(ADMIN_ROLE) {
        require(bps <= BPS_DENOMINATOR, "Invalid BPS");
        // M-10 FIX: Queue the commission change instead of immediate application
        if (_commissionChangeExecuteAfter != 0) {
            revert DelegationErrors.CommissionChangeAlreadyPending();
        }
        _pendingCommissionBps = bps;
        _commissionChangeExecuteAfter = uint64(block.timestamp) + COMMISSION_CHANGE_DELAY;
        emit CommissionChangeQueued(bps, _commissionChangeExecuteAfter);
    }

    /// @notice Execute a pending commission change after timelock
    function executeCommissionChange() external onlyRole(ADMIN_ROLE) {
        if (_commissionChangeExecuteAfter == 0) {
            revert DelegationErrors.NoCommissionChangePending();
        }
        if (block.timestamp < _commissionChangeExecuteAfter) {
            revert DelegationErrors.CommissionChangeTooEarly(_commissionChangeExecuteAfter, uint64(block.timestamp));
        }
        uint16 oldBps = operatorCommissionBps;
        uint16 newBps = _pendingCommissionBps;
        operatorCommissionBps = newBps;
        _pendingCommissionBps = 0;
        _commissionChangeExecuteAfter = 0;
        emit CommissionChangeExecuted(oldBps, newBps);
    }

    /// @notice Cancel a pending commission change
    function cancelCommissionChange() external onlyRole(ADMIN_ROLE) {
        if (_commissionChangeExecuteAfter == 0) {
            revert DelegationErrors.NoCommissionChangePending();
        }
        uint16 cancelledBps = _pendingCommissionBps;
        _pendingCommissionBps = 0;
        _commissionChangeExecuteAfter = 0;
        emit CommissionChangeCancelled(cancelledBps);
    }

    /// @notice Get pending commission change details
    /// @return pendingBps The pending commission rate (0 if none)
    /// @return executeAfter Timestamp when change can be executed (0 if none)
    function getPendingCommissionChange() external view returns (uint16 pendingBps, uint64 executeAfter) {
        return (_pendingCommissionBps, _commissionChangeExecuteAfter);
    }

    /// @notice Set delay parameters
    function setDelays(
        uint64 _delegationBondLessDelay,
        uint64 _leaveDelegatorsDelay,
        uint64 _leaveOperatorsDelay
    )
        external
        onlyRole(ADMIN_ROLE)
    {
        delegationBondLessDelay = _delegationBondLessDelay;
        leaveDelegatorsDelay = _leaveDelegatorsDelay;
        leaveOperatorsDelay = _leaveOperatorsDelay;
    }

    /// @notice Set external rewards manager for TNT incentives
    /// @param manager Address of IRewardsManager (RewardVaults), or address(0) to disable
    function setRewardsManager(address manager) external onlyRole(ADMIN_ROLE) {
        _rewardsManager = manager;
    }

    /// @notice Set external service-fee distributor for multi-token fee accrual
    /// @param distributor Address of IServiceFeeDistributor, or address(0) to disable
    function setServiceFeeDistributor(address distributor) external onlyRole(ADMIN_ROLE) {
        _serviceFeeDistributor = distributor;
    }

    /// @notice Set the operator bond token (TNT); set to address(0) for native
    function setOperatorBondToken(address token) external onlyRole(ADMIN_ROLE) {
        if (_operators.length() > 0) {
            revert DelegationErrors.OperatorBondTokenLocked();
        }
        if (token != address(0)) {
            bytes32 assetHash = _assetHash(Types.Asset(Types.AssetKind.ERC20, token));
            if (!_assetConfigs[assetHash].enabled) {
                revert DelegationErrors.AssetNotEnabled(token);
            }
        }
        _operatorBondToken = token;
    }

    /// @notice Pause the contract
    function pause() external onlyRole(ADMIN_ROLE) {
        _pause();
    }

    /// @notice Unpause the contract
    function unpause() external onlyRole(ADMIN_ROLE) {
        _unpause();
    }

    /// @notice Rescue tokens accidentally sent to this contract
    /// @dev Only allows rescuing tokens that are NOT registered restaking assets
    /// @param token The ERC20 token to rescue
    /// @param to The recipient address
    /// @param amount The amount to rescue
    function rescueTokens(address token, address to, uint256 amount) external onlyRole(DEFAULT_ADMIN_ROLE) {
        require(to != address(0), "Invalid recipient");
        require(amount > 0, "Invalid amount");

        // Prevent rescuing registered restaking assets (user funds)
        require(!_enabledErc20s.contains(token), "Cannot rescue registered asset");

        // Also check if there's an adapter registered for this token
        require(_assetAdapters[token] == address(0), "Cannot rescue adapted asset");

        IERC20(token).safeTransfer(to, amount);
    }

    /// @notice M-7 FIX: Sweep accumulated dust from rounding to a recipient
    /// @dev Only admin can call. Dust accumulates from rounding in reward distributions.
    /// @param token The token to sweep (address(0) for native)
    /// @param recipient The address to receive the dust
    /// @return amount The amount of dust swept
    function sweepDust(address token, address recipient) external onlyRole(ADMIN_ROLE) returns (uint256 amount) {
        require(recipient != address(0), "Invalid recipient");
        return _sweepDust(token, recipient);
    }
}
