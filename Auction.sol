pragma solidity >=0.4.22 <0.6.0;

contract Auction{
    address payable public owner;
    uint public startBlock;
    uint public endBlock;
    string public ipfsHash;
    
    enum State {Started, Running, Ended, Cancelled}
    State public auctionState;
    
    uint public highestBindingBid;
    address payable public highestBidder;
    
    mapping (address => uint) public bids;
    
    uint bidIncrement;
    
    constructor() public {
        owner = msg.sender;
        auctionState = State.Running;
        
        startBlock = block.number;
        endBlock = startBlock + 40320;
        ipfsHash = "";
        bidIncrement = 10;
        
    }
    
    modifier notOwner {
        require(msg.sender != owner);
        _;
    }
    
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    modifier afterStart(){
        require(block.number >= startBlock);
        _;
    }
    
    modifier beforeEnd(){
        require(block.number <= endBlock);
        _;
    } 
    
    function min(uint a, uint b) pure internal returns(uint) {
        if(a <= b){
            return a;
        } else{
            return b;
        }
    }
    
    function cancelAuction() public onlyOwner {
        auctionState = State.Cancelled;
    }
    
    
    
    function placeBid() public payable notOwner afterStart beforeEnd returns(bool){
        require(auctionState == State.Running);
        //require(msg.value > 0.001 ether);
        
        uint currentBid = bids[msg.sender] + msg.value;
        
        require(currentBid  > highestBindingBid);
        
        bids[msg.sender] = currentBid;
        
        if(currentBid <= bids[highestBidder]){
            highestBindingBid = min(currentBid + bidIncrement, bids[highestBidder]);
        } else {
            highestBindingBid = min(currentBid, bids[highestBidder] + bidIncrement);
            highestBidder = msg.sender;
        }
       return true; 
        
    }
    
    function finalizeAuction() public{
        require(auctionState == State.Cancelled || block.number > endBlock);
        require(msg.sender == owner || bids[msg.sender] > 0);
        
        address payable recepient;
        uint value;
        
        if(auctionState == State.Cancelled){
            recepient = msg.sender;
            value = bids[msg.sender];
        }else{
            if(msg.sender == owner){
                recepient = owner;
                value = highestBindingBid;
            } else{
            if(msg.sender == owner){
                recepient = highestBidder;
                value = bids[highestBidder] - highestBindingBid;
            }else{
                recepient = msg.sender;
                value = bids[msg.sender];
            }
        }
        
    }
        
        recepient.transfer(value);
    
}
    
}