/* How we got here:                     */
/* In the Bloomberg download directory  */
/* First in R convert from ods to csv   */
/* Then in stata run 01_einlesen.do     */
version 18


* On Amigo:
*local datapath  "/home/chris/Work/Current/Liquidity/Data/Raw/Bloomberg"
*local  FigPath  "/home/chris/Work/Current/Liquidity/Data/Raw/Bloomberg/Figs"
*local save_path "/home/chris/Work/Current/Liquidity/Data/Final"

/* Read in the Paths */
include Definitions/defs_Paths.do

local datapath "`bloomberg_path'"
*local  FigPath "`bloomberg_path'/Figs"

local ersatzliste "TradingSymbol IndexWeight Stockname"

/* Clear up */
graph drop _all
frame reset
clear

/* Show how the index componenets evolve over the relevant time period */

use `save_path'/IndexComposition
qui rename FFq FFq_Eurostoxx
qui rename FreeFloat FreeFloat_Eurostoxx

/* Adjust the units */
qui replace FreeFloat_Eurostoxx = 100*FreeFloat_Eurostoxx
qui replace FFq_Eurostoxx      = FFq_Eurostoxx / 1000000

/* Make datasets compatible */
encode TradingSymbol, gen(SName)
qui gen datum = zeitd
cap drop zeitd
merge 1:1  datum SName using `datapath'/Bloomberg_FFData.dta

/* Fill in for blanks */
foreach vari of varlist outstanding_* FreeFloatp_* {
   qui replace `vari' = `vari'[_n-1] if (`vari' == .)&(SName[_n]==SName[_n-1])
   }

/* Remove one-day blips in the free float series */
sort SName datum
gen x  = FreeFloatp_B
gen xd = x-x[_n-1] 
gen xd_nonu = abs(xd) > 0
gen xd_nomi = (xd != .)
gen xd_undo = xd == (-1)*xd[_n-1]
gen xd_fix  = (xd_nonu & xd_nomi & xd_undo)
gen fix_here = xd_fix[_n+1]
qui gen FreeFloatp_Ba = x
qui replace FreeFloatp_Ba = x - xd if (fix_here)

*tsset SName datum, d
*browse SName datum x xd xd_fix FreeFloatp_B FreeFloatp_Ba

/* Clean up */
qui drop x xd xd_* fix_here

/* Now fill in the blanks/missings created from missing DAX days */
foreach vari of varlist `ersatzliste' {
    qui replace  `vari' = `vari'[_n-1] if (missing(`vari') & _merge==2)
}

local datum_start = mdy(02,01,2023)
local datum_stop  = mdy(02,10,2023)

order _merge datum 
*ENDE

qui gen FFq_Bd     = outstanding_dsB * (FreeFloatp_B / 100)
qui gen FFq_Bda    = outstanding_dsB * (FreeFloatp_Ba/ 100)

/* In the remaining code we will work with the FFq and FreeFloat series: */
qui gen FFq              = FFq_Bda
qui gen double FreeFloat = FreeFloatp_Ba / 100

tsset SName datum, d
qui gen zeitd = datum
save `save_path'/Bloomberg_Stoxx.dta, replace

/* Check the merge */
preserve

local datum_start = mdy(04,01,2019)
local datum_stop  = mdy(12,31,2024)

qui keep if datum >= `datum_start'
qui keep if datum <= `datum_stop'


local bild_name "outstanding"
xtline outstanding_?sB, byopts(yrescale)     byopts(legend(off))      xlabel(,angle(60)) /*
        */ byopts(title("Number of shares outstanding") note("Bloomberg Data") ) /*
	*/ xtitle("") ytitle("") /*
	*/ name(`bild_name')
           graph export `FigPath'/`bild_name'.eps, replace
           !epstopdf "`FigPath'/`bild_name'.eps"

local bild_name "last_price"
xtline Pit lastprice_B, byopts(yrescale)     byopts(legend(off))      xlabel(,angle(60)) /*
        */ byopts(title("Daily Closing Price") note("Eurostoxx and Bloomberg Data") ) /*
	*/ xtitle("") ytitle("") /*
	*/ name(`bild_name')
           graph export `FigPath'/`bild_name'.eps, replace
           !epstopdf "`FigPath'/`bild_name'.eps"

local bild_name "FreeFloatp"
xtline FreeFloat_Eurostoxx FreeFloatp_Ba, byopts(yrescale)     byopts(legend(off))      xlabel(,angle(60)) /* 
        */ byopts(title("Free Float Percent") note("Eurostoxx and Bloomberg Data") ) /*
	*/ xtitle("") ytitle("") /*
	*/ name(`bild_name')
           graph export `FigPath'/`bild_name'.eps, replace
           !epstopdf "`FigPath'/`bild_name'.eps"

local bild_name "ffq"
xtline FFq_Eurostoxx FFq_Bda, byopts(yrescale)     byopts(legend(off))      xlabel(,angle(60)) /*
        */ byopts(title("Free Float") note("Data: EuroStoxx and Bloomberg") ) /*
	*/ ytitle("Millions of shares") xtitle("") /*
	*/ name(`bild_name')
           graph export `FigPath'/`bild_name'.eps, replace
           !epstopdf "`FigPath'/`bild_name'.eps"

/* Based on the graph we choose to work with FFq_Bd
   which reasonably matches FFq_Eurostoxx but is available for entire time that
   a stock is actually traded. */

/* I removed changes in floatpercent that were undone the following day, 
	however, if changes were undone only after two days, e.g. AIR, then I left them in */

restore
