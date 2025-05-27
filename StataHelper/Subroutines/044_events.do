    /* Eventstudies */
    include `defs_path'/defs_EventDates
    local nrep n n n n n n n n n n

    /* Create date dummy for each element of this event date list */
    local eventlist "Trip_Witch_Dates DAX_Extend_Dates DAX_Extend_Pre DAX_Extend_Post WDI_Exit_Dates"

    local dax_ext   3 9 25 35 36 37 43 41 44 49
    local dax_30    1 2 4 5 6 8 11 12 13 15 16 20 21 22 23 24 27 29 30 31 32 33 39 40 42 46 47 14 18 19

    /* Flag the stocks that entered when DAX went from 30 to 40 */
    qui gen DAX_ext = 0
    foreach si of local dax_ext {
        qui replace DAX_ext = 1 if `si'==SName
    }
    qui gen DAX_30  = 0
    foreach si of local dax_30  {
        qui replace DAX_30  = 1 if `si'==SName
    }

    foreach el of local  eventlist {
       disp("`el'")
       qui gen dummy_`el' = 0
       foreach di of local  `el'   {
        disp("`di'")
        disp(real("`di'"))
        if real("`di'") == . {
            continue
        } 
        else {
            scalar jahr  = floor(`di'/10000)
            scalar monat =floor(( `di'-10000*jahr)/100)
            scalar tag   =floor(( `di'-10000*jahr-100*monat))
            scalar zeitd = mdy(scalar(monat),scalar(tag),scalar(jahr))
            qui replace dummy_`el' = 1 if(Date==scalar(zeitd))
        }
      }
    }

    /* Generate interaction terms */
    qui gen Dummy_pre30   = dummy_DAX_Extend_Pre   * DAX_30
    qui gen Dummy_prenew  = dummy_DAX_Extend_Pre   * DAX_ext
    qui gen Dummy_day30   = dummy_DAX_Extend_Dates * DAX_30
    qui gen Dummy_daynew  = dummy_DAX_Extend_Dates * DAX_ext
    qui gen Dummy_post30  = dummy_DAX_Extend_Post  * DAX_30
    qui gen Dummy_postnew = dummy_DAX_Extend_Post  * DAX_ext

    qui gen ye_ask = log(ell_ask_R`bpi'_T`tti')
    qui gen ye_bid = log(ell_bid_R`bpi'_T`tti')
    qui gen  y_ask =    (lambda_ell_ask_R`bpi'_T`tti')
    qui gen  y_bid =    (lambda_ell_bid_R`bpi'_T`tti')
    qui gen yl_ask = log(lambda_ell_ask_R`bpi'_T`tti')
    qui gen yl_bid = log(lambda_ell_bid_R`bpi'_T`tti')

    /* regress  on dummy and */
    /* write regression results to latex table */
    table (colname  result) (command),                 /*
    */ command(_r_b _r_se: xtreg ye_ask dummy_Trip_Witch_Dates Dummy_*)   /*
    */ command(_r_b _r_se: xtreg ye_bid dummy_Trip_Witch_Dates Dummy_*)  /*
    */ command(_r_b _r_se: xtreg  y_ask dummy_Trip_Witch_Dates Dummy_*)   /*
    */ command(_r_b _r_se: xtreg  y_bid dummy_Trip_Witch_Dates Dummy_*)  /*
    */ command(_r_b _r_se: xtreg yl_ask dummy_Trip_Witch_Dates Dummy_*)   /*
    */ command(_r_b _r_se: xtreg yl_bid dummy_Trip_Witch_Dates Dummy_*)  /*
    */ style(table-reg2-fv1) nformat(%6.2f) /*
    */ sformat("(%s)" _r_se) /*
    */

    collect label levels command 1 "log(L) ask" 2 "log(L) bid" 3 "\(\lambda\) ask" 4 "\(\lambda\) bid", modify
    collect label levels command 5 "log(\(\lambda\)) ask" 6 "log(\(\lambda\)) bid", modify
    collect style header command, level(label)
    collect style tex, nobegintable
    *collect title "Event Study Results for T=`tti' and R=`bpi'" // add title

    collect preview
    collect export `FigPath'/event_table_R`bpi'_T`tti'.tex, tableonly replace // leave out Latex preamble in export

    /* Plot the stocks */
    preserve
    keep if (DAX_30) | (DAX_ext) | (SName==0) | (SName==7)
    keep if (dummy_DAX_Extend_Pre) |(dummy_DAX_Extend_Dates) |(dummy_DAX_Extend_Post)

      /* Make bid negative */
    foreach x of var ell*bid* d_*bid* lambda*bid* {
        qui replace `x' = (-1)*`x'
    }

    xtline ell*R`bpi'*, byopts(yrescale)     byopts(legend(off))      xlabel(,angle(60)) /*
        */ tline(20sep2021)      /*
        */ cmissing(`nrep') /*
        */ byopts(title("L(.,R=`bpi')") note(" ") ) /*
        */ ttitle("") lcolor(`Farbliste' `Farbliste')
           graph export `FigPath'/DAXe_EllT.eps, replace
           !epstopdf "`FigPath'/DAXe_EllT.eps"

   xtline ell*T`tti'*, byopts(yrescale)    byopts(legend(off))    xlabel(,angle(60)) /*
        */ tline(20sep2021)      /*
        */ byopts(title("L(T=`tti',.)") note(" ") ) /*
        */ ttitle("") lcolor(`Farbliste' `Farbliste')
           graph export `FigPath'/DAXe_EllR.eps, replace
           !epstopdf "`FigPath'/DAXe_EllR.eps"

   xtline lambda_ell_*R*_T`tti' , byopts(yrescale) byopts(legend(off)) xlabel(,angle(60)) /*
        */ tline(20sep2021)      /*
        */ byopts(title("{&lambda}(.,R=`bpi')") note(" ") ) /*
        */ ttitle("") lcolor(`Farbliste' `Farbliste')
           graph export `FigPath'/DAXe_LambdaR.eps, replace
           !epstopdf "`FigPath'/DAXe_LambdaR.eps"
   xtline lambda_ell_*R`bpi'_T* , byopts(yrescale) byopts(legend(off)) xlabel(,angle(60)) /*
        */ tline(20sep2021)      /*
        */ byopts(title("{&lambda}(T=`tti',.)") note(" ") ) /*
        */ ttitle("") lcolor(`Farbliste' `Farbliste')
           graph export `FigPath'/DAXe_LambdaT.eps, replace
           !epstopdf "`FigPath'/DAXe_LambdaT.eps"

   restore
