clear
version 18

qui include localdefs.do

forvalues datum_i = `datum_start'/`datum_ende' {
    local datum_str = string(`datum_i', "%tdCCYYNNDD")

display "`c(current_date)'/`c(current_time)': Loading day `datum_str'"

    if `datum_i' == `datum_start' {
        use "`daily_path'/DailySecs_`datum_str'.dta", clear
        qui gen int Datum=`datum_i'
    }
    else {
        append using "`daily_path'/DailySecs_`datum_str'.dta"
        qui replace Datum=`datum_i' if Datum==.
    }
}

/* Some basic stuff */
qui encode StockName, gen(SName)

/* A time variable that contains date and time */
qui gen zeit   = .
recast double zeit 
qui replace zeit   = Cofd(Datum)+1000*zeit_Sec

*duplicates list SName Datum zeit_Sec

*duplicates list SName zeit
tsset SName  zeit, clocktime delta(1 sec)

*save "`daily_path'/Gesamt.dta", replace

