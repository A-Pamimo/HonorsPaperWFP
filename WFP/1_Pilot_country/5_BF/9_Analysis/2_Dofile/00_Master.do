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
	local	balance			1  // Produce balance tables
	local 	attrition		1	// Attrition analysis
	local   indicator 		1	// Run indicator level analysis
	
********************************************************************************
*                	PART 1:  INSTALL PACKAGES AND SET UP		               *
********************************************************************************

local user_commands ietoolkit iefieldkit sumstats 

	foreach command of local user_commands {
		cap which `command'
		if _rc == 111 ssc install `command'
	} // Note that this never updates outdated versions of already installed commands, to update commands use adoupdate

*Standardize settings accross users
	ieboilstart, version(17.0)  
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
	* set the GD Folder
if "`c(username)'" == "nicolewu" {
	global rcari  	"/Users/nicolewu/Desktop/WFP/2_CARI_validation/1_rCARI_study/1_Pilot_country"
	}
	
if "`c(username)'" == "alirah.weyori" {
	global rcari  	"C:\Users\alirah.weyori\OneDrive - World Food Programme\2_CARI_validation\1_rCARI_study\1_Pilot_country"
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
	gl bf_docs		"${analysis}/4_Documentation"
	gl bf_temp		"${analysis}/5_Temp"
	
	gl out_tab		"${paper}/1_table"
	gl out_fig		"${paper}/2_figure"
	
********************************************************************************
*						PART 3:  RUN SELECTED SECTIONS						   *
********************************************************************************
	
* ------------------------------------------------------------------------------
* 							3.1 Organize variables
* ------------------------------------------------------------------------------

	if `organize'		do "${bf_dofile}/01_Organize.do"

* ------------------------------------------------------------------------------
* 							3.2	Outcome Balance
* ------------------------------------------------------------------------------

	if `balance'		do "${bf_dofile}/02_Balance.do"

* ------------------------------------------------------------------------------
* 							3.2	Attrition Balance
* ------------------------------------------------------------------------------

	if `attrition'		do "${bf_dofile}/03_Attrition.do"

* ------------------------------------------------------------------------------
* 							Indicator Analysis
* ------------------------------------------------------------------------------

	if `indicator'		do "${bf_dofile}/04_Indicator.do"
	
	* ------------------------------------------------------------------------------
* 							Expenditure analysis
* ------------------------------------------------------------------------------

	if `expenditure'		do "${bf_dofile}/05_Expenditure.do"

* ------------------------------------------------------------------------------
* 							Indicator Regrouping Analysis
* ------------------------------------------------------------------------------

	if `regroup'		do "${bf_dofile}/06_Regroup.do"
	
	
* -------------	
* End of dofile
