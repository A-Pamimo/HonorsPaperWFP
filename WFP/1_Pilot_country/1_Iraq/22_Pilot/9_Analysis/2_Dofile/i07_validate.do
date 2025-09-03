/* *************************************************************************** *
*						WFP RAM-N rCARI Validation Study - Iraq 			   * 
*																 			   *
*  PURPOSE:  								   *
*  AUTHOR: 				Nicole Wu (nicole.wu@wfp.org)						   *
*  DATE:  				Apr 24, 2023										   *
*  LATEST UPDATE: 		Apr 24, 2023										   *
*		  																	   *
********************************************************************************

					
	** REQUIRES:	${dta}/Iraq_F2F_Household_Analysis.dta
					${dta}/Iraq_RM_Household_Analysis.dta
	** CREATES:		${dta}/Iraq_Full_Household_Analysis.dta
								
	** NOTES:		
					
********************************************************************************
*						Part 1: Create Merged dataset for Analysis
*******************************************************************************/
	
	cap log close 
	
	// set log
	loc cdate: di %td_CCYY_NN_DD date(c(current_date), "DMY")
	loc cdate = subinstr(trim("`cdate'"), " " , "", .)
	log using "${logs}/i07_validate_`cdate'.smcl", replace
	di `cdate'
	
	* load dataset
	use "${dta}/Iraq_F2F_Household_Analysis.dta", clear 

	* merge Remote Answers to F2F Answers
	mmerge HHID using "${dta}/Iraq_RM_Household_Analysis.dta", type(1:1) uname(r_)
	ren _merge Source
	
/*	tab Modality if Source == 1
	tostring HHID, replace
	gen hhid_group = substr(HHID,1,1) */
	 
	gen Attrition = (Source != 3)

* check respondents 
	tab RESPSex r_RESPSex
	
/*	Sex of the | Sex of the respondent
	respondent |    Female       Male |     Total
	-----------+----------------------+----------
		Female |        83        149 |       232 
		  Male |        27        195 |       222 
	-----------+----------------------+----------
		 Total |       110        344 |       454 
*/
	gen Respondent = (RESPSex == r_RESPSex) & !mi(RESPSex) & !mi(r_RESPSex)
	// if Respondent == 1 means the same gender interviewed 
	// if Respondent == 0 means the opposite gender in the same household
	// potentially can be used for gender comparisons on other outcome variables
	
	mmerge HHID using "${sample}/Iraq_Full_Household_Modality.dta", ///
	type(1:1) uname(S_)
	
	compress
	save "${dta}/Iraq_Full_Household_Analysis.dta", replace
	
	gl bal_var  RESPHHH RESPAge HHSize RESPFemale RESPPLW HHDisplaced HHRefugee
	
	iebaltab 	${bal_var} if Attrition == 0, 			///
				grpvar(S_Modality_First) onerow 		///
				nonote total replace format(%12.2fc) 	///
				rowvarlabels savexlsx("${tabs_bal}/Iraq_rCARI_Modality_Assign_Full_Balance.xlsx")
	
	iebaltab 	${bal_var} if Attrition == 0 & S_HH_True_Crossover == 1,	///
				grpvar(S_Modality_First) onerow 		///
				nonote total replace format(%12.2fc) 	///
				rowvarlabels savexlsx("${tabs_bal}/Iraq_rCARI_Modality_Assign_True_Balance.xlsx")
	
	
********************************************************************************
*							Household level Validation
*******************************************************************************/
	
	asdoc ttest HHSize == r_HHSize, replace save(${tabs_val}/Iraq_rCARI_Validation_Paired_ttest.doc) ///
	title(Paired Difference: CARI vs. rCARI) fhc(\b) fhr(\b) font(Roboto) label dec(2) tzok
	
	ren *Lcs_*_Coping *_*
	ren *__* *_*
	ren _* *
	
	ren *MealSize  *MealSz
	ren *MealAdult *MealAd
	ren *HHExpFoodTotal_1M *HHExpFood
	ren *HHExpNFTotal_1M   *HHExpNF
	ren *HHExpTotal		   *HHExpT
	ren *PCExpTotal		   *PCExpT
	
	gl var_validation FCS rCSI Stress Crisis Emergency HHExpFood HHExpNF HHExpT PCExpT FES HH_Vul_CARI
	
foreach var of global var_validation {
	asdoc ttest `var' = r_`var', rowappend save(${tabs_val}/Iraq_rCARI_Validation_Paired_ttest.doc) ///
									  font(Roboto) label dec(2) tzok
}

	**** True Crossover
	asdoc ttest HHSize == r_HHSize if S_HH_True_Crossover == 1, replace save(${tabs_val}/Iraq_rCARI_Validation_True_Paired_ttest.doc) ///
	title(Paired Difference: CARI vs. rCARI True Crossover) fhc(\b) fhr(\b) font(Roboto) label dec(2) tzok
	
	gl var_validation FCS rCSI Stress Crisis Emergency HHExpFood HHExpNF HHExpT PCExpT FES HH_Vul_CARI
	
foreach var of global var_validation {
	asdoc ttest `var' = r_`var' if S_HH_True_Crossover == 1, rowappend save(${tabs_val}/Iraq_rCARI_Validation_True_Paired_ttest.doc) ///
									  font(Roboto) label dec(2) tzok
}


	** correlation between CARI and rCARI
	asdoc pwcorr HH_Vul_CARI r_HH_Vul_CARI FCS r_FCS, star(.05) replace save(${tabs_val}/Iraq_rCARI_Validation_Correlation.doc) ///
										  fhc(\b) font(Roboto) label dec(2) tzok

********************************************************************************
*						Intra-Household Gender Analysis
*******************************************************************************/

	asdoc ttest FCS == r_FCS if Respondent == 0, replace save(${tabs_val}/Iraq_rCARI_Validation_Paired_ttest.doc) ///
	title(Paired Difference) fhc(\b) fhr(\b) font(Roboto) label dec(2) tzok
	
	tabout HH_Vul_CARI r_HH_Vul_CARI  ///
	using "${tabs_val}/Iraq_rCARI_Validation_Crosstab.docx", ///
	replace style(docx) font(bold) ///
	c(freq cell) f(0 1p) nlab(Sample size) h3(nil)
