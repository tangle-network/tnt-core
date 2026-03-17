// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { BaseTest } from "../BaseTest.sol";
import { MockERC20 } from "../MockERC20.sol";
import { MockVAnchor } from "./MockVAnchor.sol";
import { ShieldedGateway } from "../../src/shielded/ShieldedGateway.sol";
import { IShieldedGateway } from "../../src/shielded/IShieldedGateway.sol";
import { Types } from "../../src/libraries/Types.sol";
import { CommonExtData, PublicInputs, Encryptions } from "protocol-solidity/structs/PublicInputs.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title ShieldedGatewayTest
/// @notice Tests the ShieldedGateway integration between VAnchor pools and tnt-core.
///         Uses a MockVAnchor that skips ZK proofs — the real VAnchorTree is already audited.
///         These tests validate: pool registration, withdrawal-to-service flow, access control,
///         and that the gateway never retains funds.
contract ShieldedGatewayTest is BaseTest {
    ShieldedGateway public gateway;
    MockVAnchor public mockPool;
    MockERC20 public wrappedToken;

    address public gatewayOwner = makeAddr("gatewayOwner");
    address public anonymousUser = makeAddr("anonymousUser");
    address public ephemeralKey = makeAddr("ephemeralKey");

    uint256 public constant POOL_LIQUIDITY = 1000 ether;
    uint256 public constant SERVICE_PAYMENT = 10 ether;

    function setUp() public override {
        super.setUp();

        // Deploy wrapped token (simulates FungibleTokenWrapper from protocol-solidity)
        wrappedToken = new MockERC20();

        // Deploy mock VAnchor pool with the wrapped token
        mockPool = new MockVAnchor(address(wrappedToken));

        // Fund the mock pool (simulates prior deposits by anonymous users)
        wrappedToken.mint(address(mockPool), POOL_LIQUIDITY);

        // Deploy the gateway (credits address can be zero for gateway-only tests)
        gateway = new ShieldedGateway(address(tangle), address(0), gatewayOwner);

        // Register the pool
        vm.prank(gatewayOwner);
        gateway.registerPool(address(wrappedToken), address(mockPool));

        // Register operators for a blueprint
        _registerOperator(operator1);
        _registerOperator(operator2);
    }

    // ═══════════════════════════════════════════════════════════════════════
    // POOL MANAGEMENT
    // ═══════════════════════════════════════════════════════════════════════

    function test_registerPool() public view {
        assertEq(gateway.getPool(address(wrappedToken)), address(mockPool));
    }

    function test_registerPool_onlyOwner() public {
        MockERC20 otherToken = new MockERC20();
        vm.prank(anonymousUser);
        vm.expectRevert();
        gateway.registerPool(address(otherToken), address(mockPool));
    }

    function test_registerPool_noDuplicate() public {
        vm.prank(gatewayOwner);
        vm.expectRevert(abi.encodeWithSelector(IShieldedGateway.PoolAlreadyRegistered.selector, address(wrappedToken)));
        gateway.registerPool(address(wrappedToken), address(mockPool));
    }

    function test_unregisteredPool_reverts() public {
        address fakeToken = makeAddr("fakeToken");
        vm.expectRevert(abi.encodeWithSelector(IShieldedGateway.PoolNotRegistered.selector, fakeToken));
        gateway.shieldedFundService(_anchorProof(fakeToken, SERVICE_PAYMENT, 1), 0);
    }

    // ═══════════════════════════════════════════════════════════════════════
    // SHIELDED REQUEST SERVICE
    // ═══════════════════════════════════════════════════════════════════════

    function test_shieldedRequestService() public {
        uint64 blueprintId = _createBlueprint(developer);
        _registerForBlueprint(operator1, blueprintId);

        address[] memory ops = new address[](1);
        ops[0] = operator1;

        // Use an ephemeral key as permitted caller (privacy: not linked to depositor)
        address[] memory callers = new address[](1);
        callers[0] = ephemeralKey;

        IShieldedGateway.ServiceRequestParams memory params = IShieldedGateway.ServiceRequestParams({
            blueprintId: blueprintId,
            operators: ops,
            config: "",
            permittedCallers: callers,
            ttl: 0,
            confidentiality: Types.ConfidentialityPolicy.Any
        });

        uint64 requestId =
            gateway.shieldedRequestService(_anchorProof(address(wrappedToken), SERVICE_PAYMENT, 1), params);

        // Service request was created
        assertTrue(requestId >= 0);

        // Gateway holds no tokens (atomic flow)
        assertEq(wrappedToken.balanceOf(address(gateway)), 0);

        // tnt-core received the payment
        assertEq(wrappedToken.balanceOf(address(tangle)), SERVICE_PAYMENT);

        // Pool liquidity decreased
        assertEq(wrappedToken.balanceOf(address(mockPool)), POOL_LIQUIDITY - SERVICE_PAYMENT);
    }

    // ═══════════════════════════════════════════════════════════════════════
    // SHIELDED FUND SERVICE
    // ═══════════════════════════════════════════════════════════════════════

    function test_shieldedFundService() public {
        // First create a service normally with a subscription model
        uint64 serviceId;
        {
            Types.BlueprintConfig memory config;
            config.pricing = Types.PricingModel.Subscription;
            config.subscriptionRate = 1 ether;
            config.subscriptionInterval = 30 days;
            uint64 blueprintId = _createBlueprintWithConfig(developer, address(0), config);

            _registerForBlueprint(operator1, blueprintId);

            address[] memory ops = new address[](1);
            ops[0] = operator1;
            address[] memory callers = new address[](0);

            wrappedToken.mint(user1, 5 ether);
            vm.startPrank(user1);
            wrappedToken.approve(address(tangle), 5 ether);
            uint64 requestId = tangle.requestService(
                blueprintId, ops, "", callers, 0, address(wrappedToken), 5 ether, Types.ConfidentialityPolicy.Any
            );
            vm.stopPrank();

            vm.prank(operator1);
            tangle.approveService(requestId, 0);
            serviceId = tangle.serviceCount() - 1;
        }

        uint256 tangleBefore = wrappedToken.balanceOf(address(tangle));

        // Fund the service anonymously via shielded gateway
        gateway.shieldedFundService(_anchorProof(address(wrappedToken), SERVICE_PAYMENT, 2), serviceId);

        // tnt-core received additional funding
        assertEq(wrappedToken.balanceOf(address(tangle)), tangleBefore + SERVICE_PAYMENT);

        // Gateway holds nothing
        assertEq(wrappedToken.balanceOf(address(gateway)), 0);
    }

    // ═══════════════════════════════════════════════════════════════════════
    // EDGE CASES
    // ═══════════════════════════════════════════════════════════════════════

    function test_invalidSpendAmount_reverts() public {
        // Positive extAmount (deposit, not withdrawal) should revert
        CommonExtData memory extData = CommonExtData({
            recipient: address(gateway),
            extAmount: int256(SERVICE_PAYMENT), // positive = deposit
            relayer: address(0),
            fee: 0,
            refund: 0,
            token: address(wrappedToken)
        });

        IShieldedGateway.VAnchorProof memory proof = IShieldedGateway.VAnchorProof({
            proof: _dummyProof(),
            auxPublicInputs: _dummyAux(),
            externalData: abi.encode(extData),
            publicInputs: abi.encode(_dummyPublicInputs(3)),
            encryptions: abi.encode(_dummyEncryptions())
        });

        vm.expectRevert(IShieldedGateway.InvalidSpendAmount.selector);
        gateway.shieldedFundService(proof, 0);
    }

    function test_wrongRecipient_reverts() public {
        CommonExtData memory extData = CommonExtData({
            recipient: anonymousUser, // wrong - must be gateway
            extAmount: -int256(SERVICE_PAYMENT),
            relayer: address(0),
            fee: 0,
            refund: 0,
            token: address(wrappedToken)
        });

        IShieldedGateway.VAnchorProof memory proof = IShieldedGateway.VAnchorProof({
            proof: _dummyProof(),
            auxPublicInputs: _dummyAux(),
            externalData: abi.encode(extData),
            publicInputs: abi.encode(_dummyPublicInputs(4)),
            encryptions: abi.encode(_dummyEncryptions())
        });

        vm.expectRevert(IShieldedGateway.InvalidRecipient.selector);
        gateway.shieldedFundService(proof, 0);
    }

    function test_nullifierReplay_reverts() public {
        uint64 blueprintId = _createBlueprint(developer);
        _registerForBlueprint(operator1, blueprintId);

        address[] memory ops = new address[](1);
        ops[0] = operator1;
        address[] memory callers = new address[](0);

        IShieldedGateway.ServiceRequestParams memory params = IShieldedGateway.ServiceRequestParams({
            blueprintId: blueprintId,
            operators: ops,
            config: "",
            permittedCallers: callers,
            ttl: 0,
            confidentiality: Types.ConfidentialityPolicy.Any
        });

        // Same nullifier seed = same nullifiers
        IShieldedGateway.VAnchorProof memory anchorProof = _anchorProof(address(wrappedToken), SERVICE_PAYMENT, 100);

        // First spend works
        gateway.shieldedRequestService(anchorProof, params);

        // Same nullifiers again = double spend
        vm.expectRevert("MockVAnchor: nullifier spent");
        gateway.shieldedRequestService(anchorProof, params);
    }

    function test_gatewayNeverRetainsFunds_multipleOps() public {
        uint64 blueprintId = _createBlueprint(developer);
        _registerForBlueprint(operator1, blueprintId);

        address[] memory ops = new address[](1);
        ops[0] = operator1;
        address[] memory callers = new address[](0);

        IShieldedGateway.ServiceRequestParams memory params = IShieldedGateway.ServiceRequestParams({
            blueprintId: blueprintId,
            operators: ops,
            config: "",
            permittedCallers: callers,
            ttl: 0,
            confidentiality: Types.ConfidentialityPolicy.Any
        });

        // Multiple shielded requests
        for (uint256 i = 10; i < 15; i++) {
            gateway.shieldedRequestService(_anchorProof(address(wrappedToken), 1 ether, i), params);
            // Gateway balance is always 0 after each operation
            assertEq(wrappedToken.balanceOf(address(gateway)), 0);
        }

        // Total drained from pool
        assertEq(wrappedToken.balanceOf(address(mockPool)), POOL_LIQUIDITY - 5 ether);
    }

    // ═══════════════════════════════════════════════════════════════════════
    // HELPERS
    // ═══════════════════════════════════════════════════════════════════════

    function _anchorProof(
        address token,
        uint256 amount,
        uint256 nullifierSeed
    )
        internal
        view
        returns (IShieldedGateway.VAnchorProof memory)
    {
        CommonExtData memory extData = CommonExtData({
            recipient: address(gateway),
            extAmount: -int256(amount),
            relayer: address(0),
            fee: 0,
            refund: 0,
            token: token
        });

        return IShieldedGateway.VAnchorProof({
            proof: _dummyProof(),
            auxPublicInputs: _dummyAux(),
            externalData: abi.encode(extData),
            publicInputs: abi.encode(_dummyPublicInputs(nullifierSeed)),
            encryptions: abi.encode(_dummyEncryptions())
        });
    }

    function _dummyProof() internal pure returns (bytes memory) {
        return new bytes(256);
    }

    function _dummyAux() internal pure returns (bytes memory) {
        return new bytes(0);
    }

    function _dummyPublicInputs(uint256 nullifierSeed) internal pure returns (PublicInputs memory) {
        uint256[] memory nullifiers = new uint256[](2);
        nullifiers[0] = uint256(keccak256(abi.encodePacked("nullifier0", nullifierSeed)));
        nullifiers[1] = uint256(keccak256(abi.encodePacked("nullifier1", nullifierSeed)));

        return PublicInputs({
            roots: new bytes(64),
            extensionRoots: new bytes(0),
            inputNullifiers: nullifiers,
            outputCommitments: [uint256(0), uint256(0)],
            publicAmount: 0,
            extDataHash: 0
        });
    }

    function _dummyEncryptions() internal pure returns (Encryptions memory) {
        return Encryptions({ encryptedOutput1: new bytes(0), encryptedOutput2: new bytes(0) });
    }
}
