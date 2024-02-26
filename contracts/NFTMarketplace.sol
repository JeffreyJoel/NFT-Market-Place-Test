// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFTMarketplace is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    // Mapping from token ID to sale price
    mapping(uint256 => uint256) private _tokenSalePrices;

    // Events
    event NFTMinted(address indexed owner, uint256 indexed tokenId, string tokenURI);
    event NFTListed(uint256 indexed tokenId, uint256 salePrice);
    event NFTSold(address indexed buyer, address indexed seller, uint256 indexed tokenId, uint256 salePrice);

    constructor() ERC721("NFTMarketplace", "NFTM") {}

    // Mint new NFT
    function mintNFT(string memory tokenURI) external onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, tokenURI);
        _tokenIdCounter.increment();
        emit NFTMinted(msg.sender, tokenId, tokenURI);
    }


    function listNFTForSale(uint256 tokenId, uint256 salePrice) external {
        require(_exists(tokenId), "Token does not exist");
        require(ownerOf(tokenId) == msg.sender, "Not the owner of the token");
        _tokenSalePrices[tokenId] = salePrice;
        emit NFTListed(tokenId, salePrice);
    }

    function buyNFT(uint256 tokenId) external payable {
        require(_exists(tokenId), "Token does not exist");
        address seller = ownerOf(tokenId);
        require(seller != address(0), "Invalid seller");
        uint256 salePrice = _tokenSalePrices[tokenId];
        require(salePrice > 0, "Token not listed for sale");
        require(msg.value >= salePrice, "Insufficient funds");

        _transfer(seller, msg.sender, tokenId);
        _tokenSalePrices[tokenId] = 0; // Remove the sale price after purchase
        payable(seller).transfer(salePrice); // Send funds to the seller
        emit NFTSold(msg.sender, seller, tokenId, salePrice);
    }

    function transferFrom(address from, address to, uint256 tokenId) public override {
        require(_tokenSalePrices[tokenId] == 0, "Token is listed for sale");
        super.transferFrom(from, to, tokenId);
    }


    function getSalePrice(uint256 tokenId) external view returns (uint256) {
        return _tokenSalePrices[tokenId];
    }

    function withdraw() external onlyOwner {
        payable(owner()).transfer(address(this).balance);
    }

     function _setTokenURI(uint256 tokenId, string memory _tokenURI) private {
        require(
            _exists(tokenId),
            "ERC721URIStorage: URI set of nonexistent token"
        );
        // _tokenURI = _tokenURI.replace("ipfs://", "");
        // _tokenURIs[tokenId] = _tokenURI;
    }
}
