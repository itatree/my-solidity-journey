/*要点：
1.payable 表示该函数可以接收以太币。没有它，别人发来的以太币都会被拒收。
→ msg.value 表示用户在交易中发送的以太币数量（单位是 wei ，以太币最小的计量单位）。
2.web3概念里，现实余额和合约记录金额是两套。Difi合约就是两套组合起来 →真实资金（address(this).balance)+内部账本（mapping的balance）
3.以太币存款：用户调用depositAmountEther从钱包发送ETH → msg.value=发送的ETH数量 → 合约账户收到ETH → 内部账本更新balance[msg.sender] += msg.value;
*/
//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract EtherPiggyBank{

    //there should be a bank manager who has the certain permissions应该有一个拥有一定权限的银行经理
    address public bankManager;
    address[] members;//there should be an array for all members registered应该有一个包含所有注册成员的数组
    mapping(address => bool) public registeredMembers;//a mapping whether they are registered or not映射他们是否已注册
    mapping(address => uint256) balance;//a mapping with there balances映射余额（不需要公开

    constructor(){
        bankManager = msg.sender;//俺是银行经理！
        members.push(msg.sender);//俺是成员！
        registeredMembers[msg.sender] = true;//俺可以存钱
    }
    //俺要声明俺的权限了！
    modifier onlyBankManager(){
        require(msg.sender == bankManager, "Only bank manager can perform this action");
        _;
    }
    //俺成员的权限
    modifier onlyRegisteredMember() {
        require(registeredMembers[msg.sender], "Member not registered");
        _;
    }
    //添加成员（但只有俺可以做到！
    function addMembers(address _member)public onlyBankManager{
        require(_member != address(0), "Invalid address");//不是无效地址
        require(_member != msg.sender, "Bank Manager is already a member");//输入的地址不是俺
        require(!registeredMembers[_member], "Member already registered");//没有注册（在mapping里面查找一番）
        registeredMembers[_member] = true;//修改key对应的value
        members.push(_member);//状态改变后上链，push进数组里
    }
    //mapping没有遍历，这边get方便查询地址数组address[]
    function getMembers() public view returns(address[] memory){
        return members;
    }
    /*deposit amount 模拟储蓄
    function depositAmount(uint256 _amount) public onlyRegisteredMember{
         require(_amount > 0, "Invalid amount");
         balance[msg.sender] = balance[msg.sender]+_amount;
    }
    /模拟取钱
    function withdraw(uint256 _amount) public onlyRegisteredMember {
        require(_amount > 0, "Invalid amount");
        require(balance[msg.sender] >= _amount, "Insufficient balance");/余额足够
        balance[msg.sender] -= _amount;
    } */
    
    //deposit in Ether以太币存款。
    //用户调用depositAmountEther从钱包发送ETH → msg.value=发送的ETH数量 → 合约账户收到ETH → 内部账本更新balance[msg.sender] += msg.value;
    function depositAmountEther() public payable onlyRegisteredMember{  
        require(msg.value > 0, "Invalid amount");
        balance[msg.sender] += msg.value;
    //  balance[msg.sender] = balance[msg.sender]+msg.value;
    }
    
    function withdrawAmount(uint256 _amount) public onlyRegisteredMember{
        require(_amount > 0, "Invalid amount");
        require(balance[msg.sender] >= _amount, "Insufficient balance");
        balance[msg.sender] = balance[msg.sender]-_amount;
   //   payable(msg.sender).tranfer(_amount);/真实取钱（提现后转账）
    }

    function getBalance(address _member) public view returns (uint256){
        require(_member != address(0), "Invalid address");
        return balance[_member];
    } 
}
