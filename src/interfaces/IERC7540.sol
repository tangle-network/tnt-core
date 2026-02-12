// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { IERC4626 } from "@openzeppelin/contracts/interfaces/IERC4626.sol";

/// @title IERC7540Deposit
/// @notice Interface for asynchronous deposit requests
/// @dev See https://eips.ethereum.org/EIPS/eip-7540
interface IERC7540Deposit {
    /// @notice Emitted when a deposit request is created
    event DepositRequest(
        address indexed controller, address indexed owner, uint256 indexed requestId, address sender, uint256 assets
    );

    /// @notice Request an asynchronous deposit
    /// @param assets Amount of assets to deposit
    /// @param controller Address that controls the request
    /// @param owner Address that owns the assets
    /// @return requestId Unique identifier for this request
    function requestDeposit(uint256 assets, address controller, address owner) external returns (uint256 requestId);

    /// @notice Get pending deposit request amount
    /// @param requestId The request identifier
    /// @param controller The controller address
    /// @return assets Amount of assets pending
    function pendingDepositRequest(uint256 requestId, address controller) external view returns (uint256 assets);

    /// @notice Get claimable deposit request amount
    /// @param requestId The request identifier
    /// @param controller The controller address
    /// @return assets Amount of assets claimable
    function claimableDepositRequest(uint256 requestId, address controller) external view returns (uint256 assets);
}

/// @title IERC7540Redeem
/// @notice Interface for asynchronous redemption requests
/// @dev See https://eips.ethereum.org/EIPS/eip-7540
interface IERC7540Redeem {
    /// @notice Emitted when a redeem request is created
    event RedeemRequest(
        address indexed controller, address indexed owner, uint256 indexed requestId, address sender, uint256 shares
    );

    /// @notice Request an asynchronous redemption
    /// @param shares Amount of shares to redeem
    /// @param controller Address that controls the request
    /// @param owner Address that owns the shares
    /// @return requestId Unique identifier for this request
    function requestRedeem(uint256 shares, address controller, address owner) external returns (uint256 requestId);

    /// @notice Get pending redeem request amount
    /// @param requestId The request identifier
    /// @param controller The controller address
    /// @return shares Amount of shares pending
    function pendingRedeemRequest(uint256 requestId, address controller) external view returns (uint256 shares);

    /// @notice Get claimable redeem request amount
    /// @param requestId The request identifier
    /// @param controller The controller address
    /// @return shares Amount of shares claimable
    function claimableRedeemRequest(uint256 requestId, address controller) external view returns (uint256 shares);
}

/// @title IERC7540Operator
/// @notice Interface for operator management in ERC7540
interface IERC7540Operator {
    /// @notice Emitted when operator approval changes
    event OperatorSet(address indexed controller, address indexed operator, bool approved);

    /// @notice Check if operator is approved for controller
    /// @param controller The controller address
    /// @param operator The operator address
    /// @return status True if approved
    function isOperator(address controller, address operator) external view returns (bool status);

    /// @notice Grant or revoke operator permissions
    /// @param operator The operator address
    /// @param approved True to approve, false to revoke
    /// @return success True if successful
    function setOperator(address operator, bool approved) external returns (bool success);
}

/// @title IERC7540
/// @notice Full ERC7540 interface combining deposit, redeem, and operator management
/// @dev Extends ERC4626 with asynchronous request patterns
interface IERC7540 is IERC4626, IERC7540Deposit, IERC7540Redeem, IERC7540Operator { }
