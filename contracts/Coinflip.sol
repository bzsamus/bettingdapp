import "./Ownable.sol";
pragma solidity 0.5.12;

contract Coinflip is Ownable {
    uint public balance;
    event balanceAdded(uint amount, uint totalBalance);
    event userWin(uint amount);
    event userLose(uint amount);

    function random() public view returns (uint) {
        return now % 2;
    }

    function addBalance() public payable onlyOwner {
        require(msg.value > 0, "Need to send some values");
        balance += msg.value;
        emit balanceAdded(msg.value, balance);
    }

    function withdrawAll() public onlyOwner returns(uint) {
       uint toTransfer = balance;
       balance = 0;
       msg.sender.transfer(toTransfer);
       return toTransfer;
   }

    function bet() public payable returns(uint){
        uint wager = msg.value;
        address payable user = msg.sender;
        if(random() == 1) {
            uint prize = wager * 2;
            balance -= prize;
            user.transfer(prize);
            emit userWin(prize);
            return prize;
        } else {
            balance += wager;
            emit userLose(wager);
            return 0;
        }
    }
}