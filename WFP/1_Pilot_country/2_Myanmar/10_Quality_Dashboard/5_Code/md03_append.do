/* *************************************************************************** *
*					WFP RAM-N rCARI Validation Study - Myanmar 				   * 
*																 			   *
*  PURPOSE:  			Set up household dataset 							   *
*  AUTHOR: 				Nicole Wu (nicole.wu@wfp.org)						   *
*  DATE:  				May 12, 2023										   *
*  LATEST UPDATE: 		Jun  7, 2023										   *
*		  																	   *
********************************************************************************
					
	** REQUIRES:	${d_temp}/Myanmar_F2F_Household_Analysis_`cdate'.dta
					${d_temp}/Myanmar_RM_Household_Analysis_`cdate'.dta
					
	** CREATES:		${d_dta}/Myanmar_Full_Household_Analysis_`cdate'.dta
					${d_dta}/Myanmar_Full_Household_Analysis.sav
					
	** NOTES:		

********************************************************************************
*								PART 1: Set Log
*******************************************************************************/
	
	cap log close 
	
	// set log
	loc cdate: di %td_CCYY_NN_DD date(c(current_date), "DMY")
	loc cdate = subinstr(trim("`cdate'"), " " , "", .)
	log using "${d_log}/md03_append_`cdate'.smcl", replace
	di `cdate'	

********************************************************************************
*				PART 2: Create master dataset for full sample
*******************************************************************************/
	
	tempfile sample master otherspecify
	
	* merge assignment record back to check implementation
	import excel "${sample}/Myanmar_Sample_Merge.xlsx", sheet("Sheet1") 	///
				 firstrow clear
	
	encode Modality_Type, gen(Assign_Modality)
	encode Length_Type, gen(Assign_Length)
	encode Region, gen(Region_byte)
	encode Township, gen(Township_byte)
	encode Camp, gen(Camp_byte)
	
	drop   Modality_Type Length_Type Region Township Camp
	ren    *_byte *
	
	compress
	save `sample'
	
	* load dataset
	* ------------
	use "${d_temp}/Myanmar_F2F_Household_Analysis.dta", clear
	
	* merge Remote Answers to F2F Answers
	append using "${d_temp}/Myanmar_RM_Household_Analysis.dta"
	compress

	** create one consent variable 
	gen Consent = (ConsentYN == 1 | RESPAvailable == 1) 
	label val Consent YesNo
	
	drop if Consent == 0 
	
	drop if mi(HHID)
	mmerge HHID using `sample', type(1:1) uname(S_)
	
	gen Completion = (_merge == 3)
*	drop if _merge == 1
	
	drop _merge 
	
*	label def com_list 1 "Completed Out-Sample" 2 "To Complete" 3 "Completed In-Sample"

	label def com_list 1 "Completed" 0 "Not Completed"
	label val Completion com_list
	label var Completion "Survey Progress"
		
********************************************************************************
*						PART 3: Organize Dataset and Labels
*******************************************************************************/

	** Define and Format Strings
gl other_specify HHHOccupation HHHOccupation_S HHHealthAcMildWhy_oth   ///
   HHHealthAcSevereWhy_oth HHHealthChronWhy_oth HHHealthEmergWhy_oth 	  		   ///
   LhCSIEnAccess_stress_oth LhCSIEnAccess_crisis_oth LhCSIEnAccess_em_oth 		   ///
   HHIncFirst_oth HHIncFirst_oth_S HHDwellType_oth HHTenureType_oth HHWallType_oth ///
   HHRoofType_oth HHFloorType_oth HHToiletType_oth  			   ///
   HHEnerLightSRC_oth HHWaterSRC_oth 
	
	** remove unnecessary blanks in string and adjust the proper cases
foreach var of global other_specify {
    replace `var' = strproper(strtrim(`var'))
*	replace `var' = subinstr(`var', "`r(0x0d)'`r(0x0a)'", "", .)
    }
	
*	missings dropvars, force 	// remove extra vars
*	missings dropobs , force 	// remove empty observations
	
/*	* Export all _other variables
	codebook *oth* HHHOccupation HHHOccupation_S HHStatusOth comments
	keep HHID EnuName_Display $other_specify comments
	drop if mi(EnuName_Display)
	export excel using "${note}/Myanmar_Full_Otherspecify.xlsx", firstrow(variables) replace
*/	
	save `master'
	
	import excel "${note}/Myanmar_other_specify_translated_co.xlsx", sheet("MMR translations") ///
		   firstrow clear
	
	drop EnuName_Display
	drop if mi(HHID)
	drop Z-AE
	
	compress
	save `otherspecify'
	
	use `master', clear
	* translate other specify answers
	mmerge HHID using `otherspecify', type(1:1) uname(T_)
	
foreach var of global other_specify {
	order T_`var', a(`var')
	drop `var'
	ren T_`var' `var'
}
	order T_comments, a(comments)
	drop comments
	ren T_comments comments
	
	compress
	drop _merge

	** Assignment 
	gen 	Assignment = .
	replace Assignment = 1 if Modality == 1 & Form == 1
	replace Assignment = 2 if Modality == 1 & Form == 2
	replace Assignment = 3 if Modality == 2 & Form == 1
	replace Assignment = 4 if Modality == 2 & Form == 2
	
	** check duplicated labels
	labeldup
	
	* rename value labels
	labelrename EnuSex gender_label
	
	* add value labels
	label values RESPSex R_Resp_Sex R_HHH_Sex gender_label
	label values ConsentYN HHAsstOthCBTRecYN HHAsstUNNGOCBTRecYN HHAsstWFPCBTRecYN ///
				 HHExp*_Purch_7D* HHExp*_GiftAid_7D* HHExp*_Own_7D* 			   ///	
				 HHExp*_Purch_1M* HHExp*_GiftAid_1M* HHExp*_Own_1M*				   ///
				 HHExp*_Purch_6M* HHExp*_GiftAid_6M* 							   ///
				 HHSBedHung HHSNoFood HHSNotEat HHToiletWho HHhostDisp 			   ///
				 MDDIHHDiscrim MDDIHHDisplChoice MDDIHHPercSafe MDDIHHShInsec6M    ///
				 MMDIHHHealthFac PWMDDW* RESPFoodWorry_YN sampleYN RESPFemale 	   ///
				 RESPHHH YesNo

	label def assign_l 1 "F2F Long" 2 "F2F Short" 3 "Remote Long" 4 "Remote Short"
	label val Assignment assign_l
	* adjust start and end time
	
	* save dataset
	compress
*	iecodebook export using "${d_out}/Myanmar_Full_Codebook.xlsx", replace
	
	save 	 "${d_dta}/Myanmar_Full_Household_Analysis.dta", replace
	save 	 "${dta}/Myanmar_Full_Household_Analysis.dta", replace
	save	 "${all_dta}/Myanmar_Full_Household_Analysis.dta", replace
	
	// not date specific for tableau import consistency
	savespss "${d_dta}/Myanmar_Full_Household_Analysis.sav", replace
	
* -------------	
* End of dofile
