// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {AccountLibrary} from "./libraries/Library.sol";

contract LoanMarketPlance {

    uint256 private accountIds;

    mapping(address => AccountLibrary.Account) private accounts;

    // Mapping to track existence of accounts
    mapping(address => bool) private accountExists;

    function makeNewAccount() public {
        require(!accountExists[msg.sender], "Account already exists");
        AccountLibrary.Account memory newAccount = AccountLibrary.Account({
            wallet : msg.sender,
            accountId : accountIds,
            creationDate : block.timestamp,
            totalAmountBorrowed : 0,
            requestedLoans : 0,
            successfulLoansCompletedAndRepaid : 0,
            totalAmountRepaid : 0,
            totalAmountLent : 0,
            loanBids : 0,
            totalLoans : 0
        });

        accounts[msg.sender] = newAccount;
        accountIds++;
    }


    function submitLoanRequest(
        uint256 amount, 
        address tokenToBorrow, 
        uint256 duration, 
        address collateralToken,
        uint256 collateral) public {

    }



    ////Getter Functions/////
    function getAccount(address accountAddress) public view returns(AccountLibrary.Account memory){
        return accounts[accountAddress];
    }
}