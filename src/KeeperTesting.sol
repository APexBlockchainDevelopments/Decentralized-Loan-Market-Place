//Probalby use Chainlink Automation
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/automation/interfaces/KeeperCompatibleInterface.sol";

//testing address on sepolia: 0x027AE10A38d030a98CE1c328e947051AC0c6D299
///SAMPLE CONTRACT
contract KeeperTesting is KeeperCompatibleInterface {

     //counter variable
     uint public counter;
    
     //function to test your counter
     function increaseCounter() public {
         counter += 1;
     }
     
     //used to view the current block.timestamp
     function timeStamp() public view returns (uint) {
         return block.timestamp;
     }
 
     // check to see if the block.timestamp is divisible by 7
     // if true call the performUpkeep function
     function checkUpkeep(bytes calldata /* checkData */) external override returns (bool upkeepNeeded, bytes memory /* performData */) {
         upkeepNeeded = (block.timestamp % 7 == 0);
     }
     //if the block.timestamp is divisible by 7 increase the counter (function checkUpkeep above)
     //keeper will perform update
     function performUpkeep(bytes calldata /* performData */) external override {
         counter = counter + 1;
     }

    // Fallback function to receive ETH
    receive() external payable {}
}

