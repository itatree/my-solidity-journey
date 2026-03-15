/*要点：
1.transfer()安全ETH传输，因为最多2300 gas限制
2.(bool success, ) = _to.call{value: _amount}("");
3.防止重入攻击，先balance再call
*/
//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleIOU{
    address public owner;
    
    // Track registered friends跟踪注册好友
    mapping(address => bool) public registeredFriends;
    address[] public friendList;//这里依旧是mapping+array的形式
    
    // Track balances跟踪余额
    mapping(address => uint256) public balances;
    
    // Simple debt tracking简单的债务跟踪
    mapping(address => mapping(address => uint256)) public debts; // debtor债务人 -> creditor债权人 -> amount
    //debts[debtor][creditor] = amount;

    //初始化
    constructor() {
        owner = msg.sender;//俺是银行经理！（复读
        registeredFriends[msg.sender] = true;
        friendList.push(msg.sender);//把俺这个管理员加进成员！
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }
    
    modifier onlyRegistered() {
        require(registeredFriends[msg.sender], "You are not registered");
        _;
    }
    
    // Register a new friend
    function addFriend(address _friend) public onlyOwner {
        require(_friend != address(0), "Invalid address");
        require(!registeredFriends[_friend], "Friend already registered");
        
        registeredFriends[_friend] = true;
        friendList.push(_friend);
    }
    
    // Deposit funds to your balance将资金存入您的余额
    function depositIntoWallet() public payable onlyRegistered {//复习！payable才能存入ETH
        require(msg.value > 0, "Must send ETH");
        balances[msg.sender] += msg.value;
    }
    
    // Record that someone owes you money记录某人欠你钱（债权人记录）
    function recordDebt(address _debtor, uint256 _amount) public onlyRegistered {
        require(_debtor != address(0), "Invalid address");
        require(registeredFriends[_debtor], "Address not registered");
        require(_amount > 0, "Amount must be greater than 0");
        
        debts[_debtor][msg.sender] += _amount;
    }
    
    // Pay off debt using internal balance transfer使用内部余额转账来偿还债务
    function payFromWallet(address _creditor, uint256 _amount) public onlyRegistered {
        require(_creditor != address(0), "Invalid address");
        require(registeredFriends[_creditor], "Creditor not registered");
        require(_amount > 0, "Amount must be greater than 0");
        require(debts[msg.sender][_creditor] >= _amount, "Debt amount incorrect");//输入金额小于等于债务
        require(balances[msg.sender] >= _amount, "Insufficient balance");//余额够
        
        // Update balances and debt更新余额和债务
        balances[msg.sender] -= _amount;
        balances[_creditor] += _amount;//两方余额变动
        debts[msg.sender][_creditor] -= _amount;//账本变动
    }
    
    // Direct transfer method using transfer()使用transfer的直接转账方法
    /*function transferEther(address payable _to, uint256 _amount) public onlyRegistered {
        require(_to != address(0), "Invalid address");
        require(registeredFriends[_to], "Recipient not registered");
        require(balances[msg.sender] >= _amount, "Insufficient balance");

        balances[msg.sender] -= _amount;
        _to.transfer(_amount); //语法是：recipientAddress.transfer(amount);但是因为gas限制没办法对智能合约发送 
        balances[_to]+=_amount;
    }
    */
    function transferEtherViaCall(address payable _to, uint256 _amount) public onlyRegistered {
        require(_to != address(0), "Invalid address");
        require(registeredFriends[_to], "Recipient not registered");
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        
        balances[msg.sender] -= _amount;//防止重入攻击，先balance再call

    //(bool success, )？多返回值接收语法，逗号后面不写代表我不需要,忽略。
    /*("")？：原本.call()设计是address.call(date),调用某个合约函数。例如contract.call(abi.encodeWithSignature("foo()"))，调用foo()函数。
    那我只转ETH，不调用函数呢？那就调用空数据。*/
        (bool success, ) = _to.call{value: _amount}("");//向_to地址发送_amount
        balances[_to]+=_amount;
        require(success, "Transfer failed");
    }
    
    // Withdraw your balance
    function withdraw(uint256 _amount) public onlyRegistered {
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        
        balances[msg.sender] -= _amount;
        
        (bool success, ) = payable(msg.sender).call{value: _amount}("");
        require(success, "Withdrawal failed");
    }
    
    // Check your balance
    function checkBalance() public view onlyRegistered returns (uint256) {
        return balances[msg.sender];
    }
}
