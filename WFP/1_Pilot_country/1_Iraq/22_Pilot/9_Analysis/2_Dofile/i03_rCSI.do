********************************************************************************
*					PART 1: rCSI Original vs. Opposite Sex
*******************************************************************************/
	
	use "${dta}/Iraq_F2F_Household_Analysis.dta", clear
	
	tab RESPSex rCSIRESPSex_oth
	
/*  Sex of the | Sex of the respondent
	respondent |    Female       Male |     Total
	-----------+----------------------+----------
		Female |        13        160 |       173 
		  Male |       237          1 |       238 
	-----------+----------------------+----------
		 Total |       250        161 |       411 

*/
	drop if RESPSex == rCSIRESPSex_oth	// dropped 14 both female or male 

	sum $out_rcsi		
	gl analysis_rcsi rCSILessQlty rCSIBorrow rCSIMealSize rCSIMealAdult rCSIMealNb ///
					 rCSIGenderMealSize rCSIGenderMealAdult rCSIGenderMealNb rCSI

	* Box graph for original rCSI by Gender and FCG
	graph box rCSI, over(RESPSex) over(FCG)  					///
	graphregion(color(white)) bgcolor(white) 					///
	title("Iraq F2F: rCSI Cross-Gender Reporting", size(5)) 		///
	subtitle("Original respondent Male vs. Female by FCS Group", size(3)) 	///
	outergap(70) bargap(100) ylabel(0(7)56, nogrid labsize(3)) 	///
	note("Note: Original Respondents N = 576 (Male = 281, Female = 295)", ///
	ring(4) pos(6) size(2.5)) legend(ring(4) pos(6) rows(5) size(small))
	graph export "${figs_gender}/Iraq_rCSI_Index_F2F_Original_Gender_FCG.png", replace	 
	
	iebaltab 	rCSI, grpvar(RESPSex) grplabels(1 Male @ 0 Female) ///
				rowvarlabels savexlsx("${tabs_gender}/Iraq_rCSI_Index_F2F_Balance_Original_Gender.xlsx") replace
	
/* * Box graph for difference
	
	graph box rCSILessQlty_diff rCSIBorrow_diff rCSIMealSize_diff 	///
			  rCSIMealAdult_diff rCSIMealNb_diff, 					///
	graphregion(color(white)) bgcolor(white) 						///
	title("rCSI Cross-Gender Reporting: Iraq F2F", size(5)) 		///
	subtitle("Original Respondent - Opposite Sex Respondent", size(3)) 		///
	yline(0)											///
	outergap(70) bargap(100) 										///
	ylabel(-7(1)7, nogrid labsize(3)) 								///
	legend(ring(0) pos(6) rows(5)									///
	  lab(1 "Relied on less preferred, less expensive food") 		///
	  lab(2 "Borrowed food or relied on help") 						///
	  lab(3 "Reduced portion size of meals at meals time")			///
	  lab(4 "Restricted consumption by adults in order for young-children to eat")		///
	  lab(5 "Reduced the number of meals eaten per day")			///
	  size(small))
	graph export "${figs}/Iraq_F2F_Full_rCSI_Opposite_Comparison.png", replace	 
   
   ** Diff by Group
   graph box rCSILessQlty_diff rCSIBorrow_diff rCSIMealSize_diff 	///
			  rCSIMealAdult_diff rCSIMealNb_diff, over(Group)					///
	graphregion(color(white)) bgcolor(white) 						///
	title("rCSI Cross-Gender Reporting: Iraq F2F by Group", size(5)) 		///
	subtitle("Original Respondent - Opposite Sex Respondent", size(3)) 		///
	yline(0)											///
	outergap(70) bargap(100) 										///
	ylabel(-7(1)7, nogrid labsize(3)) 								///
	legend(ring(0) pos(6) rows(5)									///
	  lab(1 "Relied on less preferred, less expensive food") 		///
	  lab(2 "Borrowed food or relied on help") 						///
	  lab(3 "Reduced portion size of meals at meals time")			///
	  lab(4 "Restricted consumption by adults in order for young-children to eat")		///
	  lab(5 "Reduced the number of meals eaten per day")			///
	  size(small))
	graph export "${figs}/Iraq_F2F_Full_rCSI_Opposite_Comparison.png", replace
*/
	
********************************************************************************
*					PART 2: rCSI Gendered Difference
*******************************************************************************/
  
foreach var of global analysis_rcsi {
	gen  	`var'_F = `var' 	if RESPSex 		   == 0
	replace `var'_F = `var'_oth if rCSIRESPSex_oth == 0
	lab var `var'_F "Female reported `var'"
	
	gen 	`var'_M = `var' 	if RESPSex 		   == 1
	replace `var'_M = `var'_oth if rCSIRESPSex_oth == 1
	lab var `var'_M "Male reported `var'"
	
	gen `var'_g_diff = `var'_F - `var'_M
	lab var  `var'_g_diff "Difference between female reported and male Reported `var'"
}
	
	save "${temp}/Iraq_rCSI_F2F_Analysis.dta", replace	
	
	* rename for exporting results
	ren rCSI*_F F_*
	ren rCSI*_M M_*
	ren *_MealSize  *_MealSz
	ren *_MealAdult *_MealAd
	ren F_		F_rCSI
	ren M_		M_rCSI
	
	
	asdoc ttest F_LessQlty == M_LessQlty, replace   save(${tabs_gender}/Iraq_rCSI_F2F_Gender_Difference_Paired_ttest.doc) ///
									   title(Paired Gender Difference for rCSI) fhc(\b) fhr(\b) font(Roboto) label dec(2) tzok
	asdoc ttest F_Borrow == M_Borrow,  rowappend save(${tabs_gender}/Iraq_rCSI_F2F_Gender_Difference_Paired_ttest.doc) ///
									   fhr(\b) font(Roboto) label dec(2) tzok
	asdoc ttest F_MealSz == M_MealSz,  rowappend save(${tabs_gender}/Iraq_rCSI_F2F_Gender_Difference_Paired_ttest.doc) ///
									   fhr(\b) font(Roboto) label dec(2) tzok
	asdoc ttest F_MealAd == M_MealAd,  rowappend save(${tabs_gender}/Iraq_rCSI_F2F_Gender_Difference_Paired_ttest.doc) ///
									   fhr(\b) font(Roboto) label dec(2) tzok
	asdoc ttest F_MealNb == M_MealNb,  rowappend save(${tabs_gender}/Iraq_rCSI_F2F_Gender_Difference_Paired_ttest.doc) ///
									   fhr(\b) font(Roboto) label dec(2) tzok
	asdoc ttest F_rCSI 	 == M_rCSI,    rowappend save(${tabs_gender}/Iraq_rCSI_F2F_Gender_Difference_Paired_ttest.doc) ///
									   fhr(\b) font(Roboto) label dec(2) tzok

	eststo clear
	eststo: ttest F_LessQlty == M_LessQlty
	eststo: ttest F_Borrow == M_Borrow
	eststo: ttest F_MealSz == M_MealSz
	eststo: ttest F_MealAd == M_MealAd
	eststo: ttest F_MealNb == M_MealNb
	eststo: ttest F_rCSI == M_rCSI	
	
	* Box graph for difference
	graph box rCSILessQlty_g_diff rCSIBorrow_g_diff rCSIMealSize_g_diff 	///
			  rCSIMealAdult_g_diff rCSIMealNb_g_diff, 				///
	graphregion(color(white)) bgcolor(white)						///
	title("Iraq F2F: rCSI Cross-Gender Reporting", size(5)) 		///
	subtitle("Female reported - Male reported", size(3)) 	///
	yline(0, lwidth(0.25pt) lcolor(grey) lp(shortdash)) outergap(70) bargap(100)		///
	ylabel(-7(1)7, nogrid labsize(3)) 								///
	note("Note: Matched pairs N = 397", ring(4) pos(6) size(2.5)) 	///
	legend(ring(4) pos(6) rows(5)									///
	  lab(1 "Relied on less preferred, less expensive food") 		///
	  lab(2 "Borrowed food or relied on help") 						///
	  lab(3 "Reduced portion size of meals at meals time")			///
	  lab(4 "Restricted consumption by adults in order for young-children to eat")	///
	  lab(5 "Reduced the number of meals eaten per day") 			///
	  size(small))
	graph export "${figs_gender}/Iraq_rCSI_F2F_Gender_Comparison.png", replace	 
   
   	graph box rCSI_g_diff, 											///
	graphregion(color(white)) bgcolor(white) 						///
	title("Iraq F2F: rCSI Cross-Gender Reporting", size(5)) 		///
	subtitle("Female reported - Male reported", size(3)) 	///
	yline(0, lwidth(0.25pt) lcolor(grey) lp(shortdash)) outergap(70) bargap(100) ///
	ylabel(-28(7)35, nogrid labsize(3)) 							///
	note("Note: Matched pairs N = 397", ring(4) pos(6) size(2.5)) 	///
	legend(ring(4) pos(6) rows(5) size(small))
	graph export "${figs_gender}/Iraq_rCSI_Index_F2F_Gender_Comparison.png", replace	 
   
   ** By FSC Groups
   graph box rCSILessQlty_g_diff rCSIBorrow_g_diff rCSIMealSize_g_diff 	///
			 rCSIMealAdult_g_diff rCSIMealNb_g_diff, over(FCG) 	///
	graphregion(color(white)) bgcolor(white) 						///
	title("Iraq F2F: rCSI Cross-Gender Reporting", size(5)) 		///
	subtitle("Female reported - Male reported by FCS Group", size(3))  ///
	yline(0, lwidth(0.25pt) lcolor(grey) lp(shortdash)) outergap(50) bargap(10) 	///
	ylabel(-7(1)7, nogrid labsize(3)) 								///
	note("Note: Matched pairs N = 397: FCS Poor and Borderline N = 40; FCS Acceptable N = 357", ring(4) pos(6) size(2.5)) 	///
	legend(ring(4) pos(6) rows(5)									///
	  lab(1 "Relied on less preferred, less expensive food") 		///
	  lab(2 "Borrowed food or relied on help") 						///
	  lab(3 "Reduced portion size of meals at meals time")			///
	  lab(4 "Restricted consumption by adults in order for young-children to eat")	///
	  lab(5 "Reduced the number of meals eaten per day")			///
	  size(small))
	graph export "${figs_gender}/Iraq_rCSI_F2F_Gender_Comparison_FCG.png", replace	 
	
	graph box rCSI_g_diff, over(FCG)								///
	graphregion(color(white)) bgcolor(white) 						///
	title("Iraq F2F: rCSI Cross-Gender Reporting", size(5)) 		///
	subtitle("Female reported - Male reported by FCS Group", size(3)) 	///
	note("Note: Matched pairs N = 397: FCS Poor and Borderline N = 40; FCS Acceptable N = 357", ring(4) pos(6) size(2.5)) 	///
	ytitle("") yline(0, lwidth(0.25pt) lcolor(grey) lp(shortdash)) outergap(70) bargap(100) 	///
	ylabel(-28(7)35, nogrid labsize(3)) 							///
	legend(ring(4) pos(6) rows(5) size(small))
	graph export "${figs_gender}/Iraq_rCSI_Index_F2F_Gender_Comparison_FCG.png", replace	 
	
	** By Group A & B
	graph box rCSILessQlty_g_diff rCSIBorrow_g_diff rCSIMealSize_g_diff 		 ///
			  rCSIMealAdult_g_diff rCSIMealNb_g_diff, over(Group) 	///
	graphregion(color(white)) bgcolor(white) 						///
	title("Iraq F2F: rCSI Cross-Gender Reporting", size(5)) 		///
	subtitle("Female reported - Male reported by Group", size(3))   ///
	note("Note: Matched pairs N = 397: Group A N = 226; Group B N = 171", ring(4) pos(6) size(2.5)) 	///
	yline(0, lwidth(0.25pt) lcolor(grey) lp(shortdash)) outergap(50) bargap(10) 								///
	ylabel(-7(1)7, nogrid labsize(3)) 								///
	legend(ring(4) pos(6) rows(5)									///
	  lab(1 "Relied on less preferred, less expensive food") 		///
	  lab(2 "Borrowed food or relied on help") 						///
	  lab(3 "Reduced portion size of meals at meals time")			///
	  lab(4 "Restricted consumption by adults in order for young-children to eat") ///
	  lab(5 "Reduced the number of meals eaten per day")			///
	  size(small)) 
	graph export "${figs_gender}/Iraq_rCSI_F2F_Gender_Comparison_Group.png", replace	 
	
	** By Refugee & IDP Status
	graph box rCSILessQlty_g_diff rCSIBorrow_g_diff rCSIMealSize_g_diff 	///
			  rCSIMealAdult_g_diff rCSIMealNb_g_diff, over(Status)  ///
	graphregion(color(white)) bgcolor(white) 						///
	title("Iraq F2F: rCSI Cross-Gender Reporting", size(5)) 		///
	subtitle("Female reported - Male reported by Status", size(3))  ///
	note("Note: Matched pairs N = 397: IDP N = 177; Refugee N = 220", ring(4) pos(6) size(2.5)) 	///
	yline(0, lwidth(0.25pt) lcolor(grey) lp(shortdash)) outergap(50) bargap(10) 	///
	ylabel(-7(1)7, nogrid labsize(3)) 								///
	legend(ring(4) pos(6) rows(5)									///
	  lab(1 "Relied on less preferred, less expensive food") 		///
	  lab(2 "Borrowed food or relied on help") 						///
	  lab(3 "Reduced portion size of meals at meals time")			///
	  lab(4 "Restricted consumption by adults in order for young-children to eat") ///
	  lab(5 "Reduced the number of meals eaten per day")			///
	  size(small)) 
	graph export "${figs_gender}/Iraq_rCSI_F2F_Gender_Comparison_Status.png", replace
	
	** By Refugee & IDP Status & FCS Groups
	graph box rCSILessQlty_g_diff rCSIBorrow_g_diff 				///
			  rCSIMealSize_g_diff rCSIMealAdult_g_diff				///
			  rCSIMealNb_g_diff, over(FCG) over(Status) 			///
	graphregion(color(white)) bgcolor(white) 						///
	title("Iraq F2F: rCSI Cross-Gender Reporting", size(5)) 		///
	subtitle("Female reported - Male reported by Status and FCS Group", size(3))   ///
	note("Note: Matched pairs N = 397: IDP N = 177; Refugee N = 220", ring(4) pos(6) size(2.5)) ///
	yline(0, lwidth(0.25pt) lcolor(grey) lp(shortdash)) outergap(50) bargap(10) legend(size(2))		///
	ylabel(-7(1)7, nogrid labsize(2.5))	lintensity(*)				///
	legend(ring(4) pos(6) rows(5)									///
	  lab(1 "Relied on less preferred, less expensive food") 		///
	  lab(2 "Borrowed food or relied on help") 						///
	  lab(3 "Reduced portion size of meals at meals time")			///
	  lab(4 "Restricted consumption by adults in order for young-children to eat")		///
	  lab(5 "Reduced the number of meals eaten per day")			///
	  size(2)) 
	graph export "${figs_gender}/Iraq_rCSI_F2F_Gender_Comparison_Status_FCG.png", replace
				 
	iebaltab rCSILessQlty_g_diff rCSIBorrow_g_diff 				///
			 rCSIMealSize_g_diff rCSIMealAdult_g_diff			///
			 rCSIMealNb_g_diff rCSI_g_diff, 				 		///
			 grpvar(Status) grplabels(1 IDP @ 2 Refugee) ///
			 rowvarlabels savetex("${tabs_bal}/Iraq_rCSI_F2F_Balance_Status.tex") ///
			 texdocument texcaption("Balance Test for rCSI Variables and Index: IDP vs. Refugee") replace
	
	
	iebaltab rCSILessQlty_g_diff rCSIBorrow_g_diff 				///
			 rCSIMealSize_g_diff rCSIMealAdult_g_diff			///
			 rCSIMealNb_g_diff rCSI_g_diff, 				 		///
			 grpvar(FCG) grplabels(1 Poor and Borderline @ 2 Acceptable) ///
			 rowvarlabels savetex("${tabs_bal}/Iraq_rCSI_F2F_Balance_FCG.tex") ///
			 texdocument texcaption("Balance Test for rCSI Variables and Index: IDP vs. Refugee") replace
			 