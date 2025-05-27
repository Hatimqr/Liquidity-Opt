  /* This subroutine loads the DAX weights relevant for the current date into a frame
	called index_info.
	It creates a local macro with the name of all DAX constituents
	and it creates a local macro for each DAX constituent containing the weight of that stock
	in the DAX on this particular day. 
	The weights are adjusted to guarantee they add up to one.
  */

  /* This table provides us with index weights, free float, and market cap. */
  cap frame drop DAX_Today 
  frame create DAX_Today str4 StockName weight_DAX FFF FFq

  cap frame drop index_info
  frame create index_info
  frame index_info {
    /* We are going to use the weights from Eurostoxx */
    *qui use `save_path'/IndexComposition, clear 
    /* combined with free float data from Bloomberg: */
    qui use `save_path'/Bloomberg_Stoxx, clear

    /* Put the Trading Symbols of  all stocks that have been part in the DAX since 2019 into DAX_All
	and merge it with the stock_liste to create one list containing all stock names we might ever need */
    qui levelsof TradingSymbol, local(DAX_All) clean
    local Gesamt_liste : list stock_liste | DAX_All

    /* Stata does not allow wildcards in scalar names, 
	so instead, loop over all possible stock names
	   and drop the corresponding weights if they exist */
    foreach stocki in `Gesamt_liste' {
       cap drop scalar weight_`stocki'
    }

    /* Now, find the entries in this table closest to the day we are considering 
		... but before! */
    qui gen zeitdiff = zeitd - `datum_i'
    qui drop if zeitdiff > 0
    qui su zeitdiff
    qui keep if zeitdiff == r(max)

    /* Which stocks are in the index at this point? */
    /* Write it to a local variable list */
    levelsof TradingSymbol, local(DAX_liste)
    local DAX_liste: list clean DAX_liste
    local DAX_total_components = r(r)
    /* CH: Remark: STata can handle 100 frames, 
		we will have two frames per DAX component, plus a few more
		so as long as the total components are less than approx 45 we should be OK.
	For bigger indexes, need to change the computational approach */

    /* For each stock, read in the weight it has in the Portfolio */
    /*     with the full sample there will be stocks missing or with weight zero, 
	make sure this can be handled properly */ /* CH Remark */

    /* Read the weights into a variable */
    scalar weight_DAX      = 0
    scalar weight_DAX_final= 0
    foreach stocki in `DAX_liste' {
       qui su IndexWeight if TradingSymbol =="`stocki'", meanonly
       scalar weight_`stocki' = r(mean)
       scalar weight_DAX      = weight_DAX + weight_`stocki'
    }

    /* Make sure, portfolio weights sum to ONE  and post to DAX Today frame*/
    foreach stocki in `DAX_liste' {
       scalar weight_`stocki' = weight_`stocki' / weight_DAX
       scalar weight_DAX_final= weight_DAX_final + weight_`stocki'
       disp "`stocki': weight_`stocki'"

       /* Also post the Free Float */
       qui su FFq        if TradingSymbol =="`stocki'", meanonly
       local mffq = r(mean)
       qui su FreeFloat  if TradingSymbol =="`stocki'", meanonly

       frame post DAX_Today ("`stocki'") (scalar(weight_`stocki')) (r(mean)) (`mffq')
    }
  } /* Ends the frame index_info commands */
