// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "./MockERC20.sol";

/// A comprehensive test for MockERC20 token implementation
contract MockERC20Test is Test {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    string constant NAME = "Mock Token";
    string constant SYMBOL = "MTK";
    uint8 constant DECIMALS = 18;
    uint256 constant INITIAL_SUPPLY = 1_000_000 * 10**18;
    address constant OWNER = address(0x1111);
    address constant USER1 = address(0x2222);
    address constant USER2 = address(0x3333);
    
    MockERC20 token;
    
    function setUp() public {
        vm.startPrank(OWNER);
        token = new MockERC20();
        token.initialize(NAME, SYMBOL, DECIMALS);
        token.mint(OWNER, INITIAL_SUPPLY);
        vm.stopPrank();
    }
    
    function testName() public {
        assertEq(token.name(), NAME);
    }
    
    function testSymbol() public {
        assertEq(token.symbol(), SYMBOL);
    }
    
    function testDecimals() public {
        assertEq(token.decimals(), DECIMALS);
    }
    
    function testInitializeOnlyOnce() public {
        vm.startPrank(OWNER);
        vm.expectRevert("ALREADY_INITIALIZED");
        token.initialize("New Name", "NEW", 6);
        vm.stopPrank();
    }
    
    function testTotalSupply() public {
        assertEq(token.totalSupply(), INITIAL_SUPPLY);
    }
    
    function testBalanceOf() public {
        assertEq(token.balanceOf(OWNER), INITIAL_SUPPLY);
        assertEq(token.balanceOf(USER1), 0);
    }
    
    function testTransfer() public {
        uint256 transferAmount = 100 * 10**18;
        
        vm.startPrank(OWNER);
        bool success = token.transfer(USER1, transferAmount);
        vm.stopPrank();
        
        assertTrue(success);
        assertEq(token.balanceOf(OWNER), INITIAL_SUPPLY - transferAmount);
        assertEq(token.balanceOf(USER1), transferAmount);
    }
    
    function testTransferEmitsEvent() public {
        uint256 transferAmount = 100 * 10**18;
        
        vm.startPrank(OWNER);
        vm.expectEmit(true, true, false, true);
        emit Transfer(OWNER, USER1, transferAmount);
        token.transfer(USER1, transferAmount);
        vm.stopPrank();
    }
    
    function testTransferFailsOnInsufficientBalance() public {
        uint256 transferAmount = INITIAL_SUPPLY + 1;
        
        vm.startPrank(OWNER);
        vm.expectRevert("ERC20: subtraction underflow");
        token.transfer(USER1, transferAmount);
        vm.stopPrank();
    }
    
    function testApprove() public {
        uint256 approvalAmount = 1000 * 10**18;
        
        vm.startPrank(OWNER);
        bool success = token.approve(USER1, approvalAmount);
        vm.stopPrank();
        
        assertTrue(success);
        assertEq(token.allowance(OWNER, USER1), approvalAmount);
    }
    
    function testApproveEmitsEvent() public {
        uint256 approvalAmount = 1000 * 10**18;
        
        vm.startPrank(OWNER);
        vm.expectEmit(true, true, false, true);
        emit Approval(OWNER, USER1, approvalAmount);
        token.approve(USER1, approvalAmount);
        vm.stopPrank();
    }
    
    function testTransferFrom() public {
        uint256 approvalAmount = 1000 * 10**18;
        uint256 transferAmount = 500 * 10**18;
        
        vm.startPrank(OWNER);
        token.approve(USER1, approvalAmount);
        vm.stopPrank();
        
        vm.startPrank(USER1);
        bool success = token.transferFrom(OWNER, USER2, transferAmount);
        vm.stopPrank();
        
        assertTrue(success);
        assertEq(token.balanceOf(OWNER), INITIAL_SUPPLY - transferAmount);
        assertEq(token.balanceOf(USER2), transferAmount);
        assertEq(token.allowance(OWNER, USER1), approvalAmount - transferAmount);
    }
    
    function testTransferFromWithUnlimitedApproval() public {
        uint256 unlimitedApproval = type(uint256).max;
        uint256 transferAmount = 500 * 10**18;
        
        vm.startPrank(OWNER);
        token.approve(USER1, unlimitedApproval);
        vm.stopPrank();
        
        vm.startPrank(USER1);
        bool success = token.transferFrom(OWNER, USER2, transferAmount);
        vm.stopPrank();
        
        assertTrue(success);
        assertEq(token.balanceOf(OWNER), INITIAL_SUPPLY - transferAmount);
        assertEq(token.balanceOf(USER2), transferAmount);
        assertEq(token.allowance(OWNER, USER1), unlimitedApproval); // Allowance doesn't decrease for max approval
    }
    
    function testTransferFromFailsWithoutApproval() public {
        uint256 transferAmount = 100 * 10**18;
        
        vm.startPrank(USER1);
        vm.expectRevert("ERC20: subtraction underflow");
        token.transferFrom(OWNER, USER2, transferAmount);
        vm.stopPrank();
    }
    
    function testTransferFromFailsWithInsufficientApproval() public {
        uint256 approvalAmount = 100 * 10**18;
        uint256 transferAmount = 200 * 10**18;
        
        vm.startPrank(OWNER);
        token.approve(USER1, approvalAmount);
        vm.stopPrank();
        
        vm.startPrank(USER1);
        vm.expectRevert("ERC20: subtraction underflow");
        token.transferFrom(OWNER, USER2, transferAmount);
        vm.stopPrank();
    }
    
    function testPermit() public {
        uint256 privateKey = 0xA11CE;
        address owner = vm.addr(privateKey);
        
        // Mint tokens to the owner
        vm.startPrank(OWNER);
        token.mint(owner, 1000 * 10**18);
        vm.stopPrank();
        
        uint256 value = 100 * 10**18;
        uint256 deadline = block.timestamp + 1 hours;
        uint256 nonce = token.nonces(owner);
        
        // Compute the digest
        bytes32 domainSeparator = token.DOMAIN_SEPARATOR();
        bytes32 permitHash = keccak256(
            abi.encodePacked(
                "\x19\x01",
                domainSeparator,
                keccak256(
                    abi.encode(
                        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"),
                        owner,
                        USER1,
                        value,
                        nonce,
                        deadline
                    )
                )
            )
        );
        
        // Sign the digest
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, permitHash);
        
        // Execute permit
        token.permit(owner, USER1, value, deadline, v, r, s);
        
        // Verify results
        assertEq(token.allowance(owner, USER1), value);
        assertEq(token.nonces(owner), nonce + 1);
    }
    
    function testPermitFailsAfterDeadline() public {
        uint256 privateKey = 0xA11CE;
        address owner = vm.addr(privateKey);
        
        // Mint tokens to the owner
        vm.startPrank(OWNER);
        token.mint(owner, 1000 * 10**18);
        vm.stopPrank();
        
        uint256 value = 100 * 10**18;
        uint256 deadline = block.timestamp - 1; // Expired deadline
        uint256 nonce = token.nonces(owner);
        
        // Compute the digest
        bytes32 domainSeparator = token.DOMAIN_SEPARATOR();
        bytes32 permitHash = keccak256(
            abi.encodePacked(
                "\x19\x01",
                domainSeparator,
                keccak256(
                    abi.encode(
                        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"),
                        owner,
                        USER1,
                        value,
                        nonce,
                        deadline
                    )
                )
            )
        );
        
        // Sign the digest
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, permitHash);
        
        // Execute permit
        vm.expectRevert("PERMIT_DEADLINE_EXPIRED");
        token.permit(owner, USER1, value, deadline, v, r, s);
    }
    
    function testPermitFailsWithInvalidSignature() public {
        uint256 privateKey = 0xA11CE;
        address owner = vm.addr(privateKey);
        uint256 wrongKey = 0xB0B;
        
        // Mint tokens to the owner
        vm.startPrank(OWNER);
        token.mint(owner, 1000 * 10**18);
        vm.stopPrank();
        
        uint256 value = 100 * 10**18;
        uint256 deadline = block.timestamp + 1 hours;
        uint256 nonce = token.nonces(owner);
        
        // Compute the digest
        bytes32 domainSeparator = token.DOMAIN_SEPARATOR();
        bytes32 permitHash = keccak256(
            abi.encodePacked(
                "\x19\x01",
                domainSeparator,
                keccak256(
                    abi.encode(
                        keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"),
                        owner,
                        USER1,
                        value,
                        nonce,
                        deadline
                    )
                )
            )
        );
        
        // Sign with wrong key
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(wrongKey, permitHash);
        
        // Execute permit
        vm.expectRevert("INVALID_SIGNER");
        token.permit(owner, USER1, value, deadline, v, r, s);
    }
    
    function testSafeAddition() public {
        uint256 maxAmount = type(uint256).max;
        
        vm.startPrank(OWNER);
        // First set balance to 0
        token.transfer(USER1, INITIAL_SUPPLY);
        
        // Then try to mint the maximum amount
        vm.expectRevert(stdError.arithmeticError);
        token.mint(OWNER, maxAmount);
        vm.stopPrank();
    }
    
    function testMint() public {
        uint256 mintAmount = 1000 * 10**18;
        
        vm.startPrank(OWNER);
        token.mint(USER1, mintAmount);
        vm.stopPrank();
        
        assertEq(token.balanceOf(USER1), mintAmount);
        assertEq(token.totalSupply(), INITIAL_SUPPLY + mintAmount);
    }
    
    function testMintEmitsTransfer() public {
        uint256 mintAmount = 1000 * 10**18;
        
        vm.startPrank(OWNER);
        vm.expectEmit(true, true, false, true);
        emit Transfer(address(0), USER1, mintAmount);
        token.mint(USER1, mintAmount);
        vm.stopPrank();
    }
    
    function testBurn() public {
        uint256 burnAmount = 1000 * 10**18;
        
        vm.startPrank(OWNER);
        token.burn(OWNER, burnAmount);
        vm.stopPrank();
        
        assertEq(token.balanceOf(OWNER), INITIAL_SUPPLY - burnAmount);
        assertEq(token.totalSupply(), INITIAL_SUPPLY - burnAmount);
    }
    
    function testBurnEmitsTransfer() public {
        uint256 burnAmount = 1000 * 10**18;
        
        vm.startPrank(OWNER);
        vm.expectEmit(true, true, false, true);
        emit Transfer(OWNER, address(0), burnAmount);
        token.burn(OWNER, burnAmount);
        vm.stopPrank();
    }
    
    function testBurnFailsWithInsufficientBalance() public {
        uint256 burnAmount = 100 * 10**18;
        
        vm.startPrank(OWNER);
        vm.expectRevert("ERC20: subtraction underflow");
        token.burn(USER1, burnAmount);
        vm.stopPrank();
    }
    
    function testDomainSeparator() public {
        bytes32 expectedDomainSeparator = keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                keccak256(bytes(NAME)),
                keccak256("1"),
                block.chainid,
                address(token)
            )
        );
        
        assertEq(token.DOMAIN_SEPARATOR(), expectedDomainSeparator);
    }
}
