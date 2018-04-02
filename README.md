# MATLAB-Poloniex-Trading-Tools
This repository contains MATLAB function files for executing trades and other actions on the Poloniex Exchange.

By: Adam Luke, Adason Financial, 2018 

Files include: 

scrape_poloniex.m -> scrapes financial data from the Poloniex exchange, including margin trading data, trade histories, and order books

buy_limit.m       -> places a limit buy 

sell_market.m     -> sells currency using the market price (the price of current buy orders) 

cancel_order.m    -> cancels an open order 

return_balance.m  -> returns account balances 

return_book.m     -> returns open orders on the book

return_orders.m   -> returns your open orders on the book

required sub-functions: 

HMAC.m            -> outputs hash message authentication code 

DataHash.m	  -> creates a hash value (used by HMAC.m)

urlread2.m        -> makes HTTP requests and processes response
