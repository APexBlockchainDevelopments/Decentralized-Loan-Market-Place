//SDPX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {Library} from "../src/libraries/Library.sol";
import {LoanMarketPlace} from "../src/LoanMarketPlace.sol";
import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import {MockToken} from "./mocks/MockToken.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract LoanMarketPlaceTesting is StdCheats, Test{
    
    LoanMarketPlace loanMarketPlace;

    address admin = makeAddr("admin");
    address borrower = makeAddr("borrower");
    address lender = makeAddr("lender");
    address random = makeAddr("random");

    MockToken TokenToBeBorrowed;
    MockToken CollateralToken;

    address borrowTokenAddress;
    address collateralTokenAddress;

    uint256 constant defaultBorrowAmount = 100e18;
    uint256 constant defaultCollateralAmount = 100e18;
    uint256 constant defaultLoanTime = 30 days;


    function setUp() public {
        vm.startPrank(admin);
        loanMarketPlace = new LoanMarketPlace();

        TokenToBeBorrowed = new MockToken(1000000e18, "Borrow Token", "BT");
        borrowTokenAddress = address(TokenToBeBorrowed);

        CollateralToken = new MockToken(1000000e18, "Collateral Token", "CT");
        collateralTokenAddress = address(CollateralToken);

        TokenToBeBorrowed.transfer(lender, 1000e18);
        CollateralToken.transfer(borrower, 1000e18);

        vm.stopPrank();
    }

    function test_checkOwner() public view{
        assertEq(loanMarketPlace.owner(), admin);
    }

    function test_ownerCanAddCollateralToken() public {
        assertFalse(loanMarketPlace.checkIfTokenIsApprovedForCollateral(collateralTokenAddress));

        vm.prank(admin);
        loanMarketPlace.approvedOrDenyCollateralToken(collateralTokenAddress, true);
        assertTrue(loanMarketPlace.checkIfTokenIsApprovedForCollateral(collateralTokenAddress));

        vm.prank(admin);
        loanMarketPlace.approvedOrDenyCollateralToken(collateralTokenAddress, false);
        assertFalse(loanMarketPlace.checkIfTokenIsApprovedForCollateral(collateralTokenAddress));
    }

    function test_nonOwnerCantUpdateApprovedCollateralTokens() public {
        vm.prank(random);
        vm.expectRevert();
        loanMarketPlace.approvedOrDenyCollateralToken(collateralTokenAddress, true);
    }
    

    function test_userCanCreateAccount() public {
        vm.prank(borrower);
        loanMarketPlace.makeNewAccount();

        Library.Account memory newAccount = loanMarketPlace.getAccount(borrower);
        
        assertEq(newAccount.wallet, borrower);
        assertEq(newAccount.accountId, 0);
        assertEq(newAccount.creationTimeStamp, block.timestamp);
        assertEq(newAccount.totalAmountBorrowed, 0);
        assertEq(newAccount.requestedLoans, 0);
        assertEq(newAccount.successfulLoansCompletedAndRepaid, 0);
        assertEq(newAccount.totalAmountRepaid, 0);
        assertEq(newAccount.totalAmountLent, 0);
        assertEq(newAccount.loanBids, 0);
        assertEq(newAccount.totalLoans, 0);
    }

    function test_userCantCreateAccountTwice() public borrowerMakesAccount {
        vm.prank(borrower);
        vm.expectRevert("Account already exists");
        loanMarketPlace.makeNewAccount();
    }

    function test_makeNewAccounts(uint256 numberOfUsers) public {
        numberOfUsers = bound(numberOfUsers, 1, 1000); // Bound the number of users to be between 1 and 1000

        for (uint256 i = 0; i < numberOfUsers; i++) {
            address user = address(uint160(uint256(keccak256(abi.encode(i)))));
            vm.startPrank(user);
            loanMarketPlace.makeNewAccount();
            vm.stopPrank();
            
            // Assert that the account was created correctly
            Library.Account memory account = loanMarketPlace.getAccount(user);
            assertEq(account.wallet, user);
            assertEq(account.accountId, i);
        }
    }

    function test_submitloanRequest() public borrowerMakesAccount adminAddsCollateralTokenToApprovedCollateralTokens{
        vm.prank(borrower);
        uint256 testingLoanId = loanMarketPlace.submitLoanRequest(defaultBorrowAmount, borrowTokenAddress, defaultLoanTime, collateralTokenAddress, defaultCollateralAmount); 

        // Get the loan and check its status
        Library.Loan memory loan = loanMarketPlace.getLoan(testingLoanId);
        assertEq(uint(loan.loanStatus), uint(Library.LoanStatus.Proposed));
  
        // Check if the loan status matches the expected status
        assertTrue(loan.loanStatus == Library.LoanStatus.Proposed, "Loan status should be Proposed"); 
        assertEq(testingLoanId, loan.loanId);
        assertEq(loan.borrower, borrower);
        assertEq(loan.amount, defaultBorrowAmount);
        assertEq(loan.loanToken, borrowTokenAddress);
        assertEq(loan.creationTimeStamp, block.timestamp);
        assertEq(loan.duration, defaultLoanTime);
        assertEq(loan.collateralToken, collateralTokenAddress);
        assertEq(loan.collateralAmount, defaultCollateralAmount);
        assertEq(loan.bids, 0);

        Library.Bid memory bid = Library.defaultBid();
        assertEq(loan.bid.bidId, bid.bidId);
        assertEq(loan.bid.loanId, bid.loanId);
        assertEq(loan.bid.lender, bid.lender);
        assertEq(loan.bid.APRoffer, bid.APRoffer);
        assertEq(loan.bid.timeStamp, bid.timeStamp);
        assertFalse(loan.bid.accepted);
    }

    function test_submitloanWithoutAccount() public adminAddsCollateralTokenToApprovedCollateralTokens{
        vm.prank(borrower);
        vm.expectRevert();
        loanMarketPlace.submitLoanRequest(defaultBorrowAmount, borrowTokenAddress, defaultLoanTime, collateralTokenAddress, defaultCollateralAmount); 
    }

    function test_bidSubmission() public 
    adminAddsCollateralTokenToApprovedCollateralTokens
    borrowerMakesAccount
    lenderMakesAccount
    borrowerSubmitsBasicLoan 
    {   
        vm.prank(lender);
        loanMarketPlace.createBid(0, 1000); // Lender creates bid - APR in basis points (e.g., 500 for 5%)
        
        Library.Loan memory firstLoan = loanMarketPlace.getLoan(0);
        //get the struct from the mapping
        //test it against default bid
    }




    //------------------MODIFIERS----------------------------------------------
    modifier adminAddsCollateralTokenToApprovedCollateralTokens() {
        vm.prank(admin);
        loanMarketPlace.approvedOrDenyCollateralToken(collateralTokenAddress, true);
        _;
    }

    modifier borrowerMakesAccount() {
        vm.prank(borrower);
        loanMarketPlace.makeNewAccount();
        _;
    }

    modifier lenderMakesAccount() {
        vm.prank(lender);
        loanMarketPlace.makeNewAccount();
        _;
    }

    modifier borrowerSubmitsBasicLoan() {
        vm.prank(borrower);
        loanMarketPlace.submitLoanRequest(defaultBorrowAmount, borrowTokenAddress, defaultLoanTime, collateralTokenAddress, defaultCollateralAmount); 
        _;
    }
    //------------------MODIFIERS----------------------------------------------


}