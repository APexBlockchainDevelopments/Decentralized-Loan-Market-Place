//Probalby use Chainlink Automation
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/automation/interfaces/KeeperCompatibleInterface.sol";


///SAMPLE CONTRACT
contract AutoCollection is KeeperCompatibleInterface {

    // Chainlink Keeper function to check if any loans need collateral to be claimed
    function checkUpkeep(bytes calldata /* checkData */) external view override returns (bool upkeepNeeded, bytes memory performData) {
        // upkeepNeeded = false;
        // for (uint256 i = 0; i < loans.length; i++) {
        //     if (block.timestamp > loans[i].repaymentDeadline && !loans[i].repaid) {
        //         upkeepNeeded = true;
        //         performData = abi.encode(i);
        //         break;
        //     }
        // }
    }

    // Chainlink Keeper function to perform the upkeep
    function performUpkeep(bytes calldata performData) external override {
        // uint256 loanId = abi.decode(performData, (uint256));
        // claimCollateral(loanId);
    }

    // Fallback function to receive ETH
    receive() external payable {}
}

