/* Wherever needed, use <include filename> in the statacode, 
	i.e. here include localdefs.do  */

/* Define the various paths */
include Definitions/defs_Paths

/* Which day/s? */
include `defs_path'/defs_Dates

/* Which stocks */
include `defs_path'/defs_Stocks

/* Some more stuff */
include `defs_path'/defs_Params

/* The old stuff */
*include `defs_path'/defs_Old
