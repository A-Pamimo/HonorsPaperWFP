/* *************************************************************************** *
*					WFP RAM-N rCARI Validation Study - CAR 				   * 
*																 			   *
*  PURPOSE:  			Master dofile										   *
*  AUTHOR: 				Nicole Wu (nicole.wu@wfp.org)						   *
*  DATE:  				Sep 18, 2023										   *
*  LATEST UPDATE: 		Sep 20, 2023										   *
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
	local	balance			1   // Produce balance tables
	local   cari			1 	// Run key analysis on CARI vs. rCARI
	local   gender			0 	// Run gendered analysis
	local 	wealth			0 	// Create wealth index
	local   excel 			1 	// Create result tables in Excel
	
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
	
	gl nicole 	0
	gl alirah   1
	
	* set the GD Folder
if $nicole {
	global rcari  	"/Users/nicolewu/Library/CloudStorage/OneDrive-WorldFoodProgramme/2_CARI_validation/1_rCARI_study/1_Pilot_country"
	}
	
			
if $alirah {
	global rcari  	"C:\Users\alirah.weyori\OneDrive - World Food Programme\2_CARI_validation\1_rCARI_study\1_Pilot_country"
	}
	
	
	
	* Subfolder globals
	* -----------------
	gl CAR 			"${rcari}/4_CAR"
	gl analysis 	"${CAR}/9_Analysis"

	gl dta			"${analysis}/1_Data"
	gl dofile		"${analysis}/2_Dofile"
	gl logs 		"${analysis}/3_Log"
	gl temp 		"${analysis}/4_Temp"
	gl tabs 		"${analysis}/5_Tables"
	gl figs 		"${analysis}/6_Figures"
	gl paper 		"${analysis}/8_Manuscript"
	gl docs			"${analysis}/9_Documentation"
	
	gl tex_tab 		"${paper}/1_table"
	gl tex_fig		"${paper}/2_figure"
	
********************************************************************************
*						PART 3:  RUN SELECTED SECTIONS						   *
********************************************************************************
	
* ------------------------------------------------------------------------------
* 							3.1 Organize variables
* ------------------------------------------------------------------------------
*
* 	REQUIRES:	${dta}/CAR_Full_Household_Analysis.dta
*			
* 	CREATES:	${dta}/CAR_Full_Household_Analysis_rCARI.dta
*
* ------------------------------------------------------------------------------
	
	if `organize'		do "${dofile}/c01_Organize.do"

* ------------------------------------------------------------------------------
* 							3.2	Randomization Balance
* ------------------------------------------------------------------------------
*
* 	REQUIRES:	${dta}/CAR_Full_Household_rCARI_Analysis.dta
	
*	CREATES:	
*				
* ------------------------------------------------------------------------------	
	
	if `balance'		do "${dofile}/c02_Balance.do"

* ------------------------------------------------------------------------------
* 							3.3	Main Results CARI vs. rCARI
* ------------------------------------------------------------------------------
*
* 	REQUIRES:	${dta}/CAR_Full_Household_rCARI_Analysis.dta
*	
*	CREATES:	
*				
* ------------------------------------------------------------------------------	
	
	if `cari'			do "${dofile}/c03_CARI.do"

* ------------------------------------------------------------------------------
* 							3.4	Gender Difference
* ------------------------------------------------------------------------------
*
* 	REQUIRES:	${dta}/CAR_Full_Household_rCARI_Analysis.dta
*	
*	CREATES:	
*				
* ------------------------------------------------------------------------------	
	
	if `gender'			do "${dofile}/c04_Gender.do"

* ------------------------------------------------------------------------------
* 								3.99 Excel
* ------------------------------------------------------------------------------
*
* 	REQUIRES:	${dta}/CAR_Full_Household_rCARI_Analysis.dta
*	
*	CREATES:	
*				
* ------------------------------------------------------------------------------	
	
	if `excel'			do "${dofile}/c99_Excel.do"
	
* -------------	
* End of dofilea
