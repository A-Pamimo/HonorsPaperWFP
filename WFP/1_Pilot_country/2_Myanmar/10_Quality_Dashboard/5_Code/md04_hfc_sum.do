/* *************************************************************************** *
*					WFP RAM-N rCARI Validation Study - Myanmar 				   * 
*																 			   *
*  PURPOSE:  			Create HFC and Summary Stats 						   *
*  AUTHOR: 				Nicole Wu (nicole.wu@wfp.org)						   *
*  DATE:  				Jun  8, 2023										   *
*  LATEST UPDATE: 															   *
*		  																	   *
********************************************************************************
					
	** REQUIRES:	${d_dta}/Myanmar_Full_Household_Analysis_`cdate'.dta
					
	** CREATES:		
					
	** NOTES:		

********************************************************************************
*								PART 1: Set Log
*******************************************************************************/
	
	graph set window fontface "Times New Roman"
	
	cap log close 
	
	// set log
	loc cdate: di %td_CCYY_NN_DD date(c(current_date), "DMY")
	loc cdate = subinstr(trim("`cdate'"), " " , "", .)
	log using "${d_log}/md04_hfc_sum_`cdate'.smcl", replace
	di `cdate'	

	use "${d_dta}/Myanmar_Full_Household_Analysis.dta", replace
	compress 
	
	tab S_Assign_Modality 	Modality
	tab S_Assign_Length 	Form
	
*	replace S_Assign_Modality = Modality if mi(S_Assign_Modality)
*	replace S_Assign_Length   = Form 	 if mi(S_Assign_Length)
	
********************************************************************************
*						PART 3: Check and export variables
*******************************************************************************/
	
	** 1 Survey Completion	
	eststo  clear
	estpost tabulate S_Assign_Modality Completion
	esttab using "${d_tex_tab}/Myanmar_rCARI_Completion.tex", 					///
		   cell("b(fmt(0)) rowpct(fmt(2))") unstack noobs modelwidth(15) 		///
		   collabels("Count" "Percent") nonumbers replace
	
	dtable i.Modality i.Form i.Assignment, nosample 			  ///
		   by(S_Region) title(Myanmar rCARI Validation Study Final Sample)  ///
		   export(${d_tex_tab}/Myanmar_rCARI_Completion_Final.docx, replace)     

	tabout S_Assign_Modality S_Assign_Length S_Region S_Township S_Camp Completion  ///
	using "${d_tex_tab}/Myanmar_rCARI_Completion_by_Admin.docx", ///
	replace c(freq row) clab("Count" "Percent") style(docx) f(0c 1p) font(bold) 	///
	ptotal(single)
	
	tab Assignment Completion
	
	** Survey Progress by Date
	tostring today, g(Date_Str) format(%tdd_m_CY) force
	replace Date_Str = "" if Date_Str == "."
	encode  Date_Str, gen(Data_Cat)
	
	replace Data_Cat = Data_Cat + 3
	recode  Data_Cat (18=1) (19=2) (20=3), gen(Data_Cat_C)
	label   def date_l  1  "7 Jun 2023" ///
						2  "8 Jun 2023" ///
						3  "9 Jun 2023" ///
						4  "10 Jun 2023" ///
						5  "11 Jun 2023" ///
						6  "12 Jun 2023" ///
						7  "13 Jun 2023" ///
						8  "14 Jun 2023" ///
						9  "15 Jun 2023" ///
						10 "16 Jun 2023" ///
						11 "17 Jun 2023" ///
						12 "18 Jun 2023" ///
						13 "19 Jun 2023" ///
						14 "20 Jun 2023" ///
						15 "21 Jun 2023" ///
						16 "22 Jun 2023" ///
						17 "24 Jun 2023"
	label val Data_Cat_C date_l
	drop  Data_Cat
	
	catplot Modality, asyvars stack recast(bar) 			///
			over(Data_Cat_C, label(labsize(2.5) angle(45))) ///
			graphregion(color(white)) bgcolor(white)		///
			ylabel(0(30)150, nogrid labsize(2))				///
			legend(ring(4) pos(6) rows(1) size(3)) 			///
			ytitle("") blabel(bar, pos(center) size(2)  	///
			gap(1)) b1title("") 		
	graph export "${d_tex_fig}/Myanmar_rCARI_Progress_Day.png", replace 
	
	** 2 Survey Duration: Doesn't Work and can be ignored for now	
/*	tostring today, g(Date_Str) format(%tdd_m_CY) force
	replace Date_Str = "" if Date_Str == "."
	
	gen NewDate = date(Date_Str, "DMY")
	format NewDate %tdCCYYNNDD

	graph box Duration_Min if Modality == 1, by(Date_Str) over(EnuName, label(labsize(2) angle(45))) ///
    graphregion(color(white)) bgcolor(white)                   	 ///
    outergap(70) bargap(100) ylabel(0(300)1500, nogrid labsize(3))	///
    ytitle("") legend(ring(4) pos(6) rows(5) size(3)) 
	graph export "${d_tex_fig}/Myanmar_rCARI_Duration_F2F_Date.png", replace
	 
	graph box Duration_Min if Modality == 2, by(Date_Str) over(EnuName, label(labsize(2) angle(45))) ///
    graphregion(color(white)) bgcolor(white)                   	 ///
    outergap(70) bargap(100) ylabel(0(300)2100, nogrid labsize(3))	///
    ytitle("") legend(ring(4) pos(6) rows(5) size(3)) 
    graph export "${d_tex_fig}/Myanmar_rCARI_Duration_RM_Date.png", replace
*/    
	** 3 Household Size by Enumerator
	graph box HHSize, by(Modality) over(EnuName, label(labsize(2) angle(45))) ///
    graphregion(color(white)) bgcolor(white)                   	 ///
    outergap(70) bargap(100) ylabel(0(3)15, nogrid labsize(3))	///
    ytitle("") legend(ring(4) pos(6) rows(5) size(3)) 
    graph export "${d_tex_fig}/Myanmar_rCARI_HHSize_Modality.png", replace
	
	** 4 Other specify
	keep if Completion == 1
	
/*	codebook ${other_specify}
	export excel  using "${note}/Myanmar_other_specify_`cdate'.xlsx", 	///
		   firstrow(variables) replace	   

	keep EnuName HHID HHHOccupation HHHOccupation_S HHStatusOth 		   		///
		   HHHealthAcMildWhy_oth HHHealthAcSevereWhy_oth HHHealthChronWhy_oth 	   		///
		   HHHealthEmergWhy_oth LhCSIEnAccess_stress_oth LhCSIEnAccess_crisis_oth  		///
		   LhCSIEnAccess_em_oth HHIncFirst_oth HHIncFirst_oth_S HHDwellType_oth    		///
		   HHTenureType_oth HHWallType_oth HHRoofType_oth HHFloorType_oth 		   		///
		   HHToiletType_oth HHEnerCookStove_oth HHEnerCookSRC_oth HHEnerLightSRC_oth 	///
		   HHWaterSRC_oth Sys_uuid
*/	


********************************************************************************
*							PART 4: Check Balance
*******************************************************************************/

	gl bal_all 	RESPAge RESPFemale RESPHHH HHSize HHInc_PCT HHIncNb HHInc_None	 ///
				HHInc_WageSkill HHInc_WageUnskill HHInc_Trade HHInc_AgProduction ///
				HHInc_Change_None HHInc_Increase HHInc_Reduce25 HHInc_Reduce50	 /// 
				HHInc_Reduce50More
	
	gl bal_f2f 	RESPAge RESPFemale RESPHHH RESPSingle RESPMarried 				 ///
				HHDisplaced HHDisable MDDIHHDisabledNb R_HHH_Sex R_HHH_Age		 ///
				R_HHH_Literate HHSize R_Num_Male R_Num_Female R_Num_Child		 ///
				R_Num_Senior R_Num_Adult R_Num_Dependent 	 ///
				FemaleMale_Ratio Dependency_Ratio HHInc_PCT HHIncNb HHInc_None   ///
				HHInc_WageSkill HHInc_WageUnskill HHInc_Trade HHInc_AgProduction ///
				HHInc_Change_None HHInc_Increase HHInc_Reduce25 HHInc_Reduce50	 /// 
				HHInc_Reduce50More
	
	gl bal_rm	RESPAge RESPFemale RESPHHH HHSize HHInc_PCT HHIncNb HHInc_None	 ///
				HHInc_WageSkill HHInc_WageUnskill HHInc_Trade HHInc_AgProduction ///
				HHInc_Change_None HHInc_Increase HHInc_Reduce25 HHInc_Reduce50	 /// 
				HHInc_Reduce50More
	
	gl outcome  FCS rCSI LCS_None LCS_Stress LCS_Crisis LCS_Emergency			///
				HHExpFoodTotal_1M HHExpNFTotal_1M HHExpTotal PCExpTotal FES 	///
				HH_Vul_FES HH_Vul_Income
	
	* Randomization Balance
	iebaltab ${bal_all}, grpvar(Modality) nonote nototal replace		///
             format(%12.2fc) grplabels(1 F2F @ 2 Remote) onerow 		///
             rowvarlabels savetex("${d_tex_tab}/Myanmar_Demo_Modality_Balance.tex")
	
	iebaltab ${bal_f2f} if Modality == 1, grpvar(Form) nonote nototal replace	///
             format(%12.2fc) grplabels(1 F2F @ 2 Remote) 		///
             rowvarlabels savetex("${d_tex_tab}/Myanmar_Demo_F2F_Length_Balance.tex")
			 
	iebaltab ${bal_rm}  if Modality == 2, grpvar(Form) nonote nototal replace	///
             format(%12.2fc) grplabels(1 F2F @ 2 Remote) onerow 				///
             rowvarlabels savetex("${d_tex_tab}/Myanmar_Demo_RM_Length_Balance.tex")
			 
	* Outcome Balance by Survey Modality
	iebaltab ${outcome}, grpvar(Modality) nonote nototal replace				///
             format(%12.2fc) grplabels(1 F2F @ 2 Remote) onerow					///
             rowvarlabels savetex("${d_tex_tab}/Myanmar_Outcome_Modality_Balance.tex")

	iebaltab ${outcome} if Modality == 1, grpvar(Form) nonote total replace		///
             format(%12.2fc) grplabels(1 Long @ 2 Short) onerow					///
             rowvarlabels savetex("${d_tex_tab}/Myanmar_Outcome_F2F_Length_Balance.tex")
			 
	iebaltab ${outcome} if Modality == 2, grpvar(Form) nonote total replace		///
             format(%12.2fc) grplabels(1 Long @ 2 Short) onerow					///
             rowvarlabels savetex("${d_tex_tab}/Myanmar_Outcome_RM_Length_Balance.tex")

	// onerow
	
	gl var_ad	HHID Sys_uuid ADMIN1Name ADMIN3Name ADMIN5Name EnuName EnuName_Display 	///
				Sys_HHCoord_latitude Sys_HHCoord_longitude Sys_HHCoord_altitude Consent ///
				Completion Duration_Min Modality Form S_Assign_Modality S_Assign_Length
	gl demo	RESPAge RESPSex HHSize RESPHHH RESPFemale HHDisplaced HHHSingle 			///
				HHHMarried HHDisable R_*	
	gl var_dem  RESPAge HHSize
	gl var_fcs	FCSStap FCSPulse FCSDairy FCSPr FCSVeg FCSFruit FCSFat FCSSugar	FCS			 	
	gl var_rcsi rCSILessQlty rCSIBorrow rCSIMealSize rCSIMealAdult rCSIMealNb rCSI 
	gl var_lcs	Lcs_Stress_Coping Lcs_Crisis_Coping Lcs_Emergency_Coping
	gl var_fes	HHExpFoodTotal_1M HHExpNFTotal_1M HHExpTotal PCExpTotal FES HH_Vul_FES
	gl var_inc	HH_Vul_Income
	
	eststo  clear
    estpost tabstat ${var_fcs} ${var_rcsi} ${var_lcs} ${var_fes} ${var_inc}, 		///
			by(Modality) statistics(mean sd range cv) columns(statistics) nototal
    esttab  using "${d_tex_tab}/Summary_Stats_Outlier.tex", replace style(tex) 		///
            cell("mean(fmt(2)) sd(fmt(2)) range(fmt(0)) cv(fmt(2))")  ///
            nolabel nonumbers noobs nomtitles unstack 				  ///
			collabels("Mean" "SD" "Range" "Coef of Variation") 	  	  ///
            refcat(RESPAge 			 "	\textbf{\textit{Respondent Characteristics:}}" 	  ///
                   FCSStap 			 "	\textbf{\textit{Food Consumption Score:}}"  	  ///
                   rCSILessQlty 	 "	\textbf{\textit{Reduced Coping Strategy Index:}}" ///
				   Lcs_Stress_Coping "	\textbf{\textit{Livelihood Coping Strategies:}}"  ///
				   HHExpFoodTotal_1M "	\textbf{\textit{Expenditure:}}" 				  ///
				   HH_Vul_Income 	 "	\textbf{\textit{Income:}}", nolabel)
	
* -------------	
* End of dofile
