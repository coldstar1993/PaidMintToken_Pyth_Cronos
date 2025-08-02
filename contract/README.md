## Paid Mint Token (Demo)

**In this demo, we will use real-time Pyth price data to mint erc20 tokens in exchange for $1 of ETH, wherein showcase how a Cronos Dapp could get a price feed.**

Smart Contract is deployed at address: [0xFC6eB7cCfd160606e0710b6B2D6C78Ea5E929C9E](https://explorer.cronos.org/testnet/address/0xFC6eB7cCfd160606e0710b6B2D6C78Ea5E929C9E)

It follows [PULL ORACLE pattern](https://docs.pyth.network/price-feeds/pull-updates#pull-oracles):
1. users request the latest [price update](https://github.com/pyth-network/pyth-crosschain/blob/b6d40a728aeef32fb5a7f3f3ba83eb0ef82cc1cc/target_chains/ethereum/sdk/solidity/PythStructs.sol#L25)(regarding ETH/USD) from an off-chain service.
2. then submit the price update to the on-chain Pyth contract (cost fee), which verifies its authenticity and stores it onchain.
3. then read [the price]((https://github.com/pyth-network/pyth-crosschain/blob/b6d40a728aeef32fb5a7f3f3ba83eb0ef82cc1cc/target_chains/ethereum/sdk/solidity/PythStructs.sol#L13)) of ETH/USD from Pyth contract and use it to calculate the amount of ETH required to mint the tokens.

Pyth allows applications to use a single transaction flow that first updates the price then performs the necessary application logic (i.e. above step2 & step3).

### Preliminaries
Please make sure these are installed on your system before continuing.
* [foundry](https://book.getfoundry.sh/getting-started/installation)
* [node](https://nodejs.org/en/download/)

then *git clone* this repo on you pc, then:

```shell
cd PaidMintToken_Pyth_Cronos/contract

npm install @pythnetwork/pyth-sdk-solidity

forge install foundry-rs/forge-std@v1.10.0

forge install OpenZeppelin/openzeppelin-contracts@v4.8.1

```



### Inspect Smart Contract
The key contract [PaidMintToken](./src/PaidMintToken.sol) inherits `ERC20` and `Ownable` from [openzeppelin-contracts](https://github.com/OpenZeppelin/openzeppelin-contracts), with two fields as belows by which it reads the price of ETH/USD from Pyth,
* `IPyth pyth`
* `bytes32 ethUsdPriceId`

as well as several functions as blows:
* [updateAndMint()](https://github.com/coldstar1993/PaidMintToken_Pyth_Cronos/blob/d233db8d8d341927b63da698cf01f4e3a3b92c7a/src/PaidMintToken.sol#L69): update price to Pyth contract and exec mint()
* [mint()](https://github.com/coldstar1993/PaidMintToken_Pyth_Cronos/blob/d233db8d8d341927b63da698cf01f4e3a3b92c7a/src/PaidMintToken.sol#L34): read the price from Pyth contract, and mint tokens if user pay >= $1 of ETH
* [hasMinted()](https://github.com/coldstar1993/PaidMintToken_Pyth_Cronos/blob/d233db8d8d341927b63da698cf01f4e3a3b92c7a/src/PaidMintToken.sol#L81): check and avoid re-mint.
* [withdraw()](https://github.com/coldstar1993/PaidMintToken_Pyth_Cronos/blob/d233db8d8d341927b63da698cf01f4e3a3b92c7a/src/PaidMintToken.sol#L86): only contract owner could withdraw the ETH away. 

Now, let's dive into key functions: [updateAndMint()](https://github.com/coldstar1993/PaidMintToken_Pyth_Cronos/blob/d233db8d8d341927b63da698cf01f4e3a3b92c7a/src/PaidMintToken.sol#L69) and [mint()](https://github.com/coldstar1993/PaidMintToken_Pyth_Cronos/blob/d233db8d8d341927b63da698cf01f4e3a3b92c7a/src/PaidMintToken.sol#L34):
1. Call `IPyth.getUpdateFee` to calculate the fee charged by Pyth to update the price.
2. Call `IPyth.updatePriceFeeds` to update the price, paying the fee calculated in the previous step.
3. Within [mint()](https://github.com/coldstar1993/PaidMintToken_Pyth_Cronos/blob/d233db8d8d341927b63da698cf01f4e3a3b92c7a/src/PaidMintToken.sol#L34), Call `IPyth.getPriceNoOlderThan` to read the current price, providing the price feed ID(ie. `ethUsdPriceId`) that you wish to read and your acceptable staleness threshold(**60sec** here) for the price.
4. finally, if user pay more than $1 of ETH, then allow to mint tokens.


## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```
