/* *************************************************************************** *
*						WFP RAM-N rCARI Validation Study - Iraq 			   * 
*																 			   *
*  PURPOSE:  			Create clean variables for F2F						   *
*  AUTHOR: 				Nicole Wu (nicole.wu@wfp.org)						   *
*  DATE:  				Mar 30, 2023										   *
*  LATEST UPDATE: 		Apr 17, 2023										   *
*		  																	   *
********************************************************************************

					
	** REQUIRES:	${dta}/Iraq_F2F_Household_Raw.dta
					
	** CREATES:		${dta}/Iraq_F2F_Household_Analysis.dta
								
	** NOTES:		N = 590 (Group A = 305 and Group B = 285)
					Dietary_intake section not in this dataset
					For subgroups of FCS, only respondents in Group A were asked
					For LCS, EN for Group A and Food for Group B
					
********************************************************************************
*								Define Variables
*******************************************************************************/
	
	cap log close 
	
	// set log
	loc cdate: di %td_CCYY_NN_DD date(c(current_date), "DMY")
	loc cdate = subinstr(trim("`cdate'"), " " , "", .)
	log using "${logs}/i02_organize_`cdate'.smcl", replace
	di `cdate'
	
	* load dataset
	use "${dta}/Iraq_F2F_Household_Raw.dta", clear 
	
	gen 	Status = 1 if (ADMIN5Name == 1 | ADMIN5Name == 8) 
	replace Status = 2 if (ADMIN5Name == 2 | ADMIN5Name == 7) 
	
	gen 	Modality	= (F2F_Rmt == 1 | F2F_Rmt == 3)
	replace Modality	= 2 if Modality == 0
	
** Demongraphics and basic respondents/household information

	gen RESPHHH 	= (RESPRelationHHH 		== 100)
	gen RESPFemale	= (RESPSex				== 0)
	gen RESPPLW 	= (RESPplw 				== 1)
	gen HHDisplaced = (HHStatus 			== 2)
	gen HHRefugee	= (HHStatus 			== 3)
	
	// Household roster dropped in this dataset, potentially add more vars
	gl var_demo RESPAge RESPSex RESPFemale RESPHHH RESPPLW HHSize MDDIHHDisabledNb ///
				MDDIHHChronIllNb HHDisplaced HHRefugee HHhostDisp

** Asset
	** Household Assets Items (missing as 0 due to the design)
	gen HHAsset_WaterFilter = (WealthSimpleHouseholdItems_1 == 1)
	gen HHAsset_Carpet  	= (WealthSimpleHouseholdItems_2 == 1)
	gen HHAsset_ElecLamp	= (WealthSimpleHouseholdItems_3 == 1)
	gen HHAsset_ElecStove 	= (WealthSimpleHouseholdItems_4 == 1)
	gen HHAsset_WaterTank 	= (WealthSimpleHouseholdItems_5 == 1)
	
	gen HHAsset_MicroOven 	= (WealthBasicElecItems_1 == 1)
	gen HHAsset_Fridge		= (WealthBasicElecItems_2 == 1)
	gen HHAsset_Blender		= (WealthBasicElecItems_3 == 1)
	gen HHAsset_GasHeater	= (WealthBasicElecItems_4 == 1)
	gen HHAsset_ElecFan	 	= (WealthBasicElecItems_5 == 1)
	
	gen HHAsset_Freezer	 	= (WealthAdvElecItems_1 == 1)
	gen HHAsset_AC	 		= (WealthAdvElecItems_2 == 1)
	gen HHAsset_ElecGen	 	= (WealthAdvElecItems_3 == 1)
	gen HHAsset_ElecVac	 	= (WealthAdvElecItems_4 == 1)
	gen HHAsset_WashMachine	= (WealthAdvElecItems_5 == 1)
	
	gen HHAsset_TickTokCar 	= (WealthTransportAssets_1 == 1)
	gen HHAsset_Taxi	 	= (WealthTransportAssets_2 == 1)
	gen HHAsset_PriCarTruck	= (WealthTransportAssets_3 == 1)
	gen HHAsset_Motor	 	= (WealthTransportAssets_4 == 1)
	gen HHAsset_Bicycle	 	= (WealthTransportAssets_5 == 1)
		
gl  var_assets HHAsset_WaterFilter HHAsset_Carpet HHAsset_ElecLamp HHAsset_ElecStove  ///
			   HHAsset_WaterTank HHAsset_MicroOven HHAsset_Fridge HHAsset_Blender 	  ///
			   HHAsset_GasHeater HHAsset_ElecFan HHAsset_Freezer HHAsset_AC		  	  ///
			   HHAsset_ElecGen HHAsset_ElecVac HHAsset_WashMachine HHAsset_TickTokCar ///
			   HHAsset_Taxi HHAsset_PriCarTruck HHAsset_Motor HHAsset_Bicycle
			   
	** Housing Type
	tab  HHDwellType_oth
	tab  HHDwellType, gen(HHDwellType_)
	ren  HHDwellType_1 HHDwell_House
	ren  HHDwellType_5 HHDwell_LeatherTent
	drop HHDwellType_2 HHDwellType_3 HHDwellType_4
	
	** Tenure Type
	tab  HHTenureType_oth
	tab  HHTenureType, gen(HHTenureType_)
	ren  HHTenureType_5 HHTenure_FreeCon
	ren  HHTenureType_6 HHTenure_FreeNoCon
	drop HHTenureType_1 HHTenureType_2 HHTenureType_3 HHTenureType_4

	** Wall Materials
	tab  HHWallType_oth
	tab  HHWallType, gen(HHWallType_)
	ren  HHWallType_1 HHWall_BakedBrick
	ren  HHWallType_2 HHWall_UnbakedBrick
	ren  HHWallType_3 HHWall_Cement
	ren  HHWallType_5 HHWall_PlasticSheet
	drop HHWallType_4 HHWallType_6 HHWallType_7
				   
	** Roof Materials // other specify to be cleaned
	tab  HHRoofType_oth
	tab  HHRoofType
	tab  HHRoofType, gen(HHRoofType_)
	ren  HHRoofType_1 HHRoof_Brick
	ren  HHRoofType_5 HHRoof_IronSheet
	ren  HHRoofType_7 HHRoof_Tent
	drop HHRoofType_2 HHRoofType_3 HHRoofType_4 HHRoofType_6 HHRoofType_8 HHRoofType_9
	
	** Floor Materials // other specify as ceramic, keep as is
	tab  HHFloorType_oth
	tab  HHFloorType, gen(HHFloorType_)
	ren  HHFloorType_1 HHFloor_Cement
	ren  HHFloorType_2 HHFloor_Dirt
	ren  HHFloorType_5 HHFloor_Tiles
	drop HHFloorType_3 HHFloorType_4 HHFloorType_6
	
	** Toilet Facility
	tab  HHToiletType, gen(HHToiletType_)
	tab  HHToiletType_oth
	ren  HHToiletType_2 HHToilet_FlushPit
	ren  HHToiletType_4 HHToilet_ImprovedPit
	drop HHToiletType_1 HHToiletType_3 HHToiletType_5 HHToiletType_6 HHToiletType_7
	
	** Cooking Fuel
	tab  HHEnerCookSRC, gen(HHEnerCookSRC_)
	ren  HHEnerCookSRC_4 HHEnerCook_Gas
	drop HHEnerCookSRC_1 HHEnerCookSRC_2 HHEnerCookSRC_3 HHEnerCookSRC_5 HHEnerCookSRC_6
	
	** Lighting Energy
	tab  HHEnerLightSRC, gen(HHEnerLightSRC_)
	ren  HHEnerLightSRC_2 HHEnerLight_Elec
	ren  HHEnerLightSRC_3 HHEnerLight_Gen
	drop HHEnerLightSRC_1 HHEnerLightSRC_4
	
	** Water Source
	tab  HHWaterSRC, gen(HHWaterSRC_)
	ren  HHWaterSRC_1 HHWater_Pipe
	ren  HHWaterSRC_3 HHWater_Tube
	ren  HHWaterSRC_5 HHWater_Tank
	drop HHWaterSRC_2 HHWaterSRC_4 HHWaterSRC_6 HHWaterSRC_7 HHWaterSRC_8
	
	gl   var_house HHDwell_House HHDwell_LeatherTent HHTenure_FreeCon HHTenure_FreeNoCon 	///
				   HHWall_BakedBrick HHWall_UnbakedBrick HHWall_Cement HHWall_PlasticSheet 	///
				   HHRoof_Brick HHRoof_IronSheet HHRoof_Tent HHFloor_Cement HHFloor_Dirt 	///
				   HHFloor_Tiles HHToilet_FlushPit HHToilet_ImprovedPit HHEnerCook_Gas		///
				   HHEnerLight_Elec HHEnerLight_Gen HHWater_Pipe HHWater_Tube HHWater_Tank
			
** Outcome: Household food security status 
	sum RESPFoodWorry_YN RESPPercFoodSec*
	
	gen RESPMeals_3More   = (RESPMeals 			== 3)
	gen RESPFoodWorry	  = (RESPFoodWorry_YN 	== 1)
	gen RESPFS_EnoughFood = (RESPPercFoodSec_1 	== 1)
	gen RESPFS_LessPrefer = (RESPPercFoodSec_2 	== 1)
	gen RESPFS_LessMeal   = (RESPPercFoodSec_3 	== 1)
	gen RESPFS_DayNoEat   = (RESPPercFoodSec_4 	== 1)
	
	** Number of Meals & Worried RESPMeals
	gen CARI_Meals = .
	replace CARI_Meals = 1 if RESPMeals == 3
	replace CARI_Meals = 2 if RESPMeals == 2
	replace CARI_Meals = 3 if RESPMeals == 1
	replace CARI_Meals = 4 if RESPMeals == 1 & RESPPercFoodSec_4 == 1

	gen CARI_Worry = .
	replace CARI_Worry = 1 if RESPFoodWorry_YN == 0
	replace CARI_Worry = 2 if RESPFoodWorry_YN == 1
	replace CARI_Worry = 3 if RESPFoodWorry_YN == 1 & RESPPercFoodSec_3 == 1
	replace CARI_Worry = 4 if RESPFoodWorry_YN == 1 & RESPPercFoodSec_4 == 1
							
	gl 	 out_fs RESPFoodWorry RESPFS_EnoughFood RESPFS_LessPrefer RESPFS_LessMeal 		///
				RESPFS_DayNoEat RESPMeals_3More
	
** Outcome: [FCS] Food consumption score 
	sum FCS*
	
/* quality checks
	egen FCSPr_Check = rowmax(FCSNPrMeatF FCSNPrMeatO FCSNPrFish FCSNPrEggs)
	replace FCSPr_Check = 0 if mi(FCSPr_Check)
	assert FCSPr >= FCSPr_Check 						// YES!	
	egen FCSVeg_Check = rowmax(FCSNVegOrg FCSNVegGre)
	replace FCSVeg_Check = 0 if mi(FCSVeg_Check)
	assert FCSVeg >= FCSVeg_Check 						// YES!	
	assert FCSFruit >= FCSNFruiOrg if !mi(FCSNFruiOrg)  // YES!	
*/	
	gen FCS = FCSStap * 2 + FCSPulse * 3 + FCSDairy * 4 + FCSPr * 4 + 		 ///
			  FCSVeg  * 1 + FCSFruit * 1 + FCSFat * 0.5 + FCSSugar * 0.5
	gen FCSCat28 = cond(FCS <= 28, 1, cond(FCS <= 42, 2, 3))
	
	gen 	FCG = 1 if (FCSCat28 == 1 | FCSCat28 == 2)
	replace FCG = 2 if (FCSCat28 == 3)
	
	gl  out_fcs FCSStap FCSPulse FCSDairy FCSPr FCSVeg FCSFruit FCSFat 		 ///
				FCSSugar FCSCond FCS FCSCat28 FCG 

** Outcome: [rCSI] Reduced Coping Strategies (rCSI - Gendered)

	gen rCSI 	 = rCSILessQlty * 1 + rCSIBorrow * 2 + rCSIMealNb * 1 + 	///
				   rCSIMealSize * 1 + rCSIMealAdult * 3
	gen rCSI_oth = rCSILessQlty_oth * 1 + rCSIBorrow_oth * 2 + 				///
				   rCSIMealNb_oth * 1 + rCSIMealSize_oth * 1 + 				///
				   rCSIMealAdult_oth * 3

	gl out_rcsi rCSILessQlty rCSIBorrow rCSIMealSize rCSIGenderMealSize rCSIMealAdult    ///
				rCSIGenderMealAdult rCSIMealNb rCSIGenderMealNb rCSI rCSILessQlty_oth 	 ///
				rCSIBorrow_oth rCSIMealSize_oth rCSIGenderMealSize_oth rCSIMealAdult_oth ///
				rCSIGenderMealAdult_oth rCSIMealNb_oth rCSIGenderMealNb_oth 			 ///
				rCSIRESPSex_oth rCSI_oth
	
** LCS 
	local  lcs  stress_DomAsset stress_CrdtFood stress_Saving 			///
				stress_BorrowCash crisis_ProdAssets crisis_HealthEdu	///
				crisis_OutSchool em_ChildWork em_Begged em_IllegalAct
				
foreach item of local lcs{
	replace Lcs_`item' = LcsEN_`item' if mi(Lcs_`item') & Group == 1
	sum Lcs_`item'
	label val Lcs_`item' LcsEN_`item'
}	
	
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
	
	gl  out_lcs  Lcs_Stress_Coping Lcs_Crisis_Coping 			  ///
				 Lcs_Emergency_Coping LCS_Cat
	
** Outcome: [FES] Food Expenditure Share

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
	
***** NON-FOOD EXPENDITURE *****************************************************
	
	**** 1 MONTH ****
	* Monthly non food expenditure in cash/credit (10 vars)
egen HHExp_NonFood_Purch_MN_1M = rowtotal(HHExpNFHyg_Purch_MN_1M HHExpNFTransp_Purch_MN_1M ///
	 HHExpNFFuel_Purch_MN_1M HHExpNFWat_Purch_MN_1M HHExpNFEnerg_Purch_MN_1M 			   ///
	 HHExpNFDwelSer_Purch_MN_1M HHExpNFPhone_Purch_MN_1M HHExpNFRecr_Purch_MN_1M 		   ///
	 HHExpNFAlcTobac_Purch_MN_1M HHExpNFTranspFuel_Purch_MN_1M)

	 * Monthly non food gift/aid value (10 vars)
egen HHExp_NonFood_GiftAid_MN_1M = rowtotal(HHExpNFHyg_GiftAid_MN_1M 			 	///
	 HHExpNFTransp_GiftAid_MN_1M HHExpNFFuel_GiftAid_MN_1M HHExpNFWat_GiftAid_MN_1M ///
	 HHExpNFEnerg_GiftAid_MN_1M HHExpNFDwelSer_GiftAid_MN_1M 						///
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
	
	** Income
	tab HHIncFirst_oth
	ren HHIncFirst_oth HHIncFirst_Oth
	replace HHIncFirst_SRi = 12 if HHIncFirst_Oth == "استأجار محل صغير وبيع العاب اطفال/اخي يدفع اجار المحل" | HHIncFirst_Oth == "صاحب بقالية صغيرة"
	// Renting a small shop and selling toys for my brother/children - small business
	// Owner of a small grocery - small business
	replace HHIncFirst_SRi = 7 if HHIncFirst_Oth == "رعاية" | HHIncFirst_Oth == "رعايه اجتماعية"
	// Care and Social care - Aid/gifts
	replace HHIncFirst_SRi = 1 if HHIncFirst_Oth == "مدرس" | HHIncFirst_Oth == "معلم"
	// Teacher
	
	gen CARI_Inc = .
	replace CARI_Inc = 1 if inlist(HHIncFirst_SRi, 1, 2, 5, 12, 13, 15) & inlist(HHIncChg, 0, 1, 5)
	replace CARI_Inc = 2 if inlist(HHIncFirst_SRi, 1, 2, 5, 12, 13, 15) & inlist(HHIncChg, 2, 3, 4)
	replace CARI_Inc = 2 if inlist(HHIncFirst_SRi, 3, 4, 6, 11) & inlist(HHIncChg, 0, 1, 5)
	replace CARI_Inc = 3 if inlist(HHIncFirst_SRi, 3, 4, 6, 11) & inlist(HHIncChg, 2, 3, 4)
	replace CARI_Inc = 4 if HHIncNb == 0 | inlist(HHIncFirst_SRi, 7, 8, 9, 10)
	replace CARI_Inc = 5 if HHIncFirst_SRi == 999
	* Recode missing values
	replace CARI_Inc = . if CARI_Inc == 5
	
** Outcome: [CARI] COMBINING CURRENT STATUS AND COPING CAPACITY
	recode  FCSCat28 (1 = 4) (2 = 3) (3 = 1), gen(FCS_4pt_CARI)
	replace FCS_4pt_CARI = 2 if FCSCat28 == 3 & rCSI >= 4
	
	gen CC_FES_Cat   = (FES_Cat + LCS_Cat)/2	// no round here
	gen CARI_FES_Raw = (FCS_4pt_CARI + CC_FES_Cat)/2
	gen CARI_FES_Cat = round(CARI_FES_Raw)
	gen HH_Vul_CARI  = (CARI_FES_Cat == 3 | CARI_FES_Cat == 4)

	gen CC_Inc_Cat   = (CARI_Inc + LCS_Cat)/2	// no round here
	gen CARI_Inc_Raw = (FCS_4pt_CARI + CC_Inc_Cat)/2
	gen CARI_Inc_Cat = round(CARI_Inc_Raw)
	gen HH_Vul_Income  = (CARI_Inc_Cat == 3 | CARI_Inc_Cat == 4)
	
	gl out_cari FCS_4pt_CARI CC_FES_Cat CARI_FES_Cat HH_Vul_CARI CC_Inc_Cat CARI_Inc_Cat HH_Vul_Income
	
** Gendered Comparison: Minimum Dietary Diversity for an adult
	tab MDDR_Sex RESPSex
	tab MDDWSexR MDDR_Sex
	tab RESPSex  MDDWSexR
	
	// very different results which seem like 3 people involved
	// Standard MDDW method - SNF home group will be grains
	gen MDDW_Staples 	 = (PWMDDWStapCerR == 1 |  PWMDDWStapRooR == 1 | PWMDDWSnfR == 1) if !mi(PWMDDWStapCerR)
	gen MDDW_Pulses		 = (PWMDDWPulseR == 1)  if !mi(PWMDDWPulseR)
	gen MDDW_NutsSeeds	 = (PWMDDWNutsR == 1)	if !mi(PWMDDWNutsR)
	gen MDDW_Dairies	 = (PWMDDWDairyR == 1 	| PWMDDWMilkR == 1) if !mi(PWMDDWDairyR)
	gen MDDW_MeatFish	 = (PWMDDWPrMeatOR == 1 | PWMDDWPrMeatFR == 1 | PWMDDWPrMeatProR == 1 | ///
							PWMDDWPrMeatWhiteR == 1 |  PWMDDWPrFishR == 1) if !mi(PWMDDWPrMeatOR)
	gen MDDW_Eggs		 = (PWMDDWPrEggR == 1)  if !mi(PWMDDWPrEggR)
	gen MDDW_LeafGVeg	 = (PWMDDWVegGreR == 1) if !mi(PWMDDWVegGreR)
	gen MDDW_VitA  		 = (PWMDDWVegOrgR == 1 | PWMDDWFruitOrgR == 1) if !mi(PWMDDWVegOrgR)
    gen MDDW_OtherVeg  	 = (PWMDDWVegOthR == 1) if !mi(PWMDDWVegOthR)
    gen MDDW_OtherFruits = (PWMDDWFruitOthR == 1) if !mi(PWMDDWFruitOthR)
	gen MDDW_Index = MDDW_Staples + MDDW_Pulses + MDDW_NutsSeeds + MDDW_Dairies + MDDW_MeatFish + ///
			   MDDW_Eggs + MDDW_LeafGVeg + MDDW_VitA + MDDW_OtherVeg + MDDW_OtherFruits if !mi(MDDW_Staples)
	gen MDDW_Index_5 = (MDDW_Index >= 5) if !mi(MDDW_Index)
	
	gen MDDW_Staples_oth 	 = (PWMDDWStapCer_oth == 1 |  PWMDDWStapRoo_oth == 1 | PWMDDWSnf_oth == 1) if !mi(PWMDDWStapCer_oth)
	gen MDDW_Pulses_oth		 = (PWMDDWPulse_oth == 1)  if !mi(PWMDDWPulse_oth)
	gen MDDW_NutsSeeds_oth	 = (PWMDDWNuts_oth == 1)	if !mi(PWMDDWNuts_oth)
	gen MDDW_Dairies_oth	 = (PWMDDWDairy_oth == 1 	| PWMDDWMilk_oth == 1) if !mi(PWMDDWDairy_oth)
	gen MDDW_MeatFish_oth	 = (PWMDDWPrMeatO_oth == 1 | PWMDDWPrMeatF_oth == 1 | PWMDDWPrMeatPro_oth == 1 | ///
							PWMDDWPrMeatWhite_oth == 1 |  PWMDDWPrFish_oth == 1) if !mi(PWMDDWPrMeatO_oth)
	gen MDDW_Eggs_oth		 = (PWMDDWPrEgg_oth == 1)  if !mi(PWMDDWPrEgg_oth)
	gen MDDW_LeafGVeg_oth= (PWMDDWVegGre_oth == 1) if !mi(PWMDDWVegGre_oth)
	gen MDDW_VitA_oth  		 = (PWMDDWVegOrg_oth == 1 | PWMDDWFruitOrg_oth == 1) if !mi(PWMDDWVegOrg_oth)
    gen MDDW_OtherVeg_oth  	 = (PWMDDWVegOth_oth == 1) if !mi(PWMDDWVegOth_oth)
    gen MDDW_OtherFruits_oth = (PWMDDWFruitOth_oth == 1) if !mi(PWMDDWFruitOth_oth)
	gen MDDW_Index_oth = MDDW_Staples_oth + MDDW_Pulses_oth + MDDW_NutsSeeds_oth + MDDW_Dairies_oth + MDDW_MeatFish_oth + ///
			   MDDW_Eggs_oth + MDDW_LeafGVeg_oth + MDDW_VitA_oth + MDDW_OtherVeg_oth + MDDW_OtherFruits_oth if !mi(MDDW_Staples_oth)
	gen MDDW_Index_5_oth = (MDDW_Index_oth >= 5) if !mi(MDDW_Index_oth)

	gl out_mdd PWMDDWStapCerR PWMDDWStapRooR PWMDDWPulseR PWMDDWNutsR PWMDDWMilkR   ///
			   PWMDDWDairyR PWMDDWPrMeatOR PWMDDWPrMeatFR PWMDDWPrMeatProR 			///
			   PWMDDWPrMeatWhiteR PWMDDWPrFishR PWMDDWPrEggR PWMDDWVegGreR 			///
			   PWMDDWVegOrgR PWMDDWFruitOrgR PWMDDWVegOthR PWMDDWFruitOthR 			///
			   PWMDDWSnfR PWMDDWStapCer_oth PWMDDWStapRoo_oth PWMDDWPulse_oth 		///
			   PWMDDWNuts_oth PWMDDWMilk_oth PWMDDWDairy_oth PWMDDWPrMeatO_oth 		///
			   PWMDDWPrMeatF_oth PWMDDWPrMeatPro_oth PWMDDWPrMeatWhite_oth 			///
			   PWMDDWPrFish_oth PWMDDWPrEgg_oth PWMDDWVegGre_oth PWMDDWVegOrg_oth 	  ///
			   PWMDDWFruitOrg_oth PWMDDWVegOth_oth PWMDDWFruitOth_oth PWMDDWSnf_oth   ///
			   MDDR_Sex MDDWSexR MDDW_Staples MDDW_Pulses MDDW_NutsSeeds MDDW_Dairies ///
			   MDDW_MeatFish MDDW_Eggs MDDW_LeafGVeg MDDW_VitA MDDW_OtherVeg 	  ///
			   MDDW_OtherFruits MDDW_Index MDDW_Index_5 MDDW_Staples_oth 			  ///
			   MDDW_Pulses_oth MDDW_NutsSeeds_oth MDDW_Dairies_oth MDDW_MeatFish_oth  ///
			   MDDW_Eggs_oth MDDW_LeafGVeg_oth MDDW_VitA_oth MDDW_OtherVeg_oth 	  ///
			   MDDW_OtherFruits_oth MDDW_Index_oth MDDW_Index_5_oth

* Gender Empowerment Scale 
	tab GEN_SexR GENRESPSex_oth

	gl  out_empower Income_No_PermissionR Own_Decisions_MoneyR Own_Decisions_MedicalR 	  ///
				    Own_Decisions_RelativesR Own_Decisions_FriendsR Own_Bank_AccountR 	  ///
				    Have_Money_SavedR Own_PropertyR Own_MobileR You_Decide_WorkR 		  ///
				    Took_Money_No_PermissionR Permission_Local_EventR Permission_MarketR   ///
				    Most_Time_HouseworkR Housework_Prevented_WorkR 						  ///
				    Housework_Prevent_EducationR HarmR MarriageR Decide_Prevent_PregnancyR ///
				    Income_No_Permission_oth Own_Decisions_Money_oth 					  ///
				    Own_Decisions_Medical_oth Own_Decisions_Relatives_oth 				  ///
				    Own_Decisions_Friends_oth Own_Bank_Account_oth Have_Money_Saved_oth 	  ///
				    Own_Property_oth Own_Mobile_oth You_Decide_Work_oth 					  ///
				    Took_Money_No_Permission_oth Permission_Local_Event_oth 				  ///
				    Permission_Market_oth Most_Time_Housework_oth 						  ///
				    Housework_Prevented_Work_oth Housework_Prevent_Education_oth Harm_oth  ///
				    Marriage_oth Decide_Prevent_Pregnancy_oth GEN_SexR GENRESPSex_oth
	
********************************************************************************
*						PART 3: Label Variables
*******************************************************************************/	

	label def YesNo  		0 "No"   1 "Yes"
	label val $var_assets $var_house Lcs_Stress_Coping Lcs_Crisis_Coping ///
			  Lcs_Emergency_Coping HH_Vul_CARI YesNo
	
	label def FCSCat 		1 "Poor" 2 "Borderline" 3 "Acceptable"
	label val FCSCat28 FCSCat
	
	label def Status_l 		1 "IDP" 2 "Refugee"
	label val Status Status_l
	
	label def FCG_l 		1 "FCS Poor or Borderline" 2 "FCS Acceptable"
	label val FCG FCG_l
	
	label def CARI_Meals_lbl 1 "Three meals" ///
                             2 "Two meals"   ///
                             3 "One meal"   ///
                             4 "No meals"
	label val CARI_Meals CARI_Meals_lbl
	
	label def CARI_Worry_lbl 1 "Not worried" ///
							 2 "Worried"	 ///
                             3 "Worried & skipping meals" ///
                             4 "Worried & going day/night without eating"
	label val CARI_Worry CARI_Worry_lbl
	
	label var RESPHHH				"Head of Household Respondent"
	label var RESPAge				"Respondent Age"
	label var RESPFemale			"Female Respondent"
	label var RESPPLW				"Pregnant or Lactating Respondent"
	label var HHDisplaced			"IDP Household"
	label var HHRefugee				"Refugee Household"
	label var HHhostDisp			"Household currently hosting IDP or Refugee"
	label var HHSize				"Household Size"
	label var MDDIHHDisabledNb		"Number of disabled household members"
	label var MDDIHHChronIllNb		"Number of household members with chronic disease"	
	label var HHAsset_WaterFilter	"Household owns water filter"
	label var HHAsset_Carpet		"Household owns carpet/rug"
	label var HHAsset_ElecLamp		"Household owns electric lamp"
	label var HHAsset_ElecStove 	"Household owns electric stoves/tannour"
	label var HHAsset_WaterTank		"Household owns water tank"
	label var HHAsset_MicroOven		"Household owns oven/microwave"
	label var HHAsset_Fridge		"Household owns refrigerator"
	label var HHAsset_Blender		"Household owns blender"
	label var HHAsset_GasHeater		"Household owns gas heater"
	label var HHAsset_ElecFan		"Household owns electric fan"
	label var HHAsset_Freezer		"Household owns freezer"
	label var HHAsset_AC			"Household owns air conditioner"
	label var HHAsset_ElecGen		"Household owns electric generator"
	label var HHAsset_ElecVac		"Household owns electric vacuum"
	label var HHAsset_WashMachine	"Household owns automatic washing machine"
	label var HHAsset_TickTokCar	"Household owns ticktok car"
	label var HHAsset_Taxi			"Household owns taxi"
	label var HHAsset_PriCarTruck	"Household owns private car/truck"
	label var HHAsset_Motor			"Household owns motorcycle/electronic motorcycle"
	label var HHAsset_Bicycle		"Household owns bicycle"
	
	label var HHDwell_House			"Household Dwell: House"
	label var HHDwell_LeatherTent	"Household Dwell: Leather Tent"
	label var HHTenure_FreeCon		"Household Tenure: Free to live with contract"
	label var HHTenure_FreeNoCon	"Household Tenure: Free to live without contract"
	label var HHWall_BakedBrick		"Household Wall: Baked bricks"
	label var HHWall_UnbakedBrick	"Household Wall: Unbaked bricks"
	label var HHWall_Cement			"Household Wall: Cement"
	label var HHWall_PlasticSheet	"Household Wall: Plastic sheet"
	label var HHRoof_Brick			"Household Roof: Brick"
	label var HHRoof_IronSheet		"Household Roof: Iron sheet"
	label var HHRoof_Tent			"Household Roof: Tent"
	label var HHFloor_Cement		"Household Floor: Cement"
	label var HHFloor_Dirt			"Household Floor: Dirt"
	label var HHFloor_Tiles			"Household Floor: Tiles"
	label var HHToilet_FlushPit		"Household Toilet: Pour-flush to pit"
	label var HHToilet_ImprovedPit	"Household Toilet: Improved pit latrine"
	label var HHEnerCook_Gas		"Household Cooking Fuel: Gas"
	label var HHEnerLight_Elec		"Household Lighting: Electricity"
	label var HHEnerLight_Gen		"Household Lighting: Generator"
	label var HHWater_Pipe			"Household Water Source: Piped water"
	label var HHWater_Tube			"Household Water Source: Tube well/borehole (and pump)"
	label var HHWater_Tank			"Household Water Source: Tanker truck"
	
	label var RESPMeals_3More		"Respondent and family ate 3 or more meals yesterday"
	label var RESPFoodWorry			"Respondent and family worried about no enough food in past 30 days"
	label var RESPFS_EnoughFood		"Household had no difficulties eating enough food in past 7 days"
	label var RESPFS_LessPrefer		"Household ate less preferred foods in past 7 days"
	label var RESPFS_LessMeal		"Household skipped meals or ate less than usual in past 7 days"
	label var RESPFS_DayNoEat		"Household went one whole day without eating in past 7 days"
	
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
	label var rCSI_oth				"Reduced Consumption Strategies Index (rCSI) for other respondent"
	
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
	
	label var HHExp_NonFood_Purch_MN_1M		"Total monthly non-food expenditure on cash/credit"
	label var HHExp_NonFood_GiftAid_MN_1M	"Total monthly non-food expenditure from gift aid"	
	label var HHExp_NonFood_Purch_MN_6M		"Total other non-food expenditure on cash/credit in 6 months"
	label var HHExp_NonFood_GiftAid_MN_6M	"Total other non-food expenditure from gift aid in 6 months"	
	label var HHExpNFTotal_Purch_MN_1M 		"Total monthly non-food exp on cash (average)"
	label var HHExpNFTotal_GiftAid_MN_1M 	"Total monthly non-food exp from aid (average)"
	label var HHExpNFTotal_1M				"Total monthly non-food expenditure (average)"
	
	label var HHExpTotal 			"Monthly total household expenditure"
	label var PCExpTotal			"Monthly total household expenditure per capita"
	label var FES					"Food Expenditure Share"
	label var FES_Cat				"Food Security Category based on FES"
	
	label def FS_CARI	   1 "Food Secure"  2 "Marginally Food Secure" 				///
						   3 "Moderately Food Insecure" 4 "Severely Food Insecure"
	label val FCS_4pt_CARI CARI_FES_Cat FES_Cat CARI_Inc_Cat FS_CARI	   
	
	label var CC_FES_Cat			"Coping Capacity Combined Category using FES"
	label var CARI_FES_Raw			"Raw CARI Category based on FES"
	label var CARI_FES_Cat			"CARI Category using FES"
	label var HH_Vul_CARI			"Household being vulnerable using FES CARI"
	label var Group					"Study Group A vs. B"
	label var Status				"Household Status IDP vs. Refugee" 
	label var CC_Inc_Cat			"Coping Capacity Combined Category using Income"
	label var CARI_Inc_Raw			"Raw CARI Category based on Income"
	label var CARI_Inc_Cat			"CARI Category using Income"
	label var HH_Vul_Income			"Household being vulnerable using Income rCARI"
	
	label def survey_l	1 "Remote first" 2 "Face-to-Face first"
	label val Modality  survey_l
	label var Modality				"Survey Modality: Remote first vs. F2F first"
	
	label var PWMDDWStapCerR		"Foods made from grains"
	label var PWMDDWStapRooR		"White roots and tubers or plantains"
	label var PWMDDWPulseR			"Pulses (beans, peas and lentils)"
	label var PWMDDWNutsR			"Nuts and seeds"
	label var PWMDDWMilkR			"Milk"
	label var PWMDDWDairyR			"Milk products"
	label var PWMDDWPrMeatOR		"Organ meats"
	label var PWMDDWPrMeatFR		"Red flesh meat from mammals"
	label var PWMDDWPrMeatProR		"Processed meat"
	label var PWMDDWPrMeatWhiteR	"Poultry and other white meats"
	label var PWMDDWPrFishR			"Fish and Seafood"
	label var PWMDDWPrEggR			"Eggs from poultry or any other bird"
	label var PWMDDWVegGreR 		"Dark green leafy vegetable"
	label var PWMDDWVegOrgR			"Vitamin A-rich vegetables, roots and tubers"
	label var PWMDDWFruitOrgR		"Vitamin A-rich fruits"
	label var PWMDDWVegOthR			"Other vegetables"
	label var PWMDDWFruitOthR		"Other fruits"
	label var PWMDDWSnfR			"Specialized Nutritious Foods (SNF) for women"

	label var PWMDDWStapCer_oth		"Foods made from grains"
	label var PWMDDWStapRoo_oth		"White roots and tubers or plantains"
	label var PWMDDWPulse_oth		"Pulses (beans, peas and lentils) "
	label var PWMDDWNuts_oth		"Nuts and seeds "
	label var PWMDDWMilk_oth		"Milk"
	label var PWMDDWDairy_oth		"Milk products"
	label var PWMDDWPrMeatO_oth 	"Organ meats"
	label var PWMDDWPrMeatF_oth 	"Red flesh meat from mammals"
	label var PWMDDWPrMeatPro_oth 	"Processed meat"
	label var PWMDDWPrMeatWhite_oth "Poultry and other white meats"
	label var PWMDDWPrFish_oth 		"Fish and Seafood"
	label var PWMDDWPrEgg_oth 		"Eggs from poultry or any other bird"
	label var PWMDDWVegGre_oth  	"Dark green leafy vegetable"
	label var PWMDDWVegOrg_oth 		"Vitamin A-rich vegetables, roots and tubers"
	label var PWMDDWFruitOrg_oth 	"Vitamin A-rich fruits"
	label var PWMDDWVegOth_oth 		"Other vegetables"
	label var PWMDDWFruitOth_oth 	"Other fruits"
	label var PWMDDWSnf_oth 		"Specialized Nutritious Foods (SNF) for women"

	label var Income_No_PermissionR			"Had Income to Use Without Asking For Permission"
	label var Own_Decisions_MoneyR			"Can Make Own Decisions About What to do With Money"
	label var Own_Decisions_MedicalR		"Can Make Own Decisions About Seeking Medical or Healthcare Services"
	label var Own_Decisions_RelativesR		"Can Make Own Decisions About Spending Time With Relatives"
	label var Own_Decisions_FriendsR		"Can Make Own Decisions About Spending Time With Friends"
	label var Own_Bank_AccountR				"Have Own Account With a Bank or Other Financial Institution"
	label var Have_Money_SavedR				"Have Money Saved To Use if Needed"
	label var Own_PropertyR					"Own Property Such as Land, Home, or Other Dwelling"
	label var Own_MobileR					"Own a Mobile Phone"
	label var You_Decide_WorkR				"Who Decides Whether You Can Work For Pay Outside Home"
	label var Took_Money_No_PermissionR		"Anyone in Household Took Money Earned, Received, or Saved Without Permission"
	label var Permission_Local_EventR		"Have to Get Permission to go to a Local Event Alone"
	label var Permission_MarketR			"Have to Get Permission to go to Market or Shops Alone"
	label var Most_Time_HouseworkR			"Person Who Spends the Most Time Doing Housework"
	label var Housework_Prevented_WorkR		"Doing Housework Has Prevented Doing Paid Work"
	label var Housework_Prevent_EducationR	"Doing Housework Has Prevented Participating in Education or Training"
	label var HarmR							"Anyone in Household Threatened to Harm you or Someone You Care About"
	label var MarriageR						"Married"
	label var Decide_Prevent_PregnancyR		"Able to Decide on Own About Using Methods to Prevent Pregnancy or Sexually-Transmitted Illnesses"
	
	label var Income_No_Permission_oth			"Had Income to Use Without Asking For Permission"
	label var Own_Decisions_Money_oth			"Can Make Own Decisions About What to do With Money"
	label var Own_Decisions_Medical_oth		"Can Make Own Decisions About Seeking Medical or Healthcare Services"
	label var Own_Decisions_Relatives_oth		"Can Make Own Decisions About Spending Time With Relatives"
	label var Own_Decisions_Friends_oth		"Can Make Own Decisions About Spending Time With Friends"
	label var Own_Bank_Account_oth				"Have Own Account With a Bank or Other Financial Institution"
	label var Have_Money_Saved_oth				"Have Money Saved To Use if Needed"
	label var Own_Property_oth					"Own Property Such as Land, Home, or Other Dwelling"
	label var Own_Mobile_oth					"Own a Mobile Phone"
	label var You_Decide_Work_oth				"Who Decides Whether You Can Work For Pay Outside Home"
	label var Took_Money_No_Permission_oth		"Anyone in Household Took Money Earned, Received, or Saved Without Permission"
	label var Permission_Local_Event_oth		"Have to Get Permission to go to a Local Event Alone"
	label var Permission_Market_oth			"Have to Get Permission to go to Market or Shops Alone"
	label var Most_Time_Housework_oth			"Person Who Spends the Most Time Doing Housework"
	label var Housework_Prevented_Work_oth		"Doing Housework Has Prevented Doing Paid Work"
	label var Housework_Prevent_Education_oth	"Doing Housework Has Prevented Participating in Education or Training"
	label var Harm_oth							"Anyone in Household Threatened to Harm you or Someone You Care About"
	label var Marriage_oth						"Married"
	label var Decide_Prevent_Pregnancy_oth		"Able to Decide on Own About Using Methods to Prevent Pregnancy or Sexually-Transmitted Illnesses"

********************************************************************************
*						PART 4: Check Balance Dataset
*******************************************************************************/

	compress
	keep HHID Group Status Modality $var_demo $var_assets $var_house $out_fs ///
		 $out_fcs $out_rcsi $out_lcs $out_fes $out_cari $out_mdd $out_empower
	save "${dta}/Iraq_F2F_Household_Analysis.dta", replace	
	
	* Overall Group A vs. Group B Randomization Balance
	iebaltab 	$var_demo $var_assets $var_house , 		///
				grpvar(Group) grplabels(1 Group A @ 2 Group B) ///
				rowvarlabels savexlsx("${tabs_bal}/Iraq_F2F_Group_Dempgraphics_Balance.xlsx") replace
						
	* Outcome Balance by Survey Modality
	iebaltab 	$var_demo $var_assets $var_house $out_fs $out_fcs $out_rcsi $out_lcs $out_fes $out_cari, 		///
				grpvar(Modality) grplabels(1 Remote first @ 2 F2F first) ///
				rowvarlabels savexlsx("${tabs_bal}/Iraq_F2F_Modality_Outcome_Balance.xlsx") replace

	
