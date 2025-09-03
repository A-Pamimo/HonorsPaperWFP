/* *************************************************************************** *
*					WFP RAM-N rCARI Validation Study - Ecuador 				   * 
*																 			   *
*  PURPOSE:  			Check Balance and Produce Excel Tables				   *
*  AUTHOR: 				Nicole Wu (nicole.wu@wfp.org)						   *
*  DATE:  				Sep 20, 2023										   *
*  LATEST UPDATE: 															   *
*		  																	   *
********************************************************************************
					
	** REQUIRES:	${dta}/Ecuador_Full_Household_Analysis.dta
					
	** CREATES:		
					
	** NOTES:		

********************************************************************************
*								PART 1: Set Log
*******************************************************************************/

	cap log close 
	
	// set log
	loc cdate: di %td_CCYY_NN_DD date(c(current_date), "DMY")
	loc cdate = subinstr(trim("`cdate'"), " " , "", .)
	log using "${logs}/e99_balance_excel_`cdate'.smcl", replace
	di `cdate'	

	graph set window fontface "Times New Roman"
	
	* Load dataset
	use "${dta}/Ecuador_Full_Household_rCARI_Analysis.dta", replace
	compress 
	
********************************************************************************
*						PART 2: Define variables
*******************************************************************************/
	
	gl bal_all 	RESPAge RESPFemale RESPHHH HHSize HHInc_PCT HHIncNb HHInc_None	 ///
				HHInc_WageSkill HHInc_WageUnskill HHInc_Trade HHInc_AgProduction ///
				HHInc_Change_None HHInc_Increase HHInc_Reduce25 HHInc_Reduce50	 /// 
				HHInc_Reduce50More
	
	gl bal_f2f 	RESPAge RESPFemale RESPHHH RESPSingle RESPMarried 				 ///
				HHDisplaced HHDisable MDDIHHDisabledNb R_HHH_Sex R_HHH_Age		 ///
				R_HHH_Literate HHSize R_Num_Male R_Num_Female R_Num_Child		 ///
				R_Num_Senior R_Num_Adult R_Num_Dependent 	 					 ///
				FemaleMale_Ratio Dependency_Ratio HHInc_PCT HHIncNb HHInc_None   ///
				HHInc_WageSkill HHInc_WageUnskill HHInc_Trade HHInc_AgProduction ///
				HHInc_Change_None HHInc_Increase HHInc_Reduce25 HHInc_Reduce50	 /// 
				HHInc_Reduce50More
	
	gl bal_rm	RESPAge RESPFemale RESPHHH HHSize HHInc_PCT HHIncNb HHInc_None	 ///
				HHInc_WageSkill HHInc_WageUnskill HHInc_Trade HHInc_AgProduction ///
				HHInc_Change_None HHInc_Increase HHInc_Reduce25 HHInc_Reduce50	 /// 
				HHInc_Reduce50More

	gl out_all  FCS rCSI LCS_None LCS_Stress LCS_Crisis LCS_Emergency 		///
				HHExpTotal PCExpTotal FES 									///
				CARI_Inc_1 CARI_Inc_2 CARI_Inc_3 CARI_Inc_4					///
				HH_Vul_FES HH_Vul_Income CARI_rCARI
				
	gl out_oth  FCS rCSI LCS_None LCS_Stress LCS_Crisis LCS_Emergency 		///
				HHExpTotal PCExpTotal FES 
				
	gl out_f2f  LCS_None LCS_Stress LCS_Crisis LCS_Emergency 						///
				HHExpFoodTotal_1M HHExpNFTotal_1M HHExpTotal PCExpTotal FES 	    ///
				RESPFoodWorry RESPFS_EnoughFood RESPFS_LessPrefer RESPFS_LessMeal   ///
				RESPFS_DayNoEat HH_Vul_FES HH_Vul_Income 
				
	gl out_rm   LCS_None LCS_Stress LCS_Crisis LCS_Emergency 						///
				HHExpFoodTotal_1M HHExpNFTotal_1M HHExpTotal PCExpTotal FES 		///
				HH_Vul_FES HH_Vul_Income 
				
	gl var_fcs	FCSStap FCSPulse FCSDairy FCSPr FCSVeg FCSFruit FCSFat FCSSugar	FCS			 	
	gl var_rcsi rCSILessQlty rCSIBorrow rCSIMealSize rCSIMealAdult rCSIMealNb rCSI
	
	gl out_fesinc CARI_Inc_1 CARI_Inc_2 CARI_Inc_3 CARI_Inc_4 FES_Cat_1 FES_Cat_2 FES_Cat_3 FES_Cat_4
	
	gl out_cari CARI_FES_Cat1 CARI_FES_Cat2 CARI_FES_Cat3 CARI_FES_Cat4 CARI_FES_Bad 	  ///
				rCARI_Inc_Cat1 rCARI_Inc_Cat2 rCARI_Inc_Cat3 rCARI_Inc_Cat4 rCARI_Inc_Bad ///
				CARI_rCARI_1 CARI_rCARI_2 CARI_rCARI_3 CARI_rCARI_4 CARI_rCARI
	
********************************************************************************
*							PART 4: Check Balance
*******************************************************************************/

	* Randomization Balance
	iebaltab ${bal_all}, grpvar(Modality) nonote nototal replace		///
             format(%12.2fc) grplabels(1 F2F @ 2 Remote) 		///
             rowvarlabels savexlsx("${tabs}/Ecuador_Demo_Modality_Balance.xlsx")
	
	iebaltab ${bal_f2f} if Modality == 1, grpvar(Form) nonote nototal replace	///
             format(%12.2fc) grplabels(1 F2F @ 2 Remote)		///
             rowvarlabels savexlsx("${tabs}/Ecuador_Demo_F2F_Length_Balance.xlsx")

	iebaltab ${bal_rm}  if Modality == 2, grpvar(Form) nonote nototal replace	///
             format(%12.2fc) grplabels(1 F2F @ 2 Remote)		///
             rowvarlabels savexlsx("${tabs}/Ecuador_Demo_RM_Length_Balance.xlsx")
	
	iebaltab ${bal_all}, grpvar(S_Phase) nonote nototal replace		///
             format(%12.2fc) grplabels(1 Phase 1 @ 2 Phase 2) 		///
             rowvarlabels savexlsx("${tabs}/Ecuador_Demo_Phase_Balance.xlsx")
			 
	iebaltab ${var_fcs} ${var_rcsi} ${out_all}, grpvar(S_Phase) nonote 		///
			 nototal replace format(%12.2fc) grplabels(1 Phase 1 @ 2 Phase 2) onerow	///
             rowvarlabels savexlsx("${tabs}/Ecuador_Outcome_Phase_Balance.xlsx")
			 
	* Outcome Balance by Survey Modality
	iebaltab ${var_fcs} ${var_rcsi} ${out_all}, grpvar(Modality) nonote 		///
			 nototal replace format(%12.2fc) grplabels(1 F2F @ 2 Remote) onerow	///
             rowvarlabels savexlsx("${tabs}/Ecuador_Outcome_Modality_Balance.xlsx")

	iebaltab ${var_fcs} ${var_rcsi} ${out_all} if Modality == 1, grpvar(Form)   ///
			 nonote nototal replace	onerow										///
             format(%12.2fc) grplabels(1 Long @ 2 Short) 						///
             rowvarlabels savexlsx("${tabs}/Ecuador_Outcome_F2F_Length_Balance.xlsx")
			 
	iebaltab ${var_fcs} ${var_rcsi} ${out_all} if Modality == 2, grpvar(Form)   ///
			 nonote nototal replace												///
             format(%12.2fc) grplabels(1 Long @ 2 Short) 	 	 				///
             rowvarlabels savexlsx("${tabs}/Ecuador_Outcome_RM_Length_Balance.xlsx")

	iebaltab ${out_fesinc}, grpvar(Modality) nonote 		///
			 nototal replace format(%12.2fc) grplabels(1 F2F @ 2 Remote) onerow	///
             rowvarlabels savexlsx("${tabs}/Ecuador_Outcome_Modality_Balance_FESINC.xlsx")
			 
	iebaltab ${out_cari}, grpvar(Modality) nonote 		///
			 nototal replace format(%12.2fc) grplabels(1 F2F @ 2 Remote) onerow	///
             rowvarlabels savexlsx("${tabs}/Ecuador_Outcome_Modality_Balance_Key.xlsx")
	// onerow


	iebaltab ${out_oth} if HH_Vul_FES == 1, grpvar(Modality)   ///
			 nonote nototal replace	onerow										///
             format(%12.2fc) grplabels(1 F2F @ 2 Remote) 						///
             rowvarlabels savexlsx("${tabs}/Ecuador_Outcome_Balance_Food_Insecure.xlsx")
			
	iebaltab ${out_oth} if HH_Vul_FES == 0, grpvar(Modality)   ///
			 nonote nototal replace	onerow										///
             format(%12.2fc) grplabels(1 F2F @ 2 Remote) 						///
             rowvarlabels savexlsx("${tabs}/Ecuador_Outcome_Balance_Food_Secure.xlsx") 
			 
	iebaltab ${out_oth} if RESPFemale == 1, grpvar(Modality)   ///
			 nonote nototal replace	onerow										///
             format(%12.2fc) grplabels(1 F2F @ 2 Remote) 						///
             rowvarlabels savexlsx("${tabs}/Ecuador_Outcome_Balance_Female.xlsx")
			
	iebaltab ${out_oth} if RESPFemale == 0, grpvar(Modality)   ///
			 nonote nototal replace	onerow										///
             format(%12.2fc) grplabels(1 F2F @ 2 Remote) 						///
             rowvarlabels savexlsx("${tabs}/Ecuador_Outcome_Balance_Male.xlsx")
			  
	iebaltab ${out_oth} if FCG_Accept == 0, grpvar(Modality)   ///
			 nonote nototal replace	onerow										///
             format(%12.2fc) grplabels(1 F2F @ 2 Remote) 						///
             rowvarlabels savexlsx("${tabs}/Ecuador_Outcome_Balance_FCG_Bad.xlsx")
			 
	iebaltab ${out_oth} if FCG_Accept == 1, grpvar(Modality)   ///
			 nonote nototal replace	onerow										///
             format(%12.2fc) grplabels(1 F2F @ 2 Remote) 						///
             rowvarlabels savexlsx("${tabs}/Ecuador_Outcome_Balance_FCG_Accept.xlsx")
