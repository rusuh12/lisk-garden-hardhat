# LiskGarden Hardhat Project

Lisk Garden Contract
   ```
   0x77B39033Ba0CD7DC1F2C305BE4B6Df90ab717267
   ```

LiskGarden is an Ethereum smart contract that allows users to plant, water, and harvest virtual plants that deployed in Lisk Sepolia. Each plant has growth stages and water levels, and users can earn rewards when a plant fully blooms.

## Features
- Plant seeds for 0.001 ETH
- Water plants to keep them alive
- Plants grow over time depending on water and elapsed time
- Harvest fully grown plants to earn rewards
- Contract owner can withdraw ETH from the contract

## Prerequisites
Make sure you have installed:
- [Node.js](https://nodejs.org/) v20+
- [npm](https://www.npmjs.com/) 
- Hardhat

## Setup Project

1. Clone the repository:
   ```
   git clone https://github.com/rusuh12/lisk-garden-hardhat.git
   cd lisk-garden-hardhat
   ```
2. Install dependencies:
   ```
   npm install
   ```
3. Copy .env.example to .env and configure your environment variables:
   ```
   cp .env.example .env // make sure to change to your private key
   ```

## Deploy Contract and Interact
Run Hardhat to deploy and interact with the contract on a network (e.g., Lisk-Sepolia):
   ```
    npx hardhat run scripts/interact.ts --network lisk-sepolia
   ```
   This script will:
- Display total plants in the contract
- Plant a new seed (costs 0.001 ETH)
- Show details of the newly planted seed including ID, owner, growth stage, and water level

## Running Tests
Tests are written using node:test and Viem. To run tests locally:
   ```
    npx hardhat test
   ```
Test cases include:
- Deploy contract and check owner
- Plant seeds with sufficient ETH
- Reject planting if ETH is insufficient
- Water a plant and check water level
- Check plant counter increments correctly
- Owner can withdraw ETH from the contract



