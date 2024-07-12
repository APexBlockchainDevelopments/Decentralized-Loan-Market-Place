// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;


library Library {

    struct Account {
        address wallet;  //Maybe change name of variable
        uint256 accountId;
        uint256 creationTimeStamp;

        //variables for Borrowers
        uint256 totalAmountBorrowed;
        uint256 requestedLoans;  //shoulder this be an array?
        uint256 successfulLoansCompletedAndRepaid; //shoulder this be an array?
        uint256 totalAmountRepaid;
        
        //variables for Lenders
        uint256 totalAmountLent;
        uint256 loanBids;  //total loan bids? 
        uint256 totalLoans;    //Total accepted loans?

        //is all this information necessary? Maybe just another struct. Don't use reduntant information
    }


    enum LoanStatus {
        Proposed,
        InProgress,
        Defaulted,
        Repaid
    }


    struct Loan{
        LoanStatus loanStatus;
        uint256 loanId;
        address borrower;
        address loanToken;
        uint256 amount;
        uint256 creationTimeStamp;
        uint256 duration;

        address collateralToken;
        uint256 collateralAmount;
        uint256 bids;
        Bid bid;


        //loan repaid  -- not needed because it would be in status 
        //apr -- not needed because it's in the selected bid
        //loan completed  -- not needed because it would be in status 
    }

    struct Bid{
        uint256 bidId;
        uint256 loanId;  //is this necessary for gas?
        address lender;
        uint256 APRoffer;  // APR in basis points (e.g., 500 for 5%)
        uint256 timeStamp;
        bool accepted;
    }

    function defaultBid() internal pure returns (Bid memory) {
        return Bid({
            bidId: 0,
            loanId: 0,
            lender: address(0),
            APRoffer: 0,
            timeStamp: 0,
            accepted: false
        });
    }

    //ERC-721 as collateral as CDP for the loan?
}