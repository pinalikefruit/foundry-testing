// SPDX-License-Identifier: WTFPL
pragma solidity 0.8.9;

import "./Gold.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "forge-std/console.sol";

/**
 * @title GoldMinter.
 * @author pinalikefruit
 * @dev A contract called `GoldMinter` that allows:
 * - Mint 1 NFT (function `mintOne()`)
 * - Withdraw all ETH deposit (`sweepFunds()`)
 * - Buy more than 1 NFT in bulk/simultaneous, capped at 10 points (`mintMany(uint256)`)
 * - Mint 1 free NFT when user has more than 10 points, where 1 mint is 1 point == NFT (`mintFree()`)
 * - Mint 1 free NFT for a certain condition
 * `Userpoints / nftsTotalMint * 100 > 20` (`mintDeluxe()`)
 */

contract GoldMinter {
    // Converts an address into address payable
    using Address for address payable;

    // NFT Gold price
    uint256 public immutable PRICE_TO_PAY;
    Gold public nft;

    constructor(uint256 priceToPay) {
        nft = new Gold(); // Create a new instance
        PRICE_TO_PAY = priceToPay;
    }
}
