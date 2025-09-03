/* *************************************************************************** *
*					WFP RAM-N rCARI Validation Study - CAR 					   * 
*																 			   *
*  PURPOSE:  			Create Attrition Weights										   *
*  AUTHOR: 				Nicole Wu (nicole.wu@wfp.org)						   *
*  DATE:  				Sep 20, 2023										   *
*  LATEST UPDATE: 		Oct 11, 2023										   *
*		  																	   *
********************************************************************************

	** OUTLINE:		PART 1: Install packages and Set directories
					PART 2: 
					
	** REQUIRES:	
					
	** CREATES:		
					
	** NOTES:		

*******************************************************************************/
*                     PART 1:  Install packages and Set directories            *
********************************************************************************

* set directories
* ---------------	
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

	* add your directory below
	display c(username)	// Get your username
	 
* set directories
* ---------------	
if "`c(username)'" == "nicolewu" {
	global Turkiye  "/Users/nicolewu/Library/CloudStorage/OneDrive-WorldFoodProgramme/2_CARI_validation/1_rCARI_study/1_Pilot_country"
	}
	
	* Subfolder globals
	* -----------------
	gl CAR 			"${rcari}/4_CAR"
	
	gl sample		"${CAR}/3_Sampling"
	gl analysis 	"${CAR}/9_Analysis"
	
	gl dta			"${analysis}/1_Data"
	gl dofile		"${analysis}/2_Dofile"
	gl logs 		"${analysis}/3_Log"
	gl temp 		"${analysis}/4_Temp"
	gl tabs 		"${analysis}/5_Tables"
	gl figs 		"${analysis}/6_Figures"
	gl paper 		"${analysis}/8_Manuscript"
	gl docs			"${analysis}/9_Documentation"
	
	gl all	 		"${rcari}/9_Comprehensive"
	gl all_dta		"${all}/1_Data"

*******************************************************************************/
*                   	  PART 2:  Prepare Listing Dataset            		   *
********************************************************************************
	
	tempfile listing
	
	* Select relevant variables for creating survey weights

	* Load data
	use "${sample}/CAR_Sample_Merge.dta", clear

	gen HHHResp		= (relationship == 1)
	gen HHDisplaced = (hh_status	== 2)
	gen HHHFemale	= (hh_head_sex  == 0)
	gen HHHMarried	= (hh_head_marital == 1)
	
	gen 	HHCrowding	= hh_size/area_house
	sum 	HHCrowding
	replace HHCrowding  = `r(max)' if mi(HHCrowding)

	compress
	save `listing'
