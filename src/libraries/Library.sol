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
        uint256 lengthOfLoan;
        uint256 loanRequestTimeStamp;
        uint256 loanRequestedLength;
        uint256 loadExpectedStartTimeStamp;

        uint256 desiredAPRAmount;
        mapping(uint256 => LoanOffer) offers;
    }

    struct LoanOffer{
        uint256 loanId;
        address lender;
        uint256 amountTolend;
        uint256 APRoffer;

    }

    struct ApprovedLoan{
        address borrower;
        mapping(uint256 => address) lenders;  //if there's 10 lenders for a loan, then 0-9 is their individual IDs for the partuclar loan
        address loanToken;

        uint256 loandStartDate;
        uint256 loanLength;
        uint256 loanAmount;
        uint256 paymentInterval;
    }


    //ERC-1155 as collateral for the loan?
}