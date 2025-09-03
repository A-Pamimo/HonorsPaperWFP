/* *************************************************************************** *
*						WFP RAM-N rCARI Validation Study - CAR 			   	   * 
*																 			   *
*  PURPOSE:  			Correct field errors for Remote sample				   *
*  AUTHOR: 				Nicole Wu (nicole.wu@wfp.org)						   *
*  DATE:  				Aug 14, 2023										   *
*  LATEST UPDATE: 															   *
*		  																	   *
********************************************************************************

					
	** REQUIRES:	${d_raw}/CAR_RM_Household_Raw_`cdate'.csv
					
	** CREATES:		${d_temp}/CAR_RM_Household_Correct_`cdate'.dta
			
	** NOTES:		
					
					Attempt level dataset -> Household level
					1. Best survey outcome per household
					2. Keep only the best obs for each household
					3. Drop duplicates when answered the last survey question
					4. Attrition analysis (adding listing information? or do it 
					   later)
					   
					_`cdate' removed on Sep 18 when data collection was done

********************************************************************************
*					PART 1: Load Household Data and Correct Errors
*******************************************************************************/
	
	cap log close 
	
	// set log
	loc cdate: di %td_CCYY_NN_DD date(c(current_date), "DMY")
	loc cdate = subinstr(trim("`cdate'"), " " , "", .)
	log using "${d_log}/cd00c_rm_correct_`cdate'.smcl", replace
	di `cdate'
	
* load dataset
* ---------------	
	use "${d_raw}/CAR_RM_Household_Raw.dta", clear
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
	drop if ___uuid == "7b2b1308-4a44-4e14-98e5-2c30e623a98a"
	drop if ___uuid == "4d1e8624-ba7f-4cb7-911c-d57c16928df2"
	
	* no phone, no assign phone, yes coverage, remote 
	drop if ___uuid == "1d641fc0-de45-4aa9-8bef-2062855daab4"
	
	** check duplicates
	duplicates tag HHID, generate(Dup)
	
	** Recode for best outcome - combining the consent and availability
	recode RESPpart (0=6) (1=1) (2=7) (3=4) (4=5) (999=8), gen(Outcome_Order)
	replace Outcome_Order = 2 if Outcome_Order == 1 & RESPAvailable == 2
	replace Outcome_Order = 3 if Outcome_Order == 1 & RESPAvailable == 0
	
	label def Outcome_L 1 "Agreed & Available" 2 "Agreed & Later" ///
						3 "Agreed & Not Available" 				  ///
						4 "Did not connect/network issues"		  ///
						5 "Invalid or inactive number"  		  ///
						6 "Not answer/busy" 7 "Refused" 8 "Other"
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

	ieduplicates HHID using "${note}/CAR_RM_DuplicateID_`cdate'.xlsx", 		///
					  keepvar(today EnuName_Display RESPpart RESPAvailable RESPAge RESPSex HHSize) 			///
					  uniquevars(___uuid) nodaily force 
				  
*	isid   HHID
	
	mmerge HHID using "${sample}/CAR_Sample_Merge.dta", type(1:1) uname(S_)
	
	tab S_Assign_Modality Temp_Complete
	
	** keep only Remote sample for attrition analysis
	drop if S_Assign_Modality == 1
	gen Attrition = (_merge == 2)
	label val Attrition sampleYN
	
	/*
	dtable i.S_Assign_Length i.S_Geo_Admin1 i.S_Geo_Admin2 i.S_Geo_Admin3    ///
		   i.S_Geo_Admin5 S_age i.S_relationship i.S_hh_status 				 ///
		   i.S_hh_head_sex i.S_hh_head_marital S_hh_head_educ S_hh_size 	 ///
		   S_mem_lessthan15 S_mem_greaterthan60 i.S_mem_disability 			 ///
		   i.S_house_type S_area_house i.S_roofing_material_house 			 ///
		   i.S_floor_material_house, by(Attrition, tests) 					 ///
		   title(CAR rCARI Validation Remote Attrition Analysis)  			 ///
		   export(${d_tex_tab}/CAR_rCARI_RM_Attrition.docx, replace) 
	
	*/
	drop if Attrition == 1
	
	** check ID and drop empty vars and obs
 	isid HHID	 				// check unique identifier
	
	// check again with the real survey data
	ren ___index HH_Index
	
	** Correct missing expenditure
	tempfile master expenditure
	save `master'
	
	use "${d_raw}/RM_Expenditure_Missing_20230911.dta", clear
	recode RESPpart (0=3) (1=1) (2=4) (3=2), gen(Outcome_Order)
	
	label def Outcome_L 1 "Agreed" 2 "Did not connect/network issues"  ///
						3 "Not answer/busy" 4 "Refused" 
	label val Outcome_Order Outcome_L
	duplicates tag HHID, generate(Dup)
	
	bysort HHID: egen Survey_Outcome = min(Outcome_Order) if Dup >= 1
	replace Survey_Outcome = Outcome_Order if Dup == 0
	label val Survey_Outcome Outcome_L
	
	gen HH_Final = (Outcome_Order == Survey_Outcome)
	egen HH_TAG = tag(HHID) if HH_Final == 1
	replace Survey_Outcome = . if HH_TAG == 0 

	keep if Survey_Outcome == 1
	isid HHID
	keep HHID HHExpStap_MNCRD_7D-HHExpNFEduMedCloth_GiftAid_6M
	
	** rename for merge 
	ren HHExp* E_*
	save `expenditure'
	
	use `master'
	mmerge HHID using `expenditure' , type(1:1)
	
	local exp_var Stap_MNCRD_7D Stap_GiftAid_7D Stap_Own_7D Pro_MNCRD_7D  ///
		  Pro_GiftAid_7D Pro_Own_7D FruVeg_MNCRD_7D FruVeg_GiftAid_7D 	  ///
		  FruVeg_Own_7D FOther_MNCRD_7D FOther_GiftAid_7D FOther_Own_7D	  ///
		  NF_GiftAid_YN1M NFHyg_MNCRD_1M NFHyg_GiftAid_1M 				  ///
		  NFTranspPh_MNCRD_1M NFTranspPh_GiftAid_1M NFUtilities_MNCRD_1M  ///
		  NFUtilities_GiftAid_1M NFAlcTobac_MNCRD_1M NFAlcTobac_GiftAid_1M ///
		  NFEduMedCloth_MNCRD_6M NFEduMedCloth_GiftAid_6M
	
foreach var of local exp_var {
	replace HHExp`var' = E_`var' if !mi(E_`var')
	}
	
	drop E_* _merge
	
*************************  ADD CORRECTION LINES HERE ***************************
	
	save "${d_temp}/CAR_RM_Household_Correct.dta", replace
