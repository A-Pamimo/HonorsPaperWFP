********************************************************************************
*					PART 1: Set up MDD datasets
*******************************************************************************/
	
* 	Minimum Dietary Diversity for an adult
	use "${dta}/Iraq_F2F_Household_Analysis.dta", clear
	fsum $out_mdd	
	
	* Box graph for original rCSI by Gender and FCG
	graph box MDDW_Index, over(MDDR_Sex)  						///
	graphregion(color(white)) bgcolor(white) 					///
	title("Iraq F2F: MDD Cross-Gender Reporting", size(5)) 		///
	subtitle("Original respondent Male vs. Female", size(3)) 	///
	outergap(70) bargap(100) ylabel(0(1)12, nogrid labsize(3)) 	///
	ytitle("") yline(5, lwidth(0.25pt) lcolor(grey) lp(shortdash))		  ///
	note("Note: Original Respondents N = 431 (Male = 193, Female = 238)", ///
	ring(4) pos(6) size(2.5)) legend(ring(4) pos(6) rows(5) size(small))
	graph export "${figs_gender}/Iraq_MDD_Index_F2F_Original_Gender.png", replace
	
	graph box MDDW_Index, over(MDDR_Sex) over(FCG)  					///
	graphregion(color(white)) bgcolor(white) 					///
	title("Iraq F2F: MDD Cross-Gender Reporting", size(5)) 		///
	subtitle("Original respondent Male vs. Female by FCS Group", size(3)) 	///
	outergap(70) bargap(100) ylabel(0(1)12, nogrid labsize(3)) 	///
	ytitle("") ytitle("") yline(5, lwidth(0.25pt) lcolor(grey) lp(shortdash))			///
	note("Note: Original Respondents N = 431 (Male = 193, Female = 238)", ///
	ring(4) pos(6) size(2.5)) legend(ring(4) pos(6) rows(5) size(small))
	graph export "${figs_gender}/Iraq_MDD_Index_F2F_Original_Gender_FCG.png", replace	 
	
*	Gender issues - PENDING
	tab RESPSex MDDR_Sex 
	
//  Should be the same person but changed
/*	Sex of the | Sex of the respondent
	respondent |    Female       Male |     Total
	-----------+----------------------+----------
		Female |       162         24 |       186 
		  Male |        76        169 |       245 
	-----------+----------------------+----------
		 Total |       238        193 |       431
*/
	drop if RESPSex != MDDR_Sex	//259 dropped (100 diff gender)
	
	tab MDDR_Sex MDDWSexR 
	
//  Should be of the opposite gender	
/*	Sex of the | Sex of the respondent
	respondent |    Female       Male |     Total
	-----------+----------------------+----------
		Female |         7        143 |       150 
		  Male |       160          4 |       164 
	-----------+----------------------+----------
		 Total |       167        147 |       314 
*/
	drop if MDDR_Sex == MDDWSexR 
//  dropped 11 obs same gender
//  n = 320 answered both MDD sections and of different gender
	save "${temp}/Iraq_MDD_F2F_Raw.dta", replace
	
********************************************************************************
*					PART 2: MDD Gendered Difference
*******************************************************************************/

	sum PWMDDW*

	gl raw_mddw StapCer StapRoo Pulse Nuts Milk Dairy PrMeatO PrMeatF PrMeatPro ///
				PrMeatWhite PrFish PrEgg VegGre VegOrg FruitOrg VegOth FruitOth Snf
	
	gl pro_mddw Staples Pulses NutsSeeds Dairies MeatFish Eggs LeafGVeg VitA ///
				OtherVeg OtherFruits Index Index_5
	
foreach var in $raw_mddw {
	gen  	`var'_F = PWMDDW`var'R 	  if MDDR_Sex == 0
	replace `var'_F = PWMDDW`var'_oth if MDDWSexR == 0
	lab var `var'_F "`var' Female"
	
	gen 	`var'_M = PWMDDW`var'R 	  if MDDR_Sex == 1
	replace `var'_M = PWMDDW`var'_oth if MDDWSexR == 1
	lab var `var'_M "`var' Male"
	
	gen `var'_g_diff = `var'_F - `var'_M if !mi(`var'_F) & !mi(`var'_M)
	lab var  `var'_g_diff "Difference between female reported and male reported MDDW `var'"
	
}
		
foreach var in $pro_mddw {
	gen  	`var'_F = MDDW_`var' 	  if MDDR_Sex == 0
	replace `var'_F = MDDW_`var'_oth  if MDDWSexR == 0
	lab var `var'_F "`var' Female"
	
	gen 	`var'_M = MDDW_`var' 	  if MDDR_Sex == 1
	replace `var'_M = MDDW_`var'_oth  if MDDWSexR == 1
	lab var `var'_M "`var' Male"
	
	gen `var'_g_diff = `var'_F - `var'_M
	lab var  `var'_g_diff "Difference between female reported and male reported MDDW `var'"
	
}
	
	gl diff_mdd    StapCer_g_diff StapRoo_g_diff Pulse_g_diff Nuts_g_diff Milk_g_diff ///
				   Dairy_g_diff PrMeatO_g_diff PrMeatF_g_diff PrMeatPro_g_diff 		  ///
				   PrMeatWhite_g_diff PrFish_g_diff PrEgg_g_diff VegGre_g_diff 		  ///
				   VegOrg_g_diff FruitOrg_g_diff VegOth_g_diff FruitOth_g_diff 		  ///
				   Snf_g_diff Staples_g_diff Pulses_g_diff NutsSeeds_g_diff 		  ///
				   Dairies_g_diff MeatFish_g_diff Eggs_g_diff LeafGVeg_g_diff 	  ///
				   VitA_g_diff OtherVeg_g_diff OtherFruits_g_diff Index_g_diff Index_5_g_diff
	
	save "${temp}/Iraq_MDD_F2F_Analysis.dta", replace	
	
	graph bar Staples_g_diff Pulses_g_diff NutsSeeds_g_diff 		 		 ///
			  Dairies_g_diff MeatFish_g_diff Eggs_g_diff LeafGVeg_g_diff 	 ///
			  VitA_g_diff OtherVeg_g_diff OtherFruits_g_diff, 				 ///
	graphregion(color(white)) bgcolor(white)								 ///
	title("Iraq F2F: MDD Cross-Gender Difference", size(5)) 				 ///
	subtitle("Female - Male", size(3)) 					 ///
	yline(0, lwidth(0.25pt) lcolor(grey) lp(shortdash)) outergap(70) bargap(100)	///
	ylabel(-0.1(0.05)0.1, nogrid labsize(2.5)) blabel(bar, format(%7.2f) size(2))		///
	note("Note: Matched household pairs N = 303", ring(4) pos(6) size(2.5)) 	///
	legend(ring(4) pos(5) rows(2)									///
	  lab(1 "Staples") 						///
	  lab(2 "Pulses") 						///
	  lab(3 "Nuts and seeds") 				///
	  lab(4 "Milk and dairy products") 		///
	  lab(5 "Meat and fish/seafoods") 		///
	  lab(6 "Eggs") 						///
	  lab(7 "Dark green leafy vegetables") 	///
	  lab(8 "Vitamin A-rich vegetables & fruits")	///
	  lab(9 "Other vegetables") 			///
	  lab(10 "Other fruits") 				///
	  size(2))
	graph export "${figs_gender}/Iraq_MDD_F2F_Gender_Comparison.png", replace	 
	
	graph bar Staples_g_diff Pulses_g_diff NutsSeeds_g_diff 		 		 ///
			  Dairies_g_diff MeatFish_g_diff Eggs_g_diff LeafGVeg_g_diff 	 ///
			  VitA_g_diff OtherVeg_g_diff OtherFruits_g_diff, over(FCG, gap(500))		 ///
	graphregion(color(white)) bgcolor(white)								 ///
	title("Iraq F2F: MDD Cross-Gender Difference", size(5)) 				 ///
	subtitle("Female - Male Mean by FCS Group", size(3)) 					 ///
	yline(0, lwidth(0.25pt) lcolor(grey) lp(shortdash)) outergap(10) bargap(100)	///
	ylabel(-0.15(0.05)0.15, nogrid labsize(2.5)) blabel(bar, format(%7.2f) size(2))		///
	note("Note: Matched household pairs N = 303 (FCS Poor or Borderline N = 33; FCS Acceptable N = 270)", ring(4) pos(6) size(2.5)) 	///
	legend(ring(4) pos(5) rows(2)									///
	  lab(1 "Staples") 						///
	  lab(2 "Pulses") 						///
	  lab(3 "Nuts and seeds") 				///
	  lab(4 "Milk and dairy products") 		///
	  lab(5 "Meat and fish/seafoods") 		///
	  lab(6 "Eggs") 						///
	  lab(7 "Dark green leafy vegetables") 	///
	  lab(8 "Vitamin A-rich vegetables & fruits")	///
	  lab(9 "Other vegetables") 			///
	  lab(10 "Other fruits") 				///
	  size(2))
	graph export "${figs_gender}/Iraq_MDD_F2F_Gender_Comparison_FCG.png", replace	 
	
	graph box Index_g_diff, over(FCG)				 						///
	graphregion(color(white)) bgcolor(white)								 ///
	title("Iraq F2F: MDD Cross-Gender Difference", size(5)) 				 ///
	subtitle("Female - Male by FCS Group", size(3))   ///
	yline(0, lwidth(0.25pt) lcolor(grey) lp(shortdash)) outergap(70) bargap(100) ///
	ylabel(-5(1)5, nogrid labsize(3)) blabel(bar, format(%7.2f) size(2))		 ///
	ytitle("") note("Note: Matched household pairs N = 303 (FCS Poor or Borderline N = 33; FCS Acceptable N = 270)", ring(4) pos(6) size(2.5))
	graph export "${figs_gender}/Iraq_MDD_Index_F2F_Gender_FCG.png", replace	   
	
/* ** correlation between MDD and FCS
	asdoc pwcorr Index_M Index_F FCS FES, star(.05) replace save(${tabs_gender}/Iraq_MDD_F2F_Gender_Correlation_FCS.doc) ///
										  fhc(\b) font(Roboto) label dec(2) tzok
										  
*/										  
