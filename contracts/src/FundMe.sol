// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title FundMe
 * @author Akinjeji Oluwaferanmi
 * @notice A simple smart-wallet style contract: anyone can deposit ETH,
 *         only the owner can withdraw.
 */
contract FundMe {
    error FundMe__NotOwner();
    error FundMe__NeedsMoreThanZero();
    error FundMe__WithdrawFailed();
    error FundMe__NoBalance();

    event Withdrawn(address indexed owner, uint256 amount);
    event Funded(address indexed funder, uint256 amount);

    address public immutable i_owner;

    mapping(address => uint256) private s_contributions;
    address[] private s_funders;

    modifier onlyOwner() {
        if (msg.sender != i_owner) revert FundMe__NotOwner();
        _;
    }

    constructor() {
        i_owner = msg.sender;
    }

    /// @notice Deposit ETH into the contract. Callable by anyone, including the owner.
    function fund() public payable {
        if (msg.value == 0) revert FundMe__NeedsMoreThanZero();

        if (s_contributions[msg.sender] == 0) {
            s_funders.push(msg.sender);
        }
        s_contributions[msg.sender] += msg.value;

        emit Funded(msg.sender, msg.value);
    }

    /// @notice Withdraw the full contract balance. Owner only.
    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        if (balance == 0) revert FundMe__NoBalance();

        // Reset per-funder accounting
        for (uint256 i = 0; i < s_funders.length; i++) {
            s_contributions[s_funders[i]] = 0;
        }
        delete s_funders;

        (bool success, ) = payable(i_owner).call{value: balance}("");
        if (!success) revert FundMe__WithdrawFailed();

        emit Withdrawn(i_owner, balance);
    }

    /// @notice Withdraw an arbitrary amount to an arbitrary address. Owner only.
    function withdrawTo(address to, uint256 amount) public onlyOwner {
        if (amount > address(this).balance) revert FundMe__NoBalance();

        (bool success, ) = payable(to).call{value: amount}("");
        if (!success) revert FundMe__WithdrawFailed();

        emit Withdrawn(to, amount);
    }

    function getContribution(address funder) external view returns (uint256) {
        return s_contributions[funder];
    }

    function getFunder(uint256 index) external view returns (address) {
        return s_funders[index];
    }

    function getFundersCount() external view returns (uint256) {
        return s_funders.length;
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }
}
