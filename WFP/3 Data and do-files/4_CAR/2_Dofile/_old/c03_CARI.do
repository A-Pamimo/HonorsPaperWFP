/* *************************************************************************** *
*					WFP RAM-N rCARI Validation Study - CAR 				   * 
*																 			   *
*  PURPOSE:  			Check CARI related Outcome Balance					   *
*  AUTHOR: 				Nicole Wu (nicole.wu@wfp.org)						   *
*  DATE:  				Sep 20, 2023										   *
*  LATEST UPDATE: 															   *
*		  																	   *
********************************************************************************
					
	** REQUIRES:	${dta}/CAR_Full_Household_rCARI_Analysis.dta
					
	** CREATES:		
					
	** NOTES:		

********************************************************************************
*								PART 1: Set Log
*******************************************************************************/

	cap log close 
	
	// set log
	loc cdate: di %td_CCYY_NN_DD date(c(current_date), "DMY")
	loc cdate = subinstr(trim("`cdate'"), " " , "", .)
	log using "${logs}/e01_cari_`cdate'.smcl", replace
	di `cdate'	

	graph set window fontface "Times New Roman"
	
	* Load dataset
	use "${dta}/CAR_Full_Household_rCARI_Analysis.dta", replace
	compress 

********************************************************************************
*						PART 2: Define variables
*******************************************************************************/
	
	gl out_oth  FCS rCSI LCS_None LCS_Stress LCS_Crisis LCS_Emergency 		///
				HHExpTotal PCExpTotal FES 
				
	gl out_fes HHExpFoodTotal_1M HHExpNFTotal_1M HHExpTotal PCExpTotal FES
	
	gl var_fcs	FCSStap FCSPulse FCSDairy FCSPr FCSVeg FCSFruit FCSFat FCSSugar	FCS			 	
	gl var_rcsi rCSILessQlty rCSIBorrow rCSIMealSize rCSIMealAdult rCSIMealNb rCSI
	
	gl out_cat	CARI_FES_Cat1 CARI_FES_Cat2 CARI_FES_Cat3 CARI_FES_Cat4 	///
				CARI_FES_Bad rCARI_Inc_Cat1 rCARI_Inc_Cat2 rCARI_Inc_Cat3 	///
				rCARI_Inc_Cat4 rCARI_Inc_Bad
				
	gl out_lcs LCS_None LCS_Stress LCS_Crisis LCS_Emergency
	
	gl out_cari CARI_rCARI_1 CARI_rCARI_2 CARI_rCARI_3 CARI_rCARI_4 CARI_rCARI

********************************************************************************
*							PART 4: Check Balance
*******************************************************************************/
	
	* Outcome Balance by Survey Modality
	iebaltab ${out_oth}, grpvar(Modality) nonote onerow							///
			 nototal replace format(%12.2fc) grplabels(1 F2F @ 2 Remote)		///
             rowvarlabels savetex("${tex_tab}/CAR_Outcome_Modality_Balance.tex")

	iebaltab ${out_cat}, grpvar(Modality) nonote onerow							///
			 nototal replace format(%12.2fc) grplabels(1 F2F @ 2 Remote)		///
             rowvarlabels savetex("${tex_tab}/CAR_CARI_Modality_Balance.tex")
			 
	iebaltab ${out_fes} if Modality == 1, grpvar(Form)   						///
			 nonote nototal replace	onerow										///
             format(%12.2fc) grplabels(1 Long @ 2 Short) 						///
             rowvarlabels savetex("${tex_tab}/CAR_FES_F2F_Length_Balance.tex")
			 
	iebaltab ${out_fes} if Modality == 2, grpvar(Form)  						///
			 nonote nototal replace	onerow										///
             format(%12.2fc) grplabels(1 Long @ 2 Short) 	 	 				///
             rowvarlabels savetex("${tex_tab}/CAR_FES_RM_Length_Balance.tex")
			 
	iebaltab ${out_lcs} if Modality == 1, grpvar(Form)   						///
			 nonote nototal replace	onerow										///
             format(%12.2fc) grplabels(1 Long(EN) @ 2 Short(FS)) 				///
             rowvarlabels savetex("${tex_tab}/CAR_LCS_F2F_Length_Balance.tex")
			 
	iebaltab ${out_cari}, grpvar(Modality) nonote onerow						///
			 nototal replace format(%12.2fc) grplabels(1 F2F @ 2 Remote)		///
             rowvarlabels savetex("${tex_tab}/CAR_CARI_Modality_Balance_Key.tex")
			  
	ren CARI_FES_Cat* 	C_FES_*
	ren rCARI_Inc_Cat*  rC_Inc_*
	
	asdoc ttest C_FES_1 == rC_Inc_1 if Modality == 1, unpaired replace save(${tabs}/CAR_F2F_FESINC_Unpaired_ttest.doc) ///
									   title(CARI vs. F2F rCARI) fhc(\b) fhr(\b) font(Open Sans) label dec(3) tzok
									   
	forval i = 2/4 {
	asdoc ttest C_FES_`i' == rC_Inc_`i' if Modality == 1, unpaired rowappend save(${tabs}/CAR_F2F_FESINC_Unpaired_ttest.doc) ///
				fhr(\b) font(Open Sans) label dec(3) tzok
	}
	
	asdoc ttest CARI_FES_Bad == rCARI_Inc_Bad if Modality == 1, unpaired rowappend save(${tabs}/CAR_F2F_FESINC_Unpaired_ttest.doc) ///
				fhr(\b) font(Open Sans) label dec(3) tzok
	
	// onerow

	** disaggregation by groups 
	// LCS, rCSI, FES by food secure vs food insecure
	// gender
	
	iebaltab ${out_oth} if Modality == 1, grpvar(HH_Vul_FES)   						///
			 nonote nototal replace	onerow										///
             format(%12.2fc) grplabels(0 Food Secure @ 1 Food Insecure) 				///
             rowvarlabels savetex("${tex_tab}/CAR_F2F_Outcoem_Balance_FS_Disaggregation.tex")
			 
	iebaltab ${out_oth} if Modality == 2, grpvar(HH_Vul_FES)   						///
			 nonote nototal replace	onerow										///
             format(%12.2fc) grplabels(0 Food Secure @ 1 Food Insecure) 				///
             rowvarlabels savetex("${tex_tab}/CAR_RM_Outcoem_Balance_FS_Disaggregation.tex")
	
	
