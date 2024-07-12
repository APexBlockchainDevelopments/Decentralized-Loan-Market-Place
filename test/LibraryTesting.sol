//SDPX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Library} from "../src/libraries/Library.sol";
import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

contract LibraryTesting is StdCheats, Test{

    address admin = makeAddr("admin");
    address borrower = makeAddr("borrower");
    address lender = makeAddr("lender");
    address random = makeAddr("random");

    function setUp() public {
    }

    function test_LibraryDefaultBid() public pure{
        Library.Bid memory newBid = Library.Bid({
            bidId: 0,
            loanId: 0,
            lender: address(0),
            APRoffer: 0,
            timeStamp: 0,
            accepted: false
        });

        assertEq(newBid.bidId, Library.defaultBid().bidId);
        assertEq(newBid.loanId, Library.defaultBid().loanId);
        assertEq(newBid.lender, Library.defaultBid().lender);
        assertEq(newBid.APRoffer, Library.defaultBid().APRoffer);
        assertEq(newBid.timeStamp, Library.defaultBid().timeStamp);
        assertEq(newBid.accepted, Library.defaultBid().accepted);
    }

    function test_LoanStruct() public view {
        Library.Loan memory loan = Library.Loan({
            loanStatus: Library.LoanStatus.Proposed,
            loanId: 1,
            borrower: address(0x123),
            loanToken: address(0x456),
            amount: 100,
            creationTimeStamp: block.timestamp,
            duration: 30 days,
            collateralToken: address(0x789),
            collateralAmount: 50,
            bids: 0,
            bid: Library.defaultBid()
        });

        assertEq(uint(loan.loanStatus), uint(Library.LoanStatus.Proposed));
        assertEq(loan.loanId, 1);
        assertEq(loan.borrower, address(0x123));
        assertEq(loan.loanToken, address(0x456));
        assertEq(loan.amount, 100);
        assertEq(loan.creationTimeStamp, block.timestamp);
        assertEq(loan.duration, 30 days);
        assertEq(loan.collateralToken, address(0x789));
        assertEq(loan.collateralAmount, 50);
        assertEq(loan.bids, 0);
        assertEq(loan.bid.bidId, Library.defaultBid().bidId);
    }

    function test_AccountStruct() public view {
        Library.Account memory account = Library.Account({
            wallet: address(0x123),
            accountId: 1,
            creationTimeStamp: block.timestamp,
            totalAmountBorrowed: 1000,
            requestedLoans: 5,
            successfulLoansCompletedAndRepaid: 3,
            totalAmountRepaid: 800,
            totalAmountLent: 1500,
            loanBids: 10,
            totalLoans: 7
        });

        assertEq(account.wallet, address(0x123));
        assertEq(account.accountId, 1);
        assertEq(account.creationTimeStamp, block.timestamp);
        assertEq(account.totalAmountBorrowed, 1000);
        assertEq(account.requestedLoans, 5);
        assertEq(account.successfulLoansCompletedAndRepaid, 3);
        assertEq(account.totalAmountRepaid, 800);
        assertEq(account.totalAmountLent, 1500);
        assertEq(account.loanBids, 10);
        assertEq(account.totalLoans, 7);
    }


}