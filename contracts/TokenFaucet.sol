// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

contract SimpleToken is ERC20, Ownable, ERC20Burnable {
    constructor(uint256 initialSupply) ERC20("SimpleToken", "SIM") Ownable(msg.sender) {
        _mint(msg.sender, initialSupply * 10 ** decimals());
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}

contract TokenFaucet {
    SimpleToken public token;
    uint256 public faucetAmount;
    uint256 public cooldownTime;
    address public owner;
    
    mapping(address => uint256) public lastClaimTime;
    mapping(address => bool) public isBlacklisted;
    mapping(address => uint256) public withdrawnAmount;
    
    event TokensClaimed(address indexed user, uint256 amount);
    event CooldownUpdated(uint256 newCooldown);
    event FaucetAmountUpdated(uint256 newAmount);
    event UserBlacklisted(address indexed user, bool status);
    
    constructor(address _tokenAddress, uint256 _faucetAmount, uint256 _cooldownTime) {
        token = SimpleToken(_tokenAddress);
        faucetAmount = _faucetAmount;
        cooldownTime = _cooldownTime;
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this");
        _;
    }
    
    modifier notBlacklisted(address user) {
        require(!isBlacklisted[user], "User is blacklisted");
        _;
    }
    
    function claimTokens() public notBlacklisted(msg.sender) {
        require(!isBlacklisted[msg.sender], "User is blacklisted");
        require(block.timestamp >= lastClaimTime[msg.sender] + cooldownTime, "Cooldown period not expired");
        require(token.balanceOf(address(this)) >= faucetAmount, "Insufficient tokens in faucet");
        
        lastClaimTime[msg.sender] = block.timestamp;
        withdrawnAmount[msg.sender] += faucetAmount;
        
        require(token.transfer(msg.sender, faucetAmount), "Token transfer failed");
        
        emit TokensClaimed(msg.sender, faucetAmount);
    }
    
    function updateCooldown(uint256 _newCooldown) public onlyOwner {
        cooldownTime = _newCooldown;
        emit CooldownUpdated(_newCooldown);
    }
    
    function updateFaucetAmount(uint256 _newAmount) public onlyOwner {
        faucetAmount = _newAmount;
        emit FaucetAmountUpdated(_newAmount);
    }
    
    function blacklistUser(address _user, bool _status) public onlyOwner {
        isBlacklisted[_user] = _status;
        emit UserBlacklisted(_user, _status);
    }
    
    function withdrawTokens(uint256 amount) public onlyOwner {
        require(token.balanceOf(address(this)) >= amount, "Insufficient balance");
        require(token.transfer(owner, amount), "Transfer failed");
    }
    
    function depositTokens(uint256 amount) public {
        require(token.transferFrom(msg.sender, address(this), amount), "Transfer from failed");
    }
    
    function getLastClaimTime(address user) public view returns (uint256) {
        return lastClaimTime[user];
    }
    
    function getRemainingCooldown(address user) public view returns (uint256) {
        uint256 timePassed = block.timestamp - lastClaimTime[user];
        if (timePassed >= cooldownTime) {
            return 0;
        }
        return cooldownTime - timePassed;
    }
    
    function canClaim(address user) public view returns (bool) {
        return !isBlacklisted[user] && block.timestamp >= lastClaimTime[user] + cooldownTime;
    }
}
