// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test, console2 } from "forge-std/Test.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import { Tangle } from "../../src/v2/Tangle.sol";
import { MultiAssetDelegation } from "../../src/v2/restaking/MultiAssetDelegation.sol";
import { Types } from "../../src/v2/libraries/Types.sol";
import { Errors } from "../../src/v2/libraries/Errors.sol";
import { IBlueprintServiceManager } from "../../src/v2/interfaces/IBlueprintServiceManager.sol";

/// @title BaseTest
/// @notice Base test contract with common setup for v2 tests
abstract contract BaseTest is Test {
    // Contracts
    Tangle public tangle;
    MultiAssetDelegation public restaking;

    // Proxies
    ERC1967Proxy public tangleProxy;
    ERC1967Proxy public restakingProxy;

    // Actors
    address public admin = makeAddr("admin");
    address public treasury = makeAddr("treasury");
    address public developer = makeAddr("developer");
    address public operator1 = makeAddr("operator1");
    address public operator2 = makeAddr("operator2");
    address public operator3 = makeAddr("operator3");
    address public delegator1 = makeAddr("delegator1");
    address public delegator2 = makeAddr("delegator2");
    address public user1 = makeAddr("user1");
    address public user2 = makeAddr("user2");

    // Constants
    uint256 public constant MIN_OPERATOR_STAKE = 1 ether;
    uint256 public constant MIN_DELEGATION = 0.1 ether;
    uint16 public constant OPERATOR_COMMISSION_BPS = 1000; // 10%

    function setUp() public virtual {
        // Deploy implementations
        Tangle tangleImpl = new Tangle();
        MultiAssetDelegation restakingImpl = new MultiAssetDelegation();

        // Deploy restaking proxy
        restakingProxy = new ERC1967Proxy(
            address(restakingImpl),
            abi.encodeCall(
                MultiAssetDelegation.initialize,
                (admin, MIN_OPERATOR_STAKE, MIN_DELEGATION, OPERATOR_COMMISSION_BPS)
            )
        );
        restaking = MultiAssetDelegation(payable(address(restakingProxy)));

        // Deploy tangle proxy
        tangleProxy = new ERC1967Proxy(
            address(tangleImpl),
            abi.encodeCall(
                Tangle.initialize,
                (admin, address(restaking), payable(treasury))
            )
        );
        tangle = Tangle(payable(address(tangleProxy)));

        // Setup: grant slasher role to tangle
        vm.prank(admin);
        restaking.addSlasher(address(tangle));

        // Fund actors
        vm.deal(operator1, 100 ether);
        vm.deal(operator2, 100 ether);
        vm.deal(operator3, 100 ether);
        vm.deal(delegator1, 100 ether);
        vm.deal(delegator2, 100 ether);
        vm.deal(user1, 100 ether);
        vm.deal(user2, 100 ether);
        vm.deal(developer, 100 ether);
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // HELPERS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Register an operator with minimum stake
    function _registerOperator(address operator) internal {
        vm.prank(operator);
        restaking.registerOperator{ value: MIN_OPERATOR_STAKE }();
    }

    /// @notice Register an operator with custom stake
    function _registerOperator(address operator, uint256 stake) internal {
        vm.prank(operator);
        restaking.registerOperator{ value: stake }();
    }

    /// @notice Create a blueprint and return its ID
    function _createBlueprint(address owner) internal returns (uint64) {
        vm.prank(owner);
        return tangle.createBlueprint("ipfs://metadata", address(0));
    }

    /// @notice Create a blueprint with service manager
    function _createBlueprint(address owner, address manager) internal returns (uint64) {
        vm.prank(owner);
        return tangle.createBlueprint("ipfs://metadata", manager);
    }

    /// @notice Register operator for a blueprint
    function _registerForBlueprint(address operator, uint64 blueprintId) internal {
        vm.prank(operator);
        tangle.registerOperator(blueprintId, hex"04", "http://localhost:8545"); // dummy ecdsa key prefix and RPC
    }

    /// @notice Request a service with single operator
    function _requestService(
        address requester,
        uint64 blueprintId,
        address operator
    ) internal returns (uint64) {
        address[] memory operators = new address[](1);
        operators[0] = operator;
        address[] memory callers = new address[](0);

        vm.prank(requester);
        return tangle.requestService(blueprintId, operators, "", callers, 0, address(0), 0);
    }

    /// @notice Request a service with payment
    function _requestServiceWithPayment(
        address requester,
        uint64 blueprintId,
        address operator,
        uint256 payment
    ) internal returns (uint64) {
        address[] memory operators = new address[](1);
        operators[0] = operator;
        address[] memory callers = new address[](0);

        vm.prank(requester);
        return tangle.requestService{ value: payment }(
            blueprintId, operators, "", callers, 0, address(0), payment
        );
    }

    /// @notice Approve a service request
    function _approveService(address operator, uint64 requestId) internal {
        vm.prank(operator);
        tangle.approveService(requestId, 0);
    }
}
