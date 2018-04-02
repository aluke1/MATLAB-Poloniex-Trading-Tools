function [ balance,response ] = return_balance( coin,key,secret )
%Written by Adam Luke, Adason Financial, 2018
%this program returns account balances on Poloniex Exchange
%coin = acount balance to return 
%key = personal api key 
%secret = api secret key

account = 'exchange';
post_URL = 'https://poloniex.com/tradingApi'; 
api_key = key; 
api_secret = secret;

nonce = num2str(round(datenum(clock)*10^10));
command = 'returnAvailableAccountBalances';
parameters = ['command=',command, '&nonce=',nonce,'&account=',account];

request_string = HMAC(api_secret,parameters,'SHA-512'); %generate sign based on api secret and POST body

header1=struct('name','Content-Type','value','application/x-www-form-urlencoded');
header2=struct('name','Key','value',api_key);
header3=struct('name','Sign','value',request_string);
headers=[header1, header2, header3];

success = 0; 

   while success == 0
   
   try
   response = urlread2(post_URL,'POST',parameters,headers);
   idx_start = strfind(response,coin); 
   indices = (idx_start + length(coin) + 3) : (idx_start + length(coin) + 3) + 9; 
   balance = str2double(response(1,indices));
   success = 1; 
   catch 
   end
   end
   
   



end

