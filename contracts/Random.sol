pragma solidity 0.5.12;

import "./provableAPI.sol";

contract Random is usingProvable {
    uint256 constant NUM_RANDOM_BYTES_REQUESTED = 1;
    uint256 public latestNumber;

    event LogNewProvableQuery(string description);
    event generateRandomNumber(uint256 randomNumber);

    constructor() public {
        update();
    }

    function __callback(bytes32 _queryId, string memory _result, bytes memory proof) public {
        require(msg.sender == provable_cbAddress());

        uint256 randomNumber = uint256(keccak256(abi.encodePacked(_result))) % 100;
        latestNumber = randomNumber;
        emit generateRandomNumber(randomNumber);
    }

    function update() payable public {
        uint256 QUERY_EXECUTION_DELAY = 0;
        uint256 GAS_FOR_CALLBACK = 200000;
        bytes32 queryId = testRandom();
        /*
        bytes32 queryId = provable_newRandomDSQuery(
            QUERY_EXECUTION_DELAY,
            NUM_RANDOM_BYTES_REQUESTED,
            GAS_FOR_CALLBACK
        );*/
        emit LogNewProvableQuery("Provable query was sent, standing by for answer...");
    }

    function testRandom() public returns (bytes32) {
        bytes32 queryId = bytes(keccak256(abi.encodePacked(msg.sender);));
        __callback(queryId, "1", bytes("test));
        return queryId;
    }
}