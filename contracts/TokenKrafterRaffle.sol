// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {VRFV2WrapperConsumerBase} from "@chainlink/contracts/src/v0.8/vrf/VRFV2WrapperConsumerBase.sol";

import {ISwapRouter} from "./interfaces/ISwapRouter.sol";

contract TokenKrafterRaffle is Ownable, ERC721, VRFV2WrapperConsumerBase {
    struct RequestStatus {
        uint256 paid;
        bool fulfilled;
        uint256[] randomWords;
    }

    mapping(uint256 => RequestStatus) public s_requests;
    mapping(address => bool) public isTokenAdded;

    uint32 internal constant CALLBACK_GAS_LIMIT = 100000;

    uint256 private _nextTokenId;
    address public swapRouter;
    address public rewardToken;
    address public link;
    address public wrapper;
    uint256 public lastRequestId;
    address[] public depositedTokens;
    uint256[] public requestIds;

    address public winner;
    address[] private _participants;

    constructor(
        address swapRouter_,
        address rewardToken_,
        address link_,
        address wrapper_
    )
        Ownable(_msgSender())
        ERC721("TokenKrafterRaffle", "TKR")
        VRFV2WrapperConsumerBase(link, wrapper)
    {
        swapRouter = swapRouter_;
        rewardToken = rewardToken_;
        link = link_;
        wrapper = wrapper_;
    }

    function deposit(
        address[] calldata tokens,
        uint256[] calldata amounts
    ) external {
        for (uint256 i; i < tokens.length; ++i) {
            IERC20(tokens[i]).transferFrom(
                _msgSender(),
                address(this),
                amounts[i]
            );
            if (!isTokenAdded[tokens[i]]) {
                isTokenAdded[tokens[i]] = true;
                depositedTokens.push(tokens[i]);
            }
        }
        uint256 tokenId = _nextTokenId++;
        _safeMint(_msgSender(), tokenId);
        _participants.push(_msgSender());
    }

    function drawWinner() external onlyOwner {
        uint256 requestId = requestRandomness(CALLBACK_GAS_LIMIT, 3, 1);
        s_requests[requestId] = RequestStatus({
            paid: VRF_V2_WRAPPER.calculateRequestPrice(CALLBACK_GAS_LIMIT),
            randomWords: new uint256[](0),
            fulfilled: false
        });
        requestIds.push(requestId);
        lastRequestId = requestId;
    }

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        require(s_requests[_requestId].paid > 0, "request not found");
        s_requests[_requestId].fulfilled = true;
        s_requests[_requestId].randomWords = _randomWords;
        _distributePrize(_randomWords[0] % _nextTokenId);
    }

    function participants() external view returns (address[] memory) {
        return _participants;
    }

    function withdrawLink() public onlyOwner {
        require(
            IERC20(link).transfer(
                msg.sender,
                IERC20(link).balanceOf(address(this))
            ),
            "Unable to transfer"
        );
    }

    function _distributePrize(uint256 tokenId) internal {
        winner = ownerOf(tokenId);
        for (uint256 i; i < depositedTokens.length; ++i) {
            if (depositedTokens[i] != rewardToken) {
                uint256 tokenBalance = IERC20(depositedTokens[i]).balanceOf(
                    address(this)
                );
                IERC20(depositedTokens[i]).approve(swapRouter, tokenBalance);
                ISwapRouter.ExactInputSingleParams
                    memory swapParams = ISwapRouter.ExactInputSingleParams({
                        tokenIn: depositedTokens[i],
                        tokenOut: rewardToken,
                        fee: 3000,
                        recipient: address(this),
                        deadline: block.timestamp,
                        amountIn: tokenBalance,
                        amountOutMinimum: 0,
                        sqrtPriceLimitX96: 0
                    });
                ISwapRouter(swapRouter).exactInputSingle(swapParams);
            }
        }
        uint256 amountWon = IERC20(rewardToken).balanceOf(address(this));
        IERC20(rewardToken).transfer(winner, amountWon);
    }
}
