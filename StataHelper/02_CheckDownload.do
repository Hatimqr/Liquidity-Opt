/* Load the data into stata and do some basic preps */

version 18
/* */
clear
frame reset

frame create Reports /*
	*/ Datum str4 StockName str20 StockNum NumRows SizeCSV SizeMem /*
	*/ NumAuctions VolAuctions NumBuys VolBuys NumSells VolSells /*
	*/ BidSumMin BidSumMax AskSumMin AskSumMax eodyes eod_AV eod_BV /*
	*/ pbid_range_min pbid_range_max pbid_range_mean /*
	*/ pask_range_min pask_range_max pask_range_mean /*
        */ pask_full pbid_full ptrade

frame create Alle
frame create Data
frame change Data

qui include Definitions/localdefs.do    /* The local definitions */
*qui include `sub_path'/sub_fileID.do   /* Mapping TradeSymbols/Mnemonics to security and segment ID and ISIN */

*local datum_start = mdy(04,01,2019)  /* Enter in Month,Day,Year form! */
 local datum_start = mdy(01,27,2024)  /* Enter in Month,Day,Year form! */
 local datum_ende  = mdy(12,31,2024)  /*  on Trillian */

local datum_sanfang = string(`datum_start', "%tdCCYYNNDD") 
local datum_schluss = string(`datum_ende', "%tdCCYYNNDD") 

forvalues datum_i = `datum_start'/`datum_ende' {
 local datum_str = string(`datum_i', "%tdCCYYNNDD") 
 qui include `sub_path'/sub_fileID.do   /* Mapping TradeSymbols/Mnemonics to security and segment ID and ISIN */

 scalar newday = 1

foreach aktie_nam in `Gesamt_liste' {
    local pos : list posof "`aktie_nam'" in Gesamt_liste
    local aktie_num : word `pos' of `fileID_liste'

display "`c(current_date)'/`c(current_time)': Current Stock `aktie_nam' with ID `aktie_num' for day `datum_str'"

/* Clear all reported scalars */
 cap qui scalar drop report_file_g report_mem_used_g 
 cap qui scalar drop report_bidsummin 
 cap qui scalar drop report_bidsummax 
 cap qui scalar drop report_asksummin 
 cap qui scalar drop report_asksummax 
 cap qui scalar drop report_buysum    
 cap qui scalar drop report_buyvol    
 cap qui scalar drop report_selsum    
 cap qui scalar drop report_selvol    
 cap qui scalar drop report_aucsum    
 cap qui scalar drop report_aucvol    
 cap qui scalar drop report_ptrade

 cap qui scalar drop eodyes
 cap qui scalar drop eod_AV           
 cap qui scalar drop eod_BV           

 cap qui scalar drop pbid_range_min   
 cap qui scalar drop pbid_range_max   
 cap qui scalar drop pbid_range_mean  
 cap qui scalar drop pask_range_min   
 cap qui scalar drop pask_range_max   
 cap qui scalar drop pask_range_mean  

 cap qui scalar drop pask_full
 cap qui scalar drop pbid_full

/* CSV files are gzipped, so unzip them before importing.
	keep the .gz file, so that we don't need to recompress afterwards */
local gzipyes = 0
local  csvyes = 0

cap confirm file "`raw_path'/`aktie_nam'/books.XETR.`aktie_num'.`datum_str'.csv.gz" 
if _rc == 0 {
    local gzipyes = 1
    cap !gzip -dk "`raw_path'/`aktie_nam'/books.XETR.`aktie_num'.`datum_str'.csv.gz" 
}

cap confirm file "`raw_path'/`aktie_nam'/books.XETR.`aktie_num'.`datum_str'.csv" 
if _rc == 0 {
    local csvyes = 1
    cap qui import delimited "`raw_path'/`aktie_nam'/books.XETR.`aktie_num'.`datum_str'.csv" , clear
    local readin = _rc

/* Now we have the raw file in memory and the uncompressed csv on the hard disk */
/* List the size of a file on disk */
local Datei "`raw_path'/`aktie_nam'/books.XETR.`aktie_num'.`datum_str'.csv"
file open fh using `"`Datei'"', read binary
file seek fh eof
file close fh

/* Record size in gigabyte */
scalar report_file_g = r(loc)/(1024^3)

/* To record the memory of the current frame */
qui memory

/* Record size in gigabyte */
scalar report_mem_used_g = r(data_data_u)/(1024^3)
}



/* After this, we should only have a csv.gz file left, no uncompressed files any more! */
if `csvyes'==1 {
    if (`gzipyes'==1) {
        /* Clean up and remove the uncompressed file again */
        !rm "`raw_path'/`aktie_nam'/books.XETR.`aktie_num'.`datum_str'.csv" 
        }
    else {
        /* There was no gzip-file before, so compress the csv but do not keep it around */
        cap !gzip "`raw_path'/`aktie_nam'/books.XETR.`aktie_num'.`datum_str'.csv" 
    } 
} 
else {
    /* No file, therefore no filesize: */
    scalar report_mem_used_g = -1
    scalar report_file_g    = -1

    /* For whatever reason, we have no csv file, so there was nothing to read in */
    *disp "We really should not be here ;-)"
    *disp "It looks like there was no csv file for `aktie_nam' on `datum_str'."

    /* It makes no sense to continue the import process for this day/stock combination */
    *continue
} 

/* How many rows do we have in the dataset? */
qui describe
scalar report_rows = r(N)

/* In case we have an empty file */
if r(N) < 1 {
 scalar report_bidsummin = -1
 scalar report_bidsummax = -1
 scalar report_asksummin = -1
 scalar report_asksummax = -1
 scalar report_buysum    = -1
 scalar report_buyvol    = -1
 scalar report_selsum    = -1
 scalar report_selvol    = -1
 scalar report_aucsum    = -1
 scalar report_aucvol    = -1

 scalar eodyes           = -1
 scalar eod_AV           = -1
 scalar eod_BV           = -1

 scalar pbid_range_min   = -1
 scalar pbid_range_max   = -1
 scalar pbid_range_mean  = -1
 scalar pask_range_min   = -1
 scalar pask_range_max   = -1
 scalar pask_range_mean  = -1

 scalar pask_full        = -1
 scalar pbid_full        = -1
 scalar report_ptrade    = -1

 qui set obs 1
} 
/* Otherwise */
else {
/* Generate numerical time frome timestamp: */
*qui include `sub_path'/sub_MakeTimeNumerical
*sort zeit_MilliSec

/* Compute bunch of summary stats */
qui egen bid_sum = rowtotal(bid*_volume)
qui egen ask_sum = rowtotal(ask*_volume)

qui egen bid_min_price = rowmin(bid*_price)
qui egen ask_max_price = rowmax(ask*_price)

qui gen pbid_range = .
qui gen pask_range = .

/* We do it like this, because not for every instance the p150 exists */
cap qui replace pbid_range = bid_min_price / bid1_price
cap qui replace pask_range = ask_max_price / ask1_price

/* How often do we have p150? */
qui gen byte ask_full = (ask150_price == ask_max_price)
qui gen byte bid_full = (bid150_price == bid_min_price)

foreach bai in bid ask {
    qui sum p`bai'_range
    scalar p`bai'_range_min = r(min)
    scalar p`bai'_range_max = r(max)
    scalar p`bai'_range_mean= r(mean)

    qui sum `bai'_full
    scalar p`bai'_full = r(mean)
}

qui sum bid_sum if bid_sum > 0
 scalar report_bidsummin = r(min)
 scalar report_bidsummax = r(max)

qui sum ask_sum if ask_sum > 0
 scalar report_asksummin = r(min)
 scalar report_asksummax = r(max)

/* Create a variable indicating which buy/sell event we are in */
 qui gen int buy_event = 1 if trade_side == "BUY"
 qui gen int buy_count = sum(buy_event)
 qui su  buy_event
 scalar report_buysum = r(N)
 qui su trade_volume if buy_event == 1
 scalar report_buyvol = r(sum)

 qui gen int sel_event = 1 if trade_side == "SELL"
 qui gen int sel_count = sum(sel_event)
 qui su  sel_event
 scalar report_selsum = r(N)
 qui su trade_volume if sel_event == 1
 scalar report_selvol = r(sum)

 qui gen int auc_event = 1 if /*
     */ strrpos(strlower(trade_side),"auction") > 0
 qui gen int auc_count = sum(auc_event)
 qui su  auc_event
 scalar report_aucsum = r(N)

 qui su trade_volume if auc_event == 1
 scalar report_aucvol = r(sum)

 /* End of Day Auction Volume */
 qui gen int eod_event = 1 if /*
     */ strrpos(strlower(trade_side),"closing") > 0
 qui su trade_volume if eod_event == 1
 scalar eodvol = r(sum)
 scalar eodyes = r(N)

 qui su trade_price if ( (buy_event==1)|(sel_event==1)|(auc_event==1) ), meanonly
 scalar report_ptrade=r(mean)

 /* What is the last row for bid and ask order book? */
 preserve
     drop if ( (buy_event==1)|(sel_event==1)|(auc_event==1) )
     drop if (bid1_price == .)|(ask1_price == .)

     collapse (lastnm) bid_sum ask_sum, fast
     qui su bid_sum, meanonly
     scalar eod_BV = r(mean) / scalar(eodvol)
     qui su ask_sum, meanonly
     scalar eod_AV = r(mean) / scalar(eodvol)
 restore

 /* Collapse to second-frequency */
*qui include `sub_path'/sub_MakeTimeNumerical
*sort zeit_MilliSec
 qui gen zeit_Sec = int(clock(timestamp,"hms#")/1000 )
 qui collapse (lastnm) ask* bid* trade_price (sum) trade_volume *event, by(zeit_Sec) fast
 *duplicates list zeit_Sec
 *pause on
 *pause
}

 qui gen StockName = "`aktie_nam'"

 /* Append it to the collection frame */
 frame Alle: frameappend Data

/* Post the results to the Report Frame */

frame post   Reports /*
	*/ (`datum_i') ("`aktie_nam'") ("`aktie_num'") (scalar(report_rows)) (scalar(report_file_g)) (scalar(report_mem_used_g)) /*
        */ (scalar(report_aucsum)) (scalar(report_aucvol)) (scalar(report_buysum)) (scalar(report_buyvol)) (scalar(report_selsum)) (scalar(report_selvol)) /*
        */ (scalar(report_bidsummin)) (scalar(report_bidsummax)) (scalar(report_asksummin)) (scalar(report_asksummax))  (scalar(eodyes)) (scalar(eod_AV)) (scalar(eod_BV)) /*
	*/ (scalar(pbid_range_min)) (scalar(pbid_range_max)) (scalar(pbid_range_mean)) /*
	*/ (scalar(pask_range_min)) (scalar(pask_range_max)) (scalar(pask_range_mean)) /*
	*/ (scalar(pask_full))      (scalar(pbid_full))      (scalar(report_ptrade))

 /* Make sure we have no stale data floating around */
 clear
 scalar newday = 0
} /* Ends the loop over all stocks in stock liste */

frame Reports: save Bericht_`datum_sanfang'_`datum_schluss', replace

frame Alle: cap qui drop timestamp 
frame Alle: cap qui drop trade_side
frame Alle: save "`daily_path'/DailySecs_`datum_str'.dta", replace
frame Alle: clear

} /* Ends the loop over the dates */
