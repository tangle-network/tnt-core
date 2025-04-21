// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import { Assets } from "./AssetsLib.sol";

/// @title Service Operators Library
/// @author Tangle Network Team
/// @dev Contains structs and enums related to service operators.
/// @notice Holds different structs and enums related to service operators.
library ServiceOperators {
    /// @dev Represents the preferences of an operator, including their ECDSA public key and RPC address.
    struct OperatorPreferences {
        /// @notice The ECDSA public key of the operator.
        bytes ecdsaPublicKey;
        /// @notice The address of the RPC server the operator is running.
        string rpcAddress;
    }

    /// @dev Defines the pricing targets for various resources such as CPU, memory, and different types of storage.
    struct PriceTargets {
        /// @notice The CPU price target.
        uint64 cpu;
        /// @notice The memory price target.
        uint64 mem;
        /// @notice The HDD storage price target.
        uint64 storage_hdd;
        /// @notice The SSD storage price target.
        uint64 storage_ssd;
        /// @notice The NVMe storage price target.
        uint64 storage_nvme;
    }

    /// @dev Represents parameters for a service request
    struct RequestParams {
        /// @notice Unique identifier for the request
        uint64 requestId;
        /// @notice Address of the requester
        address requester;
        /// @notice Array of operator preferences containing ECDSA public keys and RPC addresses
        OperatorPreferences[] operators;
        /// @notice Input parameters for the request encoded as bytes
        bytes requestInputs;
        /// @notice Array of addresses that are permitted to call the service
        address[] permittedCallers;
        /// @notice Time-to-live value indicating how long the service is valid
        uint64 ttl;
        /// @notice Asset to be used for payment
        Assets.Asset paymentAsset;
        /// @notice Amount of payment asset to be used
        uint256 amount;
    }

    /// @dev Converts a public key to an operator address.
    /// @param publicKey The uncompressed public key to convert.
    /// @return operator address The operator address.
    function asOperatorAddress(bytes calldata publicKey) internal pure returns (address operator) {
        return address(uint160(uint256(keccak256(publicKey))));
    }
}
