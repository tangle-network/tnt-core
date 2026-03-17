// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { CommonExtData, PublicInputs, Encryptions } from "protocol-solidity/structs/PublicInputs.sol";

/// @title IVAnchor
/// @notice Minimal interface for calling VAnchorTree.transact() from the gateway.
///         Extracted from the audited protocol-solidity contracts — no new logic.
interface IVAnchor {
    /// @notice Execute a shielded transaction (deposit, withdraw, or transfer)
    function transact(
        bytes memory _proof,
        bytes memory _auxPublicInputs,
        CommonExtData memory _externalData,
        PublicInputs memory _publicInputs,
        Encryptions memory _encryptions
    )
        external
        payable;

    /// @notice The wrapped token this VAnchor pool manages
    function token() external view returns (address);
}
