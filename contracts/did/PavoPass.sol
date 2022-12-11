// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ownership/ownable.sol";
import "./lib/StringUtils.sol";
import "./Price.sol";
import "./Metadata.sol";
import "./DID.sol";
import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract PavoID is ERC721A, Ownable, Price, Metadata, DID {
    bool private isOpen = false;

    constructor() ERC721A("PavoID", "PavoID") {
        uint256[] memory _rentPrices = new uint256[](5);
        _rentPrices[0] = 1 ether;
        _rentPrices[1] = 0.1 ether;
        _rentPrices[2] = 0.05 ether;
        _rentPrices[3] = 0.01 ether;
        _rentPrices[4] = 0.005 ether;
        initializePrice(_rentPrices);
    }

    function _startTokenId() internal pure override returns (uint256) {
        return 1;
    }

    event Minted(address indexed to, uint256 indexed _amount);

    function mint(string calldata did) external payable {
        require(isOpen, "not open");
        require(getPrice(did) <= msg.value, "no enough eth");
        _mint(msg.sender, did);
    }

    function _mint(address to, string calldata did) internal {
        require(!checkExist(did), "did already minted");
        uint256 tokenId = _nextTokenId();
        _safeMint(to, 1);
        addRecord(did, tokenId);
        emit Minted(msg.sender, 1);
    }

    function mintByOwner(address _to, string calldata did) external onlyOwner {
        _mint(_to, did);
    }

    function withdraw(address payable recipient) external onlyOwner {
        uint256 balance = address(this).balance;
        (bool success, ) = recipient.call{value: balance}("");
        require(success, "fail withdraw");
    }

    function updateOpen(bool _isOpen) external onlyOwner {
        isOpen = _isOpen;
    }

    function getOpen() external view returns (bool) {
        return isOpen;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override
        returns (string memory)
    {
        require(_exists(tokenId), "tokenId doesn't exist");
        string memory did = tokenIdToDid[tokenId];
        return _createTokenURI(tokenId, did);
    }

    fallback() external payable {}

    receive() external payable {}
}
