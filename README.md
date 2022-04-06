# Solidity DAO

## Use case
The idea of the implementation of this smart contract is to create DAO where user can propose a project and vote for | against it.

For reference, the projec model looks like this:
- id [uint256]
- amount [uint256]
- livePeriod [uint256]
- votesFor [uint256]
- votesAgainst [uint256]
- description [string]
- voting passed [bool]
- paid [bool]
- project Address [address payable]
- proposer [address]
- paidBy [address]

## Stack used
- Solidity
- Hardhat

## Installation

```bash
npm i
```

## Requirement
To interract with this Dapp, you will need a MetaMask account set on Rinkeby test network

### Faucet
In addition to MetaMask, you'll need ETH that you can get on various faucet.

| Ethily | [https://ethily.io/rinkeby-faucet/](https://ethily.io/rinkeby-faucet/)

| Official Rinkeby | [https://faucet.rinkeby.io/](https://faucet.rinkeby.io/)

|Other faucet| | [https://faucets.chain.link/rinkeby](https://faucets.chain.link/rinkeby)
## Hardhat

⚠️ ⚠️If you do any changes in the SmartContract, first, run the tests:

```bash
npx hardhat test
```
Then, you will also need to create a .env with the following variables:
- URL_INFURA="YOUR INFURA DEPLOYMENT ADDRESS"
- ACCOUNT_PRIVATE="YOUR PRIVATE ACCOUNT KEY FOR METAMASK"

NB: if you want to upload a new smart contract, make sure you take the infura key for Rinkeby development.

### Deploy your smart contract
```bash
npx hardhat run scripts/deploy.js --network rinkeby
```

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.
