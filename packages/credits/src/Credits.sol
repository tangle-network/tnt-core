// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Ownable2Step } from "@openzeppelin/contracts/access/Ownable2Step.sol";
import { MerkleProof } from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

/// @title Credits
/// @notice Standalone Merkle-root based credits claim registry (no token transfers).
/// @dev Off-chain systems compute entitlements (e.g. delegated TNT over an epoch), publish a root,
///      and users claim once per epoch to emit an auditable event stream for downstream systems.
contract Credits is Ownable2Step {
    /// @notice Emitted when a user claims credits for an epoch.
    /// @dev Event signature intentionally matches the indexer config.
    event CreditsClaimed(address indexed account, uint256 amount, bytes32 offchainAccountId);

    event MerkleRootUpdated(uint256 indexed epochId, bytes32 oldRoot, bytes32 newRoot);

    error RootNotSet(uint256 epochId);
    error AlreadyClaimed(uint256 epochId, address account);
    error InvalidMerkleProof();

    /// @notice epochId => merkleRoot
    mapping(uint256 => bytes32) public merkleRoots;

    /// @notice epochId => account => claimed?
    mapping(uint256 => mapping(address => bool)) public claimed;

    constructor(address owner_) Ownable(owner_) {}

    /// @notice Publish (or update) the Merkle root for an epoch.
    function setMerkleRoot(uint256 epochId, bytes32 root) external onlyOwner {
        bytes32 old = merkleRoots[epochId];
        merkleRoots[epochId] = root;
        emit MerkleRootUpdated(epochId, old, root);
    }

    /// @notice Claim credits for a given epoch.
    /// @param epochId The epoch/distribution identifier.
    /// @param amount The total credits claimable for `msg.sender` in this epoch.
    /// @param offchainAccountId Product/account identifier (emitted for off-chain reconciliation).
    /// @param merkleProof Merkle proof for (epochId, msg.sender, amount).
    function claim(
        uint256 epochId,
        uint256 amount,
        bytes32 offchainAccountId,
        bytes32[] calldata merkleProof
    ) external {
        bytes32 root = merkleRoots[epochId];
        if (root == bytes32(0)) revert RootNotSet(epochId);
        if (claimed[epochId][msg.sender]) revert AlreadyClaimed(epochId, msg.sender);

        bytes32 leaf = _leaf(epochId, msg.sender, amount);
        if (!MerkleProof.verify(merkleProof, root, leaf)) revert InvalidMerkleProof();

        claimed[epochId][msg.sender] = true;
        emit CreditsClaimed(msg.sender, amount, offchainAccountId);
    }

    /// @notice Verify a proof without claiming.
    function verify(
        uint256 epochId,
        address account,
        uint256 amount,
        bytes32[] calldata merkleProof
    ) external view returns (bool) {
        bytes32 root = merkleRoots[epochId];
        if (root == bytes32(0)) return false;
        return MerkleProof.verify(merkleProof, root, _leaf(epochId, account, amount));
    }

    function _leaf(uint256 epochId, address account, uint256 amount) internal pure returns (bytes32) {
        // Matches OpenZeppelin StandardMerkleTree leaf hashing.
        return keccak256(bytes.concat(keccak256(abi.encode(epochId, account, amount))));
    }
}
