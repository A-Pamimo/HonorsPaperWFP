/* *************************************************************************** *
*					WFP APP-FA rCARI Validation Study - BF 					   * 
*																 			   *
*  PURPOSE:  			Master dofile										   *
*  AUTHOR: 				Nicole Wu (yue.wu@berkeley.edu)						   *
*  DATE:  				Oct 28, 2024										   *
*  LATEST UPDATE: 		Oct 29, 2024										   *
*		  																	   *
********************************************************************************

	** OUTLINE:		PART 0:	Select parts to run
              		PART 1: Install packages and Set directories
					PART 2: Run selected dofiles
					
	** REQUIRES:	${d_raw}/BF_F2F_Household_Raw.dta
					${d_raw}/BF_F2F_Roster_Raw.dta
					${d_raw}/BF_RM_Household_Raw.dta
					
	** CREATES:		
					
	** NOTES:		

*******************************************************************************/
*                       	PART 0:  SELECT PARTS TO RUN                       *
********************************************************************************

* change 0 to 1 to select do-file to run
	local 	sample_prep		1	// Prepare sample list
	local	correct			1	// Correct field errors and de-duplcations
	local 	setup			1	// Set up datasets
	local	organize		1	// Organize variables
	local	append			1	// Append f2f and remote datasets for analysis
	
********************************************************************************
*                	PART 1:  INSTALL PACKAGES AND SET UP		               *
********************************************************************************
ssc install savespss
local user_commands ietoolkit iefieldkit sumstats 

	foreach command of local user_commands {
		cap which `command'
		if _rc == 111 ssc install `command'
	} // Note that this never updates outdated versions of already installed commands, to update commands use adoupdate

*Standardize settings accross users
	ieboilstart, version(17.0)  
	`r(version)'  

	*set global for today
	gl today:	display %tdCCYYNNDD date(c(current_date),"DMY")
	graph set window fontface "Open Sans"

********************************************************************************
*				PART 2:  PREPARE FOLDER PATHS AND DEFINE PROGRAMS			   *
*******************************************************************************/

	* add your directory below
	display c(username)	// Get your username and add path to the working folder
	
	* set the GD Folder
if "`c(username)'" == "nicolewu" {
	global rcari  	"/Users/nicolewu/Desktop/WFP/2_CARI_validation/1_rCARI_study/1_Pilot_country"
	}
	
if "`c(username)'" == "alirah.weyori" {
	global rcari  	"C:\Users\alirah.weyori\OneDrive - World Food Programme\2_CARI_validation - RAMN - Needs Assessments and Targeting Unit\1_rCARI_study\1_Pilot_country"
	}
	
	* Subfolder globals
	* -----------------
	gl BF 			"${rcari}/5_BF"
	
	gl sample		"${BF}/2_Sampling"
	gl hfc		 	"${BF}/7_HFC"
	gl notes		"${BF}/8_Field_notes"
	gl analysis 	"${BF}/9_Analysis"
	gl paper		"${BF}/10_Manuscript"
		
	gl hfc_raw		"${hfc}/1_Raw"
	gl hfc_dofile	"${hfc}/2_Code"
	gl hfc_temp		"${hfc}/3_Temp"
	gl hfc_out		"${hfc}/4_Output"
	gl hfc_note		"${hfc}/5_Notes"
	
	gl bf_dta		"${analysis}/1_Data"	
	gl bf_dofile	"${analysis}/2_Code"	
	gl bf_output	"${analysis}/3_Output"	
	
	gl out_tab		"${paper}/1_table"
	gl out_fig		"${paper}/2_figure"
	
	gl all	 		"${rcari}/9_Comprehensive"
	gl all_dta		"${all}/1_Data"
	
********************************************************************************
*						PART 3:  RUN SELECTED SECTIONS						   *
********************************************************************************

	if `sample_prep'	do "${hfc_dofile}/bf00_sample_prep.do"
		
* ------------------------------------------------------------------------------
* 							3.0 Correct field errors
* ------------------------------------------------------------------------------
	
	if `correct'		do "${hfc_dofile}/bf00a_f2f_correct.do"
	if `correct'		do "${hfc_dofile}/bf00b_roster_correct.do"
	if `correct'		do "${hfc_dofile}/bf00c_rm_correct.do"
	
* ------------------------------------------------------------------------------
* 							3.1	Set up datasets
* ------------------------------------------------------------------------------
	
	if `setup'			do "${hfc_dofile}/bf01_setup_roster.do"
	
* ------------------------------------------------------------------------------
* 							3.2 Organize variables
* ------------------------------------------------------------------------------
	
	if `organize'		do "${hfc_dofile}/bf02a_f2f_organize.do"
	if `organize'		do "${hfc_dofile}/bf02b_rm_organize.do"

* ------------------------------------------------------------------------------
* 							3.3	Organize datasets
* ------------------------------------------------------------------------------	
	
	if `append'			do "${hfc_dofile}/bf03_append.do"

* -------------	
* End of dofile
