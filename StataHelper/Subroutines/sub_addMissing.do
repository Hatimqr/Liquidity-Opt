/* Introduce a missing observation at 7am every day */

preserve

/* extract daily info from datetime */
qui gen zeitd = dofc(datetime)

keep zeitd
duplicates drop

/* Create the empty observations */
/* CH: not exactly one day! Can be improved */
gen datetime = (zeitd * 24 + 7) * 60 * 60 * 1000 

*format datetime %tcNN/DD/CCYY_HH:MM:SS
*format datetime %tcNN/DD_HH

drop zeitd
save `temp_path'/ins_miss, replace

restore

/* merge into original data */
append using `temp_path'/ins_miss
