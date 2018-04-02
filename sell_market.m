function [ trades ] = sell_market( pair, amount, fee, key, secret )
%Written by Adam Luke, Adason Financial, 2018
%this function sells available currency by taking open orders on the books
%the goal is to sell all of the "amount" currency.  no rate is
%input because we are taking the market rate 

%pair = currency pair to exchange 
%amount = amount of currency to sell
%pair = currency pair (selling second in pair name) 
%fee = exchange fee used to calculate amount available to sell 
%key = personal API key 
%secret = API secret

trades = [];
post_URL = 'https://poloniex.com/tradingApi'; 

api_key = key; 
api_secret = secret;
command = 'sell';

amount_s = amount/(1 + fee);

book = return_book(pair,50);
%sell price | sell amount (2nd cur) | buy price | buy amount (2nd curr)  
sum_sell = cumsum(book(2:end,4));
idx_filled = find(sum_sell(:,1) >= amount_s); 
idx_price = min(idx_filled);
rate = book(idx_price + 1, 3);
total = amount_s*rate ;


a=1;
while total > 1e-4
 
try
nonce = num2str(round(datenum(clock)*10^10));
parameters = ['command=',command, '&nonce=',nonce,'&currencyPair=',pair,'&rate=',num2str(rate_f),'&amount=',num2str(amount_s),'&immediateOrCancel=1'];   
request_string = HMAC(api_secret,parameters,'SHA-512');
 
header1=struct('name','Content-Type','value','application/x-www-form-urlencoded');
header2=struct('name','Key','value',api_key);
header3=struct('name','Sign','value',request_string);
headers=[header1, header2, header3];
    


response = urlread2(post_URL,'POST',parameters,headers)


amount = return_balance(pair(1,5:7));
amount_s = amount/(1 + fee);

book = return_book(pair,50); 
%sell price | sell amount (2nd cur) | buy price | buy amount (2nd curr)  
sum_sell = cumsum(book(2:end,4));
idx_filled = find(sum_sell(:,1) >= amount_s); 
idx_price = min(idx_filled);
rate = book(idx_price + 1, 3) - book(idx_price + 1, 3)*fudge;
total = amount_s*rate; 




amount_idx = strfind(response,'amount"'); 
rate_idx   = strfind(response,'rate'); 

if isempty(rate_idx) 
  
else 
    
    for i = 1:length(amount_idx)
        
        amount_idc = amount_idx(i)+ 9:amount_idx(i)+ 9 + 9; 
        rate_idc = rate_idx(i)+ 7:rate_idx(i)+ 7 + 9;
        trades{a,1} = response(1,amount_idc); 
        trades{a,2} = response(1,rate_idc); 
        trades{a,3} = datenum(clock); 
        a=a+1; 
    end
    
end

catch
end
end



