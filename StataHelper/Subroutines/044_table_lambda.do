preserve
*local prelist ell_ask ell_bid lambda_ell_ask lambda_ell_bid
local prelist ell_ask ell_bid lambda_ask lambda_bid
local pick R`bpi'_T`tti'
 
    qui rename lambda_ell_ask_`pick' lambda_ask_`pick'
    qui rename lambda_ell_bid_`pick' lambda_bid_`pick'

    foreach x of var ell* {
        qui replace `x' = `x'/1000
    }

    foreach eli of local prelist {
    local vlist `eli'_`pick'
    cap collect drop by

    table (SName) (result) , ///
        stat(mean `vlist') ///
        stat(sd `vlist') ///
        stat(min `vlist') ///
        stat(p10    `vlist') ///
        stat(median    `vlist') ///
        stat(p90    `vlist') ///
        stat(max `vlist') ///
        stat(count  `vlist') ///
        name(by)

 collect levelsof SName
 collect style autolevels SName  .m `s(levels)', clear
 collect style header SName [.m], level(hide)


*other style changes
 collect label levels result count "N" sd "sd" min "Min" max "Max" p10 "P10" p90 "P90", modify
 collect style cell result[mean median sd min p10 median p90 max], nformat(%18.2fc)
 collect preview
 *collect title "Summary Statistics for `eli' with `pick'" // add title
 collect style tex, nobegintable
 collect export `FigPath'/sumtable_`vlist'.tex, tableonly replace

}

restore
