/* *************************************************************************** *
*						WFP RAM-N rCARI Validation Study - Iraq 			   * 
*																 			   *
*  PURPOSE:  			Set up appended dataset for full roster sample		   *
*  AUTHOR: 				Nicole Wu (nicole.wu@wfp.org)						   *
*  DATE:  				May 11, 2023										   *
*  LATEST UPDATE: 															   *
*		  																	   *
********************************************************************************

					
	** REQUIRES:	${raw_f2f}/Demographic_module_RepeatPID_vA.dta
					${raw_f2f}/Demographic_module_RepeatPID_vB.dta
					
	** CREATES:		${dta}/Iraq_F2F_Roster_Raw.dta
						
	** NOTES:		

********************************************************************************
*					PART 1: Load Roster Data and Set codebook
*******************************************************************************/
	
	cap log close 
	
	// set log
	loc cdate: di %td_CCYY_NN_DD date(c(current_date), "DMY")
	loc cdate = subinstr(trim("`cdate'"), " " , "", .)
	log using "${logs}/i01b_setup_roster_`cdate'.smcl", replace
	di `cdate'
	
* load dataset
* ---------------	

	tempfile roster_b resp master 
	use "${raw_f2f}/Demographic_module_RepeatPID_vB.dta", clear
	compress
	gen Group = 2
	save `roster_b'
	
	use "${raw_f2f}/Demographic_module_RepeatPID_vA.dta", clear
	compress
	gen Group = 1
	
	lab def G_l 1 "Group A" 2 "Group B"
	lab val Group G_l
	
	append using `roster_b'
	
	** check ID and drop empty vars and obs
	missings dropvars, force 	// remove extra vars
	missings dropobs , force 	// remove empty observations

	** drop irrelevant variables 
	drop HH_index EnuName EnuSex HHIntFirstSec ___index ___parent_table_name 	///
		 ADMIN1Name ADMIN5Name age_diff_actual
	
	save `master'
	
	/* Respondent him/herself is not listed as part of the roster, need to split 
	and append back - This is strange!! 			*/
	
	keep HHID RESPName RESPAge RESPSex RESPRelationHHH
	ren  RESPName PName
	ren  RESPAge  PAge
	ren  RESPSex  PSex
	ren  RESPRelationHHH PRelationHHH
	
	sort HHID
	egen Respondent = tag(HHID)
	keep if Respondent == 1 
	
	save `resp'
	
	use `master'
	drop RESPName RESPAge RESPSex RESPRelationHHH
	
	append using `resp'
	
	** generate individual index within each household
	bysort HHID: gen Ind_Index = _n
	
	save "${dta}/Iraq_F2F_Roster_Raw.dta", replace

********************************************************************************
*					PART 2: Create Household Level Variables
*******************************************************************************/
	
	
	
********************************************************************************
*				PART 3: Create merged dataset for full sample
*******************************************************************************/


	
* End of dofile
