/* play with CAPM stuff, ... */

frame reset
tempfile savefile
version 18
clear all

 qui include Definitions/localdefs.do  /* The local definitions */
  qui include Definitions/defs_Paths.do  /* The local definitions */

    /* Load the lambda data */
    qui use "`save_path'/Daily_20190402_20191231.dta", clear
     qui append using "`save_path'/Daily_20200101_20201231.dta"
     qui append using "`save_path'/Daily_20210101_20211231.dta"
     qui append using "`save_path'/Daily_20220101_20221231.dta"
     qui append using "`save_path'/Daily_20230101_20231231.dta"
     qui append using "`save_path'/Daily_20240101_20241231.dta"

    /* Get rid of WDI for now */
    *drop if SName==48

    /* Bring in the German Market Data */
    merge m:1 Date using ../Data/Deutschland/German_DAXBond.dta


    /* Use the Business Dates*/
    tsset SName bDate

/*
    tsline rm rf, title(DAX returns and 2-year govt bond yield)
    graph export "`results_path'/Fig_rmr.eps" , replace
    !epstopdf    "`results_path'/Fig_rmr.eps"
*/

    qui gen ri = (trade_price - L1.trade_price)/L1.trade_price

    qui gen xri = ri-rf
    qui gen xrm = rm-rf
    /* Show the Excess Returns */
/*
    xtline xri, byopts(yrescale) xlabel(,angle(60)) byopts(title(Excess Returns))
    graph export "`results_path'/ExcessReturns.eps" , replace
    !epstopdf    "`results_path'/ExcessReturns.eps"
*/

    /* For now, only for BMW */
    *keep if SName == 8

    /* Only keep the date range from the lambda dataset */
    keep if _merge==3
    drop _merge

    /* do the CAPM regressions */
    frame copy default CAPM
    frame CAPM {
        save `savefile', replace
        statsby _b _se, by(SName): regress xri xrm
        qui rename _b_xrm beta
    }
    frame copy default CAPMr
    frame CAPMr {
        qui gen capm_res = .
        forvalues si = 0/47  {
            qui reg xri xrm if SName == `si'
            qui predict yhat
            qui replace capm_res = xri-yhat if SName==`si'
            qui drop yhat
        }
    }
    frame copy default Liq
    frame Liq {
        foreach bai in ask bid {
         /* Reto's idea */
          qui gen `bai'_rs = (rm-rf)/  lambda_ell_`bai'_R5_T10
          qui gen `bai'_rsh= (rm-rf)/    d_lamhat_`bai'_R5_T10
          qui gen `bai'_rl = (rm-rf)/lambda_ell_`bai'_R200_T3600
          qui gen `bai'_rlh= (rm-rf)/  d_lamhat_`bai'_R200_T3600

         /* Just the factors */
         qui gen `bai'_ls =   lambda_ell_`bai'_R5_T10
         qui gen `bai'_lsh=     d_lamhat_`bai'_R5_T10
         qui gen `bai'_ll = lambda_ell_`bai'_R200_T3600
         qui gen `bai'_llh=   d_lamhat_`bai'_R200_T3600
        }

        save `savefile', replace
        statsby _b _se, by(SName): stepwise, pr(0.1): regress xri xrm /*
	*/    ask_ls ask_ll ask_lsh ask_llh    /*
	*/    bid_ls bid_ll bid_lsh bid_llh    /*
	*/    ask_rs ask_rl ask_rsh ask_rlh    /*
	*/    bid_rs bid_rl bid_rsh bid_rlh 

        foreach xi in ls ll lsh llh rs rl rsh rlh {
         foreach bai in ask bid {
           cap gen     t_`bai'_`xi' = .
           cap replace t_`bai'_`xi' = _b_`bai'_`xi'/_se_`bai'_`xi'
         }
        }
        su t_* , sep(4)

/* Write summary to a latex table */
cap collect drop by
local vlist t_*

preserve
  foreach ti of varlist t_* {
     qui replace `ti' = abs(`ti')
  }

 /* table (var StockName) (result), /// */
* compute summary statistics
 table () (result), ///
    stat(count `vlist') ///
    stat(mean `vlist') ///
    stat(sd `vlist') ///
    stat(min `vlist') ///
    stat(p10    `vlist') ///
    stat(median    `vlist') ///
    stat(p90    `vlist') ///
    stat(max `vlist') ///
    name(by)

* other style changes
 collect label levels result count "N" sd "Std. Dev." min "Min" max "Max" p10 "P10" p90 "P90", modify
 collect style cell result[mean median sd min p10 p50 p90 max], nformat(%18.2fc)
 *collect title "Summary statistics for |t-values| of CAPM style regression"  
 collect notes 1 : "For the first letter, \(l\) denotes that the regressor entered directly into the regression, \(r\) denotes that the regressor entered in the denominator with the excess return in the numerator. "
 collect notes 2 : " For the second letter, \(s\) denotes short time period of 10 seconds.  \(l\) denotes long  time period of 3600 seconds."
 collect notes 3 : " The \(h\) as the third letter indicates \(\hat{\lambda}\), i.e. the \(\varphi\) coefficient, absence of \(h\) indicates \(\lambda\), i.e. the \(\phi\) coefficient."

 collect style tex, nobegintable
 collect preview
 qui include Definitions/defs_Paths.do  /* The local definitions */
 disp("Saving into: `FigPath'")
 collect export `FigPath'/CAPM_tvals.tex, tableonly replace 
*pause on
*pause

restore

	graph bar (mean) t_*,  /*
	  */ by(, title("t-Values") /*subtitle("")*/ /*
	  */ caption("t-values for stepwise CAPM style regression") note(" ")) /*
	  */ legend(size(tiny))  by(SName)
        graph export `FigPath'/CAPM_tvals.eps, replace
        graph export `FigPath'/CAPM_tvals.pdf, replace
        *!epstopdf   "`FigPath'/CAPM_tvals.eps"

       
    }
    frame change Liq
