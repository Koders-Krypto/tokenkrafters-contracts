// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ITokenKrafterBucket, TokenKrafterBucket} from "./TokenKrafterBucket.sol";

contract TokenKrafterFactory {
    event BucketCreated(
        address indexed creator,
        address indexed bucket,
        string name,
        string description,
        string tokenURI,
        ITokenKrafterBucket.TokenAllocation[] tokenAllocations
    );

    address[] private _deployedBuckets;
    address public swapRouter;

    constructor(address swapRouter_) {
        swapRouter = swapRouter_;
    }

    function deployedBuckets() external view returns (address[] memory) {
        return _deployedBuckets;
    }

    function createBucket(
        string memory name,
        string memory description,
        string memory bucketTokenURI,
        ITokenKrafterBucket.TokenAllocation[] memory tokenAllocations
    ) external {
        TokenKrafterBucket bucket = new TokenKrafterBucket(
            name,
            description,
            bucketTokenURI,
            msg.sender,
            swapRouter,
            tokenAllocations
        );
        _deployedBuckets.push(address(bucket));
        emit BucketCreated(
            msg.sender,
            address(bucket),
            name,
            description,
            bucketTokenURI,
            tokenAllocations
        );
    }
}
