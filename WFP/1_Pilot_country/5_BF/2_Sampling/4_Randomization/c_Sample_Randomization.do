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
	
	global nicole    0
	global alirah    1

	* set the GD Folder
if $nicole {
	global rcari  	"/Users/nicolewu/Library/CloudStorage/OneDrive-WorldFoodProgramme/2_CARI_validation/1_rCARI_study/1_Pilot_country"
	}

	* Alirah to add
if $alirah {
	global rcari  "C:\Users\alirah.weyori\OneDrive - World Food Programme\2_CARI_validation - RAMN - Needs Assessments and Targeting Unit\1_rCARI_study\1_Pilot_country"
	} 
	
	* Subfolder globals
	* -----------------

	gl car 			"${rcari}/5_BF"
	gl sample		"${BF}/2_Sampling"
	gl bal			"${sample}/Balance"
	gl analysis 	"${BF}/9_Analysis"	
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
	use "${sample}\BKF census dataset_20240911.dta", clear		 
	compress 
	
	missings dropvars, force 	// remove extra vars
	missings dropobs , force 	// remove empty observations

	* Set the environment to make randomization replicable
    isid ___index, sort
    set  seed 208414  // bit.ly/stata-random set the random seed for replication 
	
	********* Sample selection
	** check consent
	keep if consentYN == 1 	// 76 observations dropped
	// ignore attrition on 2 rejecation out of 2513 total observations
	keep if !mi(Admin5Name)
	
	tab phone_ownership, nol  //744hhs without phone numbers
/*	dtable i.Admin1Name i.Admin2Name i.Admin3Name i.Admin5Name, 			///
		   by(phone_ownership) title(CAR rCARI Validation Study - Summary of Listed Sample ADMIN Distribution)  ///
		   export(${sample}/CAR_rCARI_Listed_Sample_ADMIN.docx, replace)
*/	  


********************************************************************************
****					GEN CONTROL STRATA
********************************************************************************

	*Livelihood source 
	gen livelihood_grp = .
	replace livelihood_grp = 1 if hh_head_Occup==1 | hh_head_Occup==2
	replace livelihood_grp = 2 if hh_head_Occup==3
	replace livelihood_grp = 3 if hh_head_Occup==4 | hh_head_Occup==5
	replace livelihood_grp = 4 if hh_head_Occup==6 | hh_head_Occup==7
	replace livelihood_grp = 5 if hh_head_Occup==9
	replace livelihood_grp = 6 if hh_head_Occup==999
	
	*Age_group
	gen age_group = .
	replace age_group = 1 if age < 40
	replace age_group = 2 if age >= 40 & age <= 55
	replace age_group = 3 if age >= 55 & age <= 65
	replace age_group = 4 if age > 65
	
	*Gender
	*HHHead gender
	
	*HHSize
	gen hhsize = .
	replace hhsize = 1 if hh_size < 5
	replace hhsize = 2 if hh_size >= 5 & hh_size <= 10
	replace hhsize = 3 if hh_size > 10
	
	
	*HHDisability
	gen hhdisabilty_status=.
	replace hhdisabilty_status=1 if mem_disability == 1
	replace hhdisabilty_status=0 if hhdisabilty_status==.
	
	*HHStatus
	gen idp_status= .
	replace idp_status= 1 if hh_status== 2 | hh_status==3
	replace idp_status= 0 if idp_status==.
	
	

********************************************************************************
*  SAMPLING THE FULL SAMPLE THROUGH RANDOM SAMPLING FROM THE CENSUS DATA
********************************************************************************
	keep if phone_ownership == 1

	*This excludes all households that did not own phones == 7% of the full sample 
	
	bysort Admin5Name: gen Sample_RandomNum = uniform() 
	// Generate random values between 0 to 1 
	
	bysort Admin5Name: egen Sample_Order = rank(Sample_RandomNum) 
	// Order each observation from small to large
    
	bysort Admin5Name: gen Sample_Eligible = 1 if Sample_Order<= 120
	replace Sample_Eligible = 2 if mi(Sample_Eligible)
	
	bysort Admin5Name: count if Sample_Eligible == 1

	bysort Admin5Name: egen TotSample  = max(Sample_Order) if Sample_Eligible == 1
	
********************************************************************************
*						PART 3:  RUN RANDOMIZATION - Own Phone			       *
********************************************************************************	
	
	    * Assign sampled household with phone to F2F and Remote 
	sort Admin5Name idp_status hhdisabilty_status hhsize age_group livelihood_grp hh_head_sex, stable
	by Admin5Name: gen  Modality_RandomNum_P = uniform() 			  ///
				   if Sample_Eligible == 1
	by Admin5Name: egen Modality_Order_P = rank(Modality_RandomNum_P) ///
				   if Sample_Eligible == 1
	by Admin5Name: egen TotSample_P  = max(Modality_Order_P) 		  ///
				   if Sample_Eligible == 1
	
    gen    Modality_Type_P = (Modality_Order_P <= TotSample_P/2) 	  ///
		   if Sample_Eligible == 1
	
	********* Form Length
	sort Admin5Name Modality_Type_P, stable
	by Admin5Name Modality_Type_P: gen  Length_RandomNum_P = uniform() ///
								   if !mi(Modality_Type_P)
	by Admin5Name Modality_Type_P: egen Length_Order_P = rank(Length_RandomNum_P) ///
								   if !mi(Modality_Type_P)
	by Admin5Name Modality_Type_P: egen TotModality_P  = max(Length_Order_P) ///
								   if Sample_Eligible == 1
	
	gen    Length_Type_P = (Length_Order_P <= TotModality_P/2) 			   ///
		   if Sample_Eligible == 1
	

	

********************************************************************************
/*						PART 4:  RUN RANDOMIZATION - No Phone			       *
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
*/	
	gen		  Modality_Type = Modality_Type_P  if  phone_ownership == 1
		
	gen 	  Length_Type 	= Length_Type_P    if  phone_ownership == 1
		
	label var Modality_Type			"Modality Assignment: Type"
	label var Length_Type			"Form Length Assignment: Type"
	
	label def Modality_L			1 "Remote"	  0 "Face-to-Face"
	label val Modality_Type			Modality_L
	
	label def Length_L				1 "Long Form" 0 "Short Form"
	label val Length_Type			Length_L
	
	sort Modality_Type Length_Type, stable
	
	save "${sample}/BKF_rCARI_Sample_Randomization_Results.dta", replace
	
	export excel using "${sample}/BKF_rCARI_Sample_Randomization_Results_${today}.xlsx", ///
		   firstrow(variables) replace
