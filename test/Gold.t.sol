//SPDX-License-Identifier: WTFPL
pragma solidity 0.8.9;

import {Test} from "forge-std/Test.sol";
import "../src/GoldMinter.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/interfaces/IERC721Receiver.sol";

contract GoldMinterTest is Test {
    GoldMinter nftmin;
    address bob = makeAddr("bob");
    address alice = makeAddr("alice");

    // Automatically executed prior to each test
    function setUp() public {
        // Instance of the contract to test
        nftmin = new GoldMinter(1.1 ether);

        // Bob start with 1000 ether
        vm.deal(bob, 1000 ether);
        // Now, every call is executed by Bob
        vm.startPrank(bob);
    }

    receive() external payable {}

    function test_constructor() public {
        assertEq(1.1 ether, nftmin.PRICE_TO_PAY());
        assertFalse(address(nftmin.nft()) == address(0), "NFT not deployed");
    }

    function test_mintOne() public {
        uint256 balanceBefore = address(nftmin).balance;
        nftmin.mintOne{value: 1.1 ether}();
        uint256 balanceAfter = address(nftmin).balance;

        assertEq(nftmin.nft().getTotalMinted(), 1);
        assertLt(balanceBefore, balanceAfter);
        assertEq(balanceAfter, 1.1 ether);
    }
}
