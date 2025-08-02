
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

Here is my mint tx: https://explorer.cronos.org/testnet/tx/0x6dd8c8e6abfe7bcb3668a5828f91bf61dc3079cdf3ce24b2579f719d5625996d


