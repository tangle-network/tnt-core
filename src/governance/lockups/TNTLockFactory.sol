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
    /// @dev Permissionless by design so the genesis distributor can batch-create locks on
    ///      behalf of every recipient. Creation is hijack-safe because the lock NEVER
    ///      delegates voting power at construction time: the `delegatee` argument is recorded
    ///      in the event for off-chain visibility but is NOT acted upon. Only the beneficiary
    ///      can ever set delegation, via the `onlyBeneficiary` `TNTCliffLock.delegate(...)`.
    ///
    ///      Invariant: a third party front-running `getOrCreateLock` can deploy the clone but
    ///      cannot direct its voting power anywhere — `_delegates[lock]` stays `address(0)`
    ///      until the beneficiary themselves delegates. This closes the delegation-hijack that
    ///      a caller-chosen, auto-applied `delegatee` previously enabled, without reintroducing
    ///      the deployer-side DoS that a `msg.sender == beneficiary` guard caused.
    function getOrCreateLock(
        address token,
        address beneficiary,
        uint64 unlockTimestamp,
        address delegatee
    )
        external
        returns (address lock)
    {
        bytes32 salt = keccak256(abi.encode(token, beneficiary, unlockTimestamp));
        lock = Clones.predictDeterministicAddress(implementation, salt, address(this));
        if (lock.code.length == 0) {
            lock = Clones.cloneDeterministic(implementation, salt);
            // delegatee is intentionally NOT forwarded as an auto-delegation target: see the
            // hijack-safety invariant above. It is retained only for the event record.
            TNTCliffLock(lock).initialize(token, beneficiary, unlockTimestamp, delegatee);
            emit LockCreated(token, beneficiary, lock, unlockTimestamp, delegatee);
        }
    }

    /// @dev Retained for ABI/error-stability. No longer thrown: `getOrCreateLock` is now
    ///      permissionless (it is hijack-safe because creation never auto-delegates), so the
    ///      former `msg.sender == beneficiary` guard — which DoS'd the batch distributor — is
    ///      gone. Kept so existing consumers / tooling that reference this selector still build.
    error NotBeneficiary(address caller, address beneficiary);
}

