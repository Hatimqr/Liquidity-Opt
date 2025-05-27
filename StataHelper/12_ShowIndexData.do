version 18
clear

include Definitions/defs_Paths.do

/* Show how the index componenets evolve over the relevant time period */

*use `save_path'/IndexComposition
use `save_path'/Bloomberg_Stoxx

*qui gen SName = sym
*qui gen datum = zeitd
*merge 1:1  datum SName using `bloomberg_path'/Bloomberg_FFData.dta

/* Check the merge */
*preserve
*   qui keep datum SName Pit lastprice_B free* Free* outstan* FF* 
*restore


xtline IndexWeight, /*
    */ ttitle(`"Time (2019--2024)"') tlabel(minmax, labels format(%tdDD/NN/CCYY)) tmtick(none, nolabels) /*
    */ byopts(title(`"Weight in DAX over Time"'))
graph export "`FigPath'/IndexWeight.eps", replace
!epstopdf     "`FigPath'/IndexWeight.eps"
*graph export "`FigPath'/IndexWeight.pdf", replace

xtline FreeFloat, /*
    */ ttitle(`"Time (2019--2024)"') tlabel(minmax, labels format(%tdDD/NN/CCYY)) tmtick(none, nolabels) /*
    */ byopts(title(`"Free Float Factor over Time"'))
graph export "`FigPath'/FreeFloat.eps", replace
!epstopdf    "`FigPath'/FreeFloat.eps"
*graph export "`FigPath'/FreeFloat.pdf", replace

xtline MarketCap, /*
    */ ttitle(`"Time (2019--2024)"') tlabel(minmax, labels format(%tdDD/NN/CCYY)) tmtick(none, nolabels) /*
    */ byopts(title(`"Market Capitalization over Time"'))
graph export "`FigPath'/MarketCap.eps", replace
!epstopdf    "`FigPath'/MarketCap.eps", replace
*graph export "`FigPath'/MarketCap.pdf", replace


