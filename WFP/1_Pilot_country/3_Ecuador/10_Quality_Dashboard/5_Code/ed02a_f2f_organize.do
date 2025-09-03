/* *************************************************************************** *
*						WFP RAM-N rCARI Validation Study - Ecuador 			   * 
*																 			   *
*  PURPOSE:  			Create clean variables for Dashboard				   *
*  AUTHOR: 				Nicole Wu (nicole.wu@wfp.org)						   *
*																 			   *
*  DATE:  				Jun 18, 2023										   *
*  LATEST UPDATE: 		Jun 19, 2023										   *
*		  																	   *
********************************************************************************

					
	** REQUIRES:		${d_temp}/Ecuador_F2F_Household_Prep_`cdate'.dta
					
	** CREATES:			${d_temp}/Ecuador_F2F_Household_Analysis_`cdate'.dta
								
	** NOTES:			_`cdate' on Jul 20 when data collection finished
					
********************************************************************************
*						PART 1: Set up Log and Load Data
*******************************************************************************/
	
	cap log close 
	
	// set log
	loc cdate: di %td_CCYY_NN_DD date(c(current_date), "DMY")
	loc cdate = subinstr(trim("`cdate'"), " " , "", .)
	log using "${d_log}/ed03a_organize_`cdate'.smcl", replace
	di `cdate'
	
	* load dataset
	use "${d_temp}/Ecuador_F2F_Household_Prep.dta", clear 
	
	* keep if sampleYN == 1 

	** rename ___variables
	ren ___* Sys_*
	order R_*, a(RepeatPID_count)
	
	* survey duration variable
	destring Sys_duration, replace
	gen 	Duration_Min = Sys_duration/60
	
	* survey modality
	gen 	Modality	= 1 			 // f2f
	
	* form version long vs. short
	gen 	ID_Length = length(HHID)
	
	gen		Form = 1 if ID_Length == 10  // Long
	replace Form = 2 if ID_Length == 9   // Short

********************************************************************************
*						PART 2: Create and Define Variables
********************************************************************************

** Demongraphics and basic respondents/household information
	gen RESPHHH 	= (R_RESPRelationHHH == 100)
	gen RESPFemale	= (RESPSex			 == 0)
	gen HHDisplaced = (HHStatus 		 == 2)
	gen RESPSingle  = (RESPStatus		 == 100)
	gen RESPMarried = (RESPStatus		 == 300)
	
*	assert  == HHSize
	tab HHID if R_Num_Household != HHSize & !mi(R_Num_Household)
	
**# Lorenzo to add outcomes for Health/MMDI releted variables
	gen HHDisable = (MDDIHHDisabledNb > 0)
	 
** Roster Demongraphics
	gen 	FemaleMale_Ratio 	 = R_Num_Female/R_Num_Male
	sum		FemaleMale_Ratio
	replace FemaleMale_Ratio  	 = `r(max)' if mi(FemaleMale_Ratio)
	gen 	FemaleMale_Ratio_1_5 = (FemaleMale_Ratio >= 1.5)
	
	egen 	R_Num_Dependent 	 = rowtotal(R_Num_Child R_Num_Senior)
	gen 	Dependency_Ratio 	 = R_Num_Dependent/R_Num_Adult
	sum		Dependency_Ratio
	replace Dependency_Ratio = `r(max)' if mi(Dependency_Ratio)
	
	gen 	Dep_Ratio_Cat = 0
	replace Dep_Ratio_Cat = 1 if Dependency_Ratio <= 1
	replace Dep_Ratio_Cat = 2 if Dependency_Ratio >  1 	 & Dependency_Ratio <= 1.5
	replace Dep_Ratio_Cat = 3 if Dependency_Ratio >  1.5 & Dependency_Ratio <= 2.5
	replace Dep_Ratio_Cat = 4 if Dependency_Ratio >  2.5

	gen Dep_Ratio_1_5 	= (Dependency_Ratio > 1.5)
	gen Dep_Ratio_2 	= (Dependency_Ratio > 2)
	
** Outcome: Household food security status 
	sum RESPFoodWorry_YN RESPPercFoodSec*
	
	gen RESPMeals_3More   = (RESPMeals 			== 3)
	gen RESPFoodWorry	  = (RESPFoodWorry_YN 	== 1)
	gen RESPFS_EnoughFood = (RESPPercFoodSec_1 	== 1)
	gen RESPFS_LessPrefer = (RESPPercFoodSec_2 	== 1)
	gen RESPFS_LessMeal   = (RESPPercFoodSec_3 	== 1)
	gen RESPFS_DayNoEat   = (RESPPercFoodSec_4 	== 1)
	
	** Number of Meals & Worried RESPMeals
	gen 	CARI_Meals = .
	replace CARI_Meals = 1 if RESPMeals == 3
	replace CARI_Meals = 2 if RESPMeals == 2
	replace CARI_Meals = 3 if RESPMeals == 1 | RESPMeals == 0
	replace CARI_Meals = 4 if RESPMeals == 0 & RESPPercFoodSec_4 == 1

	gen 	CARI_Worry = .
	replace CARI_Worry = 1 if RESPFoodWorry_YN == 0
	replace CARI_Worry = 2 if RESPFoodWorry_YN == 1
	replace CARI_Worry = 3 if RESPFoodWorry_YN == 1 & RESPPercFoodSec_3 == 1
	replace CARI_Worry = 4 if RESPFoodWorry_YN == 1 & RESPPercFoodSec_4 == 1
	
** Outcome: [FCS] Food consumption score Short vs. Long
	sum FCS*
gl  fcs FCSStap FCSPulse FCSDairy FCSPr FCSVeg FCSFruit FCSFat FCSSugar FCSCond FCS
	
foreach var of global fcs {
	replace `var' = `var'_S if Form == 2 & mi(`var')
}
	destring FCS, replace
	ren 	 FCS FCS_check
	
	gen 	FCS = FCSStap * 2 + FCSPulse * 3 + FCSDairy * 4 + FCSPr * 4 + 		///
				  FCSVeg  * 1 + FCSFruit * 1 + FCSFat * 0.5 + FCSSugar * 0.5
	
	assert	FCS == FCS_check
	gen 	FCSCat28 = cond(FCS_check <= 28, 1, cond(FCS_check <= 42, 2, 3))

** Outcome: [rCSI] Reduced Coping Strategies (rCSI - Gendered)
	destring rCSI, replace
	ren		 rCSI  rCSI_check
	gen 	 rCSI = rCSILessQlty * 1 + rCSIBorrow * 2 + rCSIMealNb * 1 + 		///
					rCSIMealSize * 1 + rCSIMealAdult * 3			   
	tab 	 rCSIGenderMealAdult
	assert 	 rCSI == rCSI_check
	
** LCS: Long (EN) vs. Short (FS)
local  lcs  stress_DomAsset stress_CrdtFood stress_Saving 			///
			stress_BorrowCash crisis_ProdAssets crisis_HealthEdu		///
			crisis_OutSchool em_ChildWork em_Begged em_IllegalAct
				
foreach item of local lcs{
	replace Lcs_`item' = LcsEN_`item' if mi(Lcs_`item') & Form == 1
	sum Lcs_`item'
	label val Lcs_`item' LcsEN_`item'
}	
								
	gen Lcs_Stress_Coping 	 = (Lcs_stress_DomAsset   	== 20 | Lcs_stress_DomAsset   	== 30 | ///
								Lcs_stress_CrdtFood   	== 20 | Lcs_stress_CrdtFood   	== 30 | ///
								Lcs_stress_Saving     	== 20 | Lcs_stress_Saving     	== 30 | ///
								Lcs_stress_BorrowCash 	== 20 | Lcs_stress_BorrowCash 	== 30 ) 
	gen Lcs_Crisis_Coping	 = (Lcs_crisis_ProdAssets 	== 20 | Lcs_crisis_ProdAssets 	== 30 | ///
								Lcs_crisis_HealthEdu	== 20 | Lcs_crisis_HealthEdu  	== 30 | ///
								Lcs_crisis_OutSchool  	== 20 | Lcs_crisis_OutSchool  	== 30 ) 
	gen Lcs_Emergency_Coping = (Lcs_em_ChildWork   		== 20 | Lcs_em_ChildWork  	 	== 30 | ///
								Lcs_em_Begged      		== 20 | Lcs_em_Begged      	 	== 30 | ///
								Lcs_em_IllegalAct  		== 20 | Lcs_em_IllegalAct  	 	== 30 ) 

	gen 	LCS_Cat = 1
	replace LCS_Cat = 2 if Lcs_Stress_Coping 	== 1
	replace LCS_Cat = 3 if Lcs_Crisis_Coping 	== 1
	replace LCS_Cat = 4 if Lcs_Emergency_Coping == 1
	
	tab LCS_Cat, gen(LCS_)
	ren LCS_1 	 LCS_None
	ren LCS_2	 LCS_Stress
	ren LCS_3	 LCS_Crisis
	ren LCS_4	 LCS_Emergency
	
** Outcome: [FES] Food Expenditure Share Long vs. Short

	* 7 days food purchase in cash/credit
egen HHExp_Food_Purch_MN_7D = rowtotal(HHExpFCer_Purch_MN_7D HHExpFTub_Purch_MN_7D ///
	 HHExpFPuls_Purch_MN_7D HHExpFVeg_Purch_MN_7D HHExpFFrt_Purch_MN_7D 		   ///
	 HHExpFAnimMeat_Purch_MN_7D HHExpFAnimFish_Purch_MN_7D HHExpFFats_Purch_MN_7D  ///
	 HHExpFDairy_Purch_MN_7D HHExpFEgg_Purch_MN_7D HHExpFSgr_Purch_MN_7D 		   ///
	 HHExpFCond_Purch_MN_7D HHExpFBev_Purch_MN_7D HHExpFOut_Purch_MN_7D			   ///
	 HHExpFCer_Purch_MN_7D_S HHExpFTub_Purch_MN_7D_S HHExpFPuls_Purch_MN_7D_S	   ///
	 HHExpFVegFrt_Purch_MN_7D_S HHExpFAnimMeatFishEgg_Purch_MN_7 				   ///
	 HHExpFFatsDairy_Purch_MN_7D_S HHExpFSgrCond_Purch_MN_7D_S 					   ///
	 HHExpFBev_Purch_MN_7D_S HHExpFOut_Purch_MN_7D_S)
	
	* 7 days food gift/aid value 
egen HHExp_Food_GiftAid_MN_7D = rowtotal(HHExpFCer_GiftAid_MN_7D HHExpFTub_GiftAid_MN_7D ///
	 HHExpFPuls_GiftAid_MN_7D HHExpFVeg_GiftAid_MN_7D HHExpFFrt_GiftAid_MN_7D			 ///
	 HHExpFAnimMeat_GiftAid_MN_7D HHExpFAnimFish_GiftAid_MN_7D HHExpFFats_GiftAid_MN_7D	 ///
	 HHExpFDairy_GiftAid_MN_7D HHExpFEgg_GiftAid_MN_7D HHExpFSgr_GiftAid_MN_7D			 ///
	 HHExpFCond_GiftAid_MN_7D HHExpFBev_GiftAid_MN_7D HHExpFOut_GiftAid_MN_7D			 ///
	 HHExpFCer_GiftAid_MN_7D_S HHExpFTub_GiftAid_MN_7D_S HHExpFPuls_GiftAid_MN_7D_S		 ///
	 HHExpFVegFrt_GiftAid_MN_7D_S HHExpFAnimMeatFishEgg_GiftAid_MN 						 ///
	 HHExpFFatsDairy_GiftAid_MN_7D_S HHExpFSgrCond_GiftAid_MN_7D_S 						 ///
	 HHExpFBev_GiftAid_MN_7D_S HHExpFOut_GiftAid_MN_7D_S)

	* 7 days food own-production value
egen HHExp_Food_Own_MN_7D = rowtotal(HHExpFCer_Own_MN_7D HHExpFTub_Own_MN_7D				 ///
	 HHExpFPuls_Own_MN_7D HHExpFVeg_Own_MN_7D HHExpFFrt_Own_MN_7D HHExpFAnimMeat_Own_MN_7D	 ///
	 HHExpFAnimFish_Own_MN_7D HHExpFFats_Own_MN_7D HHExpFDairy_Own_MN_7D HHExpFEgg_Own_MN_7D ///
	 HHExpFSgr_Own_MN_7D HHExpFCond_Own_MN_7D HHExpFBev_Own_MN_7D HHExpFOut_Own_MN_7D		 ///
	 HHExpFCer_Own_MN_7D_S HHExpFTub_Own_MN_7D_S HHExpFPuls_Own_MN_7D_S 					 ///
	 HHExpFVegFrt_Own_MN_7D_S HHExpFAnimMeatFishEgg_Own_MN_7D_ HHExpFFatsDairy_Own_MN_7D_S	 ///
	 HHExpFSgrCond_Own_MN_7D_S HHExpFBev_Own_MN_7D_S HHExpFOut_Own_MN_7D_S)

	* 7 days food values in total and 1 month average 
	gen HHExpFoodTotal_7D = HHExp_Food_Purch_MN_7D + HHExp_Food_GiftAid_MN_7D + ///
							HHExp_Food_Own_MN_7D
	gen HHExpFoodTotal_1M = (HHExpFoodTotal_7D/7) * 30
	
***** NON-FOOD EXPENDITURE *****************************************************
	
	**** 1 MONTH ****
	* Monthly non food expenditure in cash/credit
egen HHExp_NonFood_Purch_MN_1M = rowtotal(HHExpNFHyg_Purch_MN_1M HHExpNFTransp_Purch_MN_1M ///
	 HHExpNFFuel_Purch_MN_1M HHExpNFWat_Purch_MN_1M HHExpNFEnerg_Purch_MN_1M			   ///
	 HHExpNFDwelSer_Purch_MN_1M HHExpNFPhone_Purch_MN_1M HHExpNFRecr_Purch_MN_1M		   ///
	 HHExpNFAlcTobac_Purch_MN_1M HHExpNFHyg_Purch_MN_1M_S HHExpNFTranspFuel_Purch_MN_1M_S  ///
	 HHExpNFEnerg_Purch_MN_1M_S HHExpNFWat_Purch_MN_1M_S HHExpNFDwelSer_Purch_MN_1M_S	   ///
	 HHExpNFPhone_Purch_MN_1M_S HHExpNFRecr_Purch_MN_1M_S HHExpNFAlcTobac_Purch_MN_1M_S)

	 * Monthly non food gift/aid value 
egen HHExp_NonFood_GiftAid_MN_1M = rowtotal(HHExpNFHyg_GiftAid_MN_1M 						///
	 HHExpNFTransp_GiftAid_MN_1M HHExpNFFuel_GiftAid_MN_1M HHExpNFWat_GiftAid_MN_1M			///
	 HHExpNFEnerg_GiftAid_MN_1M HHExpNFDwelSer_GiftAid_MN_1M HHExpNFPhone_GiftAid_MN_1M		///
	 HHExpNFRecr_GiftAid_MN_1M HHExpNFAlcTobac_GiftAid_MN_1M HHExpNFHyg_GiftAid_MN_1M_S		///
	 HHExpNFTranspFuel_GiftAid_MN_1M_ HHExpNFEnerg_GiftAid_MN_1M_S HHExpNFWat_GiftAid_MN_1M_S ///
	 HHExpNFDwelSer_GiftAid_MN_1M_S HHExpNFPhone_GiftAid_MN_1M_S HHExpNFRecr_GiftAid_MN_1M_S  ///
	 HHExpNFAlcTobac_GiftAid_MN_1M_S)

	 * Monthly non food own (just energy) 
* egen HHExp_NonFood_Own_MN_1M = rowtotal(HHExpNFEnerg_Own_MN_1M HHExpNFEnerg_Own_MN_1M_S)

	**** 6 MONTHS ****
	* Non food expenditure in cash/credit in 6 months
egen HHExp_NonFood_Purch_MN_6M = rowtotal(HHExpNFMedServ_Purch_MN_6M				///
	 HHExpNFMedGood_Purch_MN_6M HHExpNFCloth_Purch_MN_6M HHExpNFEduFee_Purch_MN_6M	///
	 HHExpNFEduGood_Purch_MN_6M HHExpNFRent_Purch_MN_6M HHExpNFHHSoft_Purch_MN_6M	///
	 HHExpNFHHMaint_Purch_MN_6M HHExpNFMedServGood_Purch_MN_6M_S 					///
	 HHExpNFCloth_Purch_MN_6M_S HHExpNFEduFeeGood_Purch_MN_6M_S 					///
	 HHExpNFRent_Purch_MN_6M_S HHExpNFHHSoftMaint_Purch_MN_6M_S)

	 * Non food expenditure gift/aid value in 6 months
egen HHExp_NonFood_GiftAid_MN_6M = rowtotal(HHExpNFMedServ_GiftAid_MN_6M 	///
	 HHExpNFMedGood_GiftAid_MN_6M HHExpNFCloth_GiftAid_MN_6M 				///
	 HHExpNFEduFee_GiftAid_MN_6M HHExpNFEduGood_GiftAid_MN_6M 				///
	 HHExpNFRent_GiftAid_MN_6M HHExpNFHHSoft_GiftAid_MN_6M 					///
	 HHExpNFHHMaint_GiftAid_MN_6M HHExpNFMedServGood_GiftAid_MN_6M			///
	 HHExpNFCloth_GiftAid_MN_6M_S HHExpNFEduFeeGood_GiftAid_MN_6M_			///
	 HHExpNFRent_GiftAid_MN_6M_S HHExpNFHHSoftMaint_GiftAid_MN_6M)

	**** TOTAL 1 MONTH AVERAGE ****
	* Total monthly non food expenditure in cash/credit 
	gen HHExpNFTotal_Purch_MN_1M = HHExp_NonFood_Purch_MN_1M + (HHExp_NonFood_Purch_MN_6M/6)
	* Total monthly non-food gift/aid value
	gen HHExpNFTotal_GiftAid_MN_1M = HHExp_NonFood_GiftAid_MN_1M + (HHExp_NonFood_GiftAid_MN_6M/6)
	* Total monthly non-food
	gen HHExpNFTotal_1M = HHExpNFTotal_Purch_MN_1M + HHExpNFTotal_GiftAid_MN_1M 
						// + HHExp_NonFood_Own_MN_1M
		
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

	** Income
	gl income HHHOccupation HHInc_PCT HHIncNb HHIncFirst_SRi HHIncFirst_oth	///
			  HHIncF_PCT HHInc017_PCT HHIncChg
	
foreach var of global income {
	replace `var' = `var'_S if Form == 2 & mi(`var')
}
	replace HHIncFirst_oth = strproper(strtrim(HHIncFirst_oth))
	replace HHIncFirst_oth = "PensióN De JubilacióN" if HHIncFirst_oth == "El Bono Del Gobierno Y  PensióN De JubilacióN"
	
	tab HHIncFirst_SRi
	gen 	HHIncFirst_Accept = inlist(HHIncFirst_SRi, 1, 2, 5, 12, 13, 14, 15)
	replace HHIncFirst_Accept = 1 if strpos(HHIncFirst_oth, "Pescador")		| ///
			strpos(HHIncFirst_oth, "Vende")			| ///
			HHIncFirst_oth == "A La Agricultura Solo Siembra"	| ///
			HHIncFirst_oth == "Acienda"	| ///
			HHIncFirst_oth == "Actividades DoméSticas Como Lavar, Cocinar, Limpiar, Planchar, Limpiar"	| ///
			HHIncFirst_oth == "Agricola"	| ///
			HHIncFirst_oth == "Agua Potable"	| ///
			HHIncFirst_oth == "Bienes Raices"	| ///
			HHIncFirst_oth == "Chofer"	| ///
			HHIncFirst_oth == "Conserje"	| ///
			HHIncFirst_oth == "CríAn Animales"	| ///
			HHIncFirst_oth == "Cuidar Chanchos"	| ///
			HHIncFirst_oth == "De OrdeñAr A Las Vacas"	| ///
			HHIncFirst_oth == "PensióN De JubilacióN"	| ///
			strpos(HHIncFirst_oth, "Florister")	| ///
			HHIncFirst_oth == "JubilacióN"	| ///
			HHIncFirst_oth == "Oficial De Cooperativa De Transporte" | ///
			HHIncFirst_oth == "PequeñA ProduccióN Agricola Sin Ganado" | ///
			HHIncFirst_oth == "ProduccióN Agricola"	| ///
			HHIncFirst_oth == "Produce Solo Lo De La Parcela"	| ///
			HHIncFirst_oth == "Se Dedica Al Café Y A Las Yucas"	| ///
			HHIncFirst_oth == "Servidor Publico"	| ///
			HHIncFirst_oth == "Trabaja En El Municipio Con Sueldo BáSico"	| ///
			HHIncFirst_oth == "Trabaja En Ventas De Calzado Y El Negocio No Es Propio" | ///
			HHIncFirst_oth == "Venta De Animales Y Recicla" 
			
	gen		HHIncFirst_Border = inlist(HHIncFirst_SRi, 3, 4, 6, 11)
	replace HHIncFirst_Border = 1 if HHIncFirst_oth == "Actividades Varias" | ///
			HHIncFirst_oth == "Actividades De Corte Y ConfeccióN Desde La Casa." | ///
			HHIncFirst_oth == "Actividades Varias, Independiente" | ///
			HHIncFirst_oth == "Agricultura Y Otros Dependiendo Lo Q Hay." | ///
			HHIncFirst_oth == "ArtesaníAs" | ///
			HHIncFirst_oth == "Ayudante En ConstruccióN" | ///
			HHIncFirst_oth == "Cargador De Café" | ///
			HHIncFirst_oth == "Coce" | ///
			HHIncFirst_oth == "Cocina Para Encargos" | ///
			HHIncFirst_oth == "Cocinero Y Bailarin" | ///
			HHIncFirst_oth == "Cortador De Pescado" | ///
			HHIncFirst_oth == "Coser" | ///
			HHIncFirst_oth == "Costura" | ///
			HHIncFirst_oth == "Cualquier Trabajo" | ///
			HHIncFirst_oth == "Cuida A Una SeñOra" | ///
			HHIncFirst_oth == "Cuida Un NiñO." | ///
			HHIncFirst_oth == "Deshiervar" | ///
			strpos(HHIncFirst_oth, "Servicios DoméSticos")		| ///
			HHIncFirst_oth == "Empleos DoméSticos" | ///
			HHIncFirst_oth == "Guardia De Seguridad" | ///
			HHIncFirst_oth == "Hace Carreras Y Es Agricultor" | ///
			HHIncFirst_oth == "Jornalero" | ///
			HHIncFirst_oth == "Jornalero Y Esposa Venta De Ropa Y CosméTicos Por CatáLogo" | ///
			HHIncFirst_oth == "Lava Ropa" | ///
			HHIncFirst_oth == "Moto Taxi" | ///
			HHIncFirst_oth == "Musico" | ///
			HHIncFirst_oth == "Obrero En Empacadora De CamaróN" | ///
			HHIncFirst_oth == "PeóN (Le Ayuda Al Maestro En La ConstruccióN)" | ///
			HHIncFirst_oth == "Recoje Del Camopo Su Comida" | ///
			HHIncFirst_oth == "Trabaja De Lo Que Sea" | ///
			HHIncFirst_oth == "Trabaja De Obrero" | ///
			HHIncFirst_oth == "Trabaja En Campo" | ///
			HHIncFirst_oth == "Trabaja En Una Apiladores De Arroz Por Temporadas" | ///
			HHIncFirst_oth == "Trabaja En Una Hacienda Por DíAs" | ///
			HHIncFirst_oth == "Tricimoto" | ///
			HHIncFirst_oth == "Venta De Salchichas Solo Los DíAs Domingos"
							 
	gen 	HHIncFirst_Poor	  = inlist(HHIncFirst_SRi, 7, 8, 9, 10)
	replace HHIncFirst_Poor   = 1 if HHIncFirst_oth == "Ama De Casa" | ///
			HHIncFirst_oth == "Ayuda De La Familia" | ///
			HHIncFirst_oth == "Ayuda Del Gobierno Mediante El Bono"	 | ///
			HHIncFirst_oth == "Bono"						| ///
			HHIncFirst_oth == "Bono De Desarrollo Humano"	| ///
			strpos(HHIncFirst_oth, "Bono De Gobierno")		| ///
			strpos(HHIncFirst_oth, "Bono Del Gobierno")		| ///
			HHIncFirst_oth == "Cobra El Bono, Esposo La Abandonó."	 | ///
			HHIncFirst_oth == "Recibe El Bono"				| ///
			HHIncFirst_oth == "Reciclaje"
			
	gen CARI_Inc = .
	replace CARI_Inc = 1 if HHIncFirst_Accept == 1 & inlist(HHIncChg, 0, 1, 5)
	replace CARI_Inc = 2 if HHIncFirst_Accept == 1 & inlist(HHIncChg, 2, 3, 4)
	replace CARI_Inc = 2 if HHIncFirst_Border == 1 & inlist(HHIncChg, 0, 1, 5)
	replace CARI_Inc = 3 if HHIncFirst_Border == 1 & inlist(HHIncChg, 2, 3, 4)
	replace CARI_Inc = 4 if HHIncNb == 0 | HHIncFirst_Poor == 1
	
	tab CARI_Inc, gen(CARI_Inc_)
	
	** Question relevant when: ${HHIncNb} >0
	tab HHIncFirst_SRi
	gen HHInc_None 			= mi(HHIncFirst_SRi)
	gen HHInc_WageSkill 	= (HHIncFirst_SRi == 1  | HHIncFirst_SRi == 2)
	gen HHInc_WageUnskill 	= (HHIncFirst_SRi == 3  | HHIncFirst_SRi == 4)
	gen HHInc_Trade 		= (HHIncFirst_SRi == 12 | HHIncFirst_SRi == 13 | ///
							   HHIncFirst_SRi == 14)
	gen HHInc_AgProduction 	= (HHIncFirst_SRi == 15 | HHIncFirst_SRi == 16)
	
	tab HHIncChg, gen(HHInc_)
	ren HHInc_1	HHInc_Change_None
	ren HHInc_2	HHInc_Increase
	ren HHInc_3	HHInc_Reduce25
	ren HHInc_4	HHInc_Reduce50
	ren HHInc_5	HHInc_Reduce50More
	
** Outcome: [CARI] COMBINING CURRENT STATUS AND COPING CAPACITY
	recode  FCSCat28 (1 = 4) (2 = 3) (3 = 1), gen(FCS_4pt_CARI)
	replace FCS_4pt_CARI = 2 if FCSCat28 == 3 & rCSI >= 4
	
	gen CC_FES_Cat   = (FES_Cat + LCS_Cat)/2	// no round here
	gen CARI_FES_Raw = (FCS_4pt_CARI + CC_FES_Cat)/2
	gen CARI_FES_Cat = round(CARI_FES_Raw)
	gen HH_Vul_FES   = (CARI_FES_Cat == 3 | CARI_FES_Cat == 4)

	gen CC_Inc_Cat   = (CARI_Inc + LCS_Cat)/2	// no round here
	gen CARI_Inc_Raw = (FCS_4pt_CARI + CC_Inc_Cat)/2
	gen CARI_Inc_Cat = round(CARI_Inc_Raw)
	gen HH_Vul_Income  = (CARI_Inc_Cat == 3 | CARI_Inc_Cat == 4)
	
	// Standard MDDW method - SNF home group will be grains
	gen MDD_Staples 	 = (PWMDDWStapCer == 1 |  PWMDDWStapRoo == 1) 	// | PWMDDWSnf == 1
	gen MDD_Pulses		 = (PWMDDWPulse == 1)
	gen MDD_NutsSeeds	 = (PWMDDWNuts == 1)
	gen MDD_Dairies	 	 = (PWMDDWDairy == 1 | PWMDDWMilk == 1)
	gen MDD_MeatFish	 = (PWMDDWPrMeatO == 1 | PWMDDWPrMeatF == 1 | PWMDDWPrMeatPro == 1 | ///
							PWMDDWPrMeatWhite == 1 |  PWMDDWPrFish == 1)
	gen MDD_Eggs		 = (PWMDDWPrEgg == 1)
	gen MDD_LeafGVeg	 = (PWMDDWVegGre == 1)
	gen MDD_VitA  		 = (PWMDDWVegOrg == 1 | PWMDDWFruitOrg == 1)
    gen MDD_OtherVeg  	 = (PWMDDWVegOth == 1) 
    gen MDD_OtherFruits  = (PWMDDWFruitOth == 1)
	gen MDD_Index 		 = MDD_Staples + MDD_Pulses + MDD_NutsSeeds + MDD_Dairies + ///
						   MDD_MeatFish + MDD_Eggs + MDD_LeafGVeg + MDD_VitA + 		///
						   MDD_OtherVeg + MDD_OtherFruits
	gen MDD_Index_5 = (MDD_Index >= 5)
	
********************************************************************************
*							PART 3: Label Variables
*******************************************************************************/	

	label def YesNo					0 "No"   1 "Yes"
	label val Lcs_Stress_Coping Lcs_Crisis_Coping 				///
			  Lcs_Emergency_Coping HH_Vul_FES HH_Vul_Income 	///
			  HHDisplaced RESPSingle RESPMarried HHDisable 		///
			  RESPMeals_3More RESPFoodWorry RESPFS_EnoughFood 	///
			  RESPFS_LessPrefer RESPFS_LessMeal RESPFS_DayNoEat YesNo
	
	label def FCSCat 				1 "Poor" 2 "Borderline" 3 "Acceptable"
	label val FCSCat28 FCSCat
	
	label def CARI_Meals_lbl 		1 "Three meals" ///
									2 "Two meals"   ///
									3 "One meal"   ///
									4 "No meals"
	label val CARI_Meals CARI_Meals_lbl
	
	label def CARI_Worry_lbl 		1 "Not worried" ///
									2 "Worried"	 ///
									3 "Worried & skipping meals" ///
									4 "Worried & going day/night without eating"
	label val CARI_Worry CARI_Worry_lbl
	
	label def LCS_l			 		1 "Not adopting coping strategies" 	///
									2 "Stress coping strategies" 		///
									3 "Crisis coping strategies" 		///
									4 "Emergencies coping strategies" 
	label val LCS_Cat 	LCS_l
	
	label def FS_CARI	  	 		1 "Food Secure"  				///
									2 "Marginally Food Secure" 		///
									3 "Moderately Food Insecure" 	///
									4 "Severely Food Insecure"
	label val FCS_4pt_CARI CARI_FES_Cat FES_Cat CARI_Inc_Cat CARI_Inc FS_CARI	   
	
	label def survey_l				1  "Face-to-Face" 2 "Remote"
	label val Modality  survey_l
	
	label def length_l				1 "Long Form"	  2 "Short Form"
	label val Form length_l
	
	label var Modality				"Survey Modality: F2F vs. Remote"
	label var ID_Length				"Household ID Length"
	label var Form					"Form Type: Long vs. Short"
	label var Duration_Min			"Survey Duration in Minutes"
	label var RESPHHH				"Head of Household Respondent"
	label var RESPAge				"Respondent Age"
	label var RESPFemale			"Female Respondent"
	label var RESPSingle			"Single Respondent"
	label var RESPMarried			"Married Respondent"
	label var HHDisable				"Household has disabled member"
	label var HHDisplaced			"IDP Household"
	label var HHhostDisp			"Household currently hosting IDP or Refugee"
	label var HHSize				"Household Size"
	label var MDDIHHDisabledNb		"Number of disabled household members"
	label var FemaleMale_Ratio		"Household Female/Male Ratio"
	label var FemaleMale_Ratio_1_5	"Household Female/Male Ratio >= 1.5"
	label var Dependency_Ratio		"Household Dependency Ratio"	
	label var Dep_Ratio_Cat			"Household Dependency Ratio Category"
	label var Dep_Ratio_1_5			"Household Dependency Ratio > 1.5"
	label var Dep_Ratio_2			"Household Dependency Ratio > 2"
	label var R_Num_Dependent		"Household total number of dependents"
	
	label var RESPMeals_3More		"Respondent and family ate 3 or more meals yesterday"
	label var RESPFoodWorry			"Respondent and family worried about no enough food in past 30 days"
	label var RESPFS_EnoughFood		"Household had no difficulties eating enough food in past 7 days"
	label var RESPFS_LessPrefer		"Household ate less preferred foods in past 7 days"
	label var RESPFS_LessMeal		"Household skipped meals or ate less than usual in past 7 days"
	label var RESPFS_DayNoEat		"Household went one whole day without eating in past 7 days"
	label var CARI_Meals			"CARI based on number of meals per day"
	label var CARI_Worry			"CARI based on worry of food insecurity"
	
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
	label var FCS_4pt_CARI			"CARI: Current Status of FCS and rCSI"
	
	label var rCSILessQlty 			"Relied on less preferred, less expensive food"
	label var rCSIBorrow 			"Borrowed food or relied on help from friends or relatives"
	label var rCSIMealSize 			"Reduced portion size of meals at meals time"
	label var rCSIMealAdult			"Restricted Coping by adults in order for young-children to eat"
	label var rCSIMealNb	 		"Reduced the number of meals eaten per day"
	label var rCSI 					"Reduced Coping Strategies Index (rCSI)"
	
	label var Lcs_stress_DomAsset 	"Stress coping: Sold household assets/goods"
	label var Lcs_stress_CrdtFood 	"Stress coping: Purchased food/non-food on credit (incur debts)"
	label var Lcs_stress_Saving	  	"Stress coping: Spent savings"
	label var Lcs_stress_BorrowCash "Stress coping: Borrowed money"
	label var Lcs_crisis_ProdAssets	"Crisis coping: Sold productive assets or means of transport"
	label var Lcs_crisis_HealthEdu	"Crisis coping: Reduced expenses on health and education"
	label var Lcs_crisis_OutSchool	"Crisis coping: Withdrew children from school"
	label var Lcs_em_ChildWork		"Emergency coping: Send children to work for household income"
	label var Lcs_em_Begged			"Emergency coping: Begged and/or scavenged"
	label var Lcs_em_IllegalAct		"Emergency coping: Engaged in illegal income activities"
	label var Lcs_Stress_Coping 	"Household engaged in stress coping strategies" 
	label var Lcs_Crisis_Coping 	"Household engaged in crisis coping strategies" 
	label var Lcs_Emergency_Coping 	"Household engaged in emergency coping strategies" 
	label var LCS_Cat				"Livelihood Coping Strategies Cateory"
	label var LCS_None				"Maximum Livelihood Coping: None"
	label var LCS_Stress			"Maximum Livelihood Coping: Stress level"
	label var LCS_Crisis			"Maximum Livelihood Coping: Crisis level"
	label var LCS_Emergency			"Maximum Livelihood Coping: Emergency level"
	
	la var HHExp_Food_Purch_MN_7D 	"Total weekly food expenditure on cash/credit"
	la var HHExp_Food_GiftAid_MN_7D "Total weekly food expenditure from gift aid"
	la var HHExp_Food_Own_MN_7D 	"Total weekly food expenditure from own production"
	la var HHExpFoodTotal_7D		"Total weekly food expenditure"	
	la var HHExpFoodTotal_1M		"Total monthly food expenditure (average)"
	
	la var HHExp_NonFood_Purch_MN_1M 	"Total monthly non-food expenditure on cash/credit"
	la var HHExp_NonFood_GiftAid_MN_1M	"Total monthly non-food expenditure from gift aid"	
	la var HHExp_NonFood_Purch_MN_6M	"Total other non-food expenditure on cash/credit in 6 months"
	la var HHExp_NonFood_GiftAid_MN_6M	"Total other non-food expenditure from gift aid in 6 months"	
	la var HHExpNFTotal_Purch_MN_1M 	"Total monthly non-food exp on cash (average)"
	la var HHExpNFTotal_GiftAid_MN_1M 	"Total monthly non-food exp from aid (average)"
	la var HHExpNFTotal_1M				"Total monthly non-food expenditure (average)"
	
	label var HHExpTotal 			"Monthly total household expenditure"
	label var PCExpTotal			"Monthly total household expenditure per capita"
	label var FES					"Food Expenditure Share"
	label var FES_Cat				"Food Security Category based on FES"
	
	label var CC_FES_Cat			"Coping Capacity Combined Category using FES"
	label var CARI_FES_Raw			"Raw CARI Category based on FES"
	label var CARI_FES_Cat			"CARI Category using FES"
	label var HH_Vul_FES			"Household being vulnerable using FES CARI"
	label var CARI_Inc				"Household Economic Vulnerability Based on Income"
	label var CC_Inc_Cat			"Coping Capacity Combined Category using Income"
	label var CARI_Inc_Raw			"Raw CARI Category based on Income"
	label var CARI_Inc_Cat			"CARI Category using Income"
	label var HH_Vul_Income			"Household being vulnerable using Income rCARI"
	label var HHIncFirst_Accept		"Income Source: Skilled waged labor, pension, business and ag production"
	label var HHIncFirst_Border		"Income Source: Unskilled waged labor, remittances, and street selling"
	label var HHIncFirst_Poor		"Income Source: None, aid, borrowing, begging, and high-risk activities, etc."
	label var CARI_Inc_1			"Income: Food Secure"
	label var CARI_Inc_2			"Income: Marginally Food Secure"
	label var CARI_Inc_3			"Income: Moderately Food Insecure"
	label var CARI_Inc_4			"Income: Severely Food Insecure"
	label var HHInc_None			"Income Source: None"
	label var HHInc_WageSkill		"Income Source: Skilled Waged Labor"
	label var HHInc_WageUnskill		"Income Source: Unskilled Waged Labor"
	label var HHInc_Trade			"Income Source: Trade"
	label var HHInc_AgProduction	"Income Source: Agricultural Production"
	label var HHInc_Change_None		"Income Change: None"
	label var HHInc_Increase		"Income Change: Increase"
	label var HHInc_Reduce25		"Income Change: Reduced < 25%"
	label var HHInc_Reduce50		"Income Change: Reduced 25% - 50%"
	label var HHInc_Reduce50More	"Income Change: Reduced 50+%"
	
	label var PWMDDWStapCer			"Foods made from grains"
	label var PWMDDWStapRoo			"White roots and tubers or plantains"
	label var PWMDDWPulse			"Pulses (beans, peas and lentils)"
	label var PWMDDWNuts			"Nuts and seeds"
	label var PWMDDWMilk			"Milk"
	label var PWMDDWDairy			"Milk products"
	label var PWMDDWPrMeatO			"Organ meats"
	label var PWMDDWPrMeatF			"Red flesh meat from mammals"
	label var PWMDDWPrMeatPro		"Processed meat"
	label var PWMDDWPrMeatWhite		"Poultry and other white meats"
	label var PWMDDWPrFish			"Fish and Seafood"
	label var PWMDDWPrEgg			"Eggs from poultry or any other bird"
	label var PWMDDWVegGre	 		"Dark green leafy vegetable"
	label var PWMDDWVegOrg			"Vitamin A-rich vegetables, roots and tubers"
	label var PWMDDWFruitOrg		"Vitamin A-rich fruits"
	label var PWMDDWVegOth			"Other vegetables"
	label var PWMDDWFruitOth		"Other fruits"
*	label var PWMDDWSnf				"Specialized Nutritious Foods (SNF) for women"
	label var MDD_Staples			"Staples"
	label var MDD_Pulses			"Pulses"
	label var MDD_NutsSeeds			"Nuts and seeds"
	label var MDD_Dairies			"Dairy products"
	label var MDD_MeatFish			"Meat, poultry and fish"
	label var MDD_Eggs				"Eggs"
	label var MDD_LeafGVeg			"Dark green leafy vegetables"
	label var MDD_VitA 				"Vitamin A-rich vegetables & fruits"
	label var MDD_OtherVeg			"Other vegetables"
	label var MDD_OtherFruits 		"Other fruits"
	label var MDD_Index				"MDD Index"
	label var MDD_Index_5			"MDD Index >= 5"
	
********************************************************************************
*						PART 4: Save F2F Analysis Dataset
*******************************************************************************/
	
	compress
	
	labelrename HHExpFAnimMeatFishEgg_Purch_7D_S HHExpFPro_Purch_7D_S
	labelrename HHExpNFHHSoftMaint_GiftAid_6M_S  HHExpNFHHSoft_GiftAid_6M_S
	labelrename HHExpFAnimMeatFishEgg_GiftAid_7D HHExpFPro_GiftAid_7D
	labelrename HHExpNFEduFeeGood_GiftAid_6M_S   HHExpNFEdu_GiftAid_6M_S
	labelrename HHExpFAnimMeatFishEgg_Own_7D_S	 HHExpFPro_Own_7D_S
	labelrename HHExpNFMedServGood_GiftAid_6M_S	 HHExpNFMed_GiftAid_6M_S
	labelrename HHExpNFTranspFuel_GiftAid_1M_S 	 HHExpNFTrans_GiftAid_1M_S 
	
*	iecodebook export using "${d_out}/Ecuador_F2F_Codebook.xlsx", replace
	
	save "${d_temp}/Ecuador_F2F_Household_Analysis.dta", replace	

* -------------	
* End of dofile
