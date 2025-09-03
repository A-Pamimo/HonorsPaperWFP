/* *************************************************************************** *
*					WFP APP-FA rCARI Validation Study - BF 					   * 
*																 			   *
*  PURPOSE:  			Correct field errors for F2F Household 				   *
*  AUTHOR: 				Nicole Wu (yue.wu@berkeley.edu)						   *
*  DATE:  				Oct 28, 2024										   *
*  LATEST UPDATE: 		Oct 29, 2024										   *
*		  																	   *
********************************************************************************

					
	** REQUIRES:	${hfc_raw}/BF_F2F_Household_Raw.dta
					${sample}/BF_Sample_Merge.dta
					
	** CREATES:		${hfc_note}/BF_F2F_DuplicateID_`cdate'.xlsx
					${hfc_temp}/BF_F2F_Household_Correct.dta
	** NOTES:		

********************************************************************************
*					PART 1: Load Household Data and Correct Errors
*******************************************************************************/
	
	loc cdate: di %td_CCYY_NN_DD date(c(current_date), "DMY")
	loc cdate = subinstr(trim("`cdate'"), " " , "", .)
	
* load dataset
* ---------------	
	use "${hfc_raw}/BF_F2F_Household_Raw.dta", clear
	compress
	
	* basic quality checks and formating
	ds, has(type string) 
	** remove unnecessary blanks in string and adjust the proper cases
	local strvars "`r(varlist)'"
foreach var of local strvars {
    replace `var' = strtrim(`var')
	replace `var' = "" if `var' == " "
    }
	
*	isid HHID 
	** create one consent variable 
	duplicates tag HHID, generate(Dup)
	
	bysort HHID: egen Survey_Outcome = max(ConsentYN) if Dup >= 1
	replace Survey_Outcome = ConsentYN if Dup == 0
	
	gen HH_Final = (ConsentYN == Survey_Outcome)
	egen HH_TAG = tag(HHID) if HH_Final == 1
	
	replace Survey_Outcome = . if HH_TAG == 0
	label val Survey_Outcome ConsentYN

	bysort HHID: egen Consent = max(ConsentYN) 
	label val Consent ConsentYN
	
	** temp complete variable to identify the duplications
	gen Temp_Complete = (!mi(PWMDDWSnf))
	keep if Temp_Complete == 1

	*	iecompdup 	 HHID, id() didifference
	ieduplicates HHID using "${hfc_note}/BF_F2F_DuplicateID_`cdate'.xlsx", 		///
				 keepvar(today EnuName_Display RESPAge RESPSex 	///
				 HHSize) uniquevars(uuid) nodaily force notes(comment)

	mmerge HHID using "${sample}/BF_Sample_Merge.dta", type(1:1) uname(S_)
	
	drop if _merge == 1
	tab S_Assign_Modality Temp_Complete
	
	** keep only F2F sample for attrition analysis
	drop if S_Assign_Modality == 2
	gen Attrition = (_merge == 2)
	label val Attrition SampleYN
	
	drop if Attrition == 1
	
	isid HHID	 				// check unique identifier
	// check again with the real survey data
	ren index	HH_Index
	
*************************  ADD CORRECTION LINES HERE ***************************
	
	compress
	save "${hfc_temp}/BF_F2F_Household_Correct.dta", replace

* -------------	
* End of dofile
