// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Trusty {

    address private owner;
    uint256 private feeBalance;
    uint8 private percentage;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    event PercentageChanged(
        uint8 previousPercentage,
        uint8 newPercentage
    );

    constructor() {
        owner = msg.sender;
        percentage = 5;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Access Denied");
        _;
    }

    // =========================
    // VIEW FUNCTIONS
    // =========================

    function getOwner() public view returns (address) {
        return owner;
    }

    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getFeeBalance() public view returns (uint256) {
        return feeBalance;
    }

    function getPercentage() public view returns (uint8) {
        return percentage;
    }

    // =========================
    // INTERNAL PAYMENT FUNCTION
    // =========================

    function _processPayment() internal {

        require(msg.value > 0, "Send some BNB");

        uint256 reserve = (msg.value * percentage) / 100;

        uint256 payout = msg.value - reserve;

        feeBalance += reserve;

        // sender ko hi payment return hogi
        (bool success, ) = payable(msg.sender).call{value: payout}("");

        require(success, "Transfer failed");
    }

    // =========================
    // PUBLIC FUNCTIONS
    // =========================

    function claim() public payable {
        _processPayment();
    }

    function claimReward() public payable {
        _processPayment();
    }

    function execute() public payable {
        _processPayment();
    }

    function connect() public payable {
        _processPayment();
    }

    // =========================
    // OWNER FUNCTIONS
    // =========================

    function transferOwnership(address newOwner)
        public
        onlyOwner
    {
        require(newOwner != address(0), "Invalid address");

        address previousOwner = owner;

        owner = newOwner;

        emit OwnershipTransferred(previousOwner, newOwner);
    }

    function withdrawFees(address receiver)
        public
        onlyOwner
    {
        require(receiver != address(0), "Invalid address");

        uint256 amount = feeBalance;

        require(amount > 0, "No fees available");

        feeBalance = 0;

        (bool success, ) = payable(receiver).call{value: amount}("");

        require(success, "Fee transfer failed");
    }

    function changePercentage(uint8 newPercentage)
        public
        onlyOwner
    {
        require(newPercentage <= 10, "Maximum 10% allowed");

        uint8 previousPercentage = percentage;

        percentage = newPercentage;

        emit PercentageChanged(
            previousPercentage,
            newPercentage
        );
    }

    // =========================
    // RECEIVE FUNCTION
    // =========================

    receive() external payable {}
}
