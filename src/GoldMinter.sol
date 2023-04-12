// SPDX-License-Identifier: WTFPL
pragma solidity 0.8.9;

import "./Gold.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "forge-std/console.sol";

error InsufficientPayment();
error AboveMintLimit();

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
    address public owner;
    // NFT Gold price
    uint256 public immutable PRICE_TO_PAY;
    uint256 public immutable MINT_LIMIT;
    Gold public nft;

    constructor(uint256 priceToPay) {
        nft = new Gold(); // Create a new instance
        PRICE_TO_PAY = priceToPay;
        owner = msg.sender;
        MINT_LIMIT = 10;
    }

    // Mint 1 NFT (function `mintOne()`)
    function mintOne() public payable {
        if (msg.value < PRICE_TO_PAY) revert InsufficientPayment();
        nft.safeMint(msg.sender);
    }

    // Withdraw all ETH deposit (`sweepFunds()`)
    function sweepFunds() public {
        payable(owner).sendValue(address(this).balance);
    }

    // - Buy more than 1 NFT in bulk/simultaneous, capped at 10 points (`mintMany(uint256)`)
    function mintMany(uint256 amount) public payable {
        if (amount > MINT_LIMIT) revert AboveMintLimit();
        for (uint256 i = 0; i < amount; i++) {
            mintOne();
        }
    }
}
