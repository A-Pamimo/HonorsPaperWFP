/* *************************************************************************** *
*						WFP RAM-N rCARI Validation Study - Iraq 			   * 
*																 			   *
*  PURPOSE:  			Create clean variables for analysis					   *
*  AUTHOR: 				Nicole Wu (nicole.wu@wfp.org)						   *
*  DATE:  				Apr 20, 2023										   *
*  LATEST UPDATE: 		Apr 22, 2023										   *
*		  																	   *
********************************************************************************
				
	** REQUIRES:	${dta}/Iraq_F2F_Household_Raw.dta
					
	** CREATES:		${dta}/Iraq_F2F_Household_Analysis.dta
								
	** NOTES:		N = 590 (Group A = 305 and Group B = 285)
					Expenditure Long module:  25 items (F2F Group A)
								Short module: 16 items (F2F Group B)
					Assumption: Group B will report lower consumption expenditures

					Need to exclude energy (other than electricity) when comparing 
					exp data between A and B due to survey design/implementation 
					errors
					* Rent was not collected for Iraq
					
********************************************************************************
*								Part 1: Define Variables
*******************************************************************************/
	
	cap log close 
	
	// set log
	loc cdate: di %td_CCYY_NN_DD date(c(current_date), "DMY")
	loc cdate = subinstr(trim("`cdate'"), " " , "", .)
	log using "${logs}/i07_exp_`cdate'.smcl", replace
	di `cdate'
	
	* load dataset
	use "${dta}/Iraq_F2F_Household_Raw.dta", clear 
	
	gen 	Status = 1 if (ADMIN5Name == 1 | ADMIN5Name == 8) 
	replace Status = 2 if (ADMIN5Name == 2 | ADMIN5Name == 7) 
	
	gen 	Modality	= (F2F_Rmt == 1 | F2F_Rmt == 3)
	replace Modality	= 2 if Modality == 0
	
	bysort Group: sum HHExp*
	
	* 7 days food purchase in cash/credit (18 vars)
egen HHExp_Food_Purch_MN_7D = rowtotal(HHExpFCer_Purch_MN_7D HHExpFTub_Purch_MN_7D ///
	 HHExpFPuls_Purch_MN_7D HHExpFVeg_Purch_MN_7D HHExpFFrt_Purch_MN_7D 		   ///
	 HHExpFAnimMeat_Purch_MN_7D HHExpFAnimFish_Purch_MN_7D HHExpFFats_Purch_MN_7D  ///
	 HHExpFDairy_Purch_MN_7D HHExpFEgg_Purch_MN_7D HHExpFSgr_Purch_MN_7D 		   ///
	 HHExpFCond_Purch_MN_7D HHExpFBev_Purch_MN_7D HHExpFOut_Purch_MN_7D 		   ///
	 HHExpFVegFrt_Purch_MN_7D HHExpFAnimMeatFishEgg_Purch_MN_7 					   ///
	 HHExpFFatsDairy_Purch_MN_7D HHExpFSgrCond_Purch_MN_7D)	 
	 
	* 7 days food gift/aid value (18 vars)
egen HHExp_Food_GiftAid_MN_7D = rowtotal(HHExpFCer_GiftAid_MN_7D HHExpFTub_GiftAid_MN_7D ///
	 HHExpFPuls_GiftAid_MN_7D HHExpFVeg_GiftAid_MN_7D HHExpFFrt_GiftAid_MN_7D 			 ///
	 HHExpFAnimMeat_GiftAid_MN_7D HHExpFAnimFish_GiftAid_MN_7D HHExpFFats_GiftAid_MN_7D  ///
	 HHExpFDairy_GiftAid_MN_7D HHExpFEgg_GiftAid_MN_7D HHExpFSgr_GiftAid_MN_7D 			 ///
	 HHExpFCond_GiftAid_MN_7D HHExpFBev_GiftAid_MN_7D HHExpFOut_GiftAid_MN_7D 			 ///
	 HHExpFVegFrt_GiftAid_MN_7D HHExpFAnimMeatFishEgg_GiftAid_MN 						 ///
	 HHExpFFatsDairy_GiftAid_MN_7D HHExpFSgrCond_GiftAid_MN_7D)

	* 7 days food own-production value (15 vars - check with Alirah)
egen HHExp_Food_Own_MN_7D = rowtotal(HHExpFCer_Own_MN_7D HHExpFTub_Own_MN_7D 			 ///
	 HHExpFPuls_Own_MN_7D HHExpFVeg_Own_MN_7D HHExpFAnimMeat_Own_MN_7D 					 ///
	 HHExpFDairy_Own_MN_7D HHExpFEgg_Own_MN_7D HHExpFSgr_Own_MN_7D HHExpFCond_Own_MN_7D  ///
	 HHExpFBev_Own_MN_7D HHExpFOut_Own_MN_7D HHExpFVegFrt_Own_MN_7D 					 ///
	 HHExpFAnimMeatFishEgg_Own_MN_7D HHExpFFatsDairy_Own_MN_7D HHExpFSgrCond_Own_MN_7D)

	* 7 days food values in total and 1 month average 
	gen HHExpFoodTotal_7D = HHExp_Food_Purch_MN_7D + HHExp_Food_GiftAid_MN_7D + HHExp_Food_Own_MN_7D
	gen HHExpFoodTotal_1M = (HHExpFoodTotal_7D/7) * 30
	gen PCExpFoodTotal_1M = HHExpFoodTotal_1M/HHSize
	
	gen HHExp_Food_Purch_MN_1M_k	= HHExp_Food_Purch_MN_7D/7000 * 30
	gen HHExp_Food_GiftAid_MN_1M_k 	= HHExp_Food_GiftAid_MN_7D/7000 * 30
	gen HHExp_Food_Own_MN_1M_k		= HHExp_Food_Own_MN_7D/7000 * 30
	
***** NON-FOOD EXPENDITURE *****************************************************
	
	**** 1 MONTH ****
	* Monthly non food expenditure in cash/credit (10 vars)
egen HHExp_NonFood_Purch_MN_1M = rowtotal(HHExpNFHyg_Purch_MN_1M HHExpNFTransp_Purch_MN_1M ///
	 HHExpNFFuel_Purch_MN_1M HHExpNFWat_Purch_MN_1M 			   ///
	 HHExpNFDwelSer_Purch_MN_1M HHExpNFPhone_Purch_MN_1M HHExpNFRecr_Purch_MN_1M 		   ///
	 HHExpNFAlcTobac_Purch_MN_1M HHExpNFTranspFuel_Purch_MN_1M)

	 * Monthly non food gift/aid value (10 vars)
egen HHExp_NonFood_GiftAid_MN_1M = rowtotal(HHExpNFHyg_GiftAid_MN_1M 			 	///
	 HHExpNFTransp_GiftAid_MN_1M HHExpNFFuel_GiftAid_MN_1M HHExpNFWat_GiftAid_MN_1M ///
	 HHExpNFDwelSer_GiftAid_MN_1M 						///
	 HHExpNFPhone_GiftAid_MN_1M HHExpNFRecr_GiftAid_MN_1M 							///
	 HHExpNFAlcTobac_GiftAid_MN_1M HHExpNFTranspFuel_GiftAid_MN_1M)

	**** 6 MONTHS ****
	* Non food expenditure in cash/credit in 6 months (10 vars)
egen HHExp_NonFood_Purch_MN_6M = rowtotal(HHExpNFMedServ_Purch_MN_6M HHExpNFMedGood_Purch_MN_6M ///
	 HHExpNFCloth_Purch_MN_6M HHExpNFEduFee_Purch_MN_6M HHExpNFEduGood_Purch_MN_6M 				///
	 HHExpNFHHSoft_Purch_MN_6M HHExpNFHHMaint_Purch_MN_6M HHExpNFMedServGood_Purch_MN_6M 		///
	 HHExpNFEduFeeGood_Purch_MN_6M HHExpNFHHSoftMaint_Purch_MN_6M)

	 * Non food expenditure gift/aid value in 6 months
egen HHExp_NonFood_GiftAid_MN_6M = rowtotal(HHExpNFMedServ_GiftAid_MN_6M HHExpNFMedGood_GiftAid_MN_6M ///
	 HHExpNFCloth_GiftAid_MN_6M HHExpNFEduFee_GiftAid_MN_6M HHExpNFEduGood_GiftAid_MN_6M 			  ///
	 HHExpNFHHSoft_GiftAid_MN_6M HHExpNFHHMaint_GiftAid_MN_6M HHExpNFMedServGood_GiftAid_MN_6M 		  ///
	 HHExpNFEduFeeGood_GiftAid_MN_6M HHExpNFHHSoftMaint_GiftAid_MN_6M)

	**** TOTAL 1 MONTH AVERAGE ****
	* Total monthly non food expenditure in cash/credit 
	gen HHExpNFTotal_Purch_MN_1M 	= HHExp_NonFood_Purch_MN_1M + (HHExp_NonFood_Purch_MN_6M/6)
	* Total monthly non-food gift/aid value
	gen HHExpNFTotal_GiftAid_MN_1M = HHExp_NonFood_GiftAid_MN_1M + (HHExp_NonFood_GiftAid_MN_6M/6)
	* Total monthly non-food
	gen HHExpNFTotal_1M = HHExpNFTotal_Purch_MN_1M + HHExpNFTotal_GiftAid_MN_1M
	gen PCExpNFTotal_1M = HHExpNFTotal_1M/HHSize
	
	**** TOTAL **** 
	gen HHExpTotal = HHExpFoodTotal_1M + HHExpNFTotal_1M
	gen PCExpTotal = HHExpTotal/HHSize
	
	* Change unit to 1k 
	gen HHExpFoodTotal_1M_k = HHExpFoodTotal_1M/1000
	gen HHExpNFTotal_1M_k	= HHExpNFTotal_1M/1000
	gen HHExpTotal_k		= HHExpTotal/1000

	gen PCExpFoodTotal_1M_k = PCExpFoodTotal_1M/1000
	gen PCExpNFTotal_1M_k	= PCExpNFTotal_1M/1000
	gen PCExpTotal_k		= PCExpTotal/1000

	gl out_exp HHExp_Food_Purch_MN_7D HHExp_Food_GiftAid_MN_7D HHExp_Food_Own_MN_7D ///
			   HHExpFoodTotal_7D HHExpFoodTotal_1M PCExpFoodTotal_1M 				///
			   HHExp_NonFood_Purch_MN_1M HHExp_NonFood_GiftAid_MN_1M 				///
			   HHExp_NonFood_Purch_MN_6M HHExp_NonFood_GiftAid_MN_6M 				///
			   HHExpNFTotal_Purch_MN_1M HHExpNFTotal_GiftAid_MN_1M 					///
			   HHExpNFTotal_1M PCExpNFTotal_1M HHExpTotal PCExpTotal
			   
	gl out_exp_1k HHExpFoodTotal_1M_k PCExpFoodTotal_1M_k HHExpNFTotal_1M_k 		///
				  PCExpNFTotal_1M_k HHExpTotal_k PCExpTotal_k
				    
********************************************************************************
*						PART 2: Label Variables
*******************************************************************************/
	
	label var HHExp_Food_Purch_MN_7D 		"Total weekly food expenditure on cash/credit"
	label var HHExp_Food_GiftAid_MN_7D 		"Total weekly food expenditure from gift aid"
	label var HHExp_Food_Own_MN_7D 			"Total weekly food expenditure from own production"
	label var HHExpFoodTotal_7D				"Total weekly food expenditure"	
	label var HHExpFoodTotal_1M				"Total monthly food expenditure (average)"
	
	label var HHExp_NonFood_Purch_MN_1M		"Total monthly non-food expenditure on cash/credit"
	label var HHExp_NonFood_GiftAid_MN_1M	"Total monthly non-food expenditure from gift aid"	
	label var HHExp_NonFood_Purch_MN_6M		"Total other non-food expenditure on cash/credit in 6 months"
	label var HHExp_NonFood_GiftAid_MN_6M	"Total other non-food expenditure from gift aid in 6 months"	
	label var HHExpNFTotal_Purch_MN_1M 		"Total monthly non-food exp on cash (average)"
	label var HHExpNFTotal_GiftAid_MN_1M 	"Total monthly non-food exp from aid (average)"
	label var HHExpNFTotal_1M				"Total monthly non-food expenditure (average)"
	
	label var HHExpTotal 					"Monthly total household expenditure"
	label var PCExpTotal					"Monthly total household expenditure per capita"
	
********************************************************************************
*						PART 3: Comparison Analysis
*******************************************************************************/
	keep if Status == 2
	* Pairwise t-test - Balance Table
	iebaltab 	$out_exp_1k $out_exp,	 ///
				grpvar(Group) grplabels(1 Group A @ 2 Group B) ///
				savexlsx("${tabs_exp}/Iraq_F2F_Group_Expenditure_Refugee_Balance.xlsx") replace
				
	* bar graph by group 			
	graph bar (mean) HHExpFoodTotal_1M_k HHExpNFTotal_1M_k HHExpTotal_k, 	///
	over(Group, gap(200)) graphregion(color(white)) bgcolor(white) 			///
	blabel(bar, format(%4.1f) size(2)) 										///
	title("Iraq F2F: Consumption Expenditure Reporting", size(5)) 			///
	subtitle("Long Module (Group A) vs. Short Module (Group B)", size(3))   ///
	outergap(50) bargap(60) ylabel(0(100)700, nogrid labsize(2.5)) 			///
	ytitle("Household Monthly Consumption in 1k Iraqi Dinar", size(2.5))	///
	note("Note: N = 590 (Group A = 305 & Group B = 285)", ring(4) pos(6) size(2.5)) 	///
	legend(ring(4) pos(6) rows(1)					///
	  lab(1 "Total food expenditure") 				///
	  lab(2 "Total non-food expenditure") 			///
	  lab(3 "Total household expenditure") size(2.5))
	graph export "${figs_exp}/Iraq_Exp_F2F_HH_Total_Group.png", replace
	
	graph bar (mean) PCExpFoodTotal_1M_k PCExpNFTotal_1M_k PCExpTotal_k, 	///
	over(Group, gap(200)) graphregion(color(white)) bgcolor(white) 			///
	blabel(bar, format(%4.1f) size(2)) 										///
	title("Iraq F2F: Consumption Expenditure Reporting", size(5)) 			///
	subtitle("Long Module (Group A) vs. Short Module (Group B)", size(3))   ///
	outergap(50) bargap(60) ylabel(0(50)150, nogrid labsize(2.5)) 			///
	ytitle("Household Per Capita Monthly Consumption in 1k Iraqi Dinar", size(2.5))		///
	note("Note: N = 590 (Group A = 305 & Group B = 285)", ring(4) pos(6) size(2.5)) 	///
	legend(ring(4) pos(6) rows(1)									///
	  lab(1 "Per capita food expenditure") 				///
	  lab(2 "Per capita non-food expenditure") 			///
	  lab(3 "Per capita household expenditure") size(2.5))
	graph export "${figs_exp}/Iraq_Exp_F2F_PC_Total_Group.png", replace
	

	
	graph bar (mean) PCExpFoodTotal_1M_k PCExpNFTotal_1M_k PCExpTotal_k, 	///
	over(Group, gap(200)) graphregion(color(white)) bgcolor(white) 			///
	blabel(bar, format(%4.1f) size(2)) 										///
	title("Iraq F2F Refugee: Consumption Expenditure Reporting", size(5)) 			///
	subtitle("Long Module (Group A) vs. Short Module (Group B)", size(3))   ///
	outergap(50) bargap(60) ylabel(0(50)150, nogrid labsize(2.5)) 			///
	ytitle("Household Per Capita Monthly Consumption in 1k Iraqi Dinar", size(2.5))		///
	note("Note: N = 590 (Group A = 305 & Group B = 285)", ring(4) pos(6) size(2.5)) 	///
	legend(ring(4) pos(6) rows(1)									///
	  lab(1 "Per capita food expenditure") 				///
	  lab(2 "Per capita non-food expenditure") 			///
	  lab(3 "Per capita household expenditure") size(2.5))
	graph export "${figs_exp}/Iraq_Exp_F2F_PC_Total_Refugee.png", replace
	
	
	* Monthly average food expenditure in 1k by source
	graph bar (mean) HHExp_Food_Purch_MN_1M_k HHExp_Food_GiftAid_MN_1M_k 	///
					 HHExp_Food_Own_MN_1M_k, 								///
	over(Group, gap(200)) graphregion(color(white)) bgcolor(white) 			///
	stack blabel(bar, format(%4.1f) size(2) pos(base)) 						///
	title("Iraq F2F: Food Consumption Expenditure Reporting", size(5)) 		///
	subtitle("Long Module (Group A) vs. Short Module (Group B) by Source", size(3))   ///
	outergap(50) bargap(60) ylabel(0(50)300, nogrid labsize(2.5)) 			///
	ytitle("Household Monthly Consumption in 1k Iraqi Dinar", size(2.5))	///
	note("Note: N = 590 (Group A = 305 & Group B = 285)", ring(4) pos(6) size(2.5)) 	///
	legend(ring(4) pos(6) rows(1)					///
	  lab(1 "Food expenditure on Purchase") 		///
	  lab(2 "Food value from gift/aid") 			///
	  lab(3 "Food value from own production") size(2.5))
	graph export "${figs_exp}/Iraq_Exp_F2F_HH_Food_Source_Group.png", replace 
	