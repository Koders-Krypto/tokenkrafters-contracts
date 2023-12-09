// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ITokenKrafterBucket, TokenKrafterBucket} from "./TokenKrafterBucket.sol";

contract TokenKrafterFactory {
    address public swapRouter;

    constructor(address swapRouter_) {
        swapRouter = swapRouter_;
    }

    function createBucket(
        ITokenKrafterBucket.TokenAllocation[] memory tokenAllocations
    ) external {
        TokenKrafterBucket bucket = new TokenKrafterBucket(
            msg.sender,
            swapRouter,
            tokenAllocations
        );
    }
}
