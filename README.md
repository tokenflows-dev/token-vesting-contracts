# Token Linear vesting smart contracts
This repository contains the smart contracts for the Token Linear Vesting project. This set of contracts has been created to automate the vesting process after any ERC20 crowdsale that requires linear vesting.

## About the source code

The source code in this repo has been created from scratch but uses OpenZeppelin standard libraries for safety in basic operations and validations.

- [Getting Started](#getting-started)
  - [Requirements](#requirements)
  - [Deploy Vesting Period](#deploy-vesting-period)
  - [Deploy Token example](#deploy-token-example)
- [Troubleshooting](#troubleshooting)

## Getting Started

### Requirements
You will need node.js (16.x) and yarn installed to run it locally. We are using Hardhat to handle the project configuration and deployment. The configuration file can be found as `hardhat.config.js`.

1. Import the repository and `cd` into the new directory.
2. Run `yarn install`.
3. Copy the file `.env.example` to `.env`, and:
   - Replace `DEPLOYER_KEY` with the private key of your account.
   - Replace `RPC_URL` with an INFURA or ALCHEMY url.
   - Replace `ETHERSCAN_KEY` with a API key from etherscan.
5. Make sure you have gas to run the transactions and deploy the contracts in your account.
6. Define the network where you want to deploy it in `hardhat.config.js`.

### Deploy New Environment
Run `npx hardhat run scripts/deploy.ts --network <YOUR_NETWORK>`

### Deploy Test Environment
Run `npx hardhat run scripts/deploy-test.ts --network <YOUR_NETWORK>`

## Troubleshooting

If you have any questions, send them along with a hi to [hello@dandelionlabs.io](mailto:hello@dandelionlabs.io).
