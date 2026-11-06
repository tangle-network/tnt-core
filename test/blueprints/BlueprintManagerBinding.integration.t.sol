// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test } from "forge-std/Test.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { Initializable } from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import { UUPSUpgradeable } from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import { Tangle } from "../../src/Tangle.sol";
import { ITangleFull } from "../../src/interfaces/ITangle.sol";
import { TangleBlueprintsFacet } from "../../src/facets/tangle/TangleBlueprintsFacet.sol";
import { TangleBlueprintsManagementFacet } from "../../src/facets/tangle/TangleBlueprintsManagementFacet.sol";
import { MBSMRegistry } from "../../src/MBSMRegistry.sol";
import { MasterBlueprintServiceManager } from "../../src/MasterBlueprintServiceManager.sol";
import { Types } from "../../src/libraries/Types.sol";
import { TokenizedBlueprintBase } from "../../src/extensions/TokenizedBlueprintBase.sol";
import { BlueprintDefinitionHelper } from "../support/BlueprintDefinitionHelper.sol";
import { BlueprintServiceManagerBase } from "../../src/BlueprintServiceManagerBase.sol";

contract TokenizedBindingManager is TokenizedBlueprintBase {
    constructor() TokenizedBlueprintBase("Binding token", "BIND") { }
}

contract ConstructorBlueprintManager is BlueprintServiceManagerBase {
    constructor(address core, address owner) {
        _initializeBlueprintManager(core, owner);
    }
}

contract UpgradeableBlueprintManager is BlueprintServiceManagerBase, Initializable, UUPSUpgradeable {
    address public paymentToken;

    constructor() {
        _disableInitializers();
    }

    function initialize(address core, address owner, address token) external initializer {
        _initializeBlueprintManager(core, owner);
        paymentToken = token;
    }

    function _authorizeUpgrade(address) internal override onlyBlueprintOwner { }
}

contract BlueprintManagerBindingIntegrationTest is Test, BlueprintDefinitionHelper {
    function _registry() internal returns (ITangleFull registry) {
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
        registry = ITangleFull(payable(address(router)));
    }

    function _assertBound(BlueprintServiceManagerBase manager, ITangleFull registry, uint64 id) internal view {
        assertEq(manager.tangleCore(), address(registry));
        assertEq(manager.blueprintOwner(), address(this));
        assertEq(manager.blueprintId(), id);
        assertEq(manager.queryDeveloperPaymentAddress(id), address(this));
    }

    function _registerOnce(BlueprintServiceManagerBase manager, ITangleFull registry) internal {
        uint64 pending = type(uint64).max;
        Types.BlueprintDefinition memory definition = _blueprintDefinition("tangle:canonical-binding", address(manager));
        _assertBound(manager, registry, pending);
        vm.prank(makeAddr("foreign creator"));
        vm.expectRevert();
        registry.createBlueprint(definition);
        _assertBound(manager, registry, pending);
        assertEq(registry.blueprintCount(), 0);
        ITangleFull other = _registry();
        vm.expectRevert();
        other.createBlueprint(definition);
        _assertBound(manager, registry, pending);
        assertEq(other.blueprintCount(), 0);
        assertEq(registry.createBlueprint(definition), 0);
        _assertBound(manager, registry, 0);
        vm.expectRevert();
        registry.createBlueprint(definition);
        _assertBound(manager, registry, 0);
        assertEq(registry.blueprintCount(), 1);
    }

    function testUntrustedFirstCallerCannotReplaceRegistryAndPaymentOwner() public {
        BlueprintServiceManagerBase manager = new BlueprintServiceManagerBase();
        address attacker = makeAddr("attacker");
        vm.prank(attacker);
        (bool accepted,) = address(manager).call(abi.encodeCall(manager.onBlueprintCreated, (42, attacker, attacker)));
        assertFalse(accepted, "untrusted caller claimed the registry and developer payment address");
        assertEq(manager.tangleCore(), address(0));
        assertEq(manager.queryDeveloperPaymentAddress(42), address(0));
    }

    function testZeroCoreCannotBypassOneShotBinding() public {
        BlueprintServiceManagerBase manager = new BlueprintServiceManagerBase();
        address attacker = makeAddr("attacker");
        vm.prank(attacker);
        (bool accepted,) = address(manager).call(abi.encodeCall(manager.onBlueprintCreated, (42, attacker, address(0))));
        assertFalse(accepted, "zero core accepted an unauthenticated owner");
    }

    function testOnlyDirectDeployerCanPrepareNonzeroOneShotBinding() public {
        BlueprintServiceManagerBase manager = new BlueprintServiceManagerBase();
        ITangleFull registry = _registry();
        vm.prank(makeAddr("foreign initializer"));
        vm.expectRevert();
        manager.initializeBlueprintManager(address(registry), address(this));
        vm.expectRevert(BlueprintServiceManagerBase.InvalidBlueprintBinding.selector);
        manager.initializeBlueprintManager(address(0), address(this));
        vm.expectRevert(BlueprintServiceManagerBase.InvalidBlueprintBinding.selector);
        manager.initializeBlueprintManager(address(registry), address(0));
        manager.initializeBlueprintManager(address(registry), address(this));
        vm.expectRevert();
        manager.initializeBlueprintManager(address(registry), address(this));
        _registerOnce(manager, registry);
    }

    function testTrustedRegistryArgumentsCannotReplaceCreatorOrCoreOrUsePendingId() public {
        ITangleFull registry = _registry();
        BlueprintServiceManagerBase manager = new BlueprintServiceManagerBase();
        manager.initializeBlueprintManager(address(registry), address(this));
        vm.startPrank(address(registry));
        vm.expectRevert();
        manager.onBlueprintCreated(0, address(this), address(0));
        vm.expectRevert();
        manager.onBlueprintCreated(0, makeAddr("wrong creator"), address(registry));
        vm.expectRevert(BlueprintServiceManagerBase.InvalidBlueprintBinding.selector);
        manager.onBlueprintCreated(type(uint64).max, address(this), address(registry));
        vm.stopPrank();
        _registerOnce(manager, registry);
    }

    function testUnpreparedProxyHasNoExternalBootstrapAuthority() public {
        BlueprintServiceManagerBase implementation = new BlueprintServiceManagerBase();
        BlueprintServiceManagerBase manager =
            BlueprintServiceManagerBase(address(new ERC1967Proxy(address(implementation), "")));
        ITangleFull registry = _registry();
        vm.expectRevert();
        manager.initializeBlueprintManager(address(registry), address(this));
        vm.expectRevert();
        registry.createBlueprint(_blueprintDefinition("tangle:unprepared-proxy", address(manager)));
        assertEq(manager.tangleCore(), address(0));
        assertEq(manager.blueprintOwner(), address(0));
        assertEq(registry.blueprintCount(), 0);
    }

    function testAtomicConstructorBindingUsesTheCanonicalRegistrationHook() public {
        ITangleFull registry = _registry();
        ConstructorBlueprintManager manager = new ConstructorBlueprintManager(address(registry), address(this));
        vm.expectRevert();
        manager.initializeBlueprintManager(address(registry), makeAddr("other owner"));
        _registerOnce(manager, registry);
    }

    function testAtomicProxyBindingAndExistingStorageSurviveAuthorizedUpgrade() public {
        ITangleFull registry = _registry();
        address token = makeAddr("payment token");
        UpgradeableBlueprintManager implementation = new UpgradeableBlueprintManager();
        bytes memory initialization =
            abi.encodeCall(UpgradeableBlueprintManager.initialize, (address(registry), address(this), token));
        (bool initialized,) = address(implementation).call(initialization);
        assertFalse(initialized, "implementation initializer is unlocked");
        UpgradeableBlueprintManager manager =
            UpgradeableBlueprintManager(payable(address(new ERC1967Proxy(address(implementation), initialization))));
        _registerOnce(manager, registry);
        UpgradeableBlueprintManager replacement = new UpgradeableBlueprintManager();
        vm.prank(makeAddr("foreign upgrader"));
        vm.expectRevert();
        manager.upgradeToAndCall(address(replacement), "");
        manager.upgradeToAndCall(address(replacement), "");
        _assertBound(manager, registry, 0);
        assertEq(manager.paymentToken(), token, "derived storage moved");
        (initialized,) = address(manager).call(initialization);
        assertFalse(initialized, "proxy reinitialized");
        (initialized,) = address(replacement).call(initialization);
        assertFalse(initialized, "replacement initializer is unlocked");
    }

    function testTokenizedExtensionRegistersWithItsExistingConstructorAndPaymentRouting() public {
        ITangleFull registry = _registry();
        TokenizedBindingManager manager = new TokenizedBindingManager();
        manager.initializeBlueprintManager(address(registry), address(this));
        uint64 id = registry.createBlueprint(_blueprintDefinition("tangle:tokenized-binding", address(manager)));
        assertEq(id, 0);
        assertEq(manager.tangleCore(), address(registry));
        assertEq(manager.blueprintOwner(), address(this));
        assertEq(manager.queryDeveloperPaymentAddress(id), address(manager));
        assertEq(manager.name(), "Binding token");
    }

    function testFuzzUnexpectedCreatorCannotRelayFirstBinding(address creator) public {
        vm.assume(creator != address(this));
        ITangleFull registry = _registry();
        BlueprintServiceManagerBase manager = new BlueprintServiceManagerBase();
        manager.initializeBlueprintManager(address(registry), address(this));
        Types.BlueprintDefinition memory definition = _blueprintDefinition("tangle:foreign-relay", address(manager));
        vm.prank(creator);
        vm.expectRevert();
        registry.createBlueprint(definition);
        _assertBound(manager, registry, type(uint64).max);
        assertEq(registry.blueprintCount(), 0);
    }
}
