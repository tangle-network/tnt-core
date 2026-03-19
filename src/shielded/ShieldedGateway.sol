// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

import { Types } from "../libraries/Types.sol";
import { ITangle } from "../interfaces/ITangle.sol";
import { IShieldedGateway } from "./IShieldedGateway.sol";
import { IShieldedCredits } from "./IShieldedCredits.sol";
import { IVAnchor } from "./IVAnchor.sol";

// protocol-solidity structs (audited, unmodified)
import { CommonExtData, PublicInputs, Encryptions } from "protocol-solidity/structs/PublicInputs.sol";

/// @title ShieldedGateway
/// @author Tangle Network
/// @notice Bridges protocol-solidity's VAnchor shielded pools with tnt-core services.
///         Users deposit into VAnchor pools (gaining anonymity), then spend UTXOs through
///         this gateway to anonymously request services, fund escrows, and submit jobs.
///
/// @dev AUDIT SURFACE: This contract is the ONLY new code. It calls into two audited systems:
///      1. protocol-solidity VAnchorTree — audited by Veridise (unmodified git submodule)
///      2. tnt-core Tangle — audited (existing contracts, no modifications)
///
///      The gateway acts as a proxy: the VAnchor withdraws tokens to the gateway,
///      then the gateway forwards them to tnt-core on behalf of the anonymous user.
///      From tnt-core's perspective, the gateway is just another address funding services.
///
/// @dev THREAT MODEL:
///      - Gateway owner can register/deregister pools but CANNOT access user funds
///      - Gateway never holds funds beyond a single transaction (atomic spend-and-forward)
///      - Anonymity set = all depositors in the VAnchor pool for that token
///      - Gateway cannot link VAnchor nullifiers to tnt-core service IDs (no mapping stored)
///      - permittedCallers should be ephemeral keys to avoid linking on-chain identity
contract ShieldedGateway is IShieldedGateway, Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    /// @notice The tnt-core Tangle contract
    ITangle public immutable tangle;

    /// @notice The ShieldedCredits contract for pay-per-use accounts
    IShieldedCredits public immutable credits;

    /// @notice Wrapped token address => VAnchorTree pool address
    mapping(address => address) internal _pools;

    /// @param _tangle The tnt-core Tangle contract address
    /// @param _credits The ShieldedCredits contract address
    /// @param _owner The gateway admin (can register pools)
    constructor(address _tangle, address _credits, address _owner) Ownable(_owner) {
        tangle = ITangle(_tangle);
        credits = IShieldedCredits(_credits);
    }

    // ═══════════════════════════════════════════════════════════════════════
    // POOL MANAGEMENT (owner only)
    // ═══════════════════════════════════════════════════════════════════════

    /// @inheritdoc IShieldedGateway
    function registerPool(address wrappedToken, address pool) external onlyOwner {
        if (_pools[wrappedToken] != address(0)) revert PoolAlreadyRegistered(wrappedToken);
        _pools[wrappedToken] = pool;
        emit PoolRegistered(wrappedToken, pool);
    }

    /// @notice Update or deregister a pool. Set pool to address(0) to deregister.
    function updatePool(address wrappedToken, address pool) external onlyOwner {
        _pools[wrappedToken] = pool;
        emit PoolRegistered(wrappedToken, pool);
    }

    /// @inheritdoc IShieldedGateway
    function getPool(address wrappedToken) external view returns (address) {
        return _pools[wrappedToken];
    }

    // ═══════════════════════════════════════════════════════════════════════
    // SHIELDED OPERATIONS
    // ═══════════════════════════════════════════════════════════════════════

    /// @inheritdoc IShieldedGateway
    function shieldedRequestService(
        VAnchorProof calldata anchorProof,
        ServiceRequestParams calldata params
    )
        external
        payable
        nonReentrant
        returns (uint64 requestId)
    {
        (address wrappedToken, uint256 amount) = _executeShieldedWithdrawal(anchorProof);

        IERC20(wrappedToken).forceApprove(address(tangle), amount);

        requestId = tangle.requestService(
            params.blueprintId,
            params.operators,
            params.config,
            params.permittedCallers,
            params.ttl,
            wrappedToken,
            amount,
            params.confidentiality
        );

        emit ShieldedServiceRequested(requestId, _pools[wrappedToken], amount);
    }

    /// @inheritdoc IShieldedGateway
    function shieldedFundService(VAnchorProof calldata anchorProof, uint64 serviceId) external payable nonReentrant {
        (address wrappedToken, uint256 amount) = _executeShieldedWithdrawal(anchorProof);

        IERC20(wrappedToken).forceApprove(address(tangle), amount);
        tangle.fundService(serviceId, amount);

        emit ShieldedServiceFunded(serviceId, _pools[wrappedToken], amount);
    }

    // NOTE: shieldedSubmitJob was removed. Per-job payments should use ShieldedCredits
    // (fund once via shieldedFundCredits, then sign cheap EIP-712 spend authorizations per job).
    // A VAnchor withdrawal per job is too expensive and the gateway cannot forward tokens
    // to tnt-core's submitJob (which doesn't pull payment).

    /// @inheritdoc IShieldedGateway
    function shieldedFundCredits(
        VAnchorProof calldata anchorProof,
        bytes32 commitment,
        address spendingKey
    )
        external
        payable
        nonReentrant
    {
        (address wrappedToken, uint256 amount) = _executeShieldedWithdrawal(anchorProof);

        IERC20(wrappedToken).forceApprove(address(credits), amount);
        credits.fundCredits(wrappedToken, amount, commitment, spendingKey);

        emit ShieldedCreditsFunded(commitment, _pools[wrappedToken], amount);
    }

    // ═══════════════════════════════════════════════════════════════════════
    // INTERNAL
    // ═══════════════════════════════════════════════════════════════════════

    /// @notice Execute a VAnchor withdrawal, sending tokens to this contract.
    /// @dev The extData.recipient MUST be this contract for the atomic flow.
    ///      The VAnchor validates the ZK proof, marks nullifiers as spent,
    ///      and transfers tokens to the recipient (this contract).
    /// @return wrappedToken The wrapped token address
    /// @return amount The absolute withdrawal amount
    function _executeShieldedWithdrawal(VAnchorProof calldata anchorProof)
        internal
        returns (address wrappedToken, uint256 amount)
    {
        CommonExtData memory extData = abi.decode(anchorProof.externalData, (CommonExtData));

        // The withdrawal amount is negative extAmount
        if (extData.extAmount >= 0) revert InvalidSpendAmount();
        amount = uint256(-extData.extAmount);

        // Recipient must be this contract
        if (extData.recipient != address(this)) revert InvalidRecipient();

        // Resolve the pool
        wrappedToken = extData.token;
        address pool = _pools[wrappedToken];
        if (pool == address(0)) revert PoolNotRegistered(wrappedToken);

        // Decode structured inputs for the VAnchor call
        PublicInputs memory pubInputs = abi.decode(anchorProof.publicInputs, (PublicInputs));
        Encryptions memory enc = abi.decode(anchorProof.encryptions, (Encryptions));

        // Record balance before to verify exact amount received
        uint256 balBefore = IERC20(wrappedToken).balanceOf(address(this));

        // Call VAnchor.transact() — validates ZK proof, marks nullifiers, transfers tokens
        IVAnchor(pool).transact{ value: msg.value }(
            anchorProof.proof, anchorProof.auxPublicInputs, extData, pubInputs, enc
        );

        // Verify we received exactly the expected amount
        uint256 balAfter = IERC20(wrappedToken).balanceOf(address(this));
        if (balAfter - balBefore < amount) revert InvalidSpendAmount();
    }

    /// @notice Rescue ETH accidentally sent to the gateway.
    function rescueETH(address payable recipient) external onlyOwner {
        uint256 balance = address(this).balance;
        (bool success,) = recipient.call{ value: balance }("");
        require(success);
    }

    /// @notice Allows the gateway to receive native tokens (for native VAnchor refunds)
    receive() external payable { }
}
