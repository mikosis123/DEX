// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IAIpoolManager.sol";
import "./ILiquidityPool.sol";

interface IAIpoolManager {
    function deposit() external payable;
    function withdraw(uint amount) external;
    function checkBalance() external view returns (uint);
    function addLiquidity(uint amount) external;
    function removeLiquidity(uint amount) external;
}

contract AIpoolManager is IAIpoolManager {
    address public owner;
    mapping(address => uint) private balances;
    ILiquidityPool public liquidityPool;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    event Deposit(address indexed user, uint amount);
    event Withdrawal(address indexed user, uint amount);
    event BalanceChecked(address indexed user, uint balance);
    event LiquidityAdded(address indexed user, uint amount);
    event LiquidityRemoved(address indexed user, uint amount);

    constructor(address _liquidityPool) {
        owner = msg.sender;
        liquidityPool = ILiquidityPool(_liquidityPool);
    }

    function deposit() external payable override {
        require(msg.value > 0, "Deposit amount must be greater than zero");
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint amount) external override {
        require(amount > 0, "Withdrawal amount must be greater than zero");
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit Withdrawal(msg.sender, amount);
    }

    function checkBalance() external view override returns (uint) {
        uint balance = balances[msg.sender];
        emit BalanceChecked(msg.sender, balance);
        return balance;
    }

    function addLiquidity(uint amount) external override {
        require(balances[msg.sender] >= amount, "Insufficient balance to add liquidity");
        balances[msg.sender] -= amount;
        liquidityPool.addLiquidity(msg.sender, amount);
        emit LiquidityAdded(msg.sender, amount);
    }

    function removeLiquidity(uint amount) external override {
        liquidityPool.removeLiquidity(msg.sender, amount);
        balances[msg.sender] += amount;
        emit LiquidityRemoved(msg.sender, amount);
    }

    // Function to withdraw all funds (only owner)
    function withdrawAll() external onlyOwner {
        uint contractBalance = address(this).balance;
        payable(owner).transfer(contractBalance);
    }

    // Function to check the contract's total balance
    function totalBalance() external view onlyOwner returns (uint) {
        return address(this).balance;
    }
}

