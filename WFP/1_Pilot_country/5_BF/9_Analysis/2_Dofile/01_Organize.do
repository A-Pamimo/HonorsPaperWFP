/* *************************************************************************** *
*					WFP APP-FA rCARI Validation Study - BF 					   * 
*																 			   *
*  PURPOSE:  			Organize BF dataset for analysis 					   *
*  AUTHOR: 				Nicole Wu (yue.wu@berkeley.edu)						   *
*  DATE:  				Oct 28, 2024										   *
*  LATEST UPDATE: 		Oct 29, 2024										   *
*		  																	   *
********************************************************************************
					
	** REQUIRES:	
	
	** CREATES:		
					
	** NOTES:		

********************************************************************************
*								PART 1: Set Log
*******************************************************************************/

	loc cdate: di %td_CCYY_NN_DD date(c(current_date), "DMY")
	loc cdate = subinstr(trim("`cdate'"), " " , "", .)
	di `cdate'	

	tempfile smallholder
	import excel "${bf_docs}/rCARI_Income_Source_Other.xlsx", ///
	sheet("Sheet1") firstrow clear
	encode Income_Recode, gen(Income_Recode_Cat)
	keep HHID HHIncFirst_oth_Eng HHIncFirst_SmallAg Income_Recode_Cat
	replace HHIncFirst_SmallAg = 0 if mi(HHIncFirst_SmallAg)
	save `smallholder'

	use "${bf_dta}/BF_Full_Household_Analysis.dta", replace
	compress 
	
********************************************************************************
*						PART 2: Create variables
*******************************************************************************/
	
	*********************** OUTCOME VARIABLES ************************
	* FCS
	tab FCSCat28, gen(FCG_)
	ren FCG_1	FCG_Poor
	ren FCG_2	FCG_Borderline
	ren FCG_3	FCG_Acceptable
	
	* Correct FC Groups
	gen 	FCG_Country = cond(FCS <= 21, 1, cond(FCS <= 35, 2, 3))
	label val FCG_Country FCSCat
	
	tab FCG_Country, gen(FCG_Country_)
	ren FCG_Country_1	FCG_Country_Poor
	ren FCG_Country_2	FCG_Country_Borderline
	ren FCG_Country_3	FCG_Country_Acceptable
	
	* rCSI
	gen rCSI_Group = cond(rCSI <= 3, 1, cond(rCSI <= 18, 2, 3)) if Completion == 1
	tab rCSI_Group, gen(rCSI_Phase)
	ren rCSI_Phase3 rCSI_Phase3_5
	
	* FCS + rCSI - Current Status
	tab FCS_4pt_CARI, gen(FCS_rCSI_4pt_)
	
	gen 	HHIncFirst_Accept_Re = inlist(HHIncFirst_SRi, 1, 2, 5, 13, 15)
	gen		HHIncFirst_Border_Re = inlist(HHIncFirst_SRi, 3, 4, 6, 11, 12, 14)
	gen 	HHIncFirst_Poor_Re   = inlist(HHIncFirst_SRi, 0, 7, 8, 9, 10)
	
	merge 1:1 HHID using `smallholder'
	drop _merge

	
	replace HHIncFirst_Accept_Re = HHIncFirst_Accept if HHIncFirst_SRi == 999 & HHIncFirst_SmallAg != 1
	replace HHIncFirst_Border_Re = HHIncFirst_Border if HHIncFirst_SRi == 999 & HHIncFirst_SmallAg != 1
	replace HHIncFirst_Poor_Re   = HHIncFirst_Poor   if HHIncFirst_SRi == 999 & HHIncFirst_SmallAg != 1
	
	replace HHIncFirst_Border_Re = 1 if HHIncFirst_SmallAg == 1 & HHIncFirst_SRi == 999

	replace HHIncFirst_Accept_Re = 1 if HHIncFirst_SRi == 999 & Income_Recode_Cat == 3
	replace HHIncFirst_Border_Re = 1 if HHIncFirst_SRi == 999 & Income_Recode_Cat == 1
	replace HHIncFirst_Poor_Re   = 1 if HHIncFirst_SRi == 999 & Income_Recode_Cat == 2
	
	gen CARI_Inc_Re = . 	 
	replace CARI_Inc_Re = 1 if HHIncFirst_Accept_Re == 1 & inlist(HHIncChg, 0, 1)
	replace CARI_Inc_Re = 2 if HHIncFirst_Accept_Re == 1 & inlist(HHIncChg, 2, 3, 4)
	replace CARI_Inc_Re = 2 if HHIncFirst_Border_Re == 1 & inlist(HHIncChg, 0, 1)
	replace CARI_Inc_Re = 3 if HHIncFirst_Border_Re == 1 & inlist(HHIncChg, 2, 3, 4)
	replace CARI_Inc_Re = 4 if HHIncFirst_Poor_Re   == 1
	tab CARI_Inc_Re, gen(CARI_Inc_Re_)
	
	gen CARI_Inc_Num = CARI_Inc
	clonevar CARI_Inc_Re_Num = CARI_Inc_Re
	

	drop HHInc_Change_None HHInc_Increase HHInc_Reduce25 	///
		 HHInc_Reduce50 HHInc_Reduce50More
	
	tab HHIncChg, gen(HHInc_)
	ren HHInc_1	HHInc_Change_None
	ren HHInc_2	HHInc_Increase
	ren HHInc_3	HHInc_Reduce25
	ren HHInc_4	HHInc_Reduce50
	ren HHInc_5	HHInc_Reduce50More
	
	gen 	HHIncome_3pt = 1 if HHIncFirst_Accept == 1
	replace HHIncome_3pt = 2 if HHIncFirst_Border == 1
	replace HHIncome_3pt = 3 if HHIncFirst_Poor   == 1 | HHIncNb == 0
	label def Income_3pt 1 "Regular employment/income" ///
						 2 "Irregular employment/income" ///
						 3 "No income"
	label val HHIncome_3pt Income_3pt
	
	gen 	HHIncome_3pt_Re = 1 if HHIncFirst_Accept_Re == 1
	replace HHIncome_3pt_Re = 2 if HHIncFirst_Border_Re == 1
	replace HHIncome_3pt_Re = 3 if HHIncFirst_Poor_Re   == 1
	label val HHIncome_3pt_Re Income_3pt
	
	gen 	HHIncChg_3pt = 1 if HHIncChg == 1
	replace HHIncChg_3pt = 2 if HHIncChg == 0
	replace HHIncChg_3pt = 3 if inlist(HHIncChg, 2,3,4)
	
	label def Change_3pt 1 "Increased income" 2 "No change" ///
						 3 "Reduced income"
	label val HHIncChg_3pt Change_3pt
	
	* LCS used different strategies by countries 
	local lcs_var Lcs_stress_DomAsset Lcs_stress_HealthEdu Lcs_stress_Saving Lcs_stress_BorrowCash Lcs_crisis_ProdAssets Lcs_crisis_DomMigration Lcs_crisis_ChildWork Lcs_em_ResAsset Lcs_em_Begged Lcs_em_FemAnimal
	
foreach var of local lcs_var { 
	gen `var'_yn = (`var' == 20 | `var' == 30) if !mi(`var')
	label var `var'_yn "Used `: var label `var''"
}
	
	* FES
	tab FES_Cat, gen(FES_Cat_)

	** CARI rCARI
	gen 	CARI_rCARI = HH_Vul_FES 	if Modality == 1 
	replace CARI_rCARI = HH_Vul_Income 	if Modality == 2
	
	tab CARI_FES_Cat, gen(CARI_FES_Cat)
	tab CARI_Inc_Cat, gen(rCARI_Inc_Cat)
	
	* real CARI vs. real rCARI
forval i = 1/4 {
	gen 	CARI_rCARI_`i' = CARI_FES_Cat`i'  if Modality == 1
	replace CARI_rCARI_`i' = rCARI_Inc_Cat`i' if Modality == 2
}
	
	gen CARI_FES_Bad  = (CARI_FES_Cat3  == 1 | CARI_FES_Cat4  == 1) if Completion == 1
	gen rCARI_Inc_Bad = (rCARI_Inc_Cat3 == 1 | rCARI_Inc_Cat4 == 1) if Completion == 1

	gen CARI_FES_Good  = (CARI_FES_Cat1  == 1 | CARI_FES_Cat2  == 1) if Completion == 1
	gen rCARI_Inc_Good = (rCARI_Inc_Cat1 == 1 | rCARI_Inc_Cat2 == 1) if Completion == 1
	
	gen EXP_pctile = .

    xtile temp_EXP_pctile = HHExpTotal if Modality == 1 & Form == 1, n(4)
    replace EXP_pctile = temp_EXP_pctile if Modality == 1 & Form == 1
    drop temp_EXP_pctile

	clonevar EXP_pctile_Cat = EXP_pctile
	tab EXP_pctile_Cat, gen(EXP_pctile_Cat_)
	
	********************* LISTING VARIABLES FOR BF ***********************
	
	gen S_HHHResp		= (S_relationship == 1) 
	gen S_HHDisplaced 	= (S_hh_status 	  == 2) 
	gen S_HHHFemale		= (S_hh_head_sex  == 0) 
	gen S_HHHMarried	= (S_hh_head_marital == 1) 
	
	gen 	S_HHCrowding	= S_hh_size/S_area_house 
	sum 	S_HHCrowding
	replace S_HHCrowding  = `r(max)' if mi(S_HHCrowding) 
	
	gen S_HHBadRoof  = inlist(S_roofing_material_house, 1,2,3,4,5,6) 
	gen S_HHBadFloor = inlist(S_floor_material_house, 1,2,3)
	
	****************** RECATEGORIZATION OF BF rCARI *********************
	* [FCS_4pt_CARI_Re] FCS Groups to country specific cut-off point 

	recode  FCG_Country (1 = 4) (2 = 3) (3 = 1), gen(FCS_4pt_CARI_Country)
	replace FCS_4pt_CARI_Country = 2 if FCG_Country == 3 & rCSI >= 4
	
	** CARI based on FES
	gen CARI_FES_Raw_Country = (FCS_4pt_CARI_Country + CC_FES_Cat)/2
	gen CARI_FES_Cat_Country = round(CARI_FES_Raw_Country)
	tab CARI_FES_Cat_Country, gen(CARI_FES_Cat_Country)
	
	* rCARI based on Income
	gen CARI_Inc_Raw_Country = (FCS_4pt_CARI_Country + CC_Inc_Cat)/2
	gen CARI_Inc_Cat_Country = round(CARI_Inc_Raw_Country)
	tab CARI_Inc_Cat_Country, gen(CARI_Inc_Cat_Country)

	* Income source recategorized smallholder agriculture
	gen CC_Inc_Cat_Re   = (CARI_Inc_Re + LCS_Cat)/2	// no round here
	gen CARI_Inc_Raw_Re = (FCS_4pt_CARI + CC_Inc_Cat_Re)/2
	gen CARI_Inc_Cat_Re = round(CARI_Inc_Raw_Re)
	tab CARI_Inc_Cat_Re, gen(CARI_Inc_Cat_Re)
	
	* rCARI based on Income
	gen CARI_Inc_Raw_Country_Re = (FCS_4pt_CARI_Country + CC_Inc_Cat_Re)/2
	gen CARI_Inc_Cat_Country_Re = round(CARI_Inc_Raw_Country_Re)
	tab CARI_Inc_Cat_Country_Re, gen(CARI_Inc_Cat_Country_Re)
	
	* real CARI vs. real rCARI after regrouping
forval i = 1/4 {
	gen 	CARI_rCARI_Country_Re_`i' = CARI_FES_Cat_Country`i'  if Modality == 1
	replace CARI_rCARI_Country_Re_`i' = CARI_Inc_Cat_Country_Re`i' if Modality == 2
}


********************************************************************************
*						PART 3: Label variables
********************************************************************************
	
*	label val CARI_Inc_Re FS_CARI

	order CARI_Inc_* HHIncFirst_Accept HHIncFirst_Border HHIncFirst_Poor ///
		  HHInc_Change_None HHInc_Increase HHInc_Reduce25 HHInc_Reduce50 ///
		  HHInc_Reduce50More, a(FES_Cat_4)
	
	label def exp_quartile  1 "Quartile 1 (Lowest)" ///
							2 "Quartile 2" ///
							3 "Quartile 3" ///
							4 "Quartile 4 (Highest)"
	label val EXP_pctile_Cat exp_quartile
	
	label def fes_secure_l 	1 "Food secure with FES"	///
							0 "Food insecure with FES"
	label val CARI_FES_Good fes_secure_l
	
	label def inc_secure_l  1 "Food secure with Income"	///
							0 "Food insecure with Income"
	label val rCARI_Inc_Good inc_secure_l
	
	label var FCG_Poor			"FCS: Poor"
	label var FCG_Borderline	"FCS: Borderline"
	label var FCG_Acceptable	"FCS: Acceptable"
	label var FCG_Country 		"FCS Groups (Country Specific)"
	
	label var rCSI_Group		"rCSI Group"
	label var rCSI_Phase1		"rCSI: Low"
	label var rCSI_Phase2		"rCSI: Median"
	label var rCSI_Phase3_5		"rCSI: Severe"
	
	label var FCS_rCSI_4pt_1	"FCS & rCSI: Acceptable"
	label var FCS_rCSI_4pt_2	"FCS & rCSI: Acceptable with reduced coping"
	label var FCS_rCSI_4pt_3	"FCS & rCSI: Borderline"
	label var FCS_rCSI_4pt_4	"FCS & rCSI: Poor"
	
	label var CARI_Inc_1		"Income: Regular and Unchanged/Increasing"
	label var CARI_Inc_2		"Income: Regular and Reduced OR Irregular and Unchanged/Increasing"
	label var CARI_Inc_3		"Income: Irregular and Reduced"
	label var CARI_Inc_4		"Income: No income sources"
	
	label var CARI_Inc_Re_1		"Income: Regular and Unchanged/Increasing"
	label var CARI_Inc_Re_2		"Income: Regular and Reduced OR Irregular and Unchanged/Increasing"
	label var CARI_Inc_Re_3		"Income: Irregular and Reduced"
	label var CARI_Inc_Re_4		"Income: No income sources"

	label var FES_Cat_1			"FES < 50 percent"
	label var FES_Cat_2			"FES: 50-65 percent"
	label var FES_Cat_3			"FES: 65-75 percent"
	label var FES_Cat_4			"FES: >= 75 percent"
	
	label var HHInc_Change_None		"Income Change: None"
	label var HHInc_Increase		"Income Change: Increase"
	label var HHInc_Reduce25		"Income Change: Reduced < 25 percent"
	label var HHInc_Reduce50		"Income Change: Reduced 25-50 percent"
	label var HHInc_Reduce50More	"Income Change: Reduced 50+ percent"
	
	label var rCARI_Inc_Cat1	"Food Secure"
	label var rCARI_Inc_Cat2	"Marginally Food Secure"
	label var rCARI_Inc_Cat3	"Moderately Food Insecure"
	label var rCARI_Inc_Cat4	"Severely Food Insecure"
	label var rCARI_Inc_Bad		"Food Insecure Group"
	label var rCARI_Inc_Good	"Food Secure with Income"
	
	label var CARI_FES_Cat1		"Food Secure"
	label var CARI_FES_Cat2		"Marginally Food Secure"
	label var CARI_FES_Cat3		"Moderately Food Insecure"
	label var CARI_FES_Cat4		"Severely Food Insecure"
	label var CARI_FES_Bad		"Food Insecure Group"
	label var CARI_FES_Good		"Food Secure with FES"
	
	label var CARI_rCARI_1		"Food Secure"
	label var CARI_rCARI_2		"Marginally Food Secure"
	label var CARI_rCARI_3		"Moderately Food Insecure"
	label var CARI_rCARI_4		"Severely Food Insecure"
	label var CARI_rCARI 		"Food Insecure Group"
	
	label var S_HHHResp			"Household head is the respondent"
	label var S_HHDisplaced		"Displaced household"
	label var S_HHHFemale		"Female Household Head"
	label var S_HHHMarried		"Married Household Head"
	label var S_HHCrowding		"Household Crowding Index"
	label var S_HHBadRoof		"Household has impoverished roof"
	label var S_HHBadFloor		"Household has impoverished floor"
	
********************************************************************************
*						PART 3: Check and export variables
*******************************************************************************/
	
	compress
	save "${bf_output}/ALL_BF_Household_Analysis.dta", replace
	
	keep if Completion == 1
	compress
	save 	 	"${bf_output}/Complete_BF_Household_Analysis.dta", replace
	save 		"${bf_output}/Complete_BF_Household_Analysis.sav", replace
