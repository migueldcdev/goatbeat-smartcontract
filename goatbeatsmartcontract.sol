// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Goatbeat is ERC721URIStorage, ReentrancyGuard {
  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  address payable platform;

  constructor() ERC721("GoatbeatNFT", "GBN") {
    platform = payable(msg.sender);
  }

  Price[] Prices;  

  struct Price {
      uint tokenId;
      uint price;
      address payable creator;
  }
  

  uint creatorPercentage = 12;
  uint platformPercentage = 3;
  uint ownerPercentage = 85;

  event transfer(address _to, uint amount);

  receive() external payable {}
  
  fallback() external payable {}  

  function mintNFT(string memory tokenURI, uint price) public returns (uint256) {

      _tokenIds.increment();
      uint256 newItemId = _tokenIds.current();
      _safeMint(msg.sender, newItemId);
      _setTokenURI(newItemId, tokenURI);      
      Prices.push(Price(newItemId, price, payable(msg.sender)));

      return newItemId;
  }

  function buyNft(uint256 _tokenId) external payable nonReentrant {
      
      require(msg.value == Prices[_tokenId - 1].price, "Wrong message value");
      require(isValidToken(_tokenId), "The token does not exist");     
      
      address payable tokenOwner = payable(super.ownerOf(_tokenId));   
      address payable creator = Prices[_tokenId - 1].creator;  
      
      uint ownerCut = msg.value * ownerPercentage / 100;
      uint creatorCut = msg.value * creatorPercentage / 100;
      uint platformCut = msg.value * platformPercentage / 100;

      tokenOwner.transfer(ownerCut);      
      creator.transfer(creatorCut);      
      platform.transfer(platformCut);      
           
      _safeTransfer(tokenOwner, msg.sender, _tokenId, "");
  } 

  function changeNftPrice(uint256 _tokenId, uint newPrice) public {
    require(ownerOf(_tokenId) == msg.sender, "Only the owner of the NFT can change the price");
    Prices[_tokenId - 1].price = newPrice;
  }

  function totalSuply() public view returns (uint) {
    return _tokenIds.current();
  }
  
  function isValidToken(uint256 _tokenId) internal view returns(bool) {
     return _tokenId != 0 && _tokenId <= _tokenIds.current(); 
  }  

  function tokenPrice(uint256 _tokenId) public view returns(uint) {
      return Prices[_tokenId - 1].price;
  }  

}