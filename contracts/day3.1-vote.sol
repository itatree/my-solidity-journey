// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract Vote {
    uint public voteCount;
    mapping(address => bool) public voted;//防止重复(bool两个值：true  （是）false （否）)
    function vote() public {
        require(!voted[msg.sender], "Already voted");//！投过就拒绝
        voted[msg.sender] = true;
        voteCount++;
    }
}
