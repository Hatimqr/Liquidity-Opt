/* 3. Compute the different time ranges */

/* Expect about one minute per numlist component */
*local ttvec 5 10 

/* Max of Order Book Volumes */
foreach vari of varlist clob* {
  foreach ti of numlist `ttvec' {
    display "`c(current_date)'/`c(current_time)': Currently T`ti':`vari'"
    rangestat (max) `vari'_T`ti'=`vari', interval(zeit_Sec -`ti' 0) by(SName)
  }
}
/* Sum of Trading Volumes */
foreach vari of varlist trade_volume {
  foreach ti of numlist `ttvec' {
    display "`c(current_date)'/`c(current_time)': Currently T`ti':`vari'"
    rangestat (sum) `vari'_T`ti'=`vari', interval(zeit_Sec -`ti' 0) by(SName)
  }
}
