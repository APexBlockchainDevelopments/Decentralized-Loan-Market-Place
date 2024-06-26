// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;


library AccountLibrary {

    struct Account {
        address wallet;
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
        uint256 lengthOfLoan;

        uint256 desiredAPRAmount;
    }
}