//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
//`"./"` 部分告诉 Solidity： “查看与这个文件相同的目录（或文件夹）中，找到xxx.sol”
import "./day9-ScientificCalculator.sol";

contract Calculator{

    address public owner;
    address public scientificCalculatorAddress;//scientificCalculatorAddress 是我们存放已部署的 ScientificCalculator 地址的地方

    constructor(){
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can do this action");
         _; 
    }
   //ScientificCalculator 合约部署完成，可以将它的地址粘贴到这里。此函数会保存该地址，以便调用
    function setScientificCalculator(address _address)public onlyOwner{
        scientificCalculatorAddress = _address;
        }

    function add(uint256 a, uint256 b)public pure returns(uint256){
        uint256 result = a+b;
        return result;
    }

    function subtract(uint256 a, uint256 b)public pure returns(uint256){
        uint256 result = a-b;
        return result;
    }

    function multiply(uint256 a, uint256 b)public pure returns(uint256){
        uint256 result = a*b;
        return result;
    }

    function divide(uint256 a, uint256 b)public pure returns(uint256){
        require(b!= 0, "Cannot divide by zero");
        uint256 result = a/b;
        return result;
    }

    function calculatePower(uint256 base, uint256 exponent)public view returns(uint256){
    //地址强制类型转换（cast）。告诉solidity，这里有个区块链上的地址。我知道它指向一个 ScientificCalculator合约。请把它当作一个合约来处理，这样我才能调用它的函数。
    ScientificCalculator scientificCalc = ScientificCalculator(scientificCalculatorAddress);//赋值变量。类型是ScientificCalculator。然后把地址当成合约来看。

    //external call 外部调用
    uint256 result = scientificCalc.power(base, exponent);

    return result;

}

    function calculateSquareRoot(uint256 number)public returns (uint256){
        require(number >= 0 , "Cannot calculate square root of negative nmber");
        bytes memory data = abi.encodeWithSignature("squareRoot(int256)", number);//ABI 代表应用程序二进制接口。abi.encodeWithSignature构建了 EVM 在调用特定函数时期望的确切二进制格式。
        //↑把“我要调用哪个函数 + 参数”打包成一段二进制数据↑相当于"我要调用 squareRoot，参数是 number"

        //.call(data)将这些数据（指success和returnData）发送到存储在scientificCalculatorAddress中的地址。
        (bool success, bytes memory returnData) = scientificCalculatorAddress.call(data);
        require(success, "External call failed");
        uint256 result = abi.decode(returnData, (uint256));//解码
        return result;
    }

    
}
