/* *************************************************************************** *
*						WFP RAM-N rCARI Validation Study - CAR 			   	   * 
*																 			   *
*  PURPOSE:  			Set up appended dataset for full roster sample		   *
*  AUTHOR: 				Nicole Wu (nicole.wu@wfp.org)						   *
*  DATE:  														 			   *
*  LATEST UPDATE: 															   *
*		  																	   *
********************************************************************************

					
	** REQUIRES:	${d_temp}/CAR_F2F_Roster_Correct_`cdate'.dta
					
	** CREATES:		${d_temp}/CAR_Roster_Prep_`cdate'.dta
					${d_temp}/CAR_Roster_Household_Prep_`cdate'.dta
						
	** NOTES:		_`cdate' removed on Sep 18 when data collection was done

********************************************************************************
*					PART 1: Load Roster Data and Set codebook
*******************************************************************************/
	
	cap log close 

	// set log
	loc cdate: di %td_CCYY_NN_DD date(c(current_date), "DMY")
	loc cdate = subinstr(trim("`cdate'"), " " , "", .)
	log using "${d_log}/cd01_setup_roster_`cdate'.smcl", replace
	di `cdate'
	
* load dataset
* ------------
	use "${d_temp}/BKF_F2F_Roster_Correct.dta", clear 
	compress
	
	* create unique ID for each individual 
	makeid HH_Index ___index, gen(Ind_Index) project(CAR)
	
********************************************************************************
*					PART 2: Create Household Level Variables
*******************************************************************************/
	
	** Create household level tag variable to filter
	egen HH_Tag = tag(HH_Index)
	
	** [Quality Outcome] check if respondent is in the roster
	bysort	HH_Index: egen Num_Resp = total(RESPYN == 1)
	tab		Num_Resp if HH_Tag == 1		// should be 1
	gen		Err_Resp = (Num_Resp != 1)	

	** [Quality Outcome] check total number of hh member marked as head
	bysort 	HH_Index: egen Num_hhh = total(PRelationHHH == 100)
	tab 	Num_hhh if  HH_Tag == 1		// should be 1
	gen		Err_Head = (Num_hhh != 1)
	
	** [Quality Outcome] check total number of hh member marked as spouse
	bysort	HH_Index: egen Num_Spouse = total(PRelationHHH == 200)
	tab 	Num_Spouse if  HH_Tag == 1		// should be 0 or 1
	gen		Err_Spouse = (Num_Spouse > 1 & !mi(Num_Spouse))
	
	** [Quality Outcome] check respondent age and sex
	bysort HH_Index: egen Resp_Sex  = min(cond(RESPYN == 1, PSex, .))
	bysort HH_Index: egen Resp_Age  = min(cond(RESPYN == 1, PAge, .))

	** [Quality Outcome] check household size
	bysort HH_Index: gen Num_Ind = _n
	bysort HH_Index: egen Num_Household = max(Num_Ind)
*	bysort HH_Index: egen Num_Household_check = max(getP)

				********* Roster Error Flag - post HHID *********
				
	**	The age of the spouse is less than 9
	bysort HH_Index: egen Age_Spouse = min(cond(PRelationHHH == 200, PAge, .))
	gen	   Err_SpouseAge = (Age_Spouse < 9) if !mi(Age_Spouse)
	
	**	The age difference between parent and head is less than 9.
	bysort HH_Index: egen Age_Head	   = max(cond(PRelationHHH == 100, PAge, .))
	bysort HH_Index: egen Age_Parent = min(cond(PRelationHHH == 400, PAge, .))
	gen	   Err_ParentAge = (Age_Parent - Age_Head < 9) if !mi(Age_Parent) & !mi(Age_Head)
	
	**	The age of parent is less than 18
	gen	Err_ParentMinor = (Age_Parent < 18) if mi(Age_Parent)
	
	**	The hoh and his/her spouse have the same sex
	bysort HH_Index: gen Err_SameSex = (PRelationHHH == 200 & PSex == PSex[1] ///
									    & PRelationHHH[1] == 100)
	
				********* Roster Household-Level Outcomes  *********
	
	** [Respondent] Relationship to head of household
	bysort HH_Index: egen RESPRelationHHH = min(cond(RESPYN == 1, PRelationHHH, .))
	
	** [Demo] Head of Household Sex
	bysort HH_Index: egen HHH_Sex  = min(cond(PRelationHHH == 100, PSex, .))
	** [Demo] Head of Household Age
	bysort HH_Index: egen HHH_Age  = min(cond(PRelationHHH == 100, PAge, .))
	** [Demo] Head of Household Education
	bysort HH_Index: egen HHH_Literate  = min(cond(PRelationHHH == 100, PSchoolEver, .))
	bysort HH_Index: egen HHH_Education = min(cond(PRelationHHH == 100, PschoolLevel, .))
	
	** [Demo] Total Male & Female
	bysort	HH_Index: egen Num_Male   = total(PSex == 1)
	bysort	HH_Index: egen Num_Female = total(PSex == 0)
	
	** [Demo] Total number of children by sex
	bysort	HH_Index: egen Num_Child = total(PAge < 18)
	bysort	HH_Index: egen Num_Boy 	 = total(PSex == 1 & PAge < 18)
	bysort	HH_Index: egen Num_Girl  = total(PSex == 0 & PAge < 18)
	
	** [Demo] Total number of Senior
	bysort	HH_Index: egen Num_Senior = total(PAge >= 60)
	
	** [Demo] Total number of Adults
	bysort	HH_Index: egen Num_Adult = total(PAge >= 18 & PAge < 60)
		   
********************************************************************************
*							PART 3: Label new variables
*******************************************************************************/
	
	order Err_*, a(HH_Index)
	
	label val RESPRelationHHH 	PRelationHHH
	label val HHH_Sex Resp_Sex	PSex
	label val HHH_Literate		PSchoolEver
	label val HHH_Education		PschoolLevel
	
	label var HH_Index			"Household Index: Identifier"
	label var Num_Ind			"Individual Index: Household Size"
	label var Err_Resp			"Error: no or more than 1 respondent in roster"
	label var Err_Head			"Error: no or more than 1 household head in roster"
	label var Err_Spouse		"Error: no or more than 1 spouse in roster"
	label var Err_SpouseAge		"Error: age of the spouse < 9"
	label var Err_ParentAge		"Error: age diff between head and youngest parent < 9"
	label var Err_ParentMinor	"Error: age of parent < 18"
	label var Err_SameSex		"Error: head and spouse of same sex"
	label var Num_Resp			"Total number of respondent in roster"
	label var Num_hhh			"Total number of household head in roster"
	label var Num_Spouse		"Total number of spouse"
	label var Num_Household		"Total number of household member"
	label var Num_Male			"Total number of male household member"
	label var Num_Female		"Total number of female household member"
	label var Num_Boy			"Total number of boys (male under 18)"
	label var Num_Girl			"Total number of girls (female under 18)"
	label var Num_Senior		"Total number of senior"
	label var Num_Adult			"Total number of adults"
	label var Num_Child			"Total number of children"
	
	label var Age_Spouse		"Age of spouse (min if more than one)"
	label var Age_Head			"Age of household head"
	label var Age_Parent		"Age of parent (min if more than one)"
	
	label var Resp_Sex			"Respondent Sex"
	label var Resp_Age			"Respondent Age"
	label var RESPRelationHHH	"Respondent relationship to head of household"
	
	label var HHH_Sex			"Head of Household Sex"
	label var HHH_Age			"Head of Household Age"
	label var HHH_Literate		"Household head has attended school"
	label var HHH_Education		"Education level of household head"
	
********************************************************************************
*						PART 4: Organize dataset for merge
*******************************************************************************/
	
	save "${d_temp}/BKF_Roster_Prep.dta", replace
	
	** Only keep household level aggregate variables
	keep HH_Index HH_Tag Err_Resp Err_Head Num_Spouse Err_Spouse Err_SpouseAge	  ///
		 Err_ParentAge Err_ParentMinor Err_SameSex Num_Resp Num_Household  		  ///
		 Num_Spouse Resp_Sex Resp_Age RESPRelationHHH HHH_Sex HHH_Age 			  ///
		 HHH_Literate HHH_Education Num_Male Num_Female Num_Child Num_Boy 		  ///
		 Num_Girl Num_Senior Num_Adult
		 
	keep if HH_Tag == 1 
	drop 	HH_Tag
	
	save "${d_temp}/BKF_Roster_Household_Prep.dta", replace

********************************************************************************
*						PART 5: Merge to Household F2F dataset
*******************************************************************************/

	use "${d_temp}/BKF_F2F_Household_Correct.dta", clear
	
	mmerge HH_Index using "${d_temp}/BKF_Roster_Household_Prep.dta", ///
		   type(1:1) uname(R_)
		   
	drop if _merge == 2 // out of sample drop 
	drop _merge 
	
	compress
	save "${d_temp}/BKF_F2F_Household_Prep.dta", replace
	
* -------------	
* End of dofile
