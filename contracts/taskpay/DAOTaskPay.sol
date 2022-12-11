// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Order.sol";

contract PayForWork is Order {
    constructor(address _token) {
        token = IERC20(_token);
    }

    // 创建任务单和子任务单，首先验证三方的签名, 然后创建主任务单和里程碑任务单
    function createOrderGroup(
        address publisher,
        address employer,
        address intercessor,
        string memory metadataURI,
        string memory title,
        uint256[] memory amounts,
        uint256[] memory deadlineTimestamps,
        bytes calldata publisherSignature,
        bytes calldata employerSignature,
        bytes calldata intercessorSignature
    ) public {
        bytes memory nonce = abi.encodePacked(
            publisher,
            employer,
            intercessor,
            metadataURI,
            title
        );
        // 验证三方的签名
        require(
            _verify(nonce, publisher, publisherSignature),
            "publisher signature error"
        );
        require(
            _verify(nonce, employer, employerSignature),
            "employer signature error"
        );
        require(
            _verify(nonce, intercessor, intercessorSignature),
            "intercessor signature error"
        );
        // 创建任务单
        uint256 groupId = _createOrderGroup(
            publisher,
            employer,
            intercessor,
            metadataURI,
            title
        );
        // 创建子任务单
        for (uint256 i = 0; i < amounts.length; i++) {
            _createOrder(amounts[i], deadlineTimestamps[i], groupId);
        }
    }

    function _verify(
        bytes32 nonce,
        address _signer,
        bytes memory signature
    ) private pure returns (bool) {
        return (_recover(hash, _token) == _signer);
    }

    function _recover(bytes32 hash, bytes memory _token)
        private
        pure
        returns (address)
    {
        return hash.toEthSignedMessageHash().recover(_token);
    }
}
