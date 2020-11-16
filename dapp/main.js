var web3 = new Web3(Web3.givenProvider);
var contractInstance;
let user = {};
var accounts = [];

window.ethereum.on('accountsChanged', function (accounts) {
    hideAlerts();
    refreshAccount(accounts);
    refreshBalance();
})

let refreshBalance = function() {
    
    contractInstance.methods.poolBalance().call().then(function(res){
        $('#balance_output').text(web3.utils.fromWei(res, 'ether'));
    });
    web3.eth.getBalance(accounts[0]).then(function(res){
        $('#wallet_address_output').text(accounts[0]);
        $('#wallet_balance_output').text(web3.utils.fromWei(res, 'ether'));
    });
    contractInstance.methods.getUser().call().then(function(res){
        user.betting = res[0],
        user.queryId = res[1],
        user.wager   = res[2],
        user.balance = res[3];
        $('#winning_balance_output').text(web3.utils.fromWei(user.balance, 'ether'));
        if (user.betting) {
            $('#betting_div').addClass('d-none');
            $('#progress_detail').text(web3.utils.fromWei(user.wager, 'ether'));
            $('#progress_id').text(user.queryId);
            $('#progress_alert').removeClass('d-none');
        } else {
            $('#betting_div').removeClass('d-none');
            $('#progress_alert').addClass('d-none');
        }
        if (user.balance > 0) {
            $('#withdraw_button').removeClass('d-none');
        } else {
            $('#withdraw_button').addClass('d-none');
        }
    });
}

let refreshAccount = function(newAccounts) {
    accounts = newAccounts;
    contractInstance = new web3.eth.Contract(abi, "0xfDfCe883d8Bbaf1C41df3a9730f6a87DD63C01Ed", {from: accounts[0]});
        console.log(contractInstance);
        refreshBalance();

        contractInstance.events.userWin()
        .on('data', (event) => {
            console.log(event);
            if (event.returnValues.queryId == user.queryId) {
                $('#win_amount').text(web3.utils.fromWei(event.returnValues.amount, "ether"));
                $('#win_alert').removeClass('d-none').show();
                refreshBalance();
            }
        })
        .on('error', console.error);

        contractInstance.events.userLose()
        .on('data', (event) => {
            console.log(event);
            if (event.returnValues.queryId == user.queryId) {
                $('#lose_amount').text(web3.utils.fromWei(event.returnValues.amount, "ether"));
                $('#lose_alert').removeClass('d-none').show();
                refreshBalance();
            }
        })
        .on('error', console.error);
}


let hideAlerts = function(){
    $('#win_alert').addClass('d-none');
    $('#lose_alert').addClass('d-none');
    $('#error_alert').addClass('d-none');
    $('#progress_alert').addClass('d-none');
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
            $('#amount_input').prop('disabled', true);
            $('#place_bet_button').prop('disabled', true);
            $('#place_bet_button').text('Placing Bet...');
            contractInstance.methods.placeBet()
            .send({value: wager})
            .on("receipt", function(receipt){
                console.log(receipt);
                refreshBalance();
            })
            .then(function(){
                $('#amount_input').prop('disabled', false);
                $('#place_bet_button').prop('disabled', false);
                $('#place_bet_button').text('Place Bet');
            })
            .catch(function(){
                $('#amount_input').prop('disabled', false);
                $('#place_bet_button').prop('disabled', false);
                $('#place_bet_button').text('Place Bet');
            })
        }
    });

    $('#withdraw_button').click(function() {
        if (user.balance > 0) {
            $('#withdraw_button').prop('disabled', true);
            contractInstance.methods.withdrawUserBalance()
            .send()
            .then(function(){
                refreshBalance();
                $('#withdraw_button').prop('disabled', false);
            })
            .catch(function(){
                $('#withdraw_button').prop('disabled', false);
            });
        }
    });
});
