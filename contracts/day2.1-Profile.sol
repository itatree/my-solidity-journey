// SPDX-License-Identifier:MIT

pragma solidity ^0.8.0;

contract Profile {

    mapping(address => string) public names;
    mapping(address => string) public bios;

    function setProfile(string memory _name, string memory _bio) public {

        names[msg.sender] = _name;
        bios[msg.sender] = _bio;

    }

    function getProfile() public view returns(string memory, string memory){

        return (names[msg.sender], bios[msg.sender]);

    }
}
