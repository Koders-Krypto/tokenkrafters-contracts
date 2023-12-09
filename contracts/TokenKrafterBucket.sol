// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ITokenKrafterBucket} from "./interfaces/ITokenKrafterBucket.sol";
import {ISwapRouter} from "./interfaces/ISwapRouter.sol";

contract TokenKrafterBucket is ITokenKrafterBucket, ERC721 {
    string public bucketName;
    string public bucketDescription;

    address public creator;
    address public swapRouter;
    string public bucketTokenURI;
    uint256 private _nextTokenId;
    TokenAllocation[] private _tokenAllocations;

    mapping(uint256 => UserAllocation[]) private _userAllocations;

    constructor(
        string memory name_,
        string memory description_,
        string memory bucketTokenURI_,
        address creator_,
        address swapRouter_,
        TokenAllocation[] memory tokenAllocations_
    ) ERC721(name_, "TKNFT") {
        bucketName = name_;
        bucketDescription = description_;
        bucketTokenURI = bucketTokenURI_;
        swapRouter = swapRouter_;
        creator = creator_;
        uint256 totalWeightage;
        for (uint256 i; i < tokenAllocations_.length; ++i) {
            _tokenAllocations.push(tokenAllocations_[i]);
            totalWeightage += tokenAllocations_[i].weightage;
        }
        if (totalWeightage != 100000) {
            revert InvalidTotalWeightage();
        }
    }

    function tokenAllocations()
        external
        view
        returns (TokenAllocation[] memory)
    {
        return _tokenAllocations;
    }

    function userAllocations(
        uint256 tokenId
    ) external view returns (UserAllocation[] memory) {
        return _userAllocations[tokenId];
    }

    function rebalance(TokenAllocation[] calldata tokenAllocations_) external {
        if (_msgSender() != creator) revert CallerNotBucketCreator();
        uint256 totalWeightage;
        for (uint256 i; i < tokenAllocations_.length; ++i) {
            _tokenAllocations[i] = tokenAllocations_[i];
            totalWeightage += tokenAllocations_[i].weightage;
        }
        if (totalWeightage != 100000) {
            revert InvalidTotalWeightage();
        }
        emit Rebalanced(_msgSender(), tokenAllocations_);
    }

    function invest(address tokenIn, uint256 amount) external {
        IERC20(tokenIn).transferFrom(_msgSender(), address(this), amount);
        uint256 tokenId = _nextTokenId++;
        UserAllocation[] storage userAllocation_ = _userAllocations[tokenId];
        for (uint256 i; i < _tokenAllocations.length; ++i) {
            TokenAllocation memory tokenAllocation = _tokenAllocations[i];
            uint256 amountIn = (amount * tokenAllocation.weightage) / 100000;
            if (tokenAllocation.tokenAddress != tokenIn) {
                IERC20(tokenIn).approve(swapRouter, amountIn);
                ISwapRouter.ExactInputSingleParams
                    memory swapParams = ISwapRouter.ExactInputSingleParams({
                        tokenIn: tokenIn,
                        tokenOut: tokenAllocation.tokenAddress,
                        fee: 3000,
                        recipient: address(this),
                        deadline: block.timestamp,
                        amountIn: amountIn,
                        amountOutMinimum: 0,
                        sqrtPriceLimitX96: 0
                    });
                uint256 amountOut = ISwapRouter(swapRouter).exactInputSingle(
                    swapParams
                );
                userAllocation_.push(
                    UserAllocation({
                        tokenAddress: tokenAllocation.tokenAddress,
                        amount: amountOut
                    })
                );
            } else {
                userAllocation_.push(
                    UserAllocation({
                        tokenAddress: tokenAllocation.tokenAddress,
                        amount: amountIn
                    })
                );
            }
        }
        _safeMint(_msgSender(), tokenId);
        emit Invested(_msgSender(), tokenIn, amount, tokenId, userAllocation_);
    }

    function withdraw(uint256 tokenId) external {
        if (ownerOf(tokenId) != _msgSender()) revert NotOwnerOfNFT();
        UserAllocation[] memory userAllocation_ = _userAllocations[tokenId];
        for (uint i; i < userAllocation_.length; ++i) {
            IERC20(userAllocation_[i].tokenAddress).transfer(
                _msgSender(),
                userAllocation_[i].amount
            );
        }
        _burn(tokenId);
        emit Withdraw(_msgSender(), tokenId);
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        _requireOwned(tokenId);

        return bucketTokenURI;
    }
}
