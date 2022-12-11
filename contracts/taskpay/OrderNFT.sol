// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../ownership/ownable.sol";

/**
 * @title 结单凭证 NFT
 * @dev 用于存储结单凭证的信息
 * 使用此凭证可以结算某个 order，将 order 的结算状态置为已结算，并且获取 order 中的 token
 */
contract OrderNFT is ERC721, Ownable {
    string private URI;

    constructor() ERC721("OrderNFT", "OrderNFT") {}

    function setBaseURI(string memory __baseURI) public onlyOwner {
        URI = __baseURI;
    }

    function _baseURI() internal view override returns (string memory) {
        return URI;
    }
}
