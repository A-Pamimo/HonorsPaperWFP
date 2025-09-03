/* *************************************************************************** *
*						WFP RAM-N rCARI Validation Study - Iraq 			   * 
*																 			   *
*  PURPOSE:  			Create clean variables for Remote					   *
*  AUTHOR: 				Nicole Wu (nicole.wu@wfp.org)						   *
*  DATE:  				Apr 24, 2023										   *
*  LATEST UPDATE: 		Apr 24, 2023										   *
*		  																	   *
********************************************************************************

					
	** REQUIRES:	${dta}/Iraq_RM_Household_Raw.dta
					
	** CREATES:		${dta}/Iraq_RM_Household_Analysis.dta
								
	** NOTES:		N = 540 (Version A = 297 and Version B = 243)
					
********************************************************************************
*								Define Variables
*******************************************************************************/
	
	cap log close 
	
	// set log
	loc cdate: di %td_CCYY_NN_DD date(c(current_date), "DMY")
	loc cdate = subinstr(trim("`cdate'"), " " , "", .)
	log using "${logs}/i02b_organize_`cdate'.smcl", replace
	di `cdate'
	
	* load dataset
	use "${dta}/Iraq_RM_Household_Raw.dta", clear 
	
	gen 	Status = 1 if (ADMIN5Name == 1 | ADMIN5Name == 5 | ADMIN5Name == 10) 
	replace Status = 2 if (ADMIN5Name == 2 | ADMIN5Name == 3) 
	
** Demongraphics and basic respondents/household information

	gen RESPHHH 	= (RESPRelationHHH 		== 100)
	gen RESPFemale	= (RESPSex				== 0)
	
	gl var_demo RESPAge RESPSex RESPFemale RESPHHH HHSize

** Outcome: [FCS] Food consumption score 
	sum FCS*
	
	gen FCS = FCSStap * 2 + FCSPulse * 3 + FCSDairy * 4 + FCSPr * 4 + 		 ///
			  FCSVeg  * 1 + FCSFruit * 1 + FCSFat * 0.5 + FCSSugar * 0.5
	gen FCSCat28 = cond(FCS <= 28, 1, cond(FCS <= 42, 2, 3))
	
	gen 	FCG = 1 if (FCSCat28 == 1 | FCSCat28 == 2)
	replace FCG = 2 if (FCSCat28 == 3)
	
	gl  out_fcs FCSStap FCSPulse FCSDairy FCSPr FCSVeg FCSFruit FCSFat 		 ///
				FCSSugar FCS FCSCat28 FCG 

** Outcome: [rCSI] Reduced Coping Strategies (rCSI - Gendered)

	gen rCSI 	 = rCSILessQlty * 1 + rCSIBorrow * 2 + rCSIMealNb * 1 + 	///
				   rCSIMealSize * 1 + rCSIMealAdult * 3
	
	gl out_rcsi rCSILessQlty rCSIBorrow rCSIMealSize rCSIGenderMealSize rCSIMealAdult    ///
				rCSIGenderMealAdult rCSIMealNb rCSIGenderMealNb rCSI 
	
** LCS 
	ren LcsEN_em_ChildWork Lcs_em_ChildWork
	gen Lcs_Stress_Coping 	 = (Lcs_stress_DomAsset   == 20 | Lcs_stress_DomAsset   == 30 | ///
								Lcs_stress_CrdtFood   == 20 | Lcs_stress_CrdtFood   == 30 | ///
								Lcs_stress_Saving     == 20 | Lcs_stress_Saving     == 30 | ///
								Lcs_stress_BorrowCash == 20 | Lcs_stress_BorrowCash == 30 )
	gen Lcs_Crisis_Coping	 = (Lcs_crisis_ProdAssets == 20 | Lcs_crisis_ProdAssets == 30 | ///
								Lcs_crisis_HealthEdu  == 20 | Lcs_crisis_HealthEdu  == 30 | ///
								Lcs_crisis_OutSchool  == 20 | Lcs_crisis_OutSchool  == 30 )			
	gen Lcs_Emergency_Coping = (Lcs_em_ChildWork  == 20 | Lcs_em_ChildWork  == 30 | ///
								Lcs_em_Begged     == 20 | Lcs_em_Begged     == 30 | ///
								Lcs_em_IllegalAct == 20 | Lcs_em_IllegalAct == 30 )
								
	gen 	LCS_Cat = 1
	replace LCS_Cat = 2 if Lcs_Stress_Coping == 1
	replace LCS_Cat = 3 if Lcs_Crisis_Coping == 1 
	replace LCS_Cat = 4 if Lcs_Emergency_Coping == 1
	
	gl  out_lcs  Lcs_Stress_Coping Lcs_Crisis_Coping Lcs_Emergency_Coping LCS_Cat
	
** Economic vulnerability: Income
	
	** One additional group 9 High risk activity (e.g. begging, scavenging) became 2 options in HHIncFirst_SRi - need to recode or change the values
	recode HHIncFirst_SRi (10 = 9)(11 = 10)(12 = 11)(13 = 12)(14 = 13)(15 = 14) ///
						  (16 = 15), gen(HHIncFirst_SRi_C)
	order HHIncFirst_SRi_C, a(HHIncFirst_SRi)
	drop  HHIncFirst_SRi
	ren	  HHIncFirst_SRi_C HHIncFirst_SRi
	
	tab HHIncFirst_Oth
	replace HHIncFirst_SRi = 7 if HHIncFirst_Oth == "راتب رعاية الاجتماعيه" 
	// Social Welfare Salary as aid/gift
	replace HHIncFirst_SRi = 2 if HHIncFirst_Oth == "سائق تكسي"
	// Taxi driver as Wage Labor - Skilled
	replace HHIncFirst_SRi = 11 if HHIncFirst_Oth == "عربانه بيع مواد"
	// Cart selling materials as petty trade/selling on streets
	
	gen CARI_Inc = .
	replace CARI_Inc = 1 if inlist(HHIncFirst_SRi, 1, 2, 5, 12, 13, 15) & inlist(HHIncChg, 0, 1, 5)
	replace CARI_Inc = 2 if inlist(HHIncFirst_SRi, 1, 2, 5, 12, 13, 15) & inlist(HHIncChg, 2, 3, 4)
	replace CARI_Inc = 2 if inlist(HHIncFirst_SRi, 3, 4, 6, 11) & inlist(HHIncChg, 0, 1, 5)
	replace CARI_Inc = 3 if inlist(HHIncFirst_SRi, 3, 4, 6, 11) & inlist(HHIncChg, 2, 3, 4)
	replace CARI_Inc = 4 if HHIncNb == 0 | inlist(HHIncFirst_SRi, 7, 8, 9, 10)
	replace CARI_Inc = 5 if HHIncFirst_SRi == 999
	* Recode missing values
	replace CARI_Inc = . if CARI_Inc == 5
	
	replace CARI_Inc = 4 if HHIncFirst_Oth == "عاطل على عمل" | ///
			HHIncFirst_Oth == "عاطل على عمل  لم يقدر العلم"  | ///
			HHIncFirst_Oth == "عاطل على عمل ولم يعمل أي عمل" | ///
			HHIncFirst_Oth == "لا أحد يعمل"
	// unemployed or nobody works
		
** Outcome: [CARI] COMBINING CURRENT STATUS AND COPING CAPACITY
	recode  FCSCat28 (1 = 4) (2 = 3) (3 = 1), gen(FCS_4pt_CARI)
	replace FCS_4pt_CARI = 2 if FCSCat28 == 3 & rCSI >= 4
	
	gen CC_Inc_Cat   = (CARI_Inc + LCS_Cat)/2	// no round here
	gen CARI_Inc_Raw = (FCS_4pt_CARI + CC_Inc_Cat)/2
	gen CARI_Inc_Cat = round(CARI_Inc_Raw)
	
	gen HH_Vul_CARI  = (CARI_Inc_Cat == 3 | CARI_Inc_Cat == 4)

	gl out_cari FCS_4pt_CARI CC_Inc_Cat CARI_Inc_Cat HH_Vul_CARI
	
** Outcome: [FES] Food Expenditure Share

	* 7 days food purchase in cash/credit 
egen HHExp_Food_Purch_MN_7D = rowtotal(HHExpStap_MNCRD_7D HHExpPro_MNCRD_7D HHExpFruVeg_MNCRD_7D ///
	 HHExpFOther_MNCRD_7D HHExpF_MNCRD_7D)
	
	* 7 days food gift/aid value
egen HHExp_Food_GiftAid_MN_7D = rowtotal(HHExpStap_GiftAid_7D HHExpPro_GiftAid_7D ///
	 HHExpFruVeg_GiftAid_7D HHExpFOther_GiftAid_7D HHExpF_GiftAid_7D)

	* 7 days food own-production value
egen HHExp_Food_Own_MN_7D = rowtotal(HHExpStap_Own_7D HHExpPro_Own_7D HHExpFruVeg_Own_7D  ///
	 HHExpFOther_Own_7D HHExpF_Own_7D)

	* 7 days food values in total and 1 month average 
	gen HHExpFoodTotal_7D = HHExp_Food_Purch_MN_7D + HHExp_Food_GiftAid_MN_7D + HHExp_Food_Own_MN_7D
	gen HHExpFoodTotal_1M = (HHExpFoodTotal_7D/7) * 30
	
***** NON-FOOD EXPENDITURE *****************************************************
	
	**** 1 MONTH but actually 6 MONTH ****
	 replace HHExpNFEduMedCloth_MNCRD_1M  = HHExpNFEduMedCloth_MNCRD_1M/6
	 replace HHExpNFEduMedCloth_GiftAid_1M  = HHExpNFEduMedCloth_GiftAid_1M/6
	 
	**** 1 MONTH ****
	* Monthly non food expenditure in cash/credit
egen HHExpNFTotal_Purch_MN_1M = rowtotal(HHExpNFHyg_MNCRD_1M HHExpNFTranspPh_MNCRD_1M  ///
	 HHExpNFUtilities_MNCRD_1M HHExpNFAlcTobac_MNCRD_1M HHExpNF_MNCRD_1M 			   ///
	 HHExpNFEduMedCloth_MNCRD_1M)

	 * Monthly non food gift/aid value
egen HHExpNFTotal_GiftAid_MN_1M = rowtotal(HHExpNFHyg_GiftAid_1M HHExpNFTranspPh_GiftAid_1M ///
	 HHExpNFUtilities_GiftAid_1M HHExpNFAlcTobac_GiftAid_1M HHExpNF_GiftAid_1M				///
	 HHExpNFEduMedCloth_GiftAid_1M)

	**** TOTAL 1 MONTH AVERAGE ****
	* Total monthly non-food
	gen HHExpNFTotal_1M = HHExpNFTotal_Purch_MN_1M + HHExpNFTotal_GiftAid_MN_1M
	
	**** TOTAL **** 
	gen HHExpTotal = HHExpFoodTotal_1M + HHExpNFTotal_1M
	gen PCExpTotal = HHExpTotal/HHSize

	* FES // household level
	gen 	FES = HHExpFoodTotal_1M/HHExpTotal * 100
	count if HHExpFoodTotal_1M == 0	// 3 missing
	
	replace FES = 0 	 if mi(FES)
	
	gen byte FES_Cat = 1 if FES <  50
	replace  FES_Cat = 2 if FES >= 50 & FES < 65
	replace  FES_Cat = 3 if FES >= 65 & FES < 75
	replace  FES_Cat = 4 if FES >= 75
	
	gl out_fes HHExpFoodTotal_1M HHExpNFTotal_Purch_MN_1M HHExpNFTotal_GiftAid_MN_1M  ///
			   HHExpNFTotal_1M HHExpTotal PCExpTotal FES FES_Cat

	** CARI based on FES
	gen CC_FES_Cat   = (FES_Cat + LCS_Cat)/2	// no round here
	gen CARI_FES_Raw = (FCS_4pt_CARI + CC_FES_Cat)/2
	gen CARI_FES_Cat = round(CARI_FES_Raw)
	
	gen HH_Vul_CARI_FES  = (CARI_FES_Cat == 3 | CARI_FES_Cat == 4)

********************************************************************************
*						PART 3: Label Variables
*******************************************************************************/	

	label def YesNo  		0 "No"   1 "Yes"
	label val Lcs_Stress_Coping Lcs_Crisis_Coping Lcs_Emergency_Coping HH_Vul_CARI YesNo
	
	label def FCSCat 		1 "Poor" 2 "Borderline" 3 "Acceptable"
	label val FCSCat28 FCSCat
	
	label def FCG_l 		1 "FCS Poor or Borderline" 2 "FCS Acceptable"
	label val FCG FCG_l
	
	label def Income_l	1	"Wage Labor - Professional" 					///
						2	"Wage Labor - Skilled"							///
						3	"Wage Labor - Unskilled/Casual/Agriculture" 	///
						4	"Wage Labor - Unskilled/Casual/non-agriculture" ///
						5	"Pension" 										///
						6	"Remittances"									///
						7	"Aid/gifts"										///
						8	"Borrowing money/Living off debt"				///
						9	"High risk activity (e.g. begging, scavenging)"	///
						10  "Saving/selling assets"							///
						11	"Petty trade/selling on streets"				///
						12	"Small trade (own business)" 					///
						13	"Medium/large trade (own business)"				///
						14	"Small Agriculture production including livestock" ///
						15	"Medium/large agriculture production including livestock" ///
						999	"Other (specify)"
	label val HHIncFirst_SRi Income_l

	label def CARI_Inc_lbl 1 "Regular employment – no change or increase" ///
						   2 "Regular employment but reduced income or informal labour/remittances no change/increase" ///
                           3 "Informal labour/remittances but reduced income" ///
                           4 "No income, dependent on assistance or support"
	label val CARI_Inc CARI_Inc_lbl
	
	label var RESPHHH				"Head of Household Respondent"
	label var RESPAge				"Respondent Age"
	label var RESPFemale			"Female Respondent"
	label var HHSize				"Household Size"

	label var FCSStap				"Consumption over the past 7 days (cereals and tubers)"
	label var FCSVeg				"Consumption over the past 7 days (vegetables)"
	label var FCSFruit				"Consumption over the past 7 days (fruit)"
	label var FCSPr					"Consumption over the past 7 days (protein-rich foods)"
	label var FCSPulse				"Consumption over the past 7 days (pulses)"
	label var FCSDairy				"Consumption over the past 7 days (dairy products)"
	label var FCSFat				"Consumption over the past 7 days (oil)"
	label var FCSSugar				"Consumption over the past 7 days (sugar)"
	label var FCS 					"Food Consumption Score"
	label var FCSCat28 				"FCS Categories, thresholds 28-42"
	label var FCG					"FCS Group"
	label var FCS_4pt_CARI			"CARI: Current Status of FCS and rCSI"
	
	label var rCSILessQlty 			"Relied on less preferred, less expensive food"
	label var rCSIBorrow 			"Borrowed food or relied on help from friends or relatives"
	label var rCSIMealSize 			"Reduced portion size of meals at meals time"
	label var rCSIMealAdult			"Restricted consumption by adults in order for young-children to eat"
	label var rCSIMealNb	 		"Reduced the number of meals eaten per day"
	label var rCSI 					"Reduced Consumption Strategies Index (rCSI)"
	
	label def LCS_l		1 "Not adopting coping strategies" 	///
						2 "Stress coping strategies" 		///
						3 "Crisis coping strategies" 		///
						4 "Emergencies coping strategies" 
	label val FES_Cat 	LCS_l
	
	label var Lcs_stress_DomAsset 	"Stress coping: Sold household assets/goods"
	label var Lcs_stress_CrdtFood 	"Stress coping: Purchased food/non-food on credit (incur debts)"
	label var Lcs_stress_Saving	  	"Stress coping: Spent savings"
	label var Lcs_stress_BorrowCash "Stress coping: Borrowed money"
	label var Lcs_crisis_ProdAssets	"Crisis coping: Sold productive assets or means of transport"
	label var Lcs_crisis_HealthEdu	"Crisis coping: Reduced expenses on health or education"
	label var Lcs_crisis_OutSchool	"Crisis coping: Withdrew children from school"
	label var Lcs_em_ChildWork		"Emergency coping: Send children to work for household income"
	label var Lcs_em_Begged			"Emergency coping: Begged and/or scavenged"
	label var Lcs_em_IllegalAct		"Emergency coping: Engaged in illegal income activities"
	label var Lcs_Stress_Coping 	"Household engaged in stress coping strategies" 
	label var Lcs_Crisis_Coping 	"Household engaged in crisis coping strategies" 
	label var Lcs_Emergency_Coping 	"Household engaged in emergency coping strategies" 
	label var LCS_Cat				"Livelihood Coping Strategies Cateory"
	
	label var HHExp_Food_Purch_MN_7D 		"Total weekly food expenditure on cash/credit"
	label var HHExp_Food_GiftAid_MN_7D 		"Total weekly food expenditure from gift aid"
	label var HHExp_Food_Own_MN_7D 			"Total weekly food expenditure from own production"
	label var HHExpFoodTotal_7D				"Total weekly food expenditure"	
	label var HHExpFoodTotal_1M				"Total monthly food expenditure (average)"
	label var HHExpNFTotal_Purch_MN_1M 		"Total monthly non-food exp on cash (average)"
	label var HHExpNFTotal_GiftAid_MN_1M 	"Total monthly non-food exp from aid (average)"
	label var HHExpNFTotal_1M				"Total monthly non-food expenditure (average)"
	
	label var HHExpTotal 			"Monthly total household expenditure"
	label var PCExpTotal			"Monthly total household expenditure per capita"
	label var FES					"Food Expenditure Share"
	label var FES_Cat				"Food Security Category based on FES"
	
	label def FS_CARI	   1 "Food Secure"  2 "Marginally Food Secure" 				///
						   3 "Moderately Food Insecure" 4 "Severely Food Insecure"
	label val FCS_4pt_CARI CARI_Inc_Cat FES_Cat CARI_Inc FS_CARI	   
	
	label var CC_Inc_Cat			"Coping Capacity Combined Category using Income"
	label var CARI_Inc_Raw			"Raw CARI Category based on Income"
	label var CARI_Inc_Cat			"CARI Category using Income"
	label var HH_Vul_CARI			"Household being vulnerable using Income rCARI"
	label var Status				"Household Status IDP vs. Refugee" 

********************************************************************************
*						PART 4: Check Balance Dataset
*******************************************************************************/

	asdoc pwcorr HH_Vul_CARI HH_Vul_CARI_FES, star(.05) replace save(${tabs_val}/Iraq_rCARI_Inc_FES_Correlation.doc) ///
										  fhc(\b) font(Roboto) label dec(2) tzok
	compress
	keep HHID Version Status $var_demo $out_fcs $out_rcsi $out_lcs $out_fes $out_cari
	save "${dta}/Iraq_RM_Household_Analysis.dta", replace	
	
	* Overall Version A vs. Version B Randomization Balance
	iebaltab 	$var_demo $out_fcs $out_rcsi $out_lcs $out_fes $out_cari, 		///
				grpvar(Version) grplabels(1 Version A @ 2 Version B) ///
				rowvarlabels savexlsx("${tabs_bal}/Iraq_RM_Version_Balance.xlsx") replace
						
	