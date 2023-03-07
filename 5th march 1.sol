pragma solidity ^0.8.0;

contract TokenSale {
    address public owner;
    uint public price;         //the cost in wei of each token.
    uint public tokensSold;   //the number of tokens that have been sold so far.
    uint public totalTokens;  // the total number of tokens available for sale.
    bool public saleActive;   //a boolean variable indicating whether the sale is currently active or not.

    mapping(address => uint) public tokenBalance;

    event Sell(address indexed _buyer, uint _amount);

    constructor(uint _price, uint _totalTokens) {
        owner = msg.sender;
        price = _price;
        totalTokens = _totalTokens;
        saleActive = false;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    modifier saleIsOpen() {
        require(saleActive == true);
        _;
    }

    function startSale() public onlyOwner {
        require(saleActive == false);
        saleActive = true;
    }

    function endSale() public onlyOwner {
        require(saleActive == true);
        saleActive = false;
        owner.transfer(address(this).balance);
    }

    function buyTokens(uint _numberOfTokens) public payable saleIsOpen {
        require(msg.value == _numberOfTokens * price);
        require(tokensSold + _numberOfTokens <= totalTokens);

        tokenBalance[msg.sender] += _numberOfTokens;
        tokensSold += _numberOfTokens;

        emit Sell(msg.sender, _numberOfTokens);
    }

    function getTokenBalance() public view returns (uint) {
        return tokenBalance[msg.sender];
    }
}
