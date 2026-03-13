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
    //constructor构造函数，部署合约时自动执行，通常用来初始化变量·设置owner·设置初始参数
    constructor(string memory _item, uint _biddingTime) {
        owner = msg.sender;//部署合约的操作者地址→owner
        item = _item;
        auctionEndTime = block.timestamp + _biddingTime;
    }

    // Allow users to place bids 允许用户出价
    function bid(uint amount) external {
        require(block.timestamp < auctionEndTime, "Auction has already ended.");//检查交易是否结束
        require(amount > 0, "Bid amount must be greater than zero.");
        require(amount > bids[msg.sender], "New bid must be higher than your current bid.");

        // Track new bidders 追踪新的投标人
        if (bids[msg.sender] == 0) {
            bidders.push(msg.sender);
        }

        bids[msg.sender] = amount;

        // Update the highest bid and bidder 更新最高出价和竞标者
        if (amount > highestBid) {
            highestBid = amount;
            highestBidder = msg.sender;
        }
    }

    // End the auction after the time has expired 时间到期后终止拍卖
    function endAuction() external {
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
