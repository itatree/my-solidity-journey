/*
要点
1.modifier修饰符 = 可以复用的函数执行规则，给函数加一个“自动检查步骤”包裹函数执行，方便做安检 → 统一规则，少重复，更安全
2.！表示逻辑取反（NOT）；！=表示不等于
3.address（0）也叫销毁地址，可以转移token销毁掉
4.function语法加强版
*/
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AdminOnly {//管理only
    // State variables /放置状态变量
    address public owner;//记录谁是owner
    uint256 public treasureAmount;//宝藏量/两个单一变量
    mapping(address => uint256) public withdrawalAllowance;//提款限额/两个映射
    mapping(address => bool) public hasWithdrawn;//bool有提款（因为只让提一次）
    
    constructor() {
        owner = msg.sender;
    }
    
    // Modifier for owner-only functions仅限所有者函数的修饰符，后续onlyOwner都会先走一遍modifier
    modifier onlyOwner() {
        require(msg.sender == owner, "Access denied: Only the owner can perform this action");//拒绝访问：只有所有者可以执行此操作
        _;//此_表示函数执行位置
    }
    
    // Only the owner can add treasure只有主人才能加宝藏
    function addTreasure(uint256 amount) public onlyOwner {
        treasureAmount += amount;
    }
    
    // Only the owner can approve withdrawals只有所有者可以批准提款
    function approveWithdrawal(address recipient, uint256 amount) public onlyOwner {//recipient接收者
        require(amount <= treasureAmount, "Not enough treasure available");//钱够
        withdrawalAllowance[recipient] = amount;//把recipient的Allowance设置成amount
    }   //recipient 这个地址的 allowance，因为是mapping这个容器，存储设定了这个人对应的地址（key，address）链接的金额（value,uint），所以用[]，查询出来
        //遇上这种[]都说明前面这个变量的数据类型是mapping
    
    
    // Anyone can attempt to withdraw, but only those with allowance will succeed任何人都可以尝试取款，但只有那些有限额的人才能成功
    function withdrawTreasure(uint256 amount) public {

        if(msg.sender == owner){
            require(amount <= treasureAmount, "Not enough treasury available for this action.");
            treasureAmount-= amount;

            return;
        }
        uint256 allowance = withdrawalAllowance[msg.sender];//看看你被允许取多少钱
        
        // Check if user has an allowance and hasn't withdrawn yet任何人都可以尝试取款，但只有那些有限额的人才能成功
        require(allowance > 0, "You don't have any treasure allowance");
        require(!hasWithdrawn[msg.sender], "You have already withdrawn your treasure");//！感叹号在前，还没取→true
        require(allowance <= treasureAmount, "Not enough treasure in the chest");
        require(allowance >= amount, "Cannot withdraw more than you are allowed"); // 检查输入数字小于等于限额/condition to check if user is withdrawing more than allowed
        
        // Mark as withdrawn and reduce treasure记录提款并减少宝藏
        hasWithdrawn[msg.sender] = true;//标记你取过了
        treasureAmount -= allowance;
        withdrawalAllowance[msg.sender] = 0;//额度清零（不管你取多少，因为只允许取一次
        
    }
    // Only the owner can reset someone's withdrawal status只有所有者可以重置某人的取款状态
    function resetWithdrawalStatus(address user) public onlyOwner {
        hasWithdrawn[user] = false;
    }
    
    // Only the owner can transfer ownership只有所有者才能转让所有权
    function transferOwnership(address newOwner) public onlyOwner {//modifier联合上下文知道newowner地址，因为是代码插入
        require(newOwner != address(0), "Invalid address");//“！=”是不等于的意思，==就是等于/地址是否是空地址，address（0）也叫销毁地址，可以转移token销毁掉
        owner = newOwner;
    }
    //function定义函数 函数名(参数) 可见性·谁可以调用 状态修饰符·状态说明·是否修改区块链 modifier·自定义函数修饰器 returns(返回值类型){
    //可见性 (public公开/ private私人/ external外部)，state mutability (view只读/ pure不可读只能算/payable可以接收ETH)，modifier
    function getTreasureDetails() public view onlyOwner returns (uint256) {
        return treasureAmount;//看余额
    }
}
