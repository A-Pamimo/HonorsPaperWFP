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
	
	gl bal_demo_m	RESPAge RESPFemale RESPHHH HHSize HHInc_PCT HHIncNb
	gl bal_demo_e	RESPAge RESPFemale RESPHHH HHSize HHInc_PCT HHIncNb
	
	gl bal_demo_c 	S_age S_HHHResp S_HHHFemale S_HHHMarried S_hh_head_educ 	 ///
					S_HHDisplaced S_hh_size S_mem_lessthan15 S_mem_greaterthan60 ///
					S_mem_disability S_area_house S_HHCrowding S_HHBadRoof 		 ///
					S_HHBadFloor
				
********************************************************************************
*						`PART 4: Check Balance on Modality
*******************************************************************************/
	
	gen Modality_Bin = Modality - 1
	
	** Maynmar	
	balancetable (mean if Modality_Bin == 0 & Country == 1)  ///
				 (mean if Modality_Bin == 1 & Country == 1)  ///
				 (diff 	  Modality_Bin 	   if Country == 1)  ///
		${bal_demo_m}	///
		using "${all_tex_tab}/Myanmar_Modality_Demo_Balance.tex", replace ///
		vce(r) pvalues varlab nonum format(%9.2f)  ///
		starlevels( * 0.05 ** 0.01 *** 0.001 )	   ///
		ctitles("F2F" "Remote" "Diff") ///
		groups("Myanmar", pattern(1 0 0))
	
	** Ecuador	
	balancetable (mean if Modality_Bin == 0 & Country == 2)  ///
				 (mean if Modality_Bin == 1 & Country == 2)  ///
				 (diff 	  Modality_Bin 	   if Country == 2)  ///	 
		${bal_demo_e}		 ///
		using "${all_tex_tab}/Ecuador_Modality_Demo_Balance.tex", replace ///
		vce(r) pvalues varlab nonum format(%9.2f)  ///
		starlevels( * 0.05 ** 0.01 *** 0.001 )	///
		ctitles("F2F" "Remote" "Diff") ///
		groups("Ecuador", pattern(1 0 0))
	
	** CAR	
	balancetable (mean if Modality_Bin == 0 & Country == 3 & S_phone_ownership == 1)  ///
				 (mean if Modality_Bin == 1 & Country == 3 & S_phone_ownership == 1)  ///
				 (diff 	  Modality_Bin 	   if Country == 3 & S_phone_ownership == 1)  ///	 
		${bal_demo_c}		 ///
		using "${all_tex_tab}/CAR_Modality_Own_Phone_Demo_Balance.tex", replace ///
		vce(r) pvalues varlab nonum format(%9.2f)  ///
		starlevels( * 0.05 ** 0.01 *** 0.001 )	///
		ctitles("F2F" "Remote" "Diff") ///
		groups("CAR", pattern(1 0 0))
		