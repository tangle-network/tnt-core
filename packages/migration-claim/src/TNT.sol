// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title TNT - Tangle Network Token
 * @notice ERC20 token for the Tangle Network migration
 * @dev Test-only token used by local deployment scripts in this package.
 */
contract TNT is ERC20, ERC20Burnable, Ownable {
    error ZeroAddress();
    error LengthMismatch();

    constructor(
        address initialOwner
    ) ERC20("Tangle Network Token", "TNT") Ownable(initialOwner) {}

    /**
     * @notice Mint initial supply to owner (for treasury allocation, etc.)
     * @dev Can only be called by the owner
     * @param to The address to mint tokens to
     * @param amount The amount of tokens to mint
     */
    function mintInitialSupply(address to, uint256 amount) external onlyOwner {
        if (to == address(0)) revert ZeroAddress();
        _mint(to, amount);
    }

    /**
     * @notice Batch mint to multiple addresses (for EVM airdrop claims)
     * @dev Can only be called by the owner. Used to mint unclaimed airdrop allocations.
     * @param recipients Array of addresses to mint to
     * @param amounts Array of amounts to mint (must match recipients length)
     */
    function batchMint(address[] calldata recipients, uint256[] calldata amounts) external onlyOwner {
        if (recipients.length != amounts.length) revert LengthMismatch();
        for (uint256 i = 0; i < recipients.length; i++) {
            if (recipients[i] != address(0)) {
                _mint(recipients[i], amounts[i]);
            }
        }
    }
}
