/* *************************************************************************** *
*						WFP RAM-N rCARI Validation Study - Iraq 			   * 
*																 			   *
*  PURPOSE:  			Attrition Analysis							  	 	   *
*  AUTHOR: 				Nicole Wu (nicole.wu@wfp.org)						   *
*  DATE:  				Apr 24, 2023										   *
*  LATEST UPDATE: 		Apr 24, 2023										   *
*		  																	   *
********************************************************************************

					
	** REQUIRES:	${dta}/Iraq_Full_Household_Analysis.dta
					
	** CREATES:		
								
	** NOTES:		
					
********************************************************************************
*						
*******************************************************************************/
	
	cap log close 
	
	// set log
	loc cdate: di %td_CCYY_NN_DD date(c(current_date), "DMY")
	loc cdate = subinstr(trim("`cdate'"), " " , "", .)
	log using "${logs}/i08_attrition_`cdate'.smcl", replace
	di `cdate'
	
	* load dataset
	use "${dta}/Iraq_Full_Household_Analysis.dta", replace
	
	* attrition balance check variables
	gl 	var_attri RESPAge HHSize FCSStap FCSPulse FCSDairy FCSPr FCSVeg ///
				  FCSFruit FCSFat FCSSugar FCS rCSILessQlty rCSIBorrow ///
				  rCSIMealSize rCSIMealAdult rCSIMealNb rCSI

foreach var of global var_attri {
	gen 	bal_`var' = `var'
	replace bal_`var' = r_`var' if mi(`var')
}

	iebaltab 	bal_*, 			///
				grpvar(Source)  ///
				rowvarlabels savexlsx("${tabs_bal}/Iraq_rCARI_Attrition_Balance.xlsx") replace
