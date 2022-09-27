// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract GtrpNFT is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    uint256 public constant MAX_SUPPLY = 10000;
    uint256 public constant MINT_PRICE = 100;
    string constant BASE_URI = "https://gateway.pinata.cloud/ipfs/QmQqF9TghmGhNj2GVa6n3FKxFP14Z2SmmDkQb95xRQM8GQ/";

    IERC20 _token = IERC20(0x87a725B3dF717C3c0a36Ebc5f34Bfa3C618aF0fd);

    constructor() ERC721("GtrpNFT", "GTRP") {}

    function random(uint number) internal view returns(uint){
        return uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty, msg.sender))) % number;
    }

    function safeMint(address to) public {
        require(totalSupply() < MAX_SUPPLY, "Max supply reached");
        require(_token.transferFrom(msg.sender, address(this), MINT_PRICE * 10**18), "Please approve tokens before minting");

        uint randomNumber = random(30);
        uint256 tokenId = _tokenIdCounter.current();

        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, string.concat(BASE_URI, Strings.toString(randomNumber), ".json"));
    }

    function getAllowance() public view returns(uint256) {
       return _token.allowance(msg.sender, address(this));
    }

    function withdrawPayments() public onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

        function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}