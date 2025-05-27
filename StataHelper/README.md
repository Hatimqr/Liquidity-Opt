/* The initial versions of the program were written directly in the Data directory 
	Starting June 3 I use the Code directory */

/* November 2024 I rewrite the code based on the version in code.old.
	This is the folder with the new code */

/* Aggregating data to per-second level yields:
	-) about 2.5GB per day stata file size
	-) about 5-10 seconds loading time
*/


/* Question: What would useful price and time intervals R,T be for the computation of ell? */
/*           I would go for 5 sec, 10 sec, 1 min, 5 min, 1h. */
/*           I would go for 5,  10, 20, 50, 100 bp. */
/*           which would give a total of 25! different ells */
/*           we can go much finer, think of it as a panel!  */


/* ************** */ /* Looks like typically 50GB with max 100GB for full day with all 49 stocks  */
/* Check Download */ /* so we should be able to run all years in parallel on the same machine :-) */
/* ************** */ /* roughly ONE WEEK per year of data */

Feb 11, 13:20
in screen Checking started 6 instances of Stata, each running 00_CheckDownload for one calendar year
 b/c of stale .csv files 2020--2023 got delayed until Feb 12, 10:45 am.

         start         finish        Duration
--------------------------------------------------
2019  02/11 13:00 -- 02/15 05:00
2020  02/12 11:00 -- 02/21 07:00
2021  02/12 11:00 -- 02/20 03:00
2022  02/12 11:00 -- 02/24 01:00
2023  02/12 11:00 -- 02/20 11:00
2024  04/10 20:00 -- 04/14 10:30 
--------------------------------------------------
--------------------------------------------------



 /* ************** */ (10 minutes per day approx, i.e. 2 days per year of data)
 /* Compute Ells   */ (25 minutes per day for the expanded range)
 /* ************** */ (45 minutes per day for the very expanded range)
		       i.e. now 7 days per year of data!

         start         finish        Duration
--------------------------------------------------
2019  04/14 11:00 --  04/20 07:30   6 d 20h
2020  04/14 11:00 --  04/22 12:20   7
2021  04/14 11:00 --  04/22 12:00
2022  04/14 11:00 --  04/22 16:30              !! Check last day, file much smaller
2023  04/14 11:00 --  04/22 16:30
2024  04/14 11:00 --  04/22 15:30
--------------------------------------------------

/* ***************** */ (approx 2 days per year of data)
/* Compute Lambdas   */ (now 3 days with the expanded ranges)
/* ***************** */

	March 1, 2023 Linde is missing which constitutes 10% of DAX
	fixed sanity check in 02_Make_Ells to not require weights to sum to one!
	Instead, I keep all rows where weights sum up to the maximum of that day,
	i.e. when all available constitutent stocks have started trading.

         start         finish        Duration
--------------------------------------------------
2019  04/24 12:00 --  04/26 14:00
2020  04/24 12:00 --  04/27 11:00
2021  04/24 12:00 --  04/27 11:00
2022  04/24 12:00 --  04/27 11:00
2023  04/24 12:00 --  04/27 11:00
2024  04/24 12:00 --  04/27 11:00
--------------------------------------------------
--------------------------------------------------

