//SDPX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {LoanMarketPlace} from "./LoanMarketPlace.sol";

contract TokenManagerContract{

    //This contract will act as the "NFT issuer / NFT manager" of lenders who set up loans.
    //Users should be able to sell a NFT as a symbol of the loan, New owner gets payments / has control

}