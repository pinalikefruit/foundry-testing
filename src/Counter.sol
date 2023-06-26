// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "forge-std/console.sol";

contract Counter {
    uint256 public count;

    function inc() external {
        console.log("Count", count);
        count += 1;
    }

    function dec() external {
        count -= 1;
    }
}
