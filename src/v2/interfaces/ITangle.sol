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

    /// @notice Pause the protocol
    function pause() external;

    /// @notice Unpause the protocol
    function unpause() external;
}

/// @title ITangleFull
/// @notice Complete Tangle interface including admin and slashing
interface ITangleFull is ITangle, ITangleSlashing, ITangleAdmin {}
