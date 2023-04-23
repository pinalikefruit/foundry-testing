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
        nftmin = new GoldMinter(0.25 ether);
    }

    receive() external payable {}

    function test_constructor() public {
        assertEq(0.25 ether, nftmin.PRICE_TO_PAY());
        assertFalse(address(nftmin.nft()) == address(0), "NFT not deployed");
    }

    function test_mintOne() public {
        uint256 balanceBefore = address(nftmin).balance;
        nftmin.mintOne{value: 1 ether}();
        uint256 balanceAfter = address(nftmin).balance;

        assertEq(nftmin.nft().getTotalMinted(), 1);
        // assertLt(balanceBefore, balanceAfter);
        assertEq(balanceBefore + nftmin.PRICE_TO_PAY(), balanceAfter);
    }

    function test_sweepFunds() public {
        uint256 balanceBefore = address(bob).balance;

        vm.deal(alice, 1 ether);
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
        vm.deal(address(nftmin), 1000 ether);
        uint256 amount = 5;
        uint256 _value = amount * nftmin.PRICE_TO_PAY();
        nftmin.mintMany{value: _value}(amount);

        assertEq(nftmin.nft().balanceOf(bob), amount);

        _value = (nftmin.MINT_LIMIT() + 1) * nftmin.PRICE_TO_PAY();
        vm.expectRevert(AboveMintLimit.selector);
        nftmin.mintMany{value: _value}(11);
        /**
         * TODO:
         * - The amount mint must be equal to real mint
         * - Don't have must mint more than 10 in the same transaction.
         */
    }

    function test_fuzz_minting(uint256 val, uint256 amount) public {
        val = bound(val, nftmin.PRICE_TO_PAY(), 10 ether);
        amount = bound(amount, 1, 10);
        vm.assume(val >= nftmin.PRICE_TO_PAY() * amount);

        uint256 accumulated;
        nftmin.mintMany{value: val}(amount);
        accumulated = nftmin.PRICE_TO_PAY() * amount;

        assertEq(accumulated, address(nftmin).balance);

        /** TODO:
         * Define a phantom variable:
         * check that the value that should be charged is equal to the value
         * who receives the contract, even when more is sent.
         *
         */
    }
}
