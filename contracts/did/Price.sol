// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./lib/StringUtils.sol";
import "./ownership/ownable.sol";

abstract contract Price is Ownable {
    using StringUtils for *;

    uint8 public minLenth = 5;
    uint8 public maxLenth = 20;
    // Rent in base price units by length
    uint256 public price1Letter;
    uint256 public price2Letter;
    uint256 public price3Letter;
    uint256 public price4Letter;
    uint256 public price5Letter;

    function initializePrice(uint256[] memory _rentPrices) internal {
        price1Letter = _rentPrices[0];
        price2Letter = _rentPrices[1];
        price3Letter = _rentPrices[2];
        price4Letter = _rentPrices[3];
        price5Letter = _rentPrices[4];
    }

    function getPrice(string calldata name) public view returns (uint256) {
        uint256 len = name.strlen();
        require(len >= minLenth, "did too short");
        require(len <= maxLenth, "did too long");
        uint256 basePrice;

        if (len >= 5) {
            basePrice = price5Letter;
        } else if (len == 4) {
            basePrice = price4Letter;
        } else if (len == 3) {
            basePrice = price3Letter;
        } else if (len == 2) {
            basePrice = price2Letter;
        } else {
            basePrice = price1Letter;
        }

        return basePrice;
    }

    function updateDidMinLength(uint8 _minLenth) external onlyOwner {
        minLenth = _minLenth;
    }

    function updateDidMaxLength(uint8 _maxLenth) external onlyOwner {
        maxLenth = _maxLenth;
    }

    function updatePrice(uint256[] memory _rentPrices) external onlyOwner {
        price1Letter = _rentPrices[0];
        price2Letter = _rentPrices[1];
        price3Letter = _rentPrices[2];
        price4Letter = _rentPrices[3];
        price5Letter = _rentPrices[4];
    }
}
