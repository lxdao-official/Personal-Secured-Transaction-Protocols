// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// 定义交易合约
contract Exchange {
    // 定义合约的状态变量
    struct Order {
        address seller; // 出售者
        address buyer; // 买家, 可以指定为 0x0，表示任何人都可以购买
        bool sellerIsNFT; // 出售者的代币是否是 NFT
        address sellerTokenAddress; // 出售者的代币地址，为 0x0 的时候表示原生代币（ETH）
        uint256 sellerTokenIdOrAmount; // 出售者的代币数量
        bool buyerIsNFT; // 买家的代币是否是 NFT
        address buyerTokenAddress; // 买家的代币地址，为 0x0 的时候表示原生代币（ETH）
        uint256 buyerTokenIdOrAmount; // 买家的代币数量
        bool completed; // 交易是否完成
    }
    mapping(uint256 => Order) public orders; // 保存交易信息
    uint256 public offerCount; // 计数器，用于生成唯一的交易 ID

    function getOffer(uint256 offerId)
        public
        view
        returns (
            address seller,
            address buyer,
            bool sellerIsNFT,
            address sellerTokenAddress,
            uint256 sellerTokenIdOrAmount,
            bool buyerIsNFT,
            address buyerTokenAddress,
            uint256 buyerTokenIdOrAmount,
            bool completed
        )
    {
        Order memory order = orders[offerId];
        return (
            order.seller,
            order.buyer,
            order.sellerIsNFT,
            order.sellerTokenAddress,
            order.sellerTokenIdOrAmount,
            order.buyerIsNFT,
            order.buyerTokenAddress,
            order.buyerTokenIdOrAmount,
            order.completed
        );
    }

    // 创建交易
    function createOrder(
        address buyer,
        bool sellerIsNFT,
        address sellerTokenAddress,
        uint256 sellerTokenIdOrAmount,
        bool buyerIsNFT,
        address buyerTokenAddress,
        uint256 buyerTokenIdOrAmount
    ) public {
        // 质押 seller token 或 nft 到合约
        if (sellerIsNFT) {
            IERC721 erc721 = IERC721(sellerTokenAddress);
            require(
                erc721.ownerOf(sellerTokenIdOrAmount) == msg.sender,
                "not owner of NFT"
            );
            erc721.transferFrom(
                msg.sender,
                address(this),
                sellerTokenIdOrAmount
            );
        } else {
            IERC20 erc20 = IERC20(sellerTokenAddress);
            require(
                erc20.allowance(msg.sender, address(this)) >=
                    sellerTokenIdOrAmount,
                "not enough allowance"
            );
            erc20.transferFrom(
                msg.sender,
                address(this),
                sellerTokenIdOrAmount
            );
        }
        // 保存交易信息
        offerCount++;
        orders[offerCount] = Order(
            msg.sender,
            buyer,
            sellerIsNFT,
            sellerTokenAddress,
            sellerTokenIdOrAmount,
            buyerIsNFT,
            buyerTokenAddress,
            buyerTokenIdOrAmount,
            false
        );
    }

    // B 提交交易并获得 token 或 NFT，提交前需要根据 order 信息 approve nft 或者 token
    function trade(uint256 id) public payable {
        Order storage order = orders[id];
        // 检查 B 是否有权提交交易
        require(order.completed == false, "Order already completed");
        if (order.buyer != address(0)) {
            require(order.buyer == msg.sender, "not correct buyer");
        }
        // 检查 b 持有的 token 或 NFT 是否足够
        if (order.buyerTokenAddress == address(0)) {
            require(
                msg.value == order.buyerTokenIdOrAmount,
                "not enough value"
            );
        } else {
            if (order.buyerIsNFT) {
                // 检查 B 是否持有 NFT
                IERC721 erc721 = IERC721(order.buyerTokenAddress);
                require(
                    erc721.ownerOf(order.buyerTokenIdOrAmount) == msg.sender,
                    "not enough NFT"
                );
            } else {
                // 检查 B 是否持有足够 token
                IERC20 erc20 = IERC20(order.buyerTokenAddress);
                require(
                    erc20.allowance(msg.sender, address(this)) >=
                        order.buyerTokenIdOrAmount,
                    "not enough allowance"
                );
            }
        }
        // 扣除 buyer 的 token 或 NFT

        if (order.buyerTokenAddress == address(0)) {
            // 从 B 转移 ETH 到 合约
            payable(order.seller).transfer(order.buyerTokenIdOrAmount);
        } else {
            _transfer(
                order.buyerIsNFT,
                order.buyerTokenAddress,
                msg.sender,
                order.seller,
                order.buyerTokenIdOrAmount
            );
        }
        if (order.sellerTokenAddress == address(0)) {
            // 从 合约给 B 转移 ETH
            payable(msg.sender).transfer(order.sellerTokenIdOrAmount);
        } else {
            // 从 合约给 B 转移 token 或 NFT
            _transfer(
                order.sellerIsNFT,
                order.sellerTokenAddress,
                address(this),
                msg.sender,
                order.sellerTokenIdOrAmount
            );
        }

        if (order.buyer == address(0)) {
            order.buyer = msg.sender;
        }
        order.completed = true;
    }

    function _transfer(
        bool isNFT,
        address tokenAddress,
        address from,
        address to,
        uint256 amount
    ) internal {
        if (isNFT) {
            IERC721 erc721 = IERC721(tokenAddress);
            erc721.transferFrom(from, to, amount);
        } else {
            IERC20 erc20 = IERC20(tokenAddress);
            erc20.transferFrom(from, to, amount);
        }
    }

    // A 提取 token 或 NFT
    function cancelOrder(uint256 id) public {
        Order storage order = orders[id];
        // 检查 A 是否有权提取 token 或 NFT
        require(order.seller == msg.sender, "Only seller can withdraw");
        require(!order.completed, "Order not completed");

        if (order.sellerTokenAddress == address(0)) {
            // 从 合约给 A 转移 ETH
            payable(msg.sender).transfer(order.sellerTokenIdOrAmount);
        } else {
            // 从 合约给 A 转移 token 或 NFT
            _transfer(
                order.sellerIsNFT,
                order.sellerTokenAddress,
                address(this),
                msg.sender,
                order.sellerTokenIdOrAmount
            );
        }
        order.completed = true;
    }
}
