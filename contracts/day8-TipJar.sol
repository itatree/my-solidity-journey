/*要点
1.货币汇率:因为1ETH=10^18wei → 1美元= 0.0005 ETH，即5 * 10^14。计算外币就用amount*5*10^14这样，得出ETH。
2.Solidity 不适用于小数。没有浮点数，没有分数。所有货币数学都保留在链上的 wei 中。人类可读的 ETH 来自链下格式化。
3.字符串不能直接比较。使用keccak256(bytes(a)) == keccak256(bytes(b))对比hash
*/
//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TipJar {
    address public owner;
    uint256 public totalTipsReceived;//合约总体上收集了多少 ETH（以 wei 为单位）*受到了多少打赏。

    mapping(string => uint256) public conversionRates;// 存储从货币代码（eg.U）到 ETH 的汇率。
    string[] public supportedCurrencies;  // List of supported支持 currencies货币
    //依旧array配mapping

    mapping(address => uint256) public tipPerPerson;//用户打赏记录
    mapping(string => uint256) public tipsPerCurrency;//跟踪了每种货币的打赏总额。因此，如果有人发送等值 2000 美元，我们会在“USD”条目下存储“2000”
    
    constructor() {
        owner = msg.sender;
        addCurrency("USD", 5 * 10**14);  // 1 USD = 0.0005 ETH
        addCurrency("EUR", 6 * 10**14);  // 1 EUR = 0.0006 ETH
        addCurrency("JPY", 4 * 10**12);  // 1 JPY = 0.000004 ETH
        addCurrency("INR", 7 * 10**12);  // 1 INR = 0.000007ETH ETH
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }
    
    // Add or update a supported currency添加或修改货币汇率
    function addCurrency(string memory _currencyCode, uint256 _rateToEth) public onlyOwner {
        require(_rateToEth > 0, "Conversion rate must be greater than 0");//防止写入无效数据

        // Check if currency already exists检查货币是否已存在
        bool currencyExists = false;//检测货币是否存在
        for (uint i = 0; i < supportedCurrencies.length; i++) {//遍历数组进行对比，避免重复
         //字符串比较。因为solidity不能直接比较string，其中的字符串是存储在内存中的复杂类型（动态数组），而不是原始值。
         /*所以需要将字符串转换为字节数组，然后使用keccak256哈希函数计算哈希值，再进行比较：
         使用 `bytes(...)`然后将这些字节传递给叫做 `keccak256()`的内置加密哈希函数（这会使数据变成一个固定长度的值），相同内容→相同hash。
         如果哈希值匹配，则意味着字符串相等，并且我们知道货币已经存在。因此，我们设置了 `currencyExists = true` 并脱离循环。
         这种方法是在 Solidity 中比较字符串的一种安全可靠的方法，也是您在链上处理动态文本值时要记住的一个很好的技巧。*/
            if (keccak256(bytes(supportedCurrencies[i])) == keccak256(bytes(_currencyCode))) {
                currencyExists = true;
                break;
            }
        }
        // Add to the list if it's new如果它是新的（currencyExists=false）则添加到列表中
        if (!currencyExists) {
            supportedCurrencies.push(_currencyCode);
        }
        // Set the conversion rate设置转换率
        conversionRates[_currencyCode] = _rateToEth;// 1 ETH = 1,000,000,000,000,000,000 wei = 10^18 wei
    }
    //换算
    function convertToEth(string memory _currencyCode, uint256 _amount) public view returns (uint256) {
        require(conversionRates[_currencyCode] > 0, "Currency not supported");
        uint256 ethAmount = _amount * conversionRates[_currencyCode];//输入的量乘以汇率，就是ETH的量
        return ethAmount;
    }
    
    // Send a tip in ETH directly直接用ETH打赏
    function tipInEth() public payable {
        require(msg.value > 0, "Tip amount must be greater than 0");
        tipPerPerson[msg.sender] += msg.value;//记录该账户
        totalTipsReceived += msg.value;//更新到合约总收集数
        tipsPerCurrency["ETH"] += msg.value;//更新到“ETH”中，方便不同货币分开管理
    }
    //外币打赏
    function tipInCurrency(string memory _currencyCode, uint256 _amount) public payable {
        require(conversionRates[_currencyCode] > 0, "Currency not supported");//货币合法（存在
        require(_amount > 0, "Amount must be greater than 0");
        uint256 ethAmount = convertToEth(_currencyCode, _amount);//换算
        require(msg.value == ethAmount, "Sent ETH doesn't match the converted amount");//检查用户发送金额和合约换算后的金额
        tipPerPerson[msg.sender] += msg.value;
        totalTipsReceived += msg.value;
        tipsPerCurrency[_currencyCode] += _amount;
    }
    //提现，但是只有owner能取
    function withdrawTips() public onlyOwner {
        uint256 contractBalance = address(this).balance;//获取合约当前的 ETH 余额
        require(contractBalance > 0, "No tips to withdraw");
        (bool success, ) = payable(owner).call{value: contractBalance}("");//发送ETH（有success标志更有效更安全）
        require(success, "Transfer failed");
        totalTipsReceived = 0;//重置总收集数为0（清除合约账本记录）
    }
    //换行长
    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != address(0), "Invalid address");
        owner = _newOwner;
    }
    //支持的货币
    function getSupportedCurrencies() public view returns (string[] memory) {
        return supportedCurrencies;
    }
    
    //当前合约的余额
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }
    
    //某人打赏金额
    function getTipperContribution(address _tipper) public view returns (uint256) {
        return tipPerPerson[_tipper];
    }
    
    //某货币总打赏
    function getTipsInCurrency(string memory _currencyCode) public view returns (uint256) {
        return tipsPerCurrency[_currencyCode];
    }
    //汇率查询
    function getConversionRate(string memory _currencyCode) public view returns (uint256) {
        require(conversionRates[_currencyCode] > 0, "Currency not supported");
        return conversionRates[_currencyCode];
    }
}
