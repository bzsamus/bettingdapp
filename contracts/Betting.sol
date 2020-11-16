import "./Ownable.sol";
import "./provableAPI.sol";

pragma solidity 0.5.12;

contract Betting is Ownable, usingProvable {
    uint256 constant NUM_RANDOM_BYTES_REQUESTED = 1;
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
        require(msg.sender == provable_cbAddress());
        uint256 randomNumber = uint256(keccak256(abi.encodePacked(_result))) % 100;
        emit generateRandomNumber(randomNumber);
        address userAddress = queryIdMapping[_queryId];
        User memory user = userMapping[userAddress];
        uint prize = user.wager * 2;
        if(user.queryId == _queryId && user.betting) {
            if (randomNumber > 50) {
                userMapping[userAddress].balance += prize;
                poolBalance -= prize;
                emit userWin(prize);
            } else {
                poolBalance += user.wager;
                emit userLose(user.wager);
            }
        }
        resetUserBet(userAddress);
        queryIdMapping[_queryId] = address(0);
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
       require(toTransfer > 0, "No balance to withdraw");
       require(poolBalance > toTransfer, "Withdraw balance greater than prize pool");
       userMapping[userAddress].balance = 0;
       poolBalance -= toTransfer;
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

    function resetUserBet(address userAddress) private {
        userMapping[userAddress].betting = false;
        userMapping[userAddress].wager = 0;
        userMapping[userAddress].queryId = '';
        emit userUpdated(
            userMapping[userAddress].betting,
            userMapping[userAddress].queryId,
            userMapping[userAddress].wager,
            userMapping[userAddress].balance
        );
    }

    function getUser() public view returns(bool, bytes32, uint, uint){
        address creator = msg.sender;
        return (userMapping[creator].betting, userMapping[creator].queryId, userMapping[creator].wager, userMapping[creator].balance);
    }

    function placeBet() public payable returns(uint){
        uint256 QUERY_EXECUTION_DELAY = 0;
        uint256 GAS_FOR_CALLBACK = 200000;

        uint wager = msg.value;
        address userAddress = msg.sender;
        User memory user;

        if (userExist()) {
            (user.betting, user.queryId, user.wager, user.balance) = getUser();
        } else {
            insertUser();
            (user.betting, user.queryId, user.wager, user.balance) = getUser();
        }

        bytes32 queryId = provable_newRandomDSQuery(
            QUERY_EXECUTION_DELAY,
            NUM_RANDOM_BYTES_REQUESTED,
            GAS_FOR_CALLBACK
        );

        updateUserQueryId(queryId);
        updateUserBetting(true, wager);
        queryIdMapping[queryId] = userAddress;
        emit LogNewProvableQuery("Provable query was sent, standing by for answer...");
    }

    function testGetQueryId() public view returns(bytes32) {
        return bytes32(keccak256(abi.encodePacked(msg.sender)));
    }
    function testRandom(bytes32 queryId) public {
        __callback(queryId, "60", bytes("test"));
    }

    function deleteMe() public onlyOwner{
        selfdestruct(address(uint160(owner)));
    }
}