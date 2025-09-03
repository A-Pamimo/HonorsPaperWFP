/* *************************************************************************** *
*						WFP RAM-N rCARI Validation Study - Myanmar 			   * 
*																 			   *
*  PURPOSE:  			Correct field errors for F2F Household 				   *
*  AUTHOR: 				Nicole Wu (nicole.wu@wfp.org)						   *
*  DATE:  				May 11, 2023										   *
*  LATEST UPDATE: 		Jul 03, 2023										   *
*		  																	   *
********************************************************************************
	
	** REQUIRES:	${d_raw}/Myanmar_F2F_Household_Raw_`cdate'.csv
					
	** CREATES:		${d_temp}/Myanmar_F2F_Household_Correct_`cdate'.dta

	** NOTES:		_`cdate' was removed after finishing data collection

********************************************************************************
*					PART 1: Load Household Data and Correct Errors
*******************************************************************************/
	
	cap log close 
	
	// set log
	loc cdate: di %td_CCYY_NN_DD date(c(current_date), "DMY")
	loc cdate = subinstr(trim("`cdate'"), " " , "", .)
	log using "${d_log}/md00a_f2f_correct_`cdate'.smcl", replace
	di `cdate'
	
* load dataset
* ---------------	
	use "${d_raw}/Myanmar_F2F_Household_Raw.dta", clear
	compress
	
	* basic quality checks and formating
	ds, has(type string) 
	** remove unnecessary blanks in string and adjust the proper cases
	local strvars "`r(varlist)'"
foreach var of local strvars {
    replace `var' = strtrim(`var')
    }
	
	** error log #16
	replace HHID = "00903553E0" if ___uuid == "365fd290-351b-4428-9e78-1bbb9f825b50"
	replace sampleYN = 1 		if ___uuid == "365fd290-351b-4428-9e78-1bbb9f825b50"
	
	** error log #1-6
	drop if sampleYN == 0
	
	** error log #22
	replace HHID = "066F10AB0" if ___uuid == "cd7e5f01-6e31-47b9-adcb-957fe246b381"	
	
	** error log #23 ?? no change, why
	replace HHID = "02E617DF6" if ___uuid == "0680192a-8dd8-4526-96d7-09b173117e07"
	
	** error log #24
	replace HHID = "04DEA1AD4" if ___uuid == "c80eba41-77d7-4f14-a470-223b4290597c"
	
	** error log #26
	drop if ___uuid == "a5dadadd-e6f0-4e40-b025-535b5febb2a5"
	
	** error log #31
	replace HHID = "02683BA01" if ___uuid == "e2e19d32-da14-4239-93af-fa0a12556771"
	
	** resolve unmatched ID
	replace HHID = "0090355MM0" if ___uuid == "365fd290-351b-4428-9e78-1bbb9f825b50"
	drop if ___uuid == "cf1e7ba4-648f-4cb6-9eb7-70c5c3dde17e"
	
	ieduplicates HHID using "${note}/Myanmar_F2F_DuplicateID_`cdate'.xlsx", 		///
				 keepvar(EnuName_Display) uniquevars(___uuid) nodaily force				
	
	isid HHID	 				// check unique identifier
	
	** Household size correction to the roster number
	replace HHSize = 6 if ___uuid == "d599ca01-01ce-447c-95a8-b71b45469393"
	replace HHSize = 2 if ___uuid == "b573d037-6c78-419f-9c08-ac7d07bbc931"
	replace HHSize = 2 if ___uuid == "1ce460f1-61a4-4c6c-808a-e1cd5449bfd6"

	** Age and Gender Difference
	replace RESPSex = 1 if ___uuid == "d8efa770-80ff-4ea3-b272-8ddd446c334b"
	replace RESPSex = 1 if ___uuid == "742e69a3-f49b-4008-ab56-6689a2be7962"
*	replace RESPSex = 1 if ___uuid == "2d5ae396-481b-4e4c-b3bb-e66f981e62b2"

	replace RESPSex = 0 if ___uuid == "e17257d8-4cae-4572-93b6-6a8d519f5180"
	replace RESPSex = 0 if ___uuid == "8a7c4ecf-0bc3-4bf8-8d09-bc129a3cb7cd"
	replace RESPSex = 0 if ___uuid == "344e35a0-6951-4c7e-aef8-4f6cfaba9a9b"
	replace RESPSex = 0 if ___uuid == "bd8ebc77-4bd4-419d-9424-0475731726bf"
	replace RESPSex = 0 if ___uuid == "66457c8a-93fe-46a4-9311-2d7fa2a128cf"
	
	replace RESPAge = 21 if ___uuid == "a80599ad-9564-46b3-8cb3-c37374ab04a3"
	replace RESPAge = 61 if ___uuid == "36da3dff-49d0-4ae9-bbe4-8f878e4223c5"
	replace RESPAge = 52 if ___uuid == "f59fe26e-03b5-48da-90fc-16b570de7b71"
	replace RESPAge = 29 if ___uuid == "7681faf0-ff35-401a-b085-ca3d2ca1cb46"
	replace RESPAge = 45 if ___uuid == "2083680e-3666-4eb9-bf90-1442477d89c8"
	replace RESPAge = 60 if ___uuid == "6aec639f-f65a-45db-8595-da815c7b4652"
	replace RESPAge = 54 if ___uuid == "2c1dc8af-497b-4e08-b08d-fef5a59a0e95"
	replace RESPAge = 48 if ___uuid == "da782ce1-153d-4c60-99e0-2fd0fdb39809"
	replace RESPAge = 43 if ___uuid == "5cc2965d-3a56-4428-8645-3725cf63e09e"
	replace RESPAge = 25 if ___uuid == "cdb86f6b-80cc-406c-a8b4-1cacedc0ce24"
	replace RESPAge = 56 if ___uuid == "f6da2c32-1151-418e-acd4-9904d94491ea"
	replace RESPAge = 67 if ___uuid == "251b35fb-e850-438d-9990-f783cc7088a3"
	replace RESPAge = 50 if ___uuid == "66457c8a-93fe-46a4-9311-2d7fa2a128cf"
	replace RESPAge = 41 if ___uuid == "2bc7836c-594a-4d7a-ab52-e3635e4ded3b"
	// check again with the real survey data
	ren ___index	HH_Index
		
*************************  ADD CORRECTION LINES HERE ***************************
	
	compress
	save "${d_temp}/Myanmar_F2F_Household_Correct.dta", replace

* -------------	
* End of dofile
