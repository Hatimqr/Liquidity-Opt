clear
version 18

frame reset
clear

frame create Hourly
frame create Daily

tempvar lxi lyi lxr lyr

tempfile daxagg

qui include Definitions/localdefs.do
qui include `defs_path'/defs_SkipDates.do

*local datum_start = mdy(04,02,2019)  /* Enter in Month,Day,Year form! */
local datum_start = mdy(01,01,2024)  /* Enter in Month,Day,Year form! */
local datum_ende  = mdy(12,31,2024)  /*  on Trillian */

local datum_s_anf = string(`datum_start', "%tdCCYYNNDD")
local datum_s_end = string(`datum_ende', "%tdCCYYNNDD")

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
use "`ells_path'/DailyElls_`datum_str'.dta", replace

qui su SName
local Max_SName = r(max)

    /* Now, save the Index ells as separate file and merge them back in m:1 */
    preserve
        qui keep if StockName=="DAX"
        qui keep zeit_Sec FFq trade_price ell* 
        qui rename FFq DAX_FFq
        qui rename trade_price DAX_price
        foreach xi of varlist ell* {
            qui rename  `xi'  DAX_`xi'
        }
        save `daxagg', replace
    restore
   
    /* Now we have the DAX as a separate column! */
    cap drop _merge
    merge m:1 zeit_Sec using `daxagg'

   qui tsset SName zeit_Sec

/* More Cleanup */
*qui drop _merge

    /* Compute the FFq Ratio: */
    qui gen FFR = DAX_FFq / FFq

    /* Compute the lambda as ratio */
    foreach xi of varlist ell* {
        qui gen lambda_`xi' = (`xi'/DAX_`xi') * FFR
    }

    qui gen Stunde = floor(zeit_Sec/3600)
    qui su  Stunde
    local Min_Stunde = r(min)
    local Max_Stunde = r(max)

    /* Compute the lambda as regression */
    /* For the Lambdas */
    cap drop `lxi' 
    cap drop `lyi' 
    qui gen  `lxi' = .
    qui gen  `lyi' = .
  
    /* For the Returns */
    cap drop `lxr' 
    cap drop `lyr' 
    qui gen  `lyr' = log(trade_price) - log(L1.trade_price)
    qui gen  `lxr' = log(  DAX_price) - log(  L1.DAX_price)

    cap drop d_alpha
    cap drop d_beta
    qui gen  d_alpha = .
    qui gen  d_beta  = .

    forvalues si=0/`Max_SName' {
        qui su `lyr' if SName == `si' , meanonly
        if r(N) > 1 {
            qui regress `lyr' `lxr' if SName == `si'
            qui replace d_beta  = r(table)[1,1] if SName == `si'
            qui replace d_alpha = r(table)[1,2] if SName == `si'
        }
    }

    /* 4. Compute the ells for R/T ranges */
    /* Why is this taking soo long? , i.e 4 minutes for 50 regressions! OK, 6 seconds for each regression plus all the data manipulations */
    foreach ti  of numlist `ttvec' {
    foreach bpi of numlist `bpvec' {
    foreach bai in     "ask" "bid" {
    display "`c(current_date)'/`c(current_time)': `datum_str': `bai'R`bpi'T`ti'"
            local xi "`bai'_R`bpi'_T`ti'"
            qui replace `lxi'  = log(DAX_ell_`xi')
            qui replace `lyi'  = log(ell_`xi')

            qui gen     d_lamhat_`xi' = .
            qui gen     d_lamhse_`xi' = .
            qui gen     d_lamcon_`xi' = .

            qui gen     h_lamhat_`xi' = .
            qui gen     h_lamhse_`xi' = .
            qui gen     h_lamcon_`xi' = .

            forvalues si=0/`Max_SName' {
	     /* Regression is in logs, no need for rescaling with Free Float 
		given that it is constant within a day */

             /* Note, ALL REGRESSIONS have the SAME X VARIABLE 
		it would be much more efficient to compute inv(x'x)x and multiply it with the different y
		I just don't know how to do it  in Stata */

            /* First at daily frequency, then if desired, hourly as well */
                qui su `lyi' if SName == `si' , meanonly
                if r(N) > 1 {
                    qui regress `lyi' `lxi' if SName == `si'
                    qui replace d_lamhat_`xi' = r(table)[1,1] if SName == `si'
                    qui replace d_lamhse_`xi' = r(table)[2,1] if SName == `si'
                    qui replace d_lamcon_`xi' = r(table)[1,2] if SName == `si'
                }
                else {
                    /* No need to move to hourly if we don't have enough for daily */
                    continue
                }

            if `Do_Hourly_Lambda' == 1 {
              forvalues hi=`Min_Stunde'/`Max_Stunde' {
                qui su `lyi' if Stunde==`hi' & SName == `si' , meanonly
                if r(N) > 1 {
                    qui regress `lyi' `lxi' if Stunde==`hi' & SName == `si'
                    qui replace h_lamhat_`xi' = r(table)[1,1] if Stunde==`hi' & SName == `si'
                    qui replace h_lamhse_`xi' = r(table)[2,1] if Stunde==`hi' & SName == `si'
                    qui replace h_lamcon_`xi' = r(table)[1,2] if Stunde==`hi' & SName == `si'
                }
              }
            }
            }
    }
    }
    }

    if `Do_Hourly_Lambda' == 1 {

     /* Collapse to hourly frequency */
        collapse (lastnm) trade_price d_* h_* FFq (sum) trade_volume /*
            */ (mean) ell* lamb* /*
	    */ , by(SName Stunde) fast
    
        qui gen Date = `datum_i'

        frame Hourly: frameappend default
        frame Hourly: save `save_path'/Hourly_`datum_s_anf'_`datum_s_end', replace
    }

 /* Collapse to daily frequency */
    collapse (lastnm) trade_price d_*  FFq (sum) trade_volume /*
        */ (mean) ell* lamb* h_* /*
	*/ , by(SName) fast
    
    qui gen Date = `datum_i'

    frame Daily: frameappend default
    frame Daily: tsset SName Date, d
    frame Daily: save `save_path'/Daily_`datum_s_anf'_`datum_s_end', replace


    /* This could also work, but seems more complex as approach */
    /* 
    foreach xi of varlist ell* {
        qui replace lxi     = log(DAX_`xi')
        qui replace lyi     = log(`xi')
	/* Regression is in logs, no need for rescaling with Free Float 
		given that it is constant within a day */
        preserve
            qui statsby _b,  by(SName) : regress lyi lxi
            qui rename _b lamhat'
            qui gen Date = `datum_i'

            frame post LamHat Date SName lamhat Bai Rval Tval
        restore
    }
    */



} /* Ends the loop over the days */
