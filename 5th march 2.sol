pragma solidity ^0.8.0;

contract Crowdfunding {
    address public owner;   //the address that deployed the contract.
    uint public fundingGoal;  //the amount of ether that needs to be raised for the campaign to be considered successful
    uint public deadline;   //the timestamp after which contributions will no longer be accepted
    uint public totalFundsRaised;   //the amount of ether that has been raised so far
    bool public fundingActive;   //a boolean variable indicating whether the funding campaign is currently active or not.

    mapping(address => uint) public contributions;

    event Contribute(address indexed _contributor, uint _amount);
    event FundingSuccessful(uint _totalFundsRaised);
    event FundingFailed();

    constructor(uint _fundingGoal, uint _durationDays) {
        owner = msg.sender;
        fundingGoal = _fundingGoal;
        deadline = block.timestamp + (_durationDays * 1 days);
        fundingActive = false;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier fundingIsOpen() {
        require(fundingActive == true);
        _;
    }

    function startFunding() public onlyOwner {
        require(fundingActive == false);
        fundingActive = true;
    }

    function endFunding() public onlyOwner {
        require(fundingActive == true);
        fundingActive = false;

        if (totalFundsRaised >= fundingGoal) {
            emit FundingSuccessful(totalFundsRaised);
            owner.transfer(address(this).balance);
        } else {
            emit FundingFailed();
            for (uint i = 0; i < contributors.length; i++) {
                address payable contributor = payable(contributors[i]);
                uint amount = contributions[contributor];
                contributor.transfer(amount);
            }
        }
    }

    function contribute() public payable fundingIsOpen {
        contributions[msg.sender] += msg.value;
        totalFundsRaised += msg.value;

        emit Contribute(msg.sender, msg.value);
    }

    function getContribution(address _contributor) public view returns (uint) {
        return contributions[_contributor];
    }
}
