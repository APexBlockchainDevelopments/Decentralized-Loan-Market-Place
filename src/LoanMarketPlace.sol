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

contract LoanMarketPlace is Ownable{

    uint256 private accountIds;
    uint256 private loanIds;

    mapping(address => AccountLibrary.Account) private accounts; // Mapping to track existence of proposedLoans
    mapping(address => bool) private accountExists;     // Mapping to track existence of accounts | "Does 0x0123 have an account?"
    mapping(uint256 => AccountLibrary.Loan) private proposedLoans; // Mapping to track existence of proposedLoans    
    mapping(uint256 loanId => mapping(uint256 bidId=> AccountLibrary.Bid)) private loanOffers; // Create a separate mapping for offers

    mapping(address => bool) private approvedCollateralTokens; //Used for tokens that are approved for collateral usage. 


    constructor() Ownable(msg.sender){}

    function approvedOrDenyCollateralToken(address _token, bool _approval) public onlyOwner {
        //Possible check to see if address is ERC-20?
        //This function doubles as a blacklist function if a token has some type of issues allowing the admins to disable it or enable it if it's deemed fit
        approvedCollateralTokens[_token] = _approval;

    }

    
    receive() external payable {}

    fallback() external payable {
        revert();
    }

    function makeNewAccount() public {
        require(!accountExists[msg.sender], "Account already exists");
        AccountLibrary.Account memory newAccount = AccountLibrary.Account({
            wallet : msg.sender,
            accountId : accountIds,
            creationTimeStamp : block.timestamp,
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

        AccountLibrary.Loan storage newLoan = proposedLoans[loanIds]; //optimize this gas usage here, use memory then push to storage
        newLoan.loanStatus = AccountLibrary.LoanStatus.Proposed;
        newLoan.loanId = loanIds;
        newLoan.borrower = msg.sender;
        newLoan.loanToken = tokenToBorrow;
        newLoan.amount = amount;
        newLoan.creationTimeStamp = block.timestamp;
        newLoan.duration = duration;
        newLoan.collateralToken = collateralToken;  
        newLoan.collateralAmount = collateralAmount; //Potentially Collateral Amount could be zero, however that is up to the Lenders to decide to lend to someone with no collateral upfront
        newLoan.bid = AccountLibrary.defaultBid();
        loanIds++;


        IERC20(newLoan.collateralToken).approve(address(this), newLoan.collateralAmount);//approve tokens at this point??
        //What if this is ETH?
    }

    function createBid(uint256 _loanId, uint256 _APRoffer) public {
        uint256 proposedLoanCreationDate = proposedLoans[_loanId].creationTimeStamp; // needs gas effecientcy rewrite
        uint256 currentLoans = proposedLoans[_loanId].bids; // needs gas effecientcy rewrite
        
        require(accountExists[msg.sender], "Account does not exist");
        require(proposedLoanCreationDate != 0, "Loan Does not exist");//check if bidding peroid ongoing check if loan exists
        require(block.timestamp <= (proposedLoanCreationDate + 7 days), "Bidding period for this loan has ended"); //check if bidding peroid ongoing
        
        //create bid and add to mapping
        AccountLibrary.Bid memory newBid = AccountLibrary.Bid({
            bidId : currentLoans,
            loanId : _loanId,
            lender : msg.sender,
            APRoffer : _APRoffer,
            timeStamp : block.timestamp,
            accepted : false
        });

        proposedLoans[_loanId].bids++;   // needs gas effecientcy rewrite
        loanOffers[_loanId][currentLoans] = newBid;

        
        IERC20(proposedLoans[_loanId].loanToken).approve(address(this), proposedLoans[_loanId].amount);//approve tokens at this point??
    }

    function selectBid(uint256 _loanId, uint256 _selectedBid) public {
        AccountLibrary.Loan storage  selectedLoan = proposedLoans[_loanId];
        require(selectedLoan.borrower == msg.sender, "You are not the owner of this loan"); //make sure its the bid owner
        require(selectedLoan.bid.lender == address(0), "Bid has already been selected");
        require(selectedLoan.creationTimeStamp + 7 days >= block.timestamp, "Cannot select bid until bidding process is over");//make sure it's within timeframe
        require(selectedLoan.creationTimeStamp + 14 days <= block.timestamp, "Bidding peroid has ended, this loan is dead.");//make sure it's within timeframe
        

        AccountLibrary.Bid storage selectedBid = loanOffers[_loanId][_selectedBid];
        require(selectedBid.lender != address(0), "Bid does not exist"); //make sure bid is legit, borrower can't select bid that doesn't exist

        selectedLoan.bid = selectedBid;
        selectedBid.accepted = true;
        
        //update user stats

        //transfer tokens and collateral
        IERC20(selectedLoan.loanToken).transfer(selectedLoan.borrower, selectedLoan.amount);
        //Escrow Collateral
        IERC20(selectedLoan.collateralToken).transfer(address(this), selectedLoan.collateralAmount);

        //Update 
    }



    ////Getter Functions/////
    function getAccount(address accountAddress) public view returns(AccountLibrary.Account memory){
        return accounts[accountAddress];
    }

    function getProposedLoan(uint256 loanId) public view returns(AccountLibrary.Loan memory){
        return proposedLoans[loanId];
    }

    function checkIfTokenIsApprovedForCollateral(address _token) public view returns(bool) {
        return approvedCollateralTokens[_token];
    }

    function getAllBidsForProposedLoan(uint256 _loanId) public view returns(AccountLibrary.Bid[] memory){
        //Get number of bids for proposedLoan
        //Desparately needs gas optimziation
        AccountLibrary.Bid[] memory bids;
        AccountLibrary.Loan memory proposedLoan = proposedLoans[_loanId];

        if(proposedLoan.bids == 0){
            return bids;
        } else {
            for(uint256 i; i< proposedLoan.bids; i++){
                bids[i] = loanOffers[_loanId][i];
            }
            return bids;
        }
    }

    //build these out more just for individual viewing functions.... for example get loan amount based on loan ID
}


//TODO esparate Escrow holding contract