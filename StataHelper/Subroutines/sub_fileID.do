/* This routine is helpful when reading the data from XETRA.
	We like to think in mnemonics/trading symbols, but
	data is stored using segmentID and securityID.
	This routine creates ordered lists  of each of these informations.
	We can then look up the position of the stock in any of these lists
	and read out the correspondign information of the other variables.

  Revision History:
	Current Version: June 4, 2024
*/
/* -------------------------------------------------------------------------- */
version 18
qui include Definitions/localdefs.do

local isin_liste
local fileID_liste
local wkn_liste

/* Don't destroy the date in memory */
preserve

/* New Way */
 qui use "`save_path'/Stock_NameNum", clear

 /* On January 29, 2024 QIA changes market segment ID and ISIN */
 qui drop if expiration_date < `datum_i ' 

 

 qui levelsof mnemonic, local(mnemo) 
 local mnemo: list clean mnemo

 foreach aktie_nam in `Gesamt_liste' {

  /* Which position is the current stock in the table? */
  local pos : list posof "`aktie_nam'" in mnemo
  *disp "`pos' `aktie_nam'"

     /* Create lists with the info from the table for later use */
	 /* don't know how to do this in one step */
         /* So first a bunch of intermediate local variables */
     local isin   = isin_code[`pos']
     local seg_ID = market_segment_id[`pos']
     local sec_ID = security_id[`pos']
     local fileID = "`seg_ID'_`sec_ID'"
     *local wkn    = wkn_number[`pos']

     *disp("`aktie_nam' `isin' `fileID'")

     /* This is what we really need going forward */
     local isin_liste   `isin_liste'    `isin'
     local fileID_liste `fileID_liste'  `fileID'
     *local wkn_lists    `wkn_liste'     `wkn' 

 }
*display "`isin_liste'"
*display "`stock_liste'"
*display "`fileID_liste'"

*display "`mnemo'"

/* Could probably be done with frames now, 
	i.e. use isin or mnemo to link two frames */

/* We are done, bring original memory content back */
restore
