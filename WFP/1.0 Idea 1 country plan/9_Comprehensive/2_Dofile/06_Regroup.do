/* *************************************************************************** *
*						WFP RAM-N rCARI Validation Study 					   * 
*																 			   *
*  PURPOSE:  			Compare key CARI/rCARI indicators after re-grouping	   *
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
				FCG_Country_Poor FCG_Country_Borderline FCG_Country_Acceptable
	
	gl var_source HHIncFirst_Accept HHIncFirst_Border HHIncFirst_Poor ///
				  HHIncFirst_Accept_Re HHIncFirst_Border_Re HHIncFirst_Poor_Re

	gl var_inc  CARI_Inc_1 CARI_Inc_2 CARI_Inc_3 CARI_Inc_4 ///
				CARI_Inc_Re_1 CARI_Inc_Re_2 CARI_Inc_Re_3 CARI_Inc_Re_4
	
	gl var_cari  CARI_FES_Cat1 CARI_FES_Cat2 CARI_FES_Cat3 CARI_FES_Cat4 ///
	CARI_FES_Cat_Country1 CARI_FES_Cat_Country2 CARI_FES_Cat_Country3 CARI_FES_Cat_Country4
	
	gl var_rcari rCARI_Inc_Cat1 rCARI_Inc_Cat2 rCARI_Inc_Cat3 rCARI_Inc_Cat4 ///
				 CARI_Inc_Cat_Re1 CARI_Inc_Cat_Re2 CARI_Inc_Cat_Re3 CARI_Inc_Cat_Re4
	
	gl var_comp CARI_rCARI_1 CARI_rCARI_2 CARI_rCARI_3 CARI_rCARI_4 ///
				CARI_rCARI_Country_Re_1 CARI_rCARI_Country_Re_2 CARI_rCARI_Country_Re_3 CARI_rCARI_Country_Re_4
	
********************************************************************************
*						`PART 4: Check Balance on Modality
*******************************************************************************/
	
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
		using "${tex_tab_re}/FCS_Modality_All_Country.tex", replace ///
		vce(r) pvalues pval(fmt(%5.3f)) varlab nonum format(%9.2f)  ///
		starlevels( * 0.05 ** 0.01 *** 0.001 )	///
		ctitles("F2F" "Remote" "Diff" "F2F" "Remote" "Diff" "F2F" "Remote" "Diff" ) ///
		groups("Myanmar" "Ecuador" "CAR", pattern(1 0 0 1 0 0 1 0 0))
	
	* CARI vs rCARI
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
		using "${tex_tab_re}/CARI_rCARI_Modality_All_Country.tex", replace ///
		vce(r) pvalues pval(fmt(%5.3f)) varlab nonum format(%9.2f)  ///
		starlevels( * 0.05 ** 0.01 *** 0.001 )	///
		ctitles("F2F" "Remote" "Diff" "F2F" "Remote" "Diff" "F2F" "Remote" "Diff" ) ///
		groups("Myanmar" "Ecuador" "CAR", pattern(1 0 0 1 0 0 1 0 0))
	
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
		using "${tex_tab_re}/CARI_FES_rCARI_Modality_All_Country.tex", replace ///
		vce(r) pvalues pval(fmt(%5.3f)) varlab nonum format(%9.2f)  ///
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
		using "${tex_tab_re}/Inc_CARI_rCARI_Modality_All_Country.tex", replace ///
		vce(r) pvalues pval(fmt(%5.3f)) varlab nonum format(%9.2f)  ///
		starlevels( * 0.05 ** 0.01 *** 0.001)	///
		ctitles("F2F" "Remote" "Diff" "F2F" "Remote" "Diff" "F2F" "Remote" "Diff" ) ///
		groups("Myanmar" "Ecuador" "CAR", pattern(1 0 0 1 0 0 1 0 0))

/*******************************************************************************
*						PART 5: Paired t-test on CARI
********************************************************************************
		
	ren CARI_FES_Cat* 	C_FES_*
	ren rCARI_Inc_Cat*  rC_Inc_*
	
	** Myanmar
	asdoc ttest CARI_FES_Bad == rCARI_Inc_Bad if Modality == 1 & Country == 1, replace ///
		  save(${tex_tab_re}/Myanmar_F2F_Paired_ttest.doc) ///
		  fhr(\b) label dec(3) tzok
		  							   
	forval i = 1/4 {
	asdoc ttest C_FES_`i' == rC_Inc_`i' if Modality == 1 & Country == 1, rowappend ///
		  save(${tex_tab_re}/Myanmar_F2F_Paired_ttest.doc) ///
		  fhr(\b) label dec(3) tzok
	}
	
	** Ecuador
	asdoc ttest CARI_FES_Bad == rCARI_Inc_Bad if Modality == 1 & Country == 2, replace ///
		  save(${tex_tab_re}/Ecuador_F2F_Paired_ttest.doc) ///
		  fhr(\b) label dec(3) tzok
		  							   
	forval i = 1/4 {
	asdoc ttest C_FES_`i' == rC_Inc_`i' if Modality == 1 & Country == 2, rowappend ///
		  save(${tex_tab_re}/Ecuador_F2F_Paired_ttest.doc) ///
		  fhr(\b) label dec(3) tzok
	}
	
	** CAR
	asdoc ttest CARI_FES_Bad == rCARI_Inc_Bad if Modality == 1 & Country == 3 & S_phone_ownership == 1, replace ///
		  save(${tex_tab_re}/CAR_F2F_Paired_ttest.doc) ///
		  fhr(\b) label dec(3) tzok
		  							   
	forval i = 1/4 {
	asdoc ttest C_FES_`i' == rC_Inc_`i' if Modality == 1 & Country == 3 & S_phone_ownership == 1, rowappend ///
		  save(${tex_tab_re}/CAR_F2F_Paired_ttest.doc) ///
		  fhr(\b) label dec(3) tzok
	}
	
	******************************* RM *****************************************

	** Myanmar
	asdoc ttest CARI_FES_Bad == rCARI_Inc_Bad if Modality == 2 & Country == 1 & Err_ExpNF == 0, replace ///
		  save(${tex_tab_re}/Myanmar_RM_Paired_ttest.doc) ///
		  fhr(\b) label dec(3) tzok
		  							   
	forval i = 1/4 {
	asdoc ttest C_FES_`i' == rC_Inc_`i' if Modality == 2 & Country == 1 & Err_ExpNF == 0, rowappend ///
		  save(${tex_tab_re}/Myanmar_RM_Paired_ttest.doc) ///
		  fhr(\b) label dec(3) tzok 
	}
	
	** Ecuador
	asdoc ttest CARI_FES_Bad == rCARI_Inc_Bad if Modality == 2 & Country == 2, replace ///
		  save(${tex_tab_re}/Ecuador_RM_Paired_ttest.doc) ///
		  fhr(\b) label dec(3) tzok
		  							   
	forval i = 1/4 {
	asdoc ttest C_FES_`i' == rC_Inc_`i' if Modality == 2 & Country == 2, rowappend ///
		  save(${tex_tab_re}/Ecuador_RM_Paired_ttest.doc) ///
		  fhr(\b) label dec(3) tzok
	}
	
	** CAR
	asdoc ttest CARI_FES_Bad == rCARI_Inc_Bad if Modality == 2 & Country == 3 & S_phone_ownership == 1, replace ///
		  save(${tex_tab_re}/CAR_RM_Paired_ttest.doc) ///
		  fhr(\b) label dec(3) tzok
		  							   
	forval i = 1/4 {
	asdoc ttest C_FES_`i' == rC_Inc_`i' if Modality == 2 & Country == 3 & S_phone_ownership == 1, rowappend ///
		  save(${tex_tab_re}/CAR_RM_Paired_ttest.doc) ///
		  fhr(\b) label dec(3) tzok
	}
	