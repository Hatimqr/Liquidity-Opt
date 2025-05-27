*clear
*frame reset
*version 18

*use hugo
local dtvar zeit
local missmus "n n n"
local missmus "n y n"
local grangle 60

cap drop zeitd
qui gen zeitd = dofc(`dtvar')

/* Get a list Days */
qui levelsof zeitd, local(DList)
  local DList: list clean DList

*disp "`DList'" 

/* Every day, insert a missing observation around 7am */
foreach tagi of local DList {
    *disp("`tagi'")
    qui insobs 1, before (1)
    qui replace  `dtvar' = (`tagi' * 24 + 7) * 60 * 60 * 1000 in 1
}

 tsline bid_price trade_price ask_price    if level==0,  xlabel(,angle(`grangle')) cmissing(`missmus')
*tsline bid_volume trade_volume ask_volume if level==0,  xlabel(,angle(`grangle')) cmissing(`missmus')
