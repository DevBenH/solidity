

pragma solidity >=0.4.16 <0.7.0;

contract Paylock {
    
    enum State { Working , Completed , Done_1 , Delay , Done_2 , Forfeit }
    
    uint256 clock;
    uint256 firstCall;
    int disc;
    address public timeAdd;
    State st;
    
    constructor(address remote) public {
        st = State.Working;
        disc = 0;
        timeAdd = remote;
    }

    function tick() public {
        require(msg.sender == timeAdd);
        clock = clock + 1;
    }
 
    function getTick() public view returns (uint256){
        require(msg.sender == timeAdd);
        return clock;
    }
 
    
    function signal() public {
        require( st == State.Working );
        st = State.Completed;
        disc = 10;
    }

    function collect_1_Y() public {
        require( st == State.Completed && clock < 4);
        st = State.Done_1;
        firstCall = clock;

        disc = 10;
    }

    function collect_1_N() external {
        require( st == State.Completed && clock >= 4);
        st = State.Delay;
        disc = 5;
    }

    function collect_2_Y() external {
        require( st == State.Delay );
        st = State.Done_2;
        disc = 5;
    }

    function collect_2_N() external {
        require( st == State.Delay );
        st = State.Forfeit;
        disc = 0;
    }
}

contract Supplier {
    
    Paylock p;
    Rental r;
    bool resource_acquired;
    uint public deposit_amount = 1 wei;

    enum State { Working , Completed, ResourceAcquired}
    
    State st;
    
    constructor(address payable pp, address payable rr) public {
        p = Paylock(pp);
        r = Rental(rr);
        st = State.Working;
    }
    
    function getRentalBalance() public view returns (uint256) {
        uint256 balance = address(r).balance;
        return balance;
    }
    
    function getYourBalance() public view returns (uint256) {
        uint256 Ybalance = msg.sender.balance;
        return Ybalance;
    }
    
    function finish() external payable{
        require (st == State.Working);
        p.signal();
        st = State.Completed;
    }
    
    event Recieved(address, uint);
    
    function acquire_resource() external payable {
        r.rent_out_resource.value(msg.value)();
        
        
    }
    
    function return_resource() external payable{
        r.retrieve_resource();
    }
    
    receive() external payable {
        emit Recieved(msg.sender, msg.value);
    }
    

}

contract Rental {
    
    address payable public resource_owner;
    bool public resource_available;
    uint public deposit_amount = 1 wei;

    event DepositReturned(address indexed _from, uint _value);

    constructor() public {
        resource_available = true;
    }
    
    function rent_out_resource() external payable {
        require(resource_available == true && msg.value == deposit_amount);
        resource_owner = msg.sender;
        resource_available = false;
    }

    function retrieve_resource() external payable{
        require(resource_available == false && msg.sender == resource_owner);
        (bool success,) = resource_owner.call.value(deposit_amount)("");
        emit DepositReturned(msg.sender, deposit_amount);
        resource_available = true;
    }

    
    receive() external payable {
        // Do nothing
    }
    
}




        
  
    


    

    
    
    
    
    
    
    
    