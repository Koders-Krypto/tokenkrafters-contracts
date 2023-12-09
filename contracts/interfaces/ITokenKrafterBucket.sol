// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

interface ITokenKrafterBucket {
    error InvalidTotalWeightage();
    error NotOwnerOfNFT();
    error CallerNotBucketCreator();

    event Invested(
        address indexed investor,
        address indexed token,
        uint256 amount,
        uint256 tokenId,
        UserAllocation[] allocations
    );

    event Rebalanced(
        address indexed creator,
        TokenAllocation[] newTokenAllocation
    );

    event Withdraw(address indexed investor, uint256 tokenId);

    struct TokenAllocation {
        address tokenAddress;
        uint256 weightage;
    }

    struct UserAllocation {
        address tokenAddress;
        uint256 amount;
    }
}
