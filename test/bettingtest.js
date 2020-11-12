const Betting = artifacts.require("Betting");
const truffleAssert = require("truffle-assertions");

contract("Betting", async function(accounts){
    it("shouldn't let user withdraw balances", async function(){
        let instance  = await Betting.deployed();
        await truffleAssert.fails(instance.withdrawAll({
            from: accounts[1],
        }));
    });
    it("should let owner withdraw balances", async function(){
        let instance  = await Betting.deployed();
        let contractAddress = instance.contract._address;
        let ownerBalance = await web3.eth.getBalance(await instance.owner());
        await instance.withdrawAll({
            from: accounts[0]
        });
        assert.equal(await web3.eth.getBalance(contractAddress), 0);
        assert(await web3.eth.getBalance(await instance.owner()) > ownerBalance);
    });
    it("shouldn't let user add balances to the contract using addBalance", async function(){
        let instance  = await Betting.deployed();
        await truffleAssert.fails(instance.addBalance({
            from: accounts[1],
            value: web3.utils.toWei("1", "ether")
        }));
    });
    it("should let owner add balances to the contract using addBalance", async function(){
        let instance = await Betting.deployed();
        let contractAddress = instance.contract._address;
        let contractBalance = await web3.eth.getBalance(contractAddress);
        let result = await instance.addBalance({
            from: accounts[0],
            value: web3.utils.toWei("1", "ether")
        });
        truffleAssert.eventEmitted(result, "balanceAdded");
        assert.equal(parseFloat(await instance.poolBalance()), contractBalance + web3.utils.toWei("1", "ether"));
    });
    it("should return false from userExist function if user does not exist", async function(){
        let instance = await Betting.deployed();
        assert.isFalse(await instance.userExist({
            from: accounts[2]
        }));
    });
    it("should create user when betting and user does not exist", async function(){
        let instance = await Betting.deployed();
        let result = await instance.placeBet({
            from: accounts[3]
        });
        truffleAssert.eventEmitted(result, "userCreated");
    });
});