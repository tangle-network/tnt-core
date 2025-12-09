// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import {BlueprintHookBase} from "../../../src/v2/interfaces/IBlueprintHook.sol";
import {TokenizedBlueprintBase} from "../../../src/v2/extensions/TokenizedBlueprintBase.sol";
import {
    BuybackBlueprintBase,
    ISwapRouter,
    IWETH
} from "../../../src/v2/extensions/BuybackBlueprintBase.sol";
import {MockERC20} from "../../MockERC20.sol";

// ═════════════════════════════════════════════════════════════════════════════
// TEST HARNESS CONTRACTS
// ═════════════════════════════════════════════════════════════════════════════

contract BlueprintHookHarness is BlueprintHookBase {}

contract TokenizedBlueprintHarness is TokenizedBlueprintBase {
    constructor() TokenizedBlueprintBase("Harness Blueprint Token", "HBT") {}

    function bootstrap(uint64 blueprintId, address owner, address tangle) external {
        this.onBlueprintCreated(blueprintId, owner, tangle);
    }

    function mintToken(address to, uint256 amount) external {
        _mint(to, amount);
    }

    function setStreamingConfig(bool enabled, uint256 duration) external {
        _setStreamingMode(enabled);
        _setRewardDuration(duration);
    }

    function externalPayment(address token, uint256 amount) external {
        _onPaymentReceived(token, amount);
    }
}

contract MockWETH is ERC20("MockWETH", "MWETH"), IWETH {
    constructor() {}

    function deposit() external payable {
        _mint(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) external {
        _burn(msg.sender, amount);
        (bool ok,) = msg.sender.call{value: amount}("");
        require(ok, "ETH send failed");
    }

    function approve(address spender, uint256 amount) public override(IWETH, ERC20) returns (bool) {
        return super.approve(spender, amount);
    }

    function balanceOf(address account) public view override(IWETH, ERC20) returns (uint256) {
        return super.balanceOf(account);
    }
}

contract MockSwapRouter is ISwapRouter {
    using SafeERC20 for IERC20;

    ExactInputSingleParams public lastParams;
    uint256 public fixedAmountOut = 1 ether;
    bool public shouldRevert;

    function setFixedAmountOut(uint256 amount) external {
        fixedAmountOut = amount;
    }

    function setShouldRevert(bool flag) external {
        shouldRevert = flag;
    }

    function exactInputSingle(ExactInputSingleParams calldata params)
        external
        payable
        override
        returns (uint256 amountOut)
    {
        lastParams = params;
        if (shouldRevert) revert("swap failure");

        IERC20(params.tokenIn).safeTransferFrom(msg.sender, address(this), params.amountIn);

        if (fixedAmountOut < params.amountOutMinimum) {
            revert("slippage");
        }

        IERC20(params.tokenOut).safeTransfer(params.recipient, fixedAmountOut);
        amountOut = fixedAmountOut;
    }

    function exactInput(ExactInputParams calldata) external payable override returns (uint256) {
        revert("not implemented");
    }
}

contract BuybackBlueprintHarness is BuybackBlueprintBase {
    uint256 internal expectedOutOverride;

    constructor(address router, address weth)
        BuybackBlueprintBase("Buyback Blueprint Token", "BBT", router, weth)
    {}

    function bootstrap(uint64 blueprintId, address owner, address tangle) external {
        this.onBlueprintCreated(blueprintId, owner, tangle);
    }

    function mintToken(address to, uint256 amount) external {
        _mint(to, amount);
    }

    function configure(BuybackMode mode, TokenDestination destination, uint256 threshold) external {
        _configureBuyback(mode, destination, threshold);
    }

    function setExpectedOutput(uint256 value) external {
        expectedOutOverride = value;
    }

    function configureMaxSlippage(uint256 bps) external {
        _setMaxSlippage(bps);
    }

    function setPoolFee(uint24 fee) external {
        _setPoolFee(fee);
    }

    function setTreasury(address treasury) external {
        _setBuybackTreasury(treasury);
    }

    function _getExpectedOutput(uint256 ethAmount) internal view override returns (uint256) {
        if (expectedOutOverride == 0) {
            return ethAmount;
        }
        return expectedOutOverride;
    }
}

// ═════════════════════════════════════════════════════════════════════════════
// BLUEPRINT HOOK BASE TESTS
// ═════════════════════════════════════════════════════════════════════════════

contract BlueprintHookBaseTest is Test {
    BlueprintHookHarness internal hook;

    function setUp() public {
        hook = new BlueprintHookHarness();
    }

    function test_DefaultLifecycleHooksAcceptOperations() public {
        bool acceptOperator = hook.onOperatorRegister(1, address(0xBEEF), "");
        assertTrue(acceptOperator, "operator registration should be accepted");

        address[] memory operators = new address[](1);
        operators[0] = address(0xCAFE);
        bool acceptRequest = hook.onServiceRequest(1, 1, address(0xFEE), operators, "");
        assertTrue(acceptRequest, "service request should be accepted");

        bool acceptJob = hook.onJobSubmitted(1, 2, 0, address(this), "");
        assertTrue(acceptJob, "job should be accepted");

        bool approveSlash = hook.onSlashProposed(1, operators[0], 1 ether, keccak256("evidence"));
        assertTrue(approveSlash, "slash should be approved");

        bool canJoin = hook.canJoin(3, operators[0], 500);
        bool canLeave = hook.canLeave(3, operators[0]);
        assertTrue(canJoin);
        assertTrue(canLeave);

        assertEq(hook.getDeveloperPaymentAddress(1), address(0));
        assertTrue(hook.isPaymentTokenAllowed(address(0xDEAD)));
        assertEq(hook.getRequiredResultCount(1, 0), 1);
        assertFalse(hook.requiresAggregation(1, 0));

        (uint16 thresholdBps, uint8 thresholdType) = hook.getAggregationThreshold(1, 0);
        assertEq(thresholdBps, 6700);
        assertEq(thresholdType, 0);
    }
}

// ═════════════════════════════════════════════════════════════════════════════
// TOKENIZED BLUEPRINT BASE TESTS
// ═════════════════════════════════════════════════════════════════════════════

contract TokenizedBlueprintBaseTest is Test {
    TokenizedBlueprintHarness internal blueprint;
    address internal owner = address(0x1111);
    address internal tangle = address(0x2222);
    address internal staker = address(0x3333);
    MockERC20 internal rewardToken;

    function setUp() public {
        blueprint = new TokenizedBlueprintHarness();
        blueprint.bootstrap(1, owner, tangle);
        blueprint.mintToken(staker, 100 ether);
        rewardToken = new MockERC20();
    }

    function test_StakeAndWithdrawUpdateBalances() public {
        vm.prank(staker);
        blueprint.stake(40 ether);

        assertEq(blueprint.stakedBalance(staker), 40 ether);
        assertEq(blueprint.totalStaked(), 40 ether);
        assertEq(blueprint.balanceOf(staker), 60 ether);

        vm.prank(staker);
        blueprint.withdraw(25 ether);
        assertEq(blueprint.stakedBalance(staker), 15 ether);
        assertEq(blueprint.balanceOf(staker), 85 ether);

        vm.prank(staker);
        blueprint.withdraw(15 ether);
        assertEq(blueprint.totalStaked(), 0);
    }

    function test_InstantRewardsDistributedToStaker() public {
        vm.prank(staker);
        blueprint.stake(80 ether);

        vm.deal(address(this), 1 ether);
        (bool ok,) = address(blueprint).call{value: 1 ether}("");
        require(ok, "payment failed");

        assertEq(staker.balance, 0);
        vm.prank(staker);
        blueprint.claimReward();
        assertEq(staker.balance, 1 ether);
    }

    function test_PendingERC20RewardsPaidToFirstStaker() public {
        rewardToken.mint(address(blueprint), 500 ether);
        blueprint.externalPayment(address(rewardToken), 500 ether);

        vm.prank(staker);
        blueprint.stake(50 ether);

        vm.prank(staker);
        blueprint.claimReward(address(rewardToken));
        vm.prank(staker);
        blueprint.claimReward(address(rewardToken));

        assertEq(rewardToken.balanceOf(staker), 500 ether);
        assertEq(blueprint.rewards(staker, address(rewardToken)), 0);
    }

    function test_StreamingModeVestsOverTime() public {
        blueprint.setStreamingConfig(true, 7 days);

        vm.prank(staker);
        blueprint.stake(50 ether);

        vm.deal(address(this), 1 ether);
        (bool ok,) = address(blueprint).call{value: 1 ether}("");
        require(ok, "payment failed");

        vm.warp(block.timestamp + 3 days);
        uint256 partialReward = blueprint.earned(staker, address(0));
        uint256 expectedPartial = (uint256(3 days) * 1 ether) / uint256(7 days);
        assertApproxEqAbs(partialReward, expectedPartial, 1e11, "partial reward should vest linearly");

        vm.warp(block.timestamp + 5 days);
        vm.prank(staker);
        blueprint.claimReward();
        assertApproxEqAbs(staker.balance, 1 ether, 1e11, "final reward should equal full payment");
    }
}

// ═════════════════════════════════════════════════════════════════════════════
// BUYBACK BLUEPRINT BASE TESTS
// ═════════════════════════════════════════════════════════════════════════════

contract BuybackBlueprintBaseTest is Test {
    BuybackBlueprintHarness internal buyback;
    MockSwapRouter internal router;
    MockWETH internal weth;
    address internal owner = address(0x4444);
    address internal tangle = address(0x5555);
    address internal treasury = address(0x6666);
    address internal staker = address(0x7777);

    function _sendEther(address target, uint256 amount) internal {
        (bool ok, bytes memory data) = target.call{value: amount}("");
        if (!ok) {
            assembly {
                revert(add(data, 0x20), mload(data))
            }
        }
    }

    function setUp() public {
        router = new MockSwapRouter();
        weth = new MockWETH();
        buyback = new BuybackBlueprintHarness(address(router), address(weth));
        buyback.bootstrap(1, owner, tangle);
        buyback.mintToken(address(router), 10_000 ether);
        buyback.mintToken(staker, 1_000 ether);
    }

    function test_AutoModeExecutesBuybackAndDistributesRewards() public {
        buyback.configure(BuybackBlueprintBase.BuybackMode.AUTO, BuybackBlueprintBase.TokenDestination.DISTRIBUTE, 0);
        buyback.setExpectedOutput(200 ether);
        router.setFixedAmountOut(200 ether);

        vm.prank(staker);
        buyback.stake(500 ether);

        vm.deal(address(this), 2 ether);
        _sendEther(address(buyback), 2 ether);

        assertEq(buyback.pendingBuybackBalance(), 0);
        assertEq(buyback.totalBuybackSpent(), 2 ether);
        assertEq(buyback.totalTokensBought(), 200 ether);
        assertGt(buyback.rewardPerToken(address(buyback)), 0, "rewards should accrue");

        vm.prank(staker);
        buyback.claimReward(address(buyback));
        assertEq(buyback.balanceOf(staker), 700 ether);
    }

    function test_ManualModeAllowsPartialBuyback() public {
        buyback.configure(BuybackBlueprintBase.BuybackMode.MANUAL, BuybackBlueprintBase.TokenDestination.BURN, 0);
        buyback.setExpectedOutput(100 ether);
        router.setFixedAmountOut(100 ether);

        vm.deal(address(this), 1 ether);
        _sendEther(address(buyback), 1 ether);
        assertEq(buyback.pendingBuybackBalance(), 1 ether);

        buyback.executeBuyback(0.4 ether);
        assertEq(buyback.pendingBuybackBalance(), 0.6 ether);
        assertEq(buyback.totalTokensBurned(), 100 ether);
    }

    function test_ThresholdModeTriggersWhenBalanceReached() public {
        buyback.configure(BuybackBlueprintBase.BuybackMode.THRESHOLD, BuybackBlueprintBase.TokenDestination.TREASURY, 1 ether);
        buyback.setTreasury(treasury);
        buyback.setExpectedOutput(150 ether);
        router.setFixedAmountOut(150 ether);

        vm.deal(address(this), 0.4 ether);
        _sendEther(address(buyback), 0.4 ether);
        assertEq(buyback.pendingBuybackBalance(), 0.4 ether);

        vm.deal(address(this), 0.4 ether);
        _sendEther(address(buyback), 0.4 ether);
        assertEq(buyback.pendingBuybackBalance(), 0.8 ether);

        vm.deal(address(this), 0.5 ether);
        _sendEther(address(buyback), 0.5 ether);

        assertEq(buyback.pendingBuybackBalance(), 0);
        assertEq(buyback.totalBuybackSpent(), 1.3 ether);
        assertEq(buyback.balanceOf(treasury), 150 ether);
    }

    function test_ThresholdModeSlippageFailureKeepsPendingBalance() public {
        buyback.configure(BuybackBlueprintBase.BuybackMode.THRESHOLD, BuybackBlueprintBase.TokenDestination.DISTRIBUTE, 5 ether);
        buyback.setExpectedOutput(150 ether);
        router.setFixedAmountOut(10 ether);

        vm.deal(address(this), 1 ether);
        _sendEther(address(buyback), 1 ether);
        assertEq(buyback.pendingBuybackBalance(), 1 ether);

        vm.expectRevert(BuybackBlueprintBase.BuybackFailed.selector);
        buyback.executeBuybackAll();

        assertEq(buyback.pendingBuybackBalance(), 1 ether);
    }

    function test_BuybackFailureRevertsAndFundsStayPending() public {
        buyback.configure(BuybackBlueprintBase.BuybackMode.MANUAL, BuybackBlueprintBase.TokenDestination.DISTRIBUTE, 0);
        router.setShouldRevert(true);

        vm.deal(address(this), 1 ether);
        _sendEther(address(buyback), 1 ether);

        vm.expectRevert(BuybackBlueprintBase.BuybackFailed.selector);
        buyback.executeBuyback(1 ether);

        assertEq(buyback.pendingBuybackBalance(), 1 ether);
    }

    function test_BuybackPauseAccumulatesUntilResumed() public {
        buyback.configure(BuybackBlueprintBase.BuybackMode.AUTO, BuybackBlueprintBase.TokenDestination.DISTRIBUTE, 0);
        buyback.setExpectedOutput(100 ether);
        router.setFixedAmountOut(100 ether);

        vm.prank(owner);
        buyback.setBuybackPaused(true);

        vm.deal(address(this), 1 ether);
        _sendEther(address(buyback), 1 ether);
        assertEq(buyback.pendingBuybackBalance(), 1 ether);
        assertEq(buyback.totalBuybackSpent(), 0);

        vm.prank(owner);
        buyback.setBuybackPaused(false);

        buyback.executeBuybackAll();
        assertEq(buyback.pendingBuybackBalance(), 0);
        assertEq(buyback.totalBuybackSpent(), 1 ether);
    }
}
