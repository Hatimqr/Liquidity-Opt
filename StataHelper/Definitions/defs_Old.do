/* Wherever needed, use <include filename> in the statacode, 
	i.e. here include localdefs.do  */

/* Buy/Sell/Auction Events? */
 local bsalist "buy sel auc"
 *local bsalist "buy sel    " /* Removes auctions from data! */

/* Which Frequencies? */
 local freqliste "Sec Min Hour"

 local preisliste trade_price /* last_buy_price last_sel_price */
 local volumliste trade_volume
 local valueliste trade_value

/* This creates a local macro with the names of all ask/bid prices */
/*  and the volumes */
/*  First initialize the lists: */
 local ask_liste
 local bid_liste
 local askbid_vol 
 local askbid_val 

/* Several of the macros should include the max depth */
/*  The loop through all the values for depth */
forvalues i = 1/`=scalar(maxdep)' {
 local ask_liste   `ask_liste'  ask`i'_price
 local bid_liste   `bid_liste'  bid`i'_price
 local askbid_vol  `askbid_vol' ask`i'_vol bid`i'_vol
 local askbid_val  `askbid_val' ask`i'_val bid`i'_val
 local preisliste  `preisliste' ask`i'_price bid`i'_price
 local volumliste  `volumliste' ask`i'_volume bid`i'_volume
 local valueliste  `valueliste' ask`i'_value bid`i'_value
}

