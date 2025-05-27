/* Read in the AktienInfo File
	that maps index mnemonics to ISIN and Market and Security IDs */

/* This is necessary for automated reading of the individual stock data */

version 18
clear

*include localdefs.do
 include Definitions/defs_Paths.do

*import delimited "/home/chris/Work/Current/Liquidity/Data/Raw/index_constituents.DAX.20231204.csv"
*import delimited "`raw_path'/index_constituents.DAX.20231204.csv"
 import delimited "`idx_path'/AktienInfo.csv"

/* This brings the names back to Schlamp's original variable names */
qui rename tradingsymbol mnemonic
qui rename isin          isin_code

/* the valid_until column only contains entries if the some info on the stock changed */
qui gen expiration_date = date(valid_until,"YMD")
qui replace expiration_date = 99999 if missing(expiration_date)

/* It is important to sort along the mnemonic component later when we loop over the items */
qui sort mnemonic expiration_date
compress
save "`save_path'/Stock_NameNum.dta", replace

