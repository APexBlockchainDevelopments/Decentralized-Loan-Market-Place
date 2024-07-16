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
import {Library} from "./libraries/Library.sol";

contract LoanMarketPlace is Ownable{

    uint256 private accountIds; //Used to keep track of Accounts
    uint256 private loanIds;  //Used to keep track of loans

    mapping(address => bool) private approvedCollateralTokens; //Used for tokens that are approved for collateral usage. 

    mapping(address => Library.Account) private accounts; // Mapping to track existence of proposedLoans
    mapping(address => bool) private accountExists;     // Mapping to track existence of accounts | "Does 0x0123 have an account?"
    mapping(uint256 => Library.Loan) private loans; // Mapping to track existence of proposedLoans    
    mapping(uint256 loanId => mapping(uint256 bidId=> Library.Bid)) private loanOffers; // Create a separate mapping for offers

    constructor() Ownable(msg.sender){}

    receive() external payable {}

    fallback() external payable {revert();}

    /**
     * @param _token This is the name of the item to be associated with the item for sale
     * @param _approval Description of the item for sale
     * @dev This function allows users to add items to the marketplace. 
     */
    function approvedOrDenyCollateralToken(address _token, bool _approval) public onlyOwner {

        //This function doubles as a blacklist function if a token has some type of issues allowing the admins to disable it or enable it if it's deemed fit
        approvedCollateralTokens[_token] = _approval;

    }

    function makeNewAccount() public {
        require(!accountExists[msg.sender], "Account already exists");
        Library.Account memory newAccount = Library.Account({
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
        accountExists[msg.sender] = true;
        accountIds++;
    }


    function submitLoanRequest(
        uint256 amount, 
        address tokenToBorrow, 
        uint256 duration, 
        address collateralToken,
        uint256 collateralAmount) 
        public 
        returns(uint256)
        {
        
        require(accountExists[msg.sender], "Account does not exist");
        require(approvedCollateralTokens[collateralToken], "Collateral Token Not Approved");
        require(duration > 3600, "Loan Duration too Short");
        require(amount != 0, "Loan Amount cannot be zero");

        Library.Loan memory newLoan; 
        newLoan.loanStatus = Library.LoanStatus.Proposed;
        newLoan.loanId = loanIds;
        newLoan.borrower = msg.sender;
        newLoan.loanToken = tokenToBorrow;
        newLoan.amount = amount;
        newLoan.creationTimeStamp = block.timestamp;
        newLoan.duration = duration;
        newLoan.startTime = 0;
        newLoan.collateralToken = collateralToken;  
        newLoan.collateralAmount = collateralAmount;
        newLoan.bid = Library.defaultBid();
        
        loans[loanIds] = newLoan; 
        loanIds++;

        return newLoan.loanId;
    }

    function createBid(uint256 _loanId, uint256 _APRoffer) public {
        Library.Loan storage loan = loans[_loanId];
        uint256 currentLoans = loan.bids;
        
        require(accountExists[msg.sender], "Account does not exist");
        require(loan.creationTimeStamp != 0, "Loan Does not exist");
        require(block.timestamp <= (loan.creationTimeStamp + 7 days), "Bidding period for this loan has ended");
        
        //create bid and add to mapping
        Library.Bid memory newBid = Library.Bid({
            bidId : currentLoans,
            loanId : _loanId,
            lender : msg.sender,
            APRoffer : _APRoffer,
            timeStamp : block.timestamp,
            accepted : false
        });

        loan.bids++;
        loanOffers[_loanId][currentLoans] = newBid;
    }


    //function to withdraw bid??

    function selectBid(uint256 _loanId, uint256 _selectedBid) public  {
        Library.Loan storage  selectedLoan = loans[_loanId];
        require(selectedLoan.borrower == msg.sender, "You are not the borrower of this loan");
        require(selectedLoan.bid.lender == address(0), "Bid has already been selected");
        require(selectedLoan.creationTimeStamp + 7 days <= block.timestamp, "Cannot select bid until bidding process is over");//make sure it's within timeframe
        require(selectedLoan.creationTimeStamp + 14 days >= block.timestamp, "Bidding peroid has ended, this loan is dead.");//make sure it's within timeframe
        

        Library.Bid storage selectedBid = loanOffers[_loanId][_selectedBid];
        require(selectedBid.lender != address(0), "Bid does not exist"); //make sure bid is legit, borrower can't select bid that doesn't exist

        selectedBid.accepted = true;
        selectedLoan.bid = selectedBid;
        selectedLoan.loanStatus = Library.LoanStatus.InProgress;
        selectedLoan.startTime = selectedLoan.duration + block.timestamp;

        
        IERC20(selectedLoan.loanToken).transferFrom(selectedLoan.bid.lender, selectedLoan.borrower, selectedLoan.amount);
        IERC20(selectedLoan.collateralToken).transferFrom(selectedLoan.borrower, address(this), selectedLoan.collateralAmount);

        ///What happens if approval is recalled? Ding their account???

        //Update Account Data
    }

    function repayLoan(uint256 _loanId) public {
        Library.Loan storage  selectedLoan = loans[_loanId];
        require(selectedLoan.borrower == msg.sender, "You are not the borrower of this loan");
        require(block.timestamp <= selectedLoan.startTime + selectedLoan.duration, "Loan repayment period has ended");
        require(selectedLoan.loanStatus == Library.LoanStatus.InProgress, "Loan is not in Progress");

        //Not necessary?
        //uint256 allowedAmount = IERC20(selectedLoan.loanToken).allowance(selectedLoan.borrower, address(this));//Check If this contract is approved to transfer tokens
        //what do if tokens are transferred out side of this contract? 
        uint256 totalAmountToBeRepaid = selectedLoan.amount + calculateInterest(selectedLoan.amount, selectedLoan.bid.APRoffer, selectedLoan.duration);
        IERC20(selectedLoan.loanToken).transferFrom(selectedLoan.borrower, selectedLoan.bid.lender, totalAmountToBeRepaid);// amount + APR

       
        IERC20(selectedLoan.collateralToken).transfer(selectedLoan.borrower, selectedLoan.collateralAmount); //need to pay back collatearl to borrower
        //Check to see if loan is enough
        selectedLoan.loanStatus = Library.LoanStatus.Repaid;

    }

    function claimCollateral(uint256 _loanId) public {
        //Lender can claim collateral if loan isn't repaid in time
        Library.Loan storage  selectedLoan = loans[_loanId];
        require(selectedLoan.bid.lender == msg.sender, "You are not the lender of this loan");
        require(block.timestamp >= selectedLoan.startTime + selectedLoan.duration, "Cannot claim collertal until duration of loan is over.");//make sure it's within timeframe

        selectedLoan.loanStatus = Library.LoanStatus.Defaulted;

        IERC20(selectedLoan.collateralToken).transfer(msg.sender, selectedLoan.collateralAmount);
    }


    //@params _duration is in seconds
    function calculateInterest(uint256 _amount, uint256 _apr, uint256 _duration) public pure returns (uint) {
        // Interest = loan amount * APR * (loan duration / 365 days) / 10000 (to account for basis points)
        uint interest = (_amount * _apr * _duration) / (365 days * 10000);
        return interest;
    }

    ////Getter Functions/////
    function getAccount(address accountAddress) public view returns(Library.Account memory){
        return accounts[accountAddress];
    }

    function getLoan(uint256 loanId) public view returns(Library.Loan memory){
        return loans[loanId];
    }

    function getBid(uint256 loanId, uint256 bidId) public view returns(Library.Bid memory){
        return loanOffers[loanId][bidId];
    }

    function checkIfTokenIsApprovedForCollateral(address _token) public view returns(bool) {
        return approvedCollateralTokens[_token];
    }

    function getAllBidsForProposedLoan(uint256 _loanId) public view returns(Library.Bid[] memory){
        //Get number of bids for proposedLoan
        //Desparately needs gas optimziation
        Library.Loan memory proposedLoan = loans[_loanId];
        uint256 bidsCount = proposedLoan.bids;
    
        Library.Bid[] memory bids = new Library.Bid[](bidsCount);
    
        for(uint256 i = 0; i < bidsCount; i++){
            bids[i] = loanOffers[_loanId][i];
        }
        
        return bids;
    }

    function getSelectedBid(uint256 _loandId) public view returns(Library.Bid memory){
        return loans[_loandId].bid;
    }

    //function for getting all loans based on account
    //function for getting all bids based on account ..etc

    //build these out more just for individual viewing functions.... for example get loan amount based on loan ID....perhaps interface?
}
