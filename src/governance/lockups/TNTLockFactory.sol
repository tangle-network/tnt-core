// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Clones } from "@openzeppelin/contracts/proxy/Clones.sol";
import { TNTCliffLock } from "./TNTCliffLock.sol";

/// @title TNTLockFactory
/// @notice Deploys per-beneficiary cliff locks for TNT (or any ERC20) using minimal proxies.
contract TNTLockFactory {
    // forge-lint: disable-next-line(screaming-snake-case-immutable)
    address public immutable implementation;

    event LockCreated(
        address indexed token, address indexed beneficiary, address lock, uint64 unlockTimestamp, address delegatee
    );

    constructor() {
        implementation = address(new TNTCliffLock());
    }

    function predictLockAddress(
        address token,
        address beneficiary,
        uint64 unlockTimestamp
    )
        public
        view
        returns (address)
    {
        bytes32 salt = keccak256(abi.encode(token, beneficiary, unlockTimestamp));
        return Clones.predictDeterministicAddress(implementation, salt, address(this));
    }

    /// @notice Create or fetch the deterministic lock for `(token, beneficiary, unlockTimestamp)`.
    /// @dev Only the beneficiary can pick the delegatee. Without this restriction,
    ///      any third party could call `getOrCreateLock(..., attacker)` BEFORE the
    ///      beneficiary touches the contract — the clone's `initialize` calls
    ///      `IVotes.delegate(attacker)` from the lock address, persistently writing
    ///      `_delegates[lock] = attacker`. When the airdrop / vesting transfer
    ///      later sends TNT to the predictable lock address, ERC20Votes silently
    ///      credits the attacker with all of the beneficiary's voting power until
    ///      the beneficiary themselves calls `lock.delegate(...)`.
    function getOrCreateLock(
        address token,
        address beneficiary,
        uint64 unlockTimestamp,
        address delegatee
    )
        external
        returns (address lock)
    {
        if (msg.sender != beneficiary) revert NotBeneficiary(msg.sender, beneficiary);
        bytes32 salt = keccak256(abi.encode(token, beneficiary, unlockTimestamp));
        lock = Clones.predictDeterministicAddress(implementation, salt, address(this));
        if (lock.code.length == 0) {
            lock = Clones.cloneDeterministic(implementation, salt);
            TNTCliffLock(lock).initialize(token, beneficiary, unlockTimestamp, delegatee);
            emit LockCreated(token, beneficiary, lock, unlockTimestamp, delegatee);
        }
    }

    error NotBeneficiary(address caller, address beneficiary);
}

