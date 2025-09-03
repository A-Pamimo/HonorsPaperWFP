	  
	tempfile phone
	
	import excel using "${sample}/HH_PhoneAssignment_Final.xls", ///
		  sheet("Sheet1") firstrow clear
	replace STATUS = 1 if STATUS == 0
	ren   STATUS   Assignment
	keep  ___index Assignment
	save `phone'
	
	use "${sample}/CAR_rCARI_Sample_Randomization_Results.dta", clear
	
	mmerge ___index using `phone', type(1:1) uname(Phone_)
	replace Phone_Assignment = 0 if mi(Phone_Assignment)
	drop _merge
	
	replace Phone_Assignment = . if phone_ownership == 1 | mobile_coverage == 0 | Modality_Type == 0
	
** Initial Balance Test on Listing Charateristics
	
	gen HHHResp			= (relationship == 1)
	gen HHHRespSpouse	= (relationship == 2)
	gen HHDisplaced 	= (hh_status 	== 2)
	gen HHHFemale		= (hh_head_sex  == 0)
	gen HHHMarried		= (hh_head_marital == 1)
	
	gen 	HHCrowding	= hh_size/area_house
	sum 	HHCrowding
	replace HHCrowding  = `r(max)' if mi(HHCrowding)
	
** Randomly select 300 from the 737 non phone owner
	sort ___index, stable
	gen  Select_RandomNum = uniform() if phone_ownership == 0 & ///
										 mobile_coverage == 1 & ///
										 Modality_Type == 0
	egen Select_Order	  = rank(Select_RandomNum) 				///
									  if phone_ownership == 0 & ///
										 mobile_coverage == 1 & ///
										 Modality_Type == 0
										 
	gen  Select_Yes 	  = (Select_Order <= 300) if phone_ownership == 0 & ///
										 mobile_coverage == 1 & ///
										 Modality_Type == 0
	
	gen  	Random_Comparison = 1 if Select_Yes == 1		// F2F Random Partial
	replace Random_Comparison = 0 if Phone_Assignment == 1	// Remote Gave Phone 
	
*	gen 	HHRoof_Bad  = inlist(roofing_material_house, ）
	
	dtable age i.relationship i.hh_status i.hh_head_sex i.hh_head_marital  		///
		   hh_head_educ hh_size mem_lessthan15 mem_greaterthan60 mem_disability ///
		   area_house i.phone_ownership i.roofing_material_house    			///
		   i.floor_material_house, by(Modality_Type, test)			   			///
		   title(CAR rCARI Study - Balance Tests of Listed Sample Assignment)   ///
		   export(${sample}/CAR_rCARI_Listing_Assignment_Balance.docx, replace)

	gl list_var age HHHResp HHHRespSpouse HHDisplaced HHHFemale HHHMarried 		///
				hh_head_educ hh_size mem_lessthan15 mem_greaterthan60 			///
				mem_disability area_house HHCrowding
	
***************************** Balance for Randomization ************************
	
	** Quality of Randomization in Phone Owners
	iebaltab ${list_var} if phone_ownership == 1, grpvar(Modality_Type) ///
			 nonote onerow nototal replace								///
             format(%12.2fc) grplabels(0 F2F @ 1 Remote) rowvarlabels	///
             savexlsx("${bal}/CAR_rCARI_Listing_Assignment_OwnPhone_Balance.xlsx")
	
	** Quality of Randomization of Non Phone Owners
	iebaltab ${list_var} if phone_ownership == 0 & mobile_coverage == 1 	///
						 & Phone_Assignment != 0, 							///
			 grpvar(Modality_Type) nonote onerow nototal replace			///
             format(%12.2fc) grplabels(0 F2F @ 1 Remote) rowvarlabels		///
             savexlsx("${bal}/CAR_rCARI_Listing_Assignment_NoPhone_Balance.xlsx")
	
	** Quality of Randomization of Non Phone Owners - Assigning Phone
	iebaltab ${list_var}, grpvar(Random_Comparison) 							///
			 nonote onerow nototal replace format(%12.2fc) rowvarlabels			///
             grplabels(0 F2F Random Partial Sample @ 1 Remote Gave Phone) 	///
             savexlsx("${bal}/CAR_rCARI_Listing_Phone_Random_Partial_Assignment_Balance.xlsx")
	
	** Quality of Randomization for Phone Assignment
	iebaltab ${list_var}, grpvar(Phone_Assignment) 							///
			 nonote onerow nototal replace format(%12.2fc) rowvarlabels		///
             grplabels(0 Not Assigned Phone @ 1 Assigned Phone) 			///
             savexlsx("${bal}/CAR_rCARI_Listing_Phone_Assignment_Balance.xlsx")
	
	iebaltab ${list_var}, grpvar(Modality_Type) nonote onerow nototal replace	///
             format(%12.2fc) grplabels(0 F2F @ 1 Remote) rowvarlabels	///
             savexlsx("${bal}/CAR_rCARI_Listing_Assignment_Balance.xlsx")
			 
	iebaltab ${list_var} if Modality_Type == 0, grpvar(Length_Type) nonote 		///
			 onerow nototal replace	rowvarlabels 								///
             format(%12.2fc) grplabels(0 Short Form @ 1 Long Form ) 			///
             savexlsx("${bal}/CAR_rCARI_Listing_F2F_Length_Balance.xlsx")
			 
	iebaltab ${list_var} if Modality_Type == 1, grpvar(Length_Type) nonote 		///
			 onerow nototal replace	rowvarlabels 								///
             format(%12.2fc) grplabels(0 Short Form @ 1 Long Form ) 			///
             savexlsx("${sample}/CAR_rCARI_Listing_RM_Length_Balance.xlsx")
