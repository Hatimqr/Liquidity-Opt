/* Wherever needed, use <include filename> in the statacode, 
	i.e. here include localdefs.do  */

/* Which stocks */
*local stock_liste "ALV DB1 FRE RWE BAS" 
local stock_a "DBK BMW BEI CON DHL DTE FRE FME DB1 HEI" 
local stock_b "HEN3 1COV IFX MRK PUM RHM RWE MBG SAP SRT3" 
local stock_c "SIE WDI TKA VOW3 LHA HNR1 ALV MUV2 MTX DWNI"  /* CH Careful with WDI */
*local stock_c "SIE     TKA VOW3 LHA HNR1 ALV MUV2 MTX DWNI" 
local stock_d "HFG BNR ADS VNA DHER BAS BAYN CBK DTG EOAN" 
local stock_e "ENR P911 PAH3 SHL SY1 ZAL LIN AIR QIA"  /* No LIN in 12 2023 */
*local stock_e "ENR P911 PAH3 SHL SY1 ZAL     AIR QIA" 
local stock_liste "`stock_a' `stock_b' `stock_c' `stock_d' `stock_e'" 
*local stock_liste "DBK BMW BEI CON DHL" 
local stock_num : word count `stock_liste'
/* will be modified in: 01_ReadIndexData to add in the entire DAX Sample */
local Gesamt_liste : list local(Gesamt_liste) | local(stock_liste)
