/* *************************************************************************** *
*					WFP APP-FA rCARI Validation Study - BF 					   * 
*																 			   *
*  PURPOSE:  			Prepare overall sample list 						   *
*  AUTHOR: 				Nicole Wu (yue.wu@berkeley.edu)						   *
*  DATE:  				Oct 28, 2024										   *
*  LATEST UPDATE: 		Oct 29, 2024										   *
*		  																	   *
********************************************************************************

					
	** REQUIRES:	${sample}/hhid.dta
					
	** CREATES:		${sample}/BF_Sample_Merge.dta

	** NOTES:		

********************************************************************************
*							PART 1: Prepare Sample List
*******************************************************************************/

	use "${sample}/Randomization_Results.dta", clear
	compress
	
	isid HHID
	
	** keep relevant variables
	keep Admin1Name Admin2Name Admin3Name Admin5Name house_type age relationship ///
		 hh_status hh_head_sex hh_head_marital hh_head_educ hh_size 		///
		 mem_lessthan15 mem_greaterthan60 mem_disability area_house 		///
		 roofing_material_house floor_material_house phone_ownership 		///
		 mobile_coverage Modality_Type Length_Type HHID
	
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
		
	order  HHID, first
	order  Assign_Modality Assign_Length Geo_Admin*, a(HHID)
	order  relationship hh_status, a(age)
	order  hh_head_sex hh_head_marital, b(hh_head_educ)
	order  house_type area_house, a(mem_disability)

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
	
	compress
	save  "${sample}/BF_Sample_Merge.dta", replace

* -------------	
* End of dofile
