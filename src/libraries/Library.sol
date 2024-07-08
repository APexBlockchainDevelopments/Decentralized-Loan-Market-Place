// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;


library AccountLibrary {

    struct Account {
        address wallet;
        uint256 accountId;
        uint256 creationTimeStamp;

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
        uint256 creationTimeStamp;
        uint256 duration;

        address collateralToken;
        uint256 collateralAmount;
        uint256 bids;
    }

    struct Bid{
        uint256 bidId;
        uint256 loanId;
        address lender;
        uint256 APRoffer;
        uint256 timeStamp;
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