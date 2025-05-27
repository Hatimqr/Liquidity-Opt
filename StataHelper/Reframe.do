/* Take whatever is in memory and create a separate frame for every stock */
clear
version 18
frame reset

frame create Gesamt
frame change Gesamt

qui include localdefs.do

/* Load some data */
use "`daily_path'/Gesamt.dta", replace

/* Get a list of stock tickers from the Stock Name Variable */
qui levelsof StockName, local(SName)
 local SName: list clean SName

/* copy each stock to an individual frame */
foreach x in `SName' {
        qui preserve
            qui keep if StockName=="`x'" 
	    *tab StockName
            qui frame copy Gesamt SF_`x'
            /* Save the individual Stock Data */
            frame SF_`x': qui save "`bystock_path'/`x'.dta" , replace
        qui restore
}
