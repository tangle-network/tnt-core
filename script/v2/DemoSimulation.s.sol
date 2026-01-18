// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console2} from "forge-std/Script.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import {Tangle} from "../../src/v2/Tangle.sol";
import { ITangleFull } from "../../src/v2/interfaces/ITangle.sol";
import { IMultiAssetDelegation } from "../../src/v2/interfaces/IMultiAssetDelegation.sol";
import {MultiAssetDelegation} from "../../src/v2/restaking/MultiAssetDelegation.sol";
import {OperatorStatusRegistry} from "../../src/v2/restaking/OperatorStatusRegistry.sol";
import {TangleToken} from "../../src/v2/governance/TangleToken.sol";
import {MasterBlueprintServiceManager} from "../../src/v2/MasterBlueprintServiceManager.sol";
import {MBSMRegistry} from "../../src/v2/MBSMRegistry.sol";
import {Types} from "../../src/v2/libraries/Types.sol";
import {BlueprintDefinitionHelper} from "../../test/support/BlueprintDefinitionHelper.sol";
import { TangleBlueprintsFacet } from "../../src/v2/facets/tangle/TangleBlueprintsFacet.sol";
import { TangleBlueprintsManagementFacet } from "../../src/v2/facets/tangle/TangleBlueprintsManagementFacet.sol";
import { TangleOperatorsFacet } from "../../src/v2/facets/tangle/TangleOperatorsFacet.sol";
import { TangleServicesRequestsFacet } from "../../src/v2/facets/tangle/TangleServicesRequestsFacet.sol";
import { TangleServicesFacet } from "../../src/v2/facets/tangle/TangleServicesFacet.sol";
import { TangleServicesLifecycleFacet } from "../../src/v2/facets/tangle/TangleServicesLifecycleFacet.sol";
import { TangleJobsFacet } from "../../src/v2/facets/tangle/TangleJobsFacet.sol";
import { TangleJobsAggregationFacet } from "../../src/v2/facets/tangle/TangleJobsAggregationFacet.sol";
import { TangleQuotesFacet } from "../../src/v2/facets/tangle/TangleQuotesFacet.sol";
import { TangleQuotesExtensionFacet } from "../../src/v2/facets/tangle/TangleQuotesExtensionFacet.sol";
import { TanglePaymentsFacet } from "../../src/v2/facets/tangle/TanglePaymentsFacet.sol";
import { TangleSlashingFacet } from "../../src/v2/facets/tangle/TangleSlashingFacet.sol";
import { RestakingOperatorsFacet } from "../../src/v2/facets/restaking/RestakingOperatorsFacet.sol";
import { RestakingDepositsFacet } from "../../src/v2/facets/restaking/RestakingDepositsFacet.sol";
import { RestakingDelegationsFacet } from "../../src/v2/facets/restaking/RestakingDelegationsFacet.sol";
import { RestakingSlashingFacet } from "../../src/v2/facets/restaking/RestakingSlashingFacet.sol";
import { RestakingAssetsFacet } from "../../src/v2/facets/restaking/RestakingAssetsFacet.sol";
import { RestakingViewsFacet } from "../../src/v2/facets/restaking/RestakingViewsFacet.sol";
import { RestakingAdminFacet } from "../../src/v2/facets/restaking/RestakingAdminFacet.sol";

/// @title DemoERC20
/// @notice Simple ERC20 for demo purposes
contract DemoERC20 {
    string public name;
    string public symbol;
    uint8 public constant decimals = 18;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    uint256 public totalSupply;

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }

    function mint(address to, uint256 amount) external {
        balanceOf[to] += amount;
        totalSupply += amount;
        emit Transfer(address(0), to, amount);
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        return _transfer(msg.sender, to, amount);
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        uint256 allowed = allowance[from][msg.sender];
        if (allowed != type(uint256).max) {
            require(allowed >= amount, "insufficient allowance");
            allowance[from][msg.sender] = allowed - amount;
        }
        return _transfer(from, to, amount);
    }

    function _transfer(address from, address to, uint256 amount) internal returns (bool) {
        require(balanceOf[from] >= amount, "insufficient balance");
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        emit Transfer(from, to, amount);
        return true;
    }
}

/// @title DemoSimulation
/// @notice Comprehensive demo simulation that generates tons of protocol activity
/// @dev Run with: forge script script/v2/DemoSimulation.s.sol:DemoSimulation --rpc-url http://127.0.0.1:8545 --broadcast
///
/// This script:
/// 1. Deploys all contracts (or uses existing ones)
/// 2. Creates multiple blueprints with different configurations
/// 3. Registers many operators
/// 4. Creates multiple services
/// 5. Runs a continuous loop generating activity every few seconds:
///    - Job submissions and results
///    - Deposits and delegations
///    - Unstaking and withdrawals
///    - Heartbeats
///    - Slashing events
///    - Reward distributions
contract DemoSimulation is Script, BlueprintDefinitionHelper {
    // ═══════════════════════════════════════════════════════════════════════════
    // CONFIGURATION
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Number of simulation ticks to run
    uint256 public constant TOTAL_TICKS = 100;

    /// @notice Seconds between each tick (use with vm.warp for time progression)
    uint256 public constant TICK_INTERVAL = 3;

    /// @notice Number of operators to create
    uint256 public constant NUM_OPERATORS = 5;

    /// @notice Number of delegators to create
    uint256 public constant NUM_DELEGATORS = 8;

    /// @notice Number of blueprints to create
    uint256 public constant NUM_BLUEPRINTS = 3;

    /// @notice Number of services to create
    uint256 public constant NUM_SERVICES = 4;

    // ═══════════════════════════════════════════════════════════════════════════
    // KEYS (deterministic from seeds)
    // ═══════════════════════════════════════════════════════════════════════════

    uint256 internal constant ADMIN_KEY = uint256(keccak256("demo.admin"));
    uint256 internal constant SLASHER_KEY = uint256(keccak256("demo.slasher"));

    // Operator keys: keccak256("demo.operator.0"), etc.
    // Delegator keys: keccak256("demo.delegator.0"), etc.

    // ═══════════════════════════════════════════════════════════════════════════
    // STATE
    // ═══════════════════════════════════════════════════════════════════════════

    // Deployed contracts
    ITangleFull public tangle;
    IMultiAssetDelegation public restaking;
    OperatorStatusRegistry public statusRegistry;
    TangleToken public tnt;
    DemoERC20 public usdc;
    DemoERC20 public weth;

    // Actors
    address public admin;
    address public slasher;
    address[] public operators;
    address[] public delegators;
    uint256[] public operatorKeys;
    uint256[] public delegatorKeys;

    // Protocol state
    uint64[] public blueprintIds;
    uint64[] public serviceIds;
    mapping(uint64 => uint64) public serviceCallIds; // serviceId => next callId
    uint256 public currentTick;

    // Activity counters for logging
    uint256 public totalJobs;
    uint256 public totalDeposits;
    uint256 public totalDelegations;
    uint256 public totalHeartbeats;
    uint256 public totalSlashes;

    function _registerTangleFacets(address tangleProxy) internal {
        Tangle router = Tangle(payable(tangleProxy));
        router.registerFacet(address(new TangleBlueprintsFacet()));
        router.registerFacet(address(new TangleBlueprintsManagementFacet()));
        router.registerFacet(address(new TangleOperatorsFacet()));
        router.registerFacet(address(new TangleServicesRequestsFacet()));
        router.registerFacet(address(new TangleServicesFacet()));
        router.registerFacet(address(new TangleServicesLifecycleFacet()));
        router.registerFacet(address(new TangleJobsFacet()));
        router.registerFacet(address(new TangleJobsAggregationFacet()));
        router.registerFacet(address(new TangleQuotesFacet()));
        router.registerFacet(address(new TangleQuotesExtensionFacet()));
        router.registerFacet(address(new TanglePaymentsFacet()));
        router.registerFacet(address(new TangleSlashingFacet()));
    }

    function _registerRestakingFacets(address restakingProxy) internal {
        MultiAssetDelegation router = MultiAssetDelegation(payable(restakingProxy));
        router.registerFacet(address(new RestakingOperatorsFacet()));
        router.registerFacet(address(new RestakingDepositsFacet()));
        router.registerFacet(address(new RestakingDelegationsFacet()));
        router.registerFacet(address(new RestakingSlashingFacet()));
        router.registerFacet(address(new RestakingAssetsFacet()));
        router.registerFacet(address(new RestakingViewsFacet()));
        router.registerFacet(address(new RestakingAdminFacet()));
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // MAIN ENTRY POINT
    // ═══════════════════════════════════════════════════════════════════════════

    function run() external virtual {
        console2.log("");
        console2.log("========================================");
        console2.log("   TANGLE DEMO SIMULATION");
        console2.log("========================================");
        console2.log("Ticks:", TOTAL_TICKS);
        console2.log("Interval:", TICK_INTERVAL);
        console2.log("Operators:", NUM_OPERATORS);
        console2.log("Delegators:", NUM_DELEGATORS);
        console2.log("Blueprints:", NUM_BLUEPRINTS);
        console2.log("Services:", NUM_SERVICES);
        console2.log("========================================");

        _initializeActors();
        _fundActors();
        _deployContracts();
        _setupTokens();
        _registerOperatorsInRestaking();
        _createBlueprints();
        _registerOperatorsForBlueprints();
        _createServices();
        _initialDelegations();

        console2.log("\n=== SETUP COMPLETE - STARTING SIMULATION ===\n");

        // Run the simulation loop
        for (uint256 tick = 0; tick < TOTAL_TICKS; tick++) {
            currentTick = tick;
            _executeTick(tick);

            // Progress time
            vm.warp(block.timestamp + TICK_INTERVAL);

            // Log progress every 10 ticks
            if (tick % 10 == 9) {
                _logProgress();
            }
        }

        _logFinalStats();
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SETUP FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    function _initializeActors() internal {
        admin = vm.addr(ADMIN_KEY);
        slasher = vm.addr(SLASHER_KEY);

        vm.label(admin, "Admin");
        vm.label(slasher, "Slasher");

        // Initialize operators
        for (uint256 i = 0; i < NUM_OPERATORS; i++) {
            uint256 key = uint256(keccak256(abi.encodePacked("demo.operator.", i)));
            address op = vm.addr(key);
            operators.push(op);
            operatorKeys.push(key);
            vm.label(op, string(abi.encodePacked("Operator", vm.toString(i))));
        }

        // Initialize delegators
        for (uint256 i = 0; i < NUM_DELEGATORS; i++) {
            uint256 key = uint256(keccak256(abi.encodePacked("demo.delegator.", i)));
            address del = vm.addr(key);
            delegators.push(del);
            delegatorKeys.push(key);
            vm.label(del, string(abi.encodePacked("Delegator", vm.toString(i))));
        }

        console2.log("[Setup] Initialized operators:", NUM_OPERATORS);
        console2.log("[Setup] Initialized delegators:", NUM_DELEGATORS);
    }

    function _fundActors() internal {
        // Fund admin
        vm.deal(admin, 10_000 ether);
        vm.deal(slasher, 100 ether);

        // Fund operators
        for (uint256 i = 0; i < operators.length; i++) {
            vm.deal(operators[i], 1_000 ether);
        }

        // Fund delegators
        for (uint256 i = 0; i < delegators.length; i++) {
            vm.deal(delegators[i], 500 ether);
        }

        console2.log("[Setup] Funded all actors with ETH");
    }

    function _deployContracts() internal {
        console2.log("[Setup] Deploying contracts...");

        vm.startBroadcast(ADMIN_KEY);

        // Deploy MultiAssetDelegation
        MultiAssetDelegation restakingImpl = new MultiAssetDelegation();
        bytes memory restakingInit = abi.encodeCall(
            MultiAssetDelegation.initialize,
            (admin, 1 ether, 7, 1000) // minOpStake, roundDelay, commissionBps
        );
        address restakingProxy = address(new ERC1967Proxy(address(restakingImpl), restakingInit));
        restaking = IMultiAssetDelegation(payable(restakingProxy));
        console2.log("  MultiAssetDelegation:", restakingProxy);

        // Deploy Tangle
        Tangle tangleImpl = new Tangle();
        bytes memory tangleInit = abi.encodeCall(Tangle.initialize, (admin, restakingProxy, payable(admin)));
        address tangleProxy = address(new ERC1967Proxy(address(tangleImpl), tangleInit));
        tangle = ITangleFull(payable(tangleProxy));
        console2.log("  Tangle:", tangleProxy);

        _registerRestakingFacets(restakingProxy);
        _registerTangleFacets(tangleProxy);

        // Deploy OperatorStatusRegistry
        statusRegistry = new OperatorStatusRegistry(tangleProxy, admin);
        console2.log("  OperatorStatusRegistry:", address(statusRegistry));

        // Deploy TNT token
        TangleToken tntImpl = new TangleToken();
        ERC1967Proxy tntProxy =
            new ERC1967Proxy(address(tntImpl), abi.encodeCall(TangleToken.initialize, (admin, tntImpl.MAX_SUPPLY())));
        tnt = TangleToken(address(tntProxy));
        console2.log("  TangleToken:", address(tnt));

        // Deploy demo tokens
        usdc = new DemoERC20("USD Coin", "USDC");
        weth = new DemoERC20("Wrapped Ether", "WETH");
        console2.log("  USDC:", address(usdc));
        console2.log("  WETH:", address(weth));

        // Configure cross-references
        restaking.addSlasher(tangleProxy);
        restaking.addSlasher(slasher);
        restaking.setTangle(tangleProxy);
        Tangle(payable(tangleProxy)).setOperatorStatusRegistry(address(statusRegistry));
        Tangle(payable(tangleProxy)).setTntToken(address(tnt));
        restaking.enableAsset(address(tnt), 1 ether, 7, 0, 10_000);
        restaking.setOperatorBondToken(address(tnt));

        // Deploy and configure MBSM
        MasterBlueprintServiceManager masterManager = new MasterBlueprintServiceManager(admin, tangleProxy);
        MBSMRegistry registryImpl = new MBSMRegistry();
        ERC1967Proxy registryProxy =
            new ERC1967Proxy(address(registryImpl), abi.encodeCall(MBSMRegistry.initialize, (admin)));
        MBSMRegistry registry = MBSMRegistry(address(registryProxy));
        registry.grantRole(registry.MANAGER_ROLE(), tangleProxy);
        registry.addVersion(address(masterManager));
        Tangle(payable(address(tangle))).setMBSMRegistry(address(registry));

        vm.stopBroadcast();

        console2.log("[Setup] Contracts deployed");
    }

    function _setupTokens() internal {
        vm.startBroadcast(ADMIN_KEY);

        // Enable assets in restaking
        restaking.enableAsset(address(usdc), 100e18, 10e18, 0, 10000);
        restaking.enableAsset(address(weth), 0.1 ether, 0.01 ether, 0, 10000);

        // Distribute TNT to operators for incentives
        for (uint256 i = 0; i < operators.length; i++) {
            tnt.transfer(operators[i], 10_000 ether);
        }

        // Distribute tokens to delegators
        for (uint256 i = 0; i < delegators.length; i++) {
            usdc.mint(delegators[i], 100_000e18);
            weth.mint(delegators[i], 100 ether);
        }

        vm.stopBroadcast();

        console2.log("[Setup] Tokens distributed");
    }

    function _registerOperatorsInRestaking() internal {
        console2.log("[Setup] Registering operators in restaking...");

        for (uint256 i = 0; i < operators.length; i++) {
            uint256 stake = 5 ether + (i * 1 ether); // Varying stakes

            vm.startBroadcast(operatorKeys[i]);
            restaking.registerOperator{value: stake}();
            vm.stopBroadcast();

            console2.log("  Operator registered with stake:", stake / 1e18);
        }
    }

    function _createBlueprints() internal {
        console2.log("[Setup] Creating blueprints...");

        vm.startBroadcast(ADMIN_KEY);

        string[3] memory names = ["Compute Blueprint", "Storage Blueprint", "Oracle Blueprint"];
        string[3] memory uris =
            ["ipfs://QmCompute123", "ipfs://QmStorage456", "ipfs://QmOracle789"];

        for (uint256 i = 0; i < NUM_BLUEPRINTS; i++) {
            Types.BlueprintDefinition memory def = _blueprintDefinition(uris[i], address(0));
            def.config.membership = Types.MembershipModel.Dynamic;
            def.config.minOperators = 1;
            def.config.maxOperators = 0; // unlimited

            uint64 bpId = tangle.createBlueprint(def);
            blueprintIds.push(bpId);
            console2.log("  Created blueprint", bpId, "-", names[i]);
        }

        vm.stopBroadcast();
    }

    function _registerOperatorsForBlueprints() internal {
        console2.log("[Setup] Registering operators for blueprints...");

        for (uint256 i = 0; i < operators.length; i++) {
            vm.startBroadcast(operatorKeys[i]);

            // Each operator registers for 1-3 blueprints
            uint256 numBlueprints = (i % 3) + 1;

            for (uint256 j = 0; j < numBlueprints && j < blueprintIds.length; j++) {
                bytes memory ecdsaKey = _generateOperatorKey(i, j);
                string memory rpcUrl = string(abi.encodePacked("http://operator", vm.toString(i), ".local:854", vm.toString(j)));

                tangle.registerOperator(blueprintIds[j], ecdsaKey, rpcUrl);
                console2.log("  Operator", i, "registered for blueprint", blueprintIds[j]);
            }

            vm.stopBroadcast();
        }
    }

    function _createServices() internal {
        console2.log("[Setup] Creating services...");

        vm.startBroadcast(ADMIN_KEY);

        for (uint256 i = 0; i < NUM_SERVICES; i++) {
            uint64 blueprintId = blueprintIds[i % blueprintIds.length];

            // Get operators registered for this blueprint (simplified: use first 2-3)
            uint256 numOps = (i % 2) + 2;
            address[] memory serviceOps = new address[](numOps);
            for (uint256 j = 0; j < numOps; j++) {
                serviceOps[j] = operators[j % operators.length];
            }

            address[] memory permittedCallers = new address[](0);

            uint64 requestId = tangle.requestService(
                blueprintId,
                serviceOps,
                abi.encode("config", i),
                permittedCallers,
                0, // No TTL
                address(0), // Native payment
                0
            );

            vm.stopBroadcast();

            // Operators approve
            for (uint256 j = 0; j < numOps; j++) {
                vm.startBroadcast(operatorKeys[j % operators.length]);
                tangle.approveService(requestId, uint8(50 + (j * 10))); // 50-70% exposure
                vm.stopBroadcast();
            }

            serviceIds.push(requestId);
            console2.log("  Created service", requestId, "on blueprint", blueprintId);

            vm.startBroadcast(ADMIN_KEY);
        }

        vm.stopBroadcast();
    }

    function _initialDelegations() internal {
        console2.log("[Setup] Initial delegations...");

        for (uint256 i = 0; i < delegators.length; i++) {
            vm.startBroadcast(delegatorKeys[i]);

            // Each delegator delegates to 1-2 operators
            uint256 numDelegations = (i % 2) + 1;
            uint256 amountPerDelegation = 2 ether + (i * 0.5 ether);

            for (uint256 j = 0; j < numDelegations; j++) {
                address op = operators[(i + j) % operators.length];
                restaking.depositAndDelegate{value: amountPerDelegation}(op);
                totalDelegations++;
            }

            vm.stopBroadcast();
        }

        console2.log("  Completed", totalDelegations, "initial delegations");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SIMULATION TICK
    // ═══════════════════════════════════════════════════════════════════════════

    function _executeTick(uint256 tick) internal {
        // Every tick: submit a job
        _submitJob(tick);

        // Every 2 ticks: submit job results
        if (tick % 2 == 1) {
            _submitResults(tick);
        }

        // Every 3 ticks: new delegation
        if (tick % 3 == 0) {
            _newDelegation(tick);
        }

        // Every 4 ticks: deposit tokens
        if (tick % 4 == 0) {
            _depositTokens(tick);
        }

        // Every 5 ticks: heartbeat
        if (tick % 5 == 0) {
            _submitHeartbeats(tick);
        }

        // Every 7 ticks: advance restaking round
        if (tick % 7 == 0) {
            _advanceRound();
        }

        // Every 10 ticks: schedule unstake
        if (tick % 10 == 0) {
            _scheduleUnstake(tick);
        }

        // Every 15 ticks: distribute rewards
        if (tick % 15 == 0) {
            _distributeRewards(tick);
        }

        // Every 20 ticks: slash event
        if (tick % 20 == 0 && tick > 0) {
            _proposeSlash(tick);
        }

        // Every 25 ticks: execute pending unstakes
        if (tick % 25 == 0) {
            _executeUnstakes();
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // ACTIVITY FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    function _submitJob(uint256 tick) internal {
        uint64 serviceId = serviceIds[tick % serviceIds.length];
        bytes memory inputs = abi.encode("job_input", tick, block.timestamp);

        vm.startBroadcast(ADMIN_KEY);
        try tangle.submitJob(serviceId, 0, inputs) returns (uint64 callId) {
            serviceCallIds[serviceId] = callId;
            totalJobs++;
        } catch {}
        vm.stopBroadcast();
    }

    function _submitResults(uint256 tick) internal {
        uint64 serviceId = serviceIds[tick % serviceIds.length];
        uint64 callId = serviceCallIds[serviceId];

        if (callId == 0) return;

        // Random operator submits result
        uint256 opIndex = tick % operators.length;

        vm.startBroadcast(operatorKeys[opIndex]);
        try tangle.submitResult(serviceId, callId, abi.encode("result", tick)) {} catch {}
        vm.stopBroadcast();
    }

    function _newDelegation(uint256 tick) internal {
        uint256 delegatorIndex = tick % delegators.length;
        uint256 operatorIndex = (tick / 3) % operators.length;
        uint256 amount = 0.5 ether + ((tick % 10) * 0.1 ether);

        vm.startBroadcast(delegatorKeys[delegatorIndex]);
        try restaking.depositAndDelegate{value: amount}(operators[operatorIndex]) {
            totalDelegations++;
            totalDeposits++;
        } catch {}
        vm.stopBroadcast();
    }

    function _depositTokens(uint256 tick) internal {
        uint256 delegatorIndex = tick % delegators.length;
        uint256 operatorIndex = (tick / 4) % operators.length;

        vm.startBroadcast(delegatorKeys[delegatorIndex]);

        // Alternate between USDC and WETH
        if (tick % 8 < 4) {
            uint256 amount = 100e18 + (tick * 10e18);
            try usdc.approve(address(restaking), amount) {} catch {}
            try restaking.depositAndDelegateWithOptions(
                operators[operatorIndex],
                address(usdc),
                amount,
                Types.BlueprintSelectionMode.All,
                new uint64[](0)
            ) {
                totalDeposits++;
                totalDelegations++;
            } catch {}
        } else {
            uint256 amount = 0.1 ether + (tick * 0.01 ether);
            try weth.approve(address(restaking), amount) {} catch {}
            try restaking.depositAndDelegateWithOptions(
                operators[operatorIndex],
                address(weth),
                amount,
                Types.BlueprintSelectionMode.All,
                new uint64[](0)
            ) {
                totalDeposits++;
                totalDelegations++;
            } catch {}
        }

        vm.stopBroadcast();
    }

    function _submitHeartbeats(uint256 tick) internal {
        uint64 serviceId = serviceIds[tick % serviceIds.length];
        uint64 blueprintId = blueprintIds[tick % blueprintIds.length];

        for (uint256 i = 0; i < operators.length; i++) {
            vm.startBroadcast(operatorKeys[i]);

            bytes memory metrics = abi.encode("cpu", 50 + (tick % 50), "mem", 60 + (tick % 40));
            bytes32 messageHash = keccak256(abi.encodePacked(serviceId, blueprintId, metrics));
            bytes32 ethSignedHash = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash));
            (uint8 v, bytes32 r, bytes32 s) = vm.sign(operatorKeys[i], ethSignedHash);
            bytes memory signature = abi.encodePacked(r, s, v);

            try statusRegistry.submitHeartbeat(serviceId, blueprintId, 0, metrics, signature) {
                totalHeartbeats++;
            } catch {}

            vm.stopBroadcast();
        }
    }

    function _advanceRound() internal {
        vm.startBroadcast(ADMIN_KEY);
        try restaking.advanceRound() {} catch {}
        vm.stopBroadcast();
    }

    function _scheduleUnstake(uint256 tick) internal {
        uint256 delegatorIndex = tick % delegators.length;
        uint256 operatorIndex = (tick / 10) % operators.length;

        vm.startBroadcast(delegatorKeys[delegatorIndex]);
        try restaking.scheduleDelegatorUnstake(operators[operatorIndex], address(0), 0.1 ether) {} catch {}
        vm.stopBroadcast();
    }

    function _executeUnstakes() internal {
        for (uint256 i = 0; i < delegators.length; i++) {
            vm.startBroadcast(delegatorKeys[i]);
            try restaking.executeDelegatorUnstake() {} catch {}
            vm.stopBroadcast();
        }
    }

    function _distributeRewards(uint256 tick) internal {
        uint256 operatorIndex = tick % operators.length;
        uint256 rewardAmount = 0.1 ether + (tick * 0.01 ether);

        // Fund restaking contract for rewards
        vm.deal(address(restaking), address(restaking).balance + rewardAmount);

        vm.startBroadcast(ADMIN_KEY);
        // Restaking-native rewards removed; service fee rewards flow via ServiceFeeDistributor on billing.
        vm.stopBroadcast();
    }

    function _proposeSlash(uint256 tick) internal {
        uint64 serviceId = serviceIds[tick % serviceIds.length];
        uint256 operatorIndex = (tick / 20) % operators.length;
        uint256 slashAmount = 0.1 ether;
        bytes32 evidence = keccak256(abi.encodePacked("slash_evidence", tick));
        uint256 stake = restaking.getOperatorStake(operators[operatorIndex]);
        uint16 slashBps = stake == 0 ? 0 : uint16((slashAmount * 10_000) / stake);
        if (slashBps > 10_000) slashBps = 10_000;

        vm.startBroadcast(SLASHER_KEY);
        try tangle.proposeSlash(serviceId, operators[operatorIndex], slashBps, evidence) {
            totalSlashes++;
        } catch {}
        vm.stopBroadcast();
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // HELPERS
    // ═══════════════════════════════════════════════════════════════════════════

    function _generateOperatorKey(uint256 opIndex, uint256 bpIndex) internal pure returns (bytes memory) {
        // Generate a 65-byte uncompressed ECDSA public key (0x04 prefix + 64 bytes)
        bytes32 part1 = keccak256(abi.encodePacked("operator_key", opIndex, bpIndex, uint256(1)));
        bytes32 part2 = keccak256(abi.encodePacked("operator_key", opIndex, bpIndex, uint256(2)));
        return abi.encodePacked(bytes1(0x04), part1, part2);
    }

    function _logProgress() internal view {
        console2.log("--- Tick", currentTick + 1, "of", TOTAL_TICKS);
        console2.log("    Jobs:", totalJobs, "Deposits:", totalDeposits);
        console2.log("    Delegations:", totalDelegations, "Heartbeats:", totalHeartbeats);
    }

    function _logFinalStats() internal view {
        console2.log("\n========================================");
        console2.log("   SIMULATION COMPLETE");
        console2.log("========================================");
        console2.log("Total Ticks:", TOTAL_TICKS);
        console2.log("Total Jobs Submitted:", totalJobs);
        console2.log("Total Deposits:", totalDeposits);
        console2.log("Total Delegations:", totalDelegations);
        console2.log("Total Heartbeats:", totalHeartbeats);
        console2.log("Total Slashes:", totalSlashes);
        console2.log("========================================");
        console2.log("\nContract Addresses:");
        console2.log("  Tangle:", address(tangle));
        console2.log("  MultiAssetDelegation:", address(restaking));
        console2.log("  OperatorStatusRegistry:", address(statusRegistry));
        console2.log("  TNT Token:", address(tnt));
        console2.log("  USDC:", address(usdc));
        console2.log("  WETH:", address(weth));
        console2.log("\nBlueprint IDs:", blueprintIds.length);
        console2.log("Service IDs:", serviceIds.length);
        console2.log("========================================\n");
    }
}

/// @title DemoSimulationContinuous
/// @notice Version that runs indefinitely until stopped
/// @dev Run with: forge script script/v2/DemoSimulation.s.sol:DemoSimulationContinuous --rpc-url http://127.0.0.1:8545 --broadcast
contract DemoSimulationContinuous is DemoSimulation {
    function run() external override {
        console2.log("\n");
        console2.log("========================================");
        console2.log("   TANGLE CONTINUOUS DEMO SIMULATION");
        console2.log("========================================");
        console2.log("Running indefinitely - press Ctrl+C to stop");
        console2.log("========================================\n");

        _initializeActors();
        _fundActors();
        _deployContracts();
        _setupTokens();
        _registerOperatorsInRestaking();
        _createBlueprints();
        _registerOperatorsForBlueprints();
        _createServices();
        _initialDelegations();

        console2.log("\n=== SETUP COMPLETE - STARTING CONTINUOUS SIMULATION ===\n");

        // Run forever
        uint256 tick = 0;
        while (true) {
            currentTick = tick;
            _executeTick(tick);

            vm.warp(block.timestamp + TICK_INTERVAL);

            if (tick % 10 == 9) {
                _logProgress();
            }

            tick++;

            // Prevent overflow
            if (tick > type(uint128).max) {
                tick = 0;
            }
        }
    }
}
