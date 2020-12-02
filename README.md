# Ethereum Betting Dapp
### A simple betting smart contract and dapp using oracle service

## Dependency
- Solidity 0.5.12
- Truffle 5.0.42
- Provable Ethereum API
- jQuery 3.4.1


## Project structure
```
./contracts  - solidity contracts
./dapp       - dapp(web3.js & jQuery)
./migration  - truffle migration files 
./test       - tests
```

## Build and running

### run npm install 
```
> npm install
```

### deploy using truffle
```
> truffle migrate --network ropsten #testnet
```

### start dapp in local
```
> cd dapp
> python -m SimpleHTTPServer
```