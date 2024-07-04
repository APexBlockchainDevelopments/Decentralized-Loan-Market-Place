// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;


library AccountLibrary {

    struct Account {
        address wallet;
        uint256 accountId;
        uint256 creationDate;

        //variables for Borrowers
        uint256 totalAmountBorrowed;
        uint256 requestedLoans;
        uint256 successfulLoansCompletedAndRepaid;
        uint256 totalAmountRepaid;
        
        //variables for Lenders
        uint256 totalAmountLent;
        uint256 loanBids;
        uint256 totalLoans;        
    }


    struct ProposedLoan{
        uint256 loanId;
        address borrower;
        address loanToken;
        uint256 amount;
        uint256 duration;
        

        address collateralToken;
        uint256 collateralAmount;

        mapping(uint256 => Bid) offers;  //This seems sloppy
    }

    struct Bid{
        uint256 loanId;
        address lender;
        uint256 amountTolend;
        uint256 APRoffer;

    }

    struct ApprovedLoan{
        address borrower;
        address lender;
        address loanToken;

        uint256 loandStartDate;
        uint256 loanLength;
        uint256 loanAmount;
        uint256 paymentInterval;
    }


    //ERC-721 as collateral as CDP for the loan?
}