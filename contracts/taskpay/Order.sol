// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./OrderNFT.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Order is OrderNFT {
    IERC20 token;

    enum OrderStatus {
        Open, // 订单已创建，但未结算
        Cancelled, // 订单已退单
        Finished // 订单已结算
    }
    struct OrderGroup {
        // 发起者
        address publisher;
        // 工作者
        address employer;
        // 仲裁者
        address intercessor;
        // metadataURI
        string metadataURI;
        // 任务描述
        string title;
        uint256[] orders;
    }
    struct Order {
        // 解锁价格
        uint256 amount;
        // 时间节点
        uint256 deadlineTimestamp;
        // 关联的 OrderGroup
        uint256 groupId;
        // 订单状态
        OrderStatus status;
    }

    mapping(uint256 => OrderGroup) public orderGroups;
    mapping(uint256 => Order) public orders;

    uint256 public orderGroupCount;
    uint256 public orderCount;

    mapping(address => uint256[]) public userOrders;

    function _createOrderGroup(
        address publisher,
        address employer,
        address intercessor,
        string memory metadataURI,
        string memory title
    ) internal returns (uint256) {
        orderGroupCount++;
        orderGroups[orderGroupCount] = OrderGroup(
            publisher,
            employer,
            intercessor,
            metadataURI,
            title,
            new uint256[](0)
        );
        return orderGroupCount;
    }

    function _createOrder(
        uint256 groupId,
        uint256 amount,
        uint256 deadlineTimestamp
    ) internal returns (uint256) {
        // 扣除用户的 token
        require(
            token.balanceOf(msg.sender) >= amount,
            "insufficient token balance"
        );
        token.transferFrom(msg.sender, address(this), amount);

        // 生成 order
        orderCount++;
        orders[orderCount] = Order(
            amount,
            deadlineTimestamp,
            groupId,
            OrderStatus.Open
        );
        orderGroups[groupId].orders.push(orderCount);
        userOrders[msg.sender].push(orderCount);

        // 生成 orderNFT ，将其转让给 publisher 持有
        _safeMint(msg.sender, orderCount);

        return orderCount;
    }

    // 雇佣者使用 orderNFT 可以结算 order，获取的 token
    function finishOrder(uint256 orderId) public {
        require(ownerOf(orderId) == msg.sender, "not owner");
        Order memory order = orders[orderId];
        OrderGroup memory orderGroup = orderGroups[order.groupId];
        require(order.status == OrderStatus.Open, "order not open");
        require(orderGroup.employer == msg.sender, "not employee");

        // 转移 token
        token.transfer(orderGroup.employer, order.amount);

        // 将 order 的状态置为已结算
        orders[orderId].status = OrderStatus.Finished;

        // 将 token 转让给 employer

        _burn(orderId);
    }

    // 发起者可以在 order 状态为 cancel 的情况下，用 orderNFT 兑换 token
    function cancelOrder(uint256 orderId) public {
        require(ownerOf(orderId) == msg.sender, "not owner");
        Order memory order = orders[orderId];
        OrderGroup memory orderGroup = orderGroups[order.groupId];
        require(order.status == OrderStatus.Cancelled, "order not cancelled");
        require(orderGroup.publisher == msg.sender, "not publisher");

        // 转移 token 给 发起者
        token.transfer(orderGroup.publisher, order.amount);

        // 将 order 的状态置为已结算
        orders[orderId].status = OrderStatus.Finished;

        _burn(orderId);
    }

    // 仲裁者可以在 order 状态为 open 的情况下，并且 deadlineTimestamp 已经过去的情况下
    // 将 order 状态置为 cancel 或者 将 nft 强制转移给 employer

    function intercessorOrder(uint256 orderId, bool isCancel) public {
        Order memory order = orders[orderId];
        OrderGroup memory orderGroup = orderGroups[order.groupId];
        require(order.status == OrderStatus.Open, "order not open");
        require(orderGroup.intercessor == msg.sender, "not intercessor");
        require(block.timestamp > order.deadlineTimestamp, "not deadline");

        if (isCancel) {
            orders[orderId].status = OrderStatus.Cancelled;
        } else {
            _transfer(orderGroup.publisher, orderGroup.employer, orderId);
        }
    }
}
