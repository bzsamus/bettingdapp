const Coinflip = artifacts.require("Coinflip");

module.exports = function(deployer, network, accounts) {
  deployer.deploy(Coinflip).then(function(instance){
    instance.addBalance({
        value: web3.utils.toWei('1', 'ether'),
        from: accounts[0]
    }).catch(function(err){
        console.log(err);
    });
  });
};
