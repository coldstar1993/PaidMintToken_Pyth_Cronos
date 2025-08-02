
## Usage

First, install dependencies and add `your private key` into env.

```shell
cd app/

npm install

export PRIVATE_KEY=YOUR_PRIVATE_KEY

```

### Build

Note: if you deploy contract yourself, then DO NOT forget to update `DEPLOYMENT_ADDRESS` in [.env](./.env) with the latest contract address. 

```shell
$ npm run build
```

### Interact

```shell
$ npm run mint
```

NOTE: each address can only mint once!

Here is my mint tx: https://explorer.cronos.org/testnet/tx/0x2cfaccce2ac9074afaaba9e98e04fcc5d097896afa5f8bcaa346dae23393ef5e


