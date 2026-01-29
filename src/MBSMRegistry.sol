// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { AccessControlUpgradeable } from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import { Errors } from "./libraries/Errors.sol";

/// @title MBSMRegistry
/// @notice Registry for Master Blueprint Service Manager versions
/// @dev Allows protocol-wide MBSM versioning and blueprint pinning to specific versions
/// This enables:
/// 1. Upgrading MBSM implementations across all blueprints using "Latest"
/// 2. Blueprints pinning to specific versions for stability
/// 3. Governance-controlled version management
contract MBSMRegistry is Initializable, AccessControlUpgradeable, UUPSUpgradeable {
    // ═══════════════════════════════════════════════════════════════════════════
    // CONSTANTS
    // ═══════════════════════════════════════════════════════════════════════════

    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");

    /// @notice Maximum number of MBSM versions that can be registered
    uint256 public constant MAX_VERSIONS = 100;

    // ═══════════════════════════════════════════════════════════════════════════
    // STORAGE
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Array of all MBSM version addresses (index = revision number)
    address[] private _versions;

    /// @notice Mapping from MBSM address to its revision number (1-indexed, 0 = not registered)
    mapping(address => uint32) private _addressToRevision;

    /// @notice Mapping from blueprint ID to pinned revision (0 = use latest)
    mapping(uint64 => uint32) private _blueprintPinnedRevision;

    /// @notice M-8 FIX: Grace period before deprecated versions become unusable
    /// @dev Maps revision => timestamp when deprecation was initiated
    mapping(uint32 => uint256) private _deprecationTimestamp;

    /// @notice M-8 FIX: Grace period duration (default 7 days)
    uint256 public deprecationGracePeriod;

    /// @notice Storage gap for upgrades
    /// @dev Standard gap size is 50 slots. When adding new storage, decrease this gap accordingly.
    uint256[48] private __gap;

    // ═══════════════════════════════════════════════════════════════════════════
    // EVENTS
    // ═══════════════════════════════════════════════════════════════════════════

    event MBSMVersionAdded(uint32 indexed revision, address indexed mbsmAddress);
    event MBSMVersionDeprecated(uint32 indexed revision, address indexed mbsmAddress);
    event BlueprintPinned(uint64 indexed blueprintId, uint32 indexed revision);
    event BlueprintUnpinned(uint64 indexed blueprintId);

    // ═══════════════════════════════════════════════════════════════════════════
    // ERRORS
    // ═══════════════════════════════════════════════════════════════════════════

    error MaxVersionsExceeded();
    error VersionAlreadyRegistered(address mbsmAddress);
    error InvalidRevision(uint32 revision);
    error NoVersionsRegistered();
    /// @notice M-8 FIX: Version is in grace period but not fully deprecated yet
    error VersionInGracePeriod(uint32 revision, uint256 gracePeriodEnds);
    /// @notice M-8 FIX: Cannot deprecate version with active services still using it
    error VersionHasActiveServices(uint32 revision);
    /// @notice M-8 FIX: Invalid grace period value
    error InvalidGracePeriod();

    // ═══════════════════════════════════════════════════════════════════════════
    // INITIALIZATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /// @notice Initialize the registry
    /// @param admin Admin address with full control
    function initialize(address admin) external initializer {
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(UPGRADER_ROLE, admin);
        _grantRole(MANAGER_ROLE, admin);

        // M-8 FIX: Set default grace period of 7 days
        deprecationGracePeriod = 7 days;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // VERSION MANAGEMENT (MANAGER_ROLE)
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Add a new MBSM version
    /// @param mbsmAddress The MBSM contract address
    /// @return revision The revision number assigned to this version
    function addVersion(address mbsmAddress) external onlyRole(MANAGER_ROLE) returns (uint32 revision) {
        if (mbsmAddress == address(0)) revert Errors.ZeroAddress();
        if (_versions.length >= MAX_VERSIONS) revert MaxVersionsExceeded();
        if (_addressToRevision[mbsmAddress] != 0) revert VersionAlreadyRegistered(mbsmAddress);

        _versions.push(mbsmAddress);
        revision = uint32(_versions.length); // 1-indexed
        _addressToRevision[mbsmAddress] = revision;

        emit MBSMVersionAdded(revision, mbsmAddress);
    }

    /// @notice M-8 FIX: Initiate deprecation of an MBSM version (starts grace period)
    /// @dev During grace period, version still works but emits deprecation warning
    /// After grace period, version becomes unusable
    /// @param revision The revision to deprecate
    function initiateDeprecation(uint32 revision) external onlyRole(MANAGER_ROLE) {
        if (revision == 0 || revision > _versions.length) revert InvalidRevision(revision);
        if (_versions[revision - 1] == address(0)) revert InvalidRevision(revision); // Already deprecated
        if (_deprecationTimestamp[revision] != 0) revert VersionInGracePeriod(revision, _deprecationTimestamp[revision] + deprecationGracePeriod);

        _deprecationTimestamp[revision] = block.timestamp;
        emit MBSMVersionDeprecated(revision, _versions[revision - 1]);
    }

    /// @notice M-8 FIX: Complete deprecation after grace period (sets to zero address)
    /// @dev Blueprints pinned to this version should re-pin before calling this
    /// @param revision The revision to fully deprecate
    function completeDeprecation(uint32 revision) external onlyRole(MANAGER_ROLE) {
        if (revision == 0 || revision > _versions.length) revert InvalidRevision(revision);
        if (_versions[revision - 1] == address(0)) revert InvalidRevision(revision); // Already fully deprecated

        uint256 deprecatedAt = _deprecationTimestamp[revision];
        if (deprecatedAt == 0) revert InvalidRevision(revision); // Not initiated
        if (block.timestamp < deprecatedAt + deprecationGracePeriod) {
            revert VersionInGracePeriod(revision, deprecatedAt + deprecationGracePeriod);
        }

        address mbsmAddress = _versions[revision - 1];
        _versions[revision - 1] = address(0);
        delete _addressToRevision[mbsmAddress];
        delete _deprecationTimestamp[revision];
    }

    /// @notice Deprecate an MBSM version immediately (for emergencies, sets to zero address)
    /// @dev Blueprints pinned to this version will get address(0) - they should re-pin
    /// @param revision The revision to deprecate
    function deprecateVersion(uint32 revision) external onlyRole(MANAGER_ROLE) {
        if (revision == 0 || revision > _versions.length) revert InvalidRevision(revision);

        address mbsmAddress = _versions[revision - 1];
        _versions[revision - 1] = address(0);
        delete _addressToRevision[mbsmAddress];
        delete _deprecationTimestamp[revision];

        emit MBSMVersionDeprecated(revision, mbsmAddress);
    }

    /// @notice M-8 FIX: Set the grace period for deprecations
    /// @param newGracePeriod New grace period in seconds (minimum 1 day)
    function setDeprecationGracePeriod(uint256 newGracePeriod) external onlyRole(MANAGER_ROLE) {
        if (newGracePeriod < 1 days) revert InvalidGracePeriod();
        deprecationGracePeriod = newGracePeriod;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // BLUEPRINT PINNING
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Pin a blueprint to a specific MBSM revision
    /// @dev Only callable by blueprint owner (verified in Tangle contract)
    /// This contract just stores the mapping; access control is external
    /// @param blueprintId The blueprint ID
    /// @param revision The revision to pin to (must be valid)
    function pinBlueprint(uint64 blueprintId, uint32 revision) external onlyRole(MANAGER_ROLE) {
        if (revision == 0 || revision > _versions.length) revert InvalidRevision(revision);
        if (_versions[revision - 1] == address(0)) revert InvalidRevision(revision); // Deprecated

        _blueprintPinnedRevision[blueprintId] = revision;
        emit BlueprintPinned(blueprintId, revision);
    }

    /// @notice Unpin a blueprint to use latest MBSM
    /// @param blueprintId The blueprint ID
    function unpinBlueprint(uint64 blueprintId) external onlyRole(MANAGER_ROLE) {
        delete _blueprintPinnedRevision[blueprintId];
        emit BlueprintUnpinned(blueprintId);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // QUERIES
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Get the MBSM address for a blueprint
    /// @dev Returns pinned version if set, otherwise latest
    /// @param blueprintId The blueprint ID
    /// @return mbsmAddress The MBSM contract address (or address(0) if none)
    // forge-lint: disable-next-line(mixed-case-function)
    function getMBSM(uint64 blueprintId) external view returns (address mbsmAddress) {
        uint32 pinnedRevision = _blueprintPinnedRevision[blueprintId];

        if (pinnedRevision != 0) {
            // Blueprint is pinned to specific revision
            return _versions[pinnedRevision - 1];
        } else {
            // Use latest
            return getLatestMBSM();
        }
    }

    /// @notice Get the latest MBSM address
    /// @return The latest MBSM contract address (or address(0) if none)
    // forge-lint: disable-next-line(mixed-case-function)
    function getLatestMBSM() public view returns (address) {
        if (_versions.length == 0) return address(0);
        return _versions[_versions.length - 1];
    }

    /// @notice Get MBSM address by revision number
    /// @param revision The revision number (1-indexed)
    /// @return The MBSM contract address
    // forge-lint: disable-next-line(mixed-case-function)
    function getMBSMByRevision(uint32 revision) external view returns (address) {
        if (revision == 0 || revision > _versions.length) revert InvalidRevision(revision);
        return _versions[revision - 1];
    }

    /// @notice Get the revision number for an MBSM address
    /// @param mbsmAddress The MBSM contract address
    /// @return revision The revision number (0 if not registered)
    function getRevision(address mbsmAddress) external view returns (uint32 revision) {
        return _addressToRevision[mbsmAddress];
    }

    /// @notice Get the pinned revision for a blueprint
    /// @param blueprintId The blueprint ID
    /// @return revision The pinned revision (0 = using latest)
    function getPinnedRevision(uint64 blueprintId) external view returns (uint32 revision) {
        return _blueprintPinnedRevision[blueprintId];
    }

    /// @notice Get the latest revision number
    /// @return The latest revision number (0 if none registered)
    function getLatestRevision() external view returns (uint32) {
        return uint32(_versions.length);
    }

    /// @notice Get total number of registered versions
    /// @return count The number of versions (including deprecated)
    function versionCount() external view returns (uint256 count) {
        return _versions.length;
    }

    /// @notice Check if a revision is valid and not deprecated
    /// @param revision The revision to check
    /// @return valid True if the revision is valid and active
    function isValidRevision(uint32 revision) external view returns (bool valid) {
        if (revision == 0 || revision > _versions.length) return false;
        return _versions[revision - 1] != address(0);
    }

    /// @notice M-8 FIX: Check if a revision is in the deprecation grace period
    /// @param revision The revision to check
    /// @return inGracePeriod True if revision is deprecated but still in grace period
    /// @return gracePeriodEnds Timestamp when grace period ends (0 if not in grace period)
    function isInGracePeriod(uint32 revision) external view returns (bool inGracePeriod, uint256 gracePeriodEnds) {
        if (revision == 0 || revision > _versions.length) return (false, 0);
        uint256 deprecatedAt = _deprecationTimestamp[revision];
        if (deprecatedAt == 0) return (false, 0);

        gracePeriodEnds = deprecatedAt + deprecationGracePeriod;
        inGracePeriod = block.timestamp < gracePeriodEnds && _versions[revision - 1] != address(0);
    }

    /// @notice M-8 FIX: Get deprecation timestamp for a revision
    /// @param revision The revision to check
    /// @return timestamp When deprecation was initiated (0 if not deprecated)
    function getDeprecationTimestamp(uint32 revision) external view returns (uint256 timestamp) {
        return _deprecationTimestamp[revision];
    }

    /// @notice Get all registered MBSM addresses
    /// @return addresses Array of all MBSM addresses (may include address(0) for deprecated)
    /// @dev M-13 FIX: For large registries, prefer using getVersionsPaginated to avoid gas issues
    function getAllVersions() external view returns (address[] memory addresses) {
        return _versions;
    }

    /// @notice M-13 FIX: Get registered MBSM addresses with pagination
    /// @param offset Starting index (0-based)
    /// @param limit Maximum number of versions to return
    /// @return addresses Array of MBSM addresses in the requested range
    /// @return total Total number of registered versions
    function getVersionsPaginated(
        uint256 offset,
        uint256 limit
    ) external view returns (address[] memory addresses, uint256 total) {
        total = _versions.length;

        if (offset >= total) {
            return (new address[](0), total);
        }

        uint256 remaining = total - offset;
        uint256 count = limit < remaining ? limit : remaining;

        addresses = new address[](count);
        for (uint256 i = 0; i < count; i++) {
            addresses[i] = _versions[offset + i];
        }
    }

    /// @notice M-13 FIX: Get only active (non-deprecated) versions with pagination
    /// @param offset Starting index in the active versions (0-based)
    /// @param limit Maximum number of versions to return
    /// @return addresses Array of active MBSM addresses
    /// @return revisions Array of revision numbers for each returned address
    /// @return totalActive Total number of active versions
    function getActiveVersionsPaginated(
        uint256 offset,
        uint256 limit
    ) external view returns (
        address[] memory addresses,
        uint32[] memory revisions,
        uint256 totalActive
    ) {
        // First pass: count active versions
        for (uint256 i = 0; i < _versions.length; i++) {
            if (_versions[i] != address(0)) {
                totalActive++;
            }
        }

        if (offset >= totalActive) {
            return (new address[](0), new uint32[](0), totalActive);
        }

        uint256 remaining = totalActive - offset;
        uint256 count = limit < remaining ? limit : remaining;

        addresses = new address[](count);
        revisions = new uint32[](count);

        // Second pass: collect active versions with pagination
        uint256 activeIndex = 0;
        uint256 resultIndex = 0;

        for (uint256 i = 0; i < _versions.length && resultIndex < count; i++) {
            if (_versions[i] != address(0)) {
                if (activeIndex >= offset) {
                    addresses[resultIndex] = _versions[i];
                    revisions[resultIndex] = uint32(i + 1); // 1-indexed revision
                    resultIndex++;
                }
                activeIndex++;
            }
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // UPGRADE
    // ═══════════════════════════════════════════════════════════════════════════

    function _authorizeUpgrade(address newImplementation) internal override onlyRole(UPGRADER_ROLE) {}
}
