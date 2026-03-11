/*核心知识点:
1.数组string[]+映射mapping（
2.编程语言规则：类型+变量名
3.编程语言其实本质是：名词（数据）+动词（行为）,比如：string,uint,address/vote(),click(),transfer()

*/
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract PollStation{
//使用数组（完整访问，遍历
    string[] public candidateNames;//[很多人名]
    //使用映射（即时访问拉取，将键链接到值，key （name）→ value （票数）
    /*关于问号和单词排序的疑惑
    编程语言习惯规则：类型+变量名，如string name =字符串变量name，所以voteCount在括号后。
    mapping的括号是定义mapping的规则。*/
    mapping(string => uint256) voteCount;//所有人名存储在叫voteCount的表里，mapping数据类型字符串→数字，变量名voteCount

    function addCandidateNames(string memory _candidateNames) public{
        candidateNames.push(_candidateNames);
        voteCount[_candidateNames] = 0;//添加候选人名字并归零票数
    }
   //检索候选人 
    function getcandidateNames() public view returns (string[] memory){
        return candidateNames;
    }
//开始投票
    function vote(string memory _candidateNames) public{
        voteCount[_candidateNames] += 1;
    }
//view票数
    function getVote(string memory _candidateNames) public view returns (uint256){
        return voteCount[_candidateNames];
    }

}
