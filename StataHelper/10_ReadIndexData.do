version 18
clear

/* Get the local variables */
include Definitions/defs_Paths
include Definitions/defs_Stocks
*include localdefs.do

local year_min = 2019
local year_max = 2024

/* Create an empty dataset to start with */
set obs 1
 qui gen zeitd = .
 qui save "`save_path'/IndexComposition", replace
clear


foreach yeari of num `year_min'/`year_max' {
  foreach monthi of num 1/12 {
    local yyyymm = 100*`yeari' + `monthi'

    qui cd `idx_path'/Extracts
    /* From 2019 to 2023 February */
    cap unzipfile "../Downloads/composition_`yyyymm'", ifilter(`"((DAX_ICR.*)$)"')
    /* Since December 2023 */
    cap unzipfile "../Downloads/composition_`yyyymm'", ifilter(`"((icr_daxk.*)$)"')
    *cap unzipfile "../Downloads/composition_`yyyymm'", ifilter(`"(.*(icr_dax.*)$)"')
    *cap unzipfile "../Downloads/composition_`yyyymm'", ifilter(`"(.*(ICR_DAXK.*)$)"')
    *cap unzipfile "../Downloads/composition_`yyyymm'", ifilter(`"(.*(ICR_DAX.*)$)"')
    qui cd `start_path'

    foreach dayi of num 1/31 {
      local yyyymmdd = 100*`yyyymm'+`dayi'
      *disp("`yyyymmdd'")
      cap {
	   if `yyyymm'<202312 {
	   qui import excel "`idx_path'/Extracts/DAX_ICR.`yyyymmdd'.xls", /*
	       */ sheet("Data") cellrange(A6:AW240) firstrow clear
	   } 
	   else {
 	   qui import excel "`idx_path'/Extracts/icr_daxk_`yyyymmdd'.xls", /*
	       */ sheet("Data") cellrange(A6:AW240) firstrow clear
           }

           qui keep if IndexTradingSymbol=="DAX"
           qui keep IndexTradingSymbol TradingSymbol ISIN ffitlastregularrebalancing AF Weightlastregularrebalancing pit qit
      
           qui rename ffitlastregularrebalancing    FreeFloat
           cap qui rename AF                        MarketCap
           cap qui rename MarketCapinMiolastregu    MarketCap
           qui rename Weightlastregularrebalancing  IndexWeight
	   qui rename qitlastregularrebalancing     Qit
	   qui rename pit                           Pit

 
	   /* sometimes there is an "n/a" in the numerical column 
		and therefore it is read as string.
		real() converts n/a to missing and the variable to numeric */
	
           foreach vari of var  FreeFloat MarketCap IndexWeight Qit Pit {
	 	cap qui destring `vari', replace force
	   }


           qui drop if missing(MarketCap)

           sort TradingSymbol
	  }
      qui gen year = `yeari'
      qui gen month = `monthi'
      qui gen day   = `dayi'
      qui gen zeitd = mdy(`monthi',`dayi',`yeari')

      qui append using "`save_path'/IndexComposition"
      qui save         "`save_path'/IndexComposition", replace
      clear
    }
  }
}


 qui use "`save_path'/IndexComposition"


/* Adjust for renaming of Trading Symboles */
qui gen flag_DPW = (TradingSymbol=="DPW")
qui gen flag_DAI = (TradingSymbol=="DAI")
qui replace TradingSymbol="DHL" if TradingSymbol =="DPW"
qui replace TradingSymbol="MBG" if TradingSymbol =="DAI"

/* Generate a variable "SampleFrac" that indicates which fraction of the sample the stock is in the DAX */
qui levelsof TradingSymbol, local(DAX_All) clean
qui gen obs = 0
foreach stocki in `DAX_All' {
  qui su IndexWeight if TradingSymbol=="`stocki'"
  qui replace obs = r(N) if TradingSymbol=="`stocki'"
}

qui su obs
qui gen SampleFrac = obs/r(max)

/* Create a list with all components of the DAX and the stock liste,
	we will need this for reading in the data. */
local Gesamt_liste : list stock_liste | DAX_All

/* Finally, encode as panel data set */
 encode TradingSymbol, generate(sym)
 encode ISIN, generate(num_isin)
 qui tsset sym  zeitd, daily


/* Computing the Free Float in Shares */
qui gen FFq = Qit * FreeFloat
qui gen FFp = (MarketCap/Pit) * 1000000

qui gen FFdir = (FFq - FFp) / Qit
qui gen FFout = (FFdir > 0.1)

su FF*
compress
qui save "`save_path'/IndexComposition", replace

/* Finally, a few images */
xtline FFdir if TradingSymbol!="WDI", /*
	*/ recast(line) tlabel(#5, angle(ninety)) tmtick(none) /*
	*/ byopts(title(`"Differences between FF{sup:q} and FF{sup:p} relative to Q"')) /*
	*/ byopts(legend(off))
graph export `FigPath'/FFdir.eps, replace
graph export `FigPath'/FFdir.pdf, replace

xtline FFp FFq , /*
	*/ tlabel(#5, angle(ninety)) tmtick(none) /*
	*/ byopts(title(`"FF{sup:q} and FF{sup:p}"')) /*
	*/ byopts(legend(off)) /*
	*/ byopts(yrescale noiylabel) 
graph export `FigPath'/FFqp.eps, replace
graph export `FigPath'/FFqp.pdf, replace

/* Compute the sum of index weights  for the full sample, 
	then plot all weights and their sum */
qui keep if SampleFrac == 1
preserve

collapse (sum) IndexWeight , by(zeitd)
qui gen TradingSymbol = "Wsum"
qui encode TradingSymbol, gen(sym)
qui gen SampleFrac = 1
save hugo, replace

restore
merge 1:1 TradingSymbol zeitd using  hugo

qui drop sym
qui encode TradingSymbol, gen(sym)

xtline IndexWeight , /*
	*/ tlabel(#5, angle(ninety)) tmtick(none) /*
	*/ byopts(title(`"Weight in DAX"')) /*
	*/ byopts(legend(off)) /*
	*/ byopts(yrescale) 
graph export `FigPath'/IWfs.eps, replace
graph export `FigPath'/IWfs.pdf, replace
