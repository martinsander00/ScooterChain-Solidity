// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract ScooterChain {

    address owner;

    constructor() {
        owner = msg.sender;
    }

    // Add yourself as a Renter
    struct Renter {
        address payable walletAddress;
        string firstName;
        string lastName;
        bool canRent;
        bool active;
        uint balance;
        uint due;
        uint start;
        uint end;
    }

    // Creating a map, key is the address, value is the Renter struct
    mapping (address => Renter) public renters;

    // Add new renter
    function addRenter(address payable walletAddress, string memory firstName, string memory lastName, bool canRent, bool active, uint balance, uint due, uint start, uint end) public {
        renters[walletAddress] = Renter(walletAddress, firstName, lastName, canRent, active, balance, due, start, end);

    }

    // Checkout scooter
    function checkOut(address walletAddress) public {
        require(renters[walletAddress].due == 0, "Pending balance. Please pay.");
        require(renters[walletAddress].canRent == true, "Cannot rent now.");
        renters[walletAddress].active = true;
        renters[walletAddress].start = block.timestamp;
        renters[walletAddress].canRent = false;

    }


    // Check in a scooter
    function checkIn(address walletAddress) public {
        require(renters[walletAddress].active == true, "Please check out first.");
        renters[walletAddress].active = false;
        renters[walletAddress].end = block.timestamp;
        setDue(walletAddress);
    }


    // Get total duration of scooter use
    function renterTimespan(uint start, uint end) internal pure returns(uint) {
        return end - start;
    }

    // Get total duration of the ride
    function getTotalDuration(address walletAddress) public view returns(uint) {
        if (renters[walletAddress].start == 0 || renters[walletAddress].end == 0) {
            return 0;
        } else {
            uint timespan = renterTimespan(renters[walletAddress].start, renters[walletAddress].end);
            uint timespanInMinutes = timespan / 60;
            return timespanInMinutes;
        }
    }


    // Get Contract balance
    function balanceOf() view public returns(uint) {
        return address(this).balance;
    }

    // Get Renter's balance
    function balanceOfRenter(address walletAddress) view public returns(uint) {
        return renters[walletAddress].balance;
    }


    // Set Due amount
    function setDue(address walletAddress) internal {
        uint timespanInMinutes = getTotalDuration(walletAddress);
        uint twoMinuteIncrements = timespanInMinutes / 2;
        renters[walletAddress].due = twoMinuteIncrements * 1500000000000000;
    }

    // Returning true or false depending on the canRent property
    function canRentScooter(address walletAddress) public view returns(bool) {
        return renters[walletAddress].canRent;
    }

    // Deposit
    function deposit(address walletAddress) payable public {
        renters[walletAddress].balance += msg.value;
    }

    // Make Payment
    function makePayment(address walletAddress) payable public {
        require(renters[walletAddress].due > 0, "Nothing due at this time.");
        require(renters[walletAddress].balance > 0, "Not enough funds. Please deposit.");
        renters[walletAddress].balance -= msg.value;
        renters[walletAddress].canRent = true;
        renters[walletAddress].due = 0;
        renters[walletAddress].start = 0;
        renters[walletAddress].end = 0;
    }

    // Get due amount
    function getDue(address walletAddress) public view returns(uint)  {
        return renters[walletAddress].due;
    }

    // Get the current Renter
    function getRenter(address walletAddress) public view returns(string memory firstName, string memory lastName, bool canRent, bool active) {
        firstName = renters[walletAddress].firstName;
        lastName = renters[walletAddress].lastName;
        canRent = renters[walletAddress].canRent;
        active = renters[walletAddress].active;
    }

    // Return true or false depending on if the renter exists
    function renterExists(address walletAddress) public view returns(bool) {
        if (renters[walletAddress].walletAddress != address(0)) {
            return true;
        }
        return false;
    }

}
