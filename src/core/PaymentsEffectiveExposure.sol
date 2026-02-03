// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Types } from "../libraries/Types.sol";
import { IStaking } from "../interfaces/IStaking.sol";
import { IPriceOracle } from "../oracles/interfaces/IPriceOracle.sol";

/// @title PaymentsEffectiveExposure
/// @notice Mixin for computing effective exposure (delegation × exposureBps) for payment distribution
/// @dev Separates the effective exposure calculation logic for maintainability
abstract contract PaymentsEffectiveExposure {
    // ═══════════════════════════════════════════════════════════════════════════
    // CONSTANTS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Precision multiplier for effective exposure calculations
    /// @dev Used to maintain precision when combining delegation amounts with exposure bps
    uint256 internal constant EXPOSURE_PRECISION = 1e18;
    
    /// @notice Local BPS constant for calculations (matches TangleStorage._BPS_DENOM)
    uint256 private constant _BPS_DENOM = 10_000;

    // ═══════════════════════════════════════════════════════════════════════════
    // INTERNAL INTERFACE (implemented by inheriting contract)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Get the staking contract
    function _getStaking() internal view virtual returns (IStaking);
    
    /// @notice Get the price oracle (may return address(0) if not configured)
    function _getPriceOracle() internal view virtual returns (address);
    
    /// @notice Get security commitments for an operator on a service
    function _getServiceSecurityCommitments(
        uint64 serviceId,
        address operator
    ) internal view virtual returns (Types.AssetSecurityCommitment[] storage);

    // ═══════════════════════════════════════════════════════════════════════════
    // EFFECTIVE EXPOSURE CALCULATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Calculate effective exposures for all operators of a service
    /// @dev Effective exposure = Σ (delegation[asset] × exposureBps[asset]) for each operator
    ///      If price oracle is configured, values are normalized to USD
    ///      If no oracle, raw token amounts are summed (less accurate but still proportional)
    /// @param serviceId The service ID
    /// @param operators Array of operator addresses
    /// @return effectiveExposures Array of effective exposure values (parallel to operators)
    /// @return totalEffectiveExposure Sum of all effective exposures
    function _calculateEffectiveExposures(
        uint64 serviceId,
        address[] memory operators
    ) internal view returns (uint256[] memory effectiveExposures, uint256 totalEffectiveExposure) {
        uint256 operatorsLength = operators.length;
        effectiveExposures = new uint256[](operatorsLength);
        
        IStaking staking = _getStaking();
        address priceOracleAddr = _getPriceOracle();
        bool useOracle = priceOracleAddr != address(0);
        IPriceOracle oracle = IPriceOracle(priceOracleAddr);

        for (uint256 i = 0; i < operatorsLength;) {
            address operator = operators[i];
            Types.AssetSecurityCommitment[] storage commitments = _getServiceSecurityCommitments(serviceId, operator);
            
            uint256 operatorEffectiveExposure = 0;
            uint256 commitmentsLength = commitments.length;
            
            for (uint256 j = 0; j < commitmentsLength;) {
                Types.AssetSecurityCommitment storage commitment = commitments[j];
                
                // Get delegation for this asset
                uint256 delegation = staking.getOperatorStakeForAsset(operator, commitment.asset);
                
                if (delegation > 0) {
                    // Calculate exposed amount: delegation × exposureBps / _BPS_DENOM
                    uint256 exposedAmount = (delegation * commitment.exposureBps) / _BPS_DENOM;
                    
                    if (useOracle && exposedAmount > 0) {
                        // Convert to USD for cross-asset comparison
                        address token = commitment.asset.kind == Types.AssetKind.Native 
                            ? address(0) 
                            : commitment.asset.token;
                        try oracle.toUSD(token, exposedAmount) returns (uint256 usdValue) {
                            operatorEffectiveExposure += usdValue;
                        } catch {
                            // Fallback: use raw amount if oracle fails
                            operatorEffectiveExposure += exposedAmount;
                        }
                    } else {
                        // No oracle: use raw amount
                        operatorEffectiveExposure += exposedAmount;
                    }
                }
                
                unchecked { ++j; }
            }
            
            effectiveExposures[i] = operatorEffectiveExposure;
            totalEffectiveExposure += operatorEffectiveExposure;
            
            unchecked { ++i; }
        }
    }

    /// @notice Calculate effective exposures using simple exposureBps fallback
    /// @dev Used when operators have no security commitments (uses stored exposureBps directly)
    /// @param operators Array of operator addresses
    /// @param exposureBps Array of exposure basis points (parallel to operators)
    /// @return effectiveExposures Array of effective exposure values
    /// @return totalEffectiveExposure Sum of all effective exposures
    function _calculateSimpleExposures(
        address[] memory operators,
        uint16[] memory exposureBps
    ) internal pure returns (uint256[] memory effectiveExposures, uint256 totalEffectiveExposure) {
        uint256 operatorsLength = operators.length;
        effectiveExposures = new uint256[](operatorsLength);
        
        for (uint256 i = 0; i < operatorsLength;) {
            effectiveExposures[i] = exposureBps[i];
            totalEffectiveExposure += exposureBps[i];
            unchecked { ++i; }
        }
    }
}
