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
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {AccountLibrary} from "./libraries/Library.sol";

contract LoanMarketPlance is Ownable{

    uint256 private accountIds;
    uint256 private loanIds;

    mapping(address => AccountLibrary.Account) private accounts; // Mapping to track existence of proposedLoans
    mapping(address => bool) private accountExists;     // Mapping to track existence of accounts | "Does 0x0123 have an account?"
    mapping(uint256 => AccountLibrary.ProposedLoan) private proposedLoans; // Mapping to track existence of proposedLoans

    mapping(address => bool) private approvedCollateralTokens; //Used for tokens that are approved for collateral usage. 


    constructor() Ownable(msg.sender){}

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
        uint256 collateralAmount) public {
        
        require(accountExists[msg.sender], "Account does not exist");
        require(approvedCollateralTokens[collateralToken], "Collateral Token Not Approved");

        require(amount != 0, "Loan Amount cannot be zero");

        AccountLibrary.ProposedLoan storage newLoan = proposedLoans[loanIds];
        newLoan.loanId = loanIds;
        newLoan.borrower = msg.sender;
        newLoan.loanToken = tokenToBorrow;
        newLoan.amount = amount;
        newLoan.duration = duration;
        newLoan.collateralToken = collateralToken;  
        newLoan.collateralAmount = collateralAmount; //Potentially Collateral Amount could be zero, however that is up to the Lenders to decide to lend to someone with no collateral upfront

        loanIds++;
    }



    ////Getter Functions/////
    function getAccount(address accountAddress) public view returns(AccountLibrary.Account memory){
        return accounts[accountAddress];
    }

    function getProposedLoan(uint256 loanId) public view returns(AccountLibrary.ProposedLoan memory){
        return proposedLoans[loanId];
    }


    //build these out more just for individual viewing functions.... for example get loan amount based on loan ID
}