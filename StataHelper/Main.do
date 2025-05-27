version 18
clear

frame reset
graph drop _all

timer clear

/* Which stages to execute */
/* ----------------------- */
scalar Do_DataCheck   = 0 	/* Expect approx:
				     30 minutes per day  of data on Trillian 
				     two weeks  per year of data on Trillian 
				*/
scalar Do_DAXBasics   = 0 	/* Expect approx:
				*/
scalar Do_MakeElls    = 0 	/* Expect approx:
				*/

scalar Do_MakeLambdas = 0 	/* Expect approx:
				*/

scalar Do_EvaluateAll = 0 	/* Expect approx:
				*/

scalar Do_CAPM        = 0 	/* Expect approx:
				*/

cap log close _all
log using MainLog,  append text

/* In the workflow, here we could run the download bash file to get the liquidity data from A7 
	which will be in gzipped csv files. */



/* Check the download of Liquidity Data */
     /* Only checks for the presence of the daily files */
if scalar(Do_DataCheck)==1 {
    do 00_CheckMissingDays.do
    do 01_EvaluateFileSize.do

    /* Reads the raw data, posts details to a summary frame */
    /* Creates a DailySecs file containing ALL stocks for the day at per second frequency */
    do 02_CheckDownload  
    do 03_EvaluateBericht
}

if scalar(Do_DAXBasics)== 1  {
    /* DAX composition Data */
      do 10_ReadIndexData  /* Assembles a file with Index Composition over time plus some info
			     Creates the file: IndexComposition  */
      do 11_MergeInBloomberg /* Brings in information from Blomberg on free float */
      do 12_ShowIndexData  /* Creates graphs with IndexWeight, Free Float */

    /* Combine the Original Schlamp-csv with the list of all DAX components 
			    to create the AktienInfo.csv file
			    which forms the basis for the download from A7 via the API */
     do 13_PrepareStockNumbers.do

    /* The Variable Name File */
     do 14_ReadNames      /* Creates the Stock_NameNum file, which is based on the AktienInfo.csv */
}

/* Compute the stock specific Ells for per second data */
if scalar(Do_MakeElls)== 1  {
    do 20_Make_Ells.do
}

/* Compute the stock specific Ells for per second data */
if scalar(Do_MakeLambdas)== 1  {
    do 30_Make_Lambdas.do
}

/* Finally, Graphs and CAPM */
if scalar(Do_EvaluateAll)== 1 {
 do 40_evaluate_lambda
}

if scalar(Do_CAPM)       == 1 {
 *do 50_GetCAPM_Data
 do 51_compute_CAPM
}

log close
