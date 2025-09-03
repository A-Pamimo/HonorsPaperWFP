/* *************************************************************************** *
*					WFP APP-FA rCARI Validation Study - BF 					   * 
*																 			   *
*  PURPOSE:  			Check Attrition Balance			 					   *
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
	use "${bf_output}/ALL_BF_Household_Analysis.dta", replace
	compress 
	
	** 1 Survey Completion	
	eststo  clear
	estpost tabulate S_Assign_Modality Completion
	esttab using "${out_tab}/BF_rCARI_Completion.tex", 					///
		   cell("b(fmt(0)) rowpct(fmt(2))") unstack noobs modelwidth(15) 		///
		   collabels("Count" "Percent") nonumbers replace 

********************************************************************************
*							PART 2: Check Attrition
*******************************************************************************/
	
	replace Attrition = 1 if mi(Attrition)	
	gen Assign_Modality_Bin = S_Assign_Modality - 1
	gen Assign_Length_Bin	= S_Assign_Length - 1
	
	gen Modality_Bin = Modality - 1
	gen Form_Bin 	 = Form - 1
	
	label var Modality_Bin  "Remote Modality"
	label var Form_Bin		"Short Form"
	
	tab Modality_Bin Form_Bin, matcell(count)
*	S_Assign_Length // wrong label
	
	gen 	Type = 1 if Modality_Bin == 0 & Form_Bin == 0 // f2f long
	replace Type = 2 if Modality_Bin == 0 & Form_Bin == 1 // f2f short
	replace Type = 3 if Modality_Bin == 1 & Form_Bin == 0 // remote long
	replace Type = 4 if Modality_Bin == 1 & Form_Bin == 1 // remote short

	label def type 1 "F2F Long" 2 "F2F Short" 3 "Remote Long" 4 "Remote Short"
	label val Type type
	
	gen 	Comp_F2F_RM_Long = 1 if Modality_Bin == 1 & Form_Bin == 0
	replace Comp_F2F_RM_Long = 0 if Modality_Bin == 0
	
	gen 	Comp_F2F_RM_Short = 1 if Modality_Bin == 1 & Form_Bin == 1
	replace Comp_F2F_RM_Short = 0 if Modality_Bin == 0
	
	balancetable (mean if Attrition == 0 & Assign_Modality_Bin == 0)  ///
				 (mean if Attrition == 1 & Assign_Modality_Bin == 0)  ///
				 (diff 	  Attrition 	if Assign_Modality_Bin == 0)  ///
		${bal_demo}		 					   ///
		using "${out_tab}/BF_Listing_Demo_Attrition_F2F.tex", replace 	 ///
		vce(r) pvalues varlab nonum format(%9.2f)  			 ///
		starlevels( * 0.05 ** 0.01 *** 0.001 )				 ///
		ctitles("Completed" "Attrition" "Diff") ///
		groups("F2F", pattern(1 0 0))
	
	balancetable (mean if Attrition == 0 & Assign_Modality_Bin == 1)  ///
				 (mean if Attrition == 1 & Assign_Modality_Bin == 1)  ///
				 (diff 	  Attrition 	if Assign_Modality_Bin == 1)  ///
		${bal_demo}		 					   ///
		using "${out_tab}/BF_Listing_Demo_Attrition_Remote.tex", replace 	 ///
		vce(r) pvalues varlab nonum format(%9.2f)  			 ///
		starlevels( * 0.05 ** 0.01 *** 0.001 )				 ///
		ctitles("Completed" "Attrition" "Diff") ///
		groups("Remote", pattern(1 0 0))
			 

