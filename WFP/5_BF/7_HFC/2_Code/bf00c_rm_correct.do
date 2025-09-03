/* *************************************************************************** *
*					WFP APP-FA rCARI Validation Study - BF 					   * 
*																 			   *
*  PURPOSE:  			Correct field errors for Remote sample				   *
*  AUTHOR: 				Nicole Wu (yue.wu@berkeley.edu)						   *
*  DATE:  				Oct 28, 2024										   *
*  LATEST UPDATE: 		Oct 29, 2024										   *
*		  																	   *
********************************************************************************

					
	** REQUIRES:	${hfc_raw}/BF_RM_Household_Raw.dta
					${sample}/BF_Sample_Merge.dta
					
	** CREATES:		${hfc_note}/BF_RM_DuplicateID_`cdate'.xlsx
					${hfc_temp}/BF_RM_Household_Correct.dta
			
	** NOTES:		Attempt level dataset -> Household level
					1. Best survey outcome per household
					2. Keep only the best obs for each household
					3. Drop duplicates when answered the last survey question
					4. Attrition analysis (adding listing information? or do it 
					   later)

********************************************************************************
*					PART 1: Load Household Data and Correct Errors
*******************************************************************************/
	
	loc cdate: di %td_CCYY_NN_DD date(c(current_date), "DMY")
	loc cdate = subinstr(trim("`cdate'"), " " , "", .)
	
* load dataset
* ---------------	
	use "${hfc_raw}/BF_RM_Household_Raw.dta", clear
	compress
	
	* basic quality checks and formating
	ds, has(type string) 
	** remove unnecessary blanks in string and adjust the proper cases
	local strvars "`r(varlist)'"
foreach var of local strvars {
    replace `var' = strtrim(`var')
    }

	** temp
	replace HHID = HHID_manual if mi(HHID)		// this is temporary
	drop if mi(HHID)
	
	*	isid HHID 
*	drop if ___uuid == ""
	
	** check duplicates
	duplicates tag HHID, generate(Dup)
	
	** Recode for best outcome - combining the consent and availability
	recode RESPpart (0=6) (1=1) (2=4) (3=5) (999=7), gen(Outcome_Order)
	replace Outcome_Order = 2 if Outcome_Order == 1 & RESPAvailable == 2
	replace Outcome_Order = 3 if Outcome_Order == 1 & RESPAvailable == 0
	
	label def Outcome_L 1 "Agreed & Available" 2 "Agreed & Later" ///
						3 "Agreed & Not Available" 				  ///
						4 "Did not connect/network issues"		  ///
						5 "Invalid or inactive number"  		  ///
						6 "Not answer/busy" 7 "Other"
	label val Outcome_Order Outcome_L
	
	bysort HHID: egen Survey_Outcome = min(Outcome_Order) if Dup >= 1
	replace Survey_Outcome = Outcome_Order if Dup == 0
	label val Survey_Outcome Outcome_L
	
	gen HH_Final = (Outcome_Order == Survey_Outcome)
	
	egen HH_TAG = tag(HHID) if HH_Final == 1
	
	replace Survey_Outcome = . if HH_TAG == 0 
		
	** create one consent variable 
	gen  Temp_Complete = !mi(HHRoofType)

	bysort HHID: gen Consent = (Survey_Outcome == 1) if !mi(Survey_Outcome)
	label val Consent sampleYN
	
	keep if Temp_Complete == 1

	ieduplicates HHID using "${hfc_note}/BF_RM_DuplicateID_`cdate'.xlsx", 		///
					  keepvar(today EnuName_Display RESPpart RESPAvailable RESPAge RESPSex HHSize) 			///
					  uniquevars(uuid) nodaily force notes(comment)
				  
*	isid   HHID
	
	mmerge HHID using "${sample}/BF_Sample_Merge.dta", type(1:1) uname(S_)
	tab S_Assign_Modality Temp_Complete
	
	** keep only Remote sample for attrition analysis
	drop if S_Assign_Modality == 1
	gen Attrition = (_merge == 2)
	label val Attrition sampleYN

	drop if Attrition == 1
	
	** check ID and drop empty vars and obs
 	isid HHID	 				// check unique identifier
	
	// check again with the real survey data
	ren index HH_Index
	
*************************  ADD CORRECTION LINES HERE ***************************
	
	save "${hfc_temp}/BF_RM_Household_Correct.dta", replace
