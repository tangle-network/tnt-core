// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console2} from "forge-std/Script.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import { IMultiAssetDelegation } from "../../src/v2/interfaces/IMultiAssetDelegation.sol";
import { MultiAssetDelegation } from "../../src/v2/staking/MultiAssetDelegation.sol";
import { Types } from "../../src/v2/libraries/Types.sol";
import { StakingOperatorsFacet } from "../../src/v2/facets/staking/StakingOperatorsFacet.sol";
import { StakingDepositsFacet } from "../../src/v2/facets/staking/StakingDepositsFacet.sol";
import { StakingDelegationsFacet } from "../../src/v2/facets/staking/StakingDelegationsFacet.sol";
import { StakingSlashingFacet } from "../../src/v2/facets/staking/StakingSlashingFacet.sol";
import { StakingAssetsFacet } from "../../src/v2/facets/staking/StakingAssetsFacet.sol";
import { StakingViewsFacet } from "../../src/v2/facets/staking/StakingViewsFacet.sol";
import { StakingAdminFacet } from "../../src/v2/facets/staking/StakingAdminFacet.sol";

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
///         Optionally set FULLSTACK_MNEMONIC to match the mnemonic used by your RPC node.
///         For local RPC time advances, set FULLSTACK_USE_FFI=1 and pass --ffi (uses cast rpc).
///         Use FULLSTACK_RPC_URL to override the RPC URL used for time advances.
contract FullStackScenario is Script {
    string internal constant MNEMONIC_ENV = "FULLSTACK_MNEMONIC";

    uint256 internal adminKey;
    uint256 internal slasherKey;
    uint256 internal operator1Key;
    uint256 internal operator2Key;
    uint256 internal operator3Key;
    uint256 internal delegator1Key;
    uint256 internal delegator2Key;
    uint256 internal delegator3Key;

    uint64 internal constant DEFAULT_DELAY = 7;
    uint16 internal constant COMMISSION_BPS = 1000; // 10%

    uint256 internal constant ITERATIONS = 12;

    IMultiAssetDelegation public delegation;
    ScenarioERC20 public tokenA;
    ScenarioERC20 public tokenB;

    address[] public delegators;
    address[] public operators;
    uint256[] public delegatorKeys;
    uint256[] public operatorKeys;

    function run() external {
        _initKeys();
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

    function _initKeys() internal {
        string memory mnemonic = _envStringOrEmpty(MNEMONIC_ENV);
        if (bytes(mnemonic).length == 0) {
            adminKey = uint256(keccak256("admin"));
            slasherKey = uint256(keccak256("slasher"));
            operator1Key = uint256(keccak256("operator1"));
            operator2Key = uint256(keccak256("operator2"));
            operator3Key = uint256(keccak256("operator3"));
            delegator1Key = uint256(keccak256("delegator1"));
            delegator2Key = uint256(keccak256("delegator2"));
            delegator3Key = uint256(keccak256("delegator3"));
            return;
        }

        adminKey = vm.deriveKey(mnemonic, 0);
        slasherKey = vm.deriveKey(mnemonic, 1);
        operator1Key = vm.deriveKey(mnemonic, 2);
        operator2Key = vm.deriveKey(mnemonic, 3);
        operator3Key = vm.deriveKey(mnemonic, 4);
        delegator1Key = vm.deriveKey(mnemonic, 5);
        delegator2Key = vm.deriveKey(mnemonic, 6);
        delegator3Key = vm.deriveKey(mnemonic, 7);
    }

    function _labelActors() internal {
        vm.label(vm.addr(adminKey), "admin");
        vm.label(vm.addr(slasherKey), "slasher");
        vm.label(vm.addr(operator1Key), "operator1");
        vm.label(vm.addr(operator2Key), "operator2");
        vm.label(vm.addr(operator3Key), "operator3");
        vm.label(vm.addr(delegator1Key), "delegator1");
        vm.label(vm.addr(delegator2Key), "delegator2");
        vm.label(vm.addr(delegator3Key), "delegator3");

        delegators = [vm.addr(delegator1Key), vm.addr(delegator2Key), vm.addr(delegator3Key)];
        operators = [vm.addr(operator1Key), vm.addr(operator2Key), vm.addr(operator3Key)];
        delegatorKeys = [delegator1Key, delegator2Key, delegator3Key];
        operatorKeys = [operator1Key, operator2Key, operator3Key];
    }

    function _fundActors() internal {
        uint256[8] memory keys = [
            adminKey,
            slasherKey,
            operator1Key,
            operator2Key,
            operator3Key,
            delegator1Key,
            delegator2Key,
            delegator3Key
        ];
        for (uint256 i = 0; i < keys.length; i++) {
            vm.deal(vm.addr(keys[i]), 1_000 ether);
        }
    }

    function _deployContracts() internal {
        vm.startBroadcast(adminKey);

        MultiAssetDelegation impl = new MultiAssetDelegation();
        bytes memory initData = abi.encodeCall(
            MultiAssetDelegation.initialize,
            (vm.addr(adminKey), 1 ether, DEFAULT_DELAY, COMMISSION_BPS)
        );
        ERC1967Proxy proxy = new ERC1967Proxy(address(impl), initData);
        _registerFacets(address(proxy));
        delegation = IMultiAssetDelegation(payable(address(proxy)));

        tokenA = new ScenarioERC20("Scenario Token A", "STA");
        tokenB = new ScenarioERC20("Scenario Token B", "STB");

        delegation.enableAsset(address(tokenA), 1 ether, 0.1 ether, 0, 10000);
        delegation.enableAsset(address(tokenB), 1 ether, 0.1 ether, 0, 10000);
        delegation.addSlasher(vm.addr(slasherKey));

        vm.stopBroadcast();
    }

    function _registerFacets(address proxy) internal {
        MultiAssetDelegation router = MultiAssetDelegation(payable(proxy));
        router.registerFacet(address(new StakingOperatorsFacet()));
        router.registerFacet(address(new StakingDepositsFacet()));
        router.registerFacet(address(new StakingDelegationsFacet()));
        router.registerFacet(address(new StakingSlashingFacet()));
        router.registerFacet(address(new StakingAssetsFacet()));
        router.registerFacet(address(new StakingViewsFacet()));
        router.registerFacet(address(new StakingAdminFacet()));
    }

    function _seedTokens() internal {
        vm.startBroadcast(adminKey);
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
            vm.startBroadcast(adminKey);
            // Restaking-native rewards removed; service fee rewards flow via ServiceFeeDistributor on billing.
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

        _advanceRound();
    }

    function _finalizeExits() internal {
        for (uint64 i = 0; i < 12; i++) {
            _advanceRound();
        }

        for (uint256 i = 0; i < delegators.length; i++) {
            vm.startBroadcast(delegatorKeys[i]);
            delegation.executeDelegatorUnstake();
            delegation.executeWithdraw();
            vm.stopBroadcast();
        }
    }

    function _advanceRound() internal {
        uint64 duration = delegation.roundDuration();
        uint64 lastAdvance = MultiAssetDelegation(payable(address(delegation))).lastRoundAdvance();

        if (lastAdvance != 0) {
            uint64 nextAllowed = lastAdvance + duration;
            if (block.timestamp < nextAllowed) {
                uint256 current = block.timestamp;
                uint256 delta = nextAllowed - current;
                vm.warp(nextAllowed);
                _rpcAdvanceTime(delta);
            }
        }

        vm.startBroadcast(adminKey);
        delegation.advanceRound();
        vm.stopBroadcast();
    }

    function _rpcAdvanceTime(uint256 delta) internal {
        if (delta == 0) {
            return;
        }
        if (!vm.envOr("FULLSTACK_USE_FFI", false)) {
            return;
        }
        string memory rpcUrl = _rpcUrlOrEmpty();
        if (bytes(rpcUrl).length == 0) {
            return;
        }
        _ffiAdvanceTime(rpcUrl, delta);
    }

    function _ffiAdvanceTime(string memory rpcUrl, uint256 delta) internal {
        string[] memory increase = new string[](6);
        increase[0] = "cast";
        increase[1] = "rpc";
        increase[2] = "--rpc-url";
        increase[3] = rpcUrl;
        increase[4] = "evm_increaseTime";
        increase[5] = vm.toString(delta);
        vm.ffi(increase);

        string[] memory mine = new string[](5);
        mine[0] = "cast";
        mine[1] = "rpc";
        mine[2] = "--rpc-url";
        mine[3] = rpcUrl;
        mine[4] = "evm_mine";
        vm.ffi(mine);
    }

    function _rpcUrlOrEmpty() internal view returns (string memory url) {
        string memory envOverride = _envStringOrEmpty("FULLSTACK_RPC_URL");
        if (bytes(envOverride).length != 0) {
            return envOverride;
        }
        try vm.rpcUrl("default") returns (string memory configured) {
            url = configured;
        } catch {
            url = "";
        }
    }

    function _envStringOrEmpty(string memory key) internal view returns (string memory value) {
        try vm.envString(key) returns (string memory raw) {
            value = raw;
        } catch {
            value = "";
        }
    }
}
