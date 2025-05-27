/* Import the CAPM data */

version 18
clear

tempfile dax bondgov 

local dax_path "../Data/Deutschland" 
local datafile "ManualBloombergDownload" 

/* Import the DAX sheet */
import excel "`dax_path'/`datafile'.xlsx",  /*
 */  sheet("DAX") firstrow
drop if Date==.
label variable DAX "DAX" 
save `dax' , replace
clear

/* Import the 2 year bond yield sheet */
import excel "`dax_path'/`datafile'.xlsx",  /*
 */  sheet("GDBR2") firstrow
drop if Date==.
label variable GDBR2 "2yr gov't bond yield" 
drop yearbondyieldgermangovtb
save `bondgov' , replace

/* Merge the Files */
merge 1:1 Date using `dax', gen(_merge_dax)
drop _merge_dax

/* Create a business Calendar */
/* important for lags, ts graphs, ... */
bcal create xetra, from(Date) replace
generate bDate = bofd("xetra", Date) 
label var bDate Date
label var  Date "Calendar Date" 
format bDate %tbxetra

tsset bDate

/* Compute market and risk free return */
qui gen rm = (DAX-L1.DAX)/L1.DAX
qui gen rf = GDBR2/100

/* Save the file */
save "`dax_path'/German_DAXBond.dta" , replace
