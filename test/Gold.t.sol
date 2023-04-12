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
        // Bob start with 1000 ether
        vm.deal(bob, 1000 ether);
        // Now, every call is executed by Bob
        vm.startPrank(bob);
        // Instance of the contract to test
        nftmin = new GoldMinter(1.1 ether);
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

    function test_sweepFunds() public {
        uint256 balanceBefore = address(bob).balance;

        vm.deal(alice, 2 ether);
        changePrank(alice);
        nftmin.mintOne{value: nftmin.PRICE_TO_PAY()}();

        changePrank(bob);
        nftmin.sweepFunds();
        uint256 balanceAfter = address(bob).balance;

        assertGt(balanceAfter, balanceBefore);

        /**
         * TODO:
         * - All funds going to Bob
         * - Alice with changePrank
         */
    }

    function test_mintMany() public {
        uint256 amount = 10;
        uint256 _value = amount * nftmin.PRICE_TO_PAY();
        nftmin.mintMany{value: _value}(amount);

        assertEq(nftmin.nft().balanceOf(bob), amount);

        _value = (nftmin.MINT_LIMIT() + 1) * nftmin.PRICE_TO_PAY();
        amount = nftmin.MINT_LIMIT() + 1;
        vm.expectRevert(AboveMintLimit.selector);
        nftmin.mintMany{value: _value}(amount);
        /**
         * TODO:
         * - The amount mint must be equal to real mint
         * - Don't have must mint more than 10 in the same transaction.
         */
    }
}
