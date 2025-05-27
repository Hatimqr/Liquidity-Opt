/* Make sure that trade_price is NOT MISSING */
/* we know that first and last row of the day are an auction so we can safely: */
qui replace trade_price = trade_price[_n-1] if trade_price == .

foreach bpi of num `bpvec' {
   display "`c(current_date)'/`c(current_time)': Price Range `bpi'"
   /* To compute the bands, we always go around the last trade price,
	be it buy, sell, or auction. */
   qui gen band_min`bpi' = trade_price*(1-`bpi'/10000)
   qui gen band_max`bpi' = trade_price*(1+`bpi'/10000)


   /* Loop over bid and ask */
   foreach bai in ask bid {
   /* For the first level */
   qui gen     clob_`bai'_vol_P`bpi' = .
   qui replace clob_`bai'_vol_P`bpi' = `bai'1_volume 
   qui replace clob_`bai'_vol_P`bpi' = 0 /*
        */ if (`bai'1_price < band_min`bpi') |  (`bai'1_price > band_max`bpi')  

   /* sum up volume over all order book levels within band */
   forvalues i = 2/`=scalar(maxdep)' {
       qui replace clob_`bai'_vol_P`bpi' = clob_`bai'_vol_P`bpi' + `bai'`i'_volume /*
        */ if (`bai'`i'_price >= band_min`bpi') &  (`bai'`i'_price <= band_max`bpi')  
   }
   }
}

/*

  /* Compute the maximum length of order book between trades */
  preserve
  keep *_count clob_*_P`bpi' /* zeilnum */ /* CH: don't think I need this any more */ 

  collapse (max) clob_`bai'_vol_P`bpi'' /*
        */ , by(trade_count)

    save `temp_path'/temp_xx, replace 
  restore

  merge m:1 trade_count using `temp_path'/temp_xx
  drop _merge

  /*     and just the increases */
  qui gen delta_pos_clob_`bai'_vol_P`bpi'  = max(0,(-last_clob_`bai'_vol_P`bpi' + clob_`bai'_vol_P`bpi'))
  qui gen delta_pos_clob_`bai'_vol_P`bpi'  = max(0,(-last_clob_`bai'_vol_P`bpi' + clob_`bai'_vol_P`bpi'))
}

/* Drop intermediate variables */
drop band_*


aorder
order del* last* lob* clob*

*/
