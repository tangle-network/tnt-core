// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Types } from "../libraries/Types.sol";
import { ITangleBlueprints } from "./ITangleBlueprints.sol";
import { ITangleOperators } from "./ITangleOperators.sol";
import { ITangleServices } from "./ITangleServices.sol";
import { ITangleJobs } from "./ITangleJobs.sol";
import { ITangleSlashing } from "./ITangleSlashing.sol";
import { ITangleRewards } from "./ITangleRewards.sol";

/// @title ITangle
/// @notice Core interface for Tangle Protocol v2
/// @dev Consolidates all sub-interfaces into a single entry point.
///      Inherits from focused sub-interfaces for modularity.
interface ITangle is
    ITangleBlueprints,
    ITangleOperators,
    ITangleServices,
    ITangleJobs,
    ITangleRewards
{
    // This interface consolidates all sub-interfaces.
    // See individual interfaces for documentation:
    // - ITangleBlueprints: Blueprint CRUD operations
    // - ITangleOperators: Operator registration/management
    // - ITangleServices: Service lifecycle (request, approve, activate, terminate)
    // - ITangleJobs: Job submission and results
    // - ITangleRewards: Reward distribution and claiming
    //
    // ITangleSlashing is implemented separately for clarity
}

/// @title ITangleAdmin
/// @notice Admin functions for Tangle protocol
interface ITangleAdmin {
    /// @notice Set the restaking module
    /// @param restaking The IRestaking implementation
    function setRestaking(address restaking) external;

    /// @notice Set the protocol treasury
    /// @param treasury The treasury address
    function setTreasury(address treasury) external;

    /// @notice Set the payment split configuration
    /// @param split The new split configuration
    function setPaymentSplit(Types.PaymentSplit calldata split) external;

    /// @notice Get the current payment split
    function paymentSplit() external view returns (uint16 developerBps, uint16 protocolBps, uint16 operatorBps, uint16 restakerBps);

    /// @notice Pause the protocol
    function pause() external;

    /// @notice Unpause the protocol
    function unpause() external;

    /// @notice Get the configured treasury
    function treasury() external view returns (address payable);

    /// @notice Set the metrics recorder (optional)
    function setMetricsRecorder(address recorder) external;

    /// @notice Get the metrics recorder address
    function metricsRecorder() external view returns (address);

    /// @notice Set operator status registry
    function setOperatorStatusRegistry(address registry) external;

    /// @notice Get operator status registry
    function operatorStatusRegistry() external view returns (address);

    /// @notice Configure service fee distributor
    function setServiceFeeDistributor(address distributor) external;

    /// @notice Get service fee distributor
    function serviceFeeDistributor() external view returns (address);

    /// @notice Configure price oracle
    function setPriceOracle(address oracle) external;

    /// @notice Get price oracle
    function priceOracle() external view returns (address);

    /// @notice Configure Master Blueprint Service Manager registry
    function setMBSMRegistry(address registry) external;

    /// @notice Get Master Blueprint Service Manager registry
    function mbsmRegistry() external view returns (address);

    /// @notice Get operator bond token
    function operatorBondToken() external view returns (address);

    /// @notice Get max blueprints per operator
    function maxBlueprintsPerOperator() external view returns (uint32);

    /// @notice Set max blueprints per operator
    function setMaxBlueprintsPerOperator(uint32 newMax) external;

    /// @notice Get operator bond amount
    function operatorBlueprintBond() external view returns (uint256);

    /// @notice Set operator bond amount
    function setOperatorBlueprintBond(uint256 newBond) external;

    /// @notice Set operator bond asset
    function setOperatorBondAsset(address token) external;

    /// @notice Get TNT token address
    function tntToken() external view returns (address);

    /// @notice Set TNT token address
    function setTntToken(address token) external;

    /// @notice Get reward vaults address
    function rewardVaults() external view returns (address);

    /// @notice Set reward vaults address
    function setRewardVaults(address vaults) external;

    /// @notice Get default TNT min exposure bps
    function defaultTntMinExposureBps() external view returns (uint16);

    /// @notice Set default TNT min exposure bps
    function setDefaultTntMinExposureBps(uint16 minExposureBps) external;

    /// @notice Get TNT restaker fee bps
    function tntRestakerFeeBps() external view returns (uint16);

    /// @notice Set TNT restaker fee bps
    function setTntRestakerFeeBps(uint16 feeBps) external;

    /// @notice Get TNT payment discount bps
    function tntPaymentDiscountBps() external view returns (uint16);

    /// @notice Set TNT payment discount bps
    function setTntPaymentDiscountBps(uint16 discountBps) external;
}

/// @title ITangleFull
/// @notice Complete Tangle interface including admin and slashing
interface ITangleFull is ITangle, ITangleSlashing, ITangleAdmin {}
