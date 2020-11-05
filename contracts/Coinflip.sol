import "./Ownable.sol";
import "./Random.sol";

pragma solidity 0.5.12;

contract Coinflip is Ownable, Random {
    uint public balance;

    struct User {
        bool betting;
        bytes32 queryId;
        uint balance;
    }

    mapping (address => User) private userMapping;
    address[] private users;

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

   function userExist() private returns(bool){
       address creator = msg.sender;
       if (users[creator]) {
           return true;
       }
       return false;
   }

   function insertUser(User memory newUser) private {
        address creator = msg.sender;
        users[creator] = newUser;
    }
    function getUser() public view returns(bool betting, bytes32 queryId, uint balance){
        address creator = msg.sender;
        return (userMapping[creator].betting, userMapping[creator].queryId, userMapping[creator].balance);
    }

    function bet() public payable returns(uint){
        uint wager = msg.value;
        address payable user = msg.sender;
        User memory user;
        if (userExist()) {
            (user.betting, user.queryId, user.balance) = getUser();
        } else {
            user.betting = false;
            user.balance = 0;
            insertUser(user);
            users.push(msg.sender);
        }

    }
}