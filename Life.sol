// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

contract InheritanceWallet {
    // State variables
    address public walletHolder;
    address payable public beneficiary;
    uint256 public lastActiveTime;
    uint256 public constant inactivityLimit = 60; // 10 seconds for testing
   //uint256 public constant inactivityLimit = 3 * 365 * 24 * 60 * 60; // 3 years in seconds
    // Events
    event FundsTransferred(address walletHolder, address beneficiary, uint256 amount);
    event WalletInteracted(address walletHolder, uint256 timestamp);

    // Modifier to restrict access to the wallet holder
    modifier onlyWalletHolder() {
        require(msg.sender == walletHolder, "Only the wallet holder can call this function");
        _;
    }

    // Constructor to initialize the contract with wallet holder and beneficiary
    constructor(address payable _beneficiary) payable {
        require(msg.value > 0, "Must fund the wallet with some ETH");

        walletHolder = msg.sender;
        beneficiary = _beneficiary;
        lastActiveTime = block.timestamp; // Record the deployment time
    }

    // Function for the wallet holder to update activity and prevent automatic transfer
    function updateActivity() external onlyWalletHolder {
        lastActiveTime = block.timestamp;
        emit WalletInteracted(walletHolder, lastActiveTime);
    }

    // Function to check inactivity and trigger the transfer if more than 3 years of inactivity
    function checkInactivity() external {
        require(block.timestamp > lastActiveTime + inactivityLimit, "Wallet is still active");
        require(address(this).balance > 0, "No funds to transfer");
        // Transfer the total available funds to the beneficiary
        _transferFunds();
    }

    // Internal function to transfer all available funds to the beneficiary
    function _transferFunds() internal {
        uint256 balance = address(this).balance;
        beneficiary.transfer(balance);
        emit FundsTransferred(walletHolder, beneficiary, balance);
    }
    // Fallback function to receive additional funds
    receive() external payable {}
}
