/* *************************************************************************** *
*					WFP RAM-N rCARI Validation Study - Myanmar 				   * 
*																 			   *
*  PURPOSE:  			Check Randomization Balance			 				   *
*  AUTHOR: 				Nicole Wu (nicole.wu@wfp.org)						   *
*  DATE:  				Jun 30, 2023										   *
*  LATEST UPDATE: 															   *
*		  																	   *
********************************************************************************
					
	** REQUIRES:	${all_dta}/Complete_Full_Household_Analysis.dta
					
	** CREATES:		
					
	** NOTES:		

********************************************************************************
*								PART 1: Set Log
*******************************************************************************/

	cap log close 
	
	// set log
	loc cdate: di %td_CCYY_NN_DD date(c(current_date), "DMY")
	loc cdate = subinstr(trim("`cdate'"), " " , "", .)
	log using "${all_logs}/02_balance_`cdate'.smcl", replace
	di `cdate'	

	graph set window fontface "Open Sans"
	
	* Load dataset
	use "${all_dta}/Complete_Full_Household_Analysis.dta", replace
	compress 
	
********************************************************************************
*						PART 2: Define variables
*******************************************************************************/
	
	gen Modality_Bin = Modality - 1
	gen Form_Bin 	 = Form - 1
	
	gen 	Comp_F2F_RM_Long = 1 if Modality_Bin == 1 & Form_Bin == 0
	replace Comp_F2F_RM_Long = 0 if Modality_Bin == 0
	
	gen 	Comp_F2F_RM_Short = 1 if Modality_Bin == 1 & Form_Bin == 1
	replace Comp_F2F_RM_Short = 0 if Modality_Bin == 0
	
	gl var_fcs	FCS FCG_Acceptable FCG_Borderline FCG_Poor ///
				FCSStap FCSPulse FCSDairy FCSPr FCSVeg FCSFruit FCSFat FCSSugar
	gl var_fcs_s FCS FCG_Acceptable FCG_Borderline FCG_Poor
	
	gl var_rcsi rCSI rCSI_Phase1 rCSI_Phase2 rCSI_Phase3_5 ///
				rCSILessQlty rCSIBorrow rCSIMealSize rCSIMealAdult rCSIMealNb 
							
	gl var_cur	FCS_rCSI_4pt_1 FCS_rCSI_4pt_2 FCS_rCSI_4pt_3 FCS_rCSI_4pt_4
	
	gl var_lcs_m Lcs_stress_DomAsset_yn Lcs_stress_CrdtFood_yn Lcs_stress_Saving_yn ///
				 Lcs_stress_BorrowCash_yn Lcs_crisis_ProdAssets_yn 					///
				 Lcs_crisis_Health_yn Lcs_crisis_OutSchool_yn Lcs_em_ChildWork_yn 	///
				 Lcs_em_Begged_yn Lcs_em_IllegalAct_yn 
				 
	gl var_lcs_e Lcs_stress_DomAsset_yn Lcs_stress_CrdtFood_yn Lcs_stress_Saving_yn  ///
				 Lcs_stress_BorrowCash_yn Lcs_crisis_ProdAssets_yn 					 ///
				 Lcs_crisis_HealthEdu_yn Lcs_crisis_OutSchool_yn Lcs_em_ChildWork_yn ///
				 Lcs_em_Begged_yn Lcs_em_IllegalAct_yn 
	
	gl var_lcs_c Lcs_stress_DomAsset_yn Lcs_stress_HealthEdu_yn Lcs_stress_Saving_yn  ///
				 Lcs_stress_BorrowCash_yn Lcs_crisis_ProdAssets_yn 					  ///
				 Lcs_crisis_DomMigration_yn Lcs_crisis_OutSchool_yn Lcs_em_ResAsset_yn ///
				 Lcs_em_Begged_yn Lcs_em_IllegalAct_yn
				 
	gl var_lcs	 LCS_None LCS_Stress LCS_Crisis LCS_Emergency
	// Lcs_Stress_Coping 	Lcs_Crisis_Coping Lcs_Emergency_Coping 
	
	gl var_fes  FES FES_Cat_1 FES_Cat_2 FES_Cat_3 FES_Cat_4
	// HHExpFoodTotal_1M HHExpNFTotal_1M HHExpTotal PCExpTotal 
	
	gl var_inc  CARI_Inc_1 CARI_Inc_2 CARI_Inc_3 CARI_Inc_4 
	
	// HHIncFirst_Accept HHIncFirst_Border HHIncFirst_Poor 
	// HHInc_Change_None HHInc_Increase HHInc_Reduce25 HHInc_Reduce50 HHInc_Reduce50More 
		
	gl var_cari  CARI_FES_Cat1 CARI_FES_Cat2 CARI_FES_Cat3 CARI_FES_Cat4 CARI_FES_Bad
	
	gl var_rcari rCARI_Inc_Cat1 rCARI_Inc_Cat2 rCARI_Inc_Cat3 rCARI_Inc_Cat4 rCARI_Inc_Bad 
	
	gl var_comp	 CARI_rCARI_1 CARI_rCARI_2 CARI_rCARI_3 CARI_rCARI_4 CARI_rCARI
	
********************************************************************************
*						`PART 4: Check Balance on Modality
*******************************************************************************/
	

	** CARI	
	balancetable (mean if Modality_Bin == 0 & Country == 1 & Err_ExpNF == 0)  ///
				 (mean if Modality_Bin == 1 & Country == 1 & Err_ExpNF == 0)  ///
				 (diff 	  Modality_Bin 	   if Country == 1 & Err_ExpNF == 0)  ///
				 (mean if Modality_Bin == 0 & Country == 2)  ///
				 (mean if Modality_Bin == 1 & Country == 2)  ///
				 (diff 	  Modality_Bin 	   if Country == 2)  ///
				 (mean if Modality_Bin == 0 & Country == 3 & S_phone_ownership == 1)  ///
				 (mean if Modality_Bin == 1 & Country == 3 & S_phone_ownership == 1)  ///
				 (diff 	  Modality_Bin 	   if Country == 3 & S_phone_ownership == 1)  ///		 
		${var_cari}		 ///
		using "${all_tex_tab}/CARI_FES_rCARI_Modality_All_Country.tex", replace ///
		vce(r) pvalues varlab nonum format(%9.2f)  ///
		starlevels( * 0.05 ** 0.01 *** 0.001 )	///
		ctitles("F2F" "Remote" "Diff" "F2F" "Remote" "Diff" "F2F" "Remote" "Diff" ) ///
		groups("Myanmar" "Ecuador" "CAR", pattern(1 0 0 1 0 0 1 0 0))
	
	balancetable (mean if Modality_Bin == 0 & Country == 1 & Err_ExpNF == 0)  ///
				 (mean if Modality_Bin == 1 & Country == 1 & Err_ExpNF == 0)  ///
				 (diff 	  Modality_Bin 	   if Country == 1 & Err_ExpNF == 0)  ///
				 (mean if Modality_Bin == 0 & Country == 2)  ///
				 (mean if Modality_Bin == 1 & Country == 2)  ///
				 (diff 	  Modality_Bin 	   if Country == 2)  ///
				 (mean if Modality_Bin == 0 & Country == 3 & S_phone_ownership == 1)  ///
				 (mean if Modality_Bin == 1 & Country == 3 & S_phone_ownership == 1)  ///
				 (diff 	  Modality_Bin 	   if Country == 3 & S_phone_ownership == 1)  ///		 
		${var_rcari}		 ///
		using "${all_tex_tab}/Inc_CARI_rCARI_Modality_All_Country.tex", replace ///
		vce(r) pvalues varlab nonum format(%9.2f)  ///
		starlevels( * 0.05 ** 0.01 *** 0.001 )	///
		ctitles("F2F" "Remote" "Diff" "F2F" "Remote" "Diff" "F2F" "Remote" "Diff" ) ///
		groups("Myanmar" "Ecuador" "CAR", pattern(1 0 0 1 0 0 1 0 0))
	
	balancetable (mean if Modality_Bin == 0 & Country == 1 & Err_ExpNF == 0)  ///
				 (mean if Modality_Bin == 1 & Country == 1 & Err_ExpNF == 0)  ///
				 (diff 	  Modality_Bin 	   if Country == 1 & Err_ExpNF == 0)  ///
				 (mean if Modality_Bin == 0 & Country == 2)  ///
				 (mean if Modality_Bin == 1 & Country == 2)  ///
				 (diff 	  Modality_Bin 	   if Country == 2)  ///
				 (mean if Modality_Bin == 0 & Country == 3 & S_phone_ownership == 1)  ///
				 (mean if Modality_Bin == 1 & Country == 3 & S_phone_ownership == 1)  ///
				 (diff 	  Modality_Bin 	   if Country == 3 & S_phone_ownership == 1)  ///		 
		${var_comp}		 ///
		using "${all_tex_tab}/CARI_rCARI_Modality_All_Country.tex", replace ///
		vce(r) pvalues varlab nonum format(%9.2f)  ///
		starlevels( * 0.05 ** 0.01 *** 0.001 )	///
		ctitles("F2F" "Remote" "Diff" "F2F" "Remote" "Diff" "F2F" "Remote" "Diff" ) ///
		groups("Myanmar" "Ecuador" "CAR", pattern(1 0 0 1 0 0 1 0 0))

	** FCS
	balancetable (mean if Modality_Bin == 0 & Country == 1)  ///
				 (mean if Modality_Bin == 1 & Country == 1)  ///
				 (diff 	  Modality_Bin 	   if Country == 1)  ///
				 (mean if Modality_Bin == 0 & Country == 2)  ///
				 (mean if Modality_Bin == 1 & Country == 2)  ///
				 (diff 	  Modality_Bin 	   if Country == 2)  ///
				 (mean if Modality_Bin == 0 & Country == 3 & S_phone_ownership == 1)  ///
				 (mean if Modality_Bin == 1 & Country == 3 & S_phone_ownership == 1)  ///
				 (diff 	  Modality_Bin 	   if Country == 3 & S_phone_ownership == 1)  ///		 
		${var_fcs}		 ///
		using "${all_tex_tab}/FCS_Modality_All_Country.tex", replace ///
		vce(r) pvalues varlab nonum format(%9.2f)  ///
		starlevels( * 0.05 ** 0.01 *** 0.001 )	///
		ctitles("F2F" "Remote" "Diff" "F2F" "Remote" "Diff" "F2F" "Remote" "Diff" ) ///
		groups("Myanmar" "Ecuador" "CAR", pattern(1 0 0 1 0 0 1 0 0))
	
	balancetable (mean if Modality_Bin == 0 & Country == 1)  ///
				 (mean if Modality_Bin == 1 & Country == 1)  ///
				 (diff 	  Modality_Bin 	   if Country == 1)  ///
				 (mean if Modality_Bin == 0 & Country == 2)  ///
				 (mean if Modality_Bin == 1 & Country == 2)  ///
				 (diff 	  Modality_Bin 	   if Country == 2)  ///
				 (mean if Modality_Bin == 0 & Country == 3 & S_phone_ownership == 1)  ///
				 (mean if Modality_Bin == 1 & Country == 3 & S_phone_ownership == 1)  ///
				 (diff 	  Modality_Bin 	   if Country == 3 & S_phone_ownership == 1)  ///		 
		${var_fcs_s}		 ///
		using "${all_tex_tab}/FCS_Modality_All_Country_Short.tex", replace ///
		vce(r) pvalues varlab nonum format(%9.2f)  ///
		starlevels( * 0.05 ** 0.01 *** 0.001 )	///
		ctitles("F2F" "Remote" "Diff" "F2F" "Remote" "Diff" "F2F" "Remote" "Diff" ) ///
		groups("Myanmar" "Ecuador" "CAR", pattern(1 0 0 1 0 0 1 0 0))
		
	** rCSI	
	balancetable (mean if Modality_Bin == 0 & Country == 1)  ///
				 (mean if Modality_Bin == 1 & Country == 1)  ///
				 (diff 	  Modality_Bin 	   if Country == 1)  ///
				 (mean if Modality_Bin == 0 & Country == 2)  ///
				 (mean if Modality_Bin == 1 & Country == 2)  ///
				 (diff 	  Modality_Bin 	   if Country == 2)  ///
				 (mean if Modality_Bin == 0 & Country == 3 & S_phone_ownership == 1)  ///
				 (mean if Modality_Bin == 1 & Country == 3 & S_phone_ownership == 1)  ///
				 (diff 	  Modality_Bin 	   if Country == 3 & S_phone_ownership == 1)  ///		 
		${var_rcsi}		 ///
		using "${all_tex_tab}/rCSI_Modality_All_Country.tex", replace ///
		vce(r) pvalues varlab nonum format(%9.2f)  	///
		starlevels( * 0.05 ** 0.01 *** 0.001 )		///
		ctitles("F2F" "Remote" "Diff" "F2F" "Remote" "Diff" "F2F" "Remote" "Diff" ) ///
		groups("Myanmar" "Ecuador" "CAR", pattern(1 0 0 1 0 0 1 0 0))
	
	** LCS
	balancetable (mean if Modality_Bin == 0 & Country == 1)  ///
				 (mean if Modality_Bin == 1 & Country == 1)  ///
				 (diff 	  Modality_Bin 	   if Country == 1)  ///
				 (mean if Modality_Bin == 0 & Country == 2)  ///
				 (mean if Modality_Bin == 1 & Country == 2)  ///
				 (diff 	  Modality_Bin 	   if Country == 2)  ///
				 (mean if Modality_Bin == 0 & Country == 3 & S_phone_ownership == 1)  ///
				 (mean if Modality_Bin == 1 & Country == 3 & S_phone_ownership == 1)  ///
				 (diff 	  Modality_Bin 	   if Country == 3 & S_phone_ownership == 1)  ///		 
		${var_lcs}		 ///
		using "${all_tex_tab}/LCS_Modality_All_Country.tex", replace ///
		vce(r) pvalues varlab nonum format(%9.2f)  ///
		starlevels( * 0.05 ** 0.01 *** 0.001 )	///
		ctitles("F2F" "Remote" "Diff" "F2F" "Remote" "Diff" "F2F" "Remote" "Diff" ) ///
		groups("Myanmar" "Ecuador" "CAR", pattern(1 0 0 1 0 0 1 0 0))
	
	balancetable (mean if Modality_Bin == 0 & Country == 1)  ///
				 (mean if Modality_Bin == 1 & Country == 1)  ///
				 (diff 	  Modality_Bin	   if Country == 1)  ///
		${var_lcs_m}		 ///
		using "${all_tex_tab}/LCS_Ind_Modality_Myanmar.tex", replace 			 ///
		vce(r) pvalues varlab nonum format(%9.2f)  	///
		starlevels( * 0.05 ** 0.01 *** 0.001 )		///
		ctitles("F2F" "Remote" "Diff") 			///
		groups("Myanmar", pattern(1 0 0))
		
	balancetable (mean if Modality_Bin == 0 & Country == 2)  ///
				 (mean if Modality_Bin == 1 & Country == 2)  ///
				 (diff 	  Modality_Bin	   if Country == 2)  ///
		${var_lcs_e}		 ///
		using "${all_tex_tab}/LCS_Ind_Modality_Ecuador.tex", replace 			 ///
		vce(r) pvalues varlab nonum format(%9.2f)  	///
		starlevels( * 0.05 ** 0.01 *** 0.001 )		///
		ctitles("F2F" "Remote" "Diff" "Diff" ) 			///
		groups("Ecuador", pattern(1 0 0))
		
	balancetable (mean if Modality_Bin == 0 & Country == 3 & S_phone_ownership == 1)  ///
				 (mean if Modality_Bin == 1 & Country == 3 & S_phone_ownership == 1)  ///
				 (diff 	  Modality_Bin	   if Country == 3 & S_phone_ownership == 1)  ///
		${var_lcs_c}		 ///
		using "${all_tex_tab}/LCS_Ind_Modality_CAR.tex", replace 			 ///
		vce(r) pvalues varlab nonum format(%9.2f)  	///
		starlevels( * 0.05 ** 0.01 *** 0.001 )		///
		ctitles("F2F" "Remote" "Diff" ) 			///
		groups("CAR", pattern(1 0 0))
		
	** FES	
	balancetable (mean if Modality_Bin == 0 & Country == 1 & Err_ExpNF == 0)  ///
				 (mean if Modality_Bin == 1 & Country == 1 & Err_ExpNF == 0)  ///
				 (diff 	  Modality_Bin 	   if Country == 1 & Err_ExpNF == 0)  ///
				 (mean if Modality_Bin == 0 & Country == 2)  ///
				 (mean if Modality_Bin == 1 & Country == 2)  ///
				 (diff 	  Modality_Bin 	   if Country == 2)  ///
				 (mean if Modality_Bin == 0 & Country == 3 & S_phone_ownership == 1)  ///
				 (mean if Modality_Bin == 1 & Country == 3 & S_phone_ownership == 1)  ///
				 (diff 	  Modality_Bin 	   if Country == 3 & S_phone_ownership == 1)  ///		 
		${var_fes}		 ///
		using "${all_tex_tab}/FES_Modality_All_Country.tex", replace ///
		vce(r) pvalues varlab nonum format(%9.2f)  ///
		starlevels( * 0.05 ** 0.01 *** 0.001 )	///
		ctitles("F2F" "Remote" "Diff" "F2F" "Remote" "Diff" "F2F" "Remote" "Diff" ) ///
		groups("Myanmar" "Ecuador" "CAR", pattern(1 0 0 1 0 0 1 0 0))
		
	** Income	
	balancetable (mean if Modality_Bin == 0 & Country == 1)  ///
				 (mean if Modality_Bin == 1 & Country == 1)  ///
				 (diff 	  Modality_Bin 	   if Country == 1)  ///
				 (mean if Modality_Bin == 0 & Country == 2)  ///
				 (mean if Modality_Bin == 1 & Country == 2)  ///
				 (diff 	  Modality_Bin 	   if Country == 2)  ///
				 (mean if Modality_Bin == 0 & Country == 3 & S_phone_ownership == 1)  ///
				 (mean if Modality_Bin == 1 & Country == 3 & S_phone_ownership == 1)  ///
				 (diff 	  Modality_Bin 	   if Country == 3 & S_phone_ownership == 1)  ///		 
		${var_inc}		 ///
		using "${all_tex_tab}/INC_Modality_All_Country.tex", replace ///
		vce(r) pvalues varlab nonum format(%9.2f)  ///
		starlevels( * 0.05 ** 0.01 *** 0.001 )	///
		ctitles("F2F" "Remote" "Diff" "F2F" "Remote" "Diff" "F2F" "Remote" "Diff" ) ///
		groups("Myanmar" "Ecuador" "CAR", pattern(1 0 0 1 0 0 1 0 0))
	
********************************************************************************
*						PART 4: Check Balance on Long/Short	
*******************************************************************************/
	
	balancetable (mean if Form_Bin == 0 & Modality_Bin == 0 & Country == 1)  ///
				 (mean if Form_Bin == 1 & Modality_Bin == 0 & Country == 1)  ///
				 (diff 	  Form_Bin	   if Modality_Bin == 0 & Country == 1)  ///
				 (mean if Form_Bin == 0 & Modality_Bin == 0 & Country == 2)  ///
				 (mean if Form_Bin == 1 & Modality_Bin == 0 & Country == 2)  ///
				 (diff 	  Form_Bin	   if Modality_Bin == 0 & Country == 2)  /// 
				 (mean if Form_Bin == 0 & Modality_Bin == 0 & Country == 3 & S_phone_ownership == 1)  ///
				 (mean if Form_Bin == 1 & Modality_Bin == 0 & Country == 3 & S_phone_ownership == 1)  ///
				 (diff 	  Form_Bin	   if Modality_Bin == 0 & Country == 3 & S_phone_ownership == 1)  ///
		${var_fcs}		 ///
		using "${all_tex_tab}/FCS_F2F_Form_Length_All_Country.tex", replace  ///
		vce(r) pvalues varlab nonum format(%9.2f)  	///
		starlevels( * 0.05 ** 0.01 *** 0.001 )		///
		ctitles("Long" "Short" "Diff" "Long" "Short" "Diff" "Long" "Short" "Diff") ///
		groups("Myanmar F2F" "Ecuador F2F" "CAR F2F", pattern(1 0 0 1 0 0 1 0 0))	
	
	balancetable (mean if Form_Bin == 0 & Modality_Bin == 0 & Country == 1)  ///
				 (mean if Form_Bin == 1 & Modality_Bin == 0 & Country == 1)  ///
				 (diff 	  Form_Bin	   if Modality_Bin == 0 & Country == 1)  ///
				 (mean if Form_Bin == 0 & Modality_Bin == 0 & Country == 2)  ///
				 (mean if Form_Bin == 1 & Modality_Bin == 0 & Country == 2)  ///
				 (diff 	  Form_Bin	   if Modality_Bin == 0 & Country == 2)  /// 
				 (mean if Form_Bin == 0 & Modality_Bin == 0 & Country == 3 & S_phone_ownership == 1)  ///
				 (mean if Form_Bin == 1 & Modality_Bin == 0 & Country == 3 & S_phone_ownership == 1)  ///
				 (diff 	  Form_Bin	   if Modality_Bin == 0 & Country == 3 & S_phone_ownership == 1)  ///
		${var_lcs}		 ///
		using "${all_tex_tab}/LCS_F2F_EN_FS_All_Country.tex", replace  ///
		vce(r) pvalues varlab nonum format(%9.2f)  	///
		starlevels( * 0.05 ** 0.01 *** 0.001 )		///
		ctitles("EN" "FS" "Diff" "EN" "FS" "Diff" "EN" "FS" "Diff") ///
		groups("Myanmar F2F" "Ecuador F2F" "CAR F2F", pattern(1 0 0 1 0 0 1 0 0))
	
	
	balancetable (mean if Form_Bin == 0 & Modality_Bin == 0 & Country == 1)  ///
				 (mean if Form_Bin == 1 & Modality_Bin == 0 & Country == 1)  ///
				 (diff 	  Form_Bin	   if Modality_Bin == 0 & Country == 1)  ///
		${var_lcs_m}		 ///
		using "${all_tex_tab}/LCS_F2F_EN_FS_Myanmar.tex", replace 			 ///
		vce(r) pvalues varlab nonum format(%9.2f)  	///
		starlevels( * 0.05 ** 0.01 *** 0.001 )		///
		ctitles("LCS EN" "LCS FS" "Diff" ) 			///
		groups("Myanmar F2F", pattern(1 0 0))
		
	balancetable (mean if Form_Bin == 0 & Modality_Bin == 0 & Country == 2)  ///
				 (mean if Form_Bin == 1 & Modality_Bin == 0 & Country == 2)  ///
				 (diff 	  Form_Bin	   if Modality_Bin == 0 & Country == 2)  ///
		${var_lcs_e}					///
		using "${all_tex_tab}/LCS_F2F_EN_FS_Ecuador.tex", replace 			 ///
		vce(r) pvalues varlab nonum format(%9.2f)  	///
		starlevels( * 0.05 ** 0.01 *** 0.001 )		///
		ctitles("LCS EN" "LCS FS" "Diff" ) 			///
		groups("Ecuador F2F", pattern(1 0 0))
	
	balancetable (mean if Form_Bin == 0 & Modality_Bin == 0 & Country == 3 & S_phone_ownership == 1)  ///
				 (mean if Form_Bin == 1 & Modality_Bin == 0 & Country == 3 & S_phone_ownership == 1)  ///
				 (diff 	  Form_Bin	   if Modality_Bin == 0 & Country == 3 & S_phone_ownership == 1)  ///
		${var_lcs_c}		 				///
		using "${all_tex_tab}/LCS_F2F_EN_FS_CAR.tex", replace 				 ///
		vce(r) pvalues varlab nonum format(%9.2f)  	///
		starlevels( * 0.05 ** 0.01 *** 0.001 )		///
		ctitles("LCS EN" "LCS FS" "Diff" ) 			///
		groups("CAR F2F", pattern(1 0 0))
		
	balancetable (mean if Form_Bin == 0 & Modality_Bin == 0 & Country == 1)  ///
				 (mean if Form_Bin == 1 & Modality_Bin == 0 & Country == 1)  ///
				 (diff 	  Form_Bin	   if Modality_Bin == 0 & Country == 1)  ///
				 (mean if Form_Bin == 0 & Modality_Bin == 0 & Country == 2)  ///
				 (mean if Form_Bin == 1 & Modality_Bin == 0 & Country == 2)  ///
				 (diff 	  Form_Bin	   if Modality_Bin == 0 & Country == 2)  /// 
				 (mean if Form_Bin == 0 & Modality_Bin == 0 & Country == 3 & S_phone_ownership == 1)  ///
				 (mean if Form_Bin == 1 & Modality_Bin == 0 & Country == 3 & S_phone_ownership == 1)  ///
				 (diff 	  Form_Bin	   if Modality_Bin == 0 & Country == 3 & S_phone_ownership == 1)  ///
		${var_fes}		 ///
		using "${all_tex_tab}/FES_F2F_Form_Length_All_Country.tex", replace  ///
		vce(r) pvalues varlab nonum format(%9.2f)  	///
		starlevels( * 0.05 ** 0.01 *** 0.001 )		///
		ctitles("Long" "Short" "Diff" "Long" "Short" "Diff" "Long" "Short" "Diff") ///
		groups("Myanmar F2F" "Ecuador F2F" "CAR F2F", pattern(1 0 0 1 0 0 1 0 0))
	
	* F2F vs. Remote Long only 
	
	balancetable (mean if 					Comp_F2F_RM_Long == 0 & Country == 1)  ///
				 (mean if 					Comp_F2F_RM_Long == 1 & Country == 1)  ///
				 (diff Comp_F2F_RM_Long	if  !mi(Comp_F2F_RM_Long) & Country == 1) ///
				 (mean if 				    Comp_F2F_RM_Long == 0 & Country == 2)  ///
				 (mean if 					Comp_F2F_RM_Long == 1 & Country == 2)  ///
				 (diff Comp_F2F_RM_Long	if  !mi(Comp_F2F_RM_Long) & Country == 2) ///
				 (mean if 				    Comp_F2F_RM_Long == 0 & Country == 3 & S_phone_ownership == 1)  ///
				 (mean if 					Comp_F2F_RM_Long == 1 & Country == 3 & S_phone_ownership == 1)  ///
				 (diff Comp_F2F_RM_Long if  !mi(Comp_F2F_RM_Long) & Country == 3 & S_phone_ownership == 1) ///
		${var_fes}		 ///
		using "${all_tex_tab}/FES_F2F_Long_All_Country.tex", replace  ///
		vce(r) pvalues varlab nonum format(%9.2f)  	///
		starlevels( * 0.05 ** 0.01 *** 0.001 )		///
		ctitles("F2F" "Remote Long" "Diff" "F2F" "Remote Long" "Diff" "F2F" "Remote Long" "Diff") ///
		groups("Myanmar" "Ecuador" "CAR", pattern(1 0 0 1 0 0 1 0 0))
	
	balancetable (mean if 				    Comp_F2F_RM_Short == 0 & Country == 2)  ///
				 (mean if 					Comp_F2F_RM_Short == 1 & Country == 2)  ///
				 (diff Comp_F2F_RM_Short if !mi(Comp_F2F_RM_Short) & Country == 2) ///
				 (mean if 				    Comp_F2F_RM_Short == 0 & Country == 3 & S_phone_ownership == 1)  ///
				 (mean if 					Comp_F2F_RM_Short == 1 & Country == 3 & S_phone_ownership == 1)  ///
				 (diff Comp_F2F_RM_Short if !mi(Comp_F2F_RM_Short) & Country == 3 & S_phone_ownership == 1) ///
		${var_fes}		 ///
		using "${all_tex_tab}/FES_F2F_Short_ECU_CAR.tex", replace  ///
		vce(r) pvalues varlab nonum format(%9.2f)  	///
		starlevels( * 0.05 ** 0.01 *** 0.001 )		///
		ctitles("F2F" "Remote Short" "Diff" "F2F" "Remote Short" "Diff") ///
		groups("Ecuador" "CAR", pattern(1 0 0 1 0 0))

		
	balancetable (mean if Form_Bin == 0 & Modality_Bin == 1 & Country == 2)  ///
				 (mean if Form_Bin == 1 & Modality_Bin == 1 & Country == 2)  ///
				 (diff 	  Form_Bin	   if Modality_Bin == 1 & Country == 2)  /// 
				 (mean if Form_Bin == 0 & Modality_Bin == 1 & Country == 3 & S_phone_ownership == 1)  ///
				 (mean if Form_Bin == 1 & Modality_Bin == 1 & Country == 3 & S_phone_ownership == 1)  ///
				 (diff 	  Form_Bin	   if Modality_Bin == 1 & Country == 3 & S_phone_ownership == 1)  ///
		${var_fes}		 ///
		using "${all_tex_tab}/FES_RM_Form_Length_ECU_CAR.tex", replace  ///
		vce(r) pvalues varlab nonum format(%9.2f)  	///
		starlevels( * 0.05 ** 0.01 *** 0.001 )		///
		ctitles("Long" "Short" "Diff" "Long" "Short" "Diff") ///
		groups("Ecuador RM" "CAR RM", pattern(1 0 0 1 0 0))	
		
********************************************************************************
*						PART 5: Paired t-test on CARI
*******************************************************************************/
		
	ren CARI_FES_Cat* 	C_FES_*
	ren rCARI_Inc_Cat*  rC_Inc_*
	
	** Myanmar
	asdoc ttest CARI_FES_Bad == rCARI_Inc_Bad if Modality == 1 & Country == 1, replace ///
		  save(${all_tex_tab}/Myanmar_F2F_Paired_ttest.doc) ///
		  fhr(\b) label dec(3) tzok
		  							   
	forval i = 1/4 {
	asdoc ttest C_FES_`i' == rC_Inc_`i' if Modality == 1 & Country == 1, rowappend ///
		  save(${all_tex_tab}/Myanmar_F2F_Paired_ttest.doc) ///
		  fhr(\b) label dec(3) tzok
	}
	
	** Ecuador
	asdoc ttest CARI_FES_Bad == rCARI_Inc_Bad if Modality == 1 & Country == 2, replace ///
		  save(${all_tex_tab}/Ecuador_F2F_Paired_ttest.doc) ///
		  fhr(\b) label dec(3) tzok
		  							   
	forval i = 1/4 {
	asdoc ttest C_FES_`i' == rC_Inc_`i' if Modality == 1 & Country == 2, rowappend ///
		  save(${all_tex_tab}/Ecuador_F2F_Paired_ttest.doc) ///
		  fhr(\b) label dec(3) tzok
	}
	
	** CAR
	asdoc ttest CARI_FES_Bad == rCARI_Inc_Bad if Modality == 1 & Country == 3 & S_phone_ownership == 1, replace ///
		  save(${all_tex_tab}/CAR_F2F_Paired_ttest.doc) ///
		  fhr(\b) label dec(3) tzok
		  							   
	forval i = 1/4 {
	asdoc ttest C_FES_`i' == rC_Inc_`i' if Modality == 1 & Country == 3 & S_phone_ownership == 1, rowappend ///
		  save(${all_tex_tab}/CAR_F2F_Paired_ttest.doc) ///
		  fhr(\b) label dec(3) tzok
	}
	
	******************************* RM *****************************************

	** Myanmar
	asdoc ttest CARI_FES_Bad == rCARI_Inc_Bad if Modality == 2 & Country == 1 & Err_ExpNF == 0, replace ///
		  save(${all_tex_tab}/Myanmar_RM_Paired_ttest.doc) ///
		  fhr(\b) label dec(3) tzok
		  							   
	forval i = 1/4 {
	asdoc ttest C_FES_`i' == rC_Inc_`i' if Modality == 2 & Country == 1 & Err_ExpNF == 0, rowappend ///
		  save(${all_tex_tab}/Myanmar_RM_Paired_ttest.doc) ///
		  fhr(\b) label dec(3) tzok 
	}
	
	** Ecuador
	asdoc ttest CARI_FES_Bad == rCARI_Inc_Bad if Modality == 2 & Country == 2, replace ///
		  save(${all_tex_tab}/Ecuador_RM_Paired_ttest.doc) ///
		  fhr(\b) label dec(3) tzok
		  							   
	forval i = 1/4 {
	asdoc ttest C_FES_`i' == rC_Inc_`i' if Modality == 2 & Country == 2, rowappend ///
		  save(${all_tex_tab}/Ecuador_RM_Paired_ttest.doc) ///
		  fhr(\b) label dec(3) tzok
	}
	
	** CAR
	asdoc ttest CARI_FES_Bad == rCARI_Inc_Bad if Modality == 2 & Country == 3 & S_phone_ownership == 1, replace ///
		  save(${all_tex_tab}/CAR_RM_Paired_ttest.doc) ///
		  fhr(\b) label dec(3) tzok
		  							   
	forval i = 1/4 {
	asdoc ttest C_FES_`i' == rC_Inc_`i' if Modality == 2 & Country == 3 & S_phone_ownership == 1, rowappend ///
		  save(${all_tex_tab}/CAR_RM_Paired_ttest.doc) ///
		  fhr(\b) label dec(3) tzok
	}
	