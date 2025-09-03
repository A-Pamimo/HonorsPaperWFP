/* *************************************************************************** *
*					WFP APP-FA rCARI Validation Study - BF 					   * 
*																 			   *
*  PURPOSE:  			Check Indicator Difference							   *
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

	graph set window fontface "Open Sans"
	
	* Load dataset
	use "${bf_output}/Complete_BF_Household_Analysis.dta", replace
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
	
	gl var_lcs_b Lcs_stress_DomAsset_yn Lcs_stress_HealthEdu_yn Lcs_stress_Saving_yn  ///
				 Lcs_stress_BorrowCash_yn Lcs_crisis_ProdAssets_yn 					  ///
				 Lcs_crisis_DomMigration_yn Lcs_crisis_ChildWork_yn Lcs_em_ResAsset_yn ///
				 Lcs_em_Begged_yn Lcs_em_FemAnimal_yn
				 
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
	balancetable (mean if Modality_Bin == 0)  ///
				 (mean if Modality_Bin == 1)  ///
				 (diff 	  Modality_Bin)  	  ///
		${var_cari}		 					  ///
		using "${out_tab}/CARI_FES_rCARI_Modality_BF.tex", replace ///
		vce(r) pvalues varlab nonum format(%9.2f)  ///
		starlevels( * 0.05 ** 0.01 *** 0.001 )	///
		ctitles("F2F" "Remote" "Diff" ) ///
		groups("Burkina Faso", pattern(1 0 0))
	
	balancetable (mean if Modality_Bin == 0)  ///
				 (mean if Modality_Bin == 1)  ///
				 (diff 	  Modality_Bin)  	  ///
		${var_rcari}		 ///
		using "${out_tab}/Inc_CARI_rCARI_Modality_BF.tex", replace ///
		vce(r) pvalues varlab nonum format(%9.2f)  ///
		starlevels( * 0.05 ** 0.01 *** 0.001 )	///
		ctitles("F2F" "Remote" "Diff" ) ///
		groups("Burkina Faso", pattern(1 0 0))
	
	balancetable (mean if Modality_Bin == 0)  ///
				 (mean if Modality_Bin == 1)  ///
				 (diff 	  Modality_Bin)  	  ///
		${var_comp}		 ///
		using "${out_tab}/CARI_rCARI_Modality_BF.tex", replace ///
		vce(r) pvalues varlab nonum format(%9.2f)  ///
		starlevels( * 0.05 ** 0.01 *** 0.001 )	///
		ctitles("F2F" "Remote" "Diff" ) ///
		groups("Burkina Faso", pattern(1 0 0))

	** FCS
	balancetable (mean if Modality_Bin == 0)  ///
				 (mean if Modality_Bin == 1)  ///
				 (diff 	  Modality_Bin)  	  ///
		${var_fcs}		 ///
		using "${out_tab}/FCS_Modality_BF.tex", replace ///
		vce(r) pvalues varlab nonum format(%9.2f)  ///
		starlevels( * 0.05 ** 0.01 *** 0.001 )	///
		ctitles("F2F" "Remote" "Diff" ) ///
		groups("Burkina Faso", pattern(1 0 0))
	
	balancetable (mean if Modality_Bin == 0)  ///
				 (mean if Modality_Bin == 1)  ///
				 (diff 	  Modality_Bin)  	  ///
		${var_fcs_s}		 ///
		using "${out_tab}/FCS_Modality_BF_Short.tex", replace ///
		vce(r) pvalues varlab nonum format(%9.2f)  ///
		starlevels( * 0.05 ** 0.01 *** 0.001 )	///
		ctitles("F2F" "Remote" "Diff" ) ///
		groups("Burkina Faso", pattern(1 0 0))
		
	** rCSI	
	balancetable (mean if Modality_Bin == 0)  ///
				 (mean if Modality_Bin == 1)  ///
				 (diff 	  Modality_Bin)  	  ///
		${var_rcsi}		 ///
		using "${out_tab}/rCSI_Modality_BF.tex", replace ///
		vce(r) pvalues varlab nonum format(%9.2f)  ///
		starlevels( * 0.05 ** 0.01 *** 0.001 )	///
		ctitles("F2F" "Remote" "Diff" ) ///
		groups("Burkina Faso", pattern(1 0 0))
	
	** LCS
	balancetable (mean if Modality_Bin == 0)  ///
				 (mean if Modality_Bin == 1)  ///
				 (diff 	  Modality_Bin)  	  ///
		${var_lcs}		 ///
		using "${out_tab}/LCS_Modality_BF.tex", replace ///
		vce(r) pvalues varlab nonum format(%9.2f)  ///
		starlevels( * 0.05 ** 0.01 *** 0.001 )	///
		ctitles("F2F" "Remote" "Diff" ) ///
		groups("Burkina Faso", pattern(1 0 0))
	
	balancetable (mean if Modality_Bin == 0)  ///
				 (mean if Modality_Bin == 1)  ///
				 (diff 	  Modality_Bin)  	  ///
		${var_lcs_b}		 ///
		using "${out_tab}/LCS_Ind_Modality_BF.tex", replace ///
		vce(r) pvalues varlab nonum format(%9.2f)  ///
		starlevels( * 0.05 ** 0.01 *** 0.001 )	///
		ctitles("F2F" "Remote" "Diff" ) ///
		groups("Burkina Faso", pattern(1 0 0))
		
	** FES	
	balancetable (mean if Modality_Bin == 0)  ///
				 (mean if Modality_Bin == 1)  ///
				 (diff 	  Modality_Bin)  	  ///
		${var_fes}		 ///
		using "${out_tab}/FES_Modality_BF.tex", replace ///
		vce(r) pvalues varlab nonum format(%9.2f)  ///
		starlevels( * 0.05 ** 0.01 *** 0.001 )	///
		ctitles("F2F" "Remote" "Diff" ) ///
		groups("Burkina Faso", pattern(1 0 0))
		
	** Income	
	balancetable (mean if Modality_Bin == 0)  ///
				 (mean if Modality_Bin == 1)  ///
				 (diff 	  Modality_Bin)  	  ///
		${var_inc}		 ///
		using "${out_tab}/INC_Modality_BF.tex", replace ///
		vce(r) pvalues varlab nonum format(%9.2f)  ///
		starlevels( * 0.05 ** 0.01 *** 0.001 )	///
		ctitles("F2F" "Remote" "Diff" ) ///
		groups("Burkina Faso", pattern(1 0 0))
	
********************************************************************************
*						PART 4: Check Balance on Long/Short	
*******************************************************************************/
	
	balancetable (mean if Form_Bin == 0 & Modality_Bin == 0)  ///
				 (mean if Form_Bin == 1 & Modality_Bin == 0)  ///
				 (diff 	  Form_Bin	   if Modality_Bin == 0)  ///
		${var_fcs}		 ///
		using "${out_tab}/FCS_F2F_Form_Length_BF.tex", replace  ///
		vce(r) pvalues varlab nonum format(%9.2f)  	///
		starlevels( * 0.05 ** 0.01 *** 0.001 )		///
		ctitles("Long" "Short" "Diff") ///
		groups("BF F2F", pattern(1 0 0))	
	
	balancetable (mean if Form_Bin == 0 & Modality_Bin == 0)  ///
				 (mean if Form_Bin == 1 & Modality_Bin == 0)  ///
				 (diff 	  Form_Bin	   if Modality_Bin == 0)  ///
		${var_lcs}		 ///
		using "${out_tab}/LCS_F2F_EN_FS_BF.tex", replace  ///
		vce(r) pvalues varlab nonum format(%9.2f)  	///
		starlevels( * 0.05 ** 0.01 *** 0.001 )		///
		ctitles("EN" "FS" "Diff") ///
		groups("BF F2F", pattern(1 0 0))
	
	balancetable (mean if Form_Bin == 0 & Modality_Bin == 0)  ///
				 (mean if Form_Bin == 1 & Modality_Bin == 0)  ///
				 (diff 	  Form_Bin	   if Modality_Bin == 0)  ///
		${var_lcs}		 ///
		using "${out_tab}/LCS_F2F_EN_FS_BF.tex", replace 			 ///
		vce(r) pvalues varlab nonum format(%9.2f)  	///
		starlevels( * 0.05 ** 0.01 *** 0.001 )		///
		ctitles("LCS EN" "LCS FS" "Diff" ) 			///
		groups("BF F2F", pattern(1 0 0))
		
	balancetable (mean if Form_Bin == 0 & Modality_Bin == 0)  ///
				 (mean if Form_Bin == 1 & Modality_Bin == 0)  ///
				 (diff 	  Form_Bin	   if Modality_Bin == 0)  ///
		${var_fes}		 ///
		using "${out_tab}/FES_F2F_Form_Length_BF.tex", replace  ///
		vce(r) pvalues varlab nonum format(%9.2f)  	///
		starlevels( * 0.05 ** 0.01 *** 0.001 )		///
		ctitles("Long" "Short" "Diff") ///
		groups("BF F2F", pattern(1 0 0))
		
********************************************************************************
*						PART 5: Paired t-test on CARI
*******************************************************************************/
		
	ren CARI_FES_Cat* 	C_FES_*
	ren rCARI_Inc_Cat*  rC_Inc_*
	
	** Burkina
	asdoc ttest CARI_FES_Bad == rCARI_Inc_Bad if Modality == 1, replace ///
		  save(${out_tab}/BF_F2F_Paired_ttest.doc) ///
		  fhr(\b) label dec(3) tzok
		  							   
	forval i = 1/4 {
	asdoc ttest C_FES_`i' == rC_Inc_`i' if Modality == 1, rowappend ///
		  save(${out_tab}/BF_F2F_Paired_ttest.doc) ///
		  fhr(\b) label dec(3) tzok
	}
	
	******************************* RM *****************************************

	** Burkina
	asdoc ttest CARI_FES_Bad == rCARI_Inc_Bad if Modality == 2, replace ///
		  save(${out_tab}/BF_RM_Paired_ttest.doc) ///
		  fhr(\b) label dec(3) tzok
		  							   
	forval i = 1/4 {
	asdoc ttest C_FES_`i' == rC_Inc_`i' if Modality == 2, rowappend ///
		  save(${out_tab}/BF_RM_Paired_ttest.doc) ///
		  fhr(\b) label dec(3) tzok
	}
	