// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract WalletDirectory is Ownable {
    mapping(address => Contact) public directory;
    IERC20 _token = IERC20(0x87a725B3dF717C3c0a36Ebc5f34Bfa3C618aF0fd);

    constructor() {
    }

    struct Contact {
        string Name;
        string Email;
        string PhoneNumber;
        uint StackedTokens;
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

    function getUserTokenBalance() public view returns(uint256) { 
       return _token.balanceOf(msg.sender);
   }

   function approveTokens(uint256 _amount) public returns(bool) {
       _token.approve(address(this), _amount);
       return true;
   }

   function getAllowance() public view returns(uint256) {
       return _token.allowance(msg.sender, address(this));
   }

   function acceptTransfer(uint256 _amount) public returns(bool) {
       require(_token.transferFrom(msg.sender, address(this), _amount), "Please approve tokens before transferring");

       directory[msg.sender].StackedTokens += _amount;
       return true;
   }

    function getContractTokenBalance() public onlyOwner view returns(uint256) {
       return _token.balanceOf(address(this));
   }
}
