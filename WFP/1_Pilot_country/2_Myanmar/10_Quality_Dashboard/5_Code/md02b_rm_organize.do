/* *************************************************************************** *
*						WFP RAM-N rCARI Validation Study - Myanmar 			   * 
*																 			   *
*  PURPOSE:  			Create clean variables for Dashboard				   *
*  AUTHOR: 				Nicole Wu (nicole.wu@wfp.org)						   *
*  DATE:  				May 15, 2023										   *
*  LATEST UPDATE: 		Jun  5, 2023										   *
*		  																	   *
********************************************************************************

					
	** REQUIRES:		${d_temp}/Myanmar_RM_Household_Correct_`cdate'.dta
					
	** CREATES:			${d_temp}/Myanmar_RM_Household_Analysis_`cdate'.dta
								
	** NOTES:			_`cdate' was removed after finishing data collection
					
********************************************************************************
*						PART 1: Set up Log and Load Data
*******************************************************************************/
	
	cap log close 
	
	// set log
	loc cdate: di %td_CCYY_NN_DD date(c(current_date), "DMY")
	loc cdate = subinstr(trim("`cdate'"), " " , "", .)
	log using "${d_log}/md02b_rm_organize_`cdate'.smcl", replace
	di `cdate'
	
	* load dataset
	use "${d_temp}/Myanmar_RM_Household_Correct.dta", clear 
	
	** rename ___variables
	ren ___* Sys_*
	
	* survey duration variable
	destring Sys_duration, replace
	gen 	Duration_Min = Sys_duration/60
	
	* survey modality
	gen 	Modality	= 2		// remote
	
	* form version long vs. short
	gen 	ID_Length = length(HHID)
	replace ID_Length = length(HHID_manual) if !mi(HHID_manual)
	
	gen		Form = 1 if ID_Length == 8   // Long
	replace Form = 2 if ID_Length == 7   // Short
	
********************************************************************************
*						PART 2: Create and Define Variables
********************************************************************************
	
** Demongraphics and basic respondents/household information

	gen RESPFemale	= (RESPSex				== 0)
	gen RESPHHH 	= (RESPRelationHHH 		== 100)
	
** Outcome: [FCS] Food consumption score 
	sum FCS*
	gen FCS = FCSStap * 2 + FCSPulse * 3 + FCSDairy * 4 + FCSPr * 4 + 		 ///
			  FCSVeg  * 1 + FCSFruit * 1 + FCSFat * 0.5 + FCSSugar * 0.5
	gen FCSCat28 = cond(FCS <= 28, 1, cond(FCS <= 42, 2, 3))

** Outcome: [rCSI] Reduced Coping Strategies 
	gen rCSI 	 = rCSILessQlty * 1 + rCSIBorrow * 2 + rCSIMealNb * 1 + 	///
				   rCSIMealSize * 1 + rCSIMealAdult * 3
	tab rCSIGenderMealAdult
	
** LCS 
	gen Lcs_Stress_Coping 	 = (Lcs_stress_DomAsset   == 20 | Lcs_stress_DomAsset   == 30 | ///
								Lcs_stress_CrdtFood   == 20 | Lcs_stress_CrdtFood   == 30 | ///
								Lcs_stress_Saving     == 20 | Lcs_stress_Saving     == 30 | ///
								Lcs_stress_BorrowCash == 20 | Lcs_stress_BorrowCash == 30 )
	gen Lcs_Crisis_Coping	 = (Lcs_crisis_ProdAssets == 20 | Lcs_crisis_ProdAssets == 30 | ///
								Lcs_crisis_Health	  == 20 | Lcs_crisis_Health		== 30 | ///
								Lcs_crisis_OutSchool  == 20 | Lcs_crisis_OutSchool  == 30 )			
	gen Lcs_Emergency_Coping = (Lcs_em_ChildWork	  == 20 | Lcs_em_ChildWork  	== 30 | ///
								Lcs_em_Begged     	  == 20 | Lcs_em_Begged     	== 30 | ///
								Lcs_em_IllegalAct 	  == 20 | Lcs_em_IllegalAct 	== 30 )
								
	gen 	LCS_Cat = 1
	replace LCS_Cat = 2 if Lcs_Stress_Coping == 1
	replace LCS_Cat = 3 if Lcs_Crisis_Coping == 1 
	replace LCS_Cat = 4 if Lcs_Emergency_Coping == 1
	
	tab LCS_Cat, gen(LCS_)
	ren LCS_1 	 LCS_None
	ren LCS_2	 LCS_Stress
	ren LCS_3	 LCS_Crisis
	ren LCS_4	 LCS_Emergency
	
** Economic vulnerability: Income
	ren HHIncFirst_Oth HHIncFirst_oth

	gen 	HHIncFirst_Accept = inlist(HHIncFirst_SRi, 1, 2, 5, 13, 14, 15, 16)
	replace HHIncFirst_Accept = 1 if Sys_uuid == "b6bfc463-b2c1-4173-970e-6260266b01d0" | ///
									 Sys_uuid == "0b09ba46-0996-4daf-9595-7741b57168ac" | ///
									 Sys_uuid == "a98f5c11-f029-4925-8e3e-8062b11fd912" | ///
									 Sys_uuid == "8b8812c0-c194-41ba-b05a-ff4049b1be6c" | ///
									 Sys_uuid == "3f1e6432c0984f9483dfdb08f3986800" 	| ///
									 Sys_uuid == "7189655c-69c3-4456-a8f8-307dc81aa318" | ///	
									 Sys_uuid == "67a0dc68-c36b-47eb-be60-fa434ad52f88" | ///
									 Sys_uuid == "e1603def-251a-49f7-90b8-f0e615766b9c" | ///
									 Sys_uuid == "9df267f4-b3f7-4150-8659-88aba4fb37d0" | ///
									 Sys_uuid == "ac3c1d561ddd42a89e8cf9ea70c2dae8" 	| ///
									 Sys_uuid == "4095282c-a287-42d9-b0de-2cf900f8b1a9" | ///
									 Sys_uuid == "04b1433a-9eb8-4fcd-a009-5a9bdfc0e69e" | ///
									 Sys_uuid == "5d205342-39ca-475c-a8a1-a3b0f5884931" | ///
									 Sys_uuid == "6704f66b-15e0-4110-a61e-8d527aa646a5" | ///
									 Sys_uuid == "f784ecc7-9724-4c81-9d98-51a4bf422b18" | ///
									 Sys_uuid == "4d469059-9514-44a0-9ca1-cc1b32e020b6" | ///
									 Sys_uuid == "fd86d647-d0b7-46ef-bd80-001de6faef2a" | ///
									 Sys_uuid == "8c96844b-e187-439f-add1-a5316fdf4ce9"
									  
	gen		HHIncFirst_Border = inlist(HHIncFirst_SRi, 3, 4, 6, 12)
	replace HHIncFirst_Border = 1 if Sys_uuid == "93c904b8-3b7f-4018-befe-6b1663d4ee2b" | ///
									 Sys_uuid == "6af9866f-6517-4060-b452-b45fc4c5e262" | ///
									 Sys_uuid == "085fc3c7-7468-4f57-b333-d444c719d88d" | ///
									 Sys_uuid == "7597586c-5740-4d7b-9970-a3a10b966e61" | ///			 
									 Sys_uuid == "b535541d-0e91-4a63-923c-76835874918d" | ///	
									 Sys_uuid == "8d74622b-be49-4cdc-ad00-bb60b1487dbe" | ///
									 Sys_uuid == "b2127baf-d708-4ec0-b1cc-55dc3764f91e" | ///
									 Sys_uuid == "a835ec99-aad6-46eb-961d-09f06572f576" | ///
									 Sys_uuid == "1b27b391-72d5-489a-b958-1f495fdd0491" | ///
									 Sys_uuid == "1762b9ca-2ef4-4499-a482-3a54e72db5b3"

	gen 	HHIncFirst_Poor	  = inlist(HHIncFirst_SRi, 7, 8, 9, 10, 11)
	
	gen CARI_Inc = . 	 
	replace CARI_Inc = 1 if HHIncFirst_Accept == 1 & inlist(HHIncChg, 0, 1, 5)
	replace CARI_Inc = 2 if HHIncFirst_Accept == 1 & inlist(HHIncChg, 2, 3, 4)
	replace CARI_Inc = 2 if HHIncFirst_Border == 1 & inlist(HHIncChg, 0, 1, 5)
	replace CARI_Inc = 3 if HHIncFirst_Border == 1 & inlist(HHIncChg, 2, 3, 4)
	replace CARI_Inc = 4 if HHIncNb == 0 | HHIncFirst_Poor == 1
	
	tab CARI_Inc, gen(CARI_Inc_)
		
	** Question relevant when: ${HHIncNb} >0
	gen HHInc_None 			= mi(HHIncFirst_SRi)
	gen HHInc_WageSkill 	= (HHIncFirst_SRi == 1  | HHIncFirst_SRi == 2)
	gen HHInc_WageUnskill 	= (HHIncFirst_SRi == 3  | HHIncFirst_SRi == 4)
	gen HHInc_Trade 		= (HHIncFirst_SRi == 11 | HHIncFirst_SRi == 12 | ///
							   HHIncFirst_SRi == 13)
	gen HHInc_AgProduction 	= (HHIncFirst_SRi == 14 | HHIncFirst_SRi == 15)
	
	** Income Change
	tab HHIncChg, gen(HHInc_)
	ren HHInc_1	HHInc_Change_None
	ren HHInc_2	HHInc_Increase
	ren HHInc_3	HHInc_Reduce25
	ren HHInc_4	HHInc_Reduce50
	ren HHInc_5	HHInc_Reduce50More
	
** Outcome: [CARI] COMBINING CURRENT STATUS AND COPING CAPACITY
	recode  FCSCat28 (1 = 4) (2 = 3) (3 = 1), gen(FCS_4pt_CARI)
	replace FCS_4pt_CARI = 2 if FCSCat28 == 3 & rCSI >= 4
	
	gen CC_Inc_Cat   = (CARI_Inc + LCS_Cat)/2	// no round here
	gen CARI_Inc_Raw = (FCS_4pt_CARI + CC_Inc_Cat)/2
	gen CARI_Inc_Cat = round(CARI_Inc_Raw)
	
	gen HH_Vul_Income = (CARI_Inc_Cat == 3 | CARI_Inc_Cat == 4)  if !mi(CARI_Inc_Cat)
	
** Outcome: [FES] Food Expenditure Share: Long vs. Short

	* 7 days food purchase in cash/credit 
egen HHExp_Food_Purch_MN_7D = rowtotal(HHExpStap_MNCRD_7D HHExpPro_MNCRD_7D 	///
	 HHExpFruVeg_MNCRD_7D HHExpFOther_MNCRD_7D HHExpF_MNCRD_7D)

	* 7 days food gift/aid value
egen HHExp_Food_GiftAid_MN_7D = rowtotal(HHExpStap_GiftAid_7D HHExpPro_GiftAid_7D ///
	 HHExpFruVeg_GiftAid_7D HHExpFOther_GiftAid_7D HHExpF_GiftAid_7D)

	* 7 days food own-production value
egen HHExp_Food_Own_MN_7D = rowtotal(HHExpStap_Own_7D HHExpPro_Own_7D HHExpFruVeg_Own_7D  ///
	 HHExpFOther_Own_7D HHExpF_Own_7D)

	* 7 days food values in total and 1 month average 
	gen HHExpFoodTotal_7D = HHExp_Food_Purch_MN_7D + HHExp_Food_GiftAid_MN_7D + ///
		HHExp_Food_Own_MN_7D
	gen HHExpFoodTotal_1M = (HHExpFoodTotal_7D/7) * 30
	
***** NON-FOOD EXPENDITURE *****************************************************
	
	**** 6 MONTH ****
	gen HHExpNFEduMedCloth_MNCRD_1M    = HHExpNFEduMedCloth_MNCRD_6M/6
	gen HHExpNFEduMedCloth_GiftAid_1M  = HHExpNFEduMedCloth_GiftAid_6M/6
	
	**** 1 MONTH ****
	* Monthly non food expenditure in cash/credit
egen HHExpNFTotal_Purch_MN_1M = rowtotal(HHExpNFHyg_MNCRD_1M HHExpNFTranspPh_MNCRD_1M  ///
	 HHExpNFUtilities_MNCRD_1M HHExpNFAlcTobac_MNCRD_1M HHExpNFEduMedCloth_MNCRD_1M	   ///
	 HHExpNF_MNCRD_1M)

	 * Monthly non food gift/aid value
egen HHExpNFTotal_GiftAid_MN_1M = rowtotal(HHExpNFHyg_GiftAid_1M HHExpNFTranspPh_GiftAid_1M ///
	 HHExpNFUtilities_GiftAid_1M HHExpNFAlcTobac_GiftAid_1M HHExpNFEduMedCloth_GiftAid_1M 	///
	 HHExpNF_GiftAid_1M)
	 
	**** TOTAL 1 MONTH AVERAGE ****
	* Total monthly non-food
	gen HHExpNFTotal_1M = HHExpNFTotal_Purch_MN_1M + HHExpNFTotal_GiftAid_MN_1M
	
	**** TOTAL **** 
	gen HHExpTotal = HHExpFoodTotal_1M + HHExpNFTotal_1M
	gen PCExpTotal = HHExpTotal/HHSize

	* FES // household level
	gen 	FES = HHExpFoodTotal_1M/HHExpTotal
	count if HHExpFoodTotal_1M == 0	//  missing
	
	replace FES = 0 	 if mi(FES)
	
	gen byte FES_Cat = 1 if FES <  0.5
	replace  FES_Cat = 2 if FES >= 0.5  & FES < 0.65
	replace  FES_Cat = 3 if FES >= 0.65 & FES < 0.75
	replace  FES_Cat = 4 if FES >= 0.75

	** CARI based on FES
	gen CC_FES_Cat   = (FES_Cat + LCS_Cat)/2	// no round here
	gen CARI_FES_Raw = (FCS_4pt_CARI + CC_FES_Cat)/2
	gen CARI_FES_Cat = round(CARI_FES_Raw)
	
	gen HH_Vul_FES   = (CARI_FES_Cat == 3 | CARI_FES_Cat == 4) 

********************************************************************************
*							PART 3: Label Variables
*******************************************************************************/	

	label def YesNo  		0 "No"   1 "Yes"
	label val Lcs_Stress_Coping Lcs_Crisis_Coping Lcs_Emergency_Coping HH_Vul_FES  ///
			  HH_Vul_Income YesNo
	
	label def FCSCat 		1 "Poor" 2 "Borderline" 3 "Acceptable"
	label val FCSCat28 FCSCat

	label def CARI_Inc_lbl 	1 "Regular employment – no change or increase" ///
							2 "Regular employment but reduced income or informal labour/remittances no change/increase" ///
							3 "Informal labour/remittances but reduced income" ///
							4 "No income, dependent on assistance or support"
	label val CARI_Inc CARI_Inc_lbl
		
	label def LCS_l			1 "Not adopting coping strategies" 	///
							2 "Stress coping strategies" 		///
							3 "Crisis coping strategies" 		///
							4 "Emergencies coping strategies" 
	label val LCS_Cat 	LCS_l
		
	label def FS_CARI	   	1 "Food Secure"  2 "Marginally Food Secure"  ///
							3 "Moderately Food Insecure" 4 "Severely Food Insecure"
	label val FCS_4pt_CARI CARI_Inc_Cat FES_Cat CARI_FES_Cat CARI_Inc FS_CARI
	
	label var Modality					"Survey Modality: F2F vs. Remote"
	label var ID_Length					"Household ID Length"
	label var Form						"Form Type: Long vs. Short"
	
	label var RESPHHH					"Head of Household Respondent"
	label var RESPAge					"Respondent Age"
	label var RESPFemale				"Female Respondent"
	label var HHSize					"Household Size"
	label var FCSStap					"Consumption over the past 7 days (cereals and tubers)"
	label var FCSVeg					"Consumption over the past 7 days (vegetables)"
	label var FCSFruit					"Consumption over the past 7 days (fruit)"
	label var FCSPr						"Consumption over the past 7 days (protein-rich foods)"
	label var FCSPulse					"Consumption over the past 7 days (pulses)"
	label var FCSDairy					"Consumption over the past 7 days (dairy products)"
	label var FCSFat					"Consumption over the past 7 days (oil)"
	label var FCSSugar					"Consumption over the past 7 days (sugar)"
	label var FCS 						"Food Consumption Score"
	label var FCSCat28 					"FCS Categories, thresholds 28-42"
	label var FCS_4pt_CARI				"CARI: Current Status of FCS and rCSI"	
	label var rCSILessQlty 				"Relied on less preferred, less expensive food"
	label var rCSIBorrow 				"Borrowed food or relied on help from friends or relatives"
	label var rCSIMealSize 				"Reduced portion size of meals at meals time"
	label var rCSIMealAdult				"Restricted consumption by adults for young-children to eat"
	label var rCSIMealNb	 			"Reduced the number of meals eaten per day"
	label var rCSI 						"Reduced Coping Strategies Index (rCSI)"
	label var Lcs_stress_DomAsset 		"Stress coping: Sold household assets/goods"
	label var Lcs_stress_CrdtFood 		"Stress coping: Purchased food/non-food on credit (incur debts)"
	label var Lcs_stress_Saving	  		"Stress coping: Spent savings"
	label var Lcs_stress_BorrowCash 	"Stress coping: Borrowed money"
	label var Lcs_crisis_ProdAssets		"Crisis coping: Sold productive assets or means of transport"
	label var Lcs_crisis_Health			"Crisis coping: Reduced expenses on health"
	label var Lcs_crisis_OutSchool		"Crisis coping: Withdrew children from school"
	label var Lcs_em_ChildWork			"Emergency coping: Send children to work for household income"
	label var Lcs_em_Begged				"Emergency coping: Begged and/or scavenged"
	label var Lcs_em_IllegalAct			"Emergency coping: Engaged in illegal income activities"
	label var Lcs_Stress_Coping 		"Household engaged in stress coping strategies" 
	label var Lcs_Crisis_Coping 		"Household engaged in crisis coping strategies" 
	label var Lcs_Emergency_Coping 		"Household engaged in emergency coping strategies" 
	label var LCS_Cat					"Livelihood Coping Strategies Cateory"
	label var LCS_None					"Maximum Livelihood Coping: None"
	label var LCS_Stress				"Maximum Livelihood Coping: Stress level"
	label var LCS_Crisis				"Maximum Livelihood Coping: Crisis level"
	label var LCS_Emergency				"Maximum Livelihood Coping: Emergency level"
	
	lab var HHExp_Food_Purch_MN_7D 		"Total weekly food expenditure on cash/credit"
	lab var HHExp_Food_GiftAid_MN_7D 	"Total weekly food expenditure from gift aid"
	lab var HHExp_Food_Own_MN_7D 		"Total weekly food expenditure from own production"
	lab var HHExpFoodTotal_7D			"Total weekly food expenditure"	
	lab var HHExpFoodTotal_1M			"Total monthly food expenditure (average)"
	lab var HHExpNFTotal_Purch_MN_1M 	"Total monthly non-food exp on cash/credit (average)"
	lab var HHExpNFTotal_GiftAid_MN_1M 	"Total monthly non-food exp from aid (average)"
	lab var HHExpNFTotal_1M				"Total monthly non-food expenditure (average)"	
	lab var HHExpNFEduMedCloth_MNCRD_1M "Total monthly edu, med and clothes exp on cash/credit (average)"
	lab var HHExpNFEduMedCloth_GiftAid_1M "Total monthly edu, med and clothes exp on aid (average)"
	label var HHExpTotal 				"Monthly total household expenditure"
	label var PCExpTotal				"Monthly total household expenditure per capita"
	label var FES						"Food Expenditure Share"
	label var FES_Cat					"Food Security Category based on FES"
	label var CARI_Inc					"Household Economic Vulnerability Based on Income"
	label var CC_Inc_Cat				"Coping Capacity Combined Category using Income"
	label var CARI_Inc_Raw				"Raw CARI Category based on Income"
	label var CARI_Inc_Cat				"CARI Category using Income"
	label var HH_Vul_Income				"Household being vulnerable using Income rCARI"
	
	label var HHIncFirst_Accept			"Income Source: Skilled waged labor, pension, business and ag production"
	label var HHIncFirst_Border			"Income Source: Unskilled waged labor, remittances, and street selling"
	label var HHIncFirst_Poor			"Income Source: None, aid, borrowing, begging, and high-risk activities, etc."
	label var CARI_Inc_1				"Income: Food Secure"
	label var CARI_Inc_2				"Income: Marginally Food Secure"
	label var CARI_Inc_3				"Income: Moderately Food Insecure"
	label var CARI_Inc_4				"Income: Severely Food Insecure"
	label var HHInc_None				"Income Source: None"
	label var HHInc_WageSkill			"Income Source: Skilled Waged Labor"
	label var HHInc_WageUnskill			"Income Source: Unskilled Waged Labor"
	label var HHInc_Trade				"Income Source: Trade"
	label var HHInc_AgProduction		"Income Source: Agricultural Production"	
	label var HHInc_Change_None			"Income Change: None"
	label var HHInc_Increase			"Income Change: Increase"
	label var HHInc_Reduce25			"Income Change: Reduced < 25%"
	label var HHInc_Reduce50			"Income Change: Reduced 25% - 50%"
	label var HHInc_Reduce50More		"Income Change: Reduced 50+%"
	label var HHInc_PCT 				"Number of household members contributing to income"
	label var HHIncNb 					"Number of household income sources"
	
	label var CC_FES_Cat				"Coping Capacity Combined Category using FES"
	label var CARI_FES_Raw				"Raw CARI Category based on FES"
	label var CARI_FES_Cat				"CARI Category using FES"
	label var HH_Vul_FES				"Household being vulnerable using FES CARI"
	
********************************************************************************
*						PART 4: Save RM Analysis Dataset
*******************************************************************************/

	compress	
*	iecodebook export using "${d_out}/Myanmar_RM_Codebook.xlsx", replace
	
	save "${d_temp}/Myanmar_RM_Household_Analysis.dta", replace	

* -------------	
* End of dofile
