qui local nrep n n n n n n n n n n n n
qui aorder
qui preserve
  /* Make bid negative */
    foreach x of var ell*bid* d_*bid* lambda*bid* {
        qui replace `x' = (-1)*`x'
    }

drop if SName == 0
drop *_q_* /* we need to either drop the q's here or explicitly remove them from the graphs! */

    xtline ell*R`bpi'*, byopts(yrescale)     byopts(legend(off))      xlabel(,angle(60)) /*
	*/ byopts(title("L(.,R=`bpi')") note(" ") ) /*
        */ cmissing(`nrep') /*
	*/ ttitle("") lcolor(`Farbliste' `Farbliste')
           graph export `FigPath'/All_EllT.eps, replace
           !epstopdf "`FigPath'/All_EllT.eps"

    xtline ell*T`tti'*, byopts(yrescale)    byopts(legend(off))    xlabel(,angle(60)) /*
	*/ byopts(title("L(T=`tti',.)") note(" ") ) /*
        */ cmissing(`nrep') /*
	*/ ttitle("") lcolor(`Farbliste' `Farbliste')
           graph export `FigPath'/All_EllR.eps, replace
           !epstopdf "`FigPath'/All_EllR.eps"

   xtline lambda_ell_*R*_T`tti' , byopts(yrescale) byopts(legend(off)) xlabel(,angle(60)) /*
	*/ byopts(title("{&lambda}(.,R=`bpi')") note(" ") ) /*
        */ cmissing(`nrep') /*
	*/ ttitle("") lcolor(`Farbliste' `Farbliste')
           graph export `FigPath'/All_LambdaR.eps, replace
           !epstopdf "`FigPath'/All_LambdaR.eps"
   xtline lambda_ell_*R`bpi'_T* , byopts(yrescale) byopts(legend(off)) xlabel(,angle(60)) /*
	*/ byopts(title("{&lambda}(T=`tti',.)") note(" ") ) /*
        */ cmissing(`nrep') /*
	*/ ttitle("") lcolor(`Farbliste' `Farbliste')
           graph export `FigPath'/All_LambdaT.eps, replace
           !epstopdf "`FigPath'/All_LambdaT.eps"

   xtline d_lamhat_*R*_T`tti' , byopts(yrescale) byopts(legend(off)) xlabel(,angle(60)) /*
	*/ byopts(title("$lamhat(.,R=`bpi')") note(" ") ) /*
        */ cmissing(`nrep') /*
	*/ ttitle("") lcolor(`Farbliste' `Farbliste')
           graph export `FigPath'/All_LamHatR.eps, replace
           graph export `FigPath'/All_LamHatR.pdf, replace
           *!epstopdf "`FigPath'/All_LamHatR.eps"
   xtline d_lamhat_*R`bpi'_T* , byopts(yrescale) byopts(legend(off)) xlabel(,angle(60)) /*
	*/ byopts(title("$lamhat(T=`tti',.)") note(" ") ) /*
        */ cmissing(`nrep') /*
	*/ ttitle("") lcolor(`Farbliste' `Farbliste')
           graph export `FigPath'/All_LamHatT.eps, replace
           graph export `FigPath'/All_LamHatT.pdf, replace
           *!epstopdf "`FigPath'/All_LamHatT.eps"
/* Now bring the q's back in */
restore



    xtline ell*q*, byopts(yrescale) /* byopts(legend(off)) */ xlabel(,angle(60)) /*
	*/ byopts(title("L(.,q)") note(" ") legend(off)) /*
        */ cmissing(`nrep') /*
	*/ ttitle("") lcolor(`Farbliste' `Farbliste')
           graph export `FigPath'/All_Ellq.eps, replace
           !epstopdf "`FigPath'/All_Ellq.eps"

    xtline lambda*q*, byopts(yrescale) /* byopts(legend(off)) */ xlabel(,angle(60)) /*
	*/ byopts(title("{&lambda}(.,q)") note(" ") legend(off)) /*
        */ cmissing(`nrep') /*
	*/ ttitle("") lcolor(`Farbliste' `Farbliste')
           graph export `FigPath'/All_Lambdaq.eps, replace
           !epstopdf "`FigPath'/All_Lambdaq.eps"

   local xi "R`bpi'_T`tti'"
   su *R`bpi'_T`tti' if SName==`Si'
   su *`xi' if SName==`Si'

preserve
    /* Again, make bid negative */
    foreach x of var ell*bid* d_*bid* lambda*bid* {
        qui replace `x' = (-1)*`x'
    }
drop if SName == 0
drop *_q_* /* we need to either drop the q's here or explicitly remove them from the graphs! */
/* Again, drop the q's */

   /* Evolution over T-Range, keeping Time constant */
   tsline d_lamhat_*R*_T`tti' if SName==`Si'  /*
	   */       ,   lcolor(`Farbliste' `Farbliste') /*
           */ legend(off) /*
           */ title("BMW: $lamhat(T=`tti',.) ")/*
	   */
           graph export `FigPath'/BMW_LamHatR.eps, replace
           graph export `FigPath'/BMW_LamHatR.pdf, replace
           *!epstopdf "`FigPath'/BMW_LamHatR.eps"

   tsline lambda_ell_*R*_T`tti' if SName==`Si' /*
	   */       ,   lcolor(`Farbliste' `Farbliste') /*
           */ legend(off) /*
           */ title("BMW: {&lambda}(T=`tti',.) ")/*
	   */
           graph export `FigPath'/BMW_LambdaR.eps, replace
           !epstopdf "`FigPath'/BMW_LambdaR.eps"
   tsline        ell_*R*_T`tti' if SName==`Si' /*
	   */       ,   lcolor(`Farbliste' `Farbliste') /*
           */ legend(off) /*
           */ title("BMW: L(T=`tti',.) ")/*
	   */
           graph export `FigPath'/BMW_EllR.eps, replace
           !epstopdf "`FigPath'/BMW_EllR.eps"

   /* Evolution over Time, keeping Range constant */
   tsline d_lamhat_*R`bpi'_T* if SName==`Si' /*
	   */       ,   lcolor(`Farbliste' `Farbliste') /*
           */ legend(off) /*
           */ title("BMW: $lamhat(.,R=`bpi') ")/*
	   */
           graph export `FigPath'/BMW_LamHatT.eps, replace
           graph export `FigPath'/BMW_LamHatT.pdf, replace
           *!epstopdf "`FigPath'/BMW_LamHatT.eps"
   tsline lambda_ell_*R`bpi'_T* if SName==`Si' /*
	   */       ,   lcolor(`Farbliste' `Farbliste') /*
           */ legend(off) /*
           */ title("BMW: {&lambda}(.,R=`bpi') ")/*
	   */
           graph export `FigPath'/BMW_LambdaT.eps, replace
           !epstopdf "`FigPath'/BMW_LambdaT.eps"
   tsline        ell_*R`bpi'_T* if SName==`Si' /*
	   */       ,   lcolor(`Farbliste' `Farbliste') /*
           */ legend(off) /*
           */ title("BMW: L(.,R=`bpi') ")/*
	   */
           graph export `FigPath'/BMW_EllT.eps, replace
           !epstopdf "`FigPath'/BMW_EllT.eps"

/* and bring the q's back in */
restore

   *frame copy default "F`Si'"  
   frame create "F`Si'"  
   frame copy default Working  
   frame dir
   frame Working {
       qui keep if SName == `Si'
       qui keep if Date  == `max_Date' /* Jan 27, 2023 */
       
       foreach bpi of num `bpvec' {
       foreach tti of num `ttvec' {
       preserve
           qui keep *R`bpi'_T`tti'
           local xi "R`bpi'_T`tti'"
           rename d_*_`xi' *
           rename   lambda_ell_*_`xi' lambda_*
           rename   *_`xi' *
           qui gen RR = `bpi'
           qui gen TT = `tti'


          frame F`Si' : frameappend Working
       restore
       }
       }
       
   }
   frame F`Si' {
       aorder 
       order RR TT
       tsset RR TT
       /* Remove the variable labels */
       foreach x of var * {
           label variable `x' `" "'
       }

       /* Basic Formating of the Graph */
       local bildopts  `"xscale(log) xlabel(,angle(60))  ytitle("Basis Points") xtitle("Time in Seconds")"'

       twoway (contour lambda_ask RR TT), `bildopts'                                       title("{&lambda} Ask")
           graph rename la
       twoway (contour lambda_bid RR TT), `bildopts'                                       title("{&lambda} Bid")
           graph rename lb
       twoway (contour    ell_ask RR TT), `bildopts'                                       title("  L    Ask")
           graph rename ea
       twoway (contour    ell_bid RR TT), `bildopts'                                       title("  L    Bid")
           graph rename eb
       twoway (contour lamhat_ask RR TT), `bildopts'                                       title("$lamhat Ask")
           graph rename ha
       twoway (contour lamhat_bid RR TT), `bildopts'                                       title("$lamhat Bid")
           graph rename hb
 
       /* which date are we using? */
       local mdate : di %td `max_Date'
       graph combine ea eb la lb, title("BMW, `mdate'")
           graph rename EllLam
           graph export `FigPath'/BMW_EllLam.eps, replace
           !epstopdf "`FigPath'/BMW_EllLam.eps"
       graph combine la lb ha hb, title("BMW, `mdate'")
           graph rename LamHat
           graph export `FigPath'/BMW_LamHat.eps, replace
           graph export `FigPath'/BMW_LamHat.pdf, replace
           *!epstopdf "`FigPath'/BMW_LamHat.eps"
   }
   frame change F`Si'
   graph drop _all

frame change default

/*
    foreach stocki in `stock_liste' {
    foreach bai in "bid" "ask" {

        local bildliste
        local row_liste
        foreach was in "inc" "ins" "max" {
            local col_liste
            foreach bpi of num `bpvec' {

            local iter "`was'_`bai'_P`bpi'"
            local g1 "*alt_`iter'_`stocki'"
            local g2 "*_ell_`iter'_`stocki'"
         
            qui include `sub_path'/sub_fig_TSLam 
        *su `g1' `g2'
            local bildliste   "`bildliste' bild_`bpi'_`was'"
            local col_liste   "`col_liste' bild_`bpi'_`was'"
            }
        graph combine `col_liste' , cols(1) colfirst xcommon title("`was'") name(bild_`was', replace) nodraw
        local row_liste   "`row_liste' bild_`was'"
        }
    graph combine `row_liste' , rows(1) , title("`stocki': `bai'") name(bild_`stocki'_`bai', replace)
    graph export "`FigPath'/fig_hatell_`stocki'_`bai'_`Freq'.pdf", replace
    graph export "`FigPath'/fig_hatell_`stocki'_`bai'_`Freq'.eps", replace
    graph drop _all
    serset clear
    }
    }

*/
