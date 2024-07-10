//SDPX-License-Identifier: MIT

pragma solidity ^0.8.20;

import {AccountLibrary} from "../src/libraries/Library.sol";
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


    function setUp() public {
        vm.startPrank(admin);
        loanMarketPlace = new LoanMarketPlace();

        TokenToBeBorrowed = new MockToken(100e18, "Borrow Token", "BT");
        borrowTokenAddress = address(TokenToBeBorrowed);

        CollateralToken = new MockToken(100e18, "Collateral Token", "CT");
        collateralTokenAddress = address(CollateralToken);

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

    //------------------MODIFIER----------------------------------------------
    modifier adminAddsCollateralTokenToApprovedCollateralTokens() {
        vm.prank(admin);
        loanMarketPlace.approvedOrDenyCollateralToken(collateralTokenAddress, true);
        _;
    }
    //------------------MODIFIER----------------------------------------------


}