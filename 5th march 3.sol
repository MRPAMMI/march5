pragma solidity ^0.8.0;

contract Subscription {
    address public owner;   //the address that deployed the contract
    uint public subscriptionFee;   //the fee that needs to be paid to subscribe to the service
    uint public subscriptionPeriod;   //the duration of each subscription period, in seconds
    uint public subscriptionStart;   //the timestamp when the subscription service was activated
    bool public subscriptionActive;   //a boolean variable indicating whether the subscription service is currently active or not

    mapping(address => uint) public subscriptions;

    event Subscribe(address indexed _subscriber, uint _amount, uint _duration);
    event ActivateSubscription();

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier onlyWhileActive() {
        require(subscriptionActive == true);
        _;
    }

    constructor(uint _fee, uint _periodDays) {
        owner = msg.sender;
        subscriptionFee = _fee;
        subscriptionPeriod = _periodDays * 1 days;
        subscriptionActive = false;
    }

    function activateSubscription() public onlyOwner {
        require(subscriptionActive == false);
        subscriptionActive = true;
        subscriptionStart = block.timestamp;

        emit ActivateSubscription();
    }

    function subscribe() public payable onlyWhileActive {
        require(msg.value == subscriptionFee);

        uint newExpiration = subscriptions[msg.sender] + subscriptionPeriod;
        if (newExpiration < block.timestamp) {
            subscriptions[msg.sender] = block.timestamp + subscriptionPeriod;
        } else {
            subscriptions[msg.sender] = newExpiration;
        }

        emit Subscribe(msg.sender, msg.value, subscriptionPeriod);
    }

    function getExpiration(address _subscriber) public view returns (uint) {
        return subscriptions[_subscriber];
    }
}
