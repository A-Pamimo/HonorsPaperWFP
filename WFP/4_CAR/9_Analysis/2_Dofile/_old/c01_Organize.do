/* *************************************************************************** *
*					WFP RAM-N rCARI Validation Study - CAR 				   * 
*																 			   *
*  PURPOSE:  			Organize full dataset for analsysis 				   *
*  AUTHOR: 				Nicole Wu (nicole.wu@wfp.org)						   *
*  DATE:  				Sep 18, 2023										   *
*  LATEST UPDATE: 															   *
*		  																	   *
********************************************************************************
					
	** REQUIRES:	${dta}/CAR_Full_Household_Analysis.dta
					
	** CREATES:		
					
	** NOTES:		

********************************************************************************
*								PART 1: Set Log
*******************************************************************************/

	cap log close 
	
	// set log
	loc cdate: di %td_CCYY_NN_DD date(c(current_date), "DMY")
	loc cdate = subinstr(trim("`cdate'"), " " , "", .)
	log using "${logs}/m01_organize_`cdate'.smcl", replace
	di `cdate'	

	use "${dta}/CAR_Full_Household_Analysis.dta", replace
	compress 
	
	** 1 Survey Completion	
	eststo  clear
	estpost tabulate S_Assign_Modality Completion
	esttab using "${tex_tab}/CAR_rCARI_Completion.tex", 					///
		   cell("b(fmt(0)) rowpct(fmt(2))") unstack noobs modelwidth(15) 		///
		   collabels("Count" "Percent") nonumbers replace

	keep if Completion == 1
	
********************************************************************************
*						PART 2: Create variables
*******************************************************************************/
	
	gen 	CARI_rCARI = HH_Vul_FES 	if Modality == 1
	replace CARI_rCARI = HH_Vul_Income 	if Modality == 2
	
	tab FES_Cat, gen(FES_Cat_)
	
	tab CARI_FES_Cat, gen(CARI_FES_Cat)
	tab CARI_Inc_Cat, gen(rCARI_Inc_Cat)
	
	* real CARI vs. real rCARI
forval i = 1/4 {
	gen 	CARI_rCARI_`i' = CARI_FES_Cat`i'  if Modality == 1
	replace CARI_rCARI_`i' = rCARI_Inc_Cat`i' if Modality == 2
}
	
	gen CARI_FES_Bad  = (CARI_FES_Cat3  == 1 | CARI_FES_Cat4  == 1)
	gen rCARI_Inc_Bad = (rCARI_Inc_Cat3 == 1 | rCARI_Inc_Cat4 == 1)

	gen FCG_Accept = (FCSCat28 == 3)
	
********************************************************************************
*						PART 3: Label variables
*******************************************************************************/
	
	label val CARI_rCARI FCG_Accept YesNo
	
	label var CARI_Inc_1		"Income: Regular and Unchanged/Increasing"
	label var CARI_Inc_2		"Income: Regular and Reduced OR Irregular and Unchanged/Increasing"
	label var CARI_Inc_3		"Income: Irregular and Reduced"
	label var CARI_Inc_4		"Income: No income sources"
	
	label var FES_Cat_1			"FES: <50%"
	label var FES_Cat_2			"FES: 50-65%"
	label var FES_Cat_3			"FES: 65-75%"
	label var FES_Cat_4			"FES: >= 75%"
	
	label var rCARI_Inc_Cat1	"rCARI: Food Secure"
	label var rCARI_Inc_Cat2	"rCARI: Marginally Food Secure"
	label var rCARI_Inc_Cat3	"rCARI: Moderately Food Insecure"
	label var rCARI_Inc_Cat4	"rCARI: Severely Food Insecure"
	label var rCARI_Inc_Bad		"rCARI: Food Insecure"
	
	label var CARI_FES_Cat1		"CARI: Food Secure"
	label var CARI_FES_Cat2		"CARI: Marginally Food Secure"
	label var CARI_FES_Cat3		"CARI: Moderately Food Insecure"
	label var CARI_FES_Cat4		"CARI: Severely Food Insecure"
	label var CARI_FES_Bad		"CARI: Food Insecure"
	
	label var CARI_rCARI_1		"CARI vs. rCARI: Food Secure"
	label var CARI_rCARI_2		"CARI vs. rCARI: Marginally Food Secure"
	label var CARI_rCARI_3		"CARI vs. rCARI: Moderately Food Insecure"
	label var CARI_rCARI_4		"CARI vs. rCARI: Severely Food Insecure"
	label var CARI_rCARI 		"CARI vs. rCARI: Food Insecure"
	
********************************************************************************
*						PART 3: Check and export variables
*******************************************************************************/
	
	compress
	save "${dta}/CAR_Full_Household_rCARI_Analysis.dta", replace
