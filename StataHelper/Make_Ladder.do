/* Take whatever is in memory and create a separate frame for every stock */
clear
version 18
frame reset

qui include localdefs.do

/* Get a list of stock tickers from the Stock Name Variable */
*qui levelsof StockName, local(SList)
* local SList: list clean SList

* alternatively, use the list of stocks from localdefs:
 local SList "`Gesamt_liste'"
*local SList "`stock_liste'"

*local SList "BMW 1COV P911 SAP"

/* copy each stock to an individual frame */
foreach aktie_nam in `SList' {
    display "`c(current_date)'/`c(current_time)': Current Stock `aktie_nam' "

    /* Load some data */
    qui use "`bystock_path'/`aktie_nam'.dta" , clear

    su zeit, meanonly
    if r(N) == 0 {
        continue
    }

    /* Clean up */
    cap drop timestamp
    cap drop trade_side

    /* For now, enough to keep only the 'ladder' variables */
    qui keep ask* bid* zeit trade_price trade_volume
    qui drop *full 

    /* Put the summaries into level 0 */
    qui rename ask_sum ask0_volume
    qui rename bid_sum bid0_volume
   
    qui rename ask_max_price ask0_price
    qui rename bid_min_price bid0_price

    reshape long ask@_price ask@_volume bid@_price bid@_volume, i(zeit) j(level)

    tsset level zeit, clocktime delta(1 sec)
    qui save "`ladder_path'/`aktie_nam'.dta" , replace

}
