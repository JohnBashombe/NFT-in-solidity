// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol"; 

contract NFT is ERC721, Ownable {

    uint256 public minimumPrice = 0.5 ether;
    uint256 public totalSupply;
    uint256 public maxSupply;
    bool public isMintEnabled;

    mapping(address => uint256) public mintedWallets;
    mapping (uint256 => string) private _tokenURIs;
    string private _baseURIextended;


    constructor() payable ERC721('NFT Token', 'TKN') {
        maxSupply = 2;
    }

    function setBaseURI(string memory baseURI_) external onlyOwner() {
        _baseURIextended = baseURI_;
    }
    
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721 Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }
    
    function _baseURI() internal view virtual override returns (string memory) {
        return _baseURIextended;
    }
    
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "ERC721 Metadata: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();
        
        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }
        // If there is a baseURI but no tokenURI, concatenate the tokenID to the baseURI.
        return string(abi.encodePacked(base, Strings.toString(tokenId)));
    }

    function toggleIsMintEnabled() external onlyOwner {
        isMintEnabled = !isMintEnabled;
    }

    function setMaxSupply(uint256 _maxSupply) external onlyOwner {
        maxSupply = _maxSupply;
    }

    function mint(string memory tokenUri) external payable returns(uint256) {
        require(isMintEnabled, 'minting not enabled');
        require(mintedWallets[msg.sender] < 1, 'exceeds max per wallet');
        require(msg.value > minimumPrice, 'Wrong Price, Minimum is 0.5 ETH');
        require(maxSupply > totalSupply, 'sold out');
        require(bytes(tokenUri).length > 0, 'Metadata is required');

        mintedWallets[msg.sender] ++;
        totalSupply ++;

        uint256 tokenId = totalSupply;
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, tokenUri);

        return tokenId;

    }

}