/*
Key concepts:
- string type 字符串类型
- public variables 公开变量
- memory keyword 内存关键字
- how functions update state 函数如何改变区块链状态
*/
// SPDX-License-Identifier:MIT

pragma solidity ^0.8.0;

contract SaveMyName{
//string x是状态变量（意味永久储存，存储在链上    
  string name;
  string bio;
/*function setProfile(string memory _name, string memory _bio) public {
    name = _name;
    bio = _bio; 
这段其实就是：
用户输入 name
↓
数据先存在 memory
↓
函数执行
↓
写入 storage
↓
区块链永久记录
*memory → storage 区块链状态改变
**代码常见 setProfile() getProfile()写法*/

/*为什么 string 一定要写 memory？因为在 Solidity 里：复杂类型必须说明存放位置。
  Storage (存在区块链，永久存储）Memory （存在临时内存，草稿纸，仅在函数运行时存在的临时存储空间，函数结束就消失）
  如果你不写，编译器会报错，因为它不知道你想存储在哪里。*/

  /*占位符_区分状态变量和函数参数，一眼就知道左边是链上数据，右边是输入数据
  _name用来接收用户输入，name = _name;表示把输入的名字存入状态变量name*/
  
function add (string memory _name, string memory _bio )public {
    name = _name;//编程语言中：等于号=是赋值，把右边的值放进左边的变量，而代码方向是 右 → 左 。所有其实是_name → name
    bio = _bio;
  }
  function retrieve() public view returns(string memory, string memory){
    return (name,bio);
  }
}
/*被标记为 view 的函数在被调用时不会消耗 gas。它只是获取并返回现有数据。（使函数可以自由调用，它不会修改区块链）
*所以 retrieve()可以免费调用——它不会在区块链上做任何改变。它只是读取并返回存储的名称和简介。
**return向调用它的任何人返回数据
**saveAndRetrieve需要消耗gas（组合可以更简短，但是可能会增加gas费*/

/*
1 定义状态
name
bio

↓
2 修改状态
setProfile()

↓
3 读取状态
retrieve()

智能合约最基础的结构
State

↓
Function (write)

↓
Function (read)
*/
/*区块链交易其实就是：
调用函数
→ 修改状态
→ 写入区块链
本合约其实就是：
状态（state）
name
bio

↓
函数（function）

setProfile()

↓
改变状态
name = 新名字
bio = 新简介
/*
*ClickCounter：
state
counter

function
click()

state change
counter +1

*SaveProfile：
state
name
bio

function
setProfile()

state change
更新资料

*投票合约：
state
voteCount

function
vote()

state change
票数+1
*/
