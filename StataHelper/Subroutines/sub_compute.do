
/* First, compute the volume sums over the different price ranges */

foreach bpi of num `bpvec' {
   display "`c(current_date)'/`c(current_time)': Price Range `bpi'"
   /* To compute the bands, we always go around the last trade price,
	be it buy, sell, or auction. */
   qui gen band_min`bpi' = trade_price*(1-`bpi'/10000)
   qui gen band_max`bpi' = trade_price*(1+`bpi'/10000)


   /* Do NOT loop over bid and ask, instead do both at same time, 
	saves a lot of time in the loops! */
   /* Make sure to have missings when no lob in this second */
   qui gen     clob_ask_vol_P`bpi' = 0
   qui replace clob_ask_vol_P`bpi' = . if ask1_price == .

   qui gen     clob_bid_vol_P`bpi' = 0
   qui replace clob_bid_vol_P`bpi' = . if bid1_price == .

   /* sum up volume over all order book levels within band */
   forvalues i = 1/`=scalar(maxdep)' {
       qui replace clob_ask_vol_P`bpi' = clob_ask_vol_P`bpi' + ask`i'_volume /*
        */ if (ask`i'_price >= band_min`bpi') &  (ask`i'_price <= band_max`bpi')  
       qui replace clob_bid_vol_P`bpi' = clob_bid_vol_P`bpi' + bid`i'_volume /*
        */ if (bid`i'_price >= band_min`bpi') &  (bid`i'_price <= band_max`bpi')  
   }
}


/* Fill in the seconds without lob by using the previous one */
foreach clobi of var clob* {
    qui replace `clobi' = `clobi'[_n-1] if ((`clobi' == .)&(NewStock!=1))
}

/*

  /* Compute the maximum length of order book between trades */
  preserve
  keep *_count clob_*_P`bpi' /* zeilnum */ /* CH: don't think I need this any more */ 

  collapse (max) clob_ask_vol_P`bpi'' /*
        */ , by(trade_count)

    save `temp_path'/temp_xx, replace 
  restore

  merge m:1 trade_count using `temp_path'/temp_xx
  drop _merge

  /*     and just the increases */
  qui gen delta_pos_clob_ask_vol_P`bpi'  = max(0,(-last_clob_ask_vol_P`bpi' + clob_ask_vol_P`bpi'))
  qui gen delta_pos_clob_ask_vol_P`bpi'  = max(0,(-last_clob_ask_vol_P`bpi' + clob_ask_vol_P`bpi'))
}

/* Drop intermediate variables */
drop band_* NewStock


/* What should we keep? */
keep clob* zeit* Datum SName StockName trade_price trade_volume *event
aorder
order zeit Datum zeitSec StockName SName trade*

*/

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
