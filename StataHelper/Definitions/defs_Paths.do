/* Wherever needed, use <include filename> in the statacode, 
	i.e. here include localdefs.do  */

/* Define the various paths */
qui pwd
local start_path  `c(pwd)'

local data_path  "../Data"
*local raw_path   "`data_path'/Raw/Stocks"
*local raw_path   "/Data/DeutscheBoerse/OrderBooks/Stocks"
if c(hostname)=="Amigo"|c(hostname)=="Arthur" {
    *disp "Amigo hier"
    local raw_path     "`data_path'/Raw/Stocks"
    local bloomberg_path "`data_path'/Raw/Bloomberg"
    local daily_path   "`data_path'/Daily"
    local ells_path    "`data_path'/Ells"
    local bystock_path "`data_path'/ByStock"
    local ladder_path  "`data_path'/Ladder"
}
else {
    *disp "Kein Amigo hier"
    local raw_path     "/Fast/Stocks"
    local bloomberg_path "/Fast/Bloomberg"
    local daily_path   "/Fast/Daily"
    local ells_path    "/Fast/Ells"
    local bystock_path "/Fast/ByStock"
    local ladder_path  "/Fast/Ladder"
}

local idx_path   "`data_path'/Raw/DAX_Composition"
local temp_path  "`data_path'/Temp"
local stock_path "`data_path'/Stocks"
local index_path "`data_path'/Index"
local save_path  "`data_path'/Final"

local    defs_path "./Definitions"
local     sub_path "./Subroutines"
local results_path "../Results"

*local FigPath "../Text/Material_2024_12/"
*local FigPath "../Text/Material_2025_03/"
local FigPath "../Text/Material_2025_04/"

