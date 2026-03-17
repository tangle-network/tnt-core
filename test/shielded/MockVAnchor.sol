// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { CommonExtData, PublicInputs, Encryptions } from "protocol-solidity/structs/PublicInputs.sol";

/// @title MockVAnchor
/// @notice Simulates a VAnchorTree for testing the ShieldedGateway integration.
///         Skips ZK proof verification — just validates structure and transfers tokens.
///         In production, the real audited VAnchorTree validates Groth16 proofs.
contract MockVAnchor {
    using SafeERC20 for IERC20;

    address public immutable token;
    mapping(uint256 => bool) public nullifierHashes;

    event MockTransact(address recipient, int256 extAmount, uint256 fee);

    constructor(address _token) {
        token = _token;
    }

    /// @notice Simulates VAnchor.transact() — accepts the same signature.
    ///         In tests, the mock holds tokens (pre-funded) and transfers on withdrawal.
    function transact(
        bytes memory, /* _proof */
        bytes memory, /* _auxPublicInputs */
        CommonExtData memory _externalData,
        PublicInputs memory _publicInputs,
        Encryptions memory /* _encryptions */
    )
        external
        payable
    {
        // Mark nullifiers as spent (prevents double-spend even in mock)
        for (uint256 i = 0; i < _publicInputs.inputNullifiers.length; i++) {
            require(!nullifierHashes[_publicInputs.inputNullifiers[i]], "MockVAnchor: nullifier spent");
            nullifierHashes[_publicInputs.inputNullifiers[i]] = true;
        }

        // Handle withdrawal (negative extAmount)
        if (_externalData.extAmount < 0) {
            uint256 amount = uint256(-_externalData.extAmount);
            IERC20(token).safeTransfer(_externalData.recipient, amount);
        }

        // Handle deposit (positive extAmount) — just pull tokens in
        if (_externalData.extAmount > 0) {
            IERC20(token).safeTransferFrom(msg.sender, address(this), uint256(_externalData.extAmount));
        }

        // Handle fee
        if (_externalData.fee > 0 && _externalData.relayer != address(0)) {
            IERC20(token).safeTransfer(_externalData.relayer, _externalData.fee);
        }

        emit MockTransact(_externalData.recipient, _externalData.extAmount, _externalData.fee);
    }
}
