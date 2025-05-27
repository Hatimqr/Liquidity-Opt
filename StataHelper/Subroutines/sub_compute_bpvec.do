
/* Compute the volume sums over the different price ranges */

foreach bpi of num `bpvec' {
   display "`c(current_date)'/`c(current_time)': Price Range `bpi'"
   /* To compute the bands, we always go around the last trade price,
	be it buy, sell, or auction. */
   qui gen band_min`bpi' = trade_price*(1-`bpi'/10000)
   qui gen band_max`bpi' = trade_price*(1+`bpi'/10000)


   /* Do NOT loop over bid and ask, instead do both at same time, 
	saves a lot of time in the loops! */
   /* Make sure to have missings when no lob in this second */
   qui gen     clob_ask_vol_R`bpi' = 0
   qui replace clob_ask_vol_R`bpi' = . if ask1_price == .

   qui gen     clob_bid_vol_R`bpi' = 0
   qui replace clob_bid_vol_R`bpi' = . if bid1_price == .

   /* sum up volume over all order book levels within band */
   forvalues i = 1/`=scalar(maxdep)' {
       qui replace clob_ask_vol_R`bpi' = clob_ask_vol_R`bpi' + ask`i'_volume /*
        */ if (ask`i'_price >= band_min`bpi') &  (ask`i'_price <= band_max`bpi')  
       qui replace clob_bid_vol_R`bpi' = clob_bid_vol_R`bpi' + bid`i'_volume /*
        */ if (bid`i'_price >= band_min`bpi') &  (bid`i'_price <= band_max`bpi')  
   }
}

/* Fill in the seconds without lob by using the previous one */
*foreach clobi of var clob* {
*    qui replace `clobi' = `clobi'[_n-1] if ((`clobi' == .)&(NewStock!=1))
*}

/* UNDER Construction */
/* */
   /* sum up volume over all order book levels for the weighted clob */
   qui gen     clob_ask_vol_w = 0
   qui replace clob_ask_vol_w = . if ask1_price == .
   qui gen     clob_ask_vol_q = clob_ask_vol_w

   qui gen     clob_bid_vol_w = 0
   qui replace clob_bid_vol_w = . if bid1_price == .
   qui gen     clob_bid_vol_q = clob_bid_vol_w

   forvalues i = 1/`=scalar(maxdep)' {
       qui replace clob_ask_vol_w = (1+( (ask`i'_price-trade_price)/trade_price )^2) /*
	*/ if(ask`i'_price != .)
       qui replace clob_ask_vol_q = clob_ask_vol_q + (ask`i'_volume/clob_ask_vol_w)  /*
	*/ if(ask`i'_volume != .)
       qui replace clob_bid_vol_w = (1+( (bid`i'_price-trade_price)/trade_price )^2) /*
	*/ if(bid`i'_price != .)
       qui replace clob_bid_vol_q = clob_bid_vol_q + (bid`i'_volume/clob_bid_vol_w)  /*
	*/ if(bid`i'_volume != .)
   }
/* */ 

/* Drop intermediate variables */
drop band_*  clob_*_vol_w

/* Time comparison for bai loop vs bid/ask: */
/* Bai: */
/*
28	Dec	2024/11:23:15:	Price	Range	1
28	Dec	2024/11:23:26:	Price	Range	5
28	Dec	2024/11:23:39:	Price	Range	10
28	Dec	2024/11:23:53:	Price	Range	25
28	Dec	2024/11:24:07:	Price	Range	50
*/
/* Bid/Ask: */
/*
28	Dec	2024/11:27:31:	Price	Range	1
28	Dec	2024/11:27:38:	Price	Range	5
28	Dec	2024/11:27:46:	Price	Range	10
28	Dec	2024/11:27:54:	Price	Range	25
28	Dec	2024/11:28:04:	Price	Range	50
*/
