set more off

//Load the total

 ***************************
 *demographics
 ***************************
 
 use "C:\Users\alirah.weyori\OneDrive - World Food Programme\2_CARI_validation\1_rCARI_study\1_Pilot_country\2_Myanmar\10_Quality_Dashboard\1_Raw\Myanmar_F2F_Roster_Raw_20230602.dta", clear
 
 tab ___parent_index
 rename ___parent_index hh_index
 
 tempfile roster

 save `roster'
 
use "C:\Users\alirah.weyori\OneDrive - World Food Programme\2_CARI_validation\1_rCARI_study\1_Pilot_country\2_Myanmar\10_Quality_Dashboard\1_Raw\Myanmar_F2F_Household_Raw_20230602.dta", clear

***********************************
 //check the uniqu identifier
 **********************************
 tab ___index
 duplicates report ___index
 rename ___index hh_index
 
 
 merge 1:m hh_index using `roster'
 drop _merge
 
 save "C:\Users\alirah.weyori\OneDrive - World Food Programme\2_CARI_validation\1_rCARI_study\1_Pilot_country\2_Myanmar\10_Quality_Dashboard\1_Raw\Myanmar_Merged_Household_Raw_20230602.dta", replace

 