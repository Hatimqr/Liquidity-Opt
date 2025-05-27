/* Converts the string: timestamp into a numerical time
	and if it exists, adds in the running indicator datum_i for the date */

/* I found some puzzling numerical inaccuracies when working with the stata-provided milliseconds.
	Therefore I create three time variables:
		zeit_Sec  contains the time of day in seconds, as extracted from timestamp 
		zeit_Nano contains the fractional seconds (9-digits) as extracted from timestamp
	
		zeit_MilliSec is a decimal in Millisecond frequency, by combining zeit_Sec and Zeit_Nano
			to use it in tsset, either multiply by 10^6 to get it to Nanoseconds
					    or int() it to the desired precision.

*/ 
/* ------------------------------------------------------------------------------------------------- */

/* Old: 

 	/* The variable MyTime is in Stata miliseconds format,
			MyNano is an integer containing the 9 decimals of the timestamp,
				i.e. it is in Nanoseconds
		          Time is in seconds, with all 9 decimals of MyNano */
	/* Therefore Time keeps the precision of timestamp, 
		whereas MyTime rounds to miliseconds. */
*/

/* ------------------------------------------------------------------------------------------------- */


        /* The NEW version */
	/* Check if datum_i is actually defined */
        local lendat : strlen local datum_i

        /* Is datum_i defined? */
        *if (`lendat'==0) { 
        *    gen        zeit_Date= 0
        *}
	* else {
        *    gen        zeit_Date= `datum_i'
	*}
	*recast long zeit_Date

	/* Extract the time info from timestamp */
        *gen double MyTime= clock(timestamp,"hms#") + cofd(`datum_i')
        gen        zeit_Sec      = int(clock(timestamp,"hms#")/1000 ) 
	recast long zeit_Sec

	/* Stata is working with MilliSeconcs, but our data is in NanoSeconds
	to make sure we don't lose the extra information, 
	store everything higher freq than seconds separately in zeit_Nano */
        qui gen zeit_Nano = ustrright(timestamp,9)
        qui destring zeit_Nano, replace
	recast long zeit_Nano

	/* Create a Time variable WITHIN the day 
	that is accurate up to Nanoseconds */
        /* We cannot at full precision in a double variable 
	bring the date info into this */
         qui gen double zeit_MilliSec = zeit_Sec*10^3 + zeit_Nano*10^(-6) /* To have it in milliseconds */
	 	format %25.6f zeit_MilliSec

/*
        /* The old version */
	qui split timestamp, generate(ts) parse(: .) limit(4)

	foreach vari of varlist ts* {
    	*disp("`vari'")
    	qui destring `vari', replace
	}

	/* Makes sure we don't lose precision */
	/* so declare Time as double precision */
 	qui gen double Time    = 3600*ts1 + 60*ts2 + ts3 + ts4*10^(-9)
*/
