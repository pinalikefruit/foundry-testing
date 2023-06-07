// SPDX-License-Identifier: WTFPL
pragma solidity 0.8.17;

import {Test} from "forge-std/Test.sol";
import "../src/HelloWorld.sol";

contract HelloWorldTest is Test {
    HelloWorld helloWorld;

    function setUp() public {
        helloWorld = new HelloWorld();
    }

    function test_greet() public {
        assertEq(helloWorld.greet(), "Hello World");
    }
}
