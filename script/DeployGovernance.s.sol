// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Script, console2 } from "forge-std/Script.sol";
import { stdJson } from "forge-std/StdJson.sol";

import { GovernanceDeployer } from "../src/governance/GovernanceDeployer.sol";
import { TangleTimelock } from "../src/governance/TangleTimelock.sol";

/// @title DeployGovernance
/// @notice Deploys the on-chain governance stack — TNT token (or reuses one) + `TangleTimelock` +
///         `TangleGovernor` — via the audited `GovernanceDeployer` helper, then renounces the
///         bootstrap timelock admin for full decentralization.
/// @dev Ordering: this runs BEFORE `FullDeploy`. The Timelock address it produces is what
///      `roles.timelock` in the FullDeploy config must point at; the token it produces (or reuses)
///      is what `incentives.tntToken` must point at. Sequence:
///        1. DeployGovernance  -> token (fresh or reused) + Timelock + Governor (this script).
///        2. FullDeploy        -> core, with roles.timelock + incentives.tntToken pinned to step 1.
///
///      Role model is `GovernanceDeployer`'s: Governor holds PROPOSER + EXECUTOR + CANCELLER on the
///      Timelock; the deployer's bootstrap DEFAULT_ADMIN_ROLE is renounced so the timelock
///      self-administers (all future role changes must pass through governance). Wiring an
///      independent CANCELLER guardian Safe (which would let quorum drop 6%->4%) is a deliberate
///      follow-up, not done here.
///
///      Governance params are read from the `governance` block of FULL_DEPLOY_CONFIG.
///
///      Usage (reuse an existing TNT token — the mainnet path):
///        PRIVATE_KEY=<pk> TOKEN=<TNT ERC20Votes> \
///        FULL_DEPLOY_CONFIG=deploy/config/base-mainnet.json \
///        forge script script/DeployGovernance.s.sol:DeployGovernance --rpc-url <rpc> --broadcast
///
///      Usage (deploy a fresh TNT token of INITIAL_SUPPLY, admin = deployer for distribution):
///        PRIVATE_KEY=<pk> INITIAL_SUPPLY=<wei> FULL_DEPLOY_CONFIG=<cfg> forge script ... --broadcast
///
///      On a production chain the params must clear conservative floors (no testnet 20m/3h leak).
///      Bypass the chain guard on anvil with TANGLE_DEPLOY_LOCAL=1.
contract DeployGovernance is Script {
    using stdJson for string;

    function run() external {
        uint256 deployerKey = _requireUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerKey);
        address existingToken = _envAddress("TOKEN", address(0));
        uint256 initialSupply = vm.envOr("INITIAL_SUPPLY", uint256(0));

        GovernanceDeployer.DeployParams memory params = _loadParams(deployer, existingToken, initialSupply);
        _requireProductionParams(existingToken, params);

        console2.log("=== Deploy Governance (token + Timelock + Governor) ===");
        console2.log("ChainId:", block.chainid);
        console2.log("Deployer:", deployer);
        console2.log("Existing token (0 = deploy fresh):", existingToken);

        vm.startBroadcast(deployerKey);
        (address token, address timelock, address governor) = _deployAndRenounce(params);
        vm.stopBroadcast();

        console2.log("TangleToken:", token);
        console2.log("TangleTimelock:", timelock);
        console2.log("TangleGovernor:", governor);
        console2.log("Set roles.timelock + incentives.tntToken in the FullDeploy config to the above.");

        string memory manifest = "governance";
        manifest.serialize("token", token);
        manifest.serialize("timelock", timelock);
        manifest = manifest.serialize("governor", governor);
        string memory outPath = vm.envOr("GOVERNANCE_MANIFEST", string("deployments/governance.json"));
        manifest.write(outPath);
        console2.log("Manifest:", outPath);
    }

    /// @notice Deploy governance via the audited helper and renounce the bootstrap admin.
    /// @dev Broadcast-free so it is directly testable. Fails closed if the renounce did not take.
    function _deployAndRenounce(GovernanceDeployer.DeployParams memory params)
        internal
        returns (address token, address timelock, address governor)
    {
        GovernanceDeployer gd = new GovernanceDeployer();
        GovernanceDeployer.DeployedContracts memory c = gd.deployGovernance(params);
        // Renounce the bootstrap admin so only governance controls the timelock.
        gd.renounceTimelockAdmin(c.timelock);

        timelock = address(c.timelock);
        governor = address(c.governor);
        token = address(c.token);

        TangleTimelock tl = TangleTimelock(payable(timelock));
        require(!tl.hasRole(tl.DEFAULT_ADMIN_ROLE(), address(gd)), "timelock admin renounce failed");
        require(tl.hasRole(tl.PROPOSER_ROLE(), governor), "governor missing PROPOSER_ROLE");
        require(tl.hasRole(tl.CANCELLER_ROLE(), governor), "governor missing CANCELLER_ROLE");
    }

    function _loadParams(
        address deployer,
        address existingToken,
        uint256 initialSupply
    )
        internal
        view
        returns (GovernanceDeployer.DeployParams memory params)
    {
        string memory path = vm.envOr("FULL_DEPLOY_CONFIG", string(""));
        require(bytes(path).length != 0, "FULL_DEPLOY_CONFIG not set");
        string memory json = vm.readFile(path);
        require(json.keyExists(".governance.timelockDelay"), "config: missing governance block");

        // When reusing a token, GovernanceDeployer requires initialTokenSupply == 0.
        params = GovernanceDeployer.DeployParams({
            tokenAdmin: deployer,
            initialTokenSupply: existingToken == address(0) ? initialSupply : 0,
            existingToken: existingToken,
            timelockDelay: json.readUint(".governance.timelockDelay"),
            votingDelay: uint48(json.readUint(".governance.votingDelay")),
            votingPeriod: uint32(json.readUint(".governance.votingPeriod")),
            proposalThreshold: _readUintFlexible(json, ".governance.proposalThreshold"),
            quorumPercent: json.readUint(".governance.quorumPercent")
        });
    }

    /// @notice Conservative floors so testnet values (20m/3h/1k/1%) cannot leak onto a prod chain.
    function _requireProductionParams(
        address existingToken,
        GovernanceDeployer.DeployParams memory p
    )
        internal
        view
    {
        if (!_isProductionChain()) return;
        require(p.votingPeriod >= 1 days, "prod: votingPeriod must be >= 1 day (testnet leak guard)");
        require(p.quorumPercent >= 1 && p.quorumPercent <= 100, "prod: quorumPercent out of [1,100]");
        require(p.proposalThreshold > 0, "prod: proposalThreshold must be > 0");
        if (existingToken == address(0)) {
            require(p.initialTokenSupply > 0, "prod: set TOKEN or INITIAL_SUPPLY");
        }
        // timelockDelay is bounded by TangleTimelock.initialize ([MIN_DELAY, MAX_DELAY]).
    }

    function _isProductionChain() internal view returns (bool) {
        if (vm.envOr("TANGLE_DEPLOY_LOCAL", uint256(0)) != 0) return false;
        uint256 id = block.chainid;
        // Ethereum, Base, Tangle, Arbitrum, Optimism mainnets.
        return id == 1 || id == 8453 || id == 5845 || id == 42_161 || id == 10;
    }

    function _readUintFlexible(string memory json, string memory key) internal view returns (uint256) {
        try vm.parseJsonUint(json, key) returns (uint256 value) {
            return value;
        } catch {
            return vm.parseUint(json.readString(key));
        }
    }

    function _requireUint(string memory key) internal returns (uint256) {
        try vm.envUint(key) returns (uint256 raw) {
            return raw;
        } catch {
            revert(string.concat("Missing env ", key));
        }
    }

    function _envAddress(string memory key, address defaultValue) internal returns (address) {
        try vm.envAddress(key) returns (address raw) {
            return raw;
        } catch {
            return defaultValue;
        }
    }
}
