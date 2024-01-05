// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import './SampleToken.sol';

contract SampleTokenSale {
    
    SampleToken public tokenContract;
    uint256 public tokenPrice;
    address owner;

    uint256 public tokensSold;

    event Sell(address indexed _buyer, uint256 indexed _amount);

    constructor(SampleToken _tokenContract, uint256 _tokenPrice) {
        owner = msg.sender;
        tokenContract = _tokenContract;
        tokenPrice = _tokenPrice;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    function modifyTokenPrice(uint256 _tokenPrice) external onlyOwner {
        tokenPrice = _tokenPrice;
    }

    function buyTokens(uint256 _numberOfTokens) external payable {
        require(msg.value >= _numberOfTokens * tokenPrice);
        require(tokenContract.transferFrom(owner, msg.sender, _numberOfTokens));
        emit Sell(msg.sender, _numberOfTokens);
        tokensSold += _numberOfTokens;

        if(msg.value == _numberOfTokens * tokenPrice) {
            return;
        }

        (bool change,) = payable(msg.sender).call{value: msg.value - _numberOfTokens * tokenPrice}("");
        require(change, "Couldn't send the change back to the buyer");
    }

    function endSale() external onlyOwner {
        require(tokenContract.transfer(owner, tokenContract.balanceOf(address(this))));
        payable(msg.sender).transfer(address(this).balance);
    }
}