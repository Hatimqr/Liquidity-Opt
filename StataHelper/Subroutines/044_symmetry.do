    /* Symmetry? between bid and ask */
    /* look at equal means and correlations */


     frame create Correlations SName R T ell lambda lamhat ell_sig lambda_sig lamhat_sig

preserve
     drop *q*
     drop d_*
     *keep if (SName == 0)|(SName==8)
     levelsof SName , local(SNameList) 
     foreach Sni of local SNameList {
     foreach ri of local bpvec {
     foreach ti of local ttvec {
         foreach pre in "ell" "lambda"{ 
         /* Reset to not carry stale values around */
         local `pre'_rho = .
         local `pre'_sig = .

         /* lambda and lamhat are 1 for DAX */
         * if "`pre'"!="`ell'"&`Sni'==0 {
         *     continue
         * }
         qui pwcorr `pre'*R`ri'_*T`ti' if SName==`Sni' , sig
         local `pre'_rho = r(rho)
         local `pre'_sig = r(sig)[2,1]
         }
    *disp("`Sni:' (`ri',`ti')")
    *disp("`ell_rho' ; `lambda_rho'")
    qui frame post Correlations (`Sni') (`ri') (`ti') (`ell_rho') (`lambda_rho') (.) (`ell_sig') (`lambda_sig')  (.)
    }
    }
    }
     *by SName: pwcorr `pre'*R`bpi'*T`tti'
     *by SName: pwcorr lambda*R`bpi'*T`tti'
restore

    frame Correlations {
        graph box ell lambda, /*
            */ by(, title("Bid-Ask Correlations") note(" ")) /*
            */ legend(order(1 "L(T,R)" 2 "{&lambda}(T,R)")) /* 
            */ by(T R) /*
            */
        graph export "`FigPath'/fig_bacorr_box.pdf", replace
        graph export "`FigPath'/fig_bacorr_box.eps", replace
    }
