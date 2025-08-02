// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import {console2} from "forge-std/Test.sol";
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "@pythnetwork/pyth-sdk-solidity/IPyth.sol";

/// @notice In this tutorial, we will use real-time Pyth price data to mint erc20 tokens in exchange for $1 of ETH.
///         Our solidity contract will read the price of ETH/USD from Pyth and use it to calculate the amount of ETH required to mint the tokens.
///
/// @title use real-time Pyth price data to mint erc20 tokens in exchange for $1 of ETH
/// @author luozhixiao1993@gmail.com
contract PaidMintToken is ERC20, Ownable {
    IPyth pyth;
    bytes32 ethUsdPriceId;

    uint256 public constant TOKENS_PER_MINT = 1000; // 1000 tokens per mint

    // record the address that has mint
    mapping(address => bool) private _hasMinted;

    event TokensMinted(address indexed user, uint256 amount);

    constructor(address _pyth, bytes32 _ethUsdPriceId) ERC20("Paid Mint Token", "PMT") Ownable(msg.sender){
        pyth = IPyth(_pyth);
        ethUsdPriceId = _ethUsdPriceId;
    }

    /// @dev this function's progress:
    ///         1. read price from pyth contract,
    ///         2. calc `oneDollarInWei`,
    ///         3. go mint NFT if fee is enough, or else revert.
    function mint() public payable {
        // to check if current msg.sender has mint before
        require(!_hasMinted[msg.sender], "Already minted");

        // to guarantee the price is not older than 60s.
        PythStructs.Price memory price = pyth.getPriceNoOlderThan(ethUsdPriceId, 60);
        console2.log("price of ETH in USD");
        console2.log(price.price);

        // let's say, 1000usd/eth, i.e. 1000usd per 10**18 WEI, then 1usd = (10**18)/1000 WEI
        uint256 ethPrice18Decimals =
            (uint256(uint64(price.price)) * (10 ** 18)) / (10 ** uint8(uint32(-1 * price.expo)));
        uint256 oneDollarInWei = ((10 ** 18) * (10 ** 18)) / ethPrice18Decimals;

        console2.log("required payment in wei");
        console2.log(oneDollarInWei);

        if (msg.value >= oneDollarInWei) {
            // >= 1 usd, then allow to mint
            uint256 tokensToMint = TOKENS_PER_MINT * 10 ** decimals();

            _mint(msg.sender, tokensToMint);
            _hasMinted[msg.sender] = true;

            emit TokensMinted(msg.sender, tokensToMint);
        } else {
            revert InsufficientFee();
        }
    }

    /// @dev this func follows PULL-ORACLE pattern:
    ///         1. (offchain)fetch latest price update,
    ///         2. update it to pyth contract,
    ///         3. go exec mint()
    /// @param pythPriceUpdate the signed price update message
    function updateAndMint(bytes[] calldata pythPriceUpdate) external payable {
        // calc the required fee
        uint256 updateFee = pyth.getUpdateFee(pythPriceUpdate);

        // update & store the newest price in pyth contract storage
        pyth.updatePriceFeeds{value: updateFee}(pythPriceUpdate);

        // go exec func `mint()`
        mint();
    }

    /// @notice check if the addr has mint
    function hasMinted(address account) public view returns (bool) {
        return _hasMinted[account];
    }

    /// @notice withdraw from contract
    function withdraw() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No ETH to withdraw");
        payable(owner()).transfer(balance);
    }

    // Error raised if the payment is not sufficient
    error InsufficientFee();
}
