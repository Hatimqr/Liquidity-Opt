/* Wherever needed, use <include filename> in the statacode, 
	i.e. here include localdefs.do  */

/* Regarding the depth of the order book and cutoffs */
scalar maxdep = 150

/* Price Range in basis points */
*local bpvec 5 10 25 50 100
local bpvec 5 10 50 100 200 500 1000
*local bpvec      25

/* Time Interval in seconds */
*local ttvec 5 10 25 60 600 3600
 local ttvec 10 60 300 600 3600 14400 25000
*local ttvec 10 60 300 600 3600 14400 
*local ttvec      25

/* For PrepareIndexFreq */
scalar show_int = 5000 /* Show where we are every 5000 iterations */

/* Compute Hourly Lambdas */
*local Do_Hourly_Lambda 1 /* takes about 4  hours per DAY! on Arthur     */
*local Do_Hourly_Lambda 1 /* takes about 4  hours per DAY! */
 local Do_Hourly_Lambda 0 /* takes about 9 minutes per DAY!  on Trillian */

/* When assembling the index portfolio */
*scalar preci = 0.001 /* This is the precision of the bid/ask volume */
*scalar maxiter = 10*scalar(maxdep) /* This is the max depth of the virtual index order book */
*scalar preci = 1 
