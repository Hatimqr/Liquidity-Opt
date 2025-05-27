/* Draw a time series graph (or several)*/

local FarblisteA blue red
local FarblisteB ltblue orange

twoway /*
 */ (tsline `g1', cmissing(n n) yaxis(1) lcolor(`FarblisteA') ) /*
 */ (tsline `g2', cmissing(n n) yaxis(2) lcolor(`FarblisteB') ) /*
 */ , legend(off) ttitle("") tlabel(none)  /*
 */ name(bild_`bpi'_`was', replace) nodraw


if (0==1) {
/* Alternatively, we could also use: */
 tlabel(#5, angle(forty_five)) 
 tlabel(#5, alternate)  
}
