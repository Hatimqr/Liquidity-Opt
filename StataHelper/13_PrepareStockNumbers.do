/* Read the mnemonics from index composition and merge in all the IDs from the XETRA .csv file */
/* Create a list with Market and Security ID for all the DAX components in our sample */
/* some is already in the list from Stefan Schlamp, 
	will have to do the remaining ones manually */

/* Manually completed list is called AktienInfo.csv  located in the Data/Raw folder */

/* Duplicates */
/* In the 2019 -- 2024 sample there are 
    two ISINs with two mnemonics:
	DPW and DHL for 
 	DAI and MGB for
    as well as one mnemonic with two ISINs:
	QIA

    make sure we know what is going on for those
*/

clear
version 18

include Definitions/defs_Paths

/* Use the CSV file of Stefan Schlamp */
frame create Schlamp
/* What are the ISIN and the Trading Symbol called in this dataset?*/
local matchliste_csv "isin_code   mnemonic"
frame Schlamp {
    import delimited "`idx_path'/index_constituents.DAX.20231204.csv"
	/* called isin_code */
	/* called mnemonic  */
}


/* Create a unique list of stocks that are in our DAX sample */
frame create DAX
/* What are the ISIN and the Trading Symbol called in this dataset?*/
local matchliste_dax "ISIN        TradingSymbol"
frame DAX {
    /* Remove irrelevant variables and drop duplicates */
    qui use `save_path'/IndexComposition
    qui keep TradingSymbol ISIN
    qui duplicates drop
    qui drop if missing(ISIN)

    sort ISIN
    duplicates list ISIN
    duplicates tag ISIN, generate(doppelisin)
    duplicates tag TradingSymbol, generate(doppeltsym)
    

   /* Connect to Schlamp table and merge in available info */
   frlink 1:1 `matchliste_dax', frame(Schlamp `matchliste_csv') 
   frget market_segment_id security_id wkn_number mnemonic , from(Schlamp)
}

frame change DAX
