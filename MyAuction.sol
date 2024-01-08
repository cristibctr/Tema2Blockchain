// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import './SampleToken.sol';
import './ProductIdentification.sol';

contract Auction {
    
    address payable internal auction_owner;
    uint256 public auction_start;
    uint256 public auction_end;
    uint256 public highestBid;
    address public highestBidder;
    address public identificationOwner;
    SampleToken public sampleToken;

    enum auction_state{
        CANCELLED,STARTED
    }

    struct  car{
        string  Brand;
        string  Rnumber;
    }
    
    car public Mycar;
    address[] bidders;

    mapping(address => uint) public bids;

    auction_state public STATE;


    modifier an_ongoing_auction() {
        require(block.timestamp <= auction_end && STATE == auction_state.STARTED);
        _;
    }
    
    modifier only_owner() {
        require(msg.sender==auction_owner, "You are not the owner");
        _;
    }
    
    function bid(uint256 _token) public virtual returns (bool) {}
    function withdraw() public virtual returns (bool) {}
    function cancel_auction() external virtual returns (bool) {}
    
    event BidEvent(address indexed highestBidder, uint256 highestBid);
    event WithdrawalEvent(address withdrawer, uint256 amount);
    event CanceledEvent(string message, uint256 time);  
    
}

contract MyAuction is Auction {
    
    constructor (uint _biddingTime, address payable _owner, string memory _brand, string memory _Rnumber, address _identificationOwner, address _sampleToken) {
        identificationOwner = _identificationOwner;
        ProductIdentification identificationContract = ProductIdentification(identificationOwner);
        sampleToken = SampleToken(_sampleToken);
        require(identificationContract.getBrandInfo(_brand) > 0, "This brand doesn't exist in ProductIdentification");
        
        auction_owner = _owner;
        auction_start = block.timestamp;
        auction_end = auction_start + _biddingTime*1 hours;
        STATE = auction_state.STARTED;
        Mycar.Brand = _brand;
        Mycar.Rnumber = _Rnumber;
    } 
    
    function get_owner() public view returns(address) {
        return auction_owner;
    }
    
    fallback () external payable {
        
    }
    
    receive () external payable {
        
    }
    
    function bid(uint256 _token) public an_ongoing_auction override returns (bool) {
      
        require(bids[msg.sender] == 0, "You already made a bid");
        require(_token > highestBid,"You can't bid, Make a higher Bid");
        highestBidder = msg.sender;
        highestBid = _token;
        bidders.push(msg.sender);
        bids[msg.sender] = highestBid;

        sampleToken.transferFrom(msg.sender, address(this), _token);
        emit BidEvent(highestBidder,  highestBid);

        return true;
    } 
    
    function cancel_auction() external only_owner an_ongoing_auction override returns (bool) {
    
        STATE = auction_state.CANCELLED;
        emit CanceledEvent("Auction Cancelled", block.timestamp);
        return true;
    }
    
    function withdraw() public override returns (bool) {
        
        require(block.timestamp > auction_end || STATE == auction_state.CANCELLED,"You can't withdraw, the auction is still open");
        require(highestBidder != msg.sender, "You can't withdraw if you won");
        uint amount;
        amount = bids[msg.sender];
        bids[msg.sender] = 0;
        
        sampleToken.transfer(msg.sender, amount);
        emit WithdrawalEvent(msg.sender, amount);

        return true;
    }
    
    function destruct_auction() external only_owner returns (bool) {
        
        require(block.timestamp > auction_end || STATE == auction_state.CANCELLED,"You can't destruct the contract,The auction is still open");
        for(uint i = 0; i < bidders.length; i++)
        {
            if(bids[bidders[i]] != 0 && bidders[i] != highestBidder)
            sampleToken.transfer(msg.sender, bids[bidders[i]]);
        }
        selfdestruct(auction_owner);
        return true;
    
    } 
}
