// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import { Script } from "forge-std/Script.sol";
import { console2 } from "forge-std/console2.sol";

/// Minimal AccessControl surface — works against any OZ AccessControl proxy.
interface IAccessControl {
    function hasRole(bytes32 role, address account) external view returns (bool);
    function grantRole(bytes32 role, address account) external;
    function renounceRole(bytes32 role, address account) external;
}

/// @title MigrateRoles
/// @notice Standalone, config-driven handoff of privileged roles from a single
///         bootstrap admin (the deployer EOA) to a timelock + multisig, for
///         contracts that are ALREADY deployed. This is the operation the
///         genesis deploy documents but defers (see Base.sol H-5): on
///         Base Sepolia every role currently sits on one EOA.
///
/// Design goals:
///   - **Configurable**: all addresses + the revoke toggle come from a JSON
///     config (no recompile to retarget). Per-role destinations are encoded in
///     one readable table (`_plan`), the single source of truth for the split.
///   - **Safe**: grants happen before revokes; `DEFAULT_ADMIN_ROLE` is the LAST
///     thing renounced on each contract (never strand a contract admin-less);
///     a role is only renounced from the bootstrap admin once a *new* holder
///     has been granted, and never when the new holder IS the bootstrap admin.
///   - **Idempotent**: grant/renounce are no-ops when already in the target
///     state (guarded by `hasRole`), so re-running converges.
///   - **Auditable**: `dryRun` prints the full plan + current on-chain holders
///     without sending a single transaction.
///
/// Usage:
///   export PRIVATE_KEY=0x...                 # MUST be the currentAdmin EOA
///   export MIGRATE_ROLES_CONFIG=deploy/config/role-migration.base-sepolia.json
///   # dry run (no broadcast needed — prints plan + current holders):
///   forge script script/MigrateRoles.s.sol:MigrateRoles --rpc-url $RPC_URL
///   # execute:
///   forge script script/MigrateRoles.s.sol:MigrateRoles --rpc-url $RPC_URL --broadcast
contract MigrateRoles is Script {
    // OZ AccessControl role ids. DEFAULT_ADMIN_ROLE is bytes32(0); the rest are
    // keccak256 of the role name (identical to the contracts' `public constant`s).
    bytes32 internal constant DEFAULT_ADMIN_ROLE = 0x00;
    bytes32 internal constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 internal constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 internal constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    bytes32 internal constant SLASH_ADMIN_ROLE = keccak256("SLASH_ADMIN_ROLE");
    bytes32 internal constant ASSET_MANAGER_ROLE = keccak256("ASSET_MANAGER_ROLE");
    bytes32 internal constant MINTER_ROLE = keccak256("MINTER_ROLE");

    struct Config {
        string network;
        address tangle;
        address staking;
        address tntToken;
        address currentAdmin; // the single EOA holding everything today
        address timelock; // destination for governance/upgrade authority
        address multisig; // destination for operational authority (pause/slash/assets)
        bool revokeCurrentAdmin; // when false: grant-only (dual-control), keep EOA
        bool dryRun; // when true: print plan only, never broadcast
    }

    // One row of the migration plan: on `target`, move `role` to `newHolder`.
    struct Move {
        address target;
        string contractName;
        bytes32 role;
        string roleName;
        address newHolder;
        bool isDefaultAdmin; // renounced last, per contract
    }

    function run() external {
        Config memory cfg = _loadConfig();
        uint256 adminKey = vm.envUint("PRIVATE_KEY");
        address broadcaster = vm.addr(adminKey);

        _printHeader(cfg, broadcaster);

        // Only the current admin can grant/renounce. Refuse to run otherwise so
        // a wrong key produces a clear error instead of a pile of reverts.
        require(
            broadcaster == cfg.currentAdmin,
            "PRIVATE_KEY must be the currentAdmin EOA from the config"
        );

        Move[] memory plan = _plan(cfg);
        _printPlan(cfg, plan);

        if (cfg.dryRun) {
            console2.log("\n[dry-run] no transactions sent. Set dryRun=false to execute.");
            return;
        }

        vm.startBroadcast(adminKey);
        // 1. Grant every destination first — the new holders must exist before
        //    we drop the bootstrap admin, or a revoke could strand a role.
        for (uint256 i = 0; i < plan.length; i++) {
            _grant(plan[i]);
        }
        // 2. Renounce the bootstrap admin from non-DEFAULT_ADMIN roles.
        if (cfg.revokeCurrentAdmin) {
            for (uint256 i = 0; i < plan.length; i++) {
                if (!plan[i].isDefaultAdmin) _renounce(plan[i], cfg.currentAdmin);
            }
            // 3. Renounce DEFAULT_ADMIN_ROLE LAST (after every other role on
            //    that contract is already in its new home).
            for (uint256 i = 0; i < plan.length; i++) {
                if (plan[i].isDefaultAdmin) _renounce(plan[i], cfg.currentAdmin);
            }
        }
        vm.stopBroadcast();

        _verify(cfg, plan);
        console2.log("\nMigration complete.");
    }

    // ── Plan: the single, readable source of truth for the role split ────────
    //
    // timelock = governance + upgrade authority (slow, on-chain reviewable).
    // multisig = operational authority (pause, slash, asset management).
    function _plan(Config memory cfg) internal pure returns (Move[] memory) {
        Move[] memory m = new Move[](11);
        uint256 n;

        if (cfg.tangle != address(0)) {
            m[n++] = _move(cfg.tangle, "Tangle", ADMIN_ROLE, "ADMIN_ROLE", cfg.timelock, false);
            m[n++] = _move(cfg.tangle, "Tangle", UPGRADER_ROLE, "UPGRADER_ROLE", cfg.timelock, false);
            m[n++] = _move(cfg.tangle, "Tangle", PAUSER_ROLE, "PAUSER_ROLE", cfg.multisig, false);
            m[n++] = _move(cfg.tangle, "Tangle", SLASH_ADMIN_ROLE, "SLASH_ADMIN_ROLE", cfg.multisig, false);
            m[n++] = _move(cfg.tangle, "Tangle", DEFAULT_ADMIN_ROLE, "DEFAULT_ADMIN_ROLE", cfg.timelock, true);
        }

        if (cfg.staking != address(0)) {
            m[n++] = _move(cfg.staking, "Staking", ADMIN_ROLE, "ADMIN_ROLE", cfg.timelock, false);
            // NOTE: staking UPGRADER_ROLE — the genesis handoff in FullDeploy
            // omits this; the EOA holds it on-chain. Included here so the
            // staking proxy's upgrade authority actually moves to the timelock.
            m[n++] = _move(cfg.staking, "Staking", UPGRADER_ROLE, "UPGRADER_ROLE", cfg.timelock, false);
            m[n++] = _move(cfg.staking, "Staking", ASSET_MANAGER_ROLE, "ASSET_MANAGER_ROLE", cfg.multisig, false);
            m[n++] = _move(cfg.staking, "Staking", DEFAULT_ADMIN_ROLE, "DEFAULT_ADMIN_ROLE", cfg.timelock, true);
        }

        if (cfg.tntToken != address(0)) {
            m[n++] = _move(cfg.tntToken, "TntToken", MINTER_ROLE, "MINTER_ROLE", cfg.timelock, false);
            m[n++] = _move(cfg.tntToken, "TntToken", UPGRADER_ROLE, "UPGRADER_ROLE", cfg.timelock, false);
            m[n++] = _move(cfg.tntToken, "TntToken", DEFAULT_ADMIN_ROLE, "DEFAULT_ADMIN_ROLE", cfg.timelock, true);
        }

        // Trim to the populated length.
        Move[] memory out = new Move[](n);
        for (uint256 i = 0; i < n; i++) out[i] = m[i];
        return out;
    }

    function _move(
        address target,
        string memory contractName,
        bytes32 role,
        string memory roleName,
        address newHolder,
        bool isDefaultAdmin
    )
        internal
        pure
        returns (Move memory)
    {
        return Move(target, contractName, role, roleName, newHolder, isDefaultAdmin);
    }

    // ── Execution primitives (idempotent + guarded) ─────────────────────────

    function _grant(Move memory mv) internal {
        if (mv.newHolder == address(0)) return; // no destination configured
        if (IAccessControl(mv.target).hasRole(mv.role, mv.newHolder)) {
            _log("  skip grant (already held)", mv, mv.newHolder);
            return;
        }
        IAccessControl(mv.target).grantRole(mv.role, mv.newHolder);
        _log("  grant", mv, mv.newHolder);
    }

    function _renounce(Move memory mv, address from) internal {
        // Never renounce a role that has no new home, or whose new home IS the
        // account we're renouncing from — that would just strand the role.
        if (mv.newHolder == address(0) || mv.newHolder == from) return;
        if (!IAccessControl(mv.target).hasRole(mv.role, from)) return;
        IAccessControl(mv.target).renounceRole(mv.role, from);
        _log("  renounce", mv, from);
    }

    // ── Config loading ──────────────────────────────────────────────────────

    function _loadConfig() internal view returns (Config memory cfg) {
        string memory path = vm.envString("MIGRATE_ROLES_CONFIG");
        string memory json = vm.readFile(path);
        cfg.network = _tryString(json, ".network");
        cfg.tangle = _tryAddress(json, ".contracts.tangle");
        cfg.staking = _tryAddress(json, ".contracts.staking");
        cfg.tntToken = _tryAddress(json, ".contracts.tntToken");
        cfg.currentAdmin = vm.parseJsonAddress(json, ".currentAdmin");
        cfg.timelock = _tryAddress(json, ".timelock");
        cfg.multisig = _tryAddress(json, ".multisig");
        cfg.revokeCurrentAdmin = vm.parseJsonBool(json, ".revokeCurrentAdmin");
        cfg.dryRun = _tryBool(json, ".dryRun");

        require(cfg.currentAdmin != address(0), "currentAdmin required");
        require(cfg.timelock != address(0) || cfg.multisig != address(0), "set timelock and/or multisig");
        // Don't let a typo'd config quietly hand god-mode back to the EOA.
        require(cfg.timelock != cfg.currentAdmin, "timelock must differ from currentAdmin");
        require(cfg.multisig != cfg.currentAdmin, "multisig must differ from currentAdmin");
    }

    function _tryAddress(string memory json, string memory key) internal view returns (address) {
        try vm.parseJsonAddress(json, key) returns (address a) {
            return a;
        } catch {
            return address(0);
        }
    }

    function _tryBool(string memory json, string memory key) internal view returns (bool) {
        try vm.parseJsonBool(json, key) returns (bool b) {
            return b;
        } catch {
            return false;
        }
    }

    function _tryString(string memory json, string memory key) internal view returns (string memory) {
        try vm.parseJsonString(json, key) returns (string memory s) {
            return s;
        } catch {
            return "";
        }
    }

    // ── Logging / verification ───────────────────────────────────────────────

    function _printHeader(Config memory cfg, address broadcaster) internal pure {
        console2.log("=== Migrate Roles ===");
        console2.log("Network:", bytes(cfg.network).length == 0 ? "unknown" : cfg.network);
        console2.log("Broadcaster:", broadcaster);
        console2.log("Current admin (from):", cfg.currentAdmin);
        console2.log("Timelock (to):", cfg.timelock);
        console2.log("Multisig (to):", cfg.multisig);
        console2.log("Revoke current admin:", cfg.revokeCurrentAdmin);
        console2.log("Dry run:", cfg.dryRun);
    }

    function _printPlan(Config memory cfg, Move[] memory plan) internal view {
        console2.log("\n-- Plan --");
        for (uint256 i = 0; i < plan.length; i++) {
            Move memory mv = plan[i];
            bool held = IAccessControl(mv.target).hasRole(mv.role, cfg.currentAdmin);
            console2.log(
                string.concat(
                    mv.contractName,
                    ".",
                    mv.roleName,
                    held ? " [EOA holds]" : " [EOA absent]"
                )
            );
            console2.log("    -> newHolder:", mv.newHolder);
        }
    }

    function _log(string memory action, Move memory mv, address account) internal pure {
        console2.log(string.concat(action, " ", mv.contractName, ".", mv.roleName));
        console2.log("      account:", account);
    }

    /// Post-run assertions: every destination holds its role, and (when
    /// revoking) the bootstrap admin no longer holds any migrated role.
    function _verify(Config memory cfg, Move[] memory plan) internal view {
        console2.log("\n-- Verify --");
        for (uint256 i = 0; i < plan.length; i++) {
            Move memory mv = plan[i];
            if (mv.newHolder != address(0)) {
                require(
                    IAccessControl(mv.target).hasRole(mv.role, mv.newHolder),
                    string.concat("grant failed: ", mv.contractName, ".", mv.roleName)
                );
            }
            if (cfg.revokeCurrentAdmin && mv.newHolder != cfg.currentAdmin) {
                require(
                    !IAccessControl(mv.target).hasRole(mv.role, cfg.currentAdmin),
                    string.concat("renounce failed: ", mv.contractName, ".", mv.roleName)
                );
            }
        }
        console2.log("  all roles in their target state.");
    }
}
