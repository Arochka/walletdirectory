// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

contract WalletDirectory {
    mapping(address => Contact) public directory;

    constructor() {
    }

    struct Contact {
        string Name;
        string Email;
        string PhoneNumber;
    }

    function setContact(Contact memory _contact) external {
        directory[msg.sender] = _contact;
    } 

    function setContactName(string memory _name) external {
        directory[msg.sender].Name = _name;
    }

    function setContactEmail(string memory _email) external {
        directory[msg.sender].Email = _email;
    } 

    function setContactPhone(string memory _phone) external {
        directory[msg.sender].PhoneNumber = _phone;
    } 

    function getWalletContact(address _target) external view returns (Contact memory) {
        return directory[_target];
    } 
}
