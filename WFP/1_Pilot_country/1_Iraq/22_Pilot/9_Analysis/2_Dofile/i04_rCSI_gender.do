********************************************************************************
*					PART 1: additional rCSI gendered variables
*******************************************************************************/

	tempfile master 
	
	use "${temp}/Iraq_rCSI_F2F_Analysis.dta", clear
	
	keep HHID Group FCSCat28 Status FCG rCSIGenderMealSize_F 	 ///
		 rCSIGenderMealSize_M rCSIGenderMealAdult_F rCSIGenderMealAdult_M 	 ///
		 rCSIGenderMealNb_F rCSIGenderMealNb_M
	
	save `master'

********************************************************************************
*					PART 2: rCSIGenderMealSize
*******************************************************************************/

	**	Reshape 
	
	keep HHID Group Status FCG rCSIGenderMealSize_F rCSIGenderMealSize_M	 
	keep if !mi(rCSIGenderMealSize_F) & !mi(rCSIGenderMealSize_M)
	
	reshape long rCSIGenderMealSize_, ///
			i(HHID Group Status FCG) j(Gender) string
	ren *_ *
	
	gen Female = (Gender == "F")
	
	lab def fem_l 1 "Female" 0 "Male"
	lab def gender_option 1 "Mainly adult male (18+)"	///
						  2 "Mainly adult female (18+)" ///
						  3 "Mainly kids and youth male (<18)" ///
						  4 "Mainly kids and youth female (<18)" ///
						  5 "All adults equally"		///
						  6 "All family members equally"					  
	lab val Female fem_l
	lab val rCSIGenderMealSize gender_option
	
	tab  Status Female if !mi(rCSIGenderMealSize)
	catplot rCSIGenderMealSize Female Status, 					  			 ///
			percent(Female Status) blabe(bar, format(%4.1f) size(2)) 		 ///
			title("Iraq F2F: rCSI Cross-Gender Reporting", span size(5)) 	 ///
			subtitle("rCSIGenderMealSize by Gender and Status", ///
					 span size(3)) 	 										 ///
			note("Note: Matched pairs N = 238; IDP N = 108; Refugee N = 130", size(2.5)) ///
			ylabel(0(10)70, nogrid labsize(2.5)) ///
			legend(ring(4) pos(6) rows(4) span size(2.5))
	graph export "${figs_gender}/Iraq_rCSI_F2F_GenderMealSize_Status.png", replace
	
	tab  FCG Female if !mi(rCSIGenderMealSize)
	catplot rCSIGenderMealSize Female FCG, 					  			 ///
			percent(Female FCG) blabe(bar, format(%4.1f) size(2)) 		 ///
			title("Iraq F2F: rCSI Cross-Gender Reporting", span size(5)) 	 ///
			subtitle("rCSIGenderMealSize by Gender and FCS Group", ///
					 span size(3)) 	 										 ///
			note("Note: Matched pairs of female and male each N = 238: FCS Poor and borderline N = 32; FCS Acceptable N = 206", span size(2.5)) ///
			ylabel(0(10)60, nogrid labsize(2.5)) ///
			legend(ring(4) pos(6) rows(4) span size(2.5))
	graph export "${figs_gender}/Iraq_rCSI_F2F_GenderMealSize_FCG.png", replace
	
********************************************************************************
*					PART 2: rCSIGenderMealAdult
*******************************************************************************/

	**	Reshape 
	use `master', clear
	
	keep HHID Group Status FCG rCSIGenderMealAdult_F rCSIGenderMealAdult_M	 
	keep if !mi(rCSIGenderMealAdult_F) & !mi(rCSIGenderMealAdult_M)
	
	reshape long rCSIGenderMealAdult_, ///
			i(HHID Group Status FCG) j(Gender) string
	ren *_ *
	
	gen Female = (Gender == "F")
	
	lab def fem_l 1 "Female" 0 "Male"
	lab def adult_option  1 "Mainly adult male (18+)"	///
						  2 "Mainly adult female (18+)" ///
						  3 "All adults equally"		
	lab val Female fem_l
	lab val rCSIGenderMealAdult adult_option
	
	tab  Status Female if !mi(rCSIGenderMealAdult)
	catplot rCSIGenderMealAdult Female Status, 					  			 ///
			percent(Female Status) blabe(bar, format(%4.1f) size(2)) 		 ///
			title("Iraq F2F: rCSI Cross-Gender Reporting", span size(5)) 	 ///
			subtitle("rCSIGenderMealAdult by Gender and Status", ///
					 span size(3)) 	 										 ///
			note("Note: Matched pairs N = 238; IDP N = 106; Refugee N = 132", size(2.5)) ///
			ylabel(0(10)90, nogrid labsize(2.5)) ///
			legend(ring(4) pos(6) rows(4) span size(2.5))
	graph export "${figs_gender}/Iraq_rCSI_F2F_GenderMealAdult_Status.png", replace
	
	tab  FCG Female if !mi(rCSIGenderMealAdult)
	catplot rCSIGenderMealAdult Female FCG, 					  			 ///
			percent(Female FCG) blabe(bar, format(%4.1f) size(2)) 		 ///
			title("Iraq F2F: rCSI Cross-Gender Reporting", span size(5)) 	 ///
			subtitle("rCSIGenderMealAdult by Gender and FCS Group", ///
					 span size(3)) 	 										 ///
			note("Note: Matched pairs of female and male each N = 238: FCS Poor and borderline N = 28; FCS Acceptable N = 210", span size(2.5)) ///
			ylabel(0(10)70, nogrid labsize(2.5)) ///
			legend(ring(4) pos(6) rows(4) span size(2.5))
	graph export "${figs_gender}/Iraq_rCSI_F2F_GenderMealAdult_FCG.png", replace
	
********************************************************************************
*					PART 2: rCSIGenderMealNb
*******************************************************************************/

	**	Reshape 
	use `master', clear
	
	keep HHID Group Status FCG rCSIGenderMealNb_F rCSIGenderMealNb_M	 
	keep if !mi(rCSIGenderMealNb_F) & !mi(rCSIGenderMealNb_M)
	
	reshape long rCSIGenderMealNb_, ///
			i(HHID Group Status FCG) j(Gender) string
	ren *_ *
	
	gen Female = (Gender == "F")
	
	lab def fem_l 1 "Female" 0 "Male"
	lab def gender_option 1 "Mainly adult male (18+)"	///
						  2 "Mainly adult female (18+)" ///
						  3 "Mainly kids and youth male (<18)" ///
						  4 "Mainly kids and youth female (<18)" ///
						  5 "All adults equally"		///
						  6 "All family members equally"
	lab val Female fem_l
	lab val rCSIGenderMealNb gender_option
	
	tab  Status Female if !mi(rCSIGenderMealNb)
	catplot rCSIGenderMealNb Female Status, 					  			 ///
			percent(Female Status) blabe(bar, format(%4.1f) size(2)) 		 ///
			title("Iraq F2F: rCSI Cross-Gender Reporting", span size(5)) 	 ///
			subtitle("rCSIGenderMealNb by Gender and Status", ///
					 span size(3)) 	 										 ///
			note("Note: Matched pairs N = 191; IDP N = 94; Refugee N = 97", size(2.5)) ///
			ylabel(0(10)80, nogrid labsize(2.5)) ///
			legend(ring(4) pos(6) rows(4) span size(2.5))
	graph export "${figs_gender}/Iraq_rCSI_F2F_GenderMealNb_Status.png", replace
	
	tab  FCG Female if !mi(rCSIGenderMealNb)
	catplot rCSIGenderMealNb Female FCG, 					  			 ///
			percent(Female FCG) blabe(bar, format(%4.1f) size(2)) 		 ///
			title("Iraq F2F: rCSI Cross-Gender Reporting", span size(5)) 	 ///
			subtitle("rCSIGenderMealNb by Gender and FCS Group", ///
					 span size(3)) 	 										 ///
			note("Note: Matched pairs of female and male each N = 191: FCS Poor and borderline N = 31; FCS Acceptable N = 160", span size(2.5)) ///
			ylabel(0(10)60, nogrid labsize(2.5)) ///
			legend(ring(4) pos(6) rows(4) span size(2.5))
	graph export "${figs_gender}/Iraq_rCSI_F2F_GenderMealNb_FCG.png", replace
	
********************************************************************************
*					PART 3: Gender Perspective Comparison
*******************************************************************************/

	use "${temp}/Iraq_rCSI_F2F_Analysis.dta", clear
	keep HHID Group FCSCat28 Status FCG rCSIGenderMealSize_F 	 ///
		 rCSIGenderMealSize_M rCSIGenderMealAdult_F rCSIGenderMealAdult_M 	 ///
		 rCSIGenderMealNb_F rCSIGenderMealNb_M
	
	gl rcsi_short MealSize MealAdult MealNb
						
	lab def gender_diff_short 1  "Mainly female" 0  "Consistent perception" ///
							  -1 "Mainly male"
						
	lab def gender_dis 1 "Full Disagreement" 0 "Agreement"
	
						
foreach var of global rcsi_short {
	gen rCSI`var'_MainM = (rCSIGender`var'_M == 1) if !mi(rCSIGender`var'_M)
	gen rCSI`var'_MainF = (rCSIGender`var'_F == 2) if !mi(rCSIGender`var'_F)
*	ttest rCSI`var'_MainM == rCSI`var'_MainF 
	gen rCSI`var'_Diff  = rCSI`var'_MainF - rCSI`var'_MainM
	gen rCSI`var'_Disagree = (rCSI`var'_MainM == 1 & rCSI`var'_MainF == 1) if !mi(rCSI`var'_Diff)
	
	lab var rCSI`var'_MainM "Male reported mainly male adults suffered rCSI`var'"
	lab var rCSI`var'_MainF "Female reported mainly female adults suffered rCSI`var'"
	lab var rCSI`var'_Diff  "Difference between female and male reported main suffering rCSI`var'"
	lab var rCSI`var'_Disagree "Household Gendered Disagreement on rCSI`var'"
	lab val rCSI`var'_Diff gender_diff_short
	lab val rCSI`var'_Disagree gender_dis
	
}

	
** Diff
	catplot rCSIMealSize_Diff FCG, 					  		///
			percent(FCG) blabe(bar, format(%4.1f) size(2)) 	///
	graphregion(color(white)) bgcolor(white) 						///
	title("Iraq F2F: rCSI Cross-Gender Reporting", span size(5)) 	///
	subtitle("Household gender perspective on rCSIMealSize", span size(3))   ///
	note("Note: Matched pairs of female and male each N = 238: FCS Poor and borderline N = 32; FCS Acceptable N = 206", span size(2.5)) ///
	yline(0) outergap(50) bargap(10) 				  ///
	ylabel(0(10)90, nogrid labsize(2)) 				  ///
	legend(ring(4) pos(6) rows(3)				      ///
	  lab(1 "Mainly male") 		  	  				  ///
	  lab(2 "Female and male consistent perception") ///
	  lab(3 "Mainly female")		  ///
	  size(small)) 
	graph export "${figs_gender}/Iraq_rCSI_F2F_MealSize_Gender_FCG.png", replace
	
	catplot rCSIMealAdult_Diff FCG, 					  		///
			percent(FCG) blabe(bar, format(%4.1f) size(2)) 	///
	graphregion(color(white)) bgcolor(white) 						///
	title("Iraq F2F: rCSI Cross-Gender Reporting", span size(5)) 	///
	subtitle("Household gender perspective on rCSIMealAdult", span size(3))   ///
	yline(0) outergap(50) bargap(10) 				  ///
	ylabel(0(10)90, nogrid labsize(2)) 				  ///
	note("Note: Matched pairs of female and male each N = 238: FCS Poor and borderline N = 28; FCS Acceptable N = 210", span size(2.5)) ///
	legend(ring(4) pos(6) rows(3)					  ///
	  lab(1 "Mainly male") 		  	  					///
	  lab(2 "Female and male consistent perception") ///
	  lab(3 "Mainly female")		  ///
	  size(small)) 
	graph export "${figs_gender}/Iraq_rCSI_F2F_MealAdult_Gender_FCG.png", replace
	
	catplot rCSIMealNb_Diff FCG, 					  		///
			percent(FCG) blabe(bar, format(%4.1f) size(2)) 	///
	graphregion(color(white)) bgcolor(white) 						///
	title("Iraq F2F: rCSI Cross-Gender Reporting", span size(5)) 	///
	subtitle("Household gender perspective on rCSIMealNb", span size(3))   ///
	yline(0) outergap(50) bargap(10) 				  ///
	ylabel(0(10)80, nogrid labsize(2)) 				  ///
	note("Note: Matched pairs of female and male each N = 191: FCS Poor and borderline N = 31; FCS Acceptable N = 160", span size(2.5)) ///
	legend(ring(4) pos(6) rows(3) span				  ///
	  lab(1 "Mainly male") 		  	  ///
	  lab(2 "Female and male consistent perception") ///
	  lab(3 "Mainly female")		  ///
	  size(small)) 
	graph export "${figs_gender}/Iraq_rCSI_F2F_MealNb_Gender_FCG.png", replace
	
**  Disagreement
	catplot rCSIMealSize_Disagree FCG, 					  			///
			percent(FCG) blabe(bar, format(%4.1f) size(2)) 			///
	graphregion(color(white)) bgcolor(white) 						///
	title("Iraq F2F: rCSI Cross-Gender Reporting", span size(5)) 	///
	subtitle("Household Disagreement on rCSIMealSize Gendered Perspective", span size(3))   ///
	note("Note: Matched pairs of female and male each N = 238: FCS Poor and borderline N = 32; FCS Acceptable N = 206", span size(2.5)) ///
	yline(0) outergap(50) bargap(10) 				  ///
	ylabel(0(10)90, nogrid labsize(2)) 				  ///
	legend(ring(4) pos(6) rows(3) span size(small)) 
	graph export "${figs_gender}/Iraq_rCSI_F2F_MealSize_Gender_FCG_Disagreement.png", replace

	catplot rCSIMealSize_Disagree, 					  			///
			percent blabe(bar, format(%4.1f) size(2)) 			///
	graphregion(color(white)) bgcolor(white) 						///
	title("Iraq F2F: rCSI Cross-Gender Reporting", span size(5)) 	///
	subtitle("Household Disagreement on rCSIMealSize Gendered Perspective", span size(3))   ///
	note("Note: Matched pairs of female and male each N = 238: FCS Poor and borderline N = 32; FCS Acceptable N = 206", span size(2.5)) ///
	ytitle("") yline(0) outergap(50) bargap(10) 				  				///
	ylabel(0(10)100, nogrid labsize(2)) 				 			///
	legend(ring(4) pos(6) rows(3) span size(small)) 	
	graph export "${figs_gender}/Iraq_rCSI_F2F_MealSize_Gender_Disagreement.png", replace
	
	catplot rCSIMealAdult_Disagree FCG, 					  		///
			percent(FCG) blabe(bar, format(%4.1f) size(2)) 			///
	graphregion(color(white)) bgcolor(white) 						///
	title("Iraq F2F: rCSI Cross-Gender Reporting", span size(5)) 	///
	subtitle("Household Disagreement on rCSIMealAdult Gendered Perspective", span size(3))   ///
	yline(0) outergap(50) bargap(10) 				  ///
	ylabel(0(10)90, nogrid labsize(2)) 				  ///
	note("Note: Matched pairs of female and male each N = 238: FCS Poor and borderline N = 28; FCS Acceptable N = 210", span size(2.5)) ///
	legend(ring(4) pos(6) rows(3) span size(small)) 
	graph export "${figs_gender}/Iraq_rCSI_F2F_MealAdult_Gender_FCG_Disagreement.png", replace
	
	catplot rCSIMealAdult_Disagree, 					  		///
			percent blabe(bar, format(%4.1f) size(2)) 			///
	graphregion(color(white)) bgcolor(white) 						///
	title("Iraq F2F: rCSI Cross-Gender Reporting", span size(5)) 	///
	subtitle("Household Disagreement on rCSIMealAdult Gendered Perspective", span size(3))   ///
	yline(0) outergap(50) bargap(10) 				  		///
	ytitle("") ytitle("") ylabel(0(10)100, nogrid labsize(2)) 				  	///
	note("Note: Matched pairs of female and male each N = 238: FCS Poor and borderline N = 28; FCS Acceptable N = 210", span size(2.5)) ///
	legend(ring(4) pos(6) rows(3) span size(small)) 
	graph export "${figs_gender}/Iraq_rCSI_F2F_MealAdult_Gender_Disagreement.png", replace
	
	catplot rCSIMealNb_Disagree FCG, 					  		///
			percent(FCG) blabe(bar, format(%4.1f) size(2)) 	///
	graphregion(color(white)) bgcolor(white) 						///
	title("Iraq F2F: rCSI Cross-Gender Reporting", span size(5)) 	///
	subtitle("Household Disagreement on rCSIMealNb Gendered Perspective", span size(3))   ///
	yline(0) outergap(50) bargap(10) 				  ///
	ylabel(0(10)80, nogrid labsize(2)) 				  ///
	note("Note: Matched pairs of female and male each N = 191: FCS Poor and borderline N = 31; FCS Acceptable N = 160", span size(2.5)) ///
	legend(ring(4) pos(6) rows(3) span size(small)) 
	graph export "${figs_gender}/Iraq_rCSI_F2F_MealNb_Gender_FCG_Disagreement.png", replace
	
	catplot rCSIMealNb_Disagree, 					  		///
			percent blabe(bar, format(%4.1f) size(2)) 		///
	graphregion(color(white)) bgcolor(white) 						///
	title("Iraq F2F: rCSI Cross-Gender Reporting", span size(5)) 	///
	subtitle("Household Disagreement on rCSIMealNb Gendered Perspective", span size(3))   ///
	ytitle("") ylabel(0(10)100, nogrid labsize(2)) 				  ///
	note("Note: Matched pairs of female and male each N = 191: FCS Poor and borderline N = 31; FCS Acceptable N = 160", span size(2.5)) ///
	legend(ring(4) pos(6) rows(3) span size(small)) 
	graph export "${figs_gender}/Iraq_rCSI_F2F_MealNb_Gender_Disagreement.png", replace
	
	iebaltab 	rCSIMealSize_Diff rCSIMealAdult_Diff rCSIMealNb_Diff,  		///
				grpvar(Status) grplabels(1 IDP @ 2 Refugee) ///
				rowvarlabels savexlsx("${tabs_gender}/Iraq_rCSI_F2F_Gender_Balance_Status.xlsx") replace
				
	iebaltab 	rCSIMealSize_Diff rCSIMealAdult_Diff rCSIMealNb_Diff,  		///
				grpvar(FCG) grplabels(1 Poor and Borderline @ 2 Acceptable) ///
				rowvarlabels savexlsx("${tabs_gender}/Iraq_rCSI_F2F_Gender_Balance_FCG.xlsx") replace

				
	** tabulation 
	label def f_agree 1 "Female reported mainly female" 0 "Other"
	label val *_MainF f_agree
	
	label def m_agree 1 "Male reported mainly male"     0 "Other"
	label val *_MainM m_agree
	
	tabout rCSIMealSize_MainM rCSIMealSize_MainF ///
	using "${tabs_gender}/Iraq_rCSI_F2F_rCSIMealSize_Crosstab.docx", ///
	replace style(docx) font(bold) ///
	c(freq cell) f(0 1p) nlab(Sample size) h3(nil)

	tabout rCSIMealAdult_MainM rCSIMealAdult_MainF ///
	using "${tabs_gender}/Iraq_rCSI_F2F_rCSIMealAdult_Crosstab.docx", ///
	replace style(docx) font(bold) ///
	c(freq cell) f(0 1p) nlab(Sample size) h3(nil)
	
	tabout rCSIMealNb_MainM rCSIMealNb_MainF ///
	using "${tabs_gender}/Iraq_rCSI_F2F_rCSIMealNb_Crosstab.docx", ///
	replace style(docx) font(bold) ///
	c(freq cell) f(0 1p) nlab(Sample size) h3(nil)
	
	