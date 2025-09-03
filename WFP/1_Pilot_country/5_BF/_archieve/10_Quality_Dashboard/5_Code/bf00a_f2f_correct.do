/* *************************************************************************** *
*						WFP RAM-N rCARI Validation Study - CAR 			       * 
*																 			   *
*  PURPOSE:  			Correct field errors for F2F Household 				   *
*  AUTHOR: 				Nicole Wu (nicole.wu@wfp.org)						   *
*  DATE:  				Aug 14, 2023										   *
*  LATEST UPDATE: 												   			   *
*		  																	   *
********************************************************************************

					
	** REQUIRES:	${d_raw}/CAR_F2F_Household_Raw_`cdate'.csv
					
	** CREATES:		${d_temp}/CAR_F2F_Household_Correct_`cdate'.dta

	** NOTES:		_`cdate' removed on Sep 18 when data collection was done

********************************************************************************
*					PART 1: Load Household Data and Correct Errors
*******************************************************************************/
	
	cap log close 
	
	// set log
	loc cdate: di %td_CCYY_NN_DD date(c(current_date), "DMY")
	loc cdate = subinstr(trim("`cdate'"), " " , "", .)
	log using "${d_log}/cd00a_f2f_correct_`cdate'.smcl", replace
	di `cdate'
	
* load dataset
* ---------------	
	use "${d_raw}/BKF_F2F_Household_Raw.dta", clear
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
	** temp
	* replace HHID = HHID_manual if mi(HHID)		// 19 this is temporary
	* drop if sampleYN == 0
	
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
	ieduplicates HHID using "${note}/BKF_F2F_DuplicateID_`cdate'.xlsx", 		///
				 keepvar(today EnuName_Display RESPAge RESPSex 	///
				 HHSize) uniquevars(___uuid) nodaily force 

	mmerge HHID using "${sample}/BKF_Sample_Merge.dta", type(1:1) uname(S_)
	
	drop if _merge == 1
	
	tab S_Assign_Modality Temp_Complete
	
	** keep only F2F sample for attrition analysis
	drop if S_Assign_Modality == 2
	gen Attrition = (_merge == 2)
	label val Attrition SampleYN
	
	/** TABLE: Attrition in F2F Sample
	dtable i.S_Assign_Length i.S_Geo_Admin1 i.S_Geo_Admin2 i.S_Geo_Admin3    ///
		   i.S_Geo_Admin5 S_age i.S_relationship i.S_hh_status 				 ///
		   i.S_hh_head_sex i.S_hh_head_marital S_hh_head_educ S_hh_size 	 ///
		   S_mem_lessthan15 S_mem_greaterthan60 i.S_mem_disability 			 ///
		   i.S_house_type S_area_house i.S_roofing_material_house 			 ///
		   i.S_floor_material_house, by(Attrition, tests) 					 ///
		   title(CAR rCARI Validation F2F Attrition Analysis)  				 ///
		   export(${d_tex_tab}/CAR_rCARI_F2F_Attrition.docx, replace) 
	*/
	
	drop if Attrition == 1
	
	isid HHID	 				// check unique identifier
	// check again with the real survey data
	ren ___index	HH_Index
	
*************************  ADD CORRECTION LINES HERE ***************************
	
	compress
	save "${d_temp}/BKF_F2F_Household_Correct.dta", replace

* -------------	
* End of dofile
