// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

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

    function buyTokens(uint256 _numberOfTokens) public payable {
        require(msg.value == _numberOfTokens * tokenPrice);
        require(tokenContract.balanceOf(address(this)) >= _numberOfTokens);
        require(tokenContract.transfer(msg.sender, _numberOfTokens));
        emit Sell(msg.sender, _numberOfTokens);
        tokensSold += _numberOfTokens;
    }

    function endSale() public {
        require(tokenContract.transfer(owner, tokenContract.balanceOf(address(this))));
        require(msg.sender == owner);
        payable(msg.sender).transfer(address(this).balance);
    }
}