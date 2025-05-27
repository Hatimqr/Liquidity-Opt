/* Load the data into stata and do some basic preps */

version 18
/* */
clear

frame create FileSizeGZ /*
	*/ Datum str4 StockName str20 StockNum FileSize

frame create Data
frame change Data

qui include Definitions/localdefs.do   /* The local definitions */
*qui include `sub_path'/sub_fileID.do   /* Mapping TradeSymbols/Mnemonics to security and segment ID and ISIN */

 local datum_start = mdy(01,01,2019)  /* Enter in Month,Day,Year form! */
 local datum_ende  = mdy(12,31,2019) 

forvalues datum_i = `datum_start'/`datum_ende' {
 local datum_str = string(`datum_i', "%tdCCYYNNDD") 
 qui include `sub_path'/sub_fileID.do   /* Mapping TradeSymbols/Mnemonics to security and segment ID and ISIN */

foreach aktie_nam in `Gesamt_liste' {
    local pos : list posof "`aktie_nam'" in Gesamt_liste
    local aktie_num : word `pos' of `fileID_liste'

*display "`c(current_date)'/`c(current_time)': Current Stock `aktie_nam' with ID `aktie_num' for day `datum_str'"

/* CSV files are gzipped, so unzip them before importing.
	keep the .gz file, so that we don't need to recompress afterwards */

cap confirm file "`raw_path'/`aktie_nam'/books.XETR.`aktie_num'.`datum_str'.csv.gz" 
if _rc == 0 {
    local gzipyes = 1

    /* List the size of a file on disk */
    local Datei "`raw_path'/`aktie_nam'/books.XETR.`aktie_num'.`datum_str'.csv.gz"
    file open fh using `"`Datei'"', read binary
    file seek fh eof
    file close fh

    scalar report_file_g = r(loc)/(1024^3)
}
else {
    scalar report_file_g = -1
}

 frame post FileSizeGZ /*
	*/ (`datum_i') ("`aktie_nam'") ("`aktie_num'") (scalar(report_file_g))

} /* Ends the loop over all stocks in stock liste */


} /* Ends the loop over the dates */

frame FileSizeGZ: save FileSizeGZ, replace
frame FileSizeGZ: outfile using "FileSizeGZ.csv", noquote replace comma wide


