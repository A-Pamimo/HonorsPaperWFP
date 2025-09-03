/* *************************************************************************** *
*						WFP RAM-N rCARI Validation Study - Ecuador 			   * 
*																 			   *
*  PURPOSE:  			Prepare overall sample list 						   *
*  AUTHOR: 				Nicole Wu (nicole.wu@wfp.org)						   *
*  DATE:  				Jul 24, 2023										   *
*  LATEST UPDATE: 															   *
*		  																	   *
********************************************************************************

					
	** REQUIRES:	${sample}/Ecuador_Sample_Merge.xlsx
					
	** CREATES:		${sample}/Ecuador_Sample_Merge.dta

	** NOTES:		

********************************************************************************
*							PART 1: Prepare Sample List
*******************************************************************************/
	
	cap log close 
	
	// set log
	loc cdate: di %td_CCYY_NN_DD date(c(current_date), "DMY")
	loc cdate = subinstr(trim("`cdate'"), " " , "", .)
	log using "${d_log}/ed00_sample_prep_`cdate'.smcl", replace
	di `cdate'
	
	import excel "${sample}/Ecuador_Sample_Merge.xlsx", sheet("Sheet1") 	///
				 firstrow clear
	
local sample_var ADMIN1 ADMIN3Name ADMIN5Name Modality_Type Length_Type ///
				 Gender Marital_Status Education HHDisable
				 
foreach var of local sample_var {
	replace `var' = strproper(strtrim(`var'))		// format proper cases
    encode  `var', gen(`var'_byte)
	drop 	`var'
	ren		`var'_byte `var'
    }

********************************************************************************
*							PART 2: Organize Sample Variables
*******************************************************************************/

	ren Modality_Type 	Assign_Modality
	ren Length_Type		Assign_Length
	ren ADMIN1			Geo_Admin1
	ren ADMIN3Name		Geo_Admin3
	ren ADMIN5Name		Geo_Admin5

	ren	   uid HHID
	order  Phase, a(HHID)
	order  Assign_Modality Assign_Length Geo_Admin*, a(Phase)
	order  Gender, b(Age)
	
	** CORRECT VALUES - TO DISCUSS WITH ALIRAH // MISSING VALUES? WHY
	replace Age = . if Age > 100
	
	** recode marital status
	recode 	Marital_Status (1 = 2) (2 = 4) (3 = 6) (4 = 1) (5 = 3) (6 = 5), gen(Marital)
	drop 	Marital_Status
	ren		Marital 	Marital_Status
	order	Marital_Status, a(Age)
	
	** check duplicate IDs
	gen Index = _n
	duplicates tag HHID if Phase == 1, generate(Dup_1)
	duplicates tag HHID if Phase == 2, generate(Dup_2)
	duplicates tag HHID, generate(Dup)
	
	tab Dup_1 // No duplicates within Phase 1
	tab Dup_2 // No duplicates within Phase 2
	tab Dup	  // 125 pairs of duplicates cross two phases
	
/*	ieduplicates HHID using "${note}/Ecuador_Sample_DuplicateID_New_`cdate'.xlsx", 		///
	keepvar(Phase Assign_Modality Assign_Length Geo_Admin1 Geo_Admin3 Geo_Admin5) ///
					  uniquevars(Index) nodaily force 
*/
	*** Systematic correction on duplicated ID cross phases
	*** Correct IDs on phase 2 since they were generated later 
	*** Naming convention ECU0xxxx to ECA0xxxx
	
	gen HHID_Correct = substr(HHID, 1, 2) + "A" + substr(HHID, 4, .) ///
					   if Phase == 2 & Dup == 1
	replace HHID = HHID_Correct if Phase == 2 & Dup == 1	// 125 changes yes
	
	duplicates tag HHID, generate(Dup_Updated)
	drop Index Dup_1 Dup_2 Dup Dup_Updated HHID_Correct
	
********************************************************************************
*							PART 3: Label Sample Variables
*******************************************************************************/
	
	label def gender_l  1 "Female" 2 "Male" 3 "Other"
	label val Gender 	gender_l
	
	label def marital_l 1 "Single" 2 "Married" 3 "Free Union" ///
						4 "Divorced" 5 "Widower" 6 "Other" 
	label val Marital_Status 	marital_l

	label def edu_l 	1 "Nsnc" 2 "Primary" 3 "Secondary" 4 "Advanced"
	label val Education edu_l
	
	compress
	save  "${sample}/Ecuador_Sample_Merge.dta", replace
	export excel using "${sample}/Ecuador_Sample_Merge_CorrectedID.xls", replace

* -------------	
* End of dofile
