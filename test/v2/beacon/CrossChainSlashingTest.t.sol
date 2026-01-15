// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test, console2} from "forge-std/Test.sol";
import {L2SlashingConnector} from "../../../src/v2/beacon/L2SlashingConnector.sol";
import {L2SlashingReceiver, IL2Slasher} from "../../../src/v2/beacon/L2SlashingReceiver.sol";
import {TangleL2Slasher} from "../../../src/v2/beacon/TangleL2Slasher.sol";
import {ICrossChainMessenger, ICrossChainReceiver} from "../../../src/v2/beacon/interfaces/ICrossChainMessenger.sol";
import {ValidatorPodManager} from "../../../src/v2/beacon/ValidatorPodManager.sol";
import {MockBeaconOracle} from "../../../src/v2/beacon/BeaconRootReceiver.sol";
import { IRestaking } from "../../../src/v2/interfaces/IRestaking.sol";
import { Types } from "../../../src/v2/libraries/Types.sol";

/// @title MockCrossChainMessenger
/// @notice Mock messenger for testing cross-chain message flow
contract MockCrossChainMessenger is ICrossChainMessenger {
    struct Message {
        uint256 destinationChainId;
        address target;
        bytes payload;
        uint256 gasLimit;
        uint256 fee;
    }

    Message[] public messages;
    uint256 public messageCount;
    uint256 public mockFee = 0.001 ether;

    mapping(uint256 => bool) public supportedChains;

    constructor() {
        // Support common test chains
        supportedChains[1] = true;      // Ethereum
        supportedChains[8453] = true;   // Base
        supportedChains[42161] = true;  // Arbitrum
        supportedChains[5000] = true;   // Test chain (Tangle)
    }

    function sendMessage(
        uint256 destinationChainId,
        address target,
        bytes calldata payload,
        uint256 gasLimit
    ) external payable returns (bytes32 messageId) {
        require(supportedChains[destinationChainId], "Unsupported chain");
        require(msg.value >= mockFee, "Insufficient fee");

        messages.push(Message({
            destinationChainId: destinationChainId,
            target: target,
            payload: payload,
            gasLimit: gasLimit,
            fee: msg.value
        }));

        messageId = keccak256(abi.encode(messageCount++, destinationChainId, target, payload));
    }

    function estimateFee(
        uint256,
        bytes calldata,
        uint256
    ) external view returns (uint256 fee) {
        return mockFee;
    }

    function isChainSupported(uint256 chainId) external view returns (bool) {
        return supportedChains[chainId];
    }

    function setMockFee(uint256 _fee) external {
        mockFee = _fee;
    }

    function setSupportedChain(uint256 chainId, bool supported) external {
        supportedChains[chainId] = supported;
    }

    function getLastMessage() external view returns (Message memory) {
        require(messages.length > 0, "No messages");
        return messages[messages.length - 1];
    }

    /// @notice Simulate delivering a message to the receiver
    function deliverMessage(address receiver, uint256 sourceChainId, address sender) external {
        require(messages.length > 0, "No messages");
        Message memory msg_ = messages[messages.length - 1];

        // Call the receiver as if we're the bridge
        ICrossChainReceiver(receiver).receiveMessage(
            sourceChainId,
            sender,
            msg_.payload
        );
    }
}

/// @title MockRestaking
/// @notice Mock restaking contract for testing
contract MockRestaking is IRestaking {
    mapping(address => uint256) public operatorStakes;
    mapping(address => bool) public operators;
    mapping(address => bool) public slashers;

    uint256 public lastSlashAmount;
    address public lastSlashedOperator;
    bytes32 public lastSlashEvidence;

    function registerOperator(address operator, uint256 stake) external {
        operators[operator] = true;
        operatorStakes[operator] = stake;
    }

    function addSlasher(address slasher) external {
        slashers[slasher] = true;
    }

    function getOperatorStake(address operator) external view returns (uint256) {
        return operatorStakes[operator];
    }

    function isSlasher(address account) external view returns (bool) {
        return slashers[account];
    }

    function slash(
        address operator,
        uint64,
        uint16 slashBps,
        bytes32 evidence
    ) external returns (uint256 actualSlashed) {
        require(slashers[msg.sender], "Not a slasher");
        require(operators[operator], "Not an operator");

        uint256 available = operatorStakes[operator];
        uint256 amount = (available * slashBps) / 10_000;
        actualSlashed = amount > available ? available : amount;

        operatorStakes[operator] -= actualSlashed;
        lastSlashAmount = actualSlashed;
        lastSlashedOperator = operator;
        lastSlashEvidence = evidence;

        return actualSlashed;
    }

    function slashForBlueprint(
        address operator,
        uint64,
        uint64,
        uint16 slashBps,
        bytes32 evidence
    ) external returns (uint256 actualSlashed) {
        return this.slash(operator, 0, slashBps, evidence);
    }

    function slashForService(
        address operator,
        uint64,
        uint64,
        Types.AssetSecurityCommitment[] calldata,
        uint16 slashBps,
        bytes32 evidence
    ) external returns (uint256 actualSlashed) {
        return this.slash(operator, 0, slashBps, evidence);
    }

    // Other interface methods (not used in tests)
    function registerOperator(bytes calldata, bytes calldata) external {}
    function updateOperatorMetadata(bytes calldata) external {}
    function unregisterOperator() external {}
    function delegate(address, uint256) external {}
    function undelegate(address, uint256) external {}
    function notifyReward(address, uint64, uint256) external {}
    function notifyRewardForBlueprint(address, uint64, uint64, uint256) external {}
    function getOperatorDelegatedStake(address) external view returns (uint256) { return 0; }
    function getOperatorDelegatedStakeForAsset(address, Types.Asset calldata) external pure returns (uint256) { return 0; }
    function getOperatorStakeForAsset(address operator, Types.Asset calldata) external view returns (uint256) {
        return operatorStakes[operator];
    }

    // Additional interface methods
    function getDelegation(address, address) external pure returns (uint256) { return 0; }
    function getOperatorSelfStake(address operator) external view returns (uint256) { return operatorStakes[operator]; }
    function getTotalDelegation(address) external pure returns (uint256) { return 0; }
    function isOperator(address operator) external view returns (bool) { return operators[operator]; }
    function isOperatorActive(address operator) external view returns (bool) { return operators[operator]; }
    function meetsStakeRequirement(address operator, uint256 required) external view returns (bool) { return operatorStakes[operator] >= required; }
    function minOperatorStake() external pure returns (uint256) { return 1 ether; }
    function addBlueprintForOperator(address, uint64) external override {}
    function removeBlueprintForOperator(address, uint64) external override {}
}

/// @title CrossChainSlashingTest
/// @notice Tests for cross-chain slashing infrastructure
contract CrossChainSlashingTest is Test {
    // Contracts
    L2SlashingConnector public connector;
    L2SlashingReceiver public receiver;
    TangleL2Slasher public slasher;
    MockCrossChainMessenger public messenger;
    MockRestaking public restaking;
    ValidatorPodManager public podManager;
    MockBeaconOracle public beaconOracle;

    // Actors
    address public admin = makeAddr("admin");
    address public oracle = makeAddr("oracle");
    address public operator1 = makeAddr("operator1");
    address public pod1 = makeAddr("pod1");

    // Constants
    uint256 public constant TANGLE_CHAIN_ID = 5000;
    uint256 public constant ETH_CHAIN_ID = 1;
    uint256 public constant INITIAL_STAKE = 100 ether;

    function setUp() public {
        vm.deal(admin, 1000 ether);
        vm.deal(oracle, 100 ether);
        vm.deal(operator1, 100 ether);

        // Deploy beacon oracle
        beaconOracle = new MockBeaconOracle();

        // Deploy pod manager
        vm.prank(admin);
        podManager = new ValidatorPodManager(address(beaconOracle), 1 ether);

        // Register operator1 with pod manager so operatorDelegatedStake returns value
        vm.prank(operator1);
        podManager.registerOperator{value: 10 ether}();

        // Deploy mock messenger
        messenger = new MockCrossChainMessenger();

        // Deploy L1 connector
        vm.prank(admin);
        connector = new L2SlashingConnector(address(podManager), oracle);

        // Configure connector
        vm.startPrank(admin);
        connector.setMessenger(address(messenger));
        connector.setChainConfig(TANGLE_CHAIN_ID, makeAddr("l2Receiver"), 200_000, true);
        connector.setDefaultDestinationChain(TANGLE_CHAIN_ID);
        connector.registerPodOperator(pod1, operator1);
        vm.stopPrank();

        // Deploy mock restaking for L2
        restaking = new MockRestaking();
        restaking.registerOperator(operator1, INITIAL_STAKE);

        // Deploy L2 slasher
        vm.prank(admin);
        slasher = new TangleL2Slasher(address(restaking), admin);

        // Deploy L2 receiver
        receiver = new L2SlashingReceiver(address(slasher), address(messenger));

        // Configure L2 contracts
        vm.prank(admin);
        slasher.setAuthorizedCaller(address(receiver), true);

        restaking.addSlasher(address(slasher));

        // Authorize connector as sender for receiver
        receiver.setAuthorizedSender(ETH_CHAIN_ID, address(connector), true);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // L2SlashingConnector Tests
    // ═══════════════════════════════════════════════════════════════════════════

    function test_propagateBeaconSlashing_Success() public {
        // First slash: 100% (implicit) -> 90%
        uint64 newFactor = 0.9e18;  // 90% (10% slashed from initial 100%)

        vm.prank(oracle);
        connector.propagateBeaconSlashing{value: 0.01 ether}(pod1, newFactor);

        // Check message was sent
        assertEq(messenger.messageCount(), 1);

        // Check state was updated
        assertEq(connector.lastProcessedSlashingFactor(pod1), newFactor);
    }

    function test_propagateBeaconSlashing_RevertsForUnknownPod() public {
        address unknownPod = makeAddr("unknownPod");
        vm.prank(oracle);
        vm.expectRevert(abi.encodeWithSelector(L2SlashingConnector.UnknownPod.selector, unknownPod));
        connector.propagateBeaconSlashing{value: 0.01 ether}(unknownPod, 0.9e18);
    }

    function test_propagateBeaconSlashingToSpecificChain() public {
        uint256 altChainId = 8453;
        address altReceiver = makeAddr("altReceiver");

        vm.prank(admin);
        connector.setChainConfig(altChainId, altReceiver, 150_000, true);

        vm.prank(oracle);
        connector.propagateBeaconSlashingToChain{value: 0.01 ether}(pod1, 0.95e18, altChainId);

        MockCrossChainMessenger.Message memory msgAlt = messenger.getLastMessage();
        assertEq(msgAlt.destinationChainId, altChainId);
        assertEq(connector.lastProcessedSlashingFactor(pod1), 0.95e18);
    }

    function test_batchPropagateBeaconSlashing_MultiplePods() public {
        messenger.setMockFee(0); // simplify fee accounting for batch calls

        address pod2 = makeAddr("pod2");
        address operator2 = makeAddr("operator2");

        vm.prank(admin);
        connector.registerPodOperator(pod2, operator2);

        vm.mockCall(
            address(podManager),
            abi.encodeWithSelector(podManager.operatorDelegatedStake.selector, operator1),
            abi.encode(40 ether)
        );
        vm.mockCall(
            address(podManager),
            abi.encodeWithSelector(podManager.operatorDelegatedStake.selector, operator2),
            abi.encode(20 ether)
        );

        address[] memory pods = new address[](2);
        pods[0] = pod1;
        pods[1] = pod2;

        uint64[] memory newFactors = new uint64[](2);
        newFactors[0] = 0.9e18;
        newFactors[1] = 0.85e18;

        vm.prank(oracle);
        connector.batchPropagateBeaconSlashing(pods, newFactors);

        assertEq(connector.lastProcessedSlashingFactor(pod1), 0.9e18);
        assertEq(connector.lastProcessedSlashingFactor(pod2), 0.85e18);
        assertTrue(connector.cumulativeSlashAmount(pod1) > 0);
        assertTrue(connector.cumulativeSlashAmount(pod2) > 0);
    }

    function test_getPendingSlashAmountAndHasPending() public {
        vm.mockCall(
            address(podManager),
            abi.encodeWithSelector(podManager.operatorDelegatedStake.selector, operator1),
            abi.encode(40 ether)
        );

        vm.prank(oracle);
        connector.propagateBeaconSlashing{value: 0.01 ether}(pod1, 0.9e18);

        uint64 futureFactor = 0.8e18;
        uint256 delta = uint256(0.9e18 - futureFactor);
        uint256 slashPercentage = (delta * 1e18) / 0.9e18;
        uint256 expected = (40 ether * slashPercentage) / 1e18;

        uint256 pending = connector.getPendingSlashAmount(pod1, futureFactor);
        assertEq(pending, expected);
        assertTrue(connector.hasPendingSlashing(pod1, futureFactor));
        assertFalse(connector.hasPendingSlashing(pod1, 0.95e18));
    }

    function test_estimatePropagationFee_UsesMessengerQuote() public {
        uint256 quotedFee = messenger.mockFee();
        vm.mockCall(
            address(podManager),
            abi.encodeWithSelector(podManager.operatorDelegatedStake.selector, operator1),
            abi.encode(10 ether)
        );

        uint256 fee = connector.estimatePropagationFee(pod1, 0.95e18, TANGLE_CHAIN_ID);
        assertEq(fee, quotedFee);
    }

    function test_propagateBeaconSlashing_RevertUnauthorized() public {
        address random = makeAddr("random");
        vm.deal(random, 1 ether);
        vm.prank(random);
        vm.expectRevert(L2SlashingConnector.OnlySlashingOracle.selector);
        connector.propagateBeaconSlashing{value: 0.01 ether}(pod1, 0.9e18);
    }

    function test_propagateBeaconSlashing_RevertInvalidFactor() public {
        // First set up initial factor: 100% -> 90%
        vm.prank(oracle);
        connector.propagateBeaconSlashing{value: 0.01 ether}(pod1, 0.9e18);

        // Try to propagate a higher/equal factor (should revert)
        vm.prank(oracle);
        vm.expectRevert(L2SlashingConnector.InvalidSlashingFactor.selector);
        connector.propagateBeaconSlashing{value: 0.01 ether}(pod1, 0.95e18);
    }

    function test_propagateBeaconSlashing_RevertUnsupportedChain() public {
        // Disable chain
        vm.prank(admin);
        connector.setChainConfig(TANGLE_CHAIN_ID, address(0), 0, false);

        vm.expectRevert(L2SlashingConnector.UnsupportedDestinationChain.selector);
        vm.prank(oracle);
        connector.propagateBeaconSlashing{value: 0.01 ether}(pod1, 0.9e18);
    }

    function test_propagateBeaconSlashing_RevertMessengerNotConfigured() public {
        vm.prank(admin);
        connector.setMessenger(address(0));

        vm.startPrank(oracle);
        vm.expectRevert(L2SlashingConnector.MessengerNotConfigured.selector);
        connector.propagateBeaconSlashing{value: 0.01 ether}(pod1, 0.9e18);
        vm.stopPrank();
    }

    function test_propagateBeaconSlashing_RevertInsufficientFee() public {
        messenger.setMockFee(0.1 ether);

        vm.startPrank(oracle);
        vm.expectRevert(L2SlashingConnector.InsufficientFee.selector);
        connector.propagateBeaconSlashing{value: 0.01 ether}(pod1, 0.9e18);
        vm.stopPrank();
    }

    function test_batchPropagateBeaconSlashing_LengthMismatch() public {
        address[] memory pods = new address[](1);
        pods[0] = pod1;

        uint64[] memory factors = new uint64[](2);
        factors[0] = 0.95e18;
        factors[1] = 0.9e18;

        vm.startPrank(oracle);
        vm.expectRevert(bytes("Length mismatch"));
        connector.batchPropagateBeaconSlashing(pods, factors);
        vm.stopPrank();
    }

    function test_batchPropagateBeaconSlashing() public {
        address pod2 = makeAddr("pod2");
        address operator2 = makeAddr("operator2");

        vm.prank(admin);
        connector.registerPodOperator(pod2, operator2);

        // Set mock fee to 0 for batch testing (batch passes value: 0 internally)
        messenger.setMockFee(0);

        address[] memory pods = new address[](2);
        pods[0] = pod1;
        pods[1] = pod2;

        // Both factors must be less than initial 1e18
        uint64[] memory factors = new uint64[](2);
        factors[0] = 0.95e18;
        factors[1] = 0.9e18;

        vm.prank(oracle);
        connector.batchPropagateBeaconSlashing(pods, factors);

        // Both should have sent messages
        assertEq(messenger.messageCount(), 2);
    }

    function test_estimatePropagationFee() public {
        // First propagate to set up state
        vm.prank(oracle);
        connector.propagateBeaconSlashing{value: 0.01 ether}(pod1, 0.95e18);

        // Now estimate fee for next slash
        uint256 fee = connector.estimatePropagationFee(pod1, 0.9e18, TANGLE_CHAIN_ID);
        assertEq(fee, messenger.mockFee());
    }

    function test_batchRegisterPodOperators_LengthMismatch() public {
        address[] memory pods = new address[](1);
        address[] memory operators = new address[](2);

        vm.prank(admin);
        vm.expectRevert(bytes("Length mismatch"));
        connector.batchRegisterPodOperators(pods, operators);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // L2SlashingReceiver Tests
    // ═══════════════════════════════════════════════════════════════════════════

    function test_receiveMessage_Success() public {
        // Encode slash message
        bytes4 messageType = bytes4(keccak256("BEACON_SLASH"));
        uint16 slashBps = 1000;
        uint64 slashingFactor = 0.9e18;
        uint256 nonce = 0;

        bytes memory payload = abi.encodePacked(
            messageType,
            abi.encode(operator1, slashBps, slashingFactor, nonce, pod1)
        );

        // Deliver message as messenger
        vm.prank(address(messenger));
        receiver.receiveMessage(ETH_CHAIN_ID, address(connector), payload);

        // Check slash was executed
        assertEq(restaking.lastSlashedOperator(), operator1);
        assertEq(restaking.lastSlashAmount(), (INITIAL_STAKE * slashBps) / 10_000);
    }

    function test_receiveMessage_RevertUnauthorizedMessenger() public {
        bytes memory payload = abi.encodePacked(bytes4(keccak256("BEACON_SLASH")));

        vm.expectRevert(L2SlashingReceiver.UnauthorizedMessenger.selector);
        vm.prank(makeAddr("random"));
        receiver.receiveMessage(ETH_CHAIN_ID, address(connector), payload);
    }

    function test_receiveMessage_RevertUnauthorizedSender() public {
        bytes4 messageType = bytes4(keccak256("BEACON_SLASH"));
        bytes memory payload = abi.encodePacked(
            messageType,
            abi.encode(operator1, uint16(1000), 0.9e18, 0, pod1)
        );

        vm.expectRevert(L2SlashingReceiver.UnauthorizedSender.selector);
        vm.prank(address(messenger));
        receiver.receiveMessage(ETH_CHAIN_ID, makeAddr("badSender"), payload);
    }

    function test_receiveMessage_ReplayProtection() public {
        bytes4 messageType = bytes4(keccak256("BEACON_SLASH"));
        uint256 nonce = 42;
        uint16 slashBps = 1000;
        bytes memory payload = abi.encodePacked(
            messageType,
            abi.encode(operator1, slashBps, 0.9e18, nonce, pod1)
        );

        // First delivery works
        vm.prank(address(messenger));
        receiver.receiveMessage(ETH_CHAIN_ID, address(connector), payload);

        assertEq(restaking.lastSlashAmount(), (INITIAL_STAKE * slashBps) / 10_000);

        // Reset to check replay is ignored
        restaking.registerOperator(operator1, INITIAL_STAKE);

        // Second delivery with same nonce is silently ignored
        vm.prank(address(messenger));
        receiver.receiveMessage(ETH_CHAIN_ID, address(connector), payload);

        // Slash amount should still be from first call (no new slash)
        assertTrue(receiver.isNonceProcessed(ETH_CHAIN_ID, address(connector), nonce));
    }

    function test_receiveMessage_SkipsWhenSlashingPaused() public {
        vm.prank(admin);
        slasher.setPaused(true);

        bytes4 messageType = bytes4(keccak256("BEACON_SLASH"));
        bytes memory payload = abi.encodePacked(
            messageType,
            abi.encode(operator1, uint16(1000), 0.9e18, 0, pod1)
        );

        uint256 previousSlash = restaking.lastSlashAmount();
        vm.prank(address(messenger));
        receiver.receiveMessage(ETH_CHAIN_ID, address(connector), payload);

        assertEq(restaking.lastSlashAmount(), previousSlash, "Slashing should be skipped while paused");
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // TangleL2Slasher Tests
    // ═══════════════════════════════════════════════════════════════════════════

    function test_slashOperator_Success() public {
        uint16 slashBps = 1000;
        bytes memory reason = abi.encode("BEACON_CHAIN_SLASH", ETH_CHAIN_ID, pod1);

        vm.prank(address(receiver));
        slasher.slashOperator(operator1, slashBps, reason);

        uint256 expected = (INITIAL_STAKE * slashBps) / 10_000;
        assertEq(restaking.operatorStakes(operator1), INITIAL_STAKE - expected);
        assertEq(slasher.totalBeaconSlashed(operator1), expected);
    }

    function test_slashOperator_RevertUnauthorized() public {
        vm.expectRevert(TangleL2Slasher.UnauthorizedCaller.selector);
        vm.prank(makeAddr("random"));
        slasher.slashOperator(operator1, 1000, "");
    }

    function test_slashOperator_RevertWhenPaused() public {
        vm.prank(admin);
        slasher.setPaused(true);

        vm.expectRevert(TangleL2Slasher.SlashingPaused.selector);
        vm.prank(address(receiver));
        slasher.slashOperator(operator1, 1000, "");
    }

    function test_slashOperator_RevertZeroAmount() public {
        vm.expectRevert(TangleL2Slasher.ZeroAmount.selector);
        vm.prank(address(receiver));
        slasher.slashOperator(operator1, 0, "");
    }

    function test_canSlash() public {
        assertTrue(slasher.canSlash(operator1));

        address noStakeOperator = makeAddr("noStake");
        assertFalse(slasher.canSlash(noStakeOperator));
    }

    function test_getSlashableStake() public {
        assertEq(slasher.getSlashableStake(operator1), INITIAL_STAKE);
    }

    function test_slasher_setRestakingUpdatesReference() public {
        MockRestaking newRestaking = new MockRestaking();
        vm.prank(admin);
        slasher.setRestaking(address(newRestaking));
        assertEq(address(slasher.restaking()), address(newRestaking));
    }

    function test_slasher_getRemainingSlashableStake() public {
        uint256 beforeSlash = slasher.getRemainingSlashableStake(operator1);
        assertEq(beforeSlash, INITIAL_STAKE);

        vm.prank(address(receiver));
        slasher.slashOperator(operator1, 5000, "");

        uint256 total = slasher.getSlashableStake(operator1);
        uint256 already = slasher.totalBeaconSlashed(operator1);
        uint256 expected = total > already ? total - already : 0;
        assertEq(slasher.getRemainingSlashableStake(operator1), expected);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // End-to-End Tests
    // ═══════════════════════════════════════════════════════════════════════════

    function test_E2E_BeaconSlashingFlow() public {
        // Setup: Mock operatorDelegatedStake to return 50 ether
        vm.mockCall(
            address(podManager),
            abi.encodeWithSelector(podManager.operatorDelegatedStake.selector, operator1),
            abi.encode(50 ether)
        );

        // 1. Oracle detects beacon chain slashing and calls connector
        uint64 slashedFactor = 0.8e18;  // 80% (20% slashed)

        // 2. Propagate slashing
        vm.prank(oracle);
        connector.propagateBeaconSlashing{value: 0.01 ether}(pod1, slashedFactor);

        // 3. Get cross-chain message
        MockCrossChainMessenger.Message memory msg1 = messenger.getLastMessage();

        // Verify message was sent to correct chain
        assertEq(msg1.destinationChainId, TANGLE_CHAIN_ID);

        // 4. Simulate cross-chain delivery by calling receiver directly
        vm.prank(address(messenger));
        receiver.receiveMessage(ETH_CHAIN_ID, address(connector), msg1.payload);

        // 5. Verify slash was executed on L2
        assertTrue(slasher.hasBeenSlashed(operator1));
        assertTrue(slasher.totalBeaconSlashed(operator1) > 0);
    }

    function test_E2E_MultipleSlashings() public {
        // Setup: Mock operatorDelegatedStake to return 50 ether
        vm.mockCall(
            address(podManager),
            abi.encodeWithSelector(podManager.operatorDelegatedStake.selector, operator1),
            abi.encode(50 ether)
        );

        // First slash: 100% (implicit) -> 90%
        vm.prank(oracle);
        connector.propagateBeaconSlashing{value: 0.01 ether}(pod1, 0.9e18);

        MockCrossChainMessenger.Message memory msg1 = messenger.getLastMessage();
        vm.prank(address(messenger));
        receiver.receiveMessage(ETH_CHAIN_ID, address(connector), msg1.payload);

        uint256 firstSlashAmount = slasher.totalBeaconSlashed(operator1);
        assertTrue(firstSlashAmount > 0);

        // Second slash: 90% -> 80%
        vm.prank(oracle);
        connector.propagateBeaconSlashing{value: 0.01 ether}(pod1, 0.8e18);

        MockCrossChainMessenger.Message memory msg2 = messenger.getLastMessage();
        vm.prank(address(messenger));
        receiver.receiveMessage(ETH_CHAIN_ID, address(connector), msg2.payload);

        uint256 totalSlashed = slasher.totalBeaconSlashed(operator1);
        assertTrue(totalSlashed > firstSlashAmount);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // Admin Tests
    // ═══════════════════════════════════════════════════════════════════════════

    function test_connector_setChainConfig() public {
        uint256 newChainId = 12345;

        vm.prank(admin);
        connector.setChainConfig(newChainId, makeAddr("receiver"), 300_000, true);

        (address rcv, uint256 gas, bool enabled) = connector.chainConfigs(newChainId);
        assertEq(rcv, makeAddr("receiver"));
        assertEq(gas, 300_000);
        assertTrue(enabled);
    }

    function test_connector_setDefaultDestinationChain() public {
        uint256 newChainId = 7777;
        vm.prank(admin);
        connector.setDefaultDestinationChain(newChainId);
        assertEq(connector.defaultDestinationChainId(), newChainId);
    }

    function test_connector_batchRegisterPodOperators() public {
        address[] memory pods = new address[](2);
        pods[0] = makeAddr("batchPod1");
        pods[1] = makeAddr("batchPod2");

        address[] memory operators = new address[](2);
        operators[0] = makeAddr("batchOp1");
        operators[1] = makeAddr("batchOp2");

        vm.prank(admin);
        connector.batchRegisterPodOperators(pods, operators);

        assertEq(connector.podOperator(pods[0]), operators[0]);
        assertEq(connector.podOperator(pods[1]), operators[1]);
    }

    function test_connector_setSlashingOracle() public {
        address newOracle = makeAddr("newOracle");
        vm.prank(admin);
        connector.setSlashingOracle(newOracle);
        assertEq(connector.slashingOracle(), newOracle);
    }

    function test_connector_setMessenger() public {
        MockCrossChainMessenger newMessenger = new MockCrossChainMessenger();
        vm.prank(admin);
        connector.setMessenger(address(newMessenger));
        assertEq(address(connector.messenger()), address(newMessenger));
    }

    function test_connector_transferOwnership() public {
        address newOwner = makeAddr("newOwner");
        vm.prank(admin);
        connector.transferOwnership(newOwner);

        vm.prank(admin);
        vm.expectRevert("Only owner");
        connector.setChainConfig(999, makeAddr("fail"), 1, true);

        vm.prank(newOwner);
        connector.setChainConfig(999, makeAddr("ok"), 1, true);
        (address receiverAddr,,) = connector.chainConfigs(999);
        assertEq(receiverAddr, makeAddr("ok"));
    }

    function test_receiver_setAuthorizedSender() public {
        address newSender = makeAddr("newSender");

        receiver.setAuthorizedSender(ETH_CHAIN_ID, newSender, true);
        assertTrue(receiver.authorizedSenders(ETH_CHAIN_ID, newSender));

        receiver.setAuthorizedSender(ETH_CHAIN_ID, newSender, false);
        assertFalse(receiver.authorizedSenders(ETH_CHAIN_ID, newSender));
    }

    function test_slasher_setAuthorizedCaller() public {
        address newCaller = makeAddr("newCaller");

        vm.prank(admin);
        slasher.setAuthorizedCaller(newCaller, true);
        assertTrue(slasher.authorizedCallers(newCaller));
    }
}
