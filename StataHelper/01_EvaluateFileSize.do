version 18
clear
graph drop _all

/* Which Paths and Dates */
include Definitions/defs_Paths
*include `defs_path'/defs_SkipDates


use FileSizeGZ, clear
qui gen Year = year(Datum)
qui keep if Year == 2019

/* Tsset the data */
encode StockName, gen(Snum)
tsset Snum Datum, d

/* Get a list of stock tickers from the Stock Name Variable */
qui levelsof StockName, local(SName)
 local SName: list clean SName

/* Flag Weekends and Holidays */
include `sub_path'/sub_ClearHolidays

qui gen File_No = (FileSize==-1)
qui gen File_Small = (FileSize > 0) & (FileSize < 10^(-5))

*xtline FileSize, byopts(yrescale)
*	graph rename FileSize


qui keep if File_No | File_Small

/* Display for missing stocks, which dates are missing */
foreach x in `SName' {
        *display("`SName'")
        qui preserve
        qui keep if StockName=="`x'"
	qui keep if File_No==1 | File_Small
	     outfile Datum using "MissingDays/`x'.csv", replace noquote wide
        qui restore
        }
