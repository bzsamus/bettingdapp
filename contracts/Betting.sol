import "./Ownable.sol";
//import "./provableAPI.sol";

pragma solidity 0.5.12;

contract Betting is Ownable {
    uint public poolBalance;

    struct User {
        bool registered;
        bytes32 queryId;
        bool betting;
        uint wager;
        uint balance;
    }

    mapping (address => User) private userMapping;
    mapping (bytes32 => address) private queryIdMapping;
    address[] private users;

    event balanceAdded(uint amount, uint totalBalance);
    event userCreated(address userAddress);
    event userUpdated(bool betting, bytes32 queryId, uint wager, uint balance);
    event userWin(uint amount);
    event userLose(uint amount);
    event LogNewProvableQuery(string description);
    event generateRandomNumber(uint256 randomNumber);

    function __callback(bytes32 _queryId, string memory _result, bytes memory proof) public {
        //require(msg.sender == provable_cbAddress());
        uint256 randomNumber = uint256(keccak256(abi.encodePacked(_result))) % 100;
        emit generateRandomNumber(randomNumber);
        address userAddress = queryIdMapping[_queryId];
        User memory user = userMapping[userAddress];
        uint prize = user.wager * 2;
        if(user.queryId == _queryId && user.betting) {
            if (randomNumber > 50) {
                userMapping[userAddress].balance += prize;
                poolBalance -= prize;
                emit userWin();
            } else {
                poolBalance += user.wager;
                emit userLose(user.wager);
            }
        }
        resetUserBet();
    }

    function addBalance() public payable onlyOwner {
        require(msg.value > 0, "Need to send some values");
        poolBalance += msg.value;
        emit balanceAdded(msg.value, poolBalance);
    }

    function withdrawAll() public onlyOwner returns(uint) {
       uint toTransfer = poolBalance;
       poolBalance = 0;
       msg.sender.transfer(toTransfer);
       return toTransfer;
   }

   function withdrawUserBalance() public payable returns(uint) {
       address userAddress = msg.sender;
       uint toTransfer = userMapping[userAddress].balance;
       userMapping[userAddress].balance = 0;
       msg.sender.transfer(toTransfer);
       return toTransfer;
   }

   function userExist() public view returns(bool){
       address creator = msg.sender;
       if (userMapping[creator].registered) {
           return true;
       }
       return false;
   }

   function insertUser() private {
        if (!userExist()) {
            User memory user;
            address creator = msg.sender;
            user.registered = true;
            user.betting = false;
            user.balance = 0;
            user.wager = 0;
            userMapping[creator] = user;
            users.push(creator);
            emit userCreated(creator);
        }
    }

    function updateUserBetting(bool betting, uint wager) private {
        address creator = msg.sender;
        if (betting) {
            userMapping[creator].betting = true;
            userMapping[creator].wager = wager;
        } else {
            userMapping[creator].betting = false;
            userMapping[creator].wager = 0;
        }
        emit userUpdated(
            userMapping[creator].betting,
            userMapping[creator].queryId,
            userMapping[creator].wager,
            userMapping[creator].balance
        );
    }

    function updateUserQueryId(bytes32 queryId) private {
        address creator = msg.sender;
        userMapping[creator].queryId = queryId;
        emit userUpdated(
            userMapping[creator].betting,
            userMapping[creator].queryId,
            userMapping[creator].wager,
            userMapping[creator].balance
        );
    }

    function updateUserBalance(uint newBalance) private {
        address creator = msg.sender;
        userMapping[creator].balance = newBalance;
        emit userUpdated(
            userMapping[creator].betting,
            userMapping[creator].queryId,
            userMapping[creator].wager,
            userMapping[creator].balance
        );
    }

    function resetUserBet() private {
        address creator = msg.sender;
        userMapping[creator].betting = false;
        userMapping[creator].wager = 0;
        userMapping[creator].queryId = '';
        emit userUpdated(
            userMapping[creator].betting,
            userMapping[creator].queryId,
            userMapping[creator].wager,
            userMapping[creator].balance
        );
    }

    function getUser() public view returns(bool, bytes32, uint){
        address creator = msg.sender;
        return (userMapping[creator].betting, userMapping[creator].queryId, userMapping[creator].balance);
    }

    function placeBet() public payable returns(uint){
        uint wager = msg.value;
        address userAddress = msg.sender;
        User memory user;

        if (userExist()) {
            (user.betting, user.queryId, user.balance) = getUser();
        } else {
            insertUser();
            (user.betting, user.queryId, user.balance) = getUser();
        }
        bytes32 queryId = testGetQueryId();
        updateUserQueryId(queryId);
        updateUserBetting(true, wager);
        queryIdMapping[queryId] = userAddress;
        emit LogNewProvableQuery("Provable query was sent, standing by for answer...");
        testRandom(queryId);
    }

    function testGetQueryId() public returns(bytes32) {
        return bytes32(keccak256(abi.encodePacked(msg.sender)));
    }
    function testRandom(bytes32 queryId) public {
        __callback(queryId, "60", bytes("test"));
    }

    function deleteMe() public {
        selfdestruct(address(uint160(owner)));
    }
}