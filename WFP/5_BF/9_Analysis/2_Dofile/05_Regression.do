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
	
	********************************************************************************
*						PART 3: Sensitivity and Specificity Test
*******************************************************************************/

	eststo clear
	estpost tabulate CARI_FES_Cat CARI_Inc_Cat
	esttab using "${out_tab}/BF_FS_Cat_Cross_Tabulation.tex", ///
    cell("b(fmt(0)) rowpct(fmt(2))") unstack noobs ///
	collabels("Count" "Percent") nonumbers replace mtitles(FES)
	
	tabplot CARI_FES_Cat CARI_Inc_Cat, showval
	
	eststo  clear
	estpost tabulate rCARI_Inc_Good CARI_FES_Good
	esttab using "${out_tab}/BF_FS_Cross_Tabulation.tex", 					///
		   cell("b(fmt(0)) rowpct(fmt(2))") unstack noobs modelwidth(15) 		///
		   collabels("Count" "Percent") nonumbers replace 
		   
********************************************************************************
*						PART 7: Logit Regression
*******************************************************************************/
	 *rename Modality_Bin Modality
	 rename Form_Bin FormLength
	gl reg_out  CARI_FES_Bad rCARI_Inc_Bad
	label variable RESPSex "Sex of respondent"
	label variable Modality_Bin "Survey modality (Remote=1)"
	gen RespSex_HHSex = RESPSex*S_HHHFemale	
	gl reg_demo  RESPSex S_age S_HHHResp S_HHHFemale S_HHHMarried S_hh_head_educ 	 ///
				 S_hh_size S_mem_lessthan15 S_mem_greaterthan60 ///
				 S_mem_disability S_HHCrowding S_HHBadRoof 		 ///
				 S_HHBadFloor
	
	gl model_1 Modality_Bin 
	gl model_2 Modality_Bin ${reg_demo}
	gl model_3 Modality_Bin RespSex_HHSex ${reg_demo}
	
	est clear
/*	
foreach outcome in $reg_out {
	forval n = 1/3 {
		logit `outcome' ${model_`n'}, vce(cluster ADMIN5Name)
		eststo: qui estpost margins, dydx(*) atmeans
		qui estadd ysumm, replace
	}
}*/

foreach outcome in $reg_out {
    forval n = 1/3 {
        * Step 1: Run logistic regression
        logit `outcome' ${model_`n'}, vce(cluster ADMIN5Name)
        
        * Step 2: Predict fitted values and residuals
        capture predict fitted_values_`outcome'_`n', xb
        capture predict dev_residuals_`outcome'_`n', deviance
        capture predict raw_residuals_`outcome'_`n', residuals

        * Check if residuals were successfully created
        if _rc != 0 {
            di as error "Residuals for `outcome'_`n' could not be created. Skipping diagnostics for this model."
            continue
        }

        * Step 3: Predict probabilities and classifications
        predict predicted_probs_`outcome'_`n', pr
        gen predicted_class_`outcome'_`n' = (predicted_probs_`outcome'_`n' >= 0.5)

        * Step 4: Scatter Plots for Residual Diagnostics
        quietly scatter dev_residuals_`outcome'_`n' fitted_values_`outcome'_`n', ///
            title("Deviance Residuals vs Fitted Values: `outcome'_`n'") ///
            xlabel(, angle(45)) ylabel(, angle(45)) ///
            saving(dev_scatter_`outcome'_`n'.gph, replace)

        quietly scatter raw_residuals_`outcome'_`n' fitted_values_`outcome'_`n', ///
            title("Raw Residuals vs Fitted Values: `outcome'_`n'") ///
            xlabel(, angle(45)) ylabel(, angle(45)) ///
            saving(raw_scatter_`outcome'_`n'.gph, replace)

        * Step 5: Marginal Effects
        eststo: qui estpost margins, dydx(*) atmeans

        * Step 6: Add outcome summary
        qui estadd ysumm, replace

        * Step 7: Save Outputs for Analysis
        save diagnostics_`outcome'_`n'.dta, replace
    }
}



	esttab using "${out_tab}/BF_FS_Logit.tex", replace ///
    cells(b(fmt(2) star) se(par fmt(2))) label ///
    stats(N, fmt(0) label("Obs.")) ///
	mlabels(none) collabels(none) nonotes ///
	mgroups("Food Insecure with FES" "Food Insecure with Income" , pattern(1 0 0 1 0 0) ///
	span prefix(\multicolumn{@span}{c}{) suffix(}) erepeat(\cmidrule(lr){@span}))

	                       