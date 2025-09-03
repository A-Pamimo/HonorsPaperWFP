/* *************************************************************************** *
*						WFP RAM-N rCARI Validation Study - CAR 			       * 
*																 			   *
*  PURPOSE:  			Correct field errors for F2F Roster					   *
*  AUTHOR: 				Nicole Wu (nicole.wu@wfp.org)						   *
*  DATE:  				Aug 14, 2023										   *
*  LATEST UPDATE: 															   *
*		  																	   *
********************************************************************************

					
	** REQUIRES:	${d_raw}/CAR_F2F_Roster_Raw_`cdate'.csv
					
	** CREATES:		${d_temp}/CAR_F2F_Roster_Correct_`cdate'.dta
	
	** NOTES:		_`cdate' removed on Sep 18 when data collection was done

********************************************************************************
*					PART 1: Load Roster Data and Correct Errors
*******************************************************************************/

	cap log close 
	
	// set log
	loc cdate: di %td_CCYY_NN_DD date(c(current_date), "DMY")
	loc cdate = subinstr(trim("`cdate'"), " " , "", .)
	log using "${d_log}/cd00b_roster_correct_`cdate'.smcl", replace
	di `cdate'
	
	* load dataset
	* ---------------	
	use "${d_raw}/CAR_F2F_Roster_Raw.dta", clear
	compress
	
	** check ID and drop empty vars and obs
 	ren ___parent_index	 HH_Index
	
	** drop PIIs
	drop RESPName

	* basic quality checks and formating
	ds, has(type string) 
	** remove unnecessary blanks in string and adjust the proper cases
	local strvars "`r(varlist)'"
foreach var of local strvars {
    replace `var' = strtrim(`var')
    }
	
*************************  ADD CORRECTION LINES HERE ***************************
	
	save "${d_temp}/CAR_F2F_Roster_Correct.dta", replace

*********************  MISSING RESPONDENT INFO TO FOLLOW UP ********************

/* 	Filter out households with multiple members as respondents 
	drop if inlist(HH_Index,3,25,71,72,73,74,75,76,77,78,79,84,86,88,171,219,220,221,332,339,345,423,504,525)
	// handled separately
	keep if RESPYN == 1
	
	mmerge HH_Index using "${d_temp}/CAR_F2F_Household_Correct_`cdate'.dta", ///
		   type(1:1) uname(F_) ukeep(HHID HH_Index EnuName_Display  		 ///
		   RESPAge RESPSex RESPStatus S_hh_head_sex S_hh_head_marital) 
	drop if _merge == 2	   
	
	order F_EnuName_Display F_HHID HH_Index F_RESPAge F_RESPSex F_RESPStatus ///
		  F_S_hh_head_sex F_S_hh_head_marital ___index, first
