const Betting = artifacts.require("Betting");

module.exports = function(deployer, network, accounts) {
  deployer.deploy(Betting).then(function(instance){
    instance.addBalance({
        value: web3.utils.toWei('1', 'ether'),
        from: accounts[0]
    }).catch(function(err){
        console.log(err);
    });
  });
};
