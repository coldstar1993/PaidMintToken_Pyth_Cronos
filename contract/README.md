## Paid Mint Token (Demo)

**In this demo, we will use real-time Pyth price data to mint erc20 tokens in exchange for $1 of ETH, wherein showcase how a Cronos Dapp could get a price feed.**

Smart Contract is deployed at address: [0x36dA3Ee88865037e80Ae350916219f5736748D77](https://explorer.cronos.org/testnet/address/0x36dA3Ee88865037e80Ae350916219f5736748D77)

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
cd PaidMintToken-Pyth-Cronos/contract

npm install @pythnetwork/pyth-sdk-solidity

forge install foundry-rs/forge-std@v1.10.0

forge install OpenZeppelin/openzeppelin-contracts@v5.4.0

```



### Inspect Smart Contract
The key contract [PaidMintToken](./src/PaidMintToken.sol) inherits `ERC20` and `Ownable` from [openzeppelin-contracts](https://github.com/OpenZeppelin/openzeppelin-contracts), with two fields as belows by which it reads the price of ETH/USD from Pyth,
* `IPyth pyth`
* `bytes32 ethUsdPriceId`

as well as several functions as blows:
* [updateAndMint()](https://github.com/coldstar1993/PaidMintToken-Pyth-Cronos/blob/main/contract/src/PaidMintToken.sol#L69): update price to Pyth contract and exec mint()
* [mint()](https://github.com/coldstar1993/PaidMintToken-Pyth-Cronos/blob/main/contract/src/PaidMintToken.sol#L34): read the price from Pyth contract, and mint tokens if user pay >= $1 of ETH
* [hasMinted()](https://github.com/coldstar1993/PaidMintToken-Pyth-Cronos/blob/main/contract/src/PaidMintToken.sol#L81): check and avoid re-mint.
* [withdraw()](https://github.com/coldstar1993/PaidMintToken-Pyth-Cronos/blob/main/contract/src/PaidMintToken.sol#L86): only contract owner could withdraw the ETH away. 

Now, let's dive into key functions: [updateAndMint()](https://github.com/coldstar1993/PaidMintToken-Pyth-Cronos/blob/main/contract/src/PaidMintToken.sol#L69) and [mint()](https://github.com/coldstar1993/PaidMintToken-Pyth-Cronos/blob/main/contract/src/PaidMintToken.sol#L34):
1. Call `IPyth.getUpdateFee` to calculate the fee charged by Pyth to update the price.
2. Call `IPyth.updatePriceFeeds` to update the price, paying the fee calculated in the previous step.
3. Within [mint()](https://github.com/coldstar1993/PaidMintToken-Pyth-Cronos/blob/main/contract/src/PaidMintToken.sol#L34), Call `IPyth.getPriceNoOlderThan` to read the current price, providing the price feed ID(ie. `ethUsdPriceId`) that you wish to read and your acceptable staleness threshold(**60sec** here) for the price.
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

### Deployment

if you wanna deploy [PaidMintToken](./src/PaidMintToken.sol) again, then follow the steps belows:

```shell
$ export ADDRESS=0x_YOUR_ADDRESS

$ export PRIVATE_KEY=0x_YOUR_PRIVATE_KEY

$ export RPC_URL="https://evm-t3.cronos.org"

$ export PYTH_CRONOS_ADDRESS=0x36825bf3Fbdf5a29E2d5148bfe7Dcf7B5639e320

$ export ETH_USD_ID=0xff61491a931112ddf1bd8147cd1b641375f79f5825126d665480874634fd0ace

$ forge create src/PaidMintToken.sol:PaidMintToken --private-key $PRIVATE_KEY --rpc-url $RPC_URL --broadcast --constructor-args $PYTH_CRONOS_ADDRESS $ETH_USD_ID

```

Note: if you deploy contract yourself, **DO NOT forget** to update `DEPLOYMENT_ADDRESS` in [.env](../app/.env) with the latest contract address. 

For more details of Pyth on Cronos TestNet, please reference [here](https://docs.cronos.org/for-dapp-developers/dev-tools-and-integrations/pyth#pyth-on-cronos-evm).
