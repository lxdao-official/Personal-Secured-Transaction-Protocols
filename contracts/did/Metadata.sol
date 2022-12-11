// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./lib/StringUtils.sol";
import "./ownership/ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

abstract contract Metadata is Ownable {
    string private name_suffix = ".pavo.id";
    string private description =
        "Pavo ID is common pass for metapavo ecosystem";
    string private image_prefix =
        "https://assets.html-js.com/uploads/1668230763949-9e2aa7061a9f68b2f56685565db86071.jpg?id=";

    function setNameSuffix(string memory _name_suffix) external onlyOwner {
        name_suffix = _name_suffix;
    }

    function setDescription(string memory _description) external onlyOwner {
        description = _description;
    }

    function setImagePrefix(string memory _image_prefix) external onlyOwner {
        image_prefix = _image_prefix;
    }

    function _createTokenURI(uint256 tokenId, string memory did)
        internal
        view
        virtual
        returns (string memory)
    {
        string memory image = string(
            abi.encodePacked(image_prefix, Strings.toHexString(tokenId), ".png")
        );

        string memory name = string(abi.encodePacked(did, name_suffix));

        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(
                        abi.encodePacked(
                            "{",
                            '"name": "',
                            name,
                            '", ',
                            '"description": "',
                            description,
                            '"',
                            ', "image": "',
                            image,
                            '"'
                            "}"
                        )
                    )
                )
            );
    }
}
