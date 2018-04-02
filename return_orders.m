function [ order_nos ] = return_orders( pair,key,secret )
%Written by Adam Luke, Adason Financial, 2018
%this function returns open orders on the Poloniex exchange 
%pair = currency pair to return open orders 
%key = personal API key 
%secret = API secret


post_URL = 'https://poloniex.com/tradingApi'; 
api_key = key; 
api_secret = secret;

a=1;
order_nos = [];
for j = 1:length(pair)
nonce = num2str(round(datenum(clock)*10^10));

command = 'returnOpenOrders';
parameters = ['command=',command, '&nonce=',nonce,'&currencyPair=',pair{1,j}];

request_string = HMAC(api_secret,parameters,'SHA-512');

header1=struct('name','Content-Type','value','application/x-www-form-urlencoded');
header2=struct('name','Key','value',api_key);
header3=struct('name','Sign','value',request_string);
headers=[header1, header2, header3];

success = 0;

while success ==0
try
response = urlread2(post_URL,'POST',parameters,headers);
success = 1;
catch 
end
end



order_idx = strfind(response,'orderNumber');


if isempty(order_idx) | strfind(response,'error') > 0
    
else 
   
    
   
    
   
        
        order_data = response(1,order_idx:order_idx +27);
        comma = strfind(order_data,',');
        
        order_nos{a,1} = order_data(1,15:comma-2);
        a=a+1;
    
    
end
end

