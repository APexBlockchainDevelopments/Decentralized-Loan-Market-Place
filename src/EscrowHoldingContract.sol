//SDPX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {LoanMarketPlace} from "./LoanMarketPlace.sol";

contract EscrowHoldingContract{

    //This contract will act as the "holding contract" for collateral totals. 
    //It should be ownabled by the main contract and only the main contract and withdrawn funds / liquidate collateral

}