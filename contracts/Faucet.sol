// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// 基礎合約，提供擁有者權限管理
contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not contract owner");
        _;
    }

    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), owner);
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Invalid address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

// Faucet 合約，繼承 Ownable
contract Faucet is Ownable {
    uint256 public withdrawLimit = 0.000001 ether;
    mapping(address => uint256) public lastWithdrawTime;
	mapping(address => bool) public blacklist;
    event Withdraw(address indexed recipient, uint256 amount);
    event Deposit(address indexed sender, uint256 amount);
	event Blacklisted(address indexed user, bool status);

    modifier cooldown() {
        require(block.timestamp >= lastWithdrawTime[msg.sender] + 1 hours, "Withdraw cooldown");
        _;
    }
	
	modifier notBlacklisted() {
        require(!blacklist[msg.sender], "Address is blacklisted");
        _;
    }
	
    constructor() payable {
        //require(msg.value = 1 ether, "Initial funding required");
    }

    function withdraw() external cooldown {
        require(address(this).balance >= withdrawLimit, "Faucet empty");
        //lastWithdrawTime[msg.sender] = block.timestamp;
        payable(msg.sender).transfer(withdrawLimit);
        emit Withdraw(msg.sender, withdrawLimit);
    }
	
    function setBlacklist(address user, bool status) external onlyOwner {
        blacklist[user] = status;
        emit Blacklisted(user, status);
    }
	
    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    function withdrawAll() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}
