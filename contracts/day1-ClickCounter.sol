/*
Day1 – ClickCounter

合约作用：
记录按钮被点击的次数。

核心知识点：
1. uint256
   Solidity 中用于存储整数的类型

2. public
   让变量可以被外部读取

3. function
   定义合约可以执行的操作

4. counter++
   每次调用 click() 时，计数 +1

理解：
智能合约其实就是：
状态（变量） + 行为（函数）
Smart Contract = State + Functions
状态变量 + 修改状态的函数
*/
/*
Learning Notes – Day1 ClickCounter

Purpose:
This contract counts how many times a button is clicked.

Key Concepts：
- uint256: used to store numbers
- public: allows anyone to read the variable
- function: defines an action in the contract
- state variable: data stored on blockchain
- counter++: increase number by 1

Logic:
Every time someone calls the "click()" function,
the counter will increase by one.

Tools used:
Remix IDE + Solidity
*/

// SPDX-License-Identifier:MIT

pragma solidity ^0.8.0;
/*contract 定义一个智能合约（可放变量，函数，逻辑规则，部署后都无法更改）
变量counter函数click*/
contract ClickCounter{
/*uint = unsigned integer（无符号整数，不能存负数） 256 = 用256 bit来存这个数字）
public 任何人都可以调用这个函数，是Solidity设计亮点，编译器会自动生成一个读取函数。=自动生成 getter
*其实相当于背后生成了：
function counter() public view returns (uint) {
    return counter;
}
*/
    uint256 public counter ;

    function click() public {
        counter++;
    }
}
