/* *************************************************************************** *
*					WFP RAM-N rCARI Validation Study - CAR 				   	   * 
*																 			   *
*  PURPOSE:  			Set up household dataset 							   *
*  AUTHOR: 				Nicole Wu (nicole.wu@wfp.org)						   *
*  DATE:  				Aug 13, 2023										   *
*  LATEST UPDATE: 		Aug 14, 2023										   *
*		  																	   *
********************************************************************************
					
	** REQUIRES:	${d_temp}/CAR_F2F_Household_Analysis_`cdate'.dta
					${d_temp}/CAR_RM_Household_Analysis_`cdate'.dta
					
	** CREATES:		${d_dta}/CAR_Full_Household_Analysis_`cdate'.dta
					${d_dta}/CAR_Full_Household_Analysis.sav
					
	** NOTES:		

********************************************************************************
*								PART 1: Set Log
*******************************************************************************/
	
	cap log close 
	
	// set log
	loc cdate: di %td_CCYY_NN_DD date(c(current_date), "DMY")
	loc cdate = subinstr(trim("`cdate'"), " " , "", .)
	log using "${d_log}/cd03_append_`cdate'.smcl", replace
	di `cdate'	

********************************************************************************
*				PART 2: Create master dataset for full sample
*******************************************************************************/
	
	* load dataset
	* ------------
	use "${d_temp}/CAR_F2F_Household_Analysis.dta", clear
	
	* append Remote Answers to F2F Answers
	append using "${d_temp}/CAR_RM_Household_Analysis.dta"
	compress
	drop S_*
	
	* merge sample list 
	mmerge HHID using "${sample}/CAR_Sample_Merge.dta", type(1:1) uname(S_)
	gen Completion = (Attrition == 0)
	
	label def com_list 1 "Completed" 0 "Not Completed"
	label val Completion com_list
	label var Completion "Survey Progress"
	
*	drop if mi(HHID)
	drop _merge
	
********************************************************************************
*						PART 3: Organize Dataset and Labels
*******************************************************************************/

*	missings dropvars, force 	// remove extra vars
*	missings dropobs , force 	// remove empty observations

** Define and Format Strings
gl other_specify EnuName_Display HHHealthAcMildWhy_oth HHHealthAcSevereWhy_oth  ///
   HHHealthChronWhy_oth HHHealthEmergWhy_oth LhCSIEnAccess_stress_oth 		    ///
   LhCSIEnAccess_crisis_oth LhCSIEnAccess_em_oth HHHOccupation HHIncFirst_oth 	///
   HHDwellType_oth HHTenureType_oth HHWallType_oth HHRoofType_oth HHFloorType_oth ///
   HHToiletType_oth HHEnerCookStove_oth HHEnerCookSRC_oth HHEnerLightSRC_oth 	///
   HHWaterSRC_oth comments remarks
	
	** remove unnecessary blanks in string and adjust the proper cases
foreach var of global other_specify {
    replace `var' = strproper(strtrim(`var'))
    }

	export excel HHID Modality ${other_specify} 					///
		   using "${note}/CAR_other_specify_raw_`cdate'.xlsx", 		///
		   firstrow(variables) replace
	
	** check duplicated labels
	labeldup
	
	* rename value labels
	labelrename EnuSex gender_label
	
	* add value labels
	label values RESPSex R_Resp_Sex gender_label
	label values ConsentYN HHAsstOthCBTRecYN HHAsstUNNGOCBTRecYN HHAsstWFPCBTRecYN ///
				 HHExp*_Purch_7D* HHExp*_GiftAid_7D* HHExp*_Own_7D* 			   ///	
				 HHExp*_Purch_1M* HHExp*_GiftAid_1M* 							   ///
				 HHExp*_Purch_6M* HHExp*_GiftAid_6M* 							   ///
				 HHSBedHung HHSNoFood HHSNotEat HHToiletWho HHhostDisp 			   ///
				 MDDIHHDiscrim MDDIHHDisplChoice MDDIHHPercSafe MDDIHHShInsec6M    ///
				 MMDIHHHealthFac PWMDDW* RESPFoodWorry_YN sampleYN RESPFemale 	   ///
				 RESPHHH YesNo

	* adjust start and end time
	
	* save dataset
	compress
*	iecodebook export using "${d_out}/CAR_Full_Codebook.xlsx", replace
	
	save 	 "${d_dta}/CAR_Full_Household_Analysis.dta", replace
	save 	 "${dta}/CAR_Full_Household_Analysis.dta", replace
	save 	 "${all_dta}/CAR_Full_Household_Analysis.dta", replace
	
	// not date specific for tableau import consistency
	savespss "${d_dta}/CAR_Full_Household_Analysis.sav", replace
	
* -------------	
* End of dofile
