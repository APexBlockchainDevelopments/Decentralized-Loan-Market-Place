// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {AccountLibrary} from "./libraries/Library.sol";

contract LoanMarketPlance {

    uint256 private accountIds;

    mapping(address => AccountLibrary.Account) private accounts;

    // Mapping to track existence of accounts
    mapping(address => bool) private accountExists;

    function makeNewAccount() public {
        require(!accountExists[_address], "Account already exists");
        AccountLibrary.Account memory newAccount = AccountLibrary.Account({
            wallet : msg.sender,
            accountId : accountIds,
            creationDate : block.timestamp,
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

    function getAccount(address accountAddress) public view returns(AccountLibrary.Account memory){
        return accounts[accountAddress];
    }
}