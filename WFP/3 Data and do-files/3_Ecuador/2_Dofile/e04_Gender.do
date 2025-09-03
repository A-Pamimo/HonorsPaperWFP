/* *************************************************************************** *
*					WFP RAM-N rCARI Validation Study - Ecuador 				   * 
*																 			   *
*  PURPOSE:  			Analyzing MDD_Index and Gender Diff					   *
*  AUTHOR: 				Nicole Wu (nicole.wu@wfp.org)						   *
*  DATE:  				Sep 20, 2023										   *
*  LATEST UPDATE: 															   *
*		  																	   *
********************************************************************************
					
	** REQUIRES:	${dta}/Ecuador_Full_Household_rCARI_Analysis.dta
					
	** CREATES:		
					
	** NOTES:		

********************************************************************************
*								PART 1: Set Log
*******************************************************************************/

	cap log close 
	
	// set log
	loc cdate: di %td_CCYY_NN_DD date(c(current_date), "DMY")
	loc cdate = subinstr(trim("`cdate'"), " " , "", .)
	log using "${logs}/e01_gender_`cdate'.smcl", replace
	di `cdate'	

	graph set window fontface "Times New Roman"
	
	* Load dataset
	use "${dta}/Ecuador_Full_Household_rCARI_Analysis.dta", replace
	compress 

********************************************************************************
*						PART 2: Define variables
*******************************************************************************/
	
	gl out_mddi MDD_Staples MDD_Pulses MDD_NutsSeeds MDD_Dairies MDD_MeatFish 	///
			    MDD_Eggs MDD_LeafGVeg MDD_VitA MDD_OtherVeg MDD_OtherFruits   	///
				MDD_Index MDD_Index_5
				
********************************************************************************
*							PART 3: Gendered Difference
*******************************************************************************/

	iebaltab ${out_mddi} if Modality == 1, grpvar(RESPSex)   					///
			 nonote nototal replace	onerow										///
             format(%12.2fc) grplabels(0 Female @ 1 Male) 						///
             rowvarlabels savetex("${tex_tab}/Ecuador_F2F_MDD_Gender.tex")
			 
********************************************************************************
*						PART 2: Create Graphs for MDDI
*******************************************************************************/
	
	betterbar MDD_Index if Modality == 1, by(FCSCat28) over(RESPSex) 	///
			  ci n bar v graphregion(color(white)) 						///
              bgcolor(white) ylabel(0(2)6, nogrid labsize(2.5)) 
	graph export "${tex_fig}/Ecuador_F2F_MDD_Index_FCG_Gender.png", replace
			  
/*	graph box MDD_Index, over(RESPSex)  						///
    graphregion(color(white)) bgcolor(white) 					///
    outergap(70) bargap(100) ylabel(0(1)12, nogrid labsize(3)) 	///
    ytitle("") yline(5, lwidth(0.25pt) lcolor(grey) lp(shortdash))	///
    legend(ring(4) pos(6) rows(5) size(3))						///
    text(5.2 21 "Mean = 4.4", place(ne) size(3) color(white))	///
    text(5.2 67 "Mean = 4.3", place(ne) size(3) color(white))	///
    text(11.5 23 "Female - Male Difference = 0.12 and P = 0.42", place(n c) size(3.5))
    graph export "${figs_tex}/Ecuador_F2F_MDD_Index_Gender.png", replace
    
    ttest MDD_Index, by(RESPSex)	
*/	
	betterbar MDD_Staples MDD_Pulses MDD_NutsSeeds MDD_Dairies MDD_MeatFish 	///
			  MDD_Eggs MDD_LeafGVeg MDD_VitA MDD_OtherVeg MDD_OtherFruits   	///
			  if Modality == 1, over(RESPSex) ylabel(, nogrid labsize(2.5))		///
			  ci n bar graphregion(color(white)) bgcolor(white)	  
	graph export "${tex_fig}/Ecuador_F2F_MDD_Group_Gender.png", replace
	
	// xlabel(, labsize(2.5) angle(45)) pct ylabel(0(0.2)1, nogrid labsize(2.5))	  
