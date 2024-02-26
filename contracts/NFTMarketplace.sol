// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTMarketplace is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    mapping(uint256 => uint256) public tokenIdToLevels;
    mapping(uint256 => uint256) public tokenPrices;
    mapping(uint256 => address) public tokenOwners;

    constructor() ERC721("Chain Battles", "CBTLS") {}

    function mint() public {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _safeMint(msg.sender, newItemId);
        tokenIdToLevels[newItemId] = 0;
        tokenOwners[newItemId] = msg.sender;
    }

    function setTokenPrice(uint256 tokenId, uint256 price) public {
        require(ownerOf(tokenId) == msg.sender, "You must own this token to set its price");
        tokenPrices[tokenId] = price;
    }

    function buy(uint256 tokenId) public payable {
        require(_exists(tokenId), "Token does not exist");
        require(tokenPrices[tokenId] > 0, "Token is not for sale");
        require(msg.value >= tokenPrices[tokenId], "Insufficient payment");

        address seller = tokenOwners[tokenId];
        tokenOwners[tokenId] = msg.sender;
        tokenIdToLevels[tokenId] = 0;
        tokenPrices[tokenId] = 0;

        payable(seller).transfer(msg.value);
        _transfer(seller, msg.sender, tokenId);
    }

    function listTokenForSale(uint256 tokenId, uint256 price) public {
        require(ownerOf(tokenId) == msg.sender, "You must own this token to list it for sale");
        tokenPrices[tokenId] = price;
    }

    function removeTokenFromSale(uint256 tokenId) public {
        require(ownerOf(tokenId) == msg.sender, "You must own this token to remove it from sale");
        tokenPrices[tokenId] = 0;
    }

    function getLevels(uint256 tokenId) public view returns (uint256) {
        uint256 levels = tokenIdToLevels[tokenId];
        return levels;
    }
}
