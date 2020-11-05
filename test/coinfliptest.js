const Coinflip = artifacts.require("Coinflip");
const truffleAssert = require("truffle-assertions");

contract("Coinflip", async function(accounts){
    it("shouldn't let user withdraw balances", async function(){
        let instance  = await Coinflip.deployed();
        await truffleAssert.fails(instance.withdrawAll({
            from: accounts[1],
        }), truffleAssert.ErrorType.REVERT);
    });
    it("should let owner withdraw balances", async function(){
        let instance  = await Coinflip.deployed();
        let contractAddress = instance.contract._address;
        let ownerBalance = await web3.eth.getBalance(await instance.owner());
        await instance.withdrawAll({
            from: accounts[0]
        });
        assert.equal(await web3.eth.getBalance(contractAddress), 0);
        assert(await web3.eth.getBalance(await instance.owner()) > ownerBalance);
    });
    it("shouldn't let user add balances to the contract using addBalance", async function(){
        let instance  = await Coinflip.deployed();
        await truffleAssert.fails(instance.addBalance({
            from: accounts[1],
            value: web3.utils.toWei("1", "ether")
        }), truffleAssert.ErrorType.REVERT);
    });
    it("should let owner add balances to the contract using addBalance", async function(){
        let instance = await Coinflip.deployed();
        let result = await instance.addBalance({
            from: accounts[0],
            value: web3.utils.toWei("1", "ether")
        });
        console.log(result);
        truffleAssert.eventEmitted(result, "balanceAdded");
        assert.equal(parseFloat(await instance.balance()), web3.utils.toWei("1", "ether"));
    });
});