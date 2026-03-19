//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract ScientificCalculator{

    function power(uint256 base, uint256 exponent)public pure returns(uint256){
        if(exponent == 0)return 1;//任何数的0次方=1
        else return (base ** exponent);//底数**指数。base 的 exponent 次方
    }
    //平方根
    function squareRoot(int256 number)public pure returns(int256){
        require(number >= 0, "Cannot calculate square root of negative number");//负数不能算
        if(number == 0)return 0;//0的平方根=0
       //牛顿迭代法
        int256 result = number/2;
        for(uint256 i = 0; i<10; i++){//for循环
            result = (result + number / result)/2;
        }//猜的值（不准）+校正值（number / result）→取平均。比如（8+16/8）/2=（8+2）/2=5，愈加逼近正确值

        return result;

    }
}//不适合链上用，消耗gas费，一般放在前端或者后端
