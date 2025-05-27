clear
version 18

frame reset
clear
scalar drop _all

qui include localdefs.do

forvalues datum_i = `datum_start'/`datum_ende' {
    local datum_str = string(`datum_i', "%tdCCYYNNDD")

display "`c(current_date)'/`c(current_time)': Loading day `datum_str'"

    *if `datum_i' == `datum_start' {
        use "`daily_path'/DailySecs_`datum_str'.dta", clear
    *}

    /* A time variable that contains date and time */
    qui gen zeit   = .
    recast double zeit 
    qui replace zeit   = Cofd(`datum_i')+1000*zeit_Sec

    /* a panel of stocks */
    tsset SName  zeit, clocktime delta(1 sec)

    qui gen Datum = `datum_i'
}
