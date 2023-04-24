// SPDX-License-Identifier: WTFPL
pragma solidity 0.8.9;

import "./Gold.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "forge-std/console.sol";

error InsufficientPayment();
error AboveMintLimit();
error NotEnoughPoints();
error AlreadyClaimed();

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
    uint256 public immutable MINT_LIMIT;
    uint8 public immutable PRIZE_THRESHOLD;

    mapping(address => uint256) public points;
    mapping(address => bool) public claimed;

    Gold public nft;
    address public owner;

    event ClaimedFree(address owner, uint256 tokenId, uint256 points);

    constructor(uint256 priceToPay, uint8 prizeThreshold) {
        nft = new Gold(); // Create a new instance
        PRICE_TO_PAY = priceToPay;

        PRIZE_THRESHOLD = prizeThreshold;
        owner = msg.sender;
        MINT_LIMIT = 10;
    }

    // Mint 1 NFT (function `mintOne()`)
    function mintOne() public payable {
        if (msg.value < PRICE_TO_PAY) revert InsufficientPayment();
        if (msg.value > PRICE_TO_PAY) {
            payable(msg.sender).sendValue(msg.value - PRICE_TO_PAY);
            console.log(
                "This amount is returned to you %s a %s",
                msg.value - PRICE_TO_PAY,
                msg.sender
            );
        }
        nft.safeMint(msg.sender);
        points[msg.sender]++;
    }

    // Withdraw all ETH deposit (`sweepFunds()`)
    function sweepFunds() public {
        payable(owner).sendValue(address(this).balance);
    }

    // - Buy more than 1 NFT in bulk/simultaneous, capped at 10 points (`mintMany(uint256)`)
    function mintMany(uint256 amount) public payable {
        if (amount > MINT_LIMIT) revert AboveMintLimit();
        if (msg.value < PRICE_TO_PAY) revert InsufficientPayment();
        if (msg.value > PRICE_TO_PAY * amount) {
            payable(msg.sender).sendValue(msg.value - PRICE_TO_PAY * amount);
            console.log(
                "This amount is returned to you %s a %s",
                msg.value - PRICE_TO_PAY,
                msg.sender
            );
        }
        for (uint256 i = 0; i < amount; i++) {
            nft.safeMint(msg.sender);
            points[msg.sender]++;
        }
    }

    // Mint 1 free NFT when user has more than 10 points, where 1 mint is 1 point == NFT (`mintFree()`)
    function mintFree() public {
        if (points[msg.sender] < PRIZE_THRESHOLD) revert NotEnoughPoints();
        if (claimed[msg.sender]) revert AlreadyClaimed();
        claimed[msg.sender] = true;
        emit ClaimedFree(msg.sender, nft.getTotalMinted(), points[msg.sender]);
        nft.safeMint(msg.sender);
    }
}
