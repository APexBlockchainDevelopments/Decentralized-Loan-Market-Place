//Probalby use Chainlink Automation
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/KeeperCompatibleInterface.sol";


///SAMPLE CONTRACT
contract AutoCollection is KeeperCompatibleInterface {

    // Function that can be called by anyone or by Chainlink Keeper to claim collateral
    function claimCollateral(uint256 loanId) public {
        Loan storage loan = loans[loanId];
        require(block.timestamp > loan.repaymentDeadline, "Repayment deadline has not passed yet");
        require(!loan.repaid, "Loan already repaid");
        require(msg.sender == loan.lender, "Only lender can claim collateral");

        // Transfer collateral to the lender
        (bool success, ) = loan.lender.call{value: loan.collateralAmount}("");
        require(success, "Collateral transfer failed");

        // Mark the loan as repaid to prevent re-entrancy
        loan.repaid = true;

        emit CollateralClaimed(loanId);
    }

    // Chainlink Keeper function to check if any loans need collateral to be claimed
    function checkUpkeep(bytes calldata /* checkData */) external view override returns (bool upkeepNeeded, bytes memory performData) {
        upkeepNeeded = false;
        for (uint256 i = 0; i < loans.length; i++) {
            if (block.timestamp > loans[i].repaymentDeadline && !loans[i].repaid) {
                upkeepNeeded = true;
                performData = abi.encode(i);
                break;
            }
        }
    }

    // Chainlink Keeper function to perform the upkeep
    function performUpkeep(bytes calldata performData) external override {
        uint256 loanId = abi.decode(performData, (uint256));
        claimCollateral(loanId);
    }

    // Fallback function to receive ETH
    receive() external payable {}
}

