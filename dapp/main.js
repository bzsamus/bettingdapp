var web3 = new Web3(Web3.givenProvider);
var contractInstance;

window.ethereum.on('accountsChanged', function (accounts) {
    hideAlerts();
    refreshAccount(accounts);
    refreshBalance(accounts);
})

let refreshBalance = function(accounts) {
    contractInstance.methods.poolBalance().call().then(function(res){
        $('#balance_output').text(web3.utils.fromWei(res, "ether"));
    });
    web3.eth.getBalance(accounts[0]).then(function(res){
        $('#wallet_address_output').text(accounts[0]);
        $('#wallet_balance_output').text(web3.utils.fromWei(res, "ether"));
    });
    contractInstance.methods.getUser().call().then(function(res){
        $('#winning_balance_output').text(web3.utils.fromWei(res[3], "ether"));
        if (res[3] > 0) {
            $('#withdraw_button').removeClass('d-none');
        } else {
            $('#withdraw_button').addClass('d-none');
        }
    });
}

let refreshAccount = function(accounts) {
    contractInstance = new web3.eth.Contract(abi, "0x1CE5879b90627d2A97c4B76A1fF31E8eA31B9183", {from: accounts[0]});
        console.log(contractInstance);
        refreshBalance(accounts);

        contractInstance.events.userWin()
        .on('data', (event) => {
            console.log(event);
            $('#win_amount').text(web3.utils.fromWei(event.returnValues.amount, "ether"));
            $('#win_alert').show();
            refreshBalance(accounts);
        })
        .on('error', console.error);

        contractInstance.events.userLose()
        .on('data', (event) => {
            console.log(event);
            $('#lose_amount').text(web3.utils.fromWei(event.returnValues.amount, "ether"));
            $('#lose_alert').show()
            refreshBalance(accounts);
        })
        .on('error', console.error);
}


let hideAlerts = function(){
    $('#win_alert').hide();
    $('#lose_alert').hide();
    $('#error_alert').hide();
}

$(document).ready(function() {
    hideAlerts();
    window.ethereum.enable().then(function(accounts){
        refreshAccount(accounts);
    });
    
    $("#place_bet_button").click(function(){
        hideAlerts();
        var wager = web3.utils.toWei($('#amount_input').val(), "ether");
        if(wager > 0) {
            contractInstance.methods.placeBet()
            .send({value: wager})
            .on("receipt", function(receipt){
                console.log(receipt);
            })
        }
    })
});
