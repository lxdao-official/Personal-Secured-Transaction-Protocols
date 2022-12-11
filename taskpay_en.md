# Task-oriented payment protocol

A protocol for task-based payments on the EVM Compatible blockchain.

This is an Ethereum-based task payment protocol, which is used to solve the mutual trust problem in task-based payment scenarios, and can be used for DAO task distribution or personal outsourcing projects, etc.

### The task flow is as follows:
1. The task is jointly initiated by three parties: the initiator, the receiver, and the arbitrator.
2. After the recipient and the arbitrator confirm and sign the task content, the initiator will generate an order on the chain and lock the task reward.
3. Task rewards are allocated by milestones, each milestone contains a time and amount, and each milestone will generate an Order.
4. When the task is generated, a certificate NFT will be generated, and the mint will be given to the initiator. There will be several orders and nfts for several milestones.
5. After the task reaches the milestone, the initiator can transfer the voucher NFT to the recipient, and the recipient can use this voucher to exchange for rewards.
6. After the task reaches the milestone, if there is a dispute, the arbitrator can choose to do one of two operations:
  1. The arbitrator can change the status of the order to refund, and the initiator can use the voucher corresponding to the order to exchange for a refund.
  2. The arbitrator can forcefully transfer the voucher NFT to the recipient, and the recipient can use this voucher to exchange for remuneration.
7. After the NFT is exchanged for rewards, the order statement will be issued and the NFT will be destroyed.

### The logic of exchanging rewards or refunds for nft vouchers is:
1. At any time and under any conditions, the task recipient can use this nft to exchange for the reward locked in the order (the order status needs to be open).
2. But by default, nft is mint to the initiator, and the initiator can transfer nft to the receiver at any time, so that the receiver can exchange rewards at any time.
3. The initiator can use nft to exchange locked rewards only in one case, that is, when the order status is "refunded", holding nft in other cases cannot be exchanged.

### Task Status:
1. Start. The representative task has started, the reward has been locked, and the arbitration cannot intervene, and the initiator cannot exchange the locked reward.
2. Milestones. It means that the task has reached the milestone, and if there is a dispute at this time, the arbitrator can intervene and operate the order status as a chargeback.
3. Chargeback. It means that the task has been refunded. Only in this state can the initiator use NFT to exchange the locked reward.
4. Statement. After any party uses nft to exchange rewards, it will automatically become a statement.