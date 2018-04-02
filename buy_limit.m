function [ buy_order ] = buy_limit( pair,rate,amount,fee,key,secret )
%Written by Adam Luke, Adason Financial, 2018
%this function initiates a limit buy on the Poloniex exchange 
%pair = currency pair to exchange 
%rate = exchange rate
%amount = amount of currency to exchange (sell)
%fee = exchange fee used to calculate amount of currency to buy
%key = personal API key
%secret = API secret key


amount_cur = amount/(rate*(1 + fee)); %amount of currency to buy accounting for exchange fees


post_URL = 'https://poloniex.com/tradingApi'; 
api_key = key; 
api_secret = secret;

try
nonce = num2str(round(datenum(clock)*10^10));

command = 'buy';
parameters = ['command=',command, '&nonce=',nonce,'&currencyPair=',pair,'&rate=',num2str(rate_f),'&amount=',num2str(amount_cur)];

request_string = HMAC(api_secret,parameters,'SHA-512');

header1=struct('name','Content-Type','value','application/x-www-form-urlencoded');
header2=struct('name','Key','value',api_key);
header3=struct('name','Sign','value',request_string);
headers=[header1, header2, header3];



response = urlread2(post_URL,'POST',parameters,headers)
catch 
end


if strfind(response,'error') > 0
    buy_order = []; 
    
else
   
    
    buy_order(1,1) = amount_cur; 
    buy_order(1,2) = rate_f; 
    buy_order(1,3) = datenum(clock);
    
    
end


end


    



    
