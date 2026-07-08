// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";
import { ValidatorPod } from "./ValidatorPod.sol";

/// @title ValidatorPodManagerLib
/// @notice Deployed (delegatecall-linked) library holding the heaviest state-mutating routines of
/// {ValidatorPodManager}: `delegateTo`, `queueUndelegation`, `completeUndelegation`, and `_slash`.
/// Declaring the entry points `public` forces the compiler to emit them as a standalone library
/// contract and link them by `DELEGATECALL` instead of inlining, so their code leaves the manager's
/// runtime bytecode.
/// @dev This is the identical technique {ServiceFeeDistributorLib} uses for {ServiceFeeDistributor}.
/// It exists so `ValidatorPodManager` fits under chains that meter code-deposit gas aggressively —
/// Tempo (chain 42431) caps a tx at 30M gas and charges ~1,372 gas/byte, giving a ~21,870 B deploy
/// ceiling. The library runs by `DELEGATECALL`, so `msg.sender`, storage, and events resolve in the
/// manager's context exactly as they did inline; behavior, access control, and events are unchanged.
///
/// The library operates on {Layout storage self} — the manager's ENTIRE storage, one field per slot
/// in the manager's exact declared order (including the two inherited leading slots from `Ownable`
/// and `ReentrancyGuard`). Slot indices MUST match the pre-refactor layout; do not reorder, insert,
/// or retype any field.
library ValidatorPodManagerLib {
    using Math for uint256;

    /// @dev Virtual shares/assets offset. MUST equal the manager's `VIRTUAL_SHARES`/`VIRTUAL_ASSETS`.
    uint256 internal constant VIRTUAL_SHARES = 1e3;
    uint256 internal constant VIRTUAL_ASSETS = 1e3;

    /// @dev Basis-point denominator. MUST equal the manager's `BPS_DENOMINATOR`.
    uint256 internal constant BPS_DENOMINATOR = 10_000;

    // ═══════════════════════════════════════════════════════════════════════════
    // STORAGE-MIRRORED STRUCTS (must match {ValidatorPodManager} bit-for-bit)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @dev Mirror of `ValidatorPodManager.BeaconPool`.
    struct BeaconPool {
        uint256 totalAssets;
        uint256 totalShares;
    }

    /// @dev Mirror of `ValidatorPodManager.DelegationPool`.
    struct DelegationPool {
        uint256 totalAssets;
        uint256 totalShares;
    }

    /// @dev Mirror of `ValidatorPodManager.Withdrawal`. Unused here but kept so a slot referencing it
    ///      resolves to the same encoding if a future function is added; not read by this library.
    struct Withdrawal {
        address staker;
        uint256 shares;
        uint256 assets;
        uint32 startBlock;
        bool completed;
    }

    /// @dev Mirror of `ValidatorPodManager.Undelegation`.
    struct Undelegation {
        address delegator;
        address operator;
        uint256 amount;
        uint32 startBlock;
        bool completed;
    }

    /// @notice The manager's storage, one field per slot in the original declaration order.
    /// @dev Slots 0..1 are the inherited fields (`Ownable._owner`, `ReentrancyGuard._status`).
    ///      Slots 2.. are `ValidatorPodManager`'s own variables, in declared order. `constant`s carry
    ///      no slot and are omitted. Do not reorder, insert, or retype fields.
    struct Layout {
        // slot 0 — Ownable._owner
        address _owner;
        // slot 1 — ReentrancyGuard._status
        uint256 _status;
        // slot 2
        address beaconOracle;
        // slot 3
        uint256 minOperatorStakeAmount;
        // slot 4
        mapping(address => address) ownerToPod;
        // slot 5
        mapping(address => address) podToOwner;
        // slot 6
        uint256 podCount;
        // slot 7
        mapping(address => BeaconPool) _pools;
        // slot 8
        mapping(address => uint256) _shares;
        // slot 9
        uint256 _aggregateShares;
        // slot 10
        mapping(address => bool) _operators;
        // slot 11
        mapping(address => uint256) operatorStake;
        // slot 12
        mapping(address => uint256) delegatorTotalDelegated;
        // slot 13
        mapping(address => bool) _slashers;
        // slot 14
        uint32 withdrawalDelayBlocks;
        // slot 15
        mapping(bytes32 => Withdrawal) pendingWithdrawals;
        // slot 16
        mapping(address => uint256) withdrawalNonce;
        // slot 17
        mapping(address => uint256) queuedShares;
        // slot 18
        mapping(address => uint256) delegatedShares;
        // slot 19
        mapping(bytes32 => Undelegation) pendingUndelegations;
        // slot 20
        mapping(address => uint256) undelegationNonce;
        // slot 21
        mapping(address => mapping(address => uint256)) queuedUndelegations;
        // slot 22
        mapping(address => DelegationPool) _operatorDelegationPools;
        // slot 23
        mapping(address => mapping(address => uint256)) _delegationShares;
        // slot 24
        mapping(address => mapping(address => uint256)) _delegatorOperatorDelegated;
        // slot 25
        mapping(address => mapping(address => uint256)) _delegatorOperatorEscrowShares;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS (same name/args as the manager → identical topic0 when emitted here)
    // ═══════════════════════════════════════════════════════════════════════════

    event BeaconRebase(address indexed owner, int256 assetsDelta, uint256 newTotalAssets, uint256 totalSharesPool);
    event Delegated(address indexed delegator, address indexed operator, uint256 amount);
    event UndelegationQueued(
        bytes32 indexed undelegationRoot, address indexed delegator, address indexed operator, uint256 amount
    );
    event UndelegationCompleted(
        bytes32 indexed undelegationRoot, address indexed delegator, address indexed operator, uint256 amount
    );
    event OperatorPoolSlashed(
        address indexed operator, uint256 slashedAssets, uint256 newTotalAssets, uint256 totalShares
    );

    // ═══════════════════════════════════════════════════════════════════════════
    // ERRORS (same selectors as the manager)
    // ═══════════════════════════════════════════════════════════════════════════

    error NotOperator();
    error ZeroAmount();
    error ZeroShares();
    error InsufficientShares();
    error UndelegationNotFound();
    error UndelegationNotReady();
    error UndelegationAlreadyCompleted();

    // ═══════════════════════════════════════════════════════════════════════════
    // CONVERSION HELPERS (mirror the manager's internal helpers exactly)
    // ═══════════════════════════════════════════════════════════════════════════

    function _convertToAssets(BeaconPool storage pool, uint256 shares) private view returns (uint256) {
        return shares.mulDiv(pool.totalAssets + VIRTUAL_ASSETS, pool.totalShares + VIRTUAL_SHARES, Math.Rounding.Floor);
    }

    function _convertToShares(BeaconPool storage pool, uint256 assets) private view returns (uint256) {
        return assets.mulDiv(pool.totalShares + VIRTUAL_SHARES, pool.totalAssets + VIRTUAL_ASSETS, Math.Rounding.Floor);
    }

    function _convertDelegationToAssets(DelegationPool storage pool, uint256 shares) private view returns (uint256) {
        return shares.mulDiv(pool.totalAssets + VIRTUAL_ASSETS, pool.totalShares + VIRTUAL_SHARES, Math.Rounding.Floor);
    }

    function _convertDelegationToShares(DelegationPool storage pool, uint256 assets) private view returns (uint256) {
        return assets.mulDiv(pool.totalShares + VIRTUAL_SHARES, pool.totalAssets + VIRTUAL_ASSETS, Math.Rounding.Floor);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // COMPLETE UNDELEGATION (moved verbatim from the manager)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Complete a pending undelegation after the delay period. Runs by `DELEGATECALL` from the
    ///         manager, so `msg.sender`, storage, and events are the manager's — identical to inline.
    /// @dev Behavior, access, and events match the pre-refactor `ValidatorPodManager.completeUndelegation`
    ///      exactly; only the code location moved.
    function completeUndelegation(Layout storage self, bytes32 undelegationRoot) public {
        Undelegation storage undelegation = self.pendingUndelegations[undelegationRoot];

        if (undelegation.delegator != msg.sender) revert UndelegationNotFound();
        if (undelegation.completed) revert UndelegationAlreadyCompleted();

        if (block.number < undelegation.startBlock + self.withdrawalDelayBlocks) {
            revert UndelegationNotReady();
        }

        undelegation.completed = true;

        address operator = undelegation.operator;
        uint256 amount = undelegation.amount;

        self.queuedUndelegations[msg.sender][operator] -= amount;

        DelegationPool storage pool = self._operatorDelegationPools[operator];
        uint256 ownerShares = self._delegationShares[msg.sender][operator];
        uint256 liveAssets = _convertDelegationToAssets(pool, ownerShares);

        uint256 realizedAssets;
        uint256 sharesBurned;
        if (liveAssets <= amount) {
            // Slashed below the requested amount: realize whatever is left and zero out.
            realizedAssets = liveAssets;
            sharesBurned = ownerShares;
        } else {
            realizedAssets = amount;
            sharesBurned = _convertDelegationToShares(pool, amount);
            if (sharesBurned > ownerShares) sharesBurned = ownerShares;
        }

        uint256 remainingShares = ownerShares - sharesBurned;
        self._delegationShares[msg.sender][operator] = remainingShares;
        pool.totalShares -= sharesBurned;
        // Share→asset conversion can round a hair above the pool's tracked assets
        // (e.g. live valuation 16.5e18+dust vs totalAssets 16.5e18 when this delegator
        // holds all shares post-slash). Clamp so the decrement — and the realized payout —
        // never exceed the pool, which would underflow and re-brick the very withdrawal
        // this path exists to unblock.
        if (realizedAssets > pool.totalAssets) realizedAssets = pool.totalAssets;
        pool.totalAssets -= realizedAssets;

        // Pay down the deposit-accounted counters. The counter is asset-denominated
        // against the *deposited* principal, not the slashed live valuation, so we must
        // NOT decrement by `realizedAssets` (which can be below the deposited amount
        // after a slash) — doing so would leave a permanent residue that can never reach
        // 0 and would brick `queueWithdrawal` forever.
        //
        // When this fully unwinds the delegator's position with this operator
        // (remainingShares == 0), clear the ENTIRE per-operator deposited commitment from
        // both counters — that residue is exactly the value lost to slashing and is no
        // longer recoverable, so it must not keep blocking withdrawals.
        //
        // On a partial undelegation (remainingShares > 0), decrement by the requested
        // `amount`. Since `queueUndelegation` bounds `amount` by the live valuation,
        // `amount <= depositedForOperator`, so this can never underflow the per-operator
        // entry; we clamp defensively regardless. This preserves the
        // INVARIANT (aggregate == Σ per-operator) on every path.
        uint256 depositedForOperator = self._delegatorOperatorDelegated[msg.sender][operator];
        uint256 counterDelta;
        if (remainingShares == 0) {
            counterDelta = depositedForOperator;
        } else {
            counterDelta = amount <= depositedForOperator ? amount : depositedForOperator;
        }

        self._delegatorOperatorDelegated[msg.sender][operator] = depositedForOperator - counterDelta;

        uint256 counter = self.delegatorTotalDelegated[msg.sender];
        self.delegatorTotalDelegated[msg.sender] = counter >= counterDelta ? counter - counterDelta : 0;

        // Reconcile the escrowed beacon shares behind this delegation. The portion of the
        // escrow covered by this unwind is proportional to the delegation-pool shares burned.
        // Of that covered escrow, the delegator only KEEPS the slash-adjusted fraction
        // (realized value / deposited value); the slashed remainder is BURNED from their
        // beacon pool so the principal lost to slashing can never be withdrawn. This is what
        // makes a service slash punitive: without it the delegator releases their full escrow
        // and withdraws 100% of beacon principal regardless of the slash.
        // INVARIANT after release+burn: a delegator's withdrawable beacon principal reflects
        // every slash that hit the operators they delegated to.
        uint256 escrowForOperator = self._delegatorOperatorEscrowShares[msg.sender][operator];
        if (escrowForOperator > 0) {
            uint256 escrowCovered;
            if (remainingShares == 0) {
                // Full unwind of this operator: reconcile the entire escrow.
                escrowCovered = escrowForOperator;
            } else {
                // Partial unwind: cover escrow proportional to delegation shares burned.
                escrowCovered = escrowForOperator.mulDiv(sharesBurned, ownerShares, Math.Rounding.Floor);
                if (escrowCovered > escrowForOperator) escrowCovered = escrowForOperator;
            }

            // Surviving (releasable) escrow = covered * realized / depositedCovered.
            // depositedCovered is the deposit-accounted value of the portion being unwound.
            uint256 depositedCovered = counterDelta;
            uint256 escrowToRelease;
            if (depositedCovered == 0 || realizedAssets >= depositedCovered) {
                // No value lost on the covered portion: release all covered escrow.
                escrowToRelease = escrowCovered;
            } else {
                escrowToRelease = escrowCovered.mulDiv(realizedAssets, depositedCovered, Math.Rounding.Floor);
            }
            uint256 escrowToBurn = escrowCovered - escrowToRelease;

            // Unlock the covered escrow from the delegation locks.
            self._delegatorOperatorEscrowShares[msg.sender][operator] = escrowForOperator - escrowCovered;
            uint256 locked = self.delegatedShares[msg.sender];
            self.delegatedShares[msg.sender] = locked >= escrowCovered ? locked - escrowCovered : 0;

            // Burn the slashed portion out of the delegator's beacon pool: destroy the
            // shares and the principal they represent so they are never withdrawable.
            if (escrowToBurn > 0) {
                BeaconPool storage bp = self._pools[msg.sender];
                uint256 burnShares = escrowToBurn > self._shares[msg.sender] ? self._shares[msg.sender] : escrowToBurn;
                if (burnShares > bp.totalShares) burnShares = bp.totalShares;
                uint256 burnAssets = _convertToAssets(bp, burnShares);
                self._shares[msg.sender] -= burnShares;
                self._aggregateShares -= burnShares;
                bp.totalShares -= burnShares;
                bp.totalAssets = burnAssets >= bp.totalAssets ? 0 : bp.totalAssets - burnAssets;
                // forge-lint: disable-next-line(unsafe-typecast)
                emit BeaconRebase(msg.sender, -int256(burnAssets), bp.totalAssets, bp.totalShares);

                // The burn lowered `totalAssets`, but the slashed ETH (if it has physically
                // arrived) is still in the pod. Tell the pod to floor `withdrawNonBeaconChainEth`
                // at the burned amount so the owner cannot drain the slashed principal as fake
                // "non-beacon surplus" once the floor drops. Without this the service slash is
                // non-punitive: the owner re-extracts 100% of principal despite the slash.
                address podAddr = self.ownerToPod[msg.sender];
                if (podAddr != address(0) && burnAssets > 0) {
                    ValidatorPod(payable(podAddr)).recordSlashedPrincipalRetained(burnAssets);
                }
            }
        }

        emit UndelegationCompleted(undelegationRoot, msg.sender, operator, realizedAssets);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // DELEGATE (moved verbatim from the manager)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Delegate beacon-pool assets to an operator. Runs by `DELEGATECALL`, so it mutates the
    ///         manager's storage and emits from the manager's address. Behavior/events unchanged.
    function delegateTo(Layout storage self, address operator, uint256 amount) public {
        if (!self._operators[operator]) revert NotOperator();
        if (amount == 0) revert ZeroAmount();

        // Only beacon shares that are neither already queued for withdrawal nor already
        // locked behind another delegation may back a new delegation. Enforcing this in
        // share space (the canonical custody unit) — instead of trusting the conservative
        // asset counter alone — closes the double-count where shares queued for withdrawal
        // were delegated again, then withdrawn for real, leaving a phantom delegation.
        // INVARIANT: _shares[d] >= queuedShares[d] + delegatedShares[d] after this call.
        BeaconPool storage beaconPool = self._pools[msg.sender];
        uint256 ownerShares = self._shares[msg.sender];
        uint256 lockedShares = self.queuedShares[msg.sender] + self.delegatedShares[msg.sender];
        uint256 freeShares = ownerShares > lockedShares ? ownerShares - lockedShares : 0;
        uint256 freeAssets = _convertToAssets(beaconPool, freeShares);
        if (freeAssets < amount) {
            revert InsufficientShares();
        }

        // Lock the beacon shares that collateralize this delegation, at the current pool rate.
        // Over-delegation is already prevented by the `freeAssets < amount` gate above; this
        // escrow is what `completeUndelegation` later releases (surviving) and burns (slashed).
        // Floor a non-zero delegation to at least one share and clamp to the free shares so
        // the no-double-spend INVARIANT (_shares >= queued + delegated) can never be violated.
        uint256 escrowShares = _convertToShares(beaconPool, amount);
        if (escrowShares == 0) escrowShares = 1;
        if (escrowShares > freeShares) escrowShares = freeShares;

        DelegationPool storage pool = self._operatorDelegationPools[operator];
        uint256 mintedShares = _convertDelegationToShares(pool, amount);
        if (mintedShares == 0) revert ZeroShares();

        pool.totalAssets += amount;
        pool.totalShares += mintedShares;
        self._delegationShares[msg.sender][operator] += mintedShares;

        // Lock the collateralizing beacon shares.
        self.delegatedShares[msg.sender] += escrowShares;
        self._delegatorOperatorEscrowShares[msg.sender][operator] += escrowShares;

        // Maintain the aggregate counter and its per-operator partition in lockstep so
        // the INVARIANT (aggregate == Σ per-operator) holds.
        self.delegatorTotalDelegated[msg.sender] += amount;
        self._delegatorOperatorDelegated[msg.sender][operator] += amount;

        emit Delegated(msg.sender, operator, amount);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // QUEUE UNDELEGATION (moved verbatim from the manager)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Queue an undelegation from an operator. Runs by `DELEGATECALL`; behavior/events unchanged.
    function queueUndelegation(
        Layout storage self,
        address operator,
        uint256 amount
    )
        public
        returns (bytes32 undelegationRoot)
    {
        if (amount == 0) revert ZeroAmount();

        uint256 currentDelegation = _convertDelegationToAssets(
            self._operatorDelegationPools[operator], self._delegationShares[msg.sender][operator]
        );
        uint256 alreadyQueued = self.queuedUndelegations[msg.sender][operator];

        if (currentDelegation < alreadyQueued + amount) revert InsufficientShares();

        uint256 nonce = self.undelegationNonce[msg.sender]++;
        undelegationRoot = keccak256(abi.encodePacked(msg.sender, operator, amount, block.number, nonce));

        self.pendingUndelegations[undelegationRoot] = Undelegation({
            delegator: msg.sender,
            operator: operator,
            amount: amount,
            startBlock: uint32(block.number),
            completed: false
        });

        self.queuedUndelegations[msg.sender][operator] += amount;

        emit UndelegationQueued(undelegationRoot, msg.sender, operator, amount);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SLASH (moved verbatim from the manager)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Internal slash. O(1): one SLOAD/SSTORE for self-stake, one for the delegation pool's
    ///         `totalAssets`. Per-delegator effective stake drops proportionally via unchanged shares.
    /// @dev Behavior and events match the pre-refactor `ValidatorPodManager._slash` exactly; only the
    ///      code location moved. Runs by `DELEGATECALL`, so it mutates the manager's storage.
    function slash(Layout storage self, address operator, uint16 slashBps) public returns (uint256 actualSlashed) {
        if (slashBps > BPS_DENOMINATOR) {
            slashBps = uint16(BPS_DENOMINATOR);
        }

        DelegationPool storage pool = self._operatorDelegationPools[operator];
        uint256 selfBefore = self.operatorStake[operator];
        uint256 delegatedBefore = pool.totalAssets;
        uint256 totalStake = selfBefore + delegatedBefore;

        uint256 amount = (totalStake * slashBps) / BPS_DENOMINATOR;
        actualSlashed = amount;

        // Self-stake first.
        uint256 selfSlash = amount > selfBefore ? selfBefore : amount;
        if (selfSlash > 0) {
            self.operatorStake[operator] = selfBefore - selfSlash;
            amount -= selfSlash;
        }

        // Delegation pool: decrement totalAssets only; shares are untouched so every
        // delegator's effective claim drops proportionally in a single SSTORE.
        if (amount > 0 && delegatedBefore > 0) {
            uint256 poolSlash = amount > delegatedBefore ? delegatedBefore : amount;
            uint256 newTotal = delegatedBefore - poolSlash;
            pool.totalAssets = newTotal;
            emit OperatorPoolSlashed(operator, poolSlash, newTotal, pool.totalShares);
        }
    }
}
