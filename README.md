# SmartSupplyChain
Engraving Trust in Supply Chain Milestones with Blockchain Fidelity.

## Overview
This repository contains smart contracts for managing a transparent and immutable product traceability system in a supply chain. It includes contracts for product identification, product deposit, and product storage, each designed to facilitate trust and verification in transactions.

## Contracts

### ProductIdentification
- **Owner Fee Setting**: Set a public registration fee for producers.
- **Producer Registration**: Record the producer's address and fee in the contract state.
- **Product Registration**: Registered producers can register multiple products with unique IDs.
- **Verification**: Check if a producer is registered via their address.
- **Product Information**: Verify product registration by ID and retrieve product details.

### ProductDeposit
- **Fee and Volume Setting**: Set a public storage fee per volume unit and a maximum storage volume.
- **Product Storage Registration**: Authorized producers can register storage with a fee based on total volume.
- **Store Authorization**: Register authorized stores for selling products.
- **Withdrawal Registration**: Record the withdrawal of product quantities by the depositing manufacturer or an authorized store.
- **Volume Tracking**: Update available volume after deposits and withdrawals.

### ProductStore
- **Contract Address Setting**: Define the warehouse and product identification contract addresses.
- **Inventory Addition**: Add product quantities from the warehouse, subject to authorization.
- **Pricing**: Set prices per product unit.
- **Availability and Authenticity Check**: Allow customers to verify product availability and authenticity by ID.
- **Purchase Transaction**: Register product purchases, adjust inventory, and transfer funds accordingly.

## Installation

To get started with these contracts:

1. Clone the repository:
git clone https://github.com/cristibctr/SmartSupplyChain
2. Upload it to remix
3. Profit???

## Usage

Deploy and interact with the contracts using your preferred blockchain development environment, following the provided function signatures and access controls.

## Contributing

Contributions are welcome. Please open an issue or submit a pull request with your suggested changes.

## License

Distributed under the MIT License. See `LICENSE` for more information.
