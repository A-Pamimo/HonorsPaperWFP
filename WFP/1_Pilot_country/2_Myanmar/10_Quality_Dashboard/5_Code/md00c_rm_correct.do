/* *************************************************************************** *
*						WFP RAM-N rCARI Validation Study - Myanmar 			   * 
*																 			   *
*  PURPOSE:  			Correct field errors for Remote sample				   *
*  AUTHOR: 				Nicole Wu (nicole.wu@wfp.org)						   *
*  DATE:  				May 15, 2023										   *
*  LATEST UPDATE: 		May 16, 2023										   *
*		  																	   *
********************************************************************************

					
	** REQUIRES:	${d_raw}/Myanmar_RM_Household_Raw_`cdate'.csv
					
	** CREATES:		${d_temp}/Myanmar_RM_Household_Correct_`cdate'.dta
			
	** NOTES:		_`cdate' was removed after finishing data collection

********************************************************************************
*					PART 1: Load Household Data and Correct Errors
*******************************************************************************/
	
	cap log close 
	
	// set log
	loc cdate: di %td_CCYY_NN_DD date(c(current_date), "DMY")
	loc cdate = subinstr(trim("`cdate'"), " " , "", .)
	log using "${d_log}/md00c_rm_correct_`cdate'.smcl", replace
	di `cdate'
	
* load dataset
* ---------------	
	use "${d_raw}/Myanmar_RM_Household_Raw.dta", clear
	compress
	
	* basic quality checks and formating
	ds, has(type string) 
	** remove unnecessary blanks in string and adjust the proper cases
	local strvars "`r(varlist)'"
foreach var of local strvars {
    replace `var' = strtrim(`var')
    }

/*	* fix the duplicated manual ID by phone number - this is very bad practice 
	* but keep temperarily to move the scripts forward 
	gen ID_Length_temp  = length(HHID_manual) 
	* get phone number last length digit for the unique ID
	gen PhoneNum_8_temp = substr(HHPhNmb,-8,.) if ID_Length_temp == 8
	gen PhoneNum_7_temp = substr(HHPhNmb,-7,.) if ID_Length_temp == 7

	replace HHID = PhoneNum_8_temp if ID_Length_temp == 8 & sampleYN == 0 
	replace HHID = PhoneNum_7_temp if ID_Length_temp == 7 & sampleYN == 0
	drop *_temp 	
*/
	** Errors log # 19
	replace HHID = "02507CEF" if ___uuid == "a98f5c11-f029-4925-8e3e-8062b11fd912"
	
	** Errors log # 20
	drop if  ___uuid == "424d5f47-9a54-43c7-ae35-9a4ab9fb0bff"
	
	** Errors log #21
	drop if  ___uuid == "db964b81207649d2891126efbc3d9f69"
	
	drop if sampleYN == 0
	
	** resolve unmatched ID
	replace HHID = "2701EM5"  if ___uuid == "c2250007-8b29-4f8a-b11c-09ae936b3a54"
	replace HHID = "4M85633"  if ___uuid == "1cbe9cc7-f90c-4068-960a-9a9af0092968"
	replace HHID = "YN425215" if ___uuid == "9da84158-e99d-4b2d-affe-3ecfa0130064"
	
	ieduplicates HHID using "${note}/Myanmar_RM_DuplicateID_`cdate'.xlsx", 		///
					  keepvar(EnuName_Display) uniquevars(___uuid) nodaily force 
	
	** Flag translation Error for Short Form
	gen 		Err_ExpNF = !mi(HHExpNF_GiftAid_1M)
	label var   Err_ExpNF "Error: invalid translation for non-food in Remote Short" 
	
	** check ID and drop empty vars and obs
 	isid HHID	 				// check unique identifier
	// check again with the real survey data
	ren ___index HH_Index
	
*************************  ADD CORRECTION LINES HERE ***************************
	
	save "${d_temp}/Myanmar_RM_Household_Correct.dta", replace
