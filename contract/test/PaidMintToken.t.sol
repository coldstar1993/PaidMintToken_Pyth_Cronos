// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test, console2} from "forge-std/Test.sol";
import {PaidMintToken} from "../src/PaidMintToken.sol";
import {MockPyth} from "@pythnetwork/pyth-sdk-solidity/MockPyth.sol";

contract PaidMintTokenTest is Test {
    MockPyth public pyth;
    bytes32 CRO_PRICE_FEED_ID = bytes32(uint256(0x1));
    PaidMintToken public app;

    uint256 CRO_TO_WEI = 10 ** 18;

    function setUp() public {
        pyth = new MockPyth(60, 1);
        app = new PaidMintToken(address(pyth), CRO_PRICE_FEED_ID);
    }

    function createCroUpdate(int64 croPrice) private view returns (bytes[] memory) {
        bytes[] memory updateData = new bytes[](1);
        updateData[0] = pyth.createPriceFeedUpdateData(
            CRO_PRICE_FEED_ID,
            croPrice * 100000,
            10 * 100000,
            -5,
            croPrice * 100000,
            10 * 100000,
            uint64(block.timestamp),
            uint64(block.timestamp)
        );

        return updateData;
    }

    function setCroPrice(int64 croPrice) private {
        bytes[] memory updateData = createCroUpdate(croPrice);
        uint256 value = pyth.getUpdateFee(updateData);
        console2.log("value: ", value);
        vm.deal(address(this), value);
        pyth.updatePriceFeeds{value: value}(updateData);
    }

    function testMint() public {
        setCroPrice(100);

        vm.deal(address(this), CRO_TO_WEI);
        app.mint{value: CRO_TO_WEI / 100}();
    }

    function testMintRevert() public {
        setCroPrice(99);

        vm.deal(address(this), CRO_TO_WEI);
        vm.expectRevert();
        app.mint{value: CRO_TO_WEI / 100}();
    }

    function testMintStalePrice() public {
        setCroPrice(100);

        skip(120);

        vm.deal(address(this), CRO_TO_WEI);

        vm.expectRevert();
        app.mint{value: CRO_TO_WEI / 100}();
    }

    function testUpdateAndMint() public {
        bytes[] memory updateData = createCroUpdate(100);

        vm.deal(address(this), CRO_TO_WEI);
        app.updateAndMint{value: CRO_TO_WEI / 100}(updateData);
    }
}
