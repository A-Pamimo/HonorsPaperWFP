/* *************************************************************************** *
*						WFP RAM-N rCARI Validation Study - CAR 				   * 
*																 			   *
*  PURPOSE:  			Randomization of Sample 							   *
*  AUTHOR: 				Nicole Wu (nicole.wu@wfp.org)						   *
*						Alirah Weyori (alirah.weyori@wfp.org)				   *
*  DATE:  				Jul 31, 2023										   *
*  LATEST UPDATE: 															   *
*		  																	   *
********************************************************************************
					
	** REQUIRES:	"${sample}/Listed HHs for CAR_20230731.xlsx"
					
	** CREATES:		"${sample}/CAR_rCARI_Sample_Randomization_Results.xlsx"
					
	** NOTES:		1. Full sample randomization since we already randomly selected
					   them in the listing and only 2 rejections
					2. Separate randomization based on phone ownership: 25% have phones
					3. Filter out those 1) assigned with remote
										2) without phones
										3) has coverage 
					   to give phones

********************************************************************************
*                	PART 1:  INSTALL PACKAGES AND SET UP		               *
*******************************************************************************/

local user_commands ietoolkit iefieldkit 

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

	gl car 			"${rcari}/4_CAR"
	
	gl sample		"${car}/3_Sampling"
	gl bal			"${sample}/Balance"
	
	gl analysis 	"${car}/9_Analysis"	
	gl dta			"${analysis}/1_Data"
	gl dofile		"${analysis}/2_Dofile"
	gl logs 		"${analysis}/3_Log"
	gl temp 		"${analysis}/4_Temp"
	gl tabs 		"${analysis}/5_Tables"
	gl figs 		"${analysis}/6_Figures"
	gl paper 		"${analysis}/8_Manuscript"
	gl docs			"${analysis}/9_Documentation"
	
	
	* Load sample
	*------------
	use "${sample}/Listed HHs for CAR_20230731.dta", clear		 
	compress 
	
	missings dropvars, force 	// remove extra vars
	missings dropobs , force 	// remove empty observations

	* Set the environment to make randomization replicable
    isid ___index, sort
    set  seed 208976  // bit.ly/stata-random set the random seed for replication 
	
	********* Sample selection
	** check consent
	keep if consentYN == 1 	// 2 observations dropped
	// ignore attrition on 2 rejecation out of 2513 total observations
	keep if !mi(Admin5Name)
	
	tab phone_ownership, nol
/*	dtable i.Admin1Name i.Admin2Name i.Admin3Name i.Admin5Name, 			///
		   by(phone_ownership) title(CAR rCARI Validation Study - Summary of Listed Sample ADMIN Distribution)  ///
		   export(${sample}/CAR_rCARI_Listed_Sample_ADMIN.docx, replace)
*/	  

********************************************************************************
*						PART 3:  RUN RANDOMIZATION - Own Phone			       *
********************************************************************************	
	
	* keep if phone_ownership == 1
	
    * Assign sampled household with phone to F2F and Remote 
	sort Admin5Name, stable
	by Admin5Name: gen  Modality_RandomNum_P = uniform() 			  ///
				   if phone_ownership == 1
	by Admin5Name: egen Modality_Order_P = rank(Modality_RandomNum_P) ///
				   if phone_ownership == 1
	by Admin5Name: egen TotSample_P  = max(Modality_Order_P) 		  ///
				   if phone_ownership == 1
	
    gen    Modality_Type_P = (Modality_Order_P <= TotSample_P/2) 	  ///
		   if phone_ownership == 1 
	
	********* Form Length
	sort Admin5Name Modality_Type_P, stable
	by Admin5Name Modality_Type_P: gen  Length_RandomNum_P = uniform() ///
								   if !mi(Modality_Type_P)
	by Admin5Name Modality_Type_P: egen Length_Order_P = rank(Length_RandomNum_P) ///
								   if !mi(Modality_Type_P)
	by Admin5Name Modality_Type_P: egen TotModality_P  = max(Length_Order_P) ///
								   if phone_ownership == 1
	
	gen    Length_Type_P = (Length_Order_P <= TotModality_P/2) 			   ///
		   if phone_ownership == 1
	
	** check in Own Phone group, assigned to Remote but without coverage
	count if Modality_Type_P == 1 & mobile_coverage == 0 // 68

********************************************************************************
*						PART 4:  RUN RANDOMIZATION - No Phone			       *
********************************************************************************	
	
	* keep if phone_ownership == 0
	sort Admin5Name, stable
    * Assign sampled household with phone to F2F and Remote 
	by Admin5Name: gen  Modality_RandomNum_NP = uniform() 			  	///
				   if phone_ownership == 0
	by Admin5Name: egen Modality_Order_NP = rank(Modality_RandomNum_NP) ///
				   if phone_ownership == 0
	by Admin5Name: egen TotSample_NP  = max(Modality_Order_NP) 		  	///
				   if phone_ownership == 0
	
    gen    Modality_Type_NP = (Modality_Order_NP <= TotSample_NP/2) 	    ///
		   if phone_ownership == 0
	
	********* Form Length 
	sort Admin5Name Modality_Type_NP, stable
	by Admin5Name Modality_Type_NP: gen  Length_RandomNum_NP = uniform() 	///
									if !mi(Modality_Type_NP)
	by Admin5Name Modality_Type_NP: egen Length_Order_NP = rank(Length_RandomNum_NP) ///
									if !mi(Modality_Type_NP)
	by Admin5Name Modality_Type_NP: egen TotModality_NP  = max(Length_Order_NP) ///
									if phone_ownership == 0
	
	gen    Length_Type_NP = (Length_Order_NP <= TotModality_NP/2) 			   ///
		   if phone_ownership == 0
	
	** check in Own Phone group, assigned to Remote but without coverage
	count if Modality_Type_NP == 1 & mobile_coverage == 0 // 213
	gen   FLAG_Remote_NoPhone_NoCoverage = (Modality_Type_NP == 1 & mobile_coverage == 0)
	
	count if Modality_Type_NP == 1 & mobile_coverage == 1 // 715
	
	gen Ind_OutSample = (phone_ownership == 0 & mobile_coverage == 0)
	
	
********************************************************************************
*							PART 5:  Label Variables			     		   *
********************************************************************************	
	
	gen		  Modality_Type = Modality_Type_P  if  phone_ownership == 1
	replace	  Modality_Type = Modality_Type_NP if  phone_ownership == 0
	
	replace   Modality_Type = . if FLAG_Remote_NoPhone_NoCoverage == 1
	
	gen 	  Length_Type 	= Length_Type_P    if  phone_ownership == 1
	replace   Length_Type 	= Length_Type_NP   if  phone_ownership == 0
	
	replace   Length_Type	= . if FLAG_Remote_NoPhone_NoCoverage == 1
	
	label var Modality_Type			"Modality Assignment: Type"
	label var Length_Type			"Form Length Assignment: Type"
	label var Ind_OutSample			"Households to be dropped"
	
	label def Modality_L			1 "Remote"	  0 "Face-to-Face"
	label val Modality_Type			Modality_L
	
	label def Length_L				1 "Long Form" 0 "Short Form"
	label val Length_Type			Length_L
	
	sort Modality_Type Length_Type, stable
	
	save "${sample}/CAR_rCARI_Sample_Randomization_Results.dta", replace
	
*	export excel using "${sample}/CAR_rCARI_Sample_Randomization_Results_${today}.xlsx", ///
		   firstrow(variables) replace
