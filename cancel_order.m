function [ out ] = cancel_order( order_nos,key,secret)
%Written by Adam Luke, Adason Financial, 2018
%This function cancels orders on the Poloniex echange 
%order nos = cell array of strings with orders to cancel
%key = personal API key 
%secret = API secret

post_URL = 'https://poloniex.com/tradingApi'; 
api_key = key; 
api_secret = secret;


command = 'cancelOrder';
out = zeros(size(order_nos,1),1);

if isempty(order_nos)
    
else

for i = 1:size(order_nos,1)
    
nonce = num2str(round(datenum(clock)*10^10));    
parameters = ['command=',command, '&nonce=',nonce,'&orderNumber=',order_nos{i,1}];

request_string = HMAC(api_secret,parameters,'SHA-512');

header1=struct('name','Content-Type','value','application/x-www-form-urlencoded');
header2=struct('name','Key','value',api_key);
header3=struct('name','Sign','value',request_string);
headers=[header1, header2, header3];

success = 0; 
while success ==0
try
response = urlread2(post_URL,'POST',parameters,headers);

if strfind(response,'"success":1') > 0 
    out(i,1) = 1; 
elseif strfind(response,'error') > 0 
    out(i,1) = 0;
end

if isempty(response) 
else
    success = 1;
end


catch 
end


end

end

end



