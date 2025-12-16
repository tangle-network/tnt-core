// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import { Test } from "forge-std/Test.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import { MasterBlueprintServiceManager } from"../src/MasterBlueprintServiceManager.sol";
import "./MockERC20.sol";
import"../src/IBlueprintServiceManager.sol";
import"../src/AssetsLib.sol";
import"../src/ServiceOperatorsLib.sol";
import "./MockBlueprintServiceManager.sol";

contract MasterBlueprintServiceManagerTest is Test {
    using Assets for address;
    using Assets for Assets.Asset;

    MasterBlueprintServiceManager masterManager;
    MockBlueprintServiceManager mockManager;
    MockERC20 erc20Token;
    address payable protocolFeesReceiver = payable(address(0xdead));
    address payable blueprintOwner = payable(address(0xbeef));

    // Set up roles
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant TRENCH_UPDATE_ROLE = keccak256("TRENCH_UPDATE_ROLE");

    address public ROOT_CHAIN = address(0x09dF6A941ee03B1e632904E382e10862fA9cc0e3);

    uint16 public constant BASE_PERCENT = 10_000;

    event BlueprintCreated(
        address indexed owner, uint64 indexed blueprintId, MasterBlueprintServiceManager.Blueprint blueprint
    );
    event OperatorRegistered(uint64 indexed blueprintId, ServiceOperators.OperatorPreferences operator);
    event OperatorUnregistered(uint64 indexed blueprintId, ServiceOperators.OperatorPreferences operator);
    event RpcAddressUpdated(uint64 indexed blueprintId, ServiceOperators.OperatorPreferences operator);
    event ServiceRequested(
        uint64 indexed blueprintId,
        uint64 indexed requestId,
        address indexed requester,
        uint64 ttl,
        Assets.Asset asset,
        uint256 amount
    );
    event RequestApproved(
        uint64 indexed blueprintId,
        uint64 indexed requestId,
        ServiceOperators.OperatorPreferences operator,
        uint8 restakingPercent
    );
    event RequestRejected(
        uint64 indexed blueprintId, uint64 indexed requestId, ServiceOperators.OperatorPreferences operator
    );
    event ServiceInitialized(
        uint64 indexed blueprintId, uint64 indexed requestId, uint64 indexed serviceId, address owner, uint64 ttl
    );
    event JobCalled(uint64 indexed blueprintId, uint64 indexed serviceId, uint8 job, uint64 jobCallId);
    event JobResultReceived(
        uint64 indexed blueprintId,
        uint64 indexed serviceId,
        uint8 job,
        uint64 jobCallId,
        ServiceOperators.OperatorPreferences operator
    );
    event ServiceTerminated(uint64 indexed blueprintId, uint64 indexed serviceId, address owner);
    event UnappliedSlash(
        uint64 indexed blueprintId, uint64 indexed serviceId, bytes offender, uint8 slashPercent
    );
    event Slashed(
        uint64 indexed blueprintId, uint64 indexed serviceId, bytes offender, uint8 slashPercent
    );

    function setUp() public {
        // Impersonate the ROOT_CHAIN address for deployment
        vm.startPrank(ROOT_CHAIN);
        masterManager = new MasterBlueprintServiceManager(protocolFeesReceiver);
        vm.stopPrank();

        // Create mock blueprint service manager
        mockManager = new MockBlueprintServiceManager();
        mockManager.setMasterBlueprintServiceManager(address(masterManager));
        mockManager.setBlueprintOwner(address(payable(blueprintOwner)));

        // Deploy a mock ERC20 token
        erc20Token = new MockERC20();
        erc20Token.initialize("Mock Token", "MTK", 18);
        erc20Token.mint(address(this), 1_000_000 ether);

        // Grant necessary roles to the test contract
        vm.startPrank(ROOT_CHAIN);
        masterManager.grantRole(masterManager.DEFAULT_ADMIN_ROLE(), address(this));
        masterManager.grantRole(PAUSER_ROLE, address(this));
        masterManager.grantRole(TRENCH_UPDATE_ROLE, address(this));
        vm.stopPrank();
    }

    modifier asRootChain() {
        vm.startPrank(ROOT_CHAIN);
        _;
        vm.stopPrank();
    }

    // Test onBlueprintCreated
    function test_onBlueprintCreated() public asRootChain {
        uint64 blueprintId = 1;
        address owner = address(this);

        // Prepare Blueprint data
        MasterBlueprintServiceManager.ServiceMetadata memory metadata = MasterBlueprintServiceManager.ServiceMetadata({
            name: "Test Blueprint",
            description: "Test Description",
            author: "Test Author",
            category: "Test Category",
            codeRepository: "https://github.com/example",
            logo: "https://example.com/logo.png",
            website: "https://example.com",
            license: "MIT"
        });

        MasterBlueprintServiceManager.Blueprint memory blueprint = MasterBlueprintServiceManager.Blueprint({
            metadata: metadata,
            manager: address(mockManager),
            mbsmRevision: 1
        });

        // Expect the BlueprintCreated event
        vm.expectEmit(true, true, false, true);
        emit BlueprintCreated(owner, blueprintId, blueprint);

        masterManager.onBlueprintCreated(blueprintId, owner, blueprint);
    }

    function test_onBlueprintCreated_NotFromRootChain() public {
        uint64 blueprintId = 1;
        address owner = address(this);

        MasterBlueprintServiceManager.ServiceMetadata memory metadata = MasterBlueprintServiceManager.ServiceMetadata({
            name: "Test Blueprint",
            description: "Test Description",
            author: "Test Author",
            category: "Test Category",
            codeRepository: "https://github.com/example",
            logo: "https://example.com/logo.png",
            website: "https://example.com",
            license: "MIT"
        });

        MasterBlueprintServiceManager.Blueprint memory blueprint = MasterBlueprintServiceManager.Blueprint({
            metadata: metadata,
            manager: address(mockManager),
            mbsmRevision: 1
        });

        vm.expectRevert(
            abi.encodeWithSelector(RootChainEnabled.OnlyRootChainAllowed.selector, address(this), ROOT_CHAIN)
        );
        masterManager.onBlueprintCreated(blueprintId, owner, blueprint);
    }

    // Test onRegister
    function test_onRegister() public asRootChain {
        uint64 blueprintId = 1;
        address owner = address(this);

        // Create a blueprint first
        MasterBlueprintServiceManager.ServiceMetadata memory metadata = MasterBlueprintServiceManager.ServiceMetadata({
            name: "Test Blueprint",
            description: "",
            author: "",
            category: "",
            codeRepository: "",
            logo: "",
            website: "",
            license: ""
        });

        MasterBlueprintServiceManager.Blueprint memory blueprint = MasterBlueprintServiceManager.Blueprint({
            metadata: metadata,
            manager: address(mockManager),
            mbsmRevision: 1
        });

        masterManager.onBlueprintCreated(blueprintId, owner, blueprint);

        // Prepare operator preferences
        ServiceOperators.OperatorPreferences memory operatorPrefs = ServiceOperators.OperatorPreferences({
            ecdsaPublicKey: hex"1234",
            rpcAddress: "https://example.com/rpc"
        });

        bytes memory registrationInputs = hex"";

        // Expect the OperatorRegistered event
        vm.expectEmit(true, false, false, true);
        emit OperatorRegistered(blueprintId, operatorPrefs);

        masterManager.onRegister(blueprintId, operatorPrefs, registrationInputs);
    }

    function test_onRegister_NotFromRootChain() public {
        uint64 blueprintId = 1;
        ServiceOperators.OperatorPreferences memory operatorPrefs = ServiceOperators.OperatorPreferences({
            ecdsaPublicKey: hex"1234",
            rpcAddress: "https://example.com/rpc"
        });
        bytes memory registrationInputs = hex"";

        vm.expectRevert(
            abi.encodeWithSelector(RootChainEnabled.OnlyRootChainAllowed.selector, address(this), ROOT_CHAIN)
        );
        masterManager.onRegister(blueprintId, operatorPrefs, registrationInputs);
    }

    // Test onUnregister
    function test_onUnregister() public asRootChain {
        uint64 blueprintId = 1;
        address owner = address(this);

        // Create a blueprint first
        MasterBlueprintServiceManager.ServiceMetadata memory metadata = MasterBlueprintServiceManager.ServiceMetadata({
            name: "Test Blueprint",
            description: "",
            author: "",
            category: "",
            codeRepository: "",
            logo: "",
            website: "",
            license: ""
        });

        MasterBlueprintServiceManager.Blueprint memory blueprint = MasterBlueprintServiceManager.Blueprint({
            metadata: metadata,
            manager: address(mockManager),
            mbsmRevision: 1
        });

        masterManager.onBlueprintCreated(blueprintId, owner, blueprint);

        // Prepare operator preferences
        ServiceOperators.OperatorPreferences memory operatorPrefs = ServiceOperators.OperatorPreferences({
            ecdsaPublicKey: hex"1234",
            rpcAddress: "https://example.com/rpc"
        });

        // Expect the OperatorUnregistered event
        vm.expectEmit(true, false, false, true);
        emit OperatorUnregistered(blueprintId, operatorPrefs);

        masterManager.onUnregister(blueprintId, operatorPrefs);
    }

    function test_onUnregister_NotFromRootChain() public {
        uint64 blueprintId = 1;
        ServiceOperators.OperatorPreferences memory operatorPrefs = ServiceOperators.OperatorPreferences({
            ecdsaPublicKey: hex"1234",
            rpcAddress: "https://example.com/rpc"
        });

        vm.expectRevert(
            abi.encodeWithSelector(RootChainEnabled.OnlyRootChainAllowed.selector, address(this), ROOT_CHAIN)
        );
        masterManager.onUnregister(blueprintId, operatorPrefs);
    }

    // Test onUpdateRpcAddress
    function test_onUpdateRpcAddress() public asRootChain {
        uint64 blueprintId = 1;
        address owner = address(this);

        // Create a blueprint first
        MasterBlueprintServiceManager.ServiceMetadata memory metadata = MasterBlueprintServiceManager.ServiceMetadata({
            name: "Test Blueprint",
            description: "",
            author: "",
            category: "",
            codeRepository: "",
            logo: "",
            website: "",
            license: ""
        });

        MasterBlueprintServiceManager.Blueprint memory blueprint = MasterBlueprintServiceManager.Blueprint({
            metadata: metadata,
            manager: address(mockManager),
            mbsmRevision: 1
        });

        masterManager.onBlueprintCreated(blueprintId, owner, blueprint);

        ServiceOperators.OperatorPreferences memory operatorPrefs = ServiceOperators.OperatorPreferences({
            ecdsaPublicKey: hex"1234",
            rpcAddress: "https://example.com/rpc"
        });

        // Expect the RpcAddressUpdated event
        vm.expectEmit(true, false, false, true);
        emit RpcAddressUpdated(blueprintId, operatorPrefs);

        masterManager.onUpdateRpcAddress(blueprintId, operatorPrefs);
    }

    function test_onUpdateRpcAddress_NotFromRootChain() public {
        uint64 blueprintId = 1;
        ServiceOperators.OperatorPreferences memory operatorPrefs = ServiceOperators.OperatorPreferences({
            ecdsaPublicKey: hex"1234",
            rpcAddress: "https://example.com/rpc"
        });

        vm.expectRevert(
            abi.encodeWithSelector(RootChainEnabled.OnlyRootChainAllowed.selector, address(this), ROOT_CHAIN)
        );
        masterManager.onUpdateRpcAddress(blueprintId, operatorPrefs);
    }

    // Test onRequest
    function test_onRequest() public asRootChain {
        uint64 blueprintId = 1;
        address requester = address(this);

        // Create a blueprint first
        MasterBlueprintServiceManager.ServiceMetadata memory metadata = MasterBlueprintServiceManager.ServiceMetadata({
            name: "Test Blueprint",
            description: "",
            author: "",
            category: "",
            codeRepository: "",
            logo: "",
            website: "",
            license: ""
        });

        MasterBlueprintServiceManager.Blueprint memory blueprint = MasterBlueprintServiceManager.Blueprint({
            metadata: metadata,
            manager: address(mockManager),
            mbsmRevision: 1
        });

        masterManager.onBlueprintCreated(blueprintId, requester, blueprint);

        // Prepare request parameters
        uint64 requestId = 1;
        uint64 ttl = 1000;

        ServiceOperators.OperatorPreferences[] memory operators = new ServiceOperators.OperatorPreferences[](1);
        operators[0] = ServiceOperators.OperatorPreferences({
            ecdsaPublicKey: hex"1234",
            rpcAddress: "https://example.com/rpc"
        });

        address[] memory permittedCallers = new address[](1);
        permittedCallers[0] = address(this);

        Assets.Asset memory paymentAsset =
            Assets.Asset({ kind: Assets.Kind.Erc20, data: bytes32(uint256(uint160(address(erc20Token)))) });

        uint256 amount = 100 ether;

        ServiceOperators.RequestParams memory params = ServiceOperators.RequestParams({
            requestId: requestId,
            requester: requester,
            operators: operators,
            requestInputs: hex"",
            permittedCallers: permittedCallers,
            ttl: ttl,
            paymentAsset: paymentAsset,
            amount: amount
        });

        // Expect the ServiceRequested event
        vm.expectEmit(true, true, true, true);
        emit ServiceRequested(blueprintId, requestId, requester, ttl, paymentAsset, amount);

        masterManager.onRequest(blueprintId, params);
    }

    function test_onRequest_NotFromRootChain() public {
        uint64 blueprintId = 1;
        address requester = address(this);

        // Prepare request parameters
        uint64 requestId = 1;
        uint64 ttl = 1000;

        ServiceOperators.OperatorPreferences[] memory operators = new ServiceOperators.OperatorPreferences[](1);
        operators[0] = ServiceOperators.OperatorPreferences({
            ecdsaPublicKey: hex"1234",
            rpcAddress: "https://example.com/rpc"
        });

        address[] memory permittedCallers = new address[](1);
        permittedCallers[0] = address(this);

        Assets.Asset memory paymentAsset =
            Assets.Asset({ kind: Assets.Kind.Erc20, data: bytes32(uint256(uint160(address(erc20Token)))) });

        uint256 amount = 100 ether;

        ServiceOperators.RequestParams memory params = ServiceOperators.RequestParams({
            requestId: requestId,
            requester: requester,
            operators: operators,
            requestInputs: hex"",
            permittedCallers: permittedCallers,
            ttl: ttl,
            paymentAsset: paymentAsset,
            amount: amount
        });

        vm.expectRevert(
            abi.encodeWithSelector(RootChainEnabled.OnlyRootChainAllowed.selector, address(this), ROOT_CHAIN)
        );
        masterManager.onRequest(blueprintId, params);
    }

    // Test onApprove
    function test_onApprove() public asRootChain {
        uint64 blueprintId = 1;
        address owner = address(this);

        // Create a blueprint first
        MasterBlueprintServiceManager.ServiceMetadata memory metadata = MasterBlueprintServiceManager.ServiceMetadata({
            name: "Test Blueprint",
            description: "",
            author: "",
            category: "",
            codeRepository: "",
            logo: "",
            website: "",
            license: ""
        });

        MasterBlueprintServiceManager.Blueprint memory blueprint = MasterBlueprintServiceManager.Blueprint({
            metadata: metadata,
            manager: address(mockManager),
            mbsmRevision: 1
        });

        masterManager.onBlueprintCreated(blueprintId, owner, blueprint);

        // Prepare operator preferences
        ServiceOperators.OperatorPreferences memory operatorPrefs = ServiceOperators.OperatorPreferences({
            ecdsaPublicKey: hex"1234",
            rpcAddress: "https://example.com/rpc"
        });

        uint64 requestId = 1;
        uint8 restakingPercent = 10;

        // Expect the RequestApproved event
        vm.expectEmit(true, true, false, true);
        emit RequestApproved(blueprintId, requestId, operatorPrefs, restakingPercent);

        masterManager.onApprove(blueprintId, operatorPrefs, requestId, restakingPercent);
    }

    function test_onApprove_NotFromRootChain() public {
        uint64 blueprintId = 1;

        ServiceOperators.OperatorPreferences memory operatorPrefs = ServiceOperators.OperatorPreferences({
            ecdsaPublicKey: hex"1234",
            rpcAddress: "https://example.com/rpc"
        });

        uint64 requestId = 1;
        uint8 restakingPercent = 10;

        vm.expectRevert(
            abi.encodeWithSelector(RootChainEnabled.OnlyRootChainAllowed.selector, address(this), ROOT_CHAIN)
        );
        masterManager.onApprove(blueprintId, operatorPrefs, requestId, restakingPercent);
    }

    // Test onReject
    function test_onReject() public asRootChain {
        uint64 blueprintId = 1;
        address owner = address(this);

        // Create a blueprint first
        MasterBlueprintServiceManager.ServiceMetadata memory metadata = MasterBlueprintServiceManager.ServiceMetadata({
            name: "Test Blueprint",
            description: "",
            author: "",
            category: "",
            codeRepository: "",
            logo: "",
            website: "",
            license: ""
        });

        MasterBlueprintServiceManager.Blueprint memory blueprint = MasterBlueprintServiceManager.Blueprint({
            metadata: metadata,
            manager: address(mockManager),
            mbsmRevision: 1
        });

        masterManager.onBlueprintCreated(blueprintId, owner, blueprint);

        // Prepare operator preferences
        ServiceOperators.OperatorPreferences memory operatorPrefs = ServiceOperators.OperatorPreferences({
            ecdsaPublicKey: hex"1234",
            rpcAddress: "https://example.com/rpc"
        });

        uint64 requestId = 1;

        // Expect the RequestRejected event
        vm.expectEmit(true, true, false, true);
        emit RequestRejected(blueprintId, requestId, operatorPrefs);

        masterManager.onReject(blueprintId, operatorPrefs, requestId);
    }

    function test_onReject_NotFromRootChain() public {
        uint64 blueprintId = 1;

        ServiceOperators.OperatorPreferences memory operatorPrefs = ServiceOperators.OperatorPreferences({
            ecdsaPublicKey: hex"1234",
            rpcAddress: "https://example.com/rpc"
        });

        uint64 requestId = 1;

        vm.expectRevert(
            abi.encodeWithSelector(RootChainEnabled.OnlyRootChainAllowed.selector, address(this), ROOT_CHAIN)
        );
        masterManager.onReject(blueprintId, operatorPrefs, requestId);
    }

    // Test onServiceInitialized
    function test_onServiceInitialized() public asRootChain {
        uint64 blueprintId = 1;
        uint64 requestId = 1;
        uint64 serviceId = 1;
        uint64 ttl = 1000;
        address owner = address(this);

        // Create a blueprint first
        MasterBlueprintServiceManager.ServiceMetadata memory metadata = MasterBlueprintServiceManager.ServiceMetadata({
            name: "Test Blueprint",
            description: "Test Description",
            author: "Test Author",
            category: "Test Category",
            codeRepository: "https://github.com/example",
            logo: "https://example.com/logo.png",
            website: "https://example.com",
            license: "MIT"
        });

        MasterBlueprintServiceManager.Blueprint memory blueprint = MasterBlueprintServiceManager.Blueprint({
            metadata: metadata,
            manager: address(mockManager),
            mbsmRevision: 1
        });

        masterManager.onBlueprintCreated(blueprintId, owner, blueprint);

        // Prepare permitted callers
        address[] memory permittedCallers = new address[](1);
        permittedCallers[0] = address(this);

        // Expect the ServiceInitialized event
        vm.expectEmit(true, true, true, true);
        emit ServiceInitialized(blueprintId, requestId, serviceId, owner, ttl);

        masterManager.onServiceInitialized(blueprintId, requestId, serviceId, owner, permittedCallers, ttl);
    }

    function test_onServiceInitialized_NotFromRootChain() public {
        uint64 blueprintId = 1;
        uint64 requestId = 1;
        uint64 serviceId = 1;
        uint64 ttl = 1000;
        address owner = address(this);

        address[] memory permittedCallers = new address[](1);
        permittedCallers[0] = address(this);

        vm.expectRevert(
            abi.encodeWithSelector(RootChainEnabled.OnlyRootChainAllowed.selector, address(this), ROOT_CHAIN)
        );
        masterManager.onServiceInitialized(blueprintId, requestId, serviceId, owner, permittedCallers, ttl);
    }

    // Test onJobCall
    function test_onJobCall() public asRootChain {
        uint64 blueprintId = 1;
        uint64 serviceId = 1;
        uint8 job = 1;
        uint64 jobCallId = 1;
        bytes memory inputs = hex"";

        // Create a blueprint first
        address owner = address(this);
        MasterBlueprintServiceManager.ServiceMetadata memory metadata = MasterBlueprintServiceManager.ServiceMetadata({
            name: "Test Blueprint",
            description: "Test Description",
            author: "Test Author",
            category: "Test Category",
            codeRepository: "https://github.com/example",
            logo: "https://example.com/logo.png",
            website: "https://example.com",
            license: "MIT"
        });

        MasterBlueprintServiceManager.Blueprint memory blueprint = MasterBlueprintServiceManager.Blueprint({
            metadata: metadata,
            manager: address(mockManager),
            mbsmRevision: 1
        });

        masterManager.onBlueprintCreated(blueprintId, owner, blueprint);

        // Expect the JobCalled event
        vm.expectEmit(true, true, false, true);
        emit JobCalled(blueprintId, serviceId, job, jobCallId);

        masterManager.onJobCall(blueprintId, serviceId, job, jobCallId, inputs);
    }

    function test_onJobCall_NotFromRootChain() public {
        uint64 blueprintId = 1;
        uint64 serviceId = 1;
        uint8 job = 1;
        uint64 jobCallId = 1;
        bytes memory inputs = hex"";

        vm.expectRevert(
            abi.encodeWithSelector(RootChainEnabled.OnlyRootChainAllowed.selector, address(this), ROOT_CHAIN)
        );
        masterManager.onJobCall(blueprintId, serviceId, job, jobCallId, inputs);
    }

    // Test onJobResult
    function test_onJobResult() public asRootChain {
        uint64 blueprintId = 1;
        uint64 serviceId = 1;
        uint8 job = 1;
        uint64 jobCallId = 1;
        bytes memory inputs = hex"";
        bytes memory outputs = hex"";

        // Prepare operator preferences
        ServiceOperators.OperatorPreferences memory operatorPrefs = ServiceOperators.OperatorPreferences({
            ecdsaPublicKey: hex"abcd",
            rpcAddress: "https://example.com/rpc"
        });

        // Create a blueprint first
        address owner = address(this);
        MasterBlueprintServiceManager.ServiceMetadata memory metadata = MasterBlueprintServiceManager.ServiceMetadata({
            name: "Test Blueprint",
            description: "Test Description",
            author: "Test Author",
            category: "Test Category",
            codeRepository: "https://github.com/example",
            logo: "https://example.com/logo.png",
            website: "https://example.com",
            license: "MIT"
        });

        MasterBlueprintServiceManager.Blueprint memory blueprint = MasterBlueprintServiceManager.Blueprint({
            metadata: metadata,
            manager: address(mockManager),
            mbsmRevision: 1
        });

        masterManager.onBlueprintCreated(blueprintId, owner, blueprint);

        // Expect the JobResultReceived event
        vm.expectEmit(true, true, false, true);
        emit JobResultReceived(blueprintId, serviceId, job, jobCallId, operatorPrefs);

        masterManager.onJobResult(blueprintId, serviceId, job, jobCallId, operatorPrefs, inputs, outputs);
    }

    function test_onJobResult_NotFromRootChain() public {
        uint64 blueprintId = 1;
        uint64 serviceId = 1;
        uint8 job = 1;
        uint64 jobCallId = 1;
        bytes memory inputs = hex"";
        bytes memory outputs = hex"";

        // Prepare operator preferences
        ServiceOperators.OperatorPreferences memory operatorPrefs = ServiceOperators.OperatorPreferences({
            ecdsaPublicKey: hex"abcd",
            rpcAddress: "https://example.com/rpc"
        });

        vm.expectRevert(
            abi.encodeWithSelector(RootChainEnabled.OnlyRootChainAllowed.selector, address(this), ROOT_CHAIN)
        );

        masterManager.onJobResult(blueprintId, serviceId, job, jobCallId, operatorPrefs, inputs, outputs);
    }

    // Test onServiceTermination
    function test_onServiceTermination() public asRootChain {
        uint64 blueprintId = 1;
        uint64 serviceId = 1;
        address owner = address(this);

        // Create a blueprint first
        MasterBlueprintServiceManager.ServiceMetadata memory metadata = MasterBlueprintServiceManager.ServiceMetadata({
            name: "Test Blueprint",
            description: "Test Description",
            author: "Test Author",
            category: "Test Category",
            codeRepository: "https://github.com/example",
            logo: "https://example.com/logo.png",
            website: "https://example.com",
            license: "MIT"
        });

        MasterBlueprintServiceManager.Blueprint memory blueprint = MasterBlueprintServiceManager.Blueprint({
            metadata: metadata,
            manager: address(mockManager),
            mbsmRevision: 1
        });

        masterManager.onBlueprintCreated(blueprintId, owner, blueprint);

        // Expect the ServiceTerminated event
        vm.expectEmit(true, true, false, true);
        emit ServiceTerminated(blueprintId, serviceId, owner);

        masterManager.onServiceTermination(blueprintId, serviceId, owner);
    }

    function test_onServiceTermination_NotFromRootChain() public {
        uint64 blueprintId = 1;
        uint64 serviceId = 1;
        address owner = address(this);

        vm.expectRevert(
            abi.encodeWithSelector(RootChainEnabled.OnlyRootChainAllowed.selector, address(this), ROOT_CHAIN)
        );

        masterManager.onServiceTermination(blueprintId, serviceId, owner);
    }

    // Test onUnappliedSlash
    function test_onUnappliedSlash() public asRootChain {
        uint64 blueprintId = 1;
        uint64 serviceId = 1;
        bytes memory offender = hex"abcd";
        uint8 slashPercent = 20;

        // Create a blueprint first
        address owner = address(this);
        MasterBlueprintServiceManager.ServiceMetadata memory metadata = MasterBlueprintServiceManager.ServiceMetadata({
            name: "Test Blueprint",
            description: "Test Description",
            author: "Test Author",
            category: "Test Category",
            codeRepository: "https://github.com/example",
            logo: "https://example.com/logo.png",
            website: "https://example.com",
            license: "MIT"
        });

        MasterBlueprintServiceManager.Blueprint memory blueprint = MasterBlueprintServiceManager.Blueprint({
            metadata: metadata,
            manager: address(mockManager),
            mbsmRevision: 1
        });

        masterManager.onBlueprintCreated(blueprintId, owner, blueprint);

        // Expect the UnappliedSlash event
        vm.expectEmit(true, true, false, true);
        emit UnappliedSlash(blueprintId, serviceId, offender, slashPercent);

        masterManager.onUnappliedSlash(blueprintId, serviceId, offender, slashPercent);
    }

    function test_onUnappliedSlash_NotFromRootChain() public {
        uint64 blueprintId = 1;
        uint64 serviceId = 1;
        bytes memory offender = hex"abcd";
        uint8 slashPercent = 20;

        vm.expectRevert(
            abi.encodeWithSelector(RootChainEnabled.OnlyRootChainAllowed.selector, address(this), ROOT_CHAIN)
        );

        masterManager.onUnappliedSlash(blueprintId, serviceId, offender, slashPercent);
    }

    // Test onSlash
    function test_onSlash() public asRootChain {
        uint64 blueprintId = 1;
        uint64 serviceId = 1;
        bytes memory offender = hex"abcd";
        uint8 slashPercent = 15;
        uint256 totalPayout = 500 ether;

        // Create a blueprint first
        address owner = address(this);
        MasterBlueprintServiceManager.ServiceMetadata memory metadata = MasterBlueprintServiceManager.ServiceMetadata({
            name: "Test Blueprint",
            description: "Test Description",
            author: "Test Author",
            category: "Test Category",
            codeRepository: "https://github.com/example",
            logo: "https://example.com/logo.png",
            website: "https://example.com",
            license: "MIT"
        });

        MasterBlueprintServiceManager.Blueprint memory blueprint = MasterBlueprintServiceManager.Blueprint({
            metadata: metadata,
            manager: address(mockManager),
            mbsmRevision: 1
        });

        masterManager.onBlueprintCreated(blueprintId, owner, blueprint);

        // Expect the Slashed event
        vm.expectEmit(true, true, false, true);
        emit Slashed(blueprintId, serviceId, offender, slashPercent);

        masterManager.onSlash(blueprintId, serviceId, offender, slashPercent);
    }

    function test_onSlash_NotFromRootChain() public {
        uint64 blueprintId = 1;
        uint64 serviceId = 1;
        bytes memory offender = hex"abcd";
        uint8 slashPercent = 15;

        vm.expectRevert(
            abi.encodeWithSelector(RootChainEnabled.OnlyRootChainAllowed.selector, address(this), ROOT_CHAIN)
        );

        masterManager.onSlash(blueprintId, serviceId, offender, slashPercent);
    }

    // Test querySlashingOrigin
    function test_querySlashingOrigin() public {
        uint64 blueprintId = 1;
        uint64 serviceId = 1;
        address expectedOrigin = address(mockManager);

        // Create a blueprint first
        address owner = address(this);

        MasterBlueprintServiceManager.ServiceMetadata memory metadata = MasterBlueprintServiceManager.ServiceMetadata({
            name: "Test Blueprint",
            description: "Test Description",
            author: "Test Author",
            category: "Test Category",
            codeRepository: "https://github.com/example",
            logo: "https://example.com/logo.png",
            website: "https://example.com",
            license: "MIT"
        });

        MasterBlueprintServiceManager.Blueprint memory blueprint = MasterBlueprintServiceManager.Blueprint({
            metadata: metadata,
            manager: address(mockManager),
            mbsmRevision: 1
        });

        vm.startPrank(ROOT_CHAIN);
        masterManager.onBlueprintCreated(blueprintId, owner, blueprint);
        vm.stopPrank();

        address slashingOrigin = masterManager.querySlashingOrigin(blueprintId, serviceId);
        assertEq(slashingOrigin, expectedOrigin);
    }

    // Test queryDisputeOrigin
    function test_queryDisputeOrigin() public {
        uint64 blueprintId = 1;
        uint64 serviceId = 1;
        address expectedOrigin = address(mockManager);

        // Create a blueprint first
        address owner = address(this);

        MasterBlueprintServiceManager.ServiceMetadata memory metadata = MasterBlueprintServiceManager.ServiceMetadata({
            name: "Test Blueprint",
            description: "Test Description",
            author: "Test Author",
            category: "Test Category",
            codeRepository: "https://github.com/example",
            logo: "https://example.com/logo.png",
            website: "https://example.com",
            license: "MIT"
        });

        MasterBlueprintServiceManager.Blueprint memory blueprint = MasterBlueprintServiceManager.Blueprint({
            metadata: metadata,
            manager: address(mockManager),
            mbsmRevision: 1
        });

        vm.startPrank(ROOT_CHAIN);
        masterManager.onBlueprintCreated(blueprintId, owner, blueprint);
        vm.stopPrank();

        address disputeOrigin = masterManager.queryDisputeOrigin(blueprintId, serviceId);
        assertEq(disputeOrigin, expectedOrigin);
    }

    // Test pause and unpause
    function test_pauseAndUnpause() public {
        masterManager.pause();
        assertTrue(masterManager.paused());

        // Attempt to call a function that is affected by whenNotPaused
        vm.startPrank(ROOT_CHAIN);

        uint64 blueprintId = 1;
        address owner = address(this);

        MasterBlueprintServiceManager.ServiceMetadata memory metadata = MasterBlueprintServiceManager.ServiceMetadata({
            name: "Test Blueprint",
            description: "",
            author: "",
            category: "",
            codeRepository: "",
            logo: "",
            website: "",
            license: ""
        });

        MasterBlueprintServiceManager.Blueprint memory blueprint = MasterBlueprintServiceManager.Blueprint({
            metadata: metadata,
            manager: address(mockManager),
            mbsmRevision: 1
        });

        vm.expectRevert(Pausable.EnforcedPause.selector);
        masterManager.onBlueprintCreated(blueprintId, owner, blueprint);

        vm.stopPrank();

        masterManager.unpause();
        assertFalse(masterManager.paused());
    }

    function test_pause_Unauthorized() public {
        assertFalse(masterManager.hasRole(PAUSER_ROLE, address(0x1234)));
        vm.prank(address(0x1234));
        vm.expectRevert(
            abi.encodeWithSelector(
                IAccessControl.AccessControlUnauthorizedAccount.selector, address(0x1234), PAUSER_ROLE
            )
        );
        masterManager.pause();
    }

    // Test setTranches
    function test_setTranches() public {
        MasterBlueprintServiceManager.Tranche[] memory newTranches = new MasterBlueprintServiceManager.Tranche[](2);
        newTranches[0] = MasterBlueprintServiceManager.Tranche({
            kind: MasterBlueprintServiceManager.TrancheKind.Developer,
            percent: 7000 // 70%
         });
        newTranches[1] = MasterBlueprintServiceManager.Tranche({
            kind: MasterBlueprintServiceManager.TrancheKind.Protocol,
            percent: 3000 // 30%
         });

        masterManager.setTranches(newTranches);

        // Since tranches is public, we can check the new values
        (MasterBlueprintServiceManager.TrancheKind kind0, uint16 percent0) = masterManager.tranches(0);
        assertEq(uint8(kind0), uint8(MasterBlueprintServiceManager.TrancheKind.Developer));
        assertEq(percent0, 7000);

        (MasterBlueprintServiceManager.TrancheKind kind1, uint16 percent1) = masterManager.tranches(1);
        assertEq(uint8(kind1), uint8(MasterBlueprintServiceManager.TrancheKind.Protocol));
        assertEq(percent1, 3000);
    }

    function test_setTranches_InvalidSum() public {
        MasterBlueprintServiceManager.Tranche[] memory newTranches = new MasterBlueprintServiceManager.Tranche[](2);
        newTranches[0] = MasterBlueprintServiceManager.Tranche({
            kind: MasterBlueprintServiceManager.TrancheKind.Developer,
            percent: 5000 // 50%
         });
        newTranches[1] = MasterBlueprintServiceManager.Tranche({
            kind: MasterBlueprintServiceManager.TrancheKind.Protocol,
            percent: 4000 // 40%
         });

        vm.expectRevert(MasterBlueprintServiceManager.InvalidTranches.selector);
        masterManager.setTranches(newTranches);
    }

    function test_setTranches_Unauthorized() public {
        MasterBlueprintServiceManager.Tranche[] memory newTranches = new MasterBlueprintServiceManager.Tranche[](2);
        newTranches[0] = MasterBlueprintServiceManager.Tranche({
            kind: MasterBlueprintServiceManager.TrancheKind.Developer,
            percent: 7000 // 70%
         });
        newTranches[1] = MasterBlueprintServiceManager.Tranche({
            kind: MasterBlueprintServiceManager.TrancheKind.Protocol,
            percent: 3000 // 30%
         });

        vm.prank(address(0x1234));
        vm.expectRevert(
            abi.encodeWithSelector(
                IAccessControl.AccessControlUnauthorizedAccount.selector, address(0x1234), TRENCH_UPDATE_ROLE
            )
        );

        masterManager.setTranches(newTranches);
    }

    // Test spliting the payment with ERC20
    function test_paymentSplit_erc20() public asRootChain {
        // Create a blueprint first
        MasterBlueprintServiceManager.ServiceMetadata memory metadata = MasterBlueprintServiceManager.ServiceMetadata({
            name: "Test Blueprint",
            description: "Test Description",
            author: "Test Author",
            category: "Test Category",
            codeRepository: "https://github.com/example",
            logo: "https://example.com/logo.png",
            website: "https://example.com",
            license: "MIT"
        });

        MasterBlueprintServiceManager.Blueprint memory blueprint = MasterBlueprintServiceManager.Blueprint({
            metadata: metadata,
            manager: address(mockManager),
            mbsmRevision: 1
        });

        masterManager.onBlueprintCreated(1, address(this), blueprint);

        ServiceOperators.OperatorPreferences[] memory operators = new ServiceOperators.OperatorPreferences[](1);
        operators[0] = ServiceOperators.OperatorPreferences({
            ecdsaPublicKey: hex"1234",
            rpcAddress: "https://example.com/rpc"
        });

        address[] memory permittedCallers = new address[](1);
        permittedCallers[0] = address(this);

        Assets.Asset memory paymentAsset =
            Assets.Asset({ kind: Assets.Kind.Erc20, data: bytes32(uint256(uint160(address(erc20Token)))) });

        uint256 amount = 100 ether;

        ServiceOperators.RequestParams memory params = ServiceOperators.RequestParams({
            requestId: 1,
            requester: address(this),
            operators: operators,
            requestInputs: hex"",
            permittedCallers: permittedCallers,
            ttl: 1000,
            paymentAsset: paymentAsset,
            amount: amount
        });

        masterManager.onRequest(1, params);

        // Approve the request
        uint8 restakingPercent = 10;
        masterManager.onApprove(1, operators[0], 1, restakingPercent);

        vm.startPrank(address(this));
        erc20Token.transfer(address(masterManager), amount);
        vm.stopPrank();

        vm.startPrank(ROOT_CHAIN);

        masterManager.onServiceInitialized(1, 1, 1, address(this), permittedCallers, 1000);

        // query the tranches to check the payment split
        (MasterBlueprintServiceManager.TrancheKind kind, uint16 percent) = masterManager.tranches(0);
        assert(kind == MasterBlueprintServiceManager.TrancheKind.Developer);
        address dev = mockManager.queryDeveloperPaymentAddress(1);
        uint256 expectedBalance = (amount * percent) / BASE_PERCENT;
        uint256 actualBalance = IERC20(erc20Token).balanceOf(dev);
        assertEq(actualBalance, expectedBalance);

        (kind, percent) = masterManager.tranches(1);
        assert(kind == MasterBlueprintServiceManager.TrancheKind.Protocol);

        address protocol = masterManager.protocolFeesReceiver();
        expectedBalance = (amount * percent) / BASE_PERCENT;
        actualBalance = IERC20(erc20Token).balanceOf(protocol);
        assertEq(actualBalance, expectedBalance);

        (kind, percent) = masterManager.tranches(2);
        assert(kind == MasterBlueprintServiceManager.TrancheKind.Operators);
        uint16 operatorPercent = percent;
        (kind, percent) = masterManager.tranches(3);
        assert(kind == MasterBlueprintServiceManager.TrancheKind.Restakers);
        uint16 restakerPercent = percent;
        uint16 rewardsPalletPercent = operatorPercent + restakerPercent;
        address rewardsPallet = masterManager.rewardsPallet();
        expectedBalance = (amount * rewardsPalletPercent) / BASE_PERCENT;
        actualBalance = IERC20(erc20Token).balanceOf(rewardsPallet);
        assertEq(actualBalance, expectedBalance);

        vm.stopPrank();
    }

    // Test spliting the payment with Native Token
    function test_paymentSplit_native() public asRootChain {
        // Create a blueprint first
        MasterBlueprintServiceManager.ServiceMetadata memory metadata = MasterBlueprintServiceManager.ServiceMetadata({
            name: "Test Blueprint",
            description: "Test Description",
            author: "Test Author",
            category: "Test Category",
            codeRepository: "https://github.com/example",
            logo: "https://example.com/logo.png",
            website: "https://example.com",
            license: "MIT"
        });

        MasterBlueprintServiceManager.Blueprint memory blueprint = MasterBlueprintServiceManager.Blueprint({
            metadata: metadata,
            manager: address(mockManager),
            mbsmRevision: 1
        });

        masterManager.onBlueprintCreated(1, address(this), blueprint);

        ServiceOperators.OperatorPreferences[] memory operators = new ServiceOperators.OperatorPreferences[](1);
        operators[0] = ServiceOperators.OperatorPreferences({
            ecdsaPublicKey: hex"1234",
            rpcAddress: "https://example.com/rpc"
        });

        address[] memory permittedCallers = new address[](1);
        permittedCallers[0] = address(this);

        Assets.Asset memory paymentAsset = Assets.Asset({ kind: Assets.Kind.Custom, data: bytes32(0x0) });

        uint256 amount = 100 ether;

        ServiceOperators.RequestParams memory params = ServiceOperators.RequestParams({
            requestId: 1,
            requester: address(this),
            operators: operators,
            requestInputs: hex"",
            permittedCallers: permittedCallers,
            ttl: 1000,
            paymentAsset: paymentAsset,
            amount: amount
        });

        masterManager.onRequest(1, params);

        // Approve the request
        uint8 restakingPercent = 10;
        masterManager.onApprove(1, operators[0], 1, restakingPercent);

        vm.startPrank(address(this));
        payable(address(ROOT_CHAIN)).transfer(amount);
        vm.stopPrank();

        vm.startPrank(ROOT_CHAIN);

        masterManager.onServiceInitialized{ value: amount }(1, 1, 1, address(this), permittedCallers, 1000);

        // query the tranches to check the payment split
        (MasterBlueprintServiceManager.TrancheKind kind, uint16 percent) = masterManager.tranches(0);
        assert(kind == MasterBlueprintServiceManager.TrancheKind.Developer);
        address dev = mockManager.queryDeveloperPaymentAddress(1);
        uint256 expectedBalance = (amount * percent) / BASE_PERCENT;
        uint256 actualBalance = dev.balance;
        assertEq(actualBalance, expectedBalance);

        (kind, percent) = masterManager.tranches(1);
        assert(kind == MasterBlueprintServiceManager.TrancheKind.Protocol);

        address protocol = masterManager.protocolFeesReceiver();
        expectedBalance = (amount * percent) / BASE_PERCENT;
        actualBalance = protocol.balance;
        assertEq(actualBalance, expectedBalance);

        (kind, percent) = masterManager.tranches(2);
        assert(kind == MasterBlueprintServiceManager.TrancheKind.Operators);
        uint16 operatorPercent = percent;
        (kind, percent) = masterManager.tranches(3);
        assert(kind == MasterBlueprintServiceManager.TrancheKind.Restakers);
        uint16 restakerPercent = percent;
        uint16 rewardsPalletPercent = operatorPercent + restakerPercent;
        address rewardsPallet = masterManager.rewardsPallet();
        expectedBalance = (amount * rewardsPalletPercent) / BASE_PERCENT;
        actualBalance = rewardsPallet.balance;
        assertEq(actualBalance, expectedBalance);

        vm.stopPrank();
    }

    function test_canJoin() public asRootChain {
        uint64 blueprintId = 1;
        address owner = address(this);

        // Create a blueprint first
        MasterBlueprintServiceManager.ServiceMetadata memory metadata = MasterBlueprintServiceManager.ServiceMetadata({
            name: "Test Blueprint",
            description: "",
            author: "",
            category: "",
            codeRepository: "",
            logo: "",
            website: "",
            license: ""
        });

        MasterBlueprintServiceManager.Blueprint memory blueprint = MasterBlueprintServiceManager.Blueprint({
            metadata: metadata,
            manager: address(mockManager),
            mbsmRevision: 1
        });

        masterManager.onBlueprintCreated(blueprintId, owner, blueprint);

        ServiceOperators.OperatorPreferences memory operator = ServiceOperators.OperatorPreferences({
            ecdsaPublicKey: hex"1234",
            rpcAddress: "https://example.com/rpc"
        });

        uint64 serviceId = 1;
        bool canJoin = masterManager.canJoin(blueprintId, serviceId, operator);
        assertTrue(canJoin, "Operator should be able to join");
    }

    function test_onOperatorJoined() public asRootChain {
        uint64 blueprintId = 1;
        address owner = address(this);

        // Create a blueprint first
        MasterBlueprintServiceManager.ServiceMetadata memory metadata = MasterBlueprintServiceManager.ServiceMetadata({
            name: "Test Blueprint",
            description: "",
            author: "",
            category: "",
            codeRepository: "",
            logo: "",
            website: "",
            license: ""
        });

        MasterBlueprintServiceManager.Blueprint memory blueprint = MasterBlueprintServiceManager.Blueprint({
            metadata: metadata,
            manager: address(mockManager),
            mbsmRevision: 1
        });

        masterManager.onBlueprintCreated(blueprintId, owner, blueprint);

        uint64 serviceId = 1;
        ServiceOperators.OperatorPreferences memory operator = ServiceOperators.OperatorPreferences({
            ecdsaPublicKey: hex"1234",
            rpcAddress: "https://example.com/rpc"
        });

        // Should not revert
        masterManager.onOperatorJoined(blueprintId, serviceId, operator);
    }

    function test_canLeave() public asRootChain {
        uint64 blueprintId = 1;
        address owner = address(this);

        // Create a blueprint first
        MasterBlueprintServiceManager.ServiceMetadata memory metadata = MasterBlueprintServiceManager.ServiceMetadata({
            name: "Test Blueprint",
            description: "",
            author: "",
            category: "",
            codeRepository: "",
            logo: "",
            website: "",
            license: ""
        });

        MasterBlueprintServiceManager.Blueprint memory blueprint = MasterBlueprintServiceManager.Blueprint({
            metadata: metadata,
            manager: address(mockManager),
            mbsmRevision: 1
        });

        masterManager.onBlueprintCreated(blueprintId, owner, blueprint);

        ServiceOperators.OperatorPreferences memory operator = ServiceOperators.OperatorPreferences({
            ecdsaPublicKey: hex"1234",
            rpcAddress: "https://example.com/rpc"
        });

        uint64 serviceId = 1;
        bool canLeave = masterManager.canLeave(blueprintId, serviceId, operator);
        assertTrue(canLeave, "Operator should be able to leave");
    }

    function test_onOperatorLeft() public asRootChain {
        uint64 blueprintId = 1;
        address owner = address(this);

        // Create a blueprint first
        MasterBlueprintServiceManager.ServiceMetadata memory metadata = MasterBlueprintServiceManager.ServiceMetadata({
            name: "Test Blueprint",
            description: "",
            author: "",
            category: "",
            codeRepository: "",
            logo: "",
            website: "",
            license: ""
        });

        MasterBlueprintServiceManager.Blueprint memory blueprint = MasterBlueprintServiceManager.Blueprint({
            metadata: metadata,
            manager: address(mockManager),
            mbsmRevision: 1
        });

        masterManager.onBlueprintCreated(blueprintId, owner, blueprint);

        uint64 serviceId = 1;
        ServiceOperators.OperatorPreferences memory operator = ServiceOperators.OperatorPreferences({
            ecdsaPublicKey: hex"1234",
            rpcAddress: "https://example.com/rpc"
        });

        // Should not revert
        masterManager.onOperatorLeft(blueprintId, serviceId, operator);
    }
}
