// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { AccessControlUpgradeable } from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import { PausableUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import { ReentrancyGuardUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";

import { SlashingManager } from "./SlashingManager.sol";
import { DepositManager } from "./DepositManager.sol";

/// @title RestakingFacetBase
/// @notice Shared base to align storage layout for restaking facets
abstract contract RestakingFacetBase is
    AccessControlUpgradeable,
    PausableUpgradeable,
    ReentrancyGuardUpgradeable,
    SlashingManager,
    DepositManager
{
    // Intentionally empty.
}
