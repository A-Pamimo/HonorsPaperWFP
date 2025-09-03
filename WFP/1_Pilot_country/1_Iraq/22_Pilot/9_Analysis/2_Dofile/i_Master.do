/* *************************************************************************** *
*						WFP RAM-N rCARI Validation Study - Iraq 			   * 
*																 			   *
*  PURPOSE:  			Master dofile										   *
*  AUTHOR: 				Nicole Wu (nicole.wu@wfp.org)						   *
*  DATE:  				Mar 30, 2023										   *
*  LATEST UPDATE: 		Apr 17, 2023										   *
*		  																	   *
********************************************************************************

	** OUTLINE:		PART 0:	Select parts to run
              		PART 1: Install packages and Set directories
					PART 2: Run selected dofiles
					
	** REQUIRES:	${raw_f2f}/HH_Data_vA.dta
					${raw_f2f}/HH_Data_vB.dta
					
	** CREATES:		
					
	** NOTES:		

*******************************************************************************/
*                       	PART 0:  SELECT PARTS TO RUN                       *
********************************************************************************

* change 0 to 1 to select do-file to run
	local 	setup			1	// Set up datasets
	local	organize		1	// Organize variables
	local	a_rcsi			1	// Analyze rCSI indicators
	local 	a_rcsi_g 		1	// Analyze gendered rCSI indicators
	local	a_mdd			1	// Analyze MDD indicators
	local 	a_cari			0	// Analyze CARI indicators
	local	balance			0	// Create balance tables
	local 	stmd			0 	// Stata Markdown draft
	
********************************************************************************
*                	PART 1:  INSTALL PACKAGES AND SET UP		               *
********************************************************************************


local user_commands ietoolkit iefieldkit sumstats markstat whereis estout 

	foreach command of local user_commands {
		cap which `command'
		if _rc == 111 ssc install `command'
	} // Note that this never updates outdated versions of already installed commands, to update commands use adoupdate

*Standardize settings accross users
	ieboilstart, version(13.1)  
	`r(version)'  

	*set global for today
	gl today :	display %tdCCYYNNDD date(c(current_date),"DMY")
	graph set window fontface "Times New Roman"
	
	
********************************************************************************
*				PART 2:  PREPARE FOLDER PATHS AND DEFINE PROGRAMS			   *
*******************************************************************************/

	* add your directory below
	display c(username)	// Get your username and add path to the working folder
	
	global nicole    1
	global alirah    0

	* set the GD Folder
if $nicole {
	global rcari  	"/Users/nicolewu/Library/CloudStorage/OneDrive-WorldFoodProgramme/2_CARI_validation/1_rCARI_study/1_Pilot_country"
	}

	* Alirah to add
if $alirah {
	global rcari  "C:\Users\alirah.weyori\OneDrive - World Food Programme\2_CARI_validation\1_rCARI_study\1_Pilot_country"
	
	} 
	
	* Subfolder globals
	* -----------------

	gl iraq 		"${rcari}/1_Iraq"
	
	gl sample		"${iraq}/3_Sampling"
	gl raw_f2f		"${iraq}/8_Datasets/F2F"
	gl raw_rm		"${iraq}/8_Datasets/Remote"
	gl analysis 	"${iraq}/9_Analysis"
	
	gl dta			"${analysis}/1_Data"
	gl dofile		"${analysis}/2_Dofile"
	gl logs 		"${analysis}/3_Log"
	gl temp 		"${analysis}/4_Temp"
	gl tabs 		"${analysis}/5_Tables"
	gl figs 		"${analysis}/6_Figures"
	gl paper 		"${analysis}/8_Manuscript"
	gl docs			"${analysis}/9_Documentation"

	gl tabs_gender	"${tabs}/F2F_Gender"
	gl tabs_exp		"${tabs}/F2F_Expenditure"
	gl tabs_val		"${tabs}/rCARI_Validation"
	gl tabs_bal		"${tabs}/Balance"
	
	gl figs_gender	"${figs}/F2F_Gender"
	gl figs_exp		"${figs}/F2F_Expenditure"
	
	gl figs_tex		"${paper}/1_figures"
	gl tabs_tex		"${paper}/2_tables"
	
********************************************************************************
*						PART 3:  RUN SELECTED SECTIONS						   *
********************************************************************************

* ------------------------------------------------------------------------------
* 								Set up dataset
* ------------------------------------------------------------------------------
*
* 	REQUIRES:	${raw_f2f}/HH_Data_vA.dta
*				${raw_f2f}/HH_Data_vB.dta
*					
*	CREATES:	${docs}/Iraq_F2F_Codebook.xlsx
*				${dta}/Iraq_F2F_Household_Raw.dta
*
* ------------------------------------------------------------------------------
	
	if `setup'			do "${dofile}/i01a_setup_household.do"

* ------------------------------------------------------------------------------
* 							Organize variables
* ------------------------------------------------------------------------------
*
* 	REQUIRES:	${dta}/Iraq_F2F_Household_Raw.dta
*				
* 	CREATES:	${dta}/Iraq_F2F_Household_Analysis.dta
*
* ------------------------------------------------------------------------------
	
	if `organize'		do "${dofile}/i02a_f2f_organize.do"
	if `organize'		do "${dofile}/i02b_rm_organize.do"
	
* ------------------------------------------------------------------------------
* 							 Analysis: rCSI
* ------------------------------------------------------------------------------
*							
* 	REQUIRES:	${dta}/Iraq_F2F_Household_Analysis.dta
*					
* 	CREATES:	${temp}/Iraq_rCSI_F2F_Analysis.dta
*	
* ------------------------------------------------------------------------------
	
	if `a_rcsi'			do "${dofile}/i03_rCSI.do"
	
	if `a_rcsi_g'		do "${dofile}/i04_rCSI_gender.do"
	
	if `a_mdd'			do "${dofile}/i05_MDD.do"
	
* ------------------------------------------------------------------------------
* 								Stata Markdown
* ------------------------------------------------------------------------------	
*
*	REQUIRES:		
*	
*	CREATES:		${msmd}/.docx
*					${msmd}/.pdf				
*
* ------------------------------------------------------------------------------

	if `stmd'			do "${dofile}/i05_stmd.do"		
