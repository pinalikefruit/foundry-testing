// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import "../src/Counter.sol";

contract CounterTest is Test {
    Counter counter;
    address bob = makeAddr("bob");

    function setUp() public {
        vm.deal(bob, 1000 ether);

        vm.startPrank(bob);

        counter = new Counter();
    }

    function test_inc() public {
        assertEq(counter.count(), 0);
        counter.inc();
        assertEq(counter.count(), 1);
    }

    function test_dec() public {
        counter.inc();
        counter.inc();
        counter.dec();
        assertEq(counter.count(), 1);
    }

    function testFailDec() public {
        counter.dec();
    }

    // function testDecUnderflow() public {
    //     vm.expectRevert(stdError.arithmeticError);
    //     counter.dec();
    // }
}
