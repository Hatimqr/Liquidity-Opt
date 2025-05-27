/* Based on the computed lambdas, create tables,graphs, ... */

frame reset

version 18
clear 


global lamhat "`=ustrunescape("\u03bb\u0302")'"

local Farbliste "ltkhaki gold orange red sienna brown black"
*local Farbliste "gold orange red navy green brown black"

 qui include Definitions/localdefs.do  /* The local definitions */

    /* Load the lambda data */
    qui use "`save_path'/Daily_20190402_20191231.dta", clear
     qui append using "`save_path'/Daily_20200101_20201231.dta"
     qui append using "`save_path'/Daily_20210101_20211231.dta"
     qui append using "`save_path'/Daily_20220101_20221231.dta"
     qui append using "`save_path'/Daily_20230101_20231231.dta"
     qui append using "`save_path'/Daily_20240101_20241231.dta"

    /* Data only starts on April 2, 2019 */
    keep if Date > mdy(04,01,2019)

    qui gen Jahr = year(Date)

    /* Get rid of Wirecard? */
    *drop if SName==48

    /* Set as panel data */
    tsset SName Date, d

    /* First and Last day  in sample */
    qui su Date, meanonly
    local min_Date = r(min)
    local max_Date = r(max)

    /* No hourly results today */
    cap drop h_*

/* Here we pick: */
   *local Si       0 /* for DAX */
   local My_Si       8 /* for BMW */
   *local Si       3 /* for AIR */
   local My_bpi  200
   local My_tti  3600
   local bpi     = `My_bpi'
   local tti     = `My_tti'
   local  Si     = `My_Si'

    /* Draw a lot of nice graphs */
       include `sub_path'/044_graph_lambda.do

   local bpi     = `My_bpi'
   local tti     = `My_tti'
   local  Si     = `My_Si'
       include `sub_path'/044_table_lambda.do

    /* Eventstudies */
       include `sub_path'/044_events.do

    /* Symmetry? between bid and ask */
       include `sub_path'/044_symmetry.do

disp("R`bpi'_T`tti'")
