/* *************************************************************************** *
*					WFP RAM-N rCARI Validation Study - All 				   * 
*																 			   *
*  PURPOSE:  			Master dofile										   *
*  AUTHOR: 				Nicole Wu (nicole.wu@wfp.org)						   *
*  DATE:  				Jun 30, 2023										   *
*  LATEST UPDATE: 		Dec  8, 2023										   *
*		  																	   *
********************************************************************************

	** OUTLINE:		PART 0:	Select parts to run
              		PART 1: Install packages and Set directories
					PART 2: Run selected dofiles
					
	** REQUIRES:	
					
	** CREATES:		
					
	** NOTES:		

*******************************************************************************/
*                       	PART 0:  SELECT PARTS TO RUN                       *
********************************************************************************

* change 0 to 1 to select do-file to run
	local	organize		1	// Organize variables
	local	balance			0  // Produce balance tables
	local 	attrition		0	// Attrition analysis
	local   indicator 		0	// Run indicator level analysis
	
********************************************************************************
*                	PART 1:  INSTALL PACKAGES AND SET UP		               *
********************************************************************************

local user_commands ietoolkit iefieldkit sumstats 

	foreach command of local user_commands {
		cap which `command'
		if _rc == 111 ssc install `command'
	} // Note that this never updates outdated versions of already installed commands, to update commands use adoupdate

*Standardize settings accross users
	ieboilstart, version(13.1)  
	`r(version)'  

	*set global for today
	gl today :	display %tdCCYYNNDD date(c(current_date),"DMY")
	graph set window fontface "Open Sans"

********************************************************************************
*				PART 2:  PREPARE FOLDER PATHS AND DEFINE PROGRAMS			   *
*******************************************************************************/

* add your directory below
	display c(username)	// Get your username
	 
* set directories
* ---------------	
if "`c(username)'" == "nicolewu" {
	global rcari  	"/Users/nicolewu/Library/CloudStorage/OneDrive-WorldFoodProgramme/2_CARI_validation/1_rCARI_study/1_Pilot_country"
	global audit  "/Users/nicolewu/Library/CloudStorage/OneDrive-WorldFoodProgramme/Documents/ODK Briefcase Storage/forms"
	}
	
if "`c(username)'" == "alirah.weyori" {
	global rcari  "C:\Users\alirah.weyori\OneDrive - World Food Programme\2_CARI_validation\1_rCARI_study\1_Pilot_country"	
	}
	
	
	* Subfolder globals
	* -----------------
	gl all	 			"${rcari}/9_Comprehensive"
	gl CAR				"${rcari}/4_CAR"
	
	gl CAR_paper 		"${CAR}/9_Analysis/8_Manuscript"
	gl CAR_tex_tab 		"${CAR_paper}/1_table"
	gl CAR_tex_fig		"${CAR_paper}/2_figure"
	
	gl all_dta			"${all}/1_Data"
	gl all_dofile		"${all}/2_Dofile"
	gl all_logs 		"${all}/3_Log"
	gl all_temp 		"${all}/4_Temp"
	gl all_tabs 		"${all}/5_Tables"
	gl all_figs 		"${all}/6_Figures"
	gl all_paper 		"${all}/8_Manuscript"
	gl all_docs			"${all}/9_Documentation"
	
	gl all_paper_main 	"${all_paper}/1_Main_Report"	
	gl all_tex_tab 		"${all_paper_main}/1_table"
	gl all_tex_fig		"${all_paper_main}/2_figure"
	
	gl paper_d			"${all_paper}/2_Duration"
	gl tex_tab_d 		"${paper_d}/1_table"
	gl tex_fig_d		"${paper_d}/2_figure"
	
	gl paper_e			"${all_paper}/3_Expenditure"
	gl tex_tab_e 		"${paper_e}/1_table"
	gl tex_fig_e		"${paper_e}/2_figure"
	
	gl paper_adm5		"${all_paper}/9_Main_Admin5"
	gl tex_tab_adm5 	"${paper_adm5}/1_table"
	gl tex_fig_adm5		"${paper_adm5}/2_figure"
	
	gl paper_re 		"${all_paper}/8_Regroup"
	gl tex_tab_re 		"${paper_re}/1_table"
	gl tex_fig_re		"${paper_re}/2_figure"
	
	gl Myanmar_f2f		"${audit}/CARI Validation Study F2F_v1/instances"
	gl Myanmar_rm		"${audit}/CARI Validation Study Remote_v1/instances"
	
	gl Ecuador_f2f		"${audit}/CARI Estudio de validacion presencia _ESP_/instances"
	gl Ecuador_rm		"${audit}/CARI Estudio de Validacion Remoto _ESP_/instances"
	
********************************************************************************
*						PART 3:  RUN SELECTED SECTIONS						   *
********************************************************************************
	
* ------------------------------------------------------------------------------
* 							3.1 Organize variables
* ------------------------------------------------------------------------------
*
* 	REQUIRES:	${all_dta}/All_Full_Household_Analysis.dta
*			
* 	CREATES:	${all_dta}/All_Full_Household_Analysis_rCARI.dta
*				${all_dta}/Complete_Full_Household_Analysis_rCARI.dta
*
* ------------------------------------------------------------------------------
	
	if `organize'		do "${all_dofile}/01_Organize.do"

* ------------------------------------------------------------------------------
* 							3.2	Outcome Balance
* ------------------------------------------------------------------------------
*
* 	REQUIRES:	${all_dta}/Complete_Full_Household_rCARI_Analysis.dta
	
*	CREATES:	
*				
* ------------------------------------------------------------------------------	
	
	if `balance'		do "${all_dofile}/02_Balance.do"

* ------------------------------------------------------------------------------
* 							3.2	Attrition Balance
* ------------------------------------------------------------------------------
*
* 	REQUIRES:	${all_dta}/All_Full_Household_rCARI_Analysis.dta
	
*	CREATES:	
*				
* ------------------------------------------------------------------------------	
	
	if `attrition'		do "${all_dofile}/03_Attrition.do"

* ------------------------------------------------------------------------------
* 							Indicator Regrouping Analysis
* ------------------------------------------------------------------------------
*
* 	REQUIRES:	${all_dta}/All_Full_Household_rCARI_Analysis.dta
	
*	CREATES:	
*				
* ------------------------------------------------------------------------------	
	
	if `indicator'		do "${all_dofile}/99_Indicator.do"
	
* -------------	
* End of dofile
