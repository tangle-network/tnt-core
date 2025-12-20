// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console2} from "forge-std/Script.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import { IMultiAssetDelegation } from "../../src/v2/interfaces/IMultiAssetDelegation.sol";
import { MultiAssetDelegation } from "../../src/v2/restaking/MultiAssetDelegation.sol";
import { Types } from "../../src/v2/libraries/Types.sol";
import { RestakingOperatorsFacet } from "../../src/v2/facets/restaking/RestakingOperatorsFacet.sol";
import { RestakingDepositsFacet } from "../../src/v2/facets/restaking/RestakingDepositsFacet.sol";
import { RestakingDelegationsFacet } from "../../src/v2/facets/restaking/RestakingDelegationsFacet.sol";
import { RestakingRewardsFacet } from "../../src/v2/facets/restaking/RestakingRewardsFacet.sol";
import { RestakingSlashingFacet } from "../../src/v2/facets/restaking/RestakingSlashingFacet.sol";
import { RestakingAssetsFacet } from "../../src/v2/facets/restaking/RestakingAssetsFacet.sol";
import { RestakingViewsFacet } from "../../src/v2/facets/restaking/RestakingViewsFacet.sol";
import { RestakingAdminFacet } from "../../src/v2/facets/restaking/RestakingAdminFacet.sol";

contract ScenarioERC20 {
    string public name;
    string public symbol;
    uint8 public constant decimals = 18;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }

    function mint(address to, uint256 amount) external {
        balanceOf[to] += amount;
        emit Transfer(address(0), to, amount);
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        uint256 allowed = allowance[from][msg.sender];
        require(allowed >= amount, "insufficient allowance");
        allowance[from][msg.sender] = allowed - amount;
        _transfer(from, to, amount);
        return true;
    }

    function _transfer(address from, address to, uint256 amount) internal {
        require(balanceOf[from] >= amount, "insufficient balance");
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        emit Transfer(from, to, amount);
    }
}

/// @notice Forge script that replays the full stack scenario on a live RPC (e.g., anvil).
///         Run with: `forge script script/v2/FullStackScenario.s.sol:FullStackScenario --rpc-url http://127.0.0.1:8545 --broadcast --slow`
contract FullStackScenario is Script {
    uint256 internal constant ADMIN_KEY = uint256(keccak256("admin"));
    uint256 internal constant SLASHER_KEY = uint256(keccak256("slasher"));
    uint256 internal constant OPERATOR1_KEY = uint256(keccak256("operator1"));
    uint256 internal constant OPERATOR2_KEY = uint256(keccak256("operator2"));
    uint256 internal constant OPERATOR3_KEY = uint256(keccak256("operator3"));
    uint256 internal constant DELEGATOR1_KEY = uint256(keccak256("delegator1"));
    uint256 internal constant DELEGATOR2_KEY = uint256(keccak256("delegator2"));
    uint256 internal constant DELEGATOR3_KEY = uint256(keccak256("delegator3"));

    uint64 internal constant DEFAULT_DELAY = 7;
    uint16 internal constant COMMISSION_BPS = 1000; // 10%

    uint256 internal constant ITERATIONS = 12;
    uint256 internal constant STEP_SECONDS = 5;

    IMultiAssetDelegation public delegation;
    ScenarioERC20 public tokenA;
    ScenarioERC20 public tokenB;

    address[] public delegators;
    address[] public operators;
    uint256[] public delegatorKeys;
    uint256[] public operatorKeys;

    function run() external {
        _labelActors();
        _fundActors();
        _deployContracts();
        _seedTokens();
        _registerOperators();

        for (uint256 tick = 0; tick < ITERATIONS; tick++) {
            _executeTick(tick);
        }

        _finalizeExits();

        console2.log("Scenario complete. Delegation:", address(delegation));
        console2.log("Token A:", address(tokenA));
        console2.log("Token B:", address(tokenB));
    }

    function _labelActors() internal {
        vm.label(vm.addr(ADMIN_KEY), "admin");
        vm.label(vm.addr(SLASHER_KEY), "slasher");
        vm.label(vm.addr(OPERATOR1_KEY), "operator1");
        vm.label(vm.addr(OPERATOR2_KEY), "operator2");
        vm.label(vm.addr(OPERATOR3_KEY), "operator3");
        vm.label(vm.addr(DELEGATOR1_KEY), "delegator1");
        vm.label(vm.addr(DELEGATOR2_KEY), "delegator2");
        vm.label(vm.addr(DELEGATOR3_KEY), "delegator3");

        delegators = [vm.addr(DELEGATOR1_KEY), vm.addr(DELEGATOR2_KEY), vm.addr(DELEGATOR3_KEY)];
        operators = [vm.addr(OPERATOR1_KEY), vm.addr(OPERATOR2_KEY), vm.addr(OPERATOR3_KEY)];
        delegatorKeys = [DELEGATOR1_KEY, DELEGATOR2_KEY, DELEGATOR3_KEY];
        operatorKeys = [OPERATOR1_KEY, OPERATOR2_KEY, OPERATOR3_KEY];
    }

    function _fundActors() internal {
        uint256[8] memory keys = [
            ADMIN_KEY,
            SLASHER_KEY,
            OPERATOR1_KEY,
            OPERATOR2_KEY,
            OPERATOR3_KEY,
            DELEGATOR1_KEY,
            DELEGATOR2_KEY,
            DELEGATOR3_KEY
        ];
        for (uint256 i = 0; i < keys.length; i++) {
            vm.deal(vm.addr(keys[i]), 1_000 ether);
        }
    }

    function _deployContracts() internal {
        vm.startBroadcast(ADMIN_KEY);

        MultiAssetDelegation impl = new MultiAssetDelegation();
        bytes memory initData = abi.encodeCall(
            MultiAssetDelegation.initialize,
            (vm.addr(ADMIN_KEY), 1 ether, DEFAULT_DELAY, COMMISSION_BPS)
        );
        ERC1967Proxy proxy = new ERC1967Proxy(address(impl), initData);
        _registerFacets(address(proxy));
        delegation = IMultiAssetDelegation(payable(address(proxy)));

        tokenA = new ScenarioERC20("Scenario Token A", "STA");
        tokenB = new ScenarioERC20("Scenario Token B", "STB");

        delegation.enableAsset(address(tokenA), 1 ether, 0.1 ether, 0, 10000);
        delegation.enableAsset(address(tokenB), 1 ether, 0.1 ether, 0, 10000);
        delegation.addSlasher(vm.addr(SLASHER_KEY));

        vm.stopBroadcast();
    }

    function _registerFacets(address proxy) internal {
        MultiAssetDelegation router = MultiAssetDelegation(payable(proxy));
        router.registerFacet(address(new RestakingOperatorsFacet()));
        router.registerFacet(address(new RestakingDepositsFacet()));
        router.registerFacet(address(new RestakingDelegationsFacet()));
        router.registerFacet(address(new RestakingRewardsFacet()));
        router.registerFacet(address(new RestakingSlashingFacet()));
        router.registerFacet(address(new RestakingAssetsFacet()));
        router.registerFacet(address(new RestakingViewsFacet()));
        router.registerFacet(address(new RestakingAdminFacet()));
    }

    function _seedTokens() internal {
        vm.startBroadcast(ADMIN_KEY);
        for (uint256 i = 0; i < delegators.length; i++) {
            tokenA.mint(delegators[i], 1_000 ether);
            tokenB.mint(delegators[i], 1_000 ether);
        }
        vm.stopBroadcast();
    }

    function _registerOperators() internal {
        for (uint256 i = 0; i < operators.length; i++) {
            vm.startBroadcast(operatorKeys[i]);
            delegation.registerOperator{value: 10 ether}();
            vm.stopBroadcast();
        }
    }

    function _executeTick(uint256 tick) internal {
        address delegator = delegators[tick % delegators.length];
        uint256 delegatorKey = delegatorKeys[tick % delegators.length];
        address operator = operators[tick % operators.length];
        uint256 amount = (tick + 1) * 0.2 ether;
        bool isNative = tick % 2 == 0;

        if (isNative) {
            vm.startBroadcast(delegatorKey);
            delegation.depositAndDelegate{value: amount}(operator);
            vm.stopBroadcast();
        } else {
            ScenarioERC20 token = tick % 2 == 1 ? tokenA : tokenB;
            vm.startBroadcast(delegatorKey);
            token.approve(address(delegation), amount);
            delegation.depositAndDelegateWithOptions(
                operator,
                address(token),
                amount,
                Types.BlueprintSelectionMode.All,
                new uint64[](0)
            );
            vm.stopBroadcast();
        }

        if (tick % 3 == 0) {
            vm.deal(address(delegation), address(delegation).balance + 0.05 ether);
            vm.startBroadcast(ADMIN_KEY);
            delegation.notifyReward(operator, 0, 0.05 ether);
            vm.stopBroadcast();
        }

        if (tick % 4 == 3) {
            uint256 unstakeAmount = amount / 2;
            address tokenAddr = isNative ? address(0) : address((tick % 2 == 1) ? tokenA : tokenB);
            vm.startBroadcast(delegatorKey);
            delegation.scheduleDelegatorUnstake(operator, tokenAddr, unstakeAmount);
            vm.stopBroadcast();
        }

        if (tick % 5 == 4) {
            uint256 liquidAmount = amount / 2;
            vm.startBroadcast(delegatorKey);
            delegation.deposit{value: liquidAmount}();
            delegation.scheduleWithdraw(address(0), liquidAmount / 2);
            vm.stopBroadcast();
        }

        vm.warp(block.timestamp + STEP_SECONDS);
        vm.startBroadcast(ADMIN_KEY);
        delegation.advanceRound();
        vm.stopBroadcast();
    }

    function _finalizeExits() internal {
        vm.startBroadcast(ADMIN_KEY);
        for (uint64 i = 0; i < 12; i++) {
            delegation.advanceRound();
        }
        vm.stopBroadcast();

        for (uint256 i = 0; i < delegators.length; i++) {
            vm.startBroadcast(delegatorKeys[i]);
            delegation.executeDelegatorUnstake();
            delegation.executeWithdraw();
            vm.stopBroadcast();
        }
    }
}
