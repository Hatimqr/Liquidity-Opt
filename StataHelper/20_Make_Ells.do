clear
version 18

frame reset
clear

tempfile daxzwischen daxtoday

frame create LamHat Date SName lamhat Bai Rval Tval

qui include Definitions/localdefs.do
qui include `defs_path'/defs_SkipDates.do

* Local dates to override the def-file
*local datum_start = mdy(04,02,2019)  /* Enter in Month,Day,Year form! */
 local datum_start = mdy(01,01,2024)  /* Enter in Month,Day,Year form! */
 local datum_ende  = mdy(12,31,2024)

forvalues datum_i = `datum_start'/`datum_ende' {
    local datum_str = string(`datum_i', "%tdCCYYNNDD")

    display "`c(current_date)'/`c(current_time)': Loading day `datum_str'"
    /* Nothing to do for holidays */
    if inlist(`datum_str',`SKIP_DATES') {
        disp "Feiertag"
	continue
    }

    /* Nothing to do for weekends */
    local wochentag = dow(`datum_i')
    if `wochentag'==0 | `wochentag'==6 {
        disp "Weekend"
	continue
    }

/* Load the data */
use "`daily_path'/DailySecs_`datum_str'.dta", clear
 
/* Some basic stuff */
/* no idea, why these to variables are still here: */
cap qui drop timestamp
cap qui drop trade_side

qui encode StockName, gen(SName)

qui su SName
local SMax = r(max)

/* Indicate where a new stock starts */
qui gen NewStock = (StockName != StockName[_n-1])

/* Make sure that trade_price is NOT MISSING */
/* we know that first and last row of the day are an auction so we can safely: */
qui sort StockName zeit_Sec
 qui replace trade_price = trade_price[_n-1] if (trade_price == .) & (NewStock != 1)

/* Now the computation of ells */
/* 1. sum the volumes over bpvec: */
    include `sub_path'/sub_compute_bpvec

/* 2a. Drop the bid/ask stuff, no more need */
qui drop ask* bid*

/* 2b. Complete the seconds, now that the file is smaller */

    /* a panel of stocks */
    tsset SName  zeit_Sec

    /* and finally, fill in the missing seconds */
    qui tsfill

/* 2c. Fill in the seconds without lob or tradeprice by using the previous one */
qui replace StockName = StockName[_n-1]  if StockName == "" & NewStock != 1
foreach vari of varlist trade_price clob* {
    qui replace `vari' = `vari'[_n-1] if ((`vari' == .)&(NewStock!=1))
}

/* 3. Compute the different time ranges */
qui sort SName zeit_Sec
    qui include `sub_path'/sub_compute_ttvec


/* 4. Compute the ells for R/T ranges */
foreach ti of numlist `ttvec' {
    foreach bpi of numlist `bpvec' {
        foreach bai in "ask" "bid" {
            qui gen ell_`bai'_R`bpi'_T`ti' = /*
            */     (clob_`bai'_vol_R`bpi'_T`ti' + trade_volume_T`ti')
        }
    }
    /* Under Construction */
    /* the ells for full sum */
        foreach bai in "ask" "bid" {
            qui gen ell_`bai'_q_T`ti' = /*
            */     (clob_`bai'_vol_q_T`ti' + trade_volume_T`ti')
        }
    /* */
}

/* Cleanup: Do I still need the clob* data? */
*pause on
*pause
*qui save hugo, replace

qui drop clob* NewStock

 /* Set up the DAX data, weights go into scalars and a separate frame */
    cap frame drop index_info
    include `sub_path'/sub_MakeIndexInfo
    
    /* Insert Index Weights */
    frame DAX_Today: save `daxtoday', replace
    merge m:1 StockName using `daxtoday'
    qui replace weight_DAX = 0 if weight_DAX==.

    /* Collapse by time and stock using the index weight */
    preserve
        qui gen eins = 1
        qui collapse (sum)  FFF FFq  ell* trade* *event eins [pw=weight_DAX], by(zeit_Sec)
        /* stocks start and finish trading at staggered times */
        /* here we don't compute the DAX unless all constituents are trading */
        /* alternatively we could carry the last traded value forward for the stopped stocks */

	/* at the beginning and end of day, 
		trading is phased in/out.
		Only use those observations, where
		all stocks are trading */
	qui su eins, meanonly
	qui drop if eins < r(max)

	/* if a DAX stock is missing, then eins will not equal one! */
        qui gen StockName = "DAX"
        qui gen SName     = 0
        qui rename eins weight_DAX
        save `daxzwischen', replace
    restore

    /* Append to the dataset */
    qui append using `daxzwischen'

    /* the label for the 0 value in SName */
    label define SName 0 DAX, add

/* Divide by the Free Float Factor */
 * do it when computing the lambdas, if at all *
 * also, currently don't have FF for stocks not in DAX!
 * foreach xi of varlist ell* {
 *     qui replace `xi'= `xi'/FFq
 * }

/* Finally, record which day we are in: */
tsset, clear
save "`ells_path'/DailyElls_`datum_str'.dta", replace


} /* Ends the loop over the days */
