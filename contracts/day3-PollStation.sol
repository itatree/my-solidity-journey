/*核心知识点:
1.数组string[]+映射mapping（
2.编程语言规则：类型+变量名
3.编程语言其实本质是：名词（数据）+动词（行为）,比如：string,uint,address/vote(),click(),transfer()
4.array + mapping 模式，方便查找某人。 *数组负责列表，mapping负责数据（mapping不知道有多少个key，不能遍历，没有length，有默认值）(不用存index，省gas）
5.function语法
*/
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract PollStation{
//使用数组（完整访问，遍历
    string[] public candidateNames;//存[很多人名]
    //使用映射（即时访问拉取，将键链接到值，key （name）→ value （票数），没有写入的 key 会返回默认值
    /*关于问号和单词排序的疑惑
    编程语言习惯规则：类型+变量名，如string name =字符串变量name，所以voteCount在括号后。
    mapping的括号是定义mapping的规则。mapping让我们不用翻表而是直接定位这个“小盒子”*/
    mapping(string => uint256) voteCount;//存票数。所有人名存储在叫voteCount的表里，mapping数据类型字符串→数字，变量名voteCount
//  mapping(string => bool) isCandidate;
    function addCandidateNames(string memory _candidateNames) public{
//      require(!isCandidate[_candidateNames], "Candidate exists");（如果已经是候选人 → 不允许再添加
        candidateNames.push(_candidateNames);
        voteCount[_candidateNames] = 0;//添加候选人名字并归零票数
//      isCandidate[_candidateNames] = true;（对应上面的mapping，筛选出真的候选人 
    }
   //检索候选人 （mapping不能遍历，mapping里面有哪些key？所以要存一个candidateNames数组，并且能够get）
    function getcandidateNames() public view returns (string[] memory){
        return candidateNames;
    }
//开始投票 //（运行函数）可见性 { 运行逻辑（函数要怎么操作）}
    function vote(string memory _candidateNames) public{
//  require(isCandidate[_candidateNames], "Not a candidate");（不满足括号里条件就告诉我not，智能合约安全设计）
        voteCount[_candidateNames] += 1;
    }
//function定义函数 函数名(参数) 可见性·谁可以调用 状态修饰符·状态说明·是否修改区块链 returns(返回值类型){
    function getVote(string memory _candidateNames) public view returns (uint256){
        return voteCount[_candidateNames];
    }

}
/*mapping 用来查一个人
array + for 用来查所有人
for(uint i=0; i<candidateNames.length; i++){
    string memory name = candidateNames[i];
    uint votes = voteCount[name];
}
*/
