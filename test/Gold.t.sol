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
}
