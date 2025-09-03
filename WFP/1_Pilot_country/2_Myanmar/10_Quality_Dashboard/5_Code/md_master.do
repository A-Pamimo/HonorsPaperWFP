/* *************************************************************************** *
*					WFP RAM-N rCARI Validation Study - Myanmar 				   * 
*																 			   *
*  PURPOSE:  			Master dofile										   *
*  AUTHOR: 				Nicole Wu (nicole.wu@wfp.org)						   *
*  DATE:  				May 12, 2023										   *
*  LATEST UPDATE: 		Jun  8, 2023										   *
*		  																	   *
********************************************************************************

	** OUTLINE:		PART 0:	Select parts to run
              		PART 1: Install packages and Set directories
					PART 2: Run selected dofiles
					
	** REQUIRES:	${d_raw}/Myanmar_F2F_Household_Raw_`cdate'.dta
					${d_raw}/Myanmar_F2F_Roster_Raw_`cdate'.dta
					${d_raw}/Myanmar_RM_Household_Raw_`cdate'.dta
					
	** CREATES:		
					
	** NOTES:		

*******************************************************************************/
*                       	PART 0:  SELECT PARTS TO RUN                       *
********************************************************************************
	

* change 0 to 1 to select do-file to run
	local	correct			1	// Correct field errors and de-duplcations
	local 	setup			1	// Set up datasets
	local	organize		1	// Organize variables
	local	append			1	// Append f2f and remote datasets for analysis
	local	hfc_sum			1	// Run high-frequency checks for quality monitoring
	
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
	display c(username)	// Get your username and add path to the working folder
	
	global nicole    1
	global alirah    0

	* set the GD Folder
if $nicole {
	global rcari  	"/Users/nicolewu/Library/CloudStorage/OneDrive-WorldFoodProgramme/2_CARI_validation/1_rCARI_study/1_Pilot_country"
	}
	
	if $alirah {
	global rcari  	"C:\Users\alirah.weyori\OneDrive - World Food Programme\2_CARI_validation\1_rCARI_study\1_Pilot_country"
	}
	
	* Subfolder globals
	* -----------------

	gl myanmar 		"${rcari}/2_Myanmar"

*	gl raw_f2f		"${myanmar}/8_Datasets/F2F"
*	gl raw_rm		"${myanmar}/8_Datasets/Remote"
	gl sample		"${myanmar}/3_Sampling"
	gl note			"${myanmar}/5_Field_notes"
	
	gl analysis 	"${myanmar}/9_Analysis"
	gl dashboard 	"${myanmar}/10_Quality_Dashboard"

	gl dta			"${analysis}/1_Data"
	gl dofile		"${analysis}/2_Dofile"
	gl logs 		"${analysis}/3_Log"
	gl temp 		"${analysis}/4_Temp"
	gl tabs 		"${analysis}/5_Tables"
	gl figs 		"${analysis}/6_Figures"
	gl paper 		"${analysis}/8_Manuscript"
	gl docs			"${analysis}/9_Documentation"

	gl d_raw		"${dashboard}/1_Raw"
	gl d_temp		"${dashboard}/2_Temp"
	gl d_log		"${dashboard}/3_Log"
	gl d_dta		"${dashboard}/4_Data"
	gl d_dofile		"${dashboard}/5_Code"
	gl d_report		"${dashboard}/6_Report"
	gl d_out		"${dashboard}/7_Output"
	
	gl d_tex_tab	"${d_report}/1_table"
	gl d_tex_fig	"${d_report}/2_figure"
	
	gl all	 		"${rcari}/9_Comprehensive"
	gl all_dta		"${all}/1_Data"
	
********************************************************************************
*						PART 3:  RUN SELECTED SECTIONS						   *
********************************************************************************
	** _`cdate' was removed after finishing data collection
* ------------------------------------------------------------------------------
* 							3.0 Correct field errors
* ------------------------------------------------------------------------------
*
* 	REQUIRES:	${d_raw}/Myanmar_F2F_Household_Raw_`cdate'.csv
*				${d_raw}/Myanmar_F2F_Roster_Raw_`cdate'.csv
*				${d_raw}/Myanmar_RM_Household_Raw_`cdate'.csv
*					
*	CREATES:	${d_temp}/Myanmar_F2F_Household_Correct_`cdate'.dta
*				${d_temp}/Myanmar_F2F_Roster_Correct_`cdate'.dta
*				${d_temp}/Myanmar_RM_Household_Correct_`cdate'.dta
*
* ------------------------------------------------------------------------------
	
	if `correct'		do "${d_dofile}/md00a_f2f_correct.do"
	if `correct'		do "${d_dofile}/md00b_roster_correct.do"
	if `correct'		do "${d_dofile}/md00c_rm_correct.do"
	
* ------------------------------------------------------------------------------
* 							3.1	Set up datasets
* ------------------------------------------------------------------------------
*
* 	REQUIRES:	${d_temp}/Myanmar_F2F_Roster_Correct_`cdate'.dta
					
*	CREATES:	${d_temp}/Myanmar_Roster_Prep_`cdate'.dta
*				${d_temp}/Myanmar_Roster_Household_Prep_`cdate'.dta
*				
* ------------------------------------------------------------------------------
	
	if `setup'			do "${d_dofile}/md01_setup_roster.do"
	
* ------------------------------------------------------------------------------
* 							3.2 Organize variables
* ------------------------------------------------------------------------------
*
* 	REQUIRES:	${d_temp}/Myanmar_F2F_Household_Prep_`cdate'.dta
*				${d_temp}/Myanmar_RM_Household_Correct_`cdate'.dta
*			
* 	CREATES:	${d_temp}/Myanmar_F2F_Household_Analysis_`cdate'.dta
*				${d_temp}/Myanmar_RM_Household_Analysis_`cdate'.dta
*
* ------------------------------------------------------------------------------
	
	if `organize'		do "${d_dofile}/md02a_f2f_organize.do"
	if `organize'		do "${d_dofile}/md02b_rm_organize.do"

* ------------------------------------------------------------------------------
* 							3.3	Organize datasets
* ------------------------------------------------------------------------------
*
* 	REQUIRES:	${d_temp}/Myanmar_F2F_Household_Analysis_`cdate'.dta
*				${d_temp}/Myanmar_RM_Household_Analysis_`cdate'.dta
	
*	CREATES:	${d_out}/Myanmar_Full_Household_Analysis_`cdate'.dta
*				
* ------------------------------------------------------------------------------	
	
	if `append'			do "${d_dofile}/md03_append.do"

* ------------------------------------------------------------------------------
* 							3.4	Run high-frequency checks
* ------------------------------------------------------------------------------
*
* 	REQUIRES:	${d_out}/Myanmar_Full_Household_Analysis_`cdate'.dta
*	
*	CREATES:	
*				
* ------------------------------------------------------------------------------	
	
	if `hfc_sum'		do "${d_dofile}/md04_hfc_sum.do"
	
* -------------	
* End of dofile
