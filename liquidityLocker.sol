// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/*
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "@openzeppelin/contracts/access/Ownable.sol";
*/
import "../OZ/IERC20.sol";

import "../OZ/Ownable.sol";

contract liquidityLocker is Ownable{

uint256 refBlock;

address lpContract;

uint256 lockDays;

uint256 lockedBlocks; /* time locked will be calculated the following way 
 : lockDays is a number of days entered upon deployment of the contract,
   17280 comes from : (24hours * (60minutes per hour) * (60seconds per minute))/5seconds per block */

   /* timeLocked then gives us a block amount by multiplicating the number of desired days by the daily 
   number of blocks */ 


constructor (uint256 _lockDays, address lpAddress){
    lockDays = _lockDays;
    lpContract = lpAddress;
    lockedBlocks = (_lockDays*17280);
}

/* this is used for community members to validate the amount of days that the liquidity will be locked */

function getLockDays() external view returns(uint){
    return(lockDays);
}

/* this is used to get the time lock in block amount */

function getLockBlocks() external view returns(uint){
    return(lockedBlocks);
}

/* only used to validate that we have stored the right contract address */

function validateContract (address _lpAddress) external view returns(bool){
return(lpContract == _lpAddress);
}

/* stores the current block number upon call which will be used in time calculations */

function setRefBlock() external onlyOwner{
    refBlock = block.number;
}

/* calculates if the current block number is bigger than the refBlock plus the amount of time chosen */

function calculateTimeLocked() internal view returns(bool){
    uint256 time = block.number;
    return(time >= refBlock + lockedBlocks);
}

/* allows us to withdraw LP tokens only when the timer ends */

function withdrawLP () external onlyOwner {
    require (calculateTimeLocked(), "Trying to rugpull?!?");
    uint256 lpBalance = IERC20(lpContract).balanceOf(address(this));
    IERC20(lpContract).transfer(msg.sender, lpBalance);
}

}
