// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./lib/StringUtils.sol";
import "./ownership/ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

abstract contract DID is Ownable {
    mapping(bytes32 => uint256) public didhashToTokenId;
    mapping(uint256 => string) public tokenIdToDid;

    function resolve(string calldata did) external view returns (uint256) {
        bytes32 didhash = keccak256(abi.encodePacked(did));
        uint256 tokenId = didhashToTokenId[didhash];
        require(tokenId != 0, "did not exist");
        return tokenId;
    }

    function resolveTokenId(uint256 tokenId)
        external
        view
        returns (string memory)
    {
        string memory did = tokenIdToDid[tokenId];
        return string(abi.encodePacked("did:pavoid:", did));
    }

    function addRecord(string calldata did, uint256 tokenId) internal {
        bytes32 didhash = keccak256(abi.encodePacked(did));
        require(didhashToTokenId[didhash] == 0, "did already minted");
        didhashToTokenId[didhash] = tokenId;
        tokenIdToDid[tokenId] = (did);
    }

    function checkExist(string calldata did) internal view returns (bool) {
        bytes32 didhash = keccak256(abi.encodePacked(did));
        return didhashToTokenId[didhash] != 0;
    }
}
