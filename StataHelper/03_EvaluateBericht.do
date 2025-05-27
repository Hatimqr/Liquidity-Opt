version 18
clear
graph drop _all
collect clear

include Definitions/defs_Paths

* use Bericht, clear
 use Bericht_20190401_20191231, clear
     append using Bericht_20200101_20201231
     append using Bericht_20210101_20211231
     append using Bericht_20220101_20221231
     append using Bericht_20230101_20231231
     append using Bericht_20240101_20241231

 qui gen Jahr = year(Datum)
*keep if Jahr == 2023
*drop Jahr

/* Data starts on April 2, 2019 */
/* No need to look at anything before that */
local StartTag = mdy(04,02,2019) 
qui drop if Datum < `StartTag'

/* Create the panel structure */
encode StockName, gen(SNam)
tsset SNam Datum, d


/* List of Figures we are creating */
local FigListe "FigAucFrac_box FigLatFrac  FigNumRows FigAucFrac_stocks FigLiqAucScatter Fig_Price_Full FigBAFrac  FigDiskTime FigMemoryBox Figeod_ABV FigBid_Range FigMemoryTime FigTradVol"

/* For some years we have not generated the eodyes variable yet.
	This line make sure it exists */
cap qui gen eodyes = (eod_AV != .) | (eod_BV != .)

local liste NumRows SizeCSV SizeMem NumAuctions VolAuctions NumBuys VolBuys /*
	*/ NumSells VolSells BidSumMin BidSumMax AskSumMin AskSumMax /*
	*/ eodyes eod_AV eod_BV /*
        */ pbid_range_min pbid_range_max pbid_range_mean /*
        */ pask_range_min pask_range_max pask_range_mean /*
        */ pask_full pbid_full ptrade

su `liste'

foreach x of varlist `liste' {
	qui replace `x' = . if `x'==-1
	su `x'
}

/* Drop Weekends and Holidays */
qui include `sub_path'/sub_ClearHolidays
local nrep n n n n n n n n n n n n n  


/* Relation between Order Book and Auctions */
qui gen BAMax = max(AskSumMax,BidSumMax)
qui gen BAFrac= BAMax/VolAuctions
    graph box BAFrac, by(StockName, yrescale note(" ")) 
	graph rename FigBAFrac

qui gen VolBS    = (VolBuys + VolSells)
qui gen VolTrade = (VolBuys + VolSells + VolAuctions)

xtline VolTrade, /* 
	*/ byopts(title("Total Trading Volume") yrescale legend(off)) /*
        */ byopts(note(" ")) cmissing(`nrep') /*
	*/ xlabel(,angle(60)) xtitle("")  ytitle("")  
	graph rename FigTradVol

qui gen BAS = BAMax/VolBS

qui gen AucFrac = VolAuctions/VolTrade
xtline AucFrac, /* 
	*/ byopts(title("Auction - Trade Volume Ratio") yrescale legend(off)) /*
        */ byopts(note(" ")) cmissing(`nrep') /*
	*/ xlabel(,angle(60)) xtitle("")  ytitle("")  
	graph rename FigAucFrac_stocks  

graph box AucFrac, title("Auction Volume as Fraction of Total Trading Volume")
	graph rename FigAucFrac_box

qui gen latent = min(AskSumMax,BidSumMax)
qui gen realized=VolBS

qui gen ell_proxy = realized + latent
qui gen latFrac   = latent/ell_proxy
graph box latFrac
	graph rename FigLatFrac

twoway (scatter VolAuctions ell_proxy), /*
	*/ by(StockName, yrescale xrescale note(" "))
        graph rename FigLiqAucScatter

/* Imporance of EoD auction */

/* Last row order book versus end of day auction: */
graph box eod_AV eod_BV, /*
	*/ by(SNam, title("Order Book and Auction Volume") note(" ")) /*
        */ by(, yrescale legend(off))
    graph rename Figeod_ABV

/* Do we have any trading activity on this day? */
qui gen NumTrade = (NumBuys + NumSells + NumAuctions)
qui gen TradeYes = (NumTrade > 0) & (NumTrade!=.)
qui gen TradeNo  = (1-TradeYes) | (NumTrade==.)
qui gen SizeSmall = (SizeCSV < 10^-3)

/* List for which stocks we are missing stuff */
tab StockName if SizeSmall

/* Get a list of stock tickers from the Stock Name Variable */
qui levelsof StockName, local(SName)
 local SName: list clean SName

/* Display for missing stocks, which dates are missing */
foreach x in `SName' {
	qui preserve
	qui keep if StockName=="`x'"
	qui su NumRows if NumRows == 0
	if r(N) > 0 {
	display("`x'")
	tab Datum if NumRows==0
	}
	qui restore
}

save hugo, replace
*ENDE

/* Price Range: */
xtline pask_range_min pbid_range_max, /*
	*/ byopts(title("Bid and Ask Ranges") legend(off) yrescale ) /*
        */ byopts(note(" ")) cmissing(`nrep') /*
	*/ xlabel(,angle(60)) xtitle("")  ytitle("") 
	graph rename FigBid_Range

/* Price Full: */
qui gen mpbid_full = (-1)*pbid_full
xtline pask_full mpbid_full, /*
	*/ byopts(title("Fraction of Level 150 Bid and Ask Prices") legend(off) yrescale ) /*
        */ byopts(note(" ")) cmissing(`nrep') /*
	*/ xlabel(,angle(60)) xtitle("")  ytitle("")  /*
	*/ addplot((line ptrade Datum, yaxis(2)))
	graph rename Fig_Price_Full

/* Memory: Total Size on Disk */
qui su SizeCSV
scalar SizeTotal=r(sum)

/* Memory RAM per day */
preserve
qui collapse (sum) SizeMem SizeCSV, by(Datum)
    tsline SizeCSV, title("Daily GB of Disk Space")
	graph rename FigDiskTime
    tsline SizeMem
	graph rename FigMemoryTime
    graph box SizeMem
	graph rename FigMemoryBox
restore

/* How many rows/day for each stock? */
 xtline NumRows, /*
	*/ byopts(title("Number of Order Book Rows per Day") yrescale ) /*
        */ byopts(note(" ")) cmissing(`nrep') /*
	*/ xlabel(,angle(60)) xtitle("")  ytitle("") 
	graph rename FigNumRows

qui su NumRows if (NumRows > 0)&(eodyes==1)
	scalar RowMin=r(min)
	scalar RowMax=r(max)

/* Write out which end of days we do not have */
foreach x in `SName' {
        *display("`SName'")
        qui preserve
        qui keep if StockName=="`x'"
        qui keep if (eodyes==0)|(NumRows==0)
             outfile Datum using "MissingStuff/`x'.csv", replace noquote wide
        qui restore
        }

preserve
    qui keep if (eodyes==0)|(NumRows==0)
    disp("Missing Stuff:")
    tab StockName
restore

/* Show a few things relevant for the test */
/* Minimum and Maximum number of rows for stock ?? on date ?? */
list SNam Datum NumRows if NumRows==scalar(RowMin)|NumRows==scalar(RowMax)

display("Total Size on Disk (in TB):")
display(scalar(SizeTotal/1024))

/* Create eps files for all the figures */
foreach FigName of local FigListe {
	*graph display `FigName'
	graph export `FigPath'`FigName'.eps, name(`FigName') replace
	!epstopdf `FigPath'`FigName'.eps
}

/* Write a table with summary info to disk */
drop if NumRows==0
local vlist /*
        */ VolAuctions /*
        */ NumAuctions /*
        */ AucFrac  latFrac eod_AV eod_BV pask_range_min pbid_range_max /*
        */ pask_full pbid_full /*
        */ SizeMem SizeCSV /*
        */ NumRows /*
        */
local vari  StockName

 /* table (var StockName) (result), /// */
* compute summary statistics
 table () (result), ///
    stat(mean `vlist') ///
    stat(sd `vlist') ///
    stat(min `vlist') ///
    stat(p10    `vlist') ///
    stat(median    `vlist') ///
    stat(p90    `vlist') ///
    stat(max `vlist') ///
    name(by)

* other style changes
 collect label levels result sd "Std. Dev." min "Min" max "Max" p10 "P10" p90 "P90", modify
 collect style cell result[mean median sd min p10 p50 p90 max], nformat(%18.2fc)
 collect style tex, nobegintable
 collect preview
 collect export `FigPath'BerichtSummaryTable.tex, tableonly replace


