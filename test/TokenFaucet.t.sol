// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "./contracts/TokenFaucet.sol";

contract TokenFaucetTest is Test {
    SimpleToken token;
    TokenFaucet faucet;
    address user1;
    address user2;
    uint256 initialSupply = 1000 * 10**18;
    uint256 faucetAmount = 10 * 10**18;
    uint256 cooldownTime = 1 days;

    function setUp() public {
        user1 = address(0x1);
        user2 = address(0x2);
        
        token = new SimpleToken(initialSupply);
        faucet = new TokenFaucet(address(token), faucetAmount, cooldownTime);
        
        token.approve(address(faucet), initialSupply);
        token.transfer(address(faucet), initialSupply / 2);
    }

    function test_ClaimTokens() public {
        vm.startPrank(user1);
        uint256 balanceBefore = token.balanceOf(user1);
        faucet.claimTokens();
        uint256 balanceAfter = token.balanceOf(user1);
        assert(balanceAfter == balanceBefore + faucetAmount);
        vm.stopPrank();
    }

    function test_CooldownPeriod() public {
        vm.startPrank(user1);
        faucet.claimTokens();
        vm.expectRevert("Cooldown period not expired");
        faucet.claimTokens();
        vm.stopPrank();
    }

    function test_CanClaimAfterCooldown() public {
        vm.startPrank(user1);
        faucet.claimTokens();
        vm.warp(block.timestamp + cooldownTime + 1);
        faucet.claimTokens();
        uint256 balance = token.balanceOf(user1);
        assert(balance == faucetAmount * 2);
        vm.stopPrank();
    }

    function test_BlacklistUser() public {
        vm.startPrank(user1);
        faucet.blacklistUser(user2, true);
        vm.stopPrank();
        
        vm.startPrank(user2);
        vm.expectRevert("User is blacklisted");
        faucet.claimTokens();
        vm.stopPrank();
    }

    function test_UpdateFaucetAmount() public {
        uint256 newAmount = 20 * 10**18;
        vm.startPrank(user1);
        faucet.updateFaucetAmount(newAmount);
        vm.stopPrank();
        
        vm.startPrank(user2);
        faucet.claimTokens();
        uint256 balance = token.balanceOf(user2);
        assert(balance == newAmount);
        vm.stopPrank();
    }
}
