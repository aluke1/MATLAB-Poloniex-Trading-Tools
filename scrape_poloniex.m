clc
clear
%Written by Adam Luke, Adason Financial, 2018
%this program collects book data, margin trading data, and trade history data
%from the Poloniex exchange.  The program runs indefinitely

%save time and loop parameters of scraping algorithm
pause_length = 30;  %length of pause in loop (seconds) 
num_iters = 720; %(6 hours per save, assuming 30 second pause length)

%margin trading data initialize 
coin_names = {'BTC','XMR','XRP','ETH','DASH','STR','MAID'}; %collect margin trading data of these coins
num_coins = length(coin_names); 
data = cell(51,4,num_iters,num_coins); %array used to store margin trading data

%trade history data initialize
currencies = {'BTC_XMR','BTC_XRP','BTC_ETH','BTC_DASH','ETH_ZEC','ETH_REP'};
num_exchanges = length(currencies); 
num_rows = 20001; 
data_th = cell(num_rows,7,1,num_exchanges);%array used to store trade history data (one scrape per loop)

%book data initialize
time_bt_scrape = 43200;                    %approximate time between scrapes for trade history(seconds)
time_bt_fb  = 3600;                        %time between saving full full book (second)
num_orders = 300;                          %number of orders in partial book scrape
num_orders_large = 3000;                   %number of orders in full book scrape
data_b = cell(num_orders+1,4,num_iters,num_exchanges); %array used to store partial book data scraped at high temporal resolution
data_b_large = cell(num_orders_large+1,4,num_iters,num_exchanges); %array used to store full book data at low temporal resolution

%set counters
counter = 24;  
UNIX_time1 = (datenum(clock) - datenum(1970,1,1))*60*60*24;
UNIX_time0 = UNIX_time1 - time_bt_scrape;
day_counter = 1; 
save_name_book = ['book_data' num2str(counter)];
save_name_th = ['trade_history_data' num2str(counter)];
save_name_lr = ['loan_rate_data' num2str(counter)];
save_name_bl = ['full_book_data' num2str(counter)];
time_0 = datenum(clock) - time_bt_fb/(24*60*60); 
sl_counter = 1;

GO = 1;
while GO==1
    

tic
for i = 1:num_iters
    %this section grabs margin trading info 
    for j = 1:num_coins
    success =0; 
    while success == 0
    try    
    scrape = webread(['https://poloniex.com/public?command=returnLoanOrders&currency=' coin_names{j}]);
    
     for k = 1:50; 
            
            data{k+1,1,i,j} = str2num(scrape.offers(k,1).rate);
            data{k+1,2,i,j} = str2num(scrape.offers(k,1).amount);
            data{k+1,3,i,j} = scrape.offers(k,1).rangeMin;
            data{k+1,4,i,j} = scrape.offers(k,1).rangeMax;
            
     end
        
     
    success = 1;
    catch  
    end
    end
    time = clock; 
    data{1,1,i,j} = coin_names{j}; 
    data{1,2,i,j} = time;
    
    
   
    marg_trade = j/num_coins
    end
    %this section grabs information on current asks and bids (book)
    for j = 1:num_exchanges 
        success =0; 
        
        while success == 0
        try    
        book = webread(['https://poloniex.com/public?command=returnOrderBook&currencyPair=' currencies{1,j} '&depth=' num2str(num_orders)]);
        
        time = clock;
        data_b{1,1,i,j} = time; 
        data_b{1,2,i,j} = currencies{1,j};
        data_b{1,3,i,j} = book.isFrozen; 
        data_b{1,4,i,j} = book.seq; 
        asks = book.asks; 
        bids = book.bids; 
        
        for k = 1:size(asks,1); 
        
            data_b{k+1,1,i,j} = str2num(asks{k,1}{1,1});
            data_b{k+1,2,i,j} = asks{k,1}{2,1};

        
        end
    
        for k = 1:size(bids,1);
    
            data_b{k+1,3,i,j} = str2num(bids{k,1}{1,1});
            data_b{k+1,4,i,j} = bids{k,1}{2,1};
        
        end
        
        
        success = 1;
        catch 
        end
        end
        
    
    
     book_trade = j/num_exchanges
    end
    
    %this section grabs order history (once per loop, about every
    %num_iters*pause_length seconds)
    UNIX_time1 = (datenum(clock) - datenum(1970,1,1))*60*60*24;
    
        if i == 1;
            
            for j = 1:num_exchanges 
                
                success = 0; 
                currency_xc = currencies{j};
                while success == 0
                try
                web_call = ['https://poloniex.com/public?command=returnTradeHistory&currencyPair=' currency_xc '&start=' num2str(UNIX_time0) '&end=' num2str(UNIX_time1)];
                th = webread(web_call);
                
                data_th{1,1,1,j} = UNIX_time0; 
                data_th{1,2,1,j} = UNIX_time1;
                data_th{1,3,1,j} = currency_xc;
                
                for k = 1:min([num_rows,size(th,1)])
                    data_th{k+1,1,1,j}=th(k,1).globalTradeID;
                    data_th{k+1,2,1,j}=th(k,1).tradeID;
                    data_th{k+1,3,1,j}=th(k,1).date;
                    data_th{k+1,4,1,j}=th(k,1).type;
                    data_th{k+1,5,1,j}=str2num(th(k,1).rate);
                    data_th{k+1,6,1,j}=str2num(th(k,1).amount);
                    data_th{k+1,7,1,j}=str2num(th(k,1).total);
                end
                
                
                success =1;
                catch 
                end
                end
                
            history_trade = j/num_exchanges  
            end
            
            day_counter = day_counter + 1; %update index for th data array 
            UNIX_time0 = UNIX_time1; %update time of scraape 
        else
        end
        
        time_1 = datenum(clock);
        
        if time_1 - time_0 > time_bt_fb/(24*60*60)
         %this sections grabs the full market depth every hour   
            for j = 1:num_exchanges 
            success =0; 
        
            while success == 0
            try    
            book = webread(['https://poloniex.com/public?command=returnOrderBook&currencyPair=' currencies{1,j} '&depth=' num2str(num_orders_large)]);
        
            time = clock;
            data_b_large{1,1,sl_counter,j} = time; 
            data_b_large{1,2,sl_counter,j} = currencies{1,j};
            data_b_large{1,3,sl_counter,j} = book.isFrozen; 
            data_b_large{1,4,sl_counter,j} = book.seq; 
            asks = book.asks; 
            bids = book.bids; 
        
            for k = 1:size(asks,1); 
        
                data_b_large{k+1,1,sl_counter,j} = str2num(asks{k,1}{1,1});
                data_b_large{k+1,2,sl_counter,j} = asks{k,1}{2,1};

        
            end
    
            for k = 1:size(bids,1);
    
            data_b_large{k+1,3,sl_counter,j} = str2num(bids{k,1}{1,1});
            data_b_large{k+1,4,sl_counter,j} = bids{k,1}{2,1};
        
            end
        
       
             success = 1;
            catch 
            end
            end
            
    
    
             large_book_scrape= j/num_exchanges
            end
            
            
            sl_counter = sl_counter +1;
            time_0 = datenum(clock);
        else
        end
        
 total_complete =  i/num_iters
 pause(pause_length)  
end
    save_data_b_large = data_b_large(:,:,1:sl_counter-1,:); 
    
    %save data to disk
    save(save_name_book,'data_b','num_iters')
    save(save_name_th,'data_th','num_iters')
    save(save_name_lr,'data','num_iters')
    save(save_name_bl,'save_data_b_large','num_iters')
    
    %delete variables
    clear data data_b data_th data_b_large save_data_b_large
    
    %re-initialize arrays
    data = cell(51,4,num_iters,num_coins); 
    data_b = cell(num_orders+1,4,num_iters,num_exchanges);  
    data_th = cell(num_rows,7,1,num_exchanges);
    data_b_large = cell(num_orders_large+1,4,num_iters,num_exchanges);
    
    %change name of saved variables
    counter = counter +1 
    sl_counter = 1;
    save_name_book = ['book_data' num2str(counter)];
    save_name_th = ['trade_history_data' num2str(counter)];
    save_name_lr = ['loan_rate_data' num2str(counter)];
    save_name_bl = ['full_book_data' num2str(counter)];



end






