/* *************************************************************************** *
*						WFP RAM-N rCARI Validation Study - CAR				   * 
*																 			   *
*  PURPOSE:  			Prepare overall sample list 						   *
*  AUTHOR: 				Nicole Wu (nicole.wu@wfp.org)						   *
*  DATE:  				Aug 12, 2023										   *
*  LATEST UPDATE: 															   *
*		  																	   *
********************************************************************************

					
	** REQUIRES:	${sample}/CAR_Sample_Merge.xlsx
					
	** CREATES:		${sample}/CAR_Sample_Merge.dta

	** NOTES:		

********************************************************************************
*							PART 1: Prepare Sample List
*******************************************************************************/
	
	cap log close 
	 
	// set log
	loc cdate: di %td_CCYY_NN_DD date(c(current_date), "DMY")
	loc cdate = subinstr(trim("`cdate'"), " " , "", .)
	log using "${d_log}/cd00_sample_prep_`cdate'.smcl", replace
	di `cdate'

	tempfile phone hhid
	
	import excel using "${sample}/HH_PhoneAssignment_Final.xls", ///
		  sheet("Sheet1") firstrow clear
	replace STATUS = 1 if STATUS == 0
	ren   STATUS   Assignment
	keep  ___index Assignment
	save `phone'
	
	import delimited "${sample}/Full_sample_Uid.csv", case(preserve) clear
	keep   Uid ___index
	save   `hhid'
	
	use "${sample}/CAR_rCARI_Sample_Randomization_Results.dta", clear
	compress
	
	mmerge ___index using `phone', type(1:1) uname(Phone_)
	replace Phone_Assignment = 0 if mi(Phone_Assignment)
	drop _merge
	
	mmerge ___index using `hhid', type(1:1) uname(ID_)
	ren ID_Uid	Uid
	drop _merge
	
	** keep relevant variables
	keep Admin1Name Admin2Name Admin3Name Admin5Name house_type age relationship ///
		 hh_status hh_head_sex hh_head_marital hh_head_educ hh_size 		///
		 mem_lessthan15 mem_greaterthan60 mem_disability area_house 		///
		 roofing_material_house floor_material_house phone_ownership 		///
		 mobile_coverage Modality_Type Length_Type Ind_OutSample 			///
		 Phone_Assignment Uid ___index
	
********************************************************************************
*							PART 2: Organize Sample Variables
*******************************************************************************/
	
	replace Modality_Type = Modality_Type + 1
	replace Length_Type   = Length_Type + 1
	
	ren Modality_Type 	Assign_Modality
	ren Length_Type		Assign_Length
	
	ren Admin1Name		Geo_Admin1
	ren Admin2Name		Geo_Admin2
	ren Admin3Name		Geo_Admin3
	ren Admin5Name		Geo_Admin5

	ren	   Uid HHID
	ren	   Phone_Assignment Assign_Phone
	
	order  HHID, first
	order  Assign_Modality Assign_Length Assign_Phone Geo_Admin*, a(HHID)
	order  relationship hh_status, a(age)
	order  hh_head_sex hh_head_marital, b(hh_head_educ)
	order  house_type area_house, a(mem_disability)
	
	* Randomly select 300 from the 737 non phone owner face to face
	set  seed 208976			// set stable seed
	sort ___index, stable
	gen  Select_RandomNum = uniform() if phone_ownership == 0 & ///
										 mobile_coverage == 1 & ///
										 Assign_Modality == 1
	egen Select_Order	  = rank(Select_RandomNum) 				///
									  if phone_ownership == 0 & ///
										 mobile_coverage == 1 & ///
										 Assign_Modality == 1
										 
	gen  Select_Yes 	  = (Select_Order <= 300) if phone_ownership == 0 & ///
										 mobile_coverage == 1 & ///
										 Assign_Modality == 1
	
	gen  	Random_Comparison = 1 if Select_Yes == 1		// F2F Random Partial
	replace Random_Comparison = 0 if Assign_Phone == 1	// Remote Gave Phone 
	
	drop Select_RandomNum Select_Order
	
********************************************************************************
*							PART 3: Label Sample Variables
*******************************************************************************/
	
	label def S_Modality  1 "Face to Face" 2 "Remote"
	label val Assign_Modality 	S_Modality
	
	label def S_Length	  1 "Short Form" 2 "Long Form"
	label val Assign_Length  	S_Length
	
	label var HHID 				"Household ID"
	label var Assign_Modality 	"Assigned Survey Modality"
	label var Assign_Length 	"Assigned Survey Length"
	label var Geo_Admin1 		"Geographic Region: Admin 1"
	label var Geo_Admin2 		"Geographic Region: Admin 2"
	label var Geo_Admin3 		"Geographic Region: Admin 3"
	label var Geo_Admin5 		"Geographic Region: Admin 5"
	
	label var age				"List respondent age"
	label var relationship		"List respondent relationship to head of household"
	label var hh_status			"Household residence status"
	label var hh_head_sex		"Household head sex"
	label var hh_head_marital	"Household head married"
	label var hh_head_educ		"Household head years of education"
	label var hh_size			"Household size"
	label var mem_lessthan15	"Number of household member younger than 15"
	label var mem_greaterthan60	"Number of household member older than 60"
	label var mem_disability	"Has household member with disability/chronic disease"
	label var area_house		"Number of rooms"
	label var house_type		"Permanent house/structure"
	label var roofing_material_house "Household main roof material"
	label var floor_material_house	 "Household main floor material"
	label var phone_ownership	"Household owns phone"
	label var mobile_coverage	"Household has mobile network coverage"
	label var Assign_Phone		"Assigned cell phone to no phone remote"
	label var Select_Yes 		"Randomly select 300 from no phone f2f"
	label var Random_Comparison "Indicator: comparing no phone f2f vs. rm"
	
	compress
	keep if Ind_OutSample == 0 
	drop Ind_OutSample ___index
	
	save  "${sample}/CAR_Sample_Merge.dta", replace

* -------------	
* End of dofile
