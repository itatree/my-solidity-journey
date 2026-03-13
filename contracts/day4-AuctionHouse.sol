/*
要点：
1.provate 守护核心数据/ external 只允许外部调用
2.constructor定初始规则，一般owner = msg.sender
3.block.timestamp 当前区块时间:掌管时间节奏自动化追踪
4.函数参数（用户输入）vs区块链内置变量（区块链自动提供），amount/msg.sender,msg.value,block.timestamp,block.number
*/
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AuctionHouse {
    address public owner;
    string public item;
    uint public auctionEndTime;//卖品和所有人和结束时间
    address private highestBidder; // Winner is private, accessible via getWinner 赢家是私人的，可通过getWinner访问
    uint private highestBid;       // Highest bid is private, accessible via getWinner 最高出价是私人的，可通过getWinner访问
    bool public ended;//拍卖是否结束

    mapping(address => uint) public bids;//数据类型 + 可见性 + 变量名
    address[] public bidders;

    // Initialize the auction with an item and a duration 用物品和持续时间初始化拍卖
    //constructor构造函数，部署合约时自动执行，通常用来初始化变量
    constructor(string memory _item, uint _biddingTime) {
        owner = msg.sender;//部署合约的操作者地址→合约管理员
        item = _item;
        auctionEndTime = block.timestamp + _biddingTime;
    }

    // Allow users to place bids 允许用户出价
    function bid(uint amount) external {
        require(block.timestamp < auctionEndTime, "Auction has already ended.");//检查交易是否结束
        require(amount > 0, "Bid amount must be greater than zero.");//通过要求，没通过就发后面的警告
        require(amount > bids[msg.sender], "New bid must be higher than your current bid.");

        // Track new bidders 追踪新的投标人
        if (bids[msg.sender] == 0) {
            bidders.push(msg.sender);//保存地址
        }

        bids[msg.sender] = amount;///记录出价

        // Update the highest bid and bidder 更新最高出价和竞标者
        if (amount > highestBid) {
            highestBid = amount;
            highestBidder = msg.sender;
        }
    }

    // End the auction after the time has expired 时间到期后终止拍卖
    function endAuction() external {//外部调用，external
        require(block.timestamp >= auctionEndTime, "Auction hasn't ended yet.");
        require(!ended, "Auction end already called.");

        ended = true;
    }

    // Get a list of all bidders 获得所有投标人的名单
    function getAllBidders() external view returns (address[] memory) {
        return bidders;
    }

    // Retrieve winner and their bid after auction ends 在拍卖结束后取回获胜者和他们的出价
    function getWinner() external view returns (address, uint) {
        require(ended, "Auction has not ended yet.");
        return (highestBidder, highestBid);
    }
}
