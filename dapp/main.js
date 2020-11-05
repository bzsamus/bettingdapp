var web3 = new Web3(Web3.givenProvider);
var contractInstance;
let refreshBalance = function(accounts){
    web3.eth.getBalance(contractInstance._address).then(function(res){
        $('#balance_output').text(web3.utils.fromWei(res, "ether"));
    });
    web3.eth.getBalance(accounts[0]).then(function(res){
        $('#wallet_address_output').text(accounts[0]);
        $('#wallet_balance_output').text(web3.utils.fromWei(res, "ether"));
    });
}

let hideAlerts = function(){
    $('#win_alert').hide();
    $('#lose_alert').hide();
    $('#error_alert').hide();
}

$(document).ready(function() {
    hideAlerts();
    window.ethereum.enable().then(function(accounts){
        contractInstance = new web3.eth.Contract(abi, "0x8EED7DA3385dD1eB9e02C4f41881349255d51FA2", {from: accounts[0]});
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
    });
    
    $("#place_bet_button").click(function(){
        hideAlerts();
        var wager = web3.utils.toWei($('#amount_input').val(), "ether");
        if(wager > 0) {
            contractInstance.methods.bet()
            .send({value: wager})
            .on("receipt", function(receipt){
                console.log(receipt);
            })
        }
    })
});
