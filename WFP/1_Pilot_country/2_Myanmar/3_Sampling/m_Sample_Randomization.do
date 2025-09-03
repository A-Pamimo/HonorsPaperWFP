/* *************************************************************************** *
*						WFP RAM-N rCARI Validation Study - Myanmar 			   * 
*																 			   *
*  PURPOSE:  			Randomization of Sample 							   *
*  AUTHOR: 				Nicole Wu (nicole.wu@wfp.org)						   *
*  DATE:  				May 10, 2023										   *
*  LATEST UPDATE: 															   *
*		  																	   *
********************************************************************************
					
	** REQUIRES:	"${sample}/Selected_villages and camps list_rCARI.xlsx"
					
	** CREATES:		"${sample}/Myanmar_rCARI_Sample_Randomization_Results_Shan.xlsx"
					
	** NOTES:		CampName "Qtr2 Lhaovo Baptist Church" has 76 households in 
					total, which is below the projected sample size. Thus, we 
					take all households in this village with randomly selected 
					90 households in other villages and equally & randomly 
					assigned them into
						- F2F (45 per village): 	Long (22) vs. Short (23)
						- Remote (45 per village):  Long (22) vs. Short (23)
						
					For "Qtr2 Lhaovo Baptist Church", 38 in each modality and
					19 for each length.

********************************************************************************
*                	PART 1:  INSTALL PACKAGES AND SET UP		               *
*******************************************************************************/


local user_commands ietoolkit iefieldkit sumstats markstat whereis 

	foreach command of local user_commands {
		cap which `command'
		if _rc == 111 ssc install `command'
	} 

*Standardize settings accross users
	ieboilstart, version(17.0)  
	`r(version)'  

	*set global for today
	gl today :	display %tdCCYYNNDD date(c(current_date),"DMY")

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
	global rcari  "C:\Users\alirah.weyori\World Food Programme\RAMN-N~1\018309~1.FOO\1ADA2~1.3RE\2_CARI~1\1_RCAR~1\1_PILO~1"
	
	} 
	
	* Subfolder globals
	* -----------------

	gl myanmar 		"${rcari}/2_Myanmar"
	
	gl sample		"${myanmar}/3_Sampling"
	gl analysis 	"${myanmar}/9_Analysis"
		
	gl dta			"${analysis}/1_Data"
	gl dofile		"${analysis}/2_Dofile"
	gl logs 		"${analysis}/3_Log"
	gl temp 		"${analysis}/4_Temp"
	gl tabs 		"${analysis}/5_Tables"
	gl figs 		"${analysis}/6_Figures"
	gl paper 		"${analysis}/8_Manuscript"
	gl docs			"${analysis}/9_Documentation"
	
********************************************************************************
*						PART 3:  RUN RANDOMIZATION - Kachin				       *
********************************************************************************

/*	tempfile test
	
	import excel "${sample}/Myanmar_rCARI_Sample_Randomization_Results_Kachin_test.xlsx", firstrow clear
	
	save `test'
*/
	* Load sample
	*------------
	import excel "${sample}/Selected_villages and camps list_rCARI.xlsx", ///
				 sheet("Kachin Phone Number") firstrow clear
				 
	drop G Samplingsetup I J Random
	ren  A Index
	
	missings dropvars, force 	// remove extra vars
	missings dropobs , force 	// remove empty observations

	* Set the environment to make randomization replicable
    isid Index, sort 
    set  seed 960502  //set the random seed for replication
	
	********* Sample selection
    bysort CampName: gen Sample_RandomNum = uniform() 
	// Generate random values between 0 to 1 
	
	bysort CampName: egen Sample_Order = rank(Sample_RandomNum) 
	// Order each observation from small to large
    
	gen 	Sample_Eligible = 1 if Sample_Order<= 90
	replace Sample_Eligible = 2 if mi(Sample_Eligible)
	
	bysort CampName: count if Sample_Eligible == 1

	bysort CampName: egen TotSample  = max(Sample_Order) if Sample_Eligible == 1
	
    * Assign sample frame to F2F and Remote 
	bysort CampName: gen  Modality_RandomNum = uniform() 			if Sample_Eligible == 1
	bysort CampName: egen Modality_Order = rank(Modality_RandomNum) if Sample_Eligible == 1
	
    gen 	Modality_Type = (Modality_Order <= TotSample/2) if Sample_Eligible == 1 
	
	********* Form Length 
	bysort CampName Modality_Type: gen  Length_RandomNum = uniform() 		  if !mi(Modality_Type)
	bysort CampName Modality_Type: egen Length_Order = rank(Length_RandomNum) if !mi(Modality_Type)
	bysort CampName Modality_Type: egen TotModality  = max(Length_Order) if Sample_Eligible == 1
	
	gen     Length_Type = (Length_Order <= TotModality/2) if Sample_Eligible == 1
	
	label var Index					"Sample Index"
	label var STREG 				"Region"
	label var Township 				"Township"
	label var CampName				"Village"
	label var Name					"Respondent Name"
	label var PhoneNumber			"Respondent Phone Number"
	label var UniqueID				"Unique ID"
	label var Sample_RandomNum		"Sample Selection: Random Number"
	label var Sample_Order			"Sample Selection: Order"
	label var Sample_Eligible		"Sample Selection: Eligibility"
	label var TotSample 			"Total number of household by Village"
	label var Modality_RandomNum	"Modality Assignment: Random Number"
	label var Modality_Order		"Modality Assignment: Order"
	label var Modality_Type			"Modality Assignment: Type"
	label var Length_RandomNum		"Form Length Assignment: Random Number"
	label var Length_Order			"Form Length Assignment: Order"
	label var TotModality			"Total number of household by Village and Modality"
	label var Length_Type			"Form Length Assignment: Type"
	
	label def Sample_L	 			1 "Selected"  2 "Not Selected"
	label val Sample_Eligible		Sample_L
		
	label def Modality_L			1 "Remote"	  0 "Face-to-Face"
	label val Modality_Type			Modality_L
	
	label def Length_L				1 "Long Form" 0 "Short Form"
	label val Length_Type			Length_L
	
	sort Sample_Eligible STREG Township CampName Modality_Type Length_Type, stable
	
/*	mmerge Index using `test'	, type(1:1) uname(a_)
*	
	global check_var Sample_RandomNum Sample_Order Sample_Eligible TotSample Modality_RandomNum Modality_Order Modality_Type Length_RandomNum Length_Order TotModality Length_Type
	
foreach var of global check_var {
	assert `var' == a_`var'
}
*/
	export excel using "${sample}/Myanmar_rCARI_Sample_Randomization_Results_Kachin.xlsx", ///
		   firstrow(variables) replace
		   
********************************************************************************
*						PART 4:  RUN RANDOMIZATION - Shan				       *
********************************************************************************

	* Load sample
	*------------
	import excel "${sample}/Selected_villages and camps list_rCARI.xlsx", ///
				 sheet("Shan Phone Number") firstrow clear
				 
	drop Samplingsetup I J Random VillageTract
	ren  A Index
	
	missings dropvars, force 	// remove extra vars
	missings dropobs , force 	// remove empty observations

	* Set the environment to make randomization replicable
    isid Index, sort 
    set  seed 960502  //set the random seed for replication
    
	** Generate Admin variables for randomization 
	// combine villages with less households)
	clonevar VillageAdmin = CampName
	replace  VillageAdmin = "Aung Tha Pyay & Namt Pha Kar KBC" 		///
			 if CampName == "Aung Tha Pyay" | CampName == "Namt Pha Kar KBC"
	replace  VillageAdmin = "Jaw-1 & St.Thomas" 					///
			 if CampName == "Jaw-1" | CampName == "St.Thomas"			  
	
	tab VillageAdmin
	
	********* Sample selection
    bysort VillageAdmin: gen Sample_RandomNum = uniform() 
	// Generate random values between 0 to 1 
	
	bysort VillageAdmin: egen Sample_Order = rank(Sample_RandomNum) 
	// Order each observation from small to large
    
	gen 	Sample_Eligible = 1 if Sample_Order<= 90
	replace Sample_Eligible = 2 if mi(Sample_Eligible)
	
	bysort VillageAdmin: count if Sample_Eligible == 1

	bysort VillageAdmin: egen TotSample  = max(Sample_Order) if Sample_Eligible == 1
	
    * Assign sample frame to F2F and Remote 
	bysort VillageAdmin: gen  Modality_RandomNum = uniform() if Sample_Eligible == 1
	bysort VillageAdmin: egen Modality_Order = rank(Modality_RandomNum) if Sample_Eligible == 1
	
    gen 	Modality_Type = (Modality_Order <= TotSample/2) if Sample_Eligible == 1 
	
	********* Form Length 
	
	bysort VillageAdmin Modality_Type: gen  Length_RandomNum = uniform() 		  if !mi(Modality_Type)
	bysort VillageAdmin Modality_Type: egen Length_Order = rank(Length_RandomNum) if !mi(Modality_Type)
	bysort VillageAdmin Modality_Type: egen TotModality  = max(Length_Order) if Sample_Eligible == 1
	
	gen     Length_Type = (Length_Order <= TotModality/2) if Sample_Eligible == 1
	
	label var Index					"Sample Index"
	label var STREG 				"Region"
	label var Township 				"Township"
	label var CampName				"Village"
	label var VillageAdmin			"Admin Village for Randomization"
	label var Name					"Respondent Name"
	label var PhoneNumber			"Respondent Phone Number"
	label var UniqueID				"Unique ID"
	label var Sample_RandomNum		"Sample Selection: Random Number"
	label var Sample_Order			"Sample Selection: Order"
	label var Sample_Eligible		"Sample Selection: Eligibility"
	label var TotSample 			"Total number of household by Village"
	label var Modality_RandomNum	"Modality Assignment: Random Number"
	label var Modality_Order		"Modality Assignment: Order"
	label var Modality_Type			"Modality Assignment: Type"
	label var Length_RandomNum		"Form Length Assignment: Random Number"
	label var Length_Order			"Form Length Assignment: Order"
	label var TotModality			"Total number of household by Village and Modality"
	label var Length_Type			"Form Length Assignment: Type"
	
	label def Sample_L	 			1 "Selected"  2 "Not Selected"
	label val Sample_Eligible		Sample_L
		
	label def Modality_L			1 "Remote"	  0 "Face-to-Face"
	label val Modality_Type			Modality_L
	
	label def Length_L				1 "Long Form" 0 "Short Form"
	label val Length_Type			Length_L
	
	sort Sample_Eligible STREG Township CampName Modality_Type Length_Type, stable
	
	export excel using "${sample}/Myanmar_rCARI_Sample_Randomization_Results_Shan.xlsx", ///
		   firstrow(variables) replace
