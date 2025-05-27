*frame reset
*include localdefs.do
*use hugo, clear

tempname Sec_Min Sec_Max Sec_Obs

qui su zeit_Sec
scalar `Sec_Min' = r(min)
scalar `Sec_Max' = r(max)
scalar `Sec_Obs' = 1+r(max)-r(min)

cap frame drop FullSec
frame create FullSec float zeit_Sec str4 StockName
frame FullSec: set obs 1 

/* Get a list of stock tickers from the Stock Name Variable */
qui levelsof StockName, local(SName)
 local SName: list clean SName

foreach x in `SName' {

frame FullSec{ 
    qui insobs `=scalar(`Sec_Obs')', before(1) 
    qui replace zeit_Sec  =  _n+scalar(`Sec_Min')-1 if zeit_Sec==.
    qui replace StockName     =  "`x'" if StockName==""
    qui drop if  StockName    == ""
    qui drop if  zeit_Sec == .
    qui sort StockName zeit_Sec
}
 
}

/* Finally save this: */
frame FullSec: qui save `temp_path'/FullSec, replace
cap frame drop FullSec
