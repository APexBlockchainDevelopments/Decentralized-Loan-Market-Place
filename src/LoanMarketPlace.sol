// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {AccountLibrary} from "./libraries/Library.sol";

contract LoanMarketPlance {
    
    using AccountLibrary for AccountLibrary.Account;

    uint256 accountIds;

    mapping(uint256 => AccountLibrary.Account) accounts;

    function makeNewAccount() public {
        AccountLibrary.Account memory newAccount = AccountLibrary.Account({
            wallet : msg.sender,
            creationDate : block.timestamp,
            totalAmountBorrowed : 0,
            requestedLoans : 0,
            successfulLoansCompletedAndRepaid : 0,
            totalAmountRepaid : 0,
            totalAmountLent : 0,
            loanBids : 0,
            totalLoans : 0
        });

        accounts[accountIds] = newAccount;
    }
}