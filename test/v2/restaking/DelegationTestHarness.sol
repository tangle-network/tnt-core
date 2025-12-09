// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import { Test } from "forge-std/Test.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { ERC1967Proxy } from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

import { MultiAssetDelegation } from "../../../src/v2/restaking/MultiAssetDelegation.sol";
import { Types } from "../../../src/v2/libraries/Types.sol";

// ═══════════════════════════════════════════════════════════════════════════════
// MOCK CONTRACTS
// ═══════════════════════════════════════════════════════════════════════════════

/// @notice Standard Mock ERC20 for testing
contract MockERC20 is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) external {
        _burn(from, amount);
    }
}

/// @notice Malicious ERC20 that reenters on transfer
contract ReentrantERC20 is ERC20 {
    MultiAssetDelegation public target;
    bool public attackOnTransferOut;
    bool public attackExecuted;
    bytes public attackCalldata;

    constructor() ERC20("ReentrantToken", "REENT") {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

    function setTarget(address _target) external {
        target = MultiAssetDelegation(payable(_target));
    }

    function setAttack(bool _attack, bytes calldata _calldata) external {
        attackOnTransferOut = _attack;
        attackCalldata = _calldata;
        attackExecuted = false;
    }

    function _update(address from, address to, uint256 amount) internal override {
        super._update(from, to, amount);

        // Attack on transfer OUT from contract (during withdraw)
        if (attackOnTransferOut && from == address(target) && to != address(0) && !attackExecuted) {
            attackExecuted = true;
            // Try the specified attack
            (bool success,) = address(target).call(attackCalldata);
            // Silently handle - we're just checking if reentry works
            success; // silence warning
        }
    }
}

/// @notice Malicious receiver that reenters on native ETH receive
contract ReentrantReceiver {
    MultiAssetDelegation public target;
    bool public attackEnabled;
    bool public attackExecuted;
    uint256 public receiveCount;
    bytes public attackCalldata;

    constructor(address _target) {
        target = MultiAssetDelegation(payable(_target));
    }

    function setAttack(bool _attack, bytes calldata _calldata) external {
        attackEnabled = _attack;
        attackCalldata = _calldata;
        attackExecuted = false;
    }

    receive() external payable {
        receiveCount++;
        if (attackEnabled && !attackExecuted) {
            attackExecuted = true;
            // Try to reenter
            (bool success,) = address(target).call(attackCalldata);
            success; // silence warning
        }
    }

    // Forward calls to target for testing
    function deposit() external payable {
        target.deposit{value: msg.value}();
    }

    function depositAndDelegate(address operator) external payable {
        target.depositAndDelegate{value: msg.value}(operator);
    }

    function scheduleWithdraw(address token, uint256 amount) external {
        target.scheduleWithdraw(token, amount);
    }

    function executeWithdraw() external {
        target.executeWithdraw();
    }

    function scheduleDelegatorUnstake(address operator, address token, uint256 amount) external {
        target.scheduleDelegatorUnstake(operator, token, amount);
    }

    function executeDelegatorUnstake() external {
        target.executeDelegatorUnstake();
    }
}

/// @notice ERC20 that fails on transfer (for testing failure handling)
contract FailingERC20 is ERC20 {
    bool public shouldFail;

    constructor() ERC20("FailingToken", "FAIL") {}

    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

    function setShouldFail(bool _fail) external {
        shouldFail = _fail;
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        if (shouldFail) return false;
        return super.transfer(to, amount);
    }

    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        if (shouldFail) return false;
        return super.transferFrom(from, to, amount);
    }
}

// ═══════════════════════════════════════════════════════════════════════════════
// BASE TEST HARNESS
// ═══════════════════════════════════════════════════════════════════════════════

/// @title DelegationTestHarness
/// @notice Base test contract with common setup, utilities and assertions
abstract contract DelegationTestHarness is Test {
    // ═══════════════════════════════════════════════════════════════════════════
    // STATE
    // ═══════════════════════════════════════════════════════════════════════════

    MultiAssetDelegation public delegation;
    MockERC20 public token;
    MockERC20 public token2;

    // Addresses
    address public admin;
    address public slasher;
    address public operator1;
    address public operator2;
    address public operator3;
    address public delegator1;
    address public delegator2;
    address public delegator3;

    // Default configuration
    uint256 public constant MIN_OPERATOR_STAKE = 1 ether;
    uint256 public constant MIN_DELEGATION = 0.1 ether;
    uint64 public constant DEFAULT_DELAY = 7;
    uint16 public constant OPERATOR_COMMISSION_BPS = 1000; // 10%

    // Precision
    uint256 public constant PRECISION = 1e18;
    uint256 public constant BPS_DENOMINATOR = 10000;

    // ═══════════════════════════════════════════════════════════════════════════
    // SETUP
    // ═══════════════════════════════════════════════════════════════════════════

    function setUp() public virtual {
        _createActors();
        _deployContracts();
        _configureAssets();
        _fundAccounts();
        _registerDefaultOperator();
    }

    function _createActors() internal {
        admin = makeAddr("admin");
        slasher = makeAddr("slasher");
        operator1 = makeAddr("operator1");
        operator2 = makeAddr("operator2");
        operator3 = makeAddr("operator3");
        delegator1 = makeAddr("delegator1");
        delegator2 = makeAddr("delegator2");
        delegator3 = makeAddr("delegator3");
    }

    function _deployContracts() internal {
        // Deploy delegation contract
        MultiAssetDelegation impl = new MultiAssetDelegation();
        bytes memory initData = abi.encodeCall(
            MultiAssetDelegation.initialize,
            (admin, MIN_OPERATOR_STAKE, 0, OPERATOR_COMMISSION_BPS)
        );
        ERC1967Proxy proxy = new ERC1967Proxy(address(impl), initData);
        delegation = MultiAssetDelegation(payable(address(proxy)));

        // Deploy mock tokens
        token = new MockERC20("MockToken", "MCK");
        token2 = new MockERC20("MockToken2", "MCK2");
    }

    function _configureAssets() internal {
        vm.startPrank(admin);
        // Enable ERC20 tokens
        delegation.enableAsset(address(token), MIN_OPERATOR_STAKE, MIN_DELEGATION, 0, 10000);
        delegation.enableAsset(address(token2), MIN_OPERATOR_STAKE, MIN_DELEGATION, 0, 10000);
        // Add slasher
        delegation.addSlasher(slasher);
        vm.stopPrank();
    }

    function _fundAccounts() internal {
        // Fund operators
        vm.deal(operator1, 1000 ether);
        vm.deal(operator2, 1000 ether);
        vm.deal(operator3, 1000 ether);

        // Fund delegators - native
        vm.deal(delegator1, 1000 ether);
        vm.deal(delegator2, 1000 ether);
        vm.deal(delegator3, 1000 ether);

        // Fund delegators - ERC20
        token.mint(delegator1, 1000 ether);
        token.mint(delegator2, 1000 ether);
        token.mint(delegator3, 1000 ether);
        token2.mint(delegator1, 1000 ether);
        token2.mint(delegator2, 1000 ether);
        token2.mint(delegator3, 1000 ether);
    }

    function _registerDefaultOperator() internal {
        vm.prank(operator1);
        delegation.registerOperator{value: 10 ether}();
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // HELPER FUNCTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Register an operator with specified stake
    function _registerOperator(address operator, uint256 stake) internal {
        vm.prank(operator);
        delegation.registerOperator{value: stake}();
    }

    /// @notice Deposit and delegate native ETH
    function _depositAndDelegate(address delegator, address operator, uint256 amount) internal {
        vm.prank(delegator);
        delegation.depositAndDelegate{value: amount}(operator);
    }

    /// @notice Deposit and delegate ERC20
    function _depositAndDelegateErc20(
        address delegator,
        address operator,
        address tokenAddr,
        uint256 amount
    ) internal {
        vm.startPrank(delegator);
        ERC20(tokenAddr).approve(address(delegation), amount);
        delegation.depositAndDelegateWithOptions(
            operator,
            tokenAddr,
            amount,
            Types.BlueprintSelectionMode.All,
            new uint64[](0)
        );
        vm.stopPrank();
    }

    /// @notice Deposit native ETH only (no delegation)
    function _depositNative(address delegator, uint256 amount) internal {
        vm.prank(delegator);
        delegation.deposit{value: amount}();
    }

    /// @notice Deposit native ETH with lock
    function _depositNativeWithLock(address delegator, uint256 amount, Types.LockMultiplier lock) internal {
        vm.prank(delegator);
        delegation.depositWithLock{value: amount}(lock);
    }

    /// @notice Deposit ERC20 only (no delegation)
    function _depositErc20(address delegator, address tokenAddr, uint256 amount) internal {
        vm.startPrank(delegator);
        ERC20(tokenAddr).approve(address(delegation), amount);
        delegation.depositERC20(tokenAddr, amount);
        vm.stopPrank();
    }

    /// @notice Schedule delegator unstake
    function _scheduleUnstake(address delegator, address operator, address tokenAddr, uint256 amount) internal {
        vm.prank(delegator);
        delegation.scheduleDelegatorUnstake(operator, tokenAddr, amount);
    }

    /// @notice Execute delegator unstake
    function _executeUnstake(address delegator) internal {
        vm.prank(delegator);
        delegation.executeDelegatorUnstake();
    }

    /// @notice Schedule withdraw
    function _scheduleWithdraw(address delegator, address tokenAddr, uint256 amount) internal {
        vm.prank(delegator);
        delegation.scheduleWithdraw(tokenAddr, amount);
    }

    /// @notice Execute withdraw
    function _executeWithdraw(address delegator) internal {
        vm.prank(delegator);
        delegation.executeWithdraw();
    }

    /// @notice Advance rounds
    function _advanceRounds(uint64 count) internal {
        for (uint64 i = 0; i < count; i++) {
            delegation.advanceRound();
        }
    }

    /// @notice Slash operator
    function _slash(address operator, uint256 amount) internal {
        vm.prank(slasher);
        delegation.slash(operator, 0, amount, keccak256("evidence"));
    }

    /// @notice Slash operator with specific evidence
    function _slashWithEvidence(address operator, uint256 amount, bytes32 evidence) internal {
        vm.prank(slasher);
        delegation.slash(operator, 0, amount, evidence);
    }

    /// @notice Pause contract
    function _pause() internal {
        vm.prank(admin);
        delegation.pause();
    }

    /// @notice Unpause contract
    function _unpause() internal {
        vm.prank(admin);
        delegation.unpause();
    }

    /// @notice Get delegation amount (convenience wrapper)
    function _getDelegation(address delegator, address operator) internal view returns (uint256) {
        return delegation.getDelegation(delegator, operator);
    }

    /// @notice Get deposit (convenience wrapper)
    function _getDeposit(address delegator, address tokenAddr) internal view returns (Types.Deposit memory) {
        return delegation.getDeposit(delegator, tokenAddr);
    }

    /// @notice Add rewards to operator (simulates reward distribution)
    function _addRewards(address operator, uint256 amount) internal {
        vm.deal(address(delegation), address(delegation).balance + amount);
        delegation.notifyReward(operator, 0, amount);
    }

    /// @notice Calculate expected slashing impact proportionally
    function _calculateSlashImpact(
        uint256 slashAmount,
        uint256 operatorStake,
        uint256 delegatedStake
    ) internal pure returns (uint256 operatorSlash, uint256 delegatorSlash) {
        uint256 totalStake = operatorStake + delegatedStake;
        if (totalStake == 0) return (0, 0);
        operatorSlash = (slashAmount * operatorStake) / totalStake;
        delegatorSlash = slashAmount - operatorSlash;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // ASSERTIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /// @notice Assert delegation equals expected (with tolerance for rounding)
    function assertDelegationEq(address delegator, address operator, uint256 expected) internal view {
        uint256 actual = _getDelegation(delegator, operator);
        assertEq(actual, expected, "Delegation mismatch");
    }

    /// @notice Assert delegation is approximately equal (within 1 wei for rounding)
    function assertDelegationApproxEq(address delegator, address operator, uint256 expected, uint256 tolerance) internal view {
        uint256 actual = _getDelegation(delegator, operator);
        assertApproxEqAbs(actual, expected, tolerance, "Delegation approx mismatch");
    }

    /// @notice Assert operator is active
    function assertOperatorActive(address operator) internal view {
        assertTrue(delegation.isOperatorActive(operator), "Operator should be active");
    }

    /// @notice Assert operator is not active
    function assertOperatorNotActive(address operator) internal view {
        assertFalse(delegation.isOperatorActive(operator), "Operator should not be active");
    }

    /// @notice Assert operator is registered
    function assertOperatorRegistered(address operator) internal view {
        assertTrue(delegation.isOperator(operator), "Operator should be registered");
    }

    /// @notice Assert deposit amount
    function assertDepositEq(address delegator, address tokenAddr, uint256 expected) internal view {
        Types.Deposit memory dep = _getDeposit(delegator, tokenAddr);
        assertEq(dep.amount, expected, "Deposit amount mismatch");
    }

    /// @notice Assert delegated amount in deposit
    function assertDelegatedAmountEq(address delegator, address tokenAddr, uint256 expected) internal view {
        Types.Deposit memory dep = _getDeposit(delegator, tokenAddr);
        assertEq(dep.delegatedAmount, expected, "Delegated amount mismatch");
    }
}
