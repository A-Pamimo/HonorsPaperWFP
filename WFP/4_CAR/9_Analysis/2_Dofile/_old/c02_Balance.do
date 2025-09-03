/* *************************************************************************** *
*					WFP RAM-N rCARI Validation Study - CAR 				   * 
*																 			   *
*  PURPOSE:  			Check Randomization Balance			 				   *
*  AUTHOR: 				Nicole Wu (nicole.wu@wfp.org)						   *
*  DATE:  				Sep 20, 2023										   *
*  LATEST UPDATE: 															   *
*		  																	   *
********************************************************************************
					
	** REQUIRES:	${dta}/CAR_Full_Household_Analysis.dta
					
	** CREATES:		
					
	** NOTES:		

********************************************************************************
*								PART 1: Set Log
*******************************************************************************/

	cap log close 
	
	// set log
	loc cdate: di %td_CCYY_NN_DD date(c(current_date), "DMY")
	loc cdate = subinstr(trim("`cdate'"), " " , "", .)
	log using "${logs}/e01_organize_`cdate'.smcl", replace
	di `cdate'	

	graph set window fontface "Times New Roman"
	
	* Load dataset
	use "${dta}/CAR_Full_Household_rCARI_Analysis.dta", replace
	compress 
	
********************************************************************************
*						PART 2: Define variables
*******************************************************************************/
	
	gl bal_all 	RESPAge RESPFemale RESPHHH HHSize HHInc_PCT HHIncNb 
	
/*	HHInc_None	 ///
				HHInc_WageSkill HHInc_WageUnskill HHInc_Trade HHInc_AgProduction ///
				HHInc_Change_None HHInc_Increase HHInc_Reduce25 HHInc_Reduce50	 /// 
				HHInc_Reduce50More
*/	
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

	gl bal_incfes	CARI_Inc_1 CARI_Inc_2 CARI_Inc_3 CARI_Inc_4 FES_Cat_1 FES_Cat_2 FES_Cat_3 FES_Cat_4

	
********************************************************************************
*							PART 4: Check Balance
*******************************************************************************/

	* Randomization Balance
	iebaltab ${bal_all}, grpvar(Modality) nonote nototal replace		///
             format(%12.2fc) grplabels(1 F2F @ 2 Remote)  		///
             rowvarlabels savetex("${tex_tab}/CAR_Demo_Modality_Balance.tex")
	
	iebaltab ${bal_incfes}, grpvar(Modality) nonote nototal replace		///
             format(%12.2fc) grplabels(1 F2F @ 2 Remote) onerow 		///
             rowvarlabels savetex("${tex_tab}/CAR_IncFes_Modality_Balance.tex")
			 
	iebaltab ${bal_f2f} if Modality == 1, grpvar(Form) nonote nototal replace	///
             format(%12.2fc) grplabels(1 F2F @ 2 Remote)		///
             rowvarlabels savetex("${tex_tab}/CAR_Demo_F2F_Length_Balance.tex")

	iebaltab ${bal_rm}  if Modality == 2, grpvar(Form) nonote nototal replace	///
             format(%12.2fc) grplabels(1 F2F @ 2 Remote)		///
             rowvarlabels savetex("${tex_tab}/CAR_Demo_RM_Length_Balance.tex")
