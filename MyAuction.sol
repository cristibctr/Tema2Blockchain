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
        require(msg.sender==auction_owner);
        _;
    }
    
    function bid() public virtual payable returns (bool) {}
    function withdraw() public virtual returns (bool) {}
    function cancel_auction() external virtual returns (bool) {}
    
    event BidEvent(address indexed highestBidder, uint256 highestBid);
    event WithdrawalEvent(address withdrawer, uint256 amount);
    event CanceledEvent(string message, uint256 time);  
    
}

contract MyAuction is Auction {
    
    constructor (uint _biddingTime, address payable _owner, string memory _brand, string memory _Rnumber, address _identificationOwner) {
        identificationOwner = _identificationOwner;
        ProductIdentification identificationContract = ProductIdentification(identificationOwner);
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
    
    function bid() public payable an_ongoing_auction override returns (bool) {
      
        for(uint i = 0; i < bidders.length; i++)
        {
            require(bidders[i] != msg.sender,"You've already made a bid");
        }
        require(bids[msg.sender] + msg.value > highestBid,"You can't bid, Make a higher Bid");
        highestBidder = msg.sender;
        highestBid = bids[msg.sender] + msg.value;
        bidders.push(msg.sender);
        bids[msg.sender] = highestBid;

        sampleToken.transfer(address(this), msg.value);
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
        uint amount;
        amount = bids[msg.sender];
        bids[msg.sender] = 0;
        
        sampleToken.transferFrom(address(this), msg.sender, amount);
        emit WithdrawalEvent(msg.sender, amount);

        return true;
    }
    
    function destruct_auction() external only_owner returns (bool) {
        
        require(block.timestamp > auction_end || STATE == auction_state.CANCELLED,"You can't destruct the contract,The auction is still open");
        for(uint i = 0; i < bidders.length; i++)
        {
            if(bids[bidders[i]] != 0 && bidders[i] != highestBidder)
            sampleToken.transferFrom(address(this), msg.sender, bids[bidders[i]]);
        }
        selfdestruct(auction_owner);
        return true;
    
    } 
}
