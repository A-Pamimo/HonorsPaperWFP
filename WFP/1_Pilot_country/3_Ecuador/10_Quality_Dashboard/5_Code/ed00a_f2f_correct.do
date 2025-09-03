/* *************************************************************************** *
*						WFP RAM-N rCARI Validation Study - Ecuador 			   * 
*																 			   *
*  PURPOSE:  			Correct field errors for F2F Household 				   *
*  AUTHOR: 				Nicole Wu (nicole.wu@wfp.org)						   *
*  DATE:  				Jun 18, 2023										   *
*  LATEST UPDATE: 		Jun 19, 2023										   *
*		  																	   *
********************************************************************************

					
	** REQUIRES:	${d_raw}/Ecuador_F2F_Household_Raw_`cdate'.csv
					
	** CREATES:		${d_temp}/Ecuador_F2F_Household_Correct_`cdate'.dta

	** NOTES:		_`cdate' on Jul 20 when data collection finished

********************************************************************************
*					PART 1: Load Household Data and Correct Errors
*******************************************************************************/
	
	cap log close 
	
	// set log
	loc cdate: di %td_CCYY_NN_DD date(c(current_date), "DMY")
	loc cdate = subinstr(trim("`cdate'"), " " , "", .)
	log using "${d_log}/ed00a_f2f_correct_`cdate'.smcl", replace
	di `cdate'
	
* load dataset
* ---------------	
	use "${d_raw}/Ecuador_F2F_Household_Raw.dta", clear
	compress
	
	* basic quality checks and formating
	ds, has(type string) 
	** remove unnecessary blanks in string and adjust the proper cases
	local strvars "`r(varlist)'"
foreach var of local strvars {
    replace `var' = strtrim(`var')
	replace `var' = "" if `var' == " "
    }
	
	** temp
	replace HHID = HHID_manual if mi(HHID)		// 19 this is temporary
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
	gen Temp_Complete = (!mi(Harm))
	keep if Temp_Complete == 1

/*	*	iecompdup 	 HHID, id() didifference
	ieduplicates HHID using "${note}/Ecuador_F2F_DuplicateID_`cdate'.xlsx", 		///
				 keepvar(EnuName_Display RESPAge RESPSex 	///
				 HHSize) uniquevars(___uuid) nodaily force 
*/
	** Dup 1
	drop if ___uuid == "d2012955-cf1e-48ee-bdda-4d8dce28d5ee"
	** Dup 2
	replace HHID = "ECU0190750" if ___uuid == "57d49e89-cc4e-4aa2-b01b-fef4e1ed2fe6"
	** Dup 3
	drop if ___uuid == "87bd5280-8278-4afe-b40e-f5988a7905b3"
	** Dup 4
	drop if ___uuid == "ddec9d93-5ff8-469b-a89c-5ff69c05e8a0"
	** Dup 5
	drop if ___uuid == "ce01ec22-a8c7-4239-9b78-f65b64962be9"
	** Dup 6
	drop if ___uuid == "94b12b58-099c-490a-a338-38fe94c0872a"
	drop if ___uuid == "614448c3-4f46-4a7a-b9e7-0843e1031cc4"
	** Dup 7
	drop if ___uuid == "00f31eb6-282f-4aaa-88e9-2ca5bf8fcfb3"
	drop if ___uuid == "2376096a-ae83-4465-b38c-62aa25017bd5"
	** Dup 8
	drop if ___uuid == "5199b75b-7cd6-4986-921d-15cb5909c0e3"
	drop if ___uuid == "d7b33ab9-df1a-43f2-8717-8ad502ff11ce"
	** Dup 9: length changed so drop
	drop if ___uuid == "cc38c82a-8439-472b-9145-4479a306f7c5"
	** Dup 10
	drop if ___uuid == "5e9e28c9-651f-436f-a56a-ff85cf87e3f6"
	** Dup 11
	drop if ___uuid == "5d2faf52-1ba2-49a8-aed6-59d03b8af5e8"
	
	duplicates tag HHID, generate(Dup_Correct)
	
	mmerge HHID using "${sample}/Ecuador_Sample_Merge.dta", type(1:1) uname(S_)
	
	drop if _merge == 1 // ECU312470 not in the sample list - temp drop
	
	tab S_Assign_Modality Temp_Complete
	tab S_Phase if Temp_Complete == 1
	
	** keep only F2F sample for attrition analysis
	drop if S_Assign_Modality == 2
	gen Attrition = (_merge == 2)
	label val Attrition SampleYN
	
	** TABLE: Attrition in F2F Sample
	
 /*	dtable i.S_Assign_Length i.S_Geo_Admin1 i.S_Geo_Admin3 i.S_Geo_Admin5 	///
		   i.S_Gender S_Age i.S_Marital_Status S_HHSize S_Num_Under15 	  	///
		   S_Num_Over60 i.S_Education i.S_HHDisable, 					  	///
		   by(Attrition, tests) 											///
		   title(Ecuador rCARI Validation F2F Attrition Analysis)  			///
		   export(${d_tex_tab}/Ecuador_rCARI_F2F_Attrition.docx, replace) 
*/
	drop if Attrition == 1
	drop Dup_Correct _merge
	
	isid HHID	 				// check unique identifier
	// check again with the real survey data
	ren ___index	HH_Index
	
*************************  ADD CORRECTION LINES HERE ***************************
	
	compress
	save "${d_temp}/Ecuador_F2F_Household_Correct.dta", replace

* -------------	
* End of dofile
