// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {
    TimelockControllerUpgradeable
} from "@openzeppelin/contracts-upgradeable/governance/TimelockControllerUpgradeable.sol";
import { IVotes } from "@openzeppelin/contracts/governance/utils/IVotes.sol";
import { IAccessControl } from "@openzeppelin/contracts/access/IAccessControl.sol";

import { TangleToken } from "./TangleToken.sol";
import { TangleGovernor } from "./TangleGovernor.sol";
import { TangleTimelock } from "./TangleTimelock.sol";

/// @title GovernanceDeployer
/// @notice Helper contract for deploying and configuring Tangle governance
/// @dev Deploys TNT token, Timelock, and Governor with proper role configuration
///
/// Deployment Flow:
/// 1. Deploy implementations (TangleToken, TangleTimelock, TangleGovernor)
/// 2. Deploy proxies and initialize
/// 3. Configure roles:
///    - Governor gets PROPOSER_ROLE and EXECUTOR_ROLE on Timelock
///    - Timelock gets UPGRADER_ROLE on controlled contracts (Tangle, etc.)
/// 4. Renounce admin roles on Timelock for full decentralization
///
/// Usage:
/// ```solidity
/// GovernanceDeployer deployer = new GovernanceDeployer();
/// (token, timelock, governor) = deployer.deployGovernance(params);
/// deployer.configureProtocolRoles(timelock, tangleContract);
/// deployer.renounceTimelockAdmin(timelock);
/// ```
contract GovernanceDeployer {
    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    event GovernanceDeployed(address indexed token, address indexed timelock, address indexed governor);

    event ProtocolRolesConfigured(address indexed timelock, address indexed protocolContract);

    // ═══════════════════════════════════════════════════════════════════════════
    // STRUCTS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Parameters for governance deployment
    struct DeployParams {
        // Token params
        address tokenAdmin;
        uint256 initialTokenSupply;
        address existingToken; // optional override to skip new TNT deployment
        // Timelock params
        uint256 timelockDelay;
        // Governor params
        uint48 votingDelay;
        uint32 votingPeriod;
        uint256 proposalThreshold;
        uint256 quorumPercent;
    }

    /// @notice Deployed governance addresses
    struct DeployedContracts {
        TangleToken token;
        TangleTimelock timelock;
        TangleGovernor governor;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // DEPLOYMENT
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Deploy complete governance system
    /// @param params Deployment parameters
    /// @return contracts The deployed contract addresses
    function deployGovernance(DeployParams calldata params) external returns (DeployedContracts memory contracts) {
        // Deploy implementations / reuse existing TNT
        TangleTimelock timelockImpl = new TangleTimelock();
        TangleGovernor governorImpl = new TangleGovernor();

        if (params.existingToken != address(0)) {
            require(params.initialTokenSupply == 0, "Initial supply handled externally");
            contracts.token = TangleToken(params.existingToken);
        } else {
            TangleToken tokenImpl = new TangleToken();
            bytes memory tokenData =
                abi.encodeCall(TangleToken.initialize, (params.tokenAdmin, params.initialTokenSupply));
            ERC1967Proxy tokenProxy = new ERC1967Proxy(address(tokenImpl), tokenData);
            contracts.token = TangleToken(address(tokenProxy));
        }

        // Deploy timelock proxy (with empty proposers/executors initially)
        address[] memory emptyAddresses = new address[](0);
        bytes memory timelockData = abi.encodeCall(
            TangleTimelock.initialize, (params.timelockDelay, emptyAddresses, emptyAddresses, address(this))
        );
        ERC1967Proxy timelockProxy = new ERC1967Proxy(address(timelockImpl), timelockData);
        contracts.timelock = TangleTimelock(payable(address(timelockProxy)));

        // Deploy governor proxy
        bytes memory governorData = abi.encodeCall(
            TangleGovernor.initialize,
            (
                IVotes(address(contracts.token)),
                TimelockControllerUpgradeable(payable(address(contracts.timelock))),
                params.votingDelay,
                params.votingPeriod,
                params.proposalThreshold,
                params.quorumPercent
            )
        );
        ERC1967Proxy governorProxy = new ERC1967Proxy(address(governorImpl), governorData);
        contracts.governor = TangleGovernor(payable(address(governorProxy)));

        // Configure timelock roles for governor
        _configureTimelockRoles(contracts.timelock, address(contracts.governor));

        emit GovernanceDeployed(address(contracts.token), address(contracts.timelock), address(contracts.governor));
    }

    /// @notice Configure timelock roles to grant governor proposer/executor/canceller
    function _configureTimelockRoles(TangleTimelock timelock, address governor) internal {
        // Grant governor the proposer role
        timelock.grantRole(timelock.PROPOSER_ROLE(), governor);

        // Grant governor the executor role
        timelock.grantRole(timelock.EXECUTOR_ROLE(), governor);

        // Grant governor the canceller role
        timelock.grantRole(timelock.CANCELLER_ROLE(), governor);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // PROTOCOL CONFIGURATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Configure protocol contract to be governed by timelock
    /// @param timelock The timelock that will control the protocol
    /// @param protocolContract The protocol contract (Tangle, MultiAssetDelegation, etc.)
    /// @param roles The role identifiers to grant to timelock
    /// @dev Caller must have DEFAULT_ADMIN_ROLE on protocolContract
    function configureProtocolRoles(address timelock, address protocolContract, bytes32[] calldata roles) external {
        IAccessControl protocol = IAccessControl(protocolContract);

        for (uint256 i = 0; i < roles.length; i++) {
            protocol.grantRole(roles[i], timelock);
        }

        emit ProtocolRolesConfigured(timelock, protocolContract);
    }

    /// @notice Renounce admin role on timelock for full decentralization
    /// @param timelock The timelock to renounce admin on
    /// @dev After calling this, only governance can modify timelock
    function renounceTimelockAdmin(TangleTimelock timelock) external {
        timelock.renounceRole(timelock.DEFAULT_ADMIN_ROLE(), address(this));
    }

    /// @notice Transfer timelock admin to a new address (e.g., multisig as backup)
    /// @param timelock The timelock
    /// @param newAdmin The new admin address
    function transferTimelockAdmin(TangleTimelock timelock, address newAdmin) external {
        timelock.grantRole(timelock.DEFAULT_ADMIN_ROLE(), newAdmin);
        timelock.renounceRole(timelock.DEFAULT_ADMIN_ROLE(), address(this));
    }

    /// @notice Full governance transfer - grants all roles including DEFAULT_ADMIN_ROLE
    /// @dev This gives governance full control including the ability to grant/revoke roles
    /// @param timelock The timelock that will control the protocol
    /// @param protocolContract The protocol contract to transfer
    /// @param roles All roles to grant (should include DEFAULT_ADMIN_ROLE as first element)
    /// @param originalAdmin The original admin to revoke roles from (set to address(0) to skip)
    function transferFullControl(
        address timelock,
        address protocolContract,
        bytes32[] calldata roles,
        address originalAdmin
    )
        external
    {
        IAccessControl protocol = IAccessControl(protocolContract);

        // Grant all roles to timelock
        for (uint256 i = 0; i < roles.length; i++) {
            protocol.grantRole(roles[i], timelock);
        }

        // Optionally revoke from original admin for full decentralization
        if (originalAdmin != address(0)) {
            for (uint256 i = 0; i < roles.length; i++) {
                // Only revoke if caller has permission (must be original admin or have admin role)
                try protocol.revokeRole(roles[i], originalAdmin) { } catch { }
            }
        }

        emit ProtocolRolesConfigured(timelock, protocolContract);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // VIEW HELPERS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Get all roles for Tangle.sol
    /// @dev Includes DEFAULT_ADMIN_ROLE for full role management capability
    function getTangleRoles() external pure returns (bytes32[] memory roles) {
        roles = new bytes32[](5);
        roles[0] = bytes32(0); // DEFAULT_ADMIN_ROLE - allows granting/revoking all other roles
        roles[1] = keccak256("ADMIN_ROLE");
        roles[2] = keccak256("PAUSER_ROLE");
        roles[3] = keccak256("UPGRADER_ROLE");
        roles[4] = keccak256("SLASH_ADMIN_ROLE");
    }

    /// @notice Get all roles for MultiAssetDelegation.sol
    /// @dev Includes DEFAULT_ADMIN_ROLE for full role management capability
    function getMultiAssetDelegationRoles() external pure returns (bytes32[] memory roles) {
        roles = new bytes32[](4);
        roles[0] = bytes32(0); // DEFAULT_ADMIN_ROLE - allows granting/revoking all other roles
        roles[1] = keccak256("ADMIN_ROLE");
        roles[2] = keccak256("ASSET_MANAGER_ROLE");
        roles[3] = keccak256("SLASHER_ROLE");
    }

    /// @notice Get all roles for TangleToken.sol
    /// @dev Includes DEFAULT_ADMIN_ROLE for full role management capability
    function getTokenRoles() external pure returns (bytes32[] memory roles) {
        roles = new bytes32[](3);
        roles[0] = bytes32(0); // DEFAULT_ADMIN_ROLE - allows granting/revoking all other roles
        roles[1] = keccak256("MINTER_ROLE");
        roles[2] = keccak256("UPGRADER_ROLE");
    }

    /// @notice Get only operational roles (excludes DEFAULT_ADMIN_ROLE)
    /// @dev Use when you want governance to have operational control but retain admin elsewhere
    function getTangleOperationalRoles() external pure returns (bytes32[] memory roles) {
        roles = new bytes32[](4);
        roles[0] = keccak256("ADMIN_ROLE");
        roles[1] = keccak256("PAUSER_ROLE");
        roles[2] = keccak256("UPGRADER_ROLE");
        roles[3] = keccak256("SLASH_ADMIN_ROLE");
    }

    /// @notice Get only operational roles for MultiAssetDelegation (excludes DEFAULT_ADMIN_ROLE)
    function getMultiAssetDelegationOperationalRoles() external pure returns (bytes32[] memory roles) {
        roles = new bytes32[](3);
        roles[0] = keccak256("ADMIN_ROLE");
        roles[1] = keccak256("ASSET_MANAGER_ROLE");
        roles[2] = keccak256("SLASHER_ROLE");
    }

    /// @notice Get only operational roles for TangleToken (excludes DEFAULT_ADMIN_ROLE)
    function getTokenOperationalRoles() external pure returns (bytes32[] memory roles) {
        roles = new bytes32[](2);
        roles[0] = keccak256("MINTER_ROLE");
        roles[1] = keccak256("UPGRADER_ROLE");
    }

    /// @notice Get default governance parameters for mainnet
    function getDefaultMainnetParams(address admin) external pure returns (DeployParams memory) {
        return DeployParams({
            tokenAdmin: admin,
            initialTokenSupply: 50_000_000 * 1e18, // 50M initial supply
            existingToken: address(0),
            timelockDelay: 2 days,
            votingDelay: 7200, // ~1 day (assuming 12s blocks)
            votingPeriod: 50_400, // ~1 week
            proposalThreshold: 100_000 * 1e18, // 100k TNT to propose
            quorumPercent: 4 // 4% quorum
        });
    }

    /// @notice Get governance parameters for testnet (faster)
    function getDefaultTestnetParams(address admin) external pure returns (DeployParams memory) {
        return DeployParams({
            tokenAdmin: admin,
            initialTokenSupply: 50_000_000 * 1e18,
            existingToken: address(0),
            timelockDelay: 1 days, // Shorter for testing
            votingDelay: 100, // ~20 minutes
            votingPeriod: 1000, // ~3 hours
            proposalThreshold: 1000 * 1e18, // 1k TNT to propose
            quorumPercent: 1 // 1% quorum for easier testing
        });
    }
}
