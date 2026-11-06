// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test } from "forge-std/Test.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { BlueprintServiceManagerBase } from "../../src/BlueprintServiceManagerBase.sol";
import { ReviewLegacyBlueprintServiceManagerBase } from "./ReviewLegacyBlueprintServiceManagerBase.sol";
import { Tangle } from "../../src/Tangle.sol";
import { ITangleFull } from "../../src/interfaces/ITangle.sol";
import { TangleBlueprintsFacet } from "../../src/facets/tangle/TangleBlueprintsFacet.sol";
import { TangleBlueprintsManagementFacet } from "../../src/facets/tangle/TangleBlueprintsManagementFacet.sol";
import { MBSMRegistry } from "../../src/MBSMRegistry.sol";
import { MasterBlueprintServiceManager } from "../../src/MasterBlueprintServiceManager.sol";
import { Types } from "../../src/libraries/Types.sol";
import { BlueprintDefinitionHelper } from "../support/BlueprintDefinitionHelper.sol";

contract ReviewManagerFactory {
    address public immutable owner = msg.sender;

    function deploy() external returns (BlueprintServiceManagerBase) {
        return new BlueprintServiceManagerBase();
    }

    function prepare(BlueprintServiceManagerBase manager, address core, address creator) external {
        require(msg.sender == owner, "factory owner");
        manager.initializeBlueprintManager(core, creator);
    }
}

contract ReviewLegacyUpgradeableManager is ReviewLegacyBlueprintServiceManagerBase, Initializable, UUPSUpgradeable {
    address public paymentToken;

    constructor() {
        _disableInitializers();
    }

    function initialize(address token) external initializer {
        paymentToken = token;
    }

    function allowAsset(uint64 id, address asset) external onlyBlueprintOwner {
        _permitAsset(id, asset);
    }

    function allowedAssets(uint64 id) external view returns (address[] memory) {
        return _getPermittedAssets(id);
    }
    function _authorizeUpgrade(address) internal override onlyBlueprintOwner { }
}

contract ReviewCurrentUpgradeableManager is BlueprintServiceManagerBase, Initializable, UUPSUpgradeable {
    address public paymentToken;

    constructor() {
        _disableInitializers();
    }

    function initialize(address token) external initializer {
        paymentToken = token;
    }

    function allowAsset(uint64 id, address asset) external onlyBlueprintOwner {
        _permitAsset(id, asset);
    }

    function allowedAssets(uint64 id) external view returns (address[] memory) {
        return _getPermittedAssets(id);
    }
    function _authorizeUpgrade(address) internal override onlyBlueprintOwner { }
}

contract ReviewPolicyManager is BlueprintServiceManagerBase {
    bool public reject = true;

    constructor(address core, address creator) {
        _initializeBlueprintManager(core, creator);
    }

    function accept() external onlyBlueprintOwner {
        reject = false;
    }

    function onBlueprintCreated(uint64 id, address creator, address core) external override {
        _onBlueprintCreated(id, creator, core);
        require(!reject, "consumer policy");
    }
}

contract ReviewBindingAdversarialTest is Test, BlueprintDefinitionHelper {
    function registry() internal returns (ITangleFull core) {
        Tangle implementation = new Tangle();
        Tangle router = Tangle(
            payable(address(
                    new ERC1967Proxy(
                        address(implementation),
                        abi.encodeCall(Tangle.initialize, (address(this), address(this), payable(address(this))))
                    )
                ))
        );
        router.registerFacet(address(new TangleBlueprintsFacet()));
        router.registerFacet(address(new TangleBlueprintsManagementFacet()));
        MBSMRegistry versions = MBSMRegistry(
            address(
                new ERC1967Proxy(address(new MBSMRegistry()), abi.encodeCall(MBSMRegistry.initialize, (address(this))))
            )
        );
        versions.addVersion(address(new MasterBlueprintServiceManager(address(this), address(router))));
        versions.grantRole(versions.MANAGER_ROLE(), address(router));
        router.setMBSMRegistry(address(versions));
        return ITangleFull(payable(address(router)));
    }

    function testFactoryAuthorityCannotBeConfusedWithTransactionSenderOrCreator() public {
        ITangleFull core = registry();
        ReviewManagerFactory factory = new ReviewManagerFactory();
        BlueprintServiceManagerBase manager = factory.deploy();
        address creator = makeAddr("different creator");
        address attacker = makeAddr("unrelated caller");
        vm.expectRevert();
        manager.initializeBlueprintManager(address(core), creator);
        vm.prank(creator);
        vm.expectRevert();
        manager.initializeBlueprintManager(address(core), creator);
        vm.prank(attacker);
        vm.expectRevert();
        factory.prepare(manager, address(core), attacker);
        factory.prepare(manager, address(core), creator);
        Types.BlueprintDefinition memory definition = _blueprintDefinition("review:factory", address(manager));
        vm.prank(attacker);
        vm.expectRevert();
        core.createBlueprint(definition);
        assertEq(core.blueprintCount(), 0);
        assertEq(manager.blueprintId(), type(uint64).max);
        vm.prank(creator);
        assertEq(core.createBlueprint(definition), 0);
        assertEq(manager.blueprintOwner(), creator);
        assertEq(manager.queryDeveloperPaymentAddress(0), creator);
        assertEq(manager.tangleCore(), address(core));
        vm.expectRevert();
        factory.prepare(manager, address(core), attacker);
        vm.prank(creator);
        vm.expectRevert();
        core.createBlueprint(definition);
        assertEq(core.blueprintCount(), 1);
    }

    function testActualLegacyRegisteredProxyKeepsPackedAndDerivedStorageAndAssets() public {
        ITangleFull core = registry();
        address token = makeAddr("persisted token");
        ReviewLegacyUpgradeableManager legacyImplementation = new ReviewLegacyUpgradeableManager();
        ReviewLegacyUpgradeableManager legacy = ReviewLegacyUpgradeableManager(
            payable(address(
                    new ERC1967Proxy(
                        address(legacyImplementation),
                        abi.encodeCall(ReviewLegacyUpgradeableManager.initialize, (token))
                    )
                ))
        );
        assertEq(core.createBlueprint(_blueprintDefinition("review:legacy", address(legacy))), 0);
        address assetA = makeAddr("asset A");
        address assetB = makeAddr("asset B");
        legacy.allowAsset(7, assetA);
        legacy.allowAsset(7, assetB);
        assertFalse(legacy.queryIsPaymentAssetAllowed(7, token));
        ReviewCurrentUpgradeableManager replacement = new ReviewCurrentUpgradeableManager();
        vm.prank(makeAddr("foreign upgrader"));
        vm.expectRevert();
        legacy.upgradeToAndCall(address(replacement), "");
        legacy.upgradeToAndCall(address(replacement), "");
        ReviewCurrentUpgradeableManager current = ReviewCurrentUpgradeableManager(payable(address(legacy)));
        assertEq(current.tangleCore(), address(core));
        assertEq(current.blueprintId(), 0);
        assertEq(current.blueprintOwner(), address(this));
        assertEq(current.queryDeveloperPaymentAddress(0), address(this));
        assertEq(current.paymentToken(), token);
        address[] memory assets = current.allowedAssets(7);
        assertEq(assets.length, 2);
        assertEq(assets[0], assetA);
        assertEq(assets[1], assetB);
        assertTrue(current.queryIsPaymentAssetAllowed(7, assetA));
        assertFalse(current.queryIsPaymentAssetAllowed(7, token));
        vm.expectRevert();
        current.initializeBlueprintManager(makeAddr("foreign core"), makeAddr("foreign owner"));
        vm.expectRevert();
        current.initialize(makeAddr("replacement token"));
        vm.expectRevert();
        core.createBlueprint(_blueprintDefinition("review:replay", address(current)));
        assertEq(core.blueprintCount(), 1);
        current.allowAsset(7, token);
        assertTrue(current.queryIsPaymentAssetAllowed(7, token));
    }

    function testConsumerRevertRollsBackCanonicalCallbackAndRegistryThenCanRegister() public {
        ITangleFull core = registry();
        ReviewPolicyManager manager = new ReviewPolicyManager(address(core), address(this));
        Types.BlueprintDefinition memory definition = _blueprintDefinition("review:policy", address(manager));
        vm.expectRevert();
        core.createBlueprint(definition);
        assertEq(core.blueprintCount(), 0);
        assertEq(manager.blueprintId(), type(uint64).max);
        assertEq(manager.blueprintOwner(), address(this));
        manager.accept();
        assertEq(core.createBlueprint(definition), 0);
        assertEq(manager.blueprintId(), 0);
        vm.expectRevert();
        core.createBlueprint(definition);
        assertEq(core.blueprintCount(), 1);
    }
}
