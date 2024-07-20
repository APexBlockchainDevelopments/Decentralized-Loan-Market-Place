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
    uint256 constant defaultAPROffer = 1000;


    function setUp() public {
        vm.startPrank(admin);
        loanMarketPlace = new LoanMarketPlace();

        TokenToBeBorrowed = new MockToken(1000000e18, "Borrow Token", "BT");
        borrowTokenAddress = address(TokenToBeBorrowed);

        CollateralToken = new MockToken(1000000e18, "Collateral Token", "CT");
        collateralTokenAddress = address(CollateralToken);

        TokenToBeBorrowed.transfer(lender, 1000e18);
        CollateralToken.transfer(borrower, 1000e18);
        TokenToBeBorrowed.transfer(borrower, 1000e18);

        vm.stopPrank();
    }

    function testDeploy() public {
        loanMarketPlace = new LoanMarketPlace();
    }

    function test_checkOwner() public view{
        assertEq(loanMarketPlace.owner(), admin);
    }

    function test_sendEthToContract() public {
        uint256 balanceBefore = address(loanMarketPlace).balance;
        vm.deal(address(loanMarketPlace), 10e18);
        assertEq(balanceBefore + 10e18, address(loanMarketPlace).balance);
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

    // function test_nonOwnerCantUpdateApprovedCollateralTokens() public {
    //     vm.prank(random);
    //     vm.expectRevert();
    //     loanMarketPlace.approvedOrDenyCollateralToken(collateralTokenAddress, true);
    // }
    

    // function test_userCanCreateAccount() public {
    //     vm.prank(borrower);
    //     loanMarketPlace.makeNewAccount();

    //     Library.Account memory newAccount = loanMarketPlace.getAccount(borrower);
        
    //     assertEq(newAccount.wallet, borrower);
    //     assertEq(newAccount.accountId, 0);
    //     assertEq(newAccount.creationTimeStamp, block.timestamp);
    //     assertEq(newAccount.totalAmountBorrowed, 0);
    //     assertEq(newAccount.requestedLoans, 0);
    //     assertEq(newAccount.successfulLoansCompletedAndRepaid, 0);
    //     assertEq(newAccount.totalAmountRepaid, 0);
    //     assertEq(newAccount.totalAmountLent, 0);
    //     assertEq(newAccount.loanBids, 0);
    //     assertEq(newAccount.totalLoans, 0);
    // }

    // function test_userCantCreateAccountTwice() public borrowerMakesAccount {
    //     vm.prank(borrower);
    //     vm.expectRevert("Account already exists");
    //     loanMarketPlace.makeNewAccount();
    // }

    // function test_makeNewAccounts(uint256 numberOfUsers) public {
    //     numberOfUsers = bound(numberOfUsers, 1, 1000); // Bound the number of users to be between 1 and 1000

    //     for (uint256 i = 0; i < numberOfUsers; i++) {
    //         address user = address(uint160(uint256(keccak256(abi.encode(i)))));
    //         vm.startPrank(user);
    //         loanMarketPlace.makeNewAccount();
    //         vm.stopPrank();
            
    //         // Assert that the account was created correctly
    //         Library.Account memory account = loanMarketPlace.getAccount(user);
    //         assertEq(account.wallet, user);
    //         assertEq(account.accountId, i);
    //     }
    // }

    // function test_submitloanRequest() public borrowerMakesAccount adminAddsCollateralTokenToApprovedCollateralTokens{
    //     vm.prank(borrower);
    //     uint256 testingLoanId = loanMarketPlace.submitLoanRequest(defaultBorrowAmount, borrowTokenAddress, defaultLoanTime, collateralTokenAddress, defaultCollateralAmount); 

    //     // Get the loan and check its status
    //     Library.Loan memory loan = loanMarketPlace.getLoan(testingLoanId);
    //     assertEq(uint(loan.loanStatus), uint(Library.LoanStatus.Proposed));
  
    //     // Check if the loan status matches the expected status
    //     assertTrue(loan.loanStatus == Library.LoanStatus.Proposed, "Loan status should be Proposed"); 
    //     assertEq(testingLoanId, loan.loanId);
    //     assertEq(loan.borrower, borrower);
    //     assertEq(loan.amount, defaultBorrowAmount);
    //     assertEq(loan.loanToken, borrowTokenAddress);
    //     assertEq(loan.creationTimeStamp, block.timestamp);
    //     assertEq(loan.duration, defaultLoanTime);
    //     assertEq(loan.collateralToken, collateralTokenAddress);
    //     assertEq(loan.collateralAmount, defaultCollateralAmount);
    //     assertEq(loan.bids, 0);

    //     Library.Bid memory bid = Library.defaultBid();
    //     assertEq(loan.bid.bidId, bid.bidId);
    //     assertEq(loan.bid.loanId, bid.loanId);
    //     assertEq(loan.bid.lender, bid.lender);
    //     assertEq(loan.bid.APRoffer, bid.APRoffer);
    //     assertEq(loan.bid.timeStamp, bid.timeStamp);
    //     assertFalse(loan.bid.accepted);
    // }

    // function test_submitloanWithoutAccount() public adminAddsCollateralTokenToApprovedCollateralTokens{
    //     vm.prank(borrower);
    //     vm.expectRevert();
    //     loanMarketPlace.submitLoanRequest(defaultBorrowAmount, borrowTokenAddress, defaultLoanTime, collateralTokenAddress, defaultCollateralAmount); 
    // }

    // function test_bidSubmission() public 
    // adminAddsCollateralTokenToApprovedCollateralTokens
    // borrowerMakesAccount
    // lenderMakesAccount
    // borrowerSubmitsBasicLoan 
    // {   
    //     vm.prank(lender);
    //     loanMarketPlace.createBid(0, defaultAPROffer); // Lender creates bid - APR in basis points (e.g., 500 for 5%)
        
    //     Library.Loan memory firstLoan = loanMarketPlace.getLoan(0);
        
    //     assertEq(firstLoan.bids, 1);
        
    //     Library.Bid memory bid = loanMarketPlace.getBid(0, 0);  //Getting Bid from LoanMarketplace Contract
        
    //     assertEq(bid.bidId, 0);
    //     assertEq(bid.loanId, 0);
    //     assertEq(bid.lender, lender);
    //     assertEq(bid.APRoffer, defaultAPROffer);
    //     assertEq(bid.timeStamp, block.timestamp);
    //     assertEq(bid.accepted, false);
    // }

    // function test_nonUserCantCreateBid() 
    // adminAddsCollateralTokenToApprovedCollateralTokens
    // borrowerMakesAccount
    // borrowerSubmitsBasicLoan 
    // public {
    //     vm.prank(lender);
    //     vm.expectRevert("Account does not exist");
    //     loanMarketPlace.createBid(0, defaultAPROffer); // Lender creates bid - APR in basis points (e.g., 500 for 5%)
    // }

    // function test_lenderCantBidOnLoanThatDoesntExist() 
    // adminAddsCollateralTokenToApprovedCollateralTokens
    // borrowerMakesAccount
    // lenderMakesAccount
    // public {
    //     vm.prank(lender);
    //     vm.expectRevert("Loan Does not exist");
    //     loanMarketPlace.createBid(0, defaultAPROffer); // Lender creates bid - APR in basis points (e.g., 500 for 5%)
    // }

    
    // function test_lenderCantBidOnLoanAfterBiddingPeroid() 
    // adminAddsCollateralTokenToApprovedCollateralTokens
    // borrowerMakesAccount
    // lenderMakesAccount
    // borrowerSubmitsBasicLoan 
    // public {
    //     vm.prank(lender);
    //     vm.warp(block.timestamp + 7 days + 1); // Warp time by 7 days
    //     vm.expectRevert("Bidding period for this loan has ended");
    //     loanMarketPlace.createBid(0, defaultAPROffer); // Lender creates bid - APR in basis points (e.g., 500 for 5%)
    // }

    // function test_userCanSelectBid() 
    // adminAddsCollateralTokenToApprovedCollateralTokens
    // borrowerMakesAccount
    // lenderMakesAccount
    // borrowerSubmitsBasicLoan 
    // lenderSubmitsBasicBid
    // public {
    //     uint256 borrowTokenBorrowerBalanceBefore = TokenToBeBorrowed.balanceOf(borrower);
    //     uint256 borrowTokenLenderBalanceBefore = TokenToBeBorrowed.balanceOf(lender);
    //     uint256 collateralTokenBorrowerBalanceBefore = CollateralToken.balanceOf(borrower);
    //     uint256 collateralTokenEscrowBalanceBefore = CollateralToken.balanceOf(address(loanMarketPlace));
        
        
    //     vm.warp(block.timestamp + 7 days + 1); // Warp time by 7 days
    //     vm.prank(lender);
    //     TokenToBeBorrowed.approve(address(loanMarketPlace), defaultBorrowAmount);
        
    //     vm.startPrank(borrower);
    //     CollateralToken.approve(address(loanMarketPlace), defaultCollateralAmount);
    //     loanMarketPlace.selectBid(0, 0);
    //     vm.stopPrank();

    //     Library.Bid memory bid = loanMarketPlace.getBid(0, 0);
    //     Library.Bid memory selectedBid = loanMarketPlace.getSelectedBid(0);

    //     //making sure selected bid is actually the same bid as chosen by the selectBid function
    //     assertEq(bid.bidId, selectedBid.bidId);
    //     assertEq(bid.loanId, selectedBid.loanId);
    //     assertEq(bid.lender, selectedBid.lender);
    //     assertEq(bid.APRoffer, selectedBid.APRoffer);
    //     assertEq(bid.timeStamp, selectedBid.timeStamp);
    //     assertEq(bid.accepted, selectedBid.accepted);

    //     uint256 borrowTokenBorrowerBalanceAfter = TokenToBeBorrowed.balanceOf(borrower);
    //     uint256 borrowTokenLenderBalanceAfter = TokenToBeBorrowed.balanceOf(lender);
    //     uint256 collateralTokenBorrowerBalanceAfter = CollateralToken.balanceOf(borrower);
    //     uint256 collateralTokenEscrowBalanceAfter = CollateralToken.balanceOf(address(loanMarketPlace));

    //     assertEq(borrowTokenBorrowerBalanceBefore + defaultBorrowAmount, borrowTokenBorrowerBalanceAfter);
    //     assertEq(borrowTokenLenderBalanceBefore - defaultBorrowAmount, borrowTokenLenderBalanceAfter);
    //     assertEq(collateralTokenBorrowerBalanceBefore - defaultCollateralAmount, collateralTokenBorrowerBalanceAfter);
    //     assertEq(collateralTokenEscrowBalanceBefore + defaultCollateralAmount, collateralTokenEscrowBalanceAfter);

    //     Library.Loan memory loan = loanMarketPlace.getLoan(0);

    //     assertEq(uint8(loan.loanStatus), uint8(Library.LoanStatus.InProgress));
    // }

    // function test_randomCantSelectLoan() 
    // adminAddsCollateralTokenToApprovedCollateralTokens
    // borrowerMakesAccount
    // lenderMakesAccount
    // borrowerSubmitsBasicLoan 
    // lenderSubmitsBasicBid
    // public {
    //     vm.warp(block.timestamp + 7 days + 1); // Warp time by 7 days
    //     vm.prank(random);
    //     vm.expectRevert("You are not the borrower of this loan");
    //     loanMarketPlace.selectBid(0, 0);
    // }


    // //write tests if lender removes approval


    // function test_userSelectBidBeforeBiddingIsOver() 
    // adminAddsCollateralTokenToApprovedCollateralTokens
    // borrowerMakesAccount
    // lenderMakesAccount
    // borrowerSubmitsBasicLoan 
    // lenderSubmitsBasicBid
    // public {
    //     vm.prank(borrower);
    //     vm.expectRevert("Cannot select bid until bidding process is over");
    //     loanMarketPlace.selectBid(0, 0);
    // }

    // function test_userSelectBidAfterSelectionPeroidIsUp() 
    // adminAddsCollateralTokenToApprovedCollateralTokens
    // borrowerMakesAccount
    // lenderMakesAccount
    // borrowerSubmitsBasicLoan 
    // lenderSubmitsBasicBid
    // public {
    //     vm.prank(borrower);
    //     vm.warp(block.timestamp + 14 days + 1); // Warp time by 7 days
    //     vm.expectRevert("Bidding peroid has ended, this loan is dead.");
    //     loanMarketPlace.selectBid(0, 0);
    // }

    // function test_borrowerSelectsBidThatDoesntExist() 
    // adminAddsCollateralTokenToApprovedCollateralTokens
    // borrowerMakesAccount
    // lenderMakesAccount
    // borrowerSubmitsBasicLoan 
    // lenderSubmitsBasicBid
    // public {
    //     vm.prank(borrower);
    //     vm.warp(block.timestamp + 7 days + 1); // Warp time by 7 days
    //     vm.expectRevert("Bid does not exist");
    //     loanMarketPlace.selectBid(0, 1);
    // }



    // function test_borrowerRepaysLoan() 
    // adminAddsCollateralTokenToApprovedCollateralTokens
    // borrowerMakesAccount
    // lenderMakesAccount
    // borrowerSubmitsBasicLoan 
    // lenderSubmitsBasicBid
    // borrowerApprovedCollateral
    // lenderApprovedCollateral
    // borrowerSelectsBasicBid
    // public {
    //     //starting values

    //     //Borrow Token
    //     uint256 borrowerBalanceBeforeRepayment = IERC20(TokenToBeBorrowed).balanceOf(borrower);
    //     uint256 lenderBalanceBeforeRepayment = IERC20(TokenToBeBorrowed).balanceOf(lender);
    //     uint256 marketPlaceBalanceBeforeRepayment = IERC20(TokenToBeBorrowed).balanceOf(address(loanMarketPlace));

    //     //Collateral Token
    //     uint256 borrowerCollateralBalanceBeforeRepayment = IERC20(CollateralToken).balanceOf(borrower);
    //     uint256 lenderCollateralBalanceBeforeRepayment = IERC20(CollateralToken).balanceOf(lender);
    //     uint256 marketCollateralPlaceBalanceBeforeRepayment = IERC20(CollateralToken).balanceOf(address(loanMarketPlace));

    //     uint256 interestAmount = loanMarketPlace.calculateInterest(defaultBorrowAmount, defaultAPROffer, defaultLoanTime);
    //     uint256 totalPaymentAmount = defaultBorrowAmount + interestAmount;
    //     vm.startPrank(borrower);
    //     TokenToBeBorrowed.approve(address(loanMarketPlace), totalPaymentAmount);
    //     loanMarketPlace.repayLoan(0);
    //     vm.stopPrank();

    //     Library.Loan memory loan = loanMarketPlace.getLoan(0);
    //     assertEq(uint8(loan.loanStatus), uint8(Library.LoanStatus.Repaid));


    //     //Finishing values

    //     //Borrow Token
    //     uint256 borrowerBalanceAfterRepayment = IERC20(TokenToBeBorrowed).balanceOf(borrower);
    //     uint256 lenderBalanceAfterRepayment = IERC20(TokenToBeBorrowed).balanceOf(lender);
    //     uint256 marketPlaceBalanceAfterRepayment = IERC20(TokenToBeBorrowed).balanceOf(address(loanMarketPlace));

    //     //Collateral Token
    //     uint256 borrowerCollateralBalanceAfterRepayment = IERC20(CollateralToken).balanceOf(borrower);
    //     uint256 lenderCollateralBalanceAfterRepayment = IERC20(CollateralToken).balanceOf(lender);
    //     uint256 marketCollateralPlaceBalanceAfterRepayment = IERC20(CollateralToken).balanceOf(address(loanMarketPlace));
        

    //     //Asserts
    //     //Borrowed Token
    //     assertEq(borrowerBalanceBeforeRepayment - totalPaymentAmount, borrowerBalanceAfterRepayment);
    //     assertEq(lenderBalanceBeforeRepayment + totalPaymentAmount, lenderBalanceAfterRepayment);
    //     assertEq(marketPlaceBalanceBeforeRepayment, marketPlaceBalanceAfterRepayment);
    //     //Collateral Token
    //     assertEq(borrowerCollateralBalanceBeforeRepayment + defaultCollateralAmount, borrowerCollateralBalanceAfterRepayment);
    //     assertEq(lenderCollateralBalanceBeforeRepayment, lenderCollateralBalanceAfterRepayment);
    //     assertEq(marketCollateralPlaceBalanceBeforeRepayment - defaultCollateralAmount, marketCollateralPlaceBalanceAfterRepayment);
    // }

    // function test_nonBorrowerCantRepaysLoan() 
    // adminAddsCollateralTokenToApprovedCollateralTokens
    // borrowerMakesAccount
    // lenderMakesAccount
    // borrowerSubmitsBasicLoan 
    // lenderSubmitsBasicBid
    // borrowerApprovedCollateral
    // lenderApprovedCollateral
    // borrowerSelectsBasicBid
    // public {
    //     vm.prank(random);
    //     vm.expectRevert("You are not the borrower of this loan");
    //     loanMarketPlace.repayLoan(0);
    // }


    // function test_borrowerCantRepayAfterLoanHasEnded() 
    // adminAddsCollateralTokenToApprovedCollateralTokens
    // borrowerMakesAccount
    // lenderMakesAccount
    // borrowerSubmitsBasicLoan 
    // lenderSubmitsBasicBid
    // borrowerApprovedCollateral
    // lenderApprovedCollateral
    // borrowerSelectsBasicBid
    // public {
    //     uint256 interestAmount = loanMarketPlace.calculateInterest(defaultBorrowAmount, defaultAPROffer, defaultLoanTime);

    //     vm.startPrank(borrower);
    //     TokenToBeBorrowed.approve(address(loanMarketPlace), defaultBorrowAmount + interestAmount);
    //     vm.warp(block.timestamp + 60 days + 1); // Warp time by duration + bidding peroid
    //     vm.expectRevert("Loan repayment period has ended");
    //     loanMarketPlace.repayLoan(0);
    //     vm.stopPrank();
    // }

    // function test_cantRepayIfNotInProgress() 
    // adminAddsCollateralTokenToApprovedCollateralTokens
    // borrowerMakesAccount
    // lenderMakesAccount
    // borrowerSubmitsBasicLoan 
    // lenderSubmitsBasicBid
    // borrowerApprovedCollateral
    // lenderApprovedCollateral
    // //borrowerSelectsBasicBid  - this commenting out because it sets the loan to inprogress. We're testing to see if they can repay a loan that is not in progress
    // public {
    //     uint256 interestAmount = loanMarketPlace.calculateInterest(defaultBorrowAmount, defaultAPROffer, defaultLoanTime);

    //     vm.startPrank(borrower);
    //     TokenToBeBorrowed.approve(address(loanMarketPlace), defaultBorrowAmount + interestAmount);
    //     vm.expectRevert("Loan is not in Progress");
    //     loanMarketPlace.repayLoan(0);
    //     vm.stopPrank();
        
    
    // }

    // function test_claimCollateral() 
    // adminAddsCollateralTokenToApprovedCollateralTokens
    // borrowerMakesAccount
    // lenderMakesAccount
    // borrowerSubmitsBasicLoan 
    // lenderSubmitsBasicBid
    // borrowerApprovedCollateral
    // lenderApprovedCollateral
    // borrowerSelectsBasicBid
    // public {
    //     //starting values

    //     //Collateral Token
    //     uint256 borrowerCollateralBalanceBeforeDefault = IERC20(CollateralToken).balanceOf(borrower);
    //     uint256 lenderCollateralBalanceBeforeDefault = IERC20(CollateralToken).balanceOf(lender);
    //     uint256 marketCollateralPlaceBalanceBeforeDefault = IERC20(CollateralToken).balanceOf(address(loanMarketPlace));

    //     vm.warp(block.timestamp + 60 days + 1);
    //     vm.prank(lender);
    //     loanMarketPlace.claimCollateral(0);

    //     Library.Loan memory loan = loanMarketPlace.getLoan(0);
    //     assertEq(uint8(loan.loanStatus), uint8(Library.LoanStatus.Defaulted));


    //     //Finishing values

    //     //Collateral Token
    //     uint256 borrowerCollateralBalanceAfterDefault = IERC20(CollateralToken).balanceOf(borrower);
    //     uint256 lenderCollateralBalanceAfterDefault = IERC20(CollateralToken).balanceOf(lender);
    //     uint256 marketCollateralPlaceBalanceAfterDefault = IERC20(CollateralToken).balanceOf(address(loanMarketPlace));
        

    //     //Asserts
    //     //Collateral Token
    //     assertEq(borrowerCollateralBalanceBeforeDefault, borrowerCollateralBalanceAfterDefault);
    //     assertEq(lenderCollateralBalanceBeforeDefault + defaultCollateralAmount, lenderCollateralBalanceAfterDefault);
    //     assertEq(marketCollateralPlaceBalanceBeforeDefault - defaultCollateralAmount, marketCollateralPlaceBalanceAfterDefault);
    // }

    // function test_nonLenderCantRepaysLoan() 
    // adminAddsCollateralTokenToApprovedCollateralTokens
    // borrowerMakesAccount
    // lenderMakesAccount
    // borrowerSubmitsBasicLoan 
    // lenderSubmitsBasicBid
    // borrowerApprovedCollateral
    // lenderApprovedCollateral
    // borrowerSelectsBasicBid
    // public {
    //     vm.prank(random);
    //     vm.expectRevert("You are not the lender of this loan");
    //     loanMarketPlace.claimCollateral(0);
    // }


    // function test_lenderCantClaimUntilDurationIsOver() 
    // adminAddsCollateralTokenToApprovedCollateralTokens
    // borrowerMakesAccount
    // lenderMakesAccount
    // borrowerSubmitsBasicLoan 
    // lenderSubmitsBasicBid
    // borrowerApprovedCollateral
    // lenderApprovedCollateral
    // borrowerSelectsBasicBid
    // public {
    //     vm.startPrank(lender);
    //     vm.expectRevert("Cannot claim collertal until duration of loan is over.");
    //     loanMarketPlace.claimCollateral(0);
    //     vm.stopPrank();
    // }


    // /*//////////////////////////////////////////////////////////////
    //                            MODIFIERES
    // //////////////////////////////////////////////////////////////*/
    // modifier adminAddsCollateralTokenToApprovedCollateralTokens() {
    //     vm.prank(admin);
    //     loanMarketPlace.approvedOrDenyCollateralToken(collateralTokenAddress, true);
    //     _;
    // }

    // modifier borrowerMakesAccount() {
    //     vm.prank(borrower);
    //     loanMarketPlace.makeNewAccount();
    //     _;
    // }

    // modifier lenderMakesAccount() {
    //     vm.prank(lender);
    //     loanMarketPlace.makeNewAccount();
    //     _;
    // }

    // modifier borrowerSubmitsBasicLoan() {
    //     vm.prank(borrower);
    //     loanMarketPlace.submitLoanRequest(defaultBorrowAmount, borrowTokenAddress, defaultLoanTime, collateralTokenAddress, defaultCollateralAmount); 
    //     _;
    // }

    // modifier lenderSubmitsBasicBid() {
    //     vm.prank(lender);
    //     loanMarketPlace.createBid(0, defaultAPROffer); // Lender creates bid - APR in basis points (e.g., 500 for 5%)
    //     _;
    // }

    // modifier borrowerApprovedCollateral() {
    //     vm.prank(borrower);
    //     CollateralToken.approve(address(loanMarketPlace), defaultCollateralAmount);
    //     _;
    // }

    // modifier lenderApprovedCollateral() {
    //     vm.prank(lender);
    //     TokenToBeBorrowed.approve(address(loanMarketPlace), defaultBorrowAmount);
    //     _;
    // }

    // modifier borrowerSelectsBasicBid() {
    //     vm.warp(block.timestamp + 7 days + 1); // Warp time by 7 days
    //     vm.prank(borrower);
    //     loanMarketPlace.selectBid(0, 0);
    //     _;
    // }


}