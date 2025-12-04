// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { ERC20Upgradeable } from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import { ERC20BurnableUpgradeable } from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20BurnableUpgradeable.sol";
import { ERC20PermitUpgradeable } from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20PermitUpgradeable.sol";
import { ERC20VotesUpgradeable } from "@openzeppelin/contracts-upgradeable/token/ERC20/extensions/ERC20VotesUpgradeable.sol";
import { NoncesUpgradeable } from "@openzeppelin/contracts-upgradeable/utils/NoncesUpgradeable.sol";
import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { AccessControlUpgradeable } from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

/// @title TangleToken (TNT)
/// @notice The Tangle Network governance token with voting capabilities
/// @dev Implements ERC20Votes for on-chain governance integration
///      - ERC20Votes: Historical voting power checkpoints
///      - ERC20Permit: Gasless approvals via signatures
///      - ERC20Burnable: Token burning capability
///      - UUPS: Upgradeable proxy pattern
///
/// Token Economics & Security Model:
/// - MAX_SUPPLY: 100 million TNT (hard cap)
/// - MINTER_ROLE: Should ONLY be held by governance (TangleTimelock)
/// - Protocol contracts (InflationPool, RewardVaults) CANNOT mint
/// - Inflation is distributed via pre-funded InflationPool, not minting
///
/// This design isolates token risk from protocol risk:
/// - If protocol contracts have bugs, attackers cannot mint unlimited tokens
/// - Governance controls inflation by funding InflationPool from treasury
/// - Token holders are protected even if reward contracts are compromised
contract TangleToken is
    Initializable,
    ERC20Upgradeable,
    ERC20BurnableUpgradeable,
    ERC20PermitUpgradeable,
    ERC20VotesUpgradeable,
    AccessControlUpgradeable,
    UUPSUpgradeable
{
    // ═══════════════════════════════════════════════════════════════════════════
    // ROLES
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Role for minting new tokens
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    /// @notice Role for upgrading the contract
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    // ═══════════════════════════════════════════════════════════════════════════
    // STORAGE
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Maximum total supply (100 million TNT with 18 decimals)
    uint256 public constant MAX_SUPPLY = 100_000_000 * 1e18;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // INITIALIZATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Initialize the TNT token
    /// @param admin The admin address that receives initial roles
    /// @param initialSupply The initial token supply to mint to admin
    function initialize(address admin, uint256 initialSupply) public initializer {
        require(admin != address(0), "Admin cannot be zero address");
        require(initialSupply <= MAX_SUPPLY, "Exceeds max supply");

        __ERC20_init("Tangle Network Token", "TNT");
        __ERC20Burnable_init();
        __ERC20Permit_init("Tangle Network Token");
        __ERC20Votes_init();
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(MINTER_ROLE, admin);
        _grantRole(UPGRADER_ROLE, admin);

        if (initialSupply > 0) {
            _mint(admin, initialSupply);
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // MINTING (GOVERNANCE CONTROLLED)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Mint new tokens (governance-only operation)
    /// @dev SECURITY: MINTER_ROLE should ONLY be granted to governance (TangleTimelock)
    ///      Intended use: Fund InflationPool or treasury allocations via governance proposals
    ///      NOT for: Direct reward distribution (use InflationPool instead)
    /// @param to The recipient address (typically InflationPool or treasury)
    /// @param amount The amount to mint
    function mint(address to, uint256 amount) external onlyRole(MINTER_ROLE) {
        require(totalSupply() + amount <= MAX_SUPPLY, "Exceeds max supply");
        _mint(to, amount);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // CLOCK (ERC-6372)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Clock used for voting checkpoints (block number based)
    function clock() public view override returns (uint48) {
        return uint48(block.number);
    }

    /// @notice Description of the clock mode
    // solhint-disable-next-line func-name-mixedcase
    function CLOCK_MODE() public pure override returns (string memory) {
        return "mode=blocknumber&from=default";
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // REQUIRED OVERRIDES
    // ═══════════════════════════════════════════════════════════════════════════

    function _update(address from, address to, uint256 value)
        internal
        override(ERC20Upgradeable, ERC20VotesUpgradeable)
    {
        super._update(from, to, value);
    }

    function nonces(address owner)
        public
        view
        override(ERC20PermitUpgradeable, NoncesUpgradeable)
        returns (uint256)
    {
        return super.nonces(owner);
    }

    function _authorizeUpgrade(address) internal override onlyRole(UPGRADER_ROLE) { }
}
