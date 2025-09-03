/* *************************************************************************** *
*					WFP RAM-N rCARI Validation Study - Myanmar 				   * 
*																 			   *
*  PURPOSE:  			Check Randomization Balance			 				   *
*  AUTHOR: 				Nicole Wu (nicole.wu@wfp.org)						   *
*  DATE:  				Jun 30, 2023										   *
*  LATEST UPDATE: 															   *
*		  																	   *
********************************************************************************
					
	** REQUIRES:	${all_dta}/ALL_Full_Household_Analysis.dta
					
	** CREATES:		
					
	** NOTES:		

********************************************************************************
*								PART 1: Set Log
*******************************************************************************/

	cap log close 
	
	// set log
	loc cdate: di %td_CCYY_NN_DD date(c(current_date), "DMY")
	loc cdate = subinstr(trim("`cdate'"), " " , "", .)
	log using "${all_logs}/03_attrition_`cdate'.smcl", replace
	di `cdate'	

	graph set window fontface "Times New Roman"
	
	* Load dataset
	use "${all_dta}/ALL_Full_Household_Analysis.dta", replace
	compress 
	
********************************************************************************
*							PART 2: Check Attrition
*******************************************************************************/

	** Myanmar
	dtable i.S_Assign_Modality i.S_Assign_Length i.S_Region i.S_Township 	 ///
		   i.S_Camp if Country == 1, by(Completion, tests) 					 ///
		   title(Myanmar rCARI Validation Attrition Analysis)  				 ///
		   export(${all_tabs}/Attrition_Myanmar.docx, replace) 
	
	** Ecuador
	dtable i.S_Assign_Modality i.S_Assign_Length i.S_Phase i.S_Geo_Admin1_e 	///
		   i.S_Geo_Admin3_e i.S_Geo_Admin5_e if Country == 2, by(Completion, tests)	 ///
		   title(Ecuador rCARI Validation Attrition Analysis)  				 ///
		   export(${all_tabs}/Attrition_Ecuador.docx, replace) 

	** CAR
	dtable i.S_Assign_Modality i.S_Assign_Length i.S_Geo_Admin1_c i.S_Geo_Admin2_c	///
		   i.S_Geo_Admin3_c i.S_Geo_Admin5_c S_hh_status S_hh_head_sex 				///
		   S_hh_head_marital S_hh_head_educ S_hh_size S_mem_lessthan15 			///
		   S_mem_greaterthan60 S_mem_disability S_house_type S_area_house 		///
		   S_phone_ownership if Country == 3, by(Completion, tests)	 			///
		   title(CAR rCARI Validation Attrition Analysis)  				 		///
		   export(${all_tabs}/Attrition_CAR_Overall.docx, replace) 
		   
	dtable i.S_Assign_Length i.S_Geo_Admin1_c i.S_Geo_Admin2_c	///
		   i.S_Geo_Admin3_c i.S_Geo_Admin5_c S_hh_status S_hh_head_sex 				///
		   S_hh_head_marital S_hh_head_educ S_hh_size S_mem_lessthan15 			///
		   S_mem_greaterthan60 S_mem_disability S_house_type S_area_house 		///
		   S_phone_ownership if Country == 3 & S_Assign_Modality == 2, by(Completion, tests)	 			///
		   title(CAR rCARI Validation Remote Survey Attrition Analysis)  				 		///
		   export(${all_tabs}/Attrition_CAR_Remote.docx, replace) 
	
	** testing listing balance
	gl list_var S_age S_HHHResp S_HHHFemale S_HHHMarried S_hh_head_educ 		///
				S_HHDisplaced S_hh_size S_mem_lessthan15 S_mem_greaterthan60 	///
				S_mem_disability S_area_house S_HHCrowding S_HHBadRoof 			///
				S_HHBadFloor
	
	iebaltab ${list_var} if Country == 3, 											///
			 grpvar(Completion) control(1) nonote nototal replace format(%12.2fc) 	///
			 grplabels(0 Attrition @ 1 Completed) rowvarlabels onerow				///
             savexlsx("${all_tabs}/Attrition_CAR_Listing_Demo.xlsx")		
			 
	iebaltab ${list_var} if Country == 3, 				///
			 grpvar(Modality) control(1) nonote nototal replace format(%12.2fc) ///
			 grplabels(1 F2F @ 2 Remote) rowvarlabels onerow					///
             savexlsx("${all_tabs}/CAR_Listing_Demo_Modality.xlsx")	
			 
	iebaltab ${list_var} if Country == 3 & S_phone_ownership == 1, 				///
			 grpvar(Modality) control(1) nonote nototal replace format(%12.2fc) ///
			 grplabels(1 F2F @ 2 Remote) rowvarlabels onerow					///
             savexlsx("${all_tabs}/CAR_Listing_Demo_Modality_OwnPhone.xlsx")
			 
	iebaltab ${list_var} if Country == 3 & Modality == 2, control(1)			///
			 grpvar(S_Assign_Phone) nonote nototal replace format(%12.2fc) 		///
			 grplabels(0 Own Phone @ 1 Assigned Phone) rowvarlabels onerow		///
             savexlsx("${all_tabs}/CAR_Listing_Demo_Remote_AssignPhone.xlsx")		 
