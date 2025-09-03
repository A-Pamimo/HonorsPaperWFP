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

	graph set window fontface "Open Sans"
	
	* Load dataset
	use "${all_dta}/Complete_Full_Household_Analysis.dta", replace
	compress 
	
********************************************************************************
*						PART 2: Define variables
*******************************************************************************/
	
	gen Modality_Bin = Modality - 1
	gen Form_Bin 	 = Form - 1
	
	gen 	Group = 1 if Modality_Bin == 0 & Form_Bin == 0
	replace Group = 2 if Modality_Bin == 0 & Form_Bin == 1
	replace Group = 3 if Modality_Bin == 1 & Form_Bin == 0
	replace Group = 4 if Modality_Bin == 1 & Form_Bin == 1
	
	** Grouped indicator
	gen 	Comp_F2F_RM_Long = 1 if Modality_Bin == 1 & Form_Bin == 0
	replace Comp_F2F_RM_Long = 0 if Modality_Bin == 0
	
	gen 	Comp_F2F_RM_Short = 1 if Modality_Bin == 1 & Form_Bin == 1
	replace Comp_F2F_RM_Short = 0 if Modality_Bin == 0
	
	* each vs. standard expenditure module (f2f long)
	
	drop PCExpTotal
	local exp_var Exp_Food_Purch_MN_7D Exp_Food_GiftAid_MN_7D ///
				  Exp_Food_Own_MN_7D ExpNFTotal_Purch_MN_1M   ///
				  ExpNFTotal_GiftAid_MN_1M ExpFoodTotal_7D 	  ///
				  ExpNFTotal_1M ExpTotal

foreach var of local exp_var  {
	gen PC`var' = HH`var'/HHSize
}
	
	gl var_fes_long  FES FES_Cat_1 FES_Cat_2 FES_Cat_3 FES_Cat_4 		 ///
					 PCExp_Food_Purch_MN_7D PCExp_Food_GiftAid_MN_7D 	 ///
					 PCExp_Food_Own_MN_7D PCExpFoodTotal_7D				 ///
					 PCExpNFTotal_Purch_MN_1M PCExpNFTotal_GiftAid_MN_1M ///
					 PCExpNFTotal_1M PCExpTotal
	
********************************************************************************
*						`PART 4: Check Balance on Modality
*******************************************************************************/
	
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
		${var_fes_long}		 ///
		using "${tex_tab_e}/FES_Modality_All_Country.tex", replace ///
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
		${var_fes_long}		 ///
		using "${tex_tab_e}/FES_F2F_Form_Length_All_Country.tex", replace  ///
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
		${var_fes_long}		 ///
		using "${tex_tab_e}/FES_F2F_Long_All_Country.tex", replace  ///
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
		${var_fes_long}		 ///
		using "${tex_tab_e}/FES_F2F_Short_ECU_CAR.tex", replace  ///
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
		${var_fes_long}		 ///
		using "${tex_tab_e}/FES_RM_Form_Length_ECU_CAR.tex", replace  ///
		vce(r) pvalues varlab nonum format(%9.2f)  	///
		starlevels( * 0.05 ** 0.01 *** 0.001 )		///
		ctitles("Long" "Short" "Diff" "Long" "Short" "Diff") ///
		groups("Ecuador RM" "CAR RM", pattern(1 0 0 1 0 0))	
		
********************************************************************************
*						PART 4: Check Balance on Long/Short	
*******************************************************************************/
	
	iebaltab ${var_fes_long} if Country == 3, 				///
			 grpvar() control(1) nonote nototal replace format(%12.2fc) ///
			 rowvarlabels onerow					///
             savexlsx("${tex_tab_e}/CAR_Listing_Demo_Modality.xlsx")	
