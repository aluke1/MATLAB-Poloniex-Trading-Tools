function [ book_out ] = return_book(coin_pair,num_orders)
%Written by Adam Luke, Adason Financial, 2018
%this function returns the book on the Poloniex Exchange
%coin_pair = currency pair 
%num_orders = number of orders from the book to return

success = 0;

        while success == 0
        try    
        book = webread(['https://poloniex.com/public?command=returnOrderBook&currencyPair=' coin_pair '&depth=' num2str(num_orders)]);
        asks = book.asks;
        bids = book.bids;
  
        book_out = zeros(size(asks,1)+1,4); %arrange data into array
        book_out(1,1) = datenum(clock);
        book_out(1,2) = str2num(book.isFrozen);
        book_out(1,3) = book.seq;
        
        if book_out(1,2) == 1
            
        
            
        else
            
        for k = 1:size(asks,1) 
        
            book_out(k+1,1) = str2num(asks{k,1}{1,1});
            book_out(k+1,2) = asks{k,1}{end,end};

        
        end
    
        for k = 1:size(bids,1)
    
            book_out(k+1,3) = str2num(bids{k,1}{1,1});
            book_out(k+1,4) = bids{k,1}{end,end};
        
        end
        
        end
        
        

        
        
        success = 1;
        catch 
        end
        end



%end

