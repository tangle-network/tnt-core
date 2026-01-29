// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Clones } from "@openzeppelin/contracts/proxy/Clones.sol";
import { TNTCliffLock } from "./TNTCliffLock.sol";

/// @title TNTLockFactory
/// @notice Deploys per-beneficiary cliff locks for TNT (or any ERC20) using minimal proxies.
contract TNTLockFactory {
    // forge-lint: disable-next-line(screaming-snake-case-immutable)
    address public immutable implementation;

    event LockCreated(address indexed token, address indexed beneficiary, address lock, uint64 unlockTimestamp, address delegatee);

    constructor() {
        implementation = address(new TNTCliffLock());
    }

    function predictLockAddress(address token, address beneficiary, uint64 unlockTimestamp) public view returns (address) {
        bytes32 salt = keccak256(abi.encode(token, beneficiary, unlockTimestamp));
        return Clones.predictDeterministicAddress(implementation, salt, address(this));
    }

    function getOrCreateLock(
        address token,
        address beneficiary,
        uint64 unlockTimestamp,
        address delegatee
    ) external returns (address lock) {
        bytes32 salt = keccak256(abi.encode(token, beneficiary, unlockTimestamp));
        lock = Clones.predictDeterministicAddress(implementation, salt, address(this));
        if (lock.code.length == 0) {
            lock = Clones.cloneDeterministic(implementation, salt);
            TNTCliffLock(lock).initialize(token, beneficiary, unlockTimestamp, delegatee);
            emit LockCreated(token, beneficiary, lock, unlockTimestamp, delegatee);
        }
    }
}

